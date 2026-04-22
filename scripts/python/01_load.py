"""Load raw data into a reproducible Python analysis pipeline."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = ROOT / "scripts" / "python" / "_outputs"


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    notes = OUTPUT_DIR / "01_load_notes.txt"
    notes.write_text(
        "Replace this stub with project-specific data loading logic.\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
