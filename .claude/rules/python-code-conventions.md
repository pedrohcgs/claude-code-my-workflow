---
paths:
  - "Scripts/**/*.py"
  - "explorations/**/*.py"
---

# Python Code Standards

**Standard:** Senior data scientist + PhD researcher quality
**Role:** Python is the **primary** empirical tool for this project.

---

## 1. Reproducibility

- `np.random.seed(42)` and/or `random.seed(42)` called ONCE at top of each script
- `random_state=42` passed to every sklearn/statsmodels call that uses randomness
- All packages imported at top via standard imports (no inline imports)
- All paths **relative to repository root** — never hardcoded absolute paths
- `requirements.txt` kept current with pinned versions
- Output directories created with `os.makedirs(out_dir, exist_ok=True)`

```python
# Top of every script
import random
import numpy as np
random.seed(42)
np.random.seed(42)
```

---

## 2. Function Design

- `snake_case` naming, verb-noun pattern (`compute_synchronicity`, `load_crsp_data`)
- Docstrings on every function (Google style):
  ```python
  def compute_synchronicity(returns: pd.DataFrame, market_col: str = "mktret") -> pd.DataFrame:
      """Compute firm-level log-odds synchronicity from annual market model.

      Args:
          returns: Panel DataFrame with columns [permno, date, ret, mktret].
          market_col: Column name for market return.

      Returns:
          DataFrame with columns [permno, year, r2, psi] where psi = log-odds(R²).
      """
  ```
- Type hints on all function signatures
- No magic numbers — define constants at top of file

---

## 3. Domain Correctness (Finance Panel Data)

### Synchronicity Computation

```python
# CORRECT: per-firm annual OLS → R² → log-odds
def compute_firm_r2(group):
    """OLS of firm return on market return, returns R²."""
    y = group["ret"]
    X = sm.add_constant(group["mktret"])
    model = sm.OLS(y, X).fit()
    return model.rsquared

df_r2 = returns.groupby(["permno", "year"]).apply(compute_firm_r2).reset_index()
df_r2.columns = ["permno", "year", "r2"]
df_r2["psi"] = np.log(df_r2["r2"] / (1 - df_r2["r2"]))  # log-odds transform
```

### Panel Data — Critical Rules

```python
# ALWAYS groupby firm before shift/pct_change
df["ret"] = df.groupby("permno")["price"].pct_change()  # CORRECT
df["ret"] = df["price"].pct_change()                    # WRONG: crosses firms

# ALWAYS reset_index after groupby.apply to avoid multi-index surprise
result = df.groupby("permno").apply(my_func).reset_index()

# NEVER fillna(0) on returns or financial variables
df["ret"].fillna(0)        # WRONG: treats missing as zero return
df = df.dropna(subset=["ret"])  # CORRECT: drop or flag explicitly
```

### Standard Errors

```python
# Panel regressions: use linearmodels with clustered SEs
from linearmodels.panel import PanelOLS

model = PanelOLS(
    dependent=df.set_index(["permno", "year"])["psi"],
    exog=df.set_index(["permno", "year"])[controls],
    entity_effects=True,
    time_effects=True
)
res = model.fit(cov_type="clustered", cluster_entity=True)
```

---

## 4. Figure Standards

```python
import matplotlib.pyplot as plt
import matplotlib as mpl

# Publication-quality settings
mpl.rcParams.update({
    "figure.dpi": 300,
    "savefig.dpi": 300,
    "figure.facecolor": "white",
    "axes.facecolor": "white",
    "font.family": "serif",
    "axes.spines.top": False,
    "axes.spines.right": False,
})

# Color palette
BLUE = "#2166ac"
RED = "#d6604d"
GRAY = "#525252"

# Saving
fig.savefig(out_path, dpi=300, bbox_inches="tight", facecolor="white")
```

---

## 5. Common Pitfalls

| Pitfall | Impact | Fix |
|---------|--------|-----|
| `.shift()` without `groupby(firm)` | Look-ahead / cross-firm leakage | Always `groupby("permno").shift()` |
| `fillna(0)` on returns | Survivorship bias | `dropna()` or explicit NaN flag |
| `groupby().apply()` creates multi-index | Unexpected downstream errors | `.reset_index()` immediately after |
| `groupby` default `sort=True` | Reorders rows silently | Use `sort=False` or re-sort explicitly |
| Raw R² as dependent variable | OLS on bounded variable | Apply log-odds transform (ψ) |
| No `random_state` in sklearn | Non-reproducible splits | Always pass `random_state=42` |
| Hardcoded path strings | Breaks replication | Use `pathlib.Path` relative to root |
| `import *` | Name collision, unclear dependencies | Explicit imports only |
| `pd.DataFrame.append()` in loop | O(n²) memory | Build list, then `pd.concat()` |

---

## 6. Code Quality Checklist

```
[ ] random_state / np.random.seed at top
[ ] All imports at top (no inline imports)
[ ] All paths relative (use pathlib.Path)
[ ] requirements.txt current
[ ] Every function has docstring + type hints
[ ] No fillna(0) on financial data
[ ] shift/pct_change uses groupby(firm)
[ ] Figures: white bg, 300 DPI, tight layout
[ ] Output directories created with exist_ok=True
[ ] Comments explain WHY not WHAT
```

---

## 7. Line Length & Mathematical Exceptions

**Standard:** Keep lines <= 100 characters.

**Exception:** Mathematical formula implementations may exceed 100 chars **if and only if:**
1. Breaking would harm readability of the math
2. An inline comment explains the operation:
   ```python
   # Log-odds transform: maps R² ∈ (0,1) → ψ ∈ (-∞, +∞)
   psi = np.log(r2 / (1 - r2))
   ```
