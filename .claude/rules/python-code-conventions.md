---
paths:
  - "scripts/python/**/*.py"
  - "explorations/**/*.py"
---

# Python Code Standards

**Standard:** Senior data engineer + PhD researcher quality

---

## 1. Reproducibility

- All packages imported at top of file
- `random.seed()` / `np.random.seed()` called once at top if any randomization
- All paths via `pathlib.Path`, relative to project root
- `if __name__ == "__main__":` guard for executable scripts
- Pin package versions in `requirements.txt` or `environment.yml`

## 2. Style

- PEP 8 compliant (`snake_case` for functions/variables, `PascalCase` for classes)
- Type hints for all public function signatures
- Google-style docstrings for all public functions
- Max line length: 100 characters (exceptions for long string literals)
- Use f-strings over `.format()` or `%`

## 3. Data Handling

- Use `pandas` for tabular data
- Log row counts before and after every merge/filter/drop operation
- Always specify `how=` and `on=` explicitly in merges (no positional args)
- Validate merge results: check for unexpected duplicates with `_merge` indicator
- Save intermediate datasets to `data/processed/` with descriptive names

## 4. Logging

```python
import logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)
```

- Use `logger.info()` for status messages (not `print()`)
- Use `logger.warning()` for unexpected but non-fatal conditions
- Use `print()` only for user-facing CLI output

## 5. Error Handling

- Validate input data at script entry points (file exists, expected columns present)
- Fail fast with clear error messages for bad inputs
- Don't catch broad exceptions silently

## 6. Script Structure

```python
"""
Script: descriptive_name.py
Purpose: What this script does
Inputs: data/raw/form_ap.csv
Outputs: data/processed/cleaned_partners.parquet
Author: [name]
Date: YYYY-MM-DD
"""

import logging
from pathlib import Path

import pandas as pd

# -- Setup --
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]  # adjust depth as needed

# -- Functions --

def main():
    """Main execution."""
    pass

if __name__ == "__main__":
    main()
```

## 7. Code Quality Checklist

```
[ ] Imports at top, stdlib -> third-party -> local order
[ ] Type hints on public functions
[ ] Docstrings on public functions
[ ] All paths via pathlib, relative to project root
[ ] Logging (not print) for status messages
[ ] Merge diagnostics logged (row counts, _merge indicator)
[ ] No hardcoded absolute paths
[ ] if __name__ == "__main__" guard present
```
