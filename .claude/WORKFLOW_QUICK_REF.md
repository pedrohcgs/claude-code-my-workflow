# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)

---

## The Research Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## Key Skills by Research Stage

### Ideation & Literature
| Command | What It Does |
|---------|-------------|
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |

### Writing & Drafting
| Command | What It Does |
|---------|-------------|
| `/draft-paper [section]` | Draft paper sections (intro, results, etc.) |
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/proofread [file]` | Grammar/typo/writing review |

### Econometrics & Analysis
| Command | What It Does |
|---------|-------------|
| `/econometrics-check [file]` | Causal inference design audit |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/review-r [file]` | R code quality review |
| `/validate-bib` | Cross-reference citations |

### Quality & Review
| Command | What It Does |
|---------|-------------|
| `/paper-excellence [file]` | Multi-agent paper review (primary score) |
| `/review-paper [file]` | Manuscript review (referee simulation) |
| `/visual-audit [file]` | Layout audit |

### Submission & Deposit
| Command | What It Does |
|---------|-------------|
| `/target-journal [paper]` | Journal targeting + strategy |
| `/respond-to-referee [report]` | Point-by-point response |
| `/data-deposit` | AEA Data Editor compliance |
| `/audit-replication [dir]` | Validate replication package |
| `/pre-analysis-plan [spec]` | Draft PAP (AEA/OSF/EGAP) |

### Presentations
| Command | What It Does |
|---------|-------------|
| `/create-talk [format]` | Generate Beamer talk (job-market/seminar/short/lightning) |
| `/devils-advocate [file]` | Challenge talk design |

### Workflow
| Command | What It Does |
|---------|-------------|
| `/commit [msg]` | Stage, commit, PR, merge |
| `/context-status` | Check context usage + session health |

---

## Quality Gates

| Score | Paper & R (blocking) | Talks (advisory) |
|-------|---------------------|------------------|
| >= 95 | Excellence | - |
| >= 90 | Ready to submit | - |
| >= 80 | Ready to commit | - |
| < 80 | **Blocked** — fix issues | Reported only |

---

## I Ask You When

- **Design forks:** "Option A vs. Option B. Which?"
- **Identification choice:** "CS DiD vs. Sun-Abraham for this setting?"
- **Scope question:** "Also run robustness X while here?"
- **Disagreement with referee:** "DISAGREE classification — please review"

## I Just Execute When

- Code fix is obvious (bug, pattern)
- Verification (compilation, tolerance checks)
- Documentation (logs, commits)
- Plotting (per established standards)

---

## Exploration Mode

For experimental work:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
