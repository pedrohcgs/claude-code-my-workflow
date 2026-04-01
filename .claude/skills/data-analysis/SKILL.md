---
name: data-analysis
description: End-to-end Python data analysis workflow from exploration through analysis to publication-ready tables and figures
argument-hint: "[dataset path or description of analysis goal]"
---

# Data Analysis Workflow

Run an end-to-end data analysis in Python: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` -- a dataset path (e.g., `data/processed/matched_partners.parquet`) or a description of the analysis goal (e.g., "summarize match rates by audit firm size").

---

## Constraints

- **Follow Python code conventions** in `.claude/rules/python-code-conventions.md`
- **Save all scripts** to `scripts/python/` with descriptive names
- **Save all outputs** (figures, tables, data) to `output/`
- **Use logging** for all status messages
- **Run review-python** on the generated script before presenting results

---

## Workflow Phases

### Phase 1: Setup and Data Loading

1. Read `.claude/rules/python-code-conventions.md` for project standards
2. Create Python script with proper header (purpose, author, inputs, outputs)
3. Import packages at top
4. Set random seed if needed: `random.seed(42)` / `np.random.seed(42)`
5. Load and inspect the dataset

### Phase 2: Exploratory Data Analysis

Generate diagnostic outputs:
- **Summary statistics:** `.describe()`, missingness rates, variable types
- **Distributions:** Histograms for key continuous variables
- **Relationships:** Cross-tabulations, correlation matrices
- **Coverage:** Match rate breakdowns by firm, year, location
- **Quality:** Duplicate checks, null patterns

Save all diagnostic figures to `output/figures/diagnostics/`.

### Phase 3: Main Analysis

Based on the research question:
- **Descriptive analysis:** Summary tables, cross-tabs, trend analysis
- **Match quality analysis:** Precision, recall, F1 by matching tier
- **Regression analysis:** If applicable, use `statsmodels` or `linearmodels`
- **Standard errors:** Cluster at the appropriate level (document why)

### Phase 4: Publication-Ready Output

**Tables:**
- Use `pandas` `.to_latex()` or `stargazer` equivalent for formatted tables
- Include all standard elements: sample sizes, means, SDs
- Export as `.csv` for quick viewing and `.tex` if LaTeX tables needed

**Figures:**
- Use `matplotlib` / `seaborn` with consistent style
- Set explicit figure dimensions: `fig, ax = plt.subplots(figsize=(10, 6))`
- Include proper axis labels, titles, legends
- Save as both `.pdf` and `.png` with `dpi=300`
- Use a consistent color palette

### Phase 5: Save and Review

1. Save all key objects (DataFrames, results) as `.parquet` or `.pkl`
2. Create `output/` subdirectories as needed
3. Run the review-python skill on the generated script
4. Address any Critical or Major issues from the review

---

## Script Structure

```python
"""
Script: descriptive_title.py
Purpose: What this script does
Inputs: data/processed/input_file.parquet
Outputs: output/figures/plot.pdf, output/tables/summary.csv
Author: [name]
Date: YYYY-MM-DD
"""

import logging
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

# -- Setup --
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]

# -- Functions --

def main():
    # 1. Load data
    # 2. Explore
    # 3. Analyze
    # 4. Output tables and figures
    pass

if __name__ == "__main__":
    main()
```

---

## Important

- **Show your work.** Print summary statistics before jumping to analysis.
- **Check for issues.** Look for duplicates, missing values, outliers.
- **Use relative paths.** All paths relative to repository root.
- **No hardcoded values.** Use variables for sample restrictions, date ranges, etc.
- **Log everything.** Row counts, match rates, key metrics.
