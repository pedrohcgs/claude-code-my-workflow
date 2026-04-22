"""Render publication-ready figures."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = ROOT / "scripts" / "python" / "_outputs"


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    notes = OUTPUT_DIR / "05_figures_notes.txt"
    notes.write_text(
        "Replace this stub with figure export logic (.pdf, .png, optional .svg).\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
