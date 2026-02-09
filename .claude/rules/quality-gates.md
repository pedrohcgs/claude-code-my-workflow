---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
---

# Quality Gates & Scoring Rubrics

**Purpose:** Define objective quality thresholds for committing and deploying course materials.

---

## Scoring System

- **80/100 = Commit threshold** — Good enough to save progress
- **90/100 = PR threshold** — High quality ready for deployment
- **95/100 = Excellence** — Aspirational target

---

## Quarto Lecture Slides (.qmd files)

### Critical (Must Pass for Commit)
| Issue | Deduction |
|-------|-----------|
| Compilation failure | -100 (auto-fail) |
| Equation overflow | -20 per instance |
| Broken citation | -15 per citation |
| Typo in equation | -10 per typo |

### Major (Should Pass for PR)
| Issue | Deduction |
|-------|-----------|
| Text overflow | -5 per instance |
| TikZ label overlap | -5 per diagram |
| Notation inconsistency | -3 per occurrence |

### Minor (Nice-to-Have)
| Issue | Deduction |
|-------|-----------|
| Font size reduction used | -1 per slide |
| Missing framing sentence | -1 per definition |
| Long lines (>100 chars) | -1 per line, EXCEPT documented mathematical formulas (see `r-code-conventions.md`) |

---

## R Scripts (.R files)

### Critical
| Issue | Deduction |
|-------|-----------|
| Syntax errors | -100 (auto-fail) |
| Known domain-specific bugs | -30 |
| Hardcoded absolute paths | -20 |

### Major
| Issue | Deduction |
|-------|-----------|
| Missing set.seed() | -10 |
| Missing figure generation | -5 per figure |
| Wrong color palette | -3 per figure |

---

## Beamer Slides (.tex files)

### Critical
| Issue | Deduction |
|-------|-----------|
| XeLaTeX compilation failure | -100 (auto-fail) |
| Undefined citation | -15 per citation |
| Overfull hbox > 10pt | -10 per instance |

---

## Quality Gate Enforcement

### Commit Gate (score < 80)
Block commit. List blocking issues with required actions.

### PR Gate (score < 90)
Allow commit but warn. List issues with recommendations to reach PR quality.

### User can override with justification when needed.

---

## Quality Report Timing

**Quality reports are generated ONLY at merge time** (not at every commit or PR):

- **Before commit:** No quality report (too frequent)
- **Before PR:** No quality report (use session logs)
- **Before merge to main:** Generate quality report and save to `quality_reports/merges/`

This prevents documentation overhead during frequent commits while maintaining a quality snapshot for every feature merged to main.

---

## Merge Quality Report Template

**When:** Generated only at merge to main
**Where:** `quality_reports/merges/YYYY-MM-DD_[branch-name].md`

```markdown
# Quality Report: Merge to Main — [Date]

## Summary
[1-2 sentences: what was merged and why]

## Files Modified
| File | Type | Quality Score |
|------|------|---|
| `path/to/file` | [Code/Slides/Config] | [N]/100 |

## Verification
- [ ] Compilation/execution succeeds
- [ ] Tolerance checks PASS (if applicable)
- [ ] Tests pass (if applicable)
- [ ] Quality gates >= 80

## Status
MERGED

## Notes
[Any learnings or follow-ups]
```

---

## Tolerance Thresholds (Research Projects)

<!-- Customize for your domain's precision requirements -->

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | [e.g., 1e-6 relative] | [Numerical precision] |
| Standard errors | [e.g., 1e-4 relative] | [MC variability + numerical methods] |
| Coverage rates | [e.g., +/- 0.01] | [MC variability with B reps] |
| RMSE | [e.g., 1e-2] | [MC + numerical error] |

**Pass criteria:** All quantities within tolerance.
**Failure handling:** Investigate before committing. If just beyond tolerance, check numerical stability. If far beyond, likely a code bug.
