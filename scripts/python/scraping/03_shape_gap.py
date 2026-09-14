"""
File:      03_shape_gap.py
Purpose:   THE pilot test (proposal risk #1). For establishments with a histogram
           on BOTH platforms, compute distribution-shape moments per platform and
           test the H1 predictions with paired within-establishment tests. Emits a
           GO / STOP verdict, a moments table, and a publication-ready figure.
Inputs:    data/scraped/histograms_long.csv
Outputs:   scripts/python/_outputs/shape_gap_moments.csv
           scripts/python/_outputs/pilot_verdict.txt
           scripts/python/_outputs/fig_shape_gap.{pdf,png}
Run order: after 02_scrape_histograms.py.

Note: coarse 5-bin histograms + small counts make effect SIZES more informative
than p-values. The verdict weighs direction + median magnitude, not just p.
"""
from __future__ import annotations
import sys
import numpy as np
import pandas as pd
from scipy.stats import wilcoxon
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

import config

MIN_REVIEWS = 10   # also report restricted to establishments with >= this many reviews per platform

# H1: predicted sign of (google - yelp) paired difference for each moment.
PREDICTIONS = {
    "variance":     "neg",   # Google less dispersed
    "polarization": "neg",   # Google lower 1★+5★ mass
    "middle_mass":  "pos",   # Google higher 2★–4★ mass
    "share_1":      "neg",
    "share_5":      "neg",
}
CORE = ("variance", "polarization", "middle_mass")   # the load-bearing shape moments


def moments(counts: np.ndarray) -> dict:
    n = counts.sum()
    p = counts / n
    stars = np.array(config.STARS, dtype=float)
    mean = float((stars * p).sum())
    var = float(((stars - mean) ** 2 * p).sum())
    return {"n_reviews": int(n), "mean": mean, "variance": var,
            "polarization": float(p[0] + p[4]),
            "middle_mass": float(p[1] + p[2] + p[3]),
            "share_1": float(p[0]), "share_5": float(p[4])}


