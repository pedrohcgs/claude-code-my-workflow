---
paths:
  - "**/*.do"
  - "**/*.ado"
  - "analysis/**/*"
---

# Stata Code Standards

**Standard:** Senior Principal Data Engineer + PhD researcher quality

---

## 1. Task-Based DAG Structure

Every analysis task lives in its own directory:

```
analysis/
├── task_name/
│   ├── code/          # .do files (main.do is entry point)
│   ├── inputs/        # Symlinks to other tasks' outputs/
│   └── outputs/       # Results: .dta, .csv, .tex, .png
```

- `inputs/` contains ONLY symlinks to another task's `outputs/`
- `main.do` is the entry point for every task
- Task names use snake_case: `build_nipa_shares`, `merge_cms_bls`
- Never hardcode paths outside the task directory

---

## 2. Reproducibility

- `version 18` (or current) at top for forward compatibility
- `set seed YYYYMMDD` once at top of master .do file
- All paths relative to task root
- `capture mkdir "outputs"` for output directories
- `clear all` at script start
- `log using "outputs/task_name.log", replace`

---

## 3. Naming Conventions

- Variables: `snake_case` (e.g., `capital_share`, `labor_share_health`)
- Locals/macros: lowercase with underscores
- Programs: verb_noun pattern (e.g., `compute_shares`, `merge_claims`)
- Tempfiles: always use `tempfile` and `tempname`

---

## 4. Data Management

- Always `compress` before saving .dta files
- Label all variables and values
- Document units in variable labels (e.g., `"Capital share (percent)"`)
- Use `assert` liberally for data integrity checks
- `isid` to verify uniqueness before merges
- `merge` must always check `_merge` values explicitly
- Never `drop if missing(x)` without commenting and counting dropped obs

---

## 5. Visual Identity

```stata
// UChicago institutional palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"
local light_gray "214 214 206"
local positive  "21 128 61"
local negative  "185 28 28"
```

### Figure Export for Beamer

```stata
graph export "outputs/figure_name.png", width(2400) height(1600) replace
```

- White background
- 300 DPI effective (width(2400) for 8" slide = 300 DPI)
- Explicit dimensions always
- Use `scheme(s2color)` or custom scheme as baseline

---

## 6. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| `merge` without checking `_merge` | Silent data loss | Always `assert _merge==3` or explicit handling |
| Missing `compress` | Bloated .dta files | Always compress before save |
| Hardcoded paths | Breaks DAG structure | Use relative paths within task |
| `drop if missing(x)` without comment | Silent sample restriction | Document and count dropped obs |
| BLS/BEA vintage mismatch | Inconsistent denominators | Log data vintage in header comment |
| Missing `isid` before merge | Unexpected many-to-many | Always verify uniqueness |

---

## 7. Code Quality Checklist

```
[ ] version statement at top
[ ] set seed once (if stochastic)
[ ] clear all at start
[ ] log file opened
[ ] All paths relative to task root
[ ] inputs/ contains only symlinks
[ ] Variables labeled with units
[ ] merge checks complete
[ ] Figures: explicit dimensions, UChicago palette
[ ] compress before save
```
