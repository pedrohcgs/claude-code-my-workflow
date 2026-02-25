# The Clo-Author: Your Econ AI Research Assistant for Claude Code

> **Work in progress.** This is an experiment born out of my discovery of [Pedro's tool](https://github.com/pedrohcgs/claude-code-my-workflow). This repo is a packaging of my own interpretation of that, tailored to pure research. It is evolving as I learn, and I share it in case others find it useful and would like to build upon. Expect rough edges.

An open-source [Claude Code](https://docs.anthropic.com/en/docs/claude-code) workflow that turns your terminal into a full-service applied econometrics research assistant — from literature review to journal submission.

**Live guide:** [hsantanna.org/clo-author](https://hsantanna.org/clo-author/)
**Built on:** [Pedro Sant'Anna's claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow)

---

## Quick Start

```bash
# 1. Fork and clone
gh repo fork hsantanna88/clo-author --clone
cd clo-author

# 2. Open Claude Code
claude
```

Then paste this prompt:

> I am starting a new applied econometrics research project on **[YOUR TOPIC]**.
> Read CLAUDE.md and help me set up the project structure.
> Start with a literature review on [YOUR TOPIC].

Claude reads the configuration, fills in your project details, and enters contractor mode — planning, implementing, reviewing, and verifying autonomously.

**Using VS Code?** Open the Claude Code panel instead. Everything works the same.

---

## What It Does

### Contractor Mode

You describe a task. Claude plans the approach, implements it, runs specialized review agents, fixes issues, re-verifies, and scores against quality gates — all autonomously. You approve the plan and see a summary when the work meets quality standards.

### 12 Specialized Agents

Instead of one general-purpose reviewer, focused agents each check one dimension:

| Agent | What It Checks |
|-------|---------------|
| **Econometrician** | Identification, causal design, SE clustering, estimator choice |
| **Proofreader** | Grammar, typos, consistency |
| **R-Reviewer** | Code quality, reproducibility, domain correctness |
| **Domain Reviewer** | Field-specific substance (customizable for your field) |
| **Replication Auditor** | Replication package completeness |
| **Verifier** | End-to-end compilation and output verification |
| **Slide Auditor** | Visual layout for presentations |
| **TikZ Reviewer** | Diagram quality |
| **Pedagogy Reviewer** | Teaching quality (for lecture slides) |
| **Beamer Translator** | Beamer-to-Quarto conversion |
| **Quarto Critic/Fixer** | Adversarial QA for slide translation |

### 26 Slash Commands

| Command | What It Does |
|---------|-------------|
| `/draft-paper [section]` | Draft paper sections with proper academic structure |
| `/econometrics-check [file]` | Causal inference design audit (DiD, IV, RDD, SC, ES) |
| `/paper-excellence [file]` | Multi-agent paper review (parallel agents + scoring) |
| `/respond-to-referee [report]` | Point-by-point referee response |
| `/lit-review [topic]` | Literature search + synthesis + gap identification |
| `/research-ideation [topic]` | Research questions + empirical strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Full manuscript review |
| `/data-analysis [dataset]` | End-to-end R analysis with publication-ready output |
| `/pre-analysis-plan [spec]` | Draft PAP (AEA/OSF/EGAP format) |
| `/data-deposit` | AEA Data Editor compliance check |
| `/audit-replication [dir]` | Validate replication package |
| `/target-journal [paper]` | Journal targeting + submission strategy |
| `/create-talk [format]` | Generate Beamer talk from paper |
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/proofread [file]` | Grammar/typo review |
| `/visual-audit [file]` | Layout audit |
| `/review-r [file]` | R code quality review |
| `/validate-bib` | Cross-reference citations |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/devils-advocate [file]` | Challenge presentation design |
| `/slide-excellence [file]` | Combined multi-agent slide review |
| `/learn` | Extract session discoveries into persistent skills |
| `/context-status` | Show session health and context usage |
| `/deploy` | Render + sync to GitHub Pages |
| `/create-lecture` | Full lecture creation workflow |

### Quality Gates

Every file gets a score (0–100). Scores below threshold block the action:

| Score | Gate | Applies To |
|-------|------|------------|
| 80 | Commit | Paper, R scripts (blocking) |
| 90 | PR | Paper, R scripts (blocking) |
| 95 | Excellence | Aspirational |
| -- | Advisory | Talks (reported, non-blocking) |

### Context Survival

Plans, specifications, and session logs survive auto-compression and session boundaries. MEMORY.md accumulates learning across sessions — patterns discovered in one session inform future work.

---

## Project Structure

```
your-project/
├── CLAUDE.md                    # Project configuration (fill in placeholders)
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Paper/                       # Main LaTeX manuscript (source of truth)
│   ├── main.tex
│   └── sections/
├── Talks/                       # Derivative Beamer presentations
├── Figures/                     # Generated figures (R output)
├── Tables/                      # Generated tables (R output)
├── Supplementary/               # Online appendix
├── Replication/                 # Replication package for deposit
├── scripts/                     # R code + utility scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox
└── master_supporting_docs/      # Reference papers and data docs
```

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Everything | `npm install -g @anthropic-ai/claude-code` |
| XeLaTeX | Paper compilation | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| R | Analysis & figures | [r-project.org](https://www.r-project.org/) |
| [gh CLI](https://cli.github.com/) | GitHub integration | `brew install gh` (macOS) |

Optional: [Quarto](https://quarto.org) (web slides), pdf2svg (TikZ to SVG).

---

## Adapting for Your Field

1. **Fill in `CLAUDE.md`** — replace `[BRACKETED PLACEHOLDERS]` with your project details
2. **Customize the domain reviewer** (`.claude/agents/domain-reviewer.md`) with review lenses for your field
3. **Add field-specific R conventions** to `.claude/rules/r-code-conventions.md`
4. **Set up the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation and methods

The Clo-Author is designed for applied econometrics but the infrastructure (contractor mode, quality gates, multi-agent review) works for any quantitative research field.

---

## Origin

This project is a fork of [Pedro Sant'Anna's claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow), which was built for Econ 730 at Emory University (6 lectures, 800+ slides). The Clo-Author reorients that infrastructure from lecture production to applied econometrics research publication.

The core infrastructure (contractor mode, quality gates, context survival, session logging) comes from the original template. The econometrics-specific agents, paper drafting skills, and submission workflow are new.

---

## License

MIT License. Fork it, customize it, make it yours.
