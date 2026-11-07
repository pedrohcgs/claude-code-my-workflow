#!/usr/bin/env python3
"""Screenshot every page of a compiled Beamer PDF, map pages to frames, and read the log.

The Beamer counterpart of scripts/slide-qa.py. For each page: a PNG to look at, the frame
and overlay step it belongs to (from Beamer's .nav file), and the first line of its text.
Then the errors and the warnings that matter from the .log next to the PDF: overfull boxes,
missing characters, undefined references. With --band-mm it also flags every page that has
ink in a band above the bottom edge: content running into the footline. The band depends on
your theme, so it is off unless you give it. Needs poppler (pdftoppm, pdftotext, pdfinfo).
No Python packages.

Usage:
  python3 scripts/beamer-qa.py Slides/Lecture01.pdf [--pages 3 4] [--out DIR]
                               [--band-mm FROM TO] [--band-x-max PCT]

  --band-mm 8 5      ink between 8 mm and 5 mm above the bottom edge is flagged
  --band-x-max 85    look only at the left 85% of that band (skip a page number on the right)

Screenshots go to quality_reports/audits/beamer-qa/<deck>/ (gitignored) unless --out is given.
Exit: 0 nothing found; 1 a log error, a warning that matters, or a page in the band;
2 could not run (no PDF, no poppler).

Adapted from claesbackman/AI-research-feedback, Skills/explorable-beamer/scripts/shoot.py:

    MIT License

    Copyright (c) 2026 claesbackman

    Permission is hereby granted, free of charge, to any person obtaining a copy of this
    software and associated documentation files (the "Software"), to deal in the Software
    without restriction, including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
    to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or
    substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.

Changes from the original: a PDF path argument instead of a fixed _build/deck.pdf; page
size read from the PDF instead of assuming 16:9; the footline band made an option instead
of one theme's geometry; output under quality_reports/; XeLaTeX and pdfLaTeX logs as well
as LuaLaTeX; exit codes for use as a check.
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W = 1280
INK = 235                       # a pixel darker than this counts as ink
PT_PER_MM = 72 / 25.4


def run(cmd: list[str]) -> str:
    r = subprocess.run(cmd, capture_output=True)
    if r.returncode:
        raise RuntimeError(f"{os.path.basename(cmd[0])} failed: {r.stderr.decode('utf-8', 'replace').strip()[:200]}")
    return r.stdout.decode("utf-8", "replace")


def pdf_info(pdf: str) -> tuple[int, float]:
    """(pages, page height in mm)."""
    info = run(["pdfinfo", pdf])
    pages = int(re.search(r"Pages:\s+(\d+)", info).group(1))
    m = re.search(r"Page size:\s+([\d.]+) x ([\d.]+) pts", info)
    return pages, (float(m.group(2)) / PT_PER_MM if m else 90.0)


def frame_map(nav: str) -> dict[int, tuple[str, int, int]]:
    """page -> (frame label, step, number of steps), from Beamer's .nav file."""
    if not os.path.exists(nav):
        return {}
    with open(nav, encoding="utf-8", errors="replace") as f:
        text = f.read()
    m = re.search(r"\\beamer@appendixpages\s*\{(\d+)\}", text)
    appendix_from = int(m.group(1)) if m else None
    out, n_main, n_app = {}, 0, 0
    for a, b in re.findall(r"\\beamer@framepages\s*\{(\d+)\}\{(\d+)\}", text):
        a, b = int(a), int(b)
        if appendix_from and a >= appendix_from:
            n_app += 1
            label = f"A{n_app}"
        else:
            n_main += 1
            label = f"frame {n_main}"
        for p in range(a, b + 1):
            out[p] = (label, p - a + 1, b - a + 1)
    return out


def log_problems(log: str) -> list[str]:
    """Errors and the warnings that matter, deduplicated, from a LaTeX log."""
    if not os.path.exists(log):
        return []
    with open(log, encoding="utf-8", errors="replace") as f:
        lines = f.read().splitlines()
    found = []
    for i, line in enumerate(lines):
        msg = None
        if line.startswith("!") or (re.match(r"^.*:\d+: ", line) and "Error" in line):
            msg = line + " " + (lines[i + 1].strip() if i + 1 < len(lines) else "")
        elif re.match(r"^(Package \w+ Warning|LaTeX Warning|Overfull|Missing character)", line):
            if "Rerun" in line or "may have changed" in line:
                continue
            msg = line
            for nxt in lines[i + 1:i + 3]:                 # "(hyperref)  removing ..." continues it
                if not nxt.startswith("("):
                    break
                msg += " " + nxt.strip()
        if msg:
            found.append(re.sub(r"\s+", " ", msg).strip())
    return list(dict.fromkeys(found))


