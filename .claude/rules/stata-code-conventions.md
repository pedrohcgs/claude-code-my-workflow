---
paths:
  - "**/*.do"
  - "code/stata/**"
---

# Stata Code Conventions

**Reproducibility is the default, not a feature.** A `.do` file should be runnable from a clean shell with no manual intervention. Every script ends in the same state regardless of how many times it runs.

> This rule mirrors [`r-code-conventions.md`](r-code-conventions.md) for users whose pipelines are Stata-first. Forkers who use both R and Stata in the same project: both rules apply on their respective files.

## 1. Reproducibility scaffolding

Every `.do` file starts with the same header:

```stata
/*------------------------------------------------------------
File:       NN_descriptive_name.do
Purpose:    [one-sentence description]
Inputs:     [path to inputs]
Outputs:    [path to outputs]
Run order:  Standalone | After NN_prior.do
------------------------------------------------------------*/

version 18                        // pin Stata semantics
clear all
set more off
set seed 12345                    // pin RNG seed for any random ops
set sortseed 12345                // pin sort stability across versions
cap log close
cap log close _all                // belt-and-suspenders
log using "code/stata/_outputs/NN_log.smcl", replace
```

Why each line:

- **`version 18`** — explicit semantics. New Stata versions can silently change defaults (e.g., `reghdfe` clustering df-adjustment); pinning is the only defence.
- **`clear all`** — no leftover state from a prior session.
- **`set more off`** — scripts shouldn't pause for keystrokes.
- **`set seed` + `set sortseed`** — every random op + every `sort` is deterministic.
- **`cap log close _all`** — pre-emptively close any logs the previous session left open.
- **`log using ... , replace`** — capture stdout; `replace` ensures re-runs don't append.

End every `.do` file with:

```stata
log close
exit, clear STATA      // explicit clean exit; useful in batch mode
```

## 2. Numbered pipeline

Scripts live in `code/stata/` and are numbered for run order:

```
code/stata/
├── 00_install.do        # ssc install packages, set globals, paths
├── 01_clean.do          # raw → cleaned panel
├── 02_descriptive.do    # summary tables, balance, attrition
├── 03_analyze.do        # main regression specs
├── 04_robustness.do     # alt specs, sensitivity
├── 05_tables_figures.do # estout/esttab + graph export
└── 99_run_all.do        # do "01_clean.do" / do "02_..." / ...
```

The 99-script is the **one-command reproduction**: `do code/stata/99_run_all.do` from the repo root produces every output the paper cites. AEA Data Editor checks this exact shape.

## 3. Outputs convention

All outputs land in `code/stata/_outputs/`:

```
code/stata/_outputs/
├── 01_log.smcl                 # captured stdout per script
├── clean_panel.dta             # cleaned data
├── descriptives.csv            # summary stats
├── main_results.tex            # esttab → .tex for direct \input{} in paper
├── balance_table.tex
├── fig_eventstudy.pdf          # graph export, vector
└── sessionInfo.txt             # capture stata version + installed pkg versions
```

`sessionInfo.txt` is mandatory. Generate via:

```stata
* At end of 00_install.do (or via a dedicated sessioninfo subroutine):
log using "code/stata/_outputs/sessionInfo.txt", text replace
which estout
which reghdfe
which ivreg2
about
log close
```

This gives the AEA / referee / future-you the package versions actually used.

## 4. Tables (estout / esttab)

Use `esttab` for any table that appears in the paper. **Never hand-format a table in LaTeX** — the `\input{}` pattern means the table cell values come from the actual estimation:

```stata
quietly: reghdfe y x1 x2, absorb(unit time) cluster(unit)
eststo m1
quietly: reghdfe y x1 x2 controls, absorb(unit time) cluster(unit)
eststo m2

esttab m1 m2 using "code/stata/_outputs/tab_main.tex", replace ///
    booktabs label                              /// use the variable labels you set
    se(2) b(3)                                  /// SE in parens, 3-decimal coeffs
    star(* 0.10 ** 0.05 *** 0.01)              /// significance convention
    stats(N r2, fmt(%9.0fc %9.3f) labels("Observations" "R²")) ///
    nonotes addnote("Robust SEs clustered at unit level.")
```

