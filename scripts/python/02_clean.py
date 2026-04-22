"""Clean and transform loaded data."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = ROOT / "scripts" / "python" / "_outputs"


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    notes = OUTPUT_DIR / "02_clean_notes.txt"
    notes.write_text(
        "Replace this stub with cleaning, merges, and feature engineering.\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
