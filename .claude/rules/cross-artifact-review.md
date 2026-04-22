---
description: Paper-to-code cross-artifact review. When /review-paper runs, auto-invoke the matching R, Python, or Stata review skill on referenced scripts and pair that with /audit-reproducibility.
globs: ["master_supporting_docs/**/*.tex", "master_supporting_docs/**/*.qmd", "Slides/**/*.tex", "*.tex", "*.qmd"]
alwaysApply: false
---

# Cross-Artifact Review Protocol

A paper is not an island. If the paper depends on code, review the code and the
reported numbers together.

## Dependency graph

```text
manuscript.tex -> Table 2
Table 2 -> scripts/<language>/_outputs/results.*
results.* -> scripts/<language>/03_analyze.<ext>
03_analyze.<ext> -> scripts/<language>/02_clean.<ext>
02_clean.<ext> -> data/raw.*
```

## When to apply

Apply when `/review-paper` detects any of these signals:

- `\input{scripts/...}` or `\input{tables/...}`
- comments such as `%% source: scripts/python/03_analyze.py`
- numeric claims in text plus a sibling `scripts/R/`, `scripts/python/`, or
  `scripts/stata/` directory
- table labels that match filenames under `scripts/*/_outputs/`

## Protocol

### 1. Identify referenced scripts

Scan the manuscript for referenced tables, figures, source comments, and script
paths. Build a list of `.R`, `.py`, and `.do` files that feed the manuscript.

### 2. Run the matching code reviews

- `.R` -> `/review-r`
- `.py` -> `/review-python`
- `.do` -> `/review-stata`

Save reports under `quality_reports/cross_artifact_[paper]/`.

### 3. Run reproducibility audit

Run `/audit-reproducibility` on the manuscript and the nearest relevant outputs
directory under `scripts/<language>/_outputs/`.

### 4. Surface findings in the paper review

Promote any load-bearing reproducibility failures or code defects into the top
of the manuscript review. Keep unrelated code-only issues as follow-up actions.

## Exit behavior

- Reproducibility FAIL on a claim cited in the manuscript -> critical paper issue
- Critical code defect affecting cited outputs -> critical paper issue
- Critical code defect unrelated to cited outputs -> separate follow-up item

## Opt-out

`/review-paper --no-cross-artifact` skips this protocol.
