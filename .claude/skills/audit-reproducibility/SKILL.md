---
name: audit-reproducibility
description: Enforce the replication-protocol.md rule by cross-checking numeric claims in a manuscript against the actual R / Stata / Python outputs. Report PASS/FAIL per claim against tolerance thresholds. Use before submission and before releasing a replication package.
argument-hint: "[manuscript path] [outputs-dir] (outputs-dir defaults to code/_outputs/)"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Task", "Monitor"]
effort: high
---

# Audit Reproducibility

Compare numeric claims in a manuscript (point estimates, standard errors, p-values, counts) against the actual outputs produced by the analysis pipeline. Report PASS / FAIL per claim against the tolerance thresholds defined in [`.claude/rules/replication-protocol.md`](../../rules/replication-protocol.md).

**Core principle:** If the paper says `ATT = -1.632 (0.584)` and the code produces `-1.628 (0.591)`, we verify — **numerically** — that the difference is within the documented tolerance. No more "looks close enough" eyeballing.

## When to use

- **Before submission.** Catches the "I updated the analysis but forgot to update Table 2" bug.
- **Before releasing a replication package.** Verifies the code actually reproduces the paper.
- **After a major revision.** Ensures the paper still matches the latest code.
- **Quality-gate in `/commit`.** Pair with a pre-commit invocation on manuscript + analysis changes.

## Inputs

- `$0` — path to the manuscript (`.tex`, `.qmd`, `.md`, `.pdf`). Required.
- `$1` — path to the outputs directory. Defaults to `code/_outputs/`. Recognised alternatives: `code/stata/_outputs/` (Stata pipelines built by [`/stata-replication`](../stata-replication/SKILL.md)), `_targets/objects/` (R `targets` workflows), any directory the user-specified outputs live in.

## Workflow

### Phase 0: Pre-flight

1. Read [`replication-protocol.md`](../../rules/replication-protocol.md) for the tolerance thresholds currently in effect.
2. Verify the outputs directory exists and is non-empty. If empty or stale (older than the manuscript), prompt the user to re-run their pipeline (e.g., `Rscript code/00_run_all.R`) before auditing.
3. Ensure a `sessionInfo.txt` or equivalent environment capture exists in the outputs dir.

### Phase 1: Extract claims from the manuscript

Parse the manuscript for numeric claims. Patterns to match:

- **Point-estimate + SE**: `ATT = -1.632 (0.584)`, `$\beta = 0.342$ (0.091)`, `hat{\tau} = 1.28**` with starred significance
- **Table cells**: `& -1.632$^{***}$ & 0.584 &` in LaTeX table environments
- **Counts**: `our sample of 2,847 firms`, `$N = 2{,}847$`
- **Summary stats**: `mean = 0.423`, `SD = 0.087`
- **P-values**: `p < 0.01`, `$p = 0.003$`

Record each claim as a tuple:

```
{
  claim_id: "Table2_col3_ATT",
  location: "Table 2, Column 3, row 'Treatment'",
  kind: "point_estimate" | "standard_error" | "p_value" | "count" | "percentage",
  reported_value: -1.632,
  uncertainty: 0.584,              # only for point estimates
  significance_stars: 3,            # 0-3 or None
  raw_context: "the ATT estimate of -1.632 (0.584) indicates..."
}
```

Write the extracted claims to `quality_reports/reproducibility_claims_[manuscript-name].json` so the user can review the extraction before audit.

### Phase 2: Extract results from outputs

Scan `$1` for corresponding values. Priority order:

1. **`.rds` files** — `readRDS(path)$coef[["treatment"]]` style lookups. Can use `Rscript -e "saveRDS(summary(readRDS(...)), '/tmp/audit.rds')"` to extract.
2. **`.tex` tables** — parse LaTeX table cells directly; match on column headers + row labels.
3. **`.csv` summary files** — pandas/readr parse, key-value lookup.
4. **`.out` / `.log` files** (Stata, regress output) — regex extraction.
5. **`.json`** — direct key lookup.

