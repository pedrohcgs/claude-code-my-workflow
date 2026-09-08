---
name: r-package-check
description: "Run the full R package release gate — regenerate docs, run the test suite, run R CMD check --as-cran, and triage every ERROR / WARNING / NOTE against CRAN policy before a release or submission. Use when the user says \"check my R package\", \"R CMD check\", \"is this package CRAN-ready\", \"run devtools::check\", \"prepare for CRAN submission\", or points at a directory containing a DESCRIPTION file. Produces a check report + CRAN-submission checklist in `quality_reports/`."
---



# `$r-package-check` — R Package Release Gate

Run the document → test → check → triage pipeline that decides whether an R package is releasable, then review the source for the issues `R CMD check` cannot see.

**Input:** `the arguments supplied with the invocation` — the package root (a directory containing `DESCRIPTION`). If blank, autodetect by searching upward/within the working directory for `DESCRIPTION`.

---

## Constraints

- **Follow [`.codex/guidance/r-package-conventions.md`](../../../.codex/guidance/r-package-conventions.md)** — the CRAN-readiness bar (0 errors, 0 warnings, explained notes) is the gate.
- **Treat `man/` and `NAMESPACE` as generated** — regenerate with `devtools::document()`; never hand-edit them.
- **Run the `r-package-reviewer` agent** on the source before declaring the package releasable.
- **Do not bump the version or write to CRAN.** This skill *checks*; the human decides when to submit.

---

## Workflow Phases

### Phase 0: Pre-Flight Report

```markdown
## Pre-Flight Report — R Package Check

**Package:** [name + version from DESCRIPTION]
**Root:** [path]
**Exported functions:** [from NAMESPACE / `@export` count]
**Dependencies:** Imports [list] · Suggests [list] · Depends [list]
**Toolchain available:** devtools [✓/✗], roxygen2 [✓/✗], testthat [✓/✗], R CMD [✓/✗], covr [✓/✗]
**Plan:** document → test → check --as-cran → triage → review
```

Detect the toolchain with a quick probe; if `devtools`/`R CMD` is missing, stop and tell the user what to install.

```bash
Rscript -e 'cat("devtools:", requireNamespace("devtools", quietly=TRUE),
               "roxygen2:", requireNamespace("roxygen2", quietly=TRUE),
               "testthat:", requireNamespace("testthat", quietly=TRUE),
               "covr:", requireNamespace("covr", quietly=TRUE), "\n")'
```

### Phase 1: Document

Regenerate `man/` + `NAMESPACE` and detect drift (generated docs that were not committed):

```bash
Rscript -e 'devtools::document("[pkg]")'
git -C "[pkg]" status --short man/ NAMESPACE   # any diff = generated docs were stale
```

If `git status` shows changes, flag: the committed `man/`/`NAMESPACE` were out of sync with the roxygen blocks.

### Phase 2: Test

```bash
Rscript -e 'devtools::test("[pkg]")'
```

Report failures and (if `covr` is available, Phase 4) coverage of exported functions.

### Phase 3: Check (`--as-cran`)

Run the full check. **This is slow** (minutes) — background-launch and stream with the running-process interface rather than blocking:

```bash
Rscript -e 'devtools::check("[pkg]", args = "--as-cran")'
# or: R CMD build [pkg] && R CMD check --as-cran [pkg]_*.tar.gz
```

Then **triage every result** into a table:

| Result | Tier | CRAN-policy meaning | Action |
|---|---|---|---|
| … | ERROR / WARNING / NOTE | … | fix / justify |

- **ERROR / WARNING** → must fix before submission.
- **NOTE** → fix if cheap; otherwise write the justification you'd put in `cran-comments.md` (e.g., "New submission", "Found the following (possibly) invalid URLs … the URL is correct and reachable").

### Phase 4: Coverage (optional)

```bash
Rscript -e 'covr::package_coverage("[pkg]")'
```

Report per-function coverage; flag exported functions with 0% coverage.

### Phase 5: Source Review

```
Delegate to the r-package-reviewer agent:
"Review the package source at [pkg]"
```

Address Critical (CRAN-policy violations) and High (check WARNINGs) findings.

### Phase 6: Release Gate + Report

Save a report to `quality_reports/[package]_package_check.md` and present a verdict:

```markdown
## Release Gate — [package] [version]
- R CMD check --as-cran: E errors, W warnings, N notes
- Tests: P passed, F failed
- Coverage: X% of exported functions
- r-package-reviewer: C critical, H high
- **Verdict:** RELEASABLE / FIX-FIRST / POLICY-VIOLATION

### CRAN-submission checklist
[ ] 0 errors, 0 warnings; each note justified in cran-comments.md
[ ] Version bumped + NEWS.md updated
[ ] devtools::check_win_devel() / R-hub on other platforms (note: run separately)
[ ] Reverse-dependency check if this is an update (revdepcheck)
```

---

## Important

- **`--as-cran` or it doesn't count.** A plain `R CMD check` misses the policy checks that actually gate submission.
- **Generated files are generated.** If docs drift, the fix is `devtools::document()`, not editing `.Rd`.
- **The gate is 0/0/explained.** 0 errors, 0 warnings, every remaining note justified — nothing less is "CRAN-ready."
- **This skill does not submit.** Cross-platform checks (win-devel, R-hub) and the actual `devtools::release()` are the maintainer's call.

## Long-running checks: use the Monitor tool

`R CMD check --as-cran` and `covr` can run for several minutes. Background-launch via Bash with `run_in_background: true`, capture the `bash_id`, and use the running-process interface to stream progress (e.g. the `checking …` lines or process exit) instead of polling. See [`data-analysis/SKILL.md`](../data-analysis/SKILL.md) for the pattern.

