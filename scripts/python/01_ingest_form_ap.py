"""
Script: 01_ingest_form_ap.py
Purpose: Ingest and clean PCAOB Form AP data (FirmFilings.csv).
         Filter to Issuer / US scope, extract unique partners and firms,
         standardize names, and produce diagnostic outputs.
Inputs:  data/raw/FirmFilings.csv
Outputs: data/processed/partners_by_firm.parquet
         data/processed/partners_deduped.parquet
         data/processed/firms_unique.parquet
         output/figures/diagnostics/partners_by_firm.png
         output/figures/diagnostics/partners_by_year.png
         output/tables/partner_summary_stats.csv
Author:  RetPartner project
Date:    2026-04-01
"""

import logging
import re
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

# -- Setup --
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]

# -- Paths --
RAW_FILE = PROJECT_ROOT / "data" / "raw" / "FirmFilings.csv"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
FIGURES_DIR = PROJECT_ROOT / "output" / "figures" / "diagnostics"
TABLES_DIR = PROJECT_ROOT / "output" / "tables"


# ============================================================
# Helper functions
# ============================================================

def standardize_name(s: str | None) -> str:
    """Lowercase, strip whitespace, normalize internal whitespace."""
    if pd.isna(s) or s is None:
        return ""
    s = str(s).strip().lower()
    s = re.sub(r"\s+", " ", s)
    return s


def standardize_firm_name(s: str) -> str:
    """Normalize firm name: fix double spaces, strip whitespace."""
    if pd.isna(s):
        return ""
    s = str(s).strip()
    s = re.sub(r"\s+", " ", s)  # collapse multiple spaces
    return s


def build_full_name(first: str, middle: str, last: str) -> str:
    """Combine first, middle, last into a single full name string."""
    parts = [first, middle, last]
    return " ".join(p for p in parts if p)


# ============================================================
# Step 0: Load and Scope Filter
# ============================================================

def step0_load_and_filter(path: Path) -> pd.DataFrame:
    """Load Form AP CSV. Filter to Issuer audit type, US firms."""
    logger.info("Loading %s", path)
    df = pd.read_csv(path, low_memory=False)
    logger.info("Loaded: %d rows, %d columns", len(df), len(df.columns))

    # Filter to Issuer audit report type (full label in data)
    before = len(df)
    issuer_mask = df["Audit Report Type"].str.startswith("Issuer", na=False)
    df = df[issuer_mask].copy()
    logger.info("Filter Issuer: %d -> %d rows", before, len(df))

    # Filter to US firms
    before = len(df)
    df = df[df["Firm Country"] == "United States"].copy()
    logger.info("Filter US: %d -> %d rows", before, len(df))

    return df


# ============================================================
# Step 1: Filter to Latest Filings
# ============================================================

def step1_latest_filings(df: pd.DataFrame) -> pd.DataFrame:
    """Keep only the latest filing for each form (exclude amended originals)."""
    before = len(df)
    df = df[df["Latest Form AP Filing"] == 1].copy()
    logger.info("Filter latest filings: %d -> %d rows", before, len(df))
    return df


# ============================================================
# Step 2: Extract Unique Partners
# ============================================================

def step2_extract_partners(df: pd.DataFrame) -> pd.DataFrame:
    """Extract unique (partner_id, firm_name) combinations.

    Includes both primary and secondary engagement partners.
    """
    # -- Primary partners --
    primary_cols = {
        "Engagement Partner ID": "partner_id",
        "Engagement Partner Last Name": "last_name_raw",
        "Engagement Partner First Name": "first_name_raw",
        "Engagement Partner Middle Name": "middle_name_raw",
        "Engagement Partner Suffix": "suffix_raw",
        "Firm Name": "firm_name_raw",
        "Firm ID": "firm_id",
        "Firm Issuing City": "city",
        "Firm Issuing State": "state",
        "Firm Country": "country",
        "Audit Report Date": "audit_report_date",
    }
    primary = df[list(primary_cols.keys())].rename(columns=primary_cols).copy()
    primary["partner_type"] = "primary"
    logger.info("Primary partner rows: %d", len(primary))

    # -- Secondary partners (where present) --
    sec_mask = df["Secondary Engagement Partner ID"].notna()
    if sec_mask.any():
        sec_cols = {
            "Secondary Engagement Partner ID": "partner_id",
            "Secondary Engagement Partner Last Name": "last_name_raw",
            "Secondary Engagement Partner First Name": "first_name_raw",
            "Secondary Engagement Partner Middle Name": "middle_name_raw",
            "Secondary Engagement Partner Suffix": "suffix_raw",
            "Firm Name": "firm_name_raw",
            "Firm ID": "firm_id",
            "Firm Issuing City": "city",
            "Firm Issuing State": "state",
            "Firm Country": "country",
            "Audit Report Date": "audit_report_date",
        }
        secondary = df.loc[sec_mask, list(sec_cols.keys())].rename(columns=sec_cols).copy()
        secondary["partner_type"] = "secondary"
        logger.info("Secondary partner rows: %d", len(secondary))
        combined = pd.concat([primary, secondary], ignore_index=True)
    else:
        combined = primary

    # Convert partner_id to int (may be float due to NaN in secondary)
    combined["partner_id"] = combined["partner_id"].astype(int)

    logger.info("Combined partner rows: %d", len(combined))
    logger.info("Unique partner IDs: %d", combined["partner_id"].nunique())

    return combined