def build_moments(long: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for (est_id, platform), g in long.groupby(["est_id", "platform"]):
        g = g.sort_values("star")
        if list(g["star"]) != list(config.STARS):
            continue
        counts = g["count"].to_numpy(dtype=float)
        if counts.sum() <= 0:
            continue
        rows.append({"est_id": est_id, "platform": platform, **moments(counts)})
    return pd.DataFrame(rows)


def paired(mom: pd.DataFrame) -> pd.DataFrame:
    wide = mom.pivot(index="est_id", columns="platform")
    if ("mean", "google") not in wide.columns or ("mean", "yelp") not in wide.columns:
        return pd.DataFrame()
    keep = wide.dropna(subset=[(m, p) for m in ["mean", "variance"] for p in ["google", "yelp"]]).index
    return wide.loc[keep]


def test_block(wide: pd.DataFrame, label: str, out) -> int:
    """Run paired tests; return count of CORE moments confirmed (direction+sig)."""
    n = len(wide)
    print(f"\n=== {label} (n = {n} matched establishments) ===", file=out)
    if n < 8:
        print("  too few paired establishments for a meaningful test.", file=out)
        return 0
    # mean gap, for the shape-vs-level contrast (H3 preview)
    mean_gap = (wide[("mean", "google")] - wide[("mean", "yelp")]).abs().median()
    print(f"  median |mean gap|: {mean_gap:.3f} stars", file=out)
    confirmed = 0
    print(f"  {'moment':<13}{'median Δ(G−Y)':>15}{'pred':>6}{'dir?':>6}{'wilcoxon p':>13}", file=out)
    for m, pred in PREDICTIONS.items():
        diff = (wide[(m, "google")] - wide[(m, "yelp")]).to_numpy()
        med = float(np.median(diff))
        dir_ok = (med < 0) if pred == "neg" else (med > 0)
        try:
            p = float(wilcoxon(diff, zero_method="wilcox", alternative="two-sided").pvalue)
        except ValueError:
            p = float("nan")
        sig = (p < 0.05)
        if m in CORE and dir_ok and sig:
            confirmed += 1
        print(f"  {m:<13}{med:>15.4f}{pred:>6}{('yes' if dir_ok else 'NO'):>6}{p:>13.4g}", file=out)
    return confirmed


def make_figure(wide: pd.DataFrame):
    fig, axes = plt.subplots(1, 3, figsize=(12, 4), dpi=300)
    for ax, m in zip(axes, CORE):
        g, y = wide[(m, "google")], wide[(m, "yelp")]
        lo, hi = float(min(g.min(), y.min())), float(max(g.max(), y.max()))
        ax.scatter(y, g, s=14, alpha=0.6, edgecolor="none")
        ax.plot([lo, hi], [lo, hi], lw=1, color="0.4", ls="--")   # 45° = no gap
        ax.set_xlabel(f"Yelp {m}")
        ax.set_ylabel(f"Google {m}")
        ax.set_title(m)
    fig.suptitle("H1 pilot: same-establishment rating-distribution shape, Google vs Yelp\n"
                 "(points off the dashed 45° line = a shape gap)", fontsize=10)
    fig.tight_layout(rect=(0, 0, 1, 0.92))
    for ext in ("pdf", "png"):
        fig.savefig(config.OUT / f"fig_shape_gap.{ext}", bbox_inches="tight",
                    facecolor="white")
    plt.close(fig)


def main() -> int:
    long_path = config.DATA_SCRAPED / "histograms_long.csv"
    if not long_path.exists():
        print("[03] run 02_scrape_histograms.py first.", file=sys.stderr)
        return 1
    long = pd.read_csv(long_path)
    mom = build_moments(long)
    if mom.empty:
        print("[03] no usable histograms.", file=sys.stderr)
        return 1
    mom.to_csv(config.OUT / "shape_gap_moments.csv", index=False)

    wide = paired(mom)
    verdict_path = config.OUT / "pilot_verdict.txt"
    with open(verdict_path, "w", encoding="utf-8") as out:
        print("SILENCE-OF-THE-SATISFIED — H1 HISTOGRAM PILOT", file=out)
        if wide.empty:
            print("No establishments matched on both platforms — cannot test H1.", file=out)
            print(open(verdict_path, encoding="utf-8").read())
            return 1
        confirmed_all = test_block(wide, "ALL matched establishments", out)
        # Restrict to establishments with enough reviews on both platforms.
        enough = wide[(wide[("n_reviews", "google")] >= MIN_REVIEWS) &
                      (wide[("n_reviews", "yelp")] >= MIN_REVIEWS)]
        confirmed_rich = test_block(enough, f"establishments with >= {MIN_REVIEWS} reviews/platform", out)

        best = max(confirmed_all, confirmed_rich)
        print("\n--- VERDICT ---", file=out)
        if best == 3:
            print("GO: all 3 core shape moments (variance, polarization, middle mass) differ in the\n"
                  "    predicted direction and significantly. A shape gap exists — proceed to Stage 2\n"
                  "    (review-level collection for H2/H6–H8).", file=out)
        elif best >= 1:
            print(f"MIXED: {best}/3 core moments confirmed. A partial gap — inspect the moments table\n"
                  "    and the figure; consider a larger frame before committing to Stage 2.", file=out)
        else:
            print("STOP: no core shape moment differs in the predicted direction. Consistent with\n"
                  "    'the distributions are indistinguishable' — the project ends here having cost\n"
                  "    almost nothing (proposal §8). Re-check take-up assumptions before continuing.", file=out)

    make_figure(wide if not wide.empty else mom)
    print(verdict_path.read_text(encoding="utf-8"))
    print(f"\n[03] wrote {verdict_path.name}, shape_gap_moments.csv, fig_shape_gap.{{pdf,png}} "
          f"→ {config.OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
