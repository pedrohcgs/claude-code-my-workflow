---
name: disclosure-check
description: "Pre-screen analysis outputs (tables, figures, logs) built on restricted or confidential data for statistical-disclosure-limitation problems before any release. Scans for small cell counts, complementary-suppression gaps, dominance (p-percent / (n,k)), re-identifiable exact counts, PII leakage, and unrounded sensitive statistics; classifies each finding CRITICAL / WARNING / OK and gates on any CRITICAL. Use before depositing or sharing restricted-data results, or when the user says \"disclosure check\", \"SDL scan\", \"is this output safe to release\", \"check for small cells\", \"disclosure avoidance\", \"pre-screen for the RDC\", or \"can I export this from the enclave\"."
---



# `$disclosure-check` — Statistical-Disclosure-Limitation pre-screen

Scan analysis outputs built on **restricted or confidential data** (Census FSRDC, IRS SOI, administrative registers, linked health records, proprietary firm panels) for the disclosure-avoidance problems that get an export request rejected — *before* it reaches the data provider's official disclosure review. The skill is a **pre-screen, not a substitute** for that review.

**Core principle:** A single un-suppressed `n=3` cell, an exact count that pins down one firm, or a `p`-percent dominance failure can re-identify a person or establishment. Catch it on your machine, not in the rejection email from the RDC analyst.

## When to use

- **Before requesting an export** from a Census FSRDC / secure data enclave / RDC.
- **Before depositing** restricted-data results to openICPSR, a journal, or a co-author outside the enclave.
- **Before sharing any figure, table, or log** derived from confidential microdata.
- **As a release gate.** Pair with a pre-commit / pre-deposit invocation so no restricted-data output ships un-screened. This is the foundation of the data-management plan for any restricted-data project.

## Inputs

- `the first argument` — outputs directory to scan. Defaults to `scripts/R/_outputs/`. Recognised siblings: `scripts/python/_outputs/`, `scripts/python/_outputs/`, or any export-staging directory (e.g., a `to_review/` folder the analyst stages for the RDC).
- `--provider` — selects which disclosure-rule profile to load (Phase 0). One of `census` / `irs` / `irb` / `generic`. **Providers differ** — thresholds and rules are not interchangeable; default `generic` is deliberately conservative.
- `--threshold N` — override the minimum cell count (default `n<10`). Census FSRDC commonly uses 10 for establishments; IRS and many IRBs differ. Always reconcile with your provider's *written* rules.

## Workflow

### Phase 0: Load the provider's disclosure rules

1. Read [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) for the project's restricted-data handling contract and the rule-profile placeholder.
2. Load the `--provider` profile (a **placeholder config** the forker fills in from their *signed* agreement — Census, IRS, and IRB rules differ and supersede any default here):
   - **min cell count** (default `n<10`),
   - **dominance rules**: `p`-percent (a cell is unsafe if the largest respondents contribute > `p`% of the total) and `(n,k)` (top `n` units > `k`% of total),
   - **rounding** required for sensitive statistics (counts, totals, ratios),
   - **top-coding / bottom-coding** thresholds for extreme values,
   - **geographic** minimum population for any geocoded statistic.
3. If no signed-rule values are recorded, fall back to the conservative `generic` profile and **flag prominently** in the report that real provider thresholds must be substituted.

### Phase 1: Scan the outputs directory

Glob the outputs dir for `.tex`, `.csv`, `.txt`, `.log`, `.smcl`, `.out`, `.md` tables and figure-data files. For each:

- **Cell counts** — parse table cells / frequency columns; flag any count `0 < n < threshold` that is not already suppressed.
- **Complementary-suppression gaps** — if one cell in a row/column is suppressed but the margin total and the other cells let a reader back it out by subtraction, the suppression is **incomplete**.
- **Dominance** — for any total/mean cell where unit-level contributions are available (or inferable), apply the `p`-percent and `(n,k)` rules.
- **Exact re-identifying counts** — small exact integers (e.g., "4 hospitals", "1 firm", a max/min that is a single observation) that single out a unit.
- **PII leakage** — regex for names, SSNs (`\d{3}-\d{2}-\d{4}`), exact dates of birth, addresses, exact lat/long or fine geocodes, record IDs that survived into an output.
- **Unrounded sensitive statistics** — exact unrounded counts/totals where the provider requires rounding.

### Phase 2: Classify each finding — CRITICAL / WARNING / OK

| Disposition | Meaning | Examples |
|---|---|---|
| **CRITICAL** | Would fail the provider's disclosure review; blocks release. | `n=3` cell un-suppressed; complementary-suppression hole; `p`-percent dominance failure; any PII; an exact count identifying ≤2 units. |
| **WARNING** | Plausibly safe but needs a human judgment call. | Cell at exactly the threshold; unrounded total just over a rounding base; geographic statistic near the min-population floor. |
| **OK** | Within the loaded rules, no action needed. | Counts ≥ threshold and rounded; dominance passes; no PII. |