# ============================================================
# Step 3: Standardize Names
# ============================================================

def step3_standardize_names(df: pd.DataFrame) -> pd.DataFrame:
    """Standardize name fields: lowercase, strip, normalize."""
    df["last_name"] = df["last_name_raw"].apply(standardize_name)
    df["first_name"] = df["first_name_raw"].apply(standardize_name)
    df["middle_name"] = df["middle_name_raw"].apply(standardize_name)
    df["suffix"] = df["suffix_raw"].apply(standardize_name)
    df["full_name"] = [
        build_full_name(f, m, l)
        for f, m, l in zip(df["first_name"], df["middle_name"], df["last_name"])
    ]

    # Log a few examples
    sample = df[["last_name", "first_name", "middle_name", "full_name"]].drop_duplicates().head(5)
    logger.info("Name standardization sample:\n%s", sample.to_string())

    return df


# ============================================================
# Step 4: Standardize Firm Names
# ============================================================

def step4_standardize_firms(df: pd.DataFrame) -> pd.DataFrame:
    """Standardize firm names and build firm summary."""
    df["firm_name"] = df["firm_name_raw"].apply(standardize_firm_name)
    n_firms = df["firm_name"].nunique()
    logger.info("Unique firms after standardization: %d", n_firms)
    return df


# ============================================================
# Step 5: Summary Statistics and Diagnostics
# ============================================================

def step5_diagnostics(
    partners_by_firm: pd.DataFrame,
    partners_deduped: pd.DataFrame,
    firms: pd.DataFrame,
    figures_dir: Path,
    tables_dir: Path,
) -> None:
    """Generate summary statistics and diagnostic figures."""
    figures_dir.mkdir(parents=True, exist_ok=True)
    tables_dir.mkdir(parents=True, exist_ok=True)

    # -- Summary stats table --
    stats = {
        "Total filings (Issuer, US, latest)": [len(partners_by_firm)],
        "Unique partner IDs": [partners_deduped["partner_id"].nunique()],
        "Unique (partner_id, firm) combos": [len(partners_by_firm.drop_duplicates(["partner_id", "firm_name"]))],
        "Unique firms": [len(firms)],
        "Partners with middle name": [(partners_deduped["middle_name"] != "").sum()],
        "Partners with suffix": [(partners_deduped["suffix"] != "").sum()],
    }
    stats_df = pd.DataFrame(stats).T
    stats_df.columns = ["Count"]
    stats_df.to_csv(tables_dir / "partner_summary_stats.csv")
    logger.info("Summary stats:\n%s", stats_df.to_string())

    # -- Figure style --
    sns.set_theme(style="whitegrid", font_scale=1.1)

    # -- Partners by firm (top 20) --
    firm_counts = (
        partners_by_firm.drop_duplicates(["partner_id", "firm_name"])
        .groupby("firm_name")
        .size()
        .sort_values(ascending=False)
        .head(20)
    )
    fig, ax = plt.subplots(figsize=(10, 7))
    firm_counts.plot.barh(ax=ax, color="#1f4e79")
    ax.set_xlabel("Number of Unique Partners")
    ax.set_title("Top 20 Firms by Number of Engagement Partners")
    ax.invert_yaxis()
    fig.tight_layout()
    fig.savefig(figures_dir / "partners_by_firm.png", dpi=300, bbox_inches="tight")
    plt.close(fig)
    logger.info("Saved partners_by_firm.png")

    # -- Partners by first-appearance year --
    partners_by_firm["audit_date"] = pd.to_datetime(
        partners_by_firm["audit_report_date"], format="mixed", errors="coerce"
    )
    first_year = (
        partners_by_firm.groupby("partner_id")["audit_date"]
        .min()
        .dt.year
        .value_counts()
        .sort_index()
    )
    fig, ax = plt.subplots(figsize=(10, 5))
    first_year.plot(ax=ax, marker="o", color="#1f4e79", linewidth=2)
    ax.set_xlabel("Year")
    ax.set_ylabel("Number of New Partners")
    ax.set_title("New Engagement Partners by Year (First Form AP Appearance)")
    fig.tight_layout()
    fig.savefig(figures_dir / "partners_by_year.png", dpi=300, bbox_inches="tight")
    plt.close(fig)
    logger.info("Saved partners_by_year.png")