Record each extracted result:

```
{
  source: "code/_outputs/results.rds",
  lookup_key: "fit_main$coefficients['treated']",
  value: -1.628,
  uncertainty: 0.591,
  p_value: 0.005
}
```

### Phase 3: Match claims to results

Use fuzzy heuristics when exact labels don't match:

- Name similarity (`"treatment effect"` ~ `"ATT"` ~ `"treated"`)
- Magnitude similarity (if two candidates have values within 10% of the reported, prefer the one with closer SE)
- Context hints from the claim's `raw_context` field (table number, row label, description)

For every claim, produce a match candidate with a confidence score. Claims below 0.7 confidence get flagged as "UNMATCHED — manual review needed" rather than silently passing.

### Phase 4: Tolerance check

For each matched claim, apply the thresholds from `replication-protocol.md`:

| Kind | Tolerance | Example |
|---|---|---|
| Integers (N, counts) | Exact | 2,847 must equal 2,847 |
| Point estimates | `abs(reported - computed)` < 0.01 | -1.632 vs -1.628 → diff = 0.004 → PASS |
| Standard errors | `abs(reported - computed)` < 0.05 | 0.584 vs 0.591 → diff = 0.007 → PASS |
| P-values | Same significance level | p<0.01 and p<0.01 → PASS; p<0.01 and p=0.03 → FAIL |
| Percentages | ±0.1pp | 42.3% vs 42.35% → PASS |

Respect any **tolerance overrides** the user has written into their `replication-protocol.md` fork (they may loosen for MC noise or tighten for administrative data).

### Phase 5: Report

Write `quality_reports/reproducibility_audit_[manuscript-name].md`:

```markdown
# Reproducibility Audit: [Manuscript Title]

**Date:** [YYYY-MM-DD]
**Manuscript:** [path]
**Outputs directory:** [path]
**Tolerance source:** .claude/rules/replication-protocol.md

## Summary

| Status | Count |
|---|---|
| PASS | N |
| FAIL (diff > tolerance) | M |
| UNMATCHED (manual review) | K |
| **Overall verdict** | **PASS / FAIL** |

## PASS (all within tolerance)
| Claim | Reported | Computed | Diff | Tolerance |
|---|---|---|---|---|
| Table2_col3_ATT | -1.632 (0.584) | -1.628 (0.591) | 0.004 / 0.007 | 0.01 / 0.05 |

## FAIL (outside tolerance — BLOCKER)
| Claim | Reported | Computed | Diff | Tolerance | Location in paper |
|---|---|---|---|---|---|

## UNMATCHED (manual review)
| Claim | Raw context | Candidate sources |
|---|---|---|

## Environment
[sessionInfo excerpt]

## Next steps
1. Fix any FAIL rows — either update the manuscript or rerun analysis.
2. Review UNMATCHED rows — add explicit lookup keys or widen the search scope.
3. After zero FAILs, the paper is replication-ready.
```

## Exit behavior

- **All PASS:** exit 0, summary printed.
- **Any FAIL:** exit 1, summary printed to stderr. This makes the skill usable as a `/commit` pre-commit gate — see `replication-protocol.md` for the enforcement pattern.
- **UNMATCHED > 0 (with 0 FAIL):** exit 0 with warning — user must manually review.

## Source-language coverage

The skill compares manuscript claims against outputs in three source-language ecosystems:

| Source | Default outputs dir | Read-output via | Common claim sources |
|---|---|---|---|
| **R** (default) | `code/_outputs/` | `readRDS()`, `arrow::read_parquet()`, `vroom::vroom()` | `.rds` / `.parquet` / `.csv` / `tinytable` `.tex` |
| **Stata** (v1.9.0) | `code/stata/_outputs/` | `haven::read_dta()` from R, or `pyreadstat.read_dta()` from Python | `.dta` / `esttab` `.tex` / `.smcl` log values |
| **Python** | `code/python/_outputs/` (or `_targets/`) | `pandas.read_parquet`, `pickle.load` | `.parquet` / `.pickle` / `.csv` |