Then in the manuscript: `\input{code/stata/_outputs/tab_main.tex}` — table values update mechanically every time the .do file runs.

## 5. Significance-stars convention

The default is `* 0.10 ** 0.05 *** 0.01` (the econ convention; matches AER / QJE / JPE / ECMA defaults). Political science journals (APSR / AJPS / JOP) often use the same. Document the convention in the table note even though it's "obvious" — referees read the notes.

For one-tailed contexts (rare in published work), use `* 0.05 ** 0.025 *** 0.005` and explain why in the note. Default to two-tailed.

## 6. Clustering and SE conventions

- **Always cluster at the level of treatment assignment** (or the highest plausible level of dependence). Never use default `, robust` without justification.
- **`reghdfe` defaults to df-adjusted clustering** but check — Stata's `, cluster()` and `reghdfe ... , cluster()` use different df adjustments in some edge cases. The version pin at top of file is partial defence; explicit `, dofadj() ` is the rest.
- **Bootstrap clustering** for very small clusters (< 50 groups): use `cluster bootstrap` not `bootstrap, cluster()`.

## 7. Balance / attrition discipline

For every RCT or quasi-experimental design:

- **Balance table** via `iebaltab` (World Bank `ietoolkit` package). Don't reinvent.
- **Attrition table** — fraction missing per round, balanced by treatment status. Same `iebaltab` invocation with different outcome.
- **Manipulation checks** (survey experiments) — pass rate per arm. Document in the paper, not just the .do.

## 8. Figures (graph export)

```stata
graph export "code/stata/_outputs/fig_eventstudy.pdf", replace as(pdf)
graph export "code/stata/_outputs/fig_eventstudy.png", replace as(png) width(2000)
```

Both vector (PDF for the paper) and raster (PNG for slides). Don't rely on the auto-generated `.gph` — it's not portable across Stata versions.

## 9. Common Stata → R / Stata → AEA traps

| Trap | Fix |
|---|---|
| `reg y x, cluster(id)` without explicit df-adjustment | Use `reghdfe` for explicit df; document the adjustment in the table note |
| Bootstrap reps inconsistent across runs | `set seed` + `set sortseed` at top of file; use `bootstrap, reps(N) seed(X)` |
| `replace` modifying observed data | Always `gen new_var = ... ` and inspect before `drop` |
| `merge 1:1` without `assert` | `merge 1:1 id using foo, assert(3)` — fail loud on mismatched keys |
| `if` on missing values | Stata treats `.` as `+∞` in inequality comparisons. `if x > 5 & x != .` for non-missing-and-greater-than-5 |
| `egen sum(x)` deprecated | `egen total(x)` is the modern form; `egen sum()` still works but `bysort id: egen y = total(x)` is the safer pattern |

## 10. AEA Data Editor compliance

The [AEA Data Editor checklist](https://aeadataeditor.github.io/) requires:

- `README.md` at repo root describing data source, computational requirements, run instructions.
- A single command that reproduces all results (`do code/stata/99_run_all.do`).
- All scripts numbered and ordered.
- A separate `requirements.txt`-equivalent — for Stata, that's the `sessionInfo.txt` from §3 plus a list of `ssc install` commands in `00_install.do`.
- License (MIT / GPL / similar).
- No hard-coded paths — use globals or relative paths from repo root.

## Enforcement

- [`/stata-replication`](../skills/stata-replication/SKILL.md) is the analogue of `/data-analysis` for Stata. It emits .do files conforming to this convention.
- [`/audit-reproducibility`](../skills/audit-reproducibility/SKILL.md) handles Stata `.dta` outputs alongside R `.rds` (via `haven` or `pyreadstat`).
- [`/review-r`](../skills/review-r/SKILL.md) is R-specific; a Stata-equivalent is on the v2.0-backlog.

## Cross-references

- [`r-code-conventions.md`](r-code-conventions.md) — analogous discipline for R-first pipelines.
- [`replication-protocol.md`](replication-protocol.md) — tolerance contract that applies across R / Stata / Python.
- [stata-mcp on GitHub](https://github.com/SepineTam/stata-mcp) — the MCP server that lets Claude Code execute Stata `.do` files. Install via `claude mcp add stata-mcp --scope user -- uvx stata-mcp`.
