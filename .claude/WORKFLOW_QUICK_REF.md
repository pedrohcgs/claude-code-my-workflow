# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates via dependency graph)

---

## The Research Pipeline

```
/interview-me → Research Spec + Domain Profile
    ↓
/lit-review → Literature Synthesis (Librarian + Editor)
    ↓
/find-data → Data Assessment (Explorer + Surveyor)
    ↓
/identify → Strategy Memo (Strategist + Econometrician)
    ↓
/data-analysis → Scripts + Output (Coder + Debugger)
    ↓
/draft-paper → Paper Sections (Writer + Humanizer)
    ↓
/paper-excellence → Weighted Score (4 agents parallel)
    ↓
/review-paper → Peer Review (2 Referees + Editor)
    ↓
/submit → Final Gate (score >= 95, all components >= 80)
```

Enter at any stage. Use `/new-project` for the full pipeline.

---

## Key Skills by Research Stage

### Ideation & Literature
| Command | Agents | What It Does |
|---------|--------|-------------|
| `/interview-me [topic]` | — | Interactive Q&A → research spec + domain profile |
| `/lit-review [topic]` | Librarian + Editor | Literature search + synthesis |
| `/research-ideation [topic]` | — | Research questions + strategies |

### Data & Strategy
| Command | Agents | What It Does |
|---------|--------|-------------|
| `/find-data [question]` | Explorer + Surveyor | Data discovery + quality assessment |
| `/identify [question]` | Strategist + Econometrician | Design identification strategy |
| `/pre-analysis-plan [spec]` | Strategist | Draft PAP (AEA/OSF/EGAP) |

### Analysis & Writing
| Command | Agents | What It Does |
|---------|--------|-------------|
| `/data-analysis [dataset]` | Coder + Debugger | End-to-end analysis + code review |
| `/draft-paper [section]` | Writer | Paper sections + humanizer pass |
| `/compile-latex [file]` | — | 3-pass XeLaTeX + bibtex |

### Quality & Review
| Command | Agents | What It Does |
|---------|--------|-------------|
| `/econometrics-check [file]` | Econometrician | 4-phase causal inference audit |
| `/review-r [file]` | Debugger | Code quality review (standalone) |
| `/proofread [file]` | Proofreader | 6-category manuscript review |
| `/paper-excellence [file]` | 4 parallel | Multi-agent review + weighted score |
| `/review-paper [file]` | 2 Referees + Editor | Simulated peer review |
| `/validate-bib` | — | Cross-reference citations |

### Submission & Deposit
| Command | Agents | What It Does |
|---------|--------|-------------|
| `/target-journal [paper]` | Editor | Journal targeting + strategy |
| `/respond-to-referee [report]` | Writer + routing | Point-by-point response |
| `/data-deposit` | Coder + Verifier | AEA replication package |
| `/audit-replication [dir]` | Verifier | 10-check submission audit |
| `/submit [journal]` | Verifier + scoring | Final gate (score >= 95) |

### Presentations
| Command | Agents | What It Does |
|---------|--------|-------------|
| `/create-talk [format]` | Storyteller + Discussant | Beamer talk (4 formats) |
| `/visual-audit [file]` | — | Slide layout audit |

### Infrastructure
| Command | What It Does |
|---------|-------------|
| `/commit [msg]` | Stage, commit, PR, merge |
| `/humanizer [file]` | Strip 24 AI writing patterns |
| `/journal` | Research journal timeline |
| `/context-status` | Session health + context usage |
| `/learn` | Extract discoveries into skills |
| `/deploy` | Build + deploy to GitHub Pages |

---

## Quality Gates

| Score | Gate | What It Means |
|-------|------|--------------|
| >= 95 | Submission | Ready for top-5 (all components >= 80) |
| >= 90 | PR | Ready to submit (minor polish recommended) |
| >= 80 | Commit | Ready to commit (address major issues before submission) |
| < 80 | **Blocked** | Must fix critical/major issues |
| -- | Advisory | Talks: reported only, non-blocking |

Weighted aggregate: Literature 10% + Data 10% + Identification 25% + Code 15% + Paper 25% + Polish 10% + Replication 5%

---

## I Ask You When

- **Design forks:** "Option A vs. Option B. Which?"
- **Identification choice:** "CS DiD vs. Sun-Abraham for this setting?"
- **Disagreement with referee:** "DISAGREE classification — please review"
- **After 3 strikes:** "Coder and Debugger can't agree — your call"

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
