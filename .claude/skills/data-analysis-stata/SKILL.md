---
name: data-analysis-stata
description: End-to-end Stata empirical pipeline — load → clean → analyze → publication-ready tables and figures. Use when user says "analyze this dataset in Stata", "run a regression in Stata", "do-file workflow on this data", "Stata pipeline for X", "give me a Stata analysis of...", or points at a `.dta` and asks for empirical results in Stata. Produces numbered `.do` files in `scripts/stata/` and outputs to `scripts/stata/_outputs/`.
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Stata Data Analysis Workflow

Run an end-to-end empirical analysis in Stata: load, clean, estimate, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path (e.g., `Data/raw/panel.dta`) or a description of the analysis goal (e.g., "regress depression on internet use with district fixed effects").

---

## Constraints

- **Follow Stata code conventions** in `.claude/rules/stata-code-conventions.md`
- **Save all `.do` files** to `scripts/stata/` (or a route-specific subfolder under `scripts/stata/depression_internet/<route>/` for multi-route projects)
- **Save all outputs** (tables, figures, model objects, logs) to `scripts/stata/_outputs/`
- **Use `eststo` + `estimates save`** for every fitted model — downstream tables and `/audit-reproducibility` depend on it
- **Open a text log** in `00_run_all.do` and close it at the end
- **Pin `version`** at the top of every `.do` file
- **Run the `stata-reviewer` agent** on the generated/modified `.do` file(s) before presenting results

---

## Workflow Phases

### Phase 0: Pre-Flight Report

**Before writing any analysis code, produce a Pre-Flight Report** showing you read the inputs. This prevents the common failure mode where the agent hallucinates variable names or skips project conventions.

Output block (in your response to the user, before Phase 1):

```markdown
## Pre-Flight Report

**Dataset:** [path]
- Variables found: [list from describe / codebook, compact]
- Observations: [count]
- Key types: [e.g., "outcome=float, treatment=byte, district=long"]
- Missing-data summary: [% missing per key var via `misstable summarize`]

**Project conventions read:**
- `.claude/rules/stata-code-conventions.md` — [one-line summary of most relevant section]
- `.claude/rules/replication-protocol.md` — [tolerance thresholds applicable to this analysis]

**Task interpretation:** [one sentence restating what the user asked for]

**Plan:** [3–5 bullet outline of the staged do-file pipeline]
```

If any input cannot be read (missing file, unreadable format), stop and ask the user before proceeding.

### Phase 1: Setup and Data Loading

1. Author/extend `00_run_all.do` (orchestrator):
   - `version <N>` (pin Stata version)
   - `clear all`, `set more off`
   - `set seed YYYYMMDD` if any randomness will appear downstream
   - Define `${REPO_ROOT}` and `${STATA_OUTPUTS}` globals
   - `capture mkdir "${STATA_OUTPUTS}"`
   - `log using "${STATA_OUTPUTS}/run_all.log", replace text`
   - Chain `do` calls to `01_load.do` … `05_figures.do`
   - Close with `log close`
2. Author `01_load.do`:
   - `version <N>` and a header block
   - Read raw data via `use "${REPO_ROOT}/Data/raw/<file>.dta"` or `import delimited`
   - Initial `describe` and `count` for sanity
   - Save raw snapshot to `${STATA_OUTPUTS}/01_raw_snapshot.dta` if useful

### Phase 2: Cleaning

`02_clean.do`:
- Type coercions (`destring`, `tostring`, `encode`) — explicit, not silent
- Merges with `assert(...)` and explicit `_merge` handling
- Sample restrictions (`drop if`, `keep if`) with inline rationale comments
- Derived variables clearly labeled (`label var ...`)
- Final `tab` / `misstable summarize` checkpoint
- Save processed data: `save "${STATA_OUTPUTS}/02_clean.dta", replace`

### Phase 3: Main Analysis