def band_ink(pgm: str, page_mm: float, band: tuple[float, float], x_max_pct: float) -> bool:
    """True if any ink lies between band[0] and band[1] mm above the bottom edge."""
    with open(pgm, "rb") as f:
        data = f.read()
    parts, pos = [], 0
    while len(parts) < 4:                                  # P5 header: magic, width, height, maxval
        m = re.compile(rb"\s*(#[^\n]*\n\s*)*(\S+)").match(data, pos)
        parts.append(m.group(2))
        pos = m.end()
    w, h = int(parts[1]), int(parts[2])
    pixels = data[pos + 1:]
    px_per_mm = h / page_mm
    lo, hi = int(h - band[0] * px_per_mm), int(h - band[1] * px_per_mm)
    xmax = max(1, int(w * x_max_pct / 100))
    for row in range(max(lo, 0), min(hi, h)):
        if any(b < INK for b in pixels[row * w:row * w + xmax]):
            return True
    return False


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    ap.add_argument("pdf")
    ap.add_argument("--pages", type=int, nargs="*", default=[])
    ap.add_argument("--out")
    ap.add_argument("--band-mm", type=float, nargs=2, metavar=("FROM", "TO"))
    ap.add_argument("--band-x-max", type=float, default=100.0, metavar="PCT")
    a = ap.parse_args()
    for s in (sys.stdout, sys.stderr):
        try:
            s.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, ValueError):
            pass
    pdf = os.path.abspath(a.pdf)
    if not os.path.isfile(pdf):
        print(f"beamer-qa: no such PDF: {a.pdf} (compile the deck first: /compile-latex)", file=sys.stderr)
        return 2
    missing = [t for t in ("pdftoppm", "pdftotext", "pdfinfo") if not shutil.which(t)]
    if missing:
        print(f"beamer-qa: CANNOT RUN — {', '.join(missing)} not found: brew install poppler (macOS) "
              "or apt install poppler-utils", file=sys.stderr)
        return 2
    stem = os.path.splitext(pdf)[0]
    out = os.path.abspath(a.out or os.path.join(ROOT, "quality_reports", "audits", "beamer-qa", os.path.basename(stem)))
    os.makedirs(out, exist_ok=True)
    try:
        n, page_mm = pdf_info(pdf)
        frames = frame_map(stem + ".nav")
        print(f"{n} pages, {len({v[0] for v in frames.values()}) or '?'} frames, {page_mm:.0f} mm tall: {a.pdf}")
        flagged = []
        for p in range(1, n + 1):
            if a.pages and p not in a.pages:
                continue
            base = os.path.join(out, f"{p:02d}")
            run(["pdftoppm", "-png", "-scale-to", str(W), "-f", str(p), "-l", str(p), "-singlefile", pdf, base])
            hit = False
            if a.band_mm:
                run(["pdftoppm", "-gray", "-scale-to", str(W), "-f", str(p), "-l", str(p), "-singlefile", pdf, base + "_g"])
                hit = band_ink(base + "_g.pgm", page_mm, (max(a.band_mm), min(a.band_mm)), a.band_x_max)
                os.remove(base + "_g.pgm")
            label, step, nsteps = frames.get(p, ("", 1, 1))
            stepinfo = f" step {step}/{nsteps}" if nsteps > 1 else ""
            title = next((l.strip()[:56] for l in run(["pdftotext", "-f", str(p), "-l", str(p), "-layout", pdf, "-"]).splitlines() if l.strip()), "")
            print(f"  {p:02d}.png  {label:9s}{stepinfo:11s} {title}" + ("   <- ink in the footline band" if hit else ""))
            if hit:
                flagged.append(p)
    except RuntimeError as e:
        print(f"beamer-qa: CANNOT RUN — {e}", file=sys.stderr)
        return 2
    problems = log_problems(stem + ".log")
    print()
    print("log: " + ("no log next to the PDF" if not os.path.exists(stem + ".log") else
                     ("no errors or warnings that matter" if not problems else f"{len(problems)} message(s)")))
    for m in problems:
        print("  -", m[:220])
    if a.band_mm:
        print("pages with ink in the footline band: " + (", ".join(f"{p:02d}" for p in flagged) or "none"))
    try:
        shown = os.path.relpath(out)
    except ValueError:                                     # another drive on Windows
        shown = out
    print(f"screenshots in {out if shown.startswith('..') else shown}/")
    return 1 if problems or flagged else 0


if __name__ == "__main__":
    sys.exit(main())
