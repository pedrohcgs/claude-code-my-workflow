---
name: validate-bib
description: Validate bibliography entries against citations in all lecture files. Structural checks (missing/unused entries, malformed fields) by default; `--semantic` adds citation-drift detection, DOI verification, and style-consistency checks.
argument-hint: "[--semantic] [--skip-doi] [--cite-claim]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "WebFetch"]
---

# Validate Bibliography

Cross-reference citations in lecture files against bibliography entries. Two modes:

- **Default (structural):** missing entries, unused entries, malformed fields, typo candidates.
- **`--semantic`:** adds citation-drift detection (duplicate entries for the same paper), DOI verification via crossref, and citation-style consistency within each file.

Report saved to `quality_reports/bib_audit_[structural|semantic].md`.

## Mode 1: Structural (default)

### Steps

1. **Read the bibliography file** and extract all citation keys.

2. **Scan lecture files for citation keys:**
   - `.tex`: `\cite{`, `\citet{`, `\citep{`, `\citeauthor{`, `\citeyear{`, `\textcite{`, `\parencite{`
   - `.qmd` / `.md`: `@key`, `[@key]`, `[@key1; @key2]`
   - Extract all unique citation keys used.

3. **Cross-reference:**
   - **Missing entries (CRITICAL):** cited in lectures, absent from `.bib`.
   - **Unused entries (informational):** in `.bib` but never cited.
   - **Typo candidates:** keys within edit-distance 2 of a `.bib` key (e.g., `Smith2020` vs `Smth2020`).

4. **Check entry quality:**
   - Required fields present (author, title, year, journal/booktitle).
   - Author field properly formatted.
   - Year in 1900–current.
   - No malformed characters / encoding issues.
   - `doi` field normalized (no leading `https://doi.org/`).

5. **Write report** to `quality_reports/bib_audit_structural.md`.

### Files scanned

```
Slides/*.tex
Quarto/*.qmd
guide/*.qmd
master_supporting_docs/**/*.tex
```

### Bibliography location

`Bibliography_base.bib` at repo root by default; override via CLAUDE.md.

## Mode 2: Semantic (`--semantic`)

Everything in Mode 1, plus:

### 2a. Citation drift detection

Multiple `.bib` entries describing the same paper under different keys. Symptoms:

- `Smith2020` + `Smith2020a` with identical DOI or title.
- `CallawaySantAnna2021` + `CS2021` both pointing to the same paper.
- Collaborator-merged `.bib` files.

**Detection heuristics (any → FLAG):**

| Check | Signal |
|---|---|
| Same DOI across keys | Hard-duplicate (CRITICAL) |
| Same title (case-insensitive, punct-stripped) | Likely duplicate (CRITICAL) |
| Same author+year+journal | Probable duplicate (MEDIUM) |
| Title Jaccard > 0.85 on tokens ≥ 4 chars | Soft-duplicate (LOW) |

For each flagged pair: list both keys, where each is cited, and recommend a canonical key (prefer most-cited, then alphabetically first).

### 2b. DOI verification (optional; network)

For each entry with a `doi`, fetch `https://api.crossref.org/works/{doi}` and compare:

- First-author last name
- Year
- Title (Jaccard > 0.7 on normalized tokens)
- Container-title / journal (exact or abbreviation)

**Severity:**

- Author or title mismatch → CRITICAL (wrong paper)
- Year mismatch → MEDIUM (preprint vs published, or typo)
- Journal mismatch → LOW (legitimate preprint variants)

**Rate limit:** cap 50 lookups per run, 0.5s delay between calls. Cache in `quality_reports/.doi_cache.json`.

**Opt-out:** `--skip-doi` for offline or no-WebFetch environments.

### 2c. Style consistency within each file

For each file, count citation commands (`\citet` vs `\citep` vs `\cite`; `@key` vs `[@key]`). FLAG files with mixed styles without an obvious pattern (e.g., 20× `\citep` and 3× `\cite` in the same deck). Low-severity.

### 2d. Cite-claim sanity (flag-only)

Gated behind `--cite-claim`. For the top-10 most-cited works per file, WebFetch the crossref abstract and surface it beside the in-text context. **No auto-judgment** — humans decide if the claim matches.

### Report structure (`quality_reports/bib_audit_semantic.md`)

```markdown
# Bibliography Semantic Audit

**Date:** YYYY-MM-DD
**Bibliography:** Bibliography_base.bib (N entries)
**Files scanned:** [list]

## Summary

| Check | Critical | Medium | Low |
|---|---|---|---|
| Structural | | | |
| Citation drift | | | |
| DOI verification | | | |
| Style consistency | 0 | 0 | |

## Critical Issues

### Duplicate entries
| Keys | Signal | Citations | Recommended canonical |
|---|---|---|---|

### DOI mismatches
| Key | Field | .bib value | crossref value |
|---|---|---|---|

## Medium / Low issues
…

## Next steps
1. Resolve duplicates — pick canonical key, update citations, remove orphans.
2. Fix DOI mismatches — verify paper in crossref or strip the wrong DOI.
3. Review style-consistency notes.
```

## Exit behavior

- **Structural:** exit 0; report enumerates issues.
- **Semantic:** exit 0 if only LOW findings; exit 1 on any CRITICAL. Usable as a pre-submission gate.

## Cross-references

- `.claude/skills/review-paper/SKILL.md` — pair for full pre-submission.
- `.claude/skills/audit-reproducibility/SKILL.md` — numeric-claims counterpart.

## What this skill does NOT do

- Judge whether a citation is used in the right *context* (`--cite-claim` surfaces abstracts but does not judge).
- Auto-fix your `.bib` file — all edits are recommendations.
- Check non-DOI identifiers (ISBN, arXiv, SSRN) — roadmap.