# ============================================================
# Step 6: Save Outputs
# ============================================================

def step6_save(
    partners_by_firm: pd.DataFrame,
    partners_deduped: pd.DataFrame,
    firms: pd.DataFrame,
    out_dir: Path,
) -> None:
    """Save processed datasets to parquet."""
    out_dir.mkdir(parents=True, exist_ok=True)

    # Partners by firm
    pbf_path = out_dir / "partners_by_firm.parquet"
    partners_by_firm.to_parquet(pbf_path, index=False)
    logger.info("Saved %s (%d rows)", pbf_path.name, len(partners_by_firm))

    # Partners deduped (one row per partner_id — most recent firm)
    pd_path = out_dir / "partners_deduped.parquet"
    partners_deduped.to_parquet(pd_path, index=False)
    logger.info("Saved %s (%d rows)", pd_path.name, len(partners_deduped))

    # Firms
    firms_path = out_dir / "firms_unique.parquet"
    firms.to_parquet(firms_path, index=False)
    logger.info("Saved %s (%d rows)", firms_path.name, len(firms))


# ============================================================
# Main
# ============================================================

def main() -> None:
    logger.info("=" * 60)
    logger.info("01_ingest_form_ap.py — START")
    logger.info("=" * 60)

    # Step 0: Load and scope filter
    df = step0_load_and_filter(RAW_FILE)

    # Step 1: Latest filings only
    df = step1_latest_filings(df)

    # Step 2: Extract unique partners
    combined = step2_extract_partners(df)

    # Step 3: Standardize names
    combined = step3_standardize_names(combined)

    # Step 4: Standardize firm names
    combined = step4_standardize_firms(combined)

    # -- Build output datasets --

    # Partners by firm: one row per unique (partner_id, firm_name)
    # Keep the most recent audit date for each combo
    combined["audit_date"] = pd.to_datetime(combined["audit_report_date"], format="mixed", errors="coerce")
    partners_by_firm = (
        combined.sort_values("audit_date", ascending=False)
        .drop_duplicates(subset=["partner_id", "firm_name"], keep="first")
        .reset_index(drop=True)
    )
    logger.info(
        "Partners by firm: %d rows, %d unique partner IDs",
        len(partners_by_firm),
        partners_by_firm["partner_id"].nunique(),
    )

    # Partners deduped: one row per partner_id (most recent firm)
    partners_deduped = (
        combined.sort_values("audit_date", ascending=False)
        .drop_duplicates(subset=["partner_id"], keep="first")
        .reset_index(drop=True)
    )
    logger.info(
        "Partners deduped: %d rows (unique partner IDs)",
        len(partners_deduped),
    )

    # Firms unique
    firms = (
        partners_by_firm.groupby("firm_name")
        .agg(
            firm_id=("firm_id", "first"),
            n_partners=("partner_id", "nunique"),
            n_filings=("partner_id", "size"),
            city=("city", "first"),
            state=("state", "first"),
        )
        .reset_index()
        .sort_values("n_partners", ascending=False)
    )
    logger.info("Unique firms: %d", len(firms))

    # Step 5: Diagnostics
    step5_diagnostics(partners_by_firm, partners_deduped, firms, FIGURES_DIR, TABLES_DIR)

    # Step 6: Save
    step6_save(partners_by_firm, partners_deduped, firms, PROCESSED_DIR)

    logger.info("=" * 60)
    logger.info("01_ingest_form_ap.py — DONE")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()
