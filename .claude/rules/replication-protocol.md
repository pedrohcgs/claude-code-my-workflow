---
paths:
  - "code/**/*.R"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

---

## Phase 1: Inventory & Baseline

Before writing any R code:

- [ ] Read the paper's replication README
- [ ] Inventory replication package: language, data files, scripts, outputs
- [ ] Record gold standard numbers from the paper:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Main ATT | Table 2, Col 3 | -1.632 | (0.584) | Primary specification |
```

- [ ] Store targets in `quality_reports/LectureNN_replication_targets.md` or as RDS

---

## Phase 2: Translate & Execute

- [ ] Follow `r-code-conventions.md` for all R coding standards
- [ ] Translate line-by-line initially -- don't "improve" during replication
- [ ] Match original specification exactly (covariates, sample, clustering, SE computation)
- [ ] Save intermediate results: `fst::write_fst()` for tabular data, `qs2::qs_save()` for model objects

### Stata to R Translation Pitfalls

<!-- Customize: Add pitfalls specific to your field -->

| Stata | R | Trap |
|-------|---|------|
| `reg y x, cluster(id)` | `feols(y ~ x, cluster = ~id)` | Stata clusters df-adjust differently from some R packages |
| `areg y x, absorb(id)` | `feols(y ~ x \| id)` | Check demeaning method matches |
| `probit` for PS | `glm(family=binomial(link="probit"))` | R default logit != Stata default in some commands |
| `bootstrap, reps(999)` | Depends on method | Match seed, reps, and bootstrap type exactly |

---

## Phase 3: Verify Match

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Integers (N, counts) | Exact match | No reason for any difference |
| Point estimates | < 0.01 | Rounding in paper display |
| Standard errors | < 0.05 | Bootstrap/clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Percentages | < 0.1pp | Display rounding |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample size, SE computation, default options, variable definitions), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/LectureNN_replication_report.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Original language:** [Stata/R/etc.]
**R translation:** [script path]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- R version, key packages (with versions), data source
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication script: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with course-specific modifications (different estimators, new figures, etc.)
- [ ] Each extension builds on the verified baseline

---

## Enforcement

This rule is enforced by the [`/audit-reproducibility`](../skills/audit-reproducibility/SKILL.md) skill. It parses numeric claims from a manuscript, locates matching values in `code/_outputs/` (or the user-specified outputs directory), and compares against the tolerance thresholds above. Run it:

- **Before submission** — `/audit-reproducibility path/to/manuscript.tex`
- **Before releasing a replication package** — same invocation; aim for zero FAILs.
- **As a pre-commit gate** — wire into `/commit` when the diff touches both manuscript and analysis files.

The skill exits 1 on any tolerance violation, so it integrates cleanly with quality gates.

---

## Claims Provenance: `passport.yaml`

A passport is a single per-paper, per-branch YAML file at `quality_reports/passports/<paper-slug>.yaml` that records, for each verified numeric claim in the manuscript, the script invocation and output file that produced it. The contract is intentionally narrow: numeric claims only (point estimates, standard errors, p-values, sample sizes, percentages from tables/figures), not prose claims (which `/verify-claims` handles separately).

`templates/passport-template.yaml` is the starter file. Forkers should copy it once per paper.

### Schema

```yaml
paper:
  slug: <paper-slug>                              # used in filename + report headings
  title: <full paper title>
  branch: <git branch on which this passport is current>
  last_audit: <ISO-8601 timestamp>
  last_audit_by: "/audit-reproducibility"         # or human, or another skill

claims:
  - id: C1                                        # stable identifier (used in cross-references)
    claim: "ATT = -1.632 (SE 0.584, N=4291)"     # exact text or paraphrase from manuscript
    location: "manuscript.tex:Table 2, Col 3"     # where it appears in the paper
    source_file: code/03_analyze.R           # script that produced the value
    source_line: 147                              # nearest line in the script
    output_file: code/_outputs/main_did.rds  # where the value lives on disk
    output_field: att_overall                      # field within the output (e.g., list element, column)
    tolerance:
      point_estimate: 0.01                         # absolute tolerance per Phase 3 above
      standard_error: 0.05
      n: exact
    last_verified_on: <ISO-8601>
    last_verified_by: "/audit-reproducibility"
    status: PASS                                   # PASS | FAIL | STALE | UNVERIFIED
    notes: |
      Optional notes — e.g., "matches paper to 3 decimals; SE differs in 4th
      decimal due to clustering df adjustment, within tolerance."
```

### `status` semantics

- **PASS** — last audit confirmed the claim within tolerance.
- **FAIL** — last audit detected a discrepancy outside tolerance. Blocks `/commit` for the affected files unless explicit override.
- **STALE** — the underlying `source_file` or `output_file` was modified after `last_verified_on`. Re-run `/audit-reproducibility` to refresh.
- **UNVERIFIED** — the claim was added to the manuscript but never run through `/audit-reproducibility`. Should not appear in a submission-ready passport.

### Integration

- **`/audit-reproducibility`** reads the passport at start, writes back after every claim audit. Failed claims are reported with their `id` and `location` so the author can find them in the manuscript instantly.
- **`/commit`** reads the passport when a diff touches both `manuscript.tex` (or .qmd) and any `source_file` listed. If the passport contains any FAIL or STALE for a claim whose `source_file` is in the diff, `/commit` halts (advisory by default; gate-refuse if `--strict-passport` is set in `.claude/settings.json`).
- **`/review-paper`** (default mode + `--peer`) appends a summary section to its report when the passport exists: `claims: N total, PASS: A, FAIL: B, STALE: C, UNVERIFIED: D`. Editors and referees know whether numeric claims have been independently verified at draft time.

### Inspiration

The pattern is borrowed from [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills)'s "Material Passport" concept (a YAML state-file threaded through their pipeline). Their schema is heavier (13 contracts, threaded through ~6 agents); ours is deliberately scoped to numeric-claim provenance only. Forkers who need broader provenance tracking can extend the schema or vendor ARS's design directly.

### Anti-patterns

- **Do not auto-populate** the passport at `/audit-reproducibility` time without showing the user the inferred mapping. Source-line inference is best-effort; the author confirms.
- **Do not promote UNVERIFIED claims to PASS** without running the actual numeric audit. The passport is a verified-state artifact; bypassing the verification defeats the purpose.
- **Do not use the passport as a substitute for `/verify-claims`.** The passport handles numeric claims with code provenance; `/verify-claims` handles citation and named-entity claims with literature provenance. Both run.
