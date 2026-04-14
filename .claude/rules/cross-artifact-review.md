---
description: Paper ↔ code cross-artifact review — when /review-paper runs, auto-invoke /review-r on referenced scripts and /audit-reproducibility on the pair. Surface cross-artifact findings alongside the paper review.
globs: ["master_supporting_docs/**/*.tex", "master_supporting_docs/**/*.qmd", "Slides/**/*.tex", "*.tex", "*.qmd"]
alwaysApply: false
---

# Cross-Artifact Review Protocol

A paper is not an island. Its claims depend on the code that produced them. Reviewing the paper without reviewing the code is reviewing half the artifact.

## The Dependency Graph

```
manuscript.tex ──cites──> Table 2
Table 2        ──from──> scripts/R/_outputs/results.rds
results.rds    ──by──> scripts/R/03_analyze.R
03_analyze.R   ──uses──> scripts/R/_outputs/clean.rds
clean.rds      ──by──> scripts/R/02_clean.R
02_clean.R     ──reads──> data/raw.csv
```

A bug in `02_clean.R` invalidates Table 2. Reviewing `manuscript.tex` without touching the code misses this class of error entirely.

## When to apply

Applies when `/review-paper` runs on a manuscript that references analysis scripts. Detection signals:

- `\input{scripts/R/...}` or `\input{tables/...}`
- `%% source: scripts/R/03_analyze.R` comments
- Numeric claims in text (ATT, coefficients, N, p-values)
- Paper lives in a repo that has `scripts/R/` or `scripts/stata/` or `scripts/python/`

## The protocol

When `/review-paper` detects any of the above:

### 1. Identify referenced scripts

Scan the manuscript for:

- `\input{path}` commands (tables, figures pulled from files)
- Line comments `%% from: scripts/...`
- Table labels that match filenames in `scripts/R/_outputs/` (e.g., `Table:main_ATT` ↔ `results_main.rds`)

Build a list of scripts that produced content in this paper.

### 2. Auto-invoke `/review-r`

For each identified R script, launch `/review-r` in a forked subagent (`context: fork`). Save reports to `quality_reports/cross_artifact_[paper]/review_r_[script].md`.

### 3. Auto-invoke `/audit-reproducibility`

Run `/audit-reproducibility $manuscript scripts/R/_outputs/` once. Save to `quality_reports/cross_artifact_[paper]/reproducibility.md`.

### 4. Surface cross-artifact findings

In the paper review report, add a new section:

```markdown
## Cross-Artifact Findings

**Scripts reviewed:** N (see `quality_reports/cross_artifact_[paper]/`)
**Reproducibility:** PASS / FAIL — k of m claims within tolerance
**Code quality (merged from /review-r reports):** C critical, M major, L minor

### Critical cross-artifact issues (paper + code together)
| Paper claim | Code location | Issue |
|---|---|---|

### Code-only issues (won't block paper, but file a follow-up)
…

### Paper-only issues (code is clean)
[Rest of the paper review goes here]
```

### 5. Exit behavior

- Any CRITICAL from `/audit-reproducibility` (FAIL on tolerance) → escalate to CRITICAL in paper review.
- Code CRITICAL bugs that affect paper claims → escalate in paper review.
- Code CRITICAL bugs unrelated to paper claims → file as separate action item.

## Opt-out

- `/review-paper --no-cross-artifact` skips the dependency graph. Useful for theory papers, comments, or preprints without code.

## Cross-references

- `.claude/skills/review-paper/SKILL.md` — the orchestrator.
- `.claude/skills/review-r/SKILL.md` — code reviewer.
- `.claude/skills/audit-reproducibility/SKILL.md` — numeric claims verifier.
- `.claude/rules/replication-protocol.md` — tolerance contract.

## What this rule does NOT require

- Running R / Stata / Python (that's `/audit-reproducibility`'s job, and it reads existing outputs).
- Git-blame archaeology — we review current state.
- Judging whether a paper's authors wrote good code vs. whether their *results* are defensible. We care about the latter first.

## `--peer` mode ordering

In `/review-paper --peer [journal]` mode, cross-artifact review runs **before** the editor's desk review (as Phase 0). This gives the editor reproducibility evidence — any FAIL on load-bearing claims is desk-reject-worthy. The editor's desk review will cite specific `/audit-reproducibility` findings in the desk_review.md when relevant.

In default and `--adversarial` modes, cross-artifact still runs at Step 6b (after the paper review). Both orderings are valid; the `--peer` pre-flight ordering exists because editors make desk-reject decisions based on evidence of data errors.

