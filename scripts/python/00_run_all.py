"""Run the full Python empirical pipeline."""

from __future__ import annotations

import platform
import runpy
import sys
from pathlib import Path

PROJECT_SEED = 20260422
ROOT = Path(__file__).resolve().parents[2]
SCRIPTS_DIR = ROOT / "scripts" / "python"
OUTPUT_DIR = SCRIPTS_DIR / "_outputs"
STAGES = [
    "01_load.py",
    "02_clean.py",
    "03_analyze.py",
    "04_tables.py",
    "05_figures.py",
]


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for stage in STAGES:
        script_path = SCRIPTS_DIR / stage
        print(f"[python-pipeline] running {script_path.name}")
        runpy.run_path(str(script_path), run_name="__main__")

    environment_path = OUTPUT_DIR / "environment.txt"
    environment_path.write_text(
        "\n".join(
            [
                f"python={sys.version}",
                f"platform={platform.platform()}",
                f"project_seed={PROJECT_SEED}",
            ]
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"[python-pipeline] wrote {environment_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