When two findings interact (a suppressed cell + a recoverable margin), report them **together** — the gate cares about the joint disclosure risk, not each cell in isolation. Be economics-aware: DiD / event-study cell counts per (cohort × period), IV first-stage subsamples, RCT arm × stratum balance tables, and panel firm-counts are the usual offenders.

### Phase 3: Suggest remediation

For each CRITICAL / WARNING, propose the standard SDL fix, in order of preference:

- **Suppress** the offending cell (and its complement, if a margin allows back-out).
- **Round** counts/totals to the provider's base (e.g., nearest 10 or 15).
- **Top-code / bottom-code** extreme values.
- **Aggregate** — collapse thin categories, coarsen geography, widen bins until every cell clears the threshold.
- **Drop** the statistic if no remediation preserves both safety and meaning.

Each suggestion names the file, the cell/location, the rule it violates, and the concrete edit — never auto-applies it (the analyst owns the disclosure decision).

### Phase 4: Gate

Exit non-zero on any **CRITICAL**. WARNINGs surface but do not block. See Exit behavior.

## Output / Report format

Write `quality_reports/disclosure_check_[outputs-dir-slug].md`:

```markdown
# Disclosure Check: [outputs dir]

**Date:** [YYYY-MM-DD]
**Provider profile:** census | irs | irb | generic   (rules source: confidential-data.md)
**Min cell count:** [N]   **Dominance:** p=[p]%, (n,k)=([n],[k]%)   **Rounding base:** [b]

## Summary
| Disposition | Count |
|---|---|
| CRITICAL | M |
| WARNING | W |
| OK | P |
| **Verdict** | **PASS / FAIL** (FAIL iff M > 0) |

## CRITICAL (blocks release)
| File | Location | Rule violated | Observed | Suggested remediation |
|---|---|---|---|---|
| tab3_by_cohort.tex | row "2008", col "n" | min cell (n<10) | n=4 | suppress cell + suppress complement in margin |

## WARNING (human judgment)
| File | Location | Concern | Suggested action |
|---|---|---|---|

## OK
[counts only, or a short list]

## Next steps
1. Resolve every CRITICAL — suppress / round / top-code / aggregate, then re-run.
2. Review WARNINGs with the agreement's written rules in hand.
3. Re-run until zero CRITICAL, THEN submit to the provider's OFFICIAL disclosure review.
```

## Exit behavior

- **Zero CRITICAL:** exit 0; report printed. (WARNINGs allowed — they are surfaced, not blocking.)
- **Any CRITICAL:** exit 1; summary to stderr. This makes the skill usable as a release / pre-deposit gate. Mirrors [`$audit-reproducibility`](../audit-reproducibility/SKILL.md)'s gate semantics: WARNING ≠ FAIL, only CRITICAL blocks.
- **No rules loaded (generic fallback):** exit 0 with a **prominent warning** that real provider thresholds were not supplied — the pre-screen ran but at conservative defaults, not the actual agreement.

## Flags

- `--provider` `<name>` — Load that data provider's disclosure rules (e.g. `census-fsrdc`, `irs`, `irb`). Default: the generic small-cell ruleset.
- `--threshold` `<n>` — Override the minimum cell-count threshold (default `n<10`); match your data-use agreement's actual rule.

## Cross-references

- [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) — restricted-data handling contract + the provider-rule profiles this skill loads.
- [`.codex/guidance/replication-protocol.md`](../../../.codex/guidance/replication-protocol.md) — for restricted-data papers the replication package ships code + access path, not the microdata; screen every released output first.
- [`.agents/skills/audit-reproducibility/SKILL.md`](../audit-reproducibility/SKILL.md) — numeric paper↔code verification: run it on the *retained* values, this skill on the *released* ones.
- [`.agents/skills/data-analysis/SKILL.md`](../data-analysis/SKILL.md) — produces the R or Python outputs this skill screens.
- [AEA Data Editor checklist](https://aeadataeditor.github.io/) and the [DCAS standard](https://datacodestandard.org/) — disclosure + access expectations for restricted-data deposits (openICPSR restricted-access stub).

## What this skill does NOT do

- **It does not replace the data provider's official disclosure review.** Census/RDC, IRS, and IRB analysts run the authoritative review; this skill **pre-screens** so the official review is more likely to pass on the first pass. A PASS here is not clearance to release.
- **It does not certify your rules are correct.** It applies the thresholds *you load* from your signed agreement; if the loaded `--provider` profile is wrong, the scan is wrong. Reconcile with the written agreement, not a default.
- **It does not move, encrypt, or transmit data,** never exfiltrates microdata from the enclave — it reads only the staged outputs you point it at.
- **It does not catch every disclosure risk.** Differencing across released tables, longitudinal re-identification, and model-based inferential disclosure can evade a per-file scan. A clean run is necessary, not sufficient.
