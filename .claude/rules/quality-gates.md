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
