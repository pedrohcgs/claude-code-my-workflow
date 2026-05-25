---
name: stata-replication
description: End-to-end Stata replication pipeline — scaffolds numbered `.do` files in `code/stata/`, executes them via the `stata-mcp` MCP server, captures logs and outputs to `code/stata/_outputs/`, and produces publication-ready tables (esttab) and figures (graph export). Mirrors `/data-analysis` for R-first projects. Use when user says "stata replication", "set up Stata pipeline", "scaffold the .do files", "run Stata analysis", "AEA replication package in Stata", or when a project's analysis language is Stata not R.
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[paper-or-data-pointer] [--from-r] [--no-execute]"
disable-model-invocation: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Task"]
---

# `/stata-replication` — Stata pipeline scaffold + execution

Build a complete Stata replication pipeline in `code/stata/`: numbered `.do` files following [`.claude/rules/stata-code-conventions.md`](../../rules/stata-code-conventions.md), executed via the [`stata-mcp`](https://github.com/SepineTam/stata-mcp) MCP server, with outputs landing in `code/stata/_outputs/`.

## When to use

- Your project's analysis language is **Stata** (not R). Common in econ field experiments, RCT studies, and any AEA submission where the original replication package is Stata.
- You're porting an R-first project to Stata for an AEA submission.
- You're adding a Stata robustness check to an R-first paper.
- You want a one-command reproduction: `do code/stata/99_run_all.do`.

## When NOT to use

- Your project is R-first. Use [`/data-analysis`](../data-analysis/SKILL.md).
- Your project is Python-first. Neither this skill nor `/data-analysis` is the right fit; consider extending the convention rule for Python or porting one of these skills.
- You're doing quick exploratory work. The numbered-pipeline scaffold is for replication packages, not scratch notebooks.

## Prerequisite: `stata-mcp` installed

This skill requires the `stata-mcp` MCP server. Install once per user:

```bash
claude mcp add stata-mcp --scope user -- uvx stata-mcp
```

The MCP server provides command-guarded Stata execution (refuses destructive operations like `!/shell/erase`), RAM monitoring, and Stata Language Server pairing. Maintained by SepineTam, 171 stars on GitHub as of 2026-05.

If `stata-mcp` is not installed, the skill halts at Phase 0 with installation instructions.

## Workflow

### Phase 0: Pre-flight

1. Verify `stata-mcp` is registered in the user's MCP configuration. If not → halt with install instructions.
2. Verify Stata is installed locally (the MCP server cannot run without it). Output stata version to confirm.
3. Confirm `code/stata/` directory exists or can be created.
4. Read [`.claude/rules/stata-code-conventions.md`](../../rules/stata-code-conventions.md) — every emitted `.do` file follows this convention.
5. If `--from-r` flag is set, locate the existing R pipeline at `code/` and use it as a translation source. Apply the Stata → R pitfalls table from `replication-protocol.md` in reverse.

### Phase 1: Scaffold the pipeline

Emit (or update) these files in `code/stata/`, each conforming to the header convention from `stata-code-conventions.md`:

```
code/stata/
├── 00_install.do        # ssc install, set globals, paths, sessionInfo capture
├── 01_clean.do          # raw → cleaned panel
├── 02_descriptive.do    # summary tables, balance (iebaltab), attrition
├── 03_analyze.do        # main regression specs (reghdfe / ivreg2 as needed)
├── 04_robustness.do     # alt specs, sensitivity
├── 05_tables_figures.do # esttab .tex outputs + graph export PDFs
└── 99_run_all.do        # do "01_clean.do" / do "02_..." / ...
```

If the paper or data source suggests specific specs (e.g., DiD with `reghdfe`, IV with `ivreg2`, RD with `rdrobust`), tailor `03_analyze.do` accordingly.

### Phase 2: Execute (unless `--no-execute`)

For each script in numbered order:

1. Dispatch to `stata-mcp` to execute the `.do` file.
2. Capture the log (Stata writes to `code/stata/_outputs/NN_log.smcl` per the header convention) and the resulting `.dta` / `.tex` / `.pdf` outputs.
3. If a script fails, halt — do NOT auto-fix unless the failure is trivial (typo flagged by Stata at parse time). For substantive failures (insufficient observations, singular matrices, missing covariates), surface to the user.

For long-running scripts (> 2 minutes), use the **Monitor tool** to stream stdout — same pattern documented in `/data-analysis` and `/audit-reproducibility`.

### Phase 3: Verify

1. Confirm every expected output exists in `code/stata/_outputs/`.
2. Check `sessionInfo.txt` was captured (package versions).
3. Run `/audit-reproducibility` if a manuscript exists — it now handles Stata `.dta` outputs via `haven`/`pyreadstat` (Pass 4.3).
4. Report scripts run, outputs produced, any warnings from Stata.

### Phase 4 (optional): R cross-check

If `--from-r` was set, run the R version of the same analysis (assumed to live at `code/`) and compare:

- Point estimates: should match to ~0.01 (per `replication-protocol.md` tolerance).
- Standard errors: should match to ~0.05 (clustering df adjustments can differ slightly between Stata and R).
- Sample sizes: must match exactly.

Discrepancies are surfaced for the user to investigate — typical culprits: clustering df, default options (logit vs probit for PS), bootstrap seed handling.

## Companion skills

- [`/data-analysis`](../data-analysis/SKILL.md) — R analogue. Same pipeline shape, different language.
- [`/audit-reproducibility`](../audit-reproducibility/SKILL.md) — reads both `.rds` and `.dta` outputs. Cross-checks manuscript claims against the produced values. Updated in v1.9.0 to handle Stata outputs.
- [`/review-paper`](../review-paper/SKILL.md) — if the paper exists and cites tables/figures produced by this pipeline, `/review-paper` auto-invokes `/audit-reproducibility` (per `cross-artifact-review.md`).

## Anti-patterns

- **Hand-editing `.dta` files.** Never. All transformations happen via the `.do` files; `.dta` outputs are derived and reproducible.
- **Skipping the `99_run_all.do`.** This is the AEA-mandated one-command entry point. Build it even for small projects.
- **Using `, robust` by default.** Use `, cluster(id)` at the appropriate level — see `stata-code-conventions.md` §6.
- **Hand-formatting tables in LaTeX.** Use `esttab` and `\input{}` — see `stata-code-conventions.md` §4.
- **Pinning Stata version in only one .do file.** Every `.do` file starts with `version 18` per the convention.

## Cross-references

- [`.claude/rules/stata-code-conventions.md`](../../rules/stata-code-conventions.md) — the discipline contract.
- [`.claude/rules/replication-protocol.md`](../../rules/replication-protocol.md) — tolerance thresholds (applies across R / Stata / Python).
- [stata-mcp on GitHub](https://github.com/SepineTam/stata-mcp) — the MCP server this skill depends on.
- [AEA Data Editor checklist](https://aeadataeditor.github.io/) — replication-package standards.

## Long-running fits / batch reruns: use the Monitor tool (Apr 2026)

Long Stata fits (multi-hour bootstrap with `cluster bootstrap`, large `reghdfe` with millions of observations, simulation studies) should be background-launched and tailed with the Monitor tool — same pattern as `/data-analysis` and `/audit-reproducibility` for R / Python. The .do file logs to SMCL; the Monitor tool follows stderr so Claude can react to errors mid-stream.