`03_analyze.do`:
- Choose estimator that matches identification strategy:
  - Panel + within: `reghdfe y x, absorb(unit time) vce(cluster id)`
  - 2SLS / IV: `ivreg2` or `ivreghdfe`
  - DiD with staggered adoption: `did_imputation` / `csdid` / `eventstudyinteract`
  - RDD: `rdrobust` (and consult `quality_reports/specs/rdd_design_standard.md` if it exists)
- Document clustering, weights, and absorbed FEs inline
- After each fit: `eststo <name>` AND `estimates save "${STATA_OUTPUTS}/<name>.ster", replace`
- Multiple specifications: simple → controls → FE → robust SE — each `eststo`'d separately

### Phase 4: Publication-Ready Output

`04_tables.do`:
- `esttab` with consistent template:
  ```stata
  esttab m1 m2 m3 using "${STATA_OUTPUTS}/table_main.tex", ///
      booktabs label se star(* 0.10 ** 0.05 *** 0.01) ///
      stats(N r2 r2_a, fmt(0 3 3)) ///
      varlabels(...) replace
  ```
- Also export `.csv` for spreadsheet inspection: `esttab ... using "...csv", csv replace`

`05_figures.do`:
- Apply consistent scheme (`set scheme s2color` or project scheme)
- `graph export` with explicit dimensions: `graph export "${STATA_OUTPUTS}/fig_main.pdf", as(pdf) replace`
- Emit both `.pdf` (for slides/manuscript) and `.png` (for quick inspection)
- Background consistent with the slide pipeline

### Phase 5: Save and Review

1. Confirm all artifacts are under `${STATA_OUTPUTS}/`:
   - `*.ster` for fitted models
   - `*.tex` / `*.csv` for tables
   - `*.pdf` / `*.png` for figures
   - `*.dta` for processed data snapshots
   - `run_all.log` for the orchestrator log
2. Capture environment metadata at end of `00_run_all.do`:
   ```stata
   creturn list  // logged
   display "Stata version: " c(stata_version) ", build: " c(version)
   ```
3. Run the `stata-reviewer` agent on the new/modified `.do` files:

   ```
   Delegate to the stata-reviewer agent:
   "Review the script at scripts/stata/03_analyze.do"
   ```

4. Address any **Critical** or **High** issues from the review before presenting results.

---

## Orchestrator Template

The canonical `00_run_all.do` pattern (already present at `scripts/stata/00_run_all.do`):

```stata
version 18.0
clear all
set more off
set seed 20260422

local repo_root : pwd
global REPO_ROOT "`repo_root'"
global STATA_OUTPUTS "${REPO_ROOT}/scripts/stata/_outputs"

capture mkdir "${STATA_OUTPUTS}"
log using "${STATA_OUTPUTS}/run_all.log", replace text

display "Running Stata pipeline from ${REPO_ROOT}"
do "${REPO_ROOT}/scripts/stata/01_load.do"
do "${REPO_ROOT}/scripts/stata/02_clean.do"
do "${REPO_ROOT}/scripts/stata/03_analyze.do"
do "${REPO_ROOT}/scripts/stata/04_tables.do"
do "${REPO_ROOT}/scripts/stata/05_figures.do"

display "Finished Stata pipeline"
log close
```

Each stage `.do` should begin with:

```stata
version 18.0

* ============================================================
* [Stage Title]
* Purpose: [What this stage does]
* Inputs:  [Data files / globals expected]
* Outputs: [Files written under ${STATA_OUTPUTS}]
* ============================================================
```

---

## Important

- **Reproduce, don't guess.** If the user specifies an estimator, run exactly that — don't substitute.
- **Show your work.** `summarize` and `tab` before estimation; document the analysis sample.
- **Check for issues.** Multicollinearity (`_rmcoll`), perfect prediction in logit, sample loss across specifications.
- **Use globals, not absolute paths.** All file references via `${REPO_ROOT}` and `${STATA_OUTPUTS}`.
- **No hardcoded values.** Use `local` macros for sample restrictions, date ranges, cutoffs.
- **Pair with `/audit-reproducibility`** when the analysis feeds a manuscript — it cross-checks numeric claims against `${STATA_OUTPUTS}`.
