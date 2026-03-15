---
paths:
  - "code/python/**/*.py"
---

# Python Conventions

**Python version:** 3.13 (managed via conda)
**Scope:** Data collection, cleaning, and preprocessing scripts in `code/python/`

## Environment Management

- Python is managed via **conda** — do not use `pip install` for packages that are available via conda
- Activate the project environment before running scripts: `conda activate usc2024`
- Run scripts via conda: `conda run -n usc2024 python code/python/script_name.py`
- To add packages: `conda install -n usc2024 [package]` (preferred) or `pip install [package]` if conda doesn't have it
- Keep an `environment.yml` in the repo root for reproducibility (create with `conda env export -n usc2024 > environment.yml`)

---

## File Header (Required)

Every script must start with:

```python
"""
Script: script_name.py
Purpose: [One-sentence description]
Inputs:  [data/raw/... or API source]
Outputs: [data/processed/... or data/final/...]
Author:  [from project context]
Date:    YYYY-MM-DD
"""
```

---

## Imports

- All imports at the **top of the file**, before any code
- Standard library first, then third-party, then local
- No `import *` — always explicit
- No inline imports inside functions unless unavoidable

```python
# Standard library
import os
from pathlib import Path

# Third-party
import pandas as pd
import numpy as np

# Local
from utils import clean_firm_id
```

---

## Path Management

- **Always use relative paths** from the project root
- Use `pathlib.Path` — never string concatenation for paths
- Define a `ROOT` constant at the top of each script:

```python
ROOT = Path(__file__).resolve().parents[2]  # adjust depth as needed
RAW   = ROOT / "data" / "raw"
PROC  = ROOT / "data" / "processed"
FINAL = ROOT / "data" / "final"
OUT   = ROOT / "output"
```

- **Never hardcode** `C:/`, `C:\`, `/Users/`, or any absolute path

---

## Reproducibility

- Set random seed early if any stochastic operations:
  ```python
  import random
  import numpy as np
  random.seed(20240101)
  np.random.seed(20240101)
  ```
- Use seed format `YYYYMMDD` (today's date when script was written)
- Do NOT modify files in `data/raw/` — read only

---

## Functions

- Every non-trivial function gets a docstring:
  ```python
  def clean_firm_id(df: pd.DataFrame) -> pd.DataFrame:
      """Remove duplicate firm-year observations and standardize firm ID format.

      Args:
          df: Raw CSMAR panel with columns [firm_id, year, ...]

      Returns:
          Deduplicated DataFrame with normalized firm_id column.
      """
  ```
- Functions should do one thing
- No function longer than 50 lines without a strong reason

---

## Data Safety

- **Never overwrite raw data.** Output always goes to `data/processed/` or `data/final/`
- Log row counts before and after any merge/filter:
  ```python
  print(f"Before merge: {len(df):,} rows")
  df = df.merge(...)
  print(f"After merge: {len(df):,} rows")
  ```
- Assert expected columns exist before processing:
  ```python
  assert {"firm_id", "year", "revenue"}.issubset(df.columns), "Missing required columns"
  ```

---

## Output

- Save processed data with descriptive names: `csmar_firm_panel_2010_2022.parquet`
- Prefer `.parquet` for large datasets (fast, compressed), `.csv` for small/readable outputs
- Print a summary at the end:
  ```python
  print(f"Saved {len(df):,} rows to {output_path}")
  ```

---

## Style

- Follow PEP 8
- Line length: 100 characters max
- Use f-strings, not `.format()` or `%`
- Avoid `df.apply()` with lambda when vectorized operations exist