**Stata-specific notes (v1.9.0):**

- `.dta` outputs are read via `haven::read_dta()` (R), `pyreadstat.read_dta()` (Python), or by parsing the corresponding `esttab` `.tex` if the table-cell value is what the manuscript cites.
- Manuscript cell `\input{code/stata/_outputs/tab_main.tex}` is the strongest provenance signal — the cell value comes mechanically from the .do file. Match the location in the `.tex` to the regression call in `03_analyze.do`.
- Clustering df adjustments can differ between `reghdfe` and base `reg, cluster()`. If a SE mismatches at the 2nd decimal, the tolerance in `replication-protocol.md` covers it; if it mismatches at the 1st decimal, investigate the df adjustment.

## Passport-mode (v1.9.0)

When `quality_reports/passports/<paper-slug>.yaml` exists, the skill operates in **passport mode**: instead of emitting a one-shot report, it **reads, updates, and rewrites** the passport file in place.

- For each `claims:` entry in the passport, perform the same numeric audit as the default mode (extract reported value from manuscript at `location`, locate computed value at `source_file:source_line` / `output_file:output_field`, compare against `tolerance:`).
- After each claim is audited, update `status` in place:
  - PASS → claim within tolerance.
  - FAIL → claim outside tolerance. Record the discrepancy in the entry's `notes`.
  - STALE → if `source_file` or `output_file` modification time is later than `last_verified_on`, mark STALE and re-run the audit logic (after the rerun, status becomes PASS or FAIL — STALE is transient).
- Update `last_verified_on` and `last_verified_by: "/audit-reproducibility"` per claim.
- Update `paper.last_audit` at the top level.

If a claim in the manuscript is detected that has no matching passport entry, emit an UNVERIFIED warning — the author should add it (passport scope is author-curated, not auto-populated, to avoid bad inferences).

Passport mode does NOT delete passport entries. If a claim disappears from the manuscript, the passport entry remains with a STALE status — the author decides whether to delete (claim retracted) or update the entry's `location` (claim moved).

See [`.claude/rules/replication-protocol.md`](../../rules/replication-protocol.md) "Claims Provenance: `passport.yaml`" for the full schema and integration points (`/commit`, `/review-paper`).

## Cross-references

- [`.claude/rules/replication-protocol.md`](../../rules/replication-protocol.md) — the tolerance contract + passport schema.
- [`templates/passport-template.yaml`](../../../templates/passport-template.yaml) — starter file to copy for a new paper.
- [`.claude/skills/review-r/SKILL.md`](../review-r/SKILL.md) — catches code-style issues; this skill catches NUMERICAL reproducibility.
- [`.claude/skills/review-paper/SKILL.md`](../review-paper/SKILL.md) — content review; pair with this skill for a full pre-submission audit.

## What this skill does NOT do

- **Re-run your analysis.** The skill compares CURRENT outputs against manuscript claims. If the outputs are stale, re-run your pipeline first (the pre-flight phase will warn).
- **Catch wrong specifications.** A regression that compiles cleanly and produces a reproducible `-1.632` is reproducible. Whether `-1.632` is the RIGHT estimand is a `review-paper` / domain-reviewer question.
- **Check external package versions.** The `sessionInfo.txt` capture lets a reviewer see the env; pinning versions is on the user (via `renv.lock` or a `DESCRIPTION` file).

## Long batch reruns: use the Monitor tool (Apr 2026)

When `/audit-reproducibility` is asked to verify *all* numeric claims in a paper, the safest approach is to re-run the full pipeline (`00_run_all.R` or equivalent) and compare the regenerated outputs to the manuscript values. For pipelines that take more than a couple of minutes, background-launch the rerun and use Anthropic's **Monitor tool** (Apr 2026 Week 15) to stream stdout. The audit can react to errors mid-stream rather than waiting for the entire pipeline to finish before noticing a failed step.
