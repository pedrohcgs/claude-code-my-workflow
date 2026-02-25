---
name: data-analysis
description: End-to-end Stata data analysis workflow from data construction through regression to publication-ready tables and figures
disable-model-invocation: true
argument-hint: "[task name or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis Workflow

Run an end-to-end data analysis in Stata: construct data, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a task name (e.g., `build_nipa_shares`) or a description of the analysis goal (e.g., "compute capital shares by healthcare subsector using BEA NIPA tables").

---

## Constraints

- **Follow Stata conventions** in `.claude/rules/stata-conventions.md`
- **Use the task-based DAG** structure in `analysis/`
- **Save all scripts** to `analysis/[task_name]/code/`
- **Save all outputs** (data, figures, tables) to `analysis/[task_name]/outputs/`
- **Use symlinks** for inputs from upstream tasks
- **Use UChicago palette** for all figures (see Stata conventions)

---

## Workflow Phases

### Phase 1: Setup and Task Structure

1. Read `.claude/rules/stata-conventions.md` for project standards
2. Create task directory if it doesn't exist: `analysis/[task_name]/{code,inputs,outputs}`
3. Create `code/main.do` with proper header:

```stata
* ============================================================
* [Descriptive Title]
* Author: [from project context]
* Purpose: [What this script does]
* Inputs: [Data files in inputs/]
* Outputs: [Files produced in outputs/]
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "outputs/[task_name].log", replace

* --- 0. Setup ---
// UChicago palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"
```

4. Create symlinks in `inputs/` to upstream task outputs
5. Set `version` and `set seed` at top

### Phase 2: Data Construction

- Load raw data or upstream inputs
- Clean, merge, reshape as needed
- **Always check `_merge` after merge**
- **Always `isid` before merge to verify uniqueness**
- Label all variables with units
- Document sample restrictions with counts
- `compress` before saving

### Phase 3: Exploratory Analysis

Generate diagnostic outputs:
- **Summary statistics:** `tabstat`, `summarize`, missing rates
- **Distributions:** `histogram` for key variables
- **Time patterns:** `graph twoway line` for trends
- **Cross-sectional patterns:** `graph twoway scatter` or `binscatter`
- **Group comparisons:** `tabstat ... , by(group) stat(mean sd N)`

Save all diagnostic figures to `outputs/diagnostics/`.

### Phase 4: Main Analysis

Based on the research question:
- **Regression:** Use `reghdfe` for panel with high-dimensional FE, `reg`/`areg` for simpler specs
- **Standard errors:** Cluster at appropriate level (document why)
- **Multiple specifications:** Start simple, progressively add controls
- **Effect sizes:** Report standardized effects alongside raw coefficients

### Phase 5: Publication-Ready Output

**Tables:**
- Use `esttab` / `estout` for regression tables
- Include all standard elements: coefficients, SEs, significance, N, R-squared
- Export as `.tex` for LaTeX inclusion: `esttab using "outputs/table_name.tex", replace`

**Figures:**
- Use UChicago palette (maroon, gray, phoenix)
- White background
- Explicit dimensions: `graph export "outputs/figure_name.png", width(2400) height(1600) replace`
- Include proper axis labels with units

### Phase 6: Save and Review

1. `compress` and `save` all constructed datasets
2. Close log: `log close`
3. Verify all outputs exist in `outputs/`
4. Run quality review on the generated script

---

## Important

- **Reproduce, don't guess.** If the user specifies an analysis, implement exactly that.
- **Show your work.** Print summary statistics before jumping to regression.
- **Check for issues.** Look for multicollinearity, outliers, missing data patterns.
- **Use relative paths.** All paths relative to task root directory.
- **No hardcoded values.** Use locals for sample restrictions, date ranges, etc.
- **Document data vintage.** Always note BEA release date, BLS reference quarter, CMS data year.
