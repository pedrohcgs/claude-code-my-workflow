# My Claude Code Setup

> **Work in progress.** This is not meant to be a polished guide for everyone. It's mostly a summary of how I've been using Claude Code for academic work — creating lecture slides, writing R scripts, managing Beamer-to-Quarto workflows, and so on. I keep learning new things, and as I do, I keep updating these files. This is just a way for me to share what I've figured out with friends and colleagues.

**Live site:** [psantanna.com/claude-code-my-workflow](https://psantanna.com/claude-code-my-workflow/)

A ready-to-fork starter kit for academics using [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with **LaTeX/Beamer + R + Quarto**. You describe what you want; Claude plans the approach, runs specialized agents, fixes issues, verifies quality, and presents results — like a contractor who handles the entire job. Extracted from a production PhD course.

---

## What This Is

This repository provides the **transportable infrastructure** behind a Claude Code workflow used to develop 6 complete PhD lecture decks (800+ slides) with:

- **Contractor-mode orchestrator** — you describe the task; Claude plans, implements, reviews with agents, fixes issues, and re-verifies until quality gates pass
- **Adversarial critic-fixer loops** — two agents check each other's work across up to 5 rounds, catching errors humans miss
- **Quality scoring** with commit/PR/excellence thresholds (80/90/95) — nothing ships below 80
- **Automated Beamer-to-Quarto translation** with TikZ-to-SVG and ggplot-to-plotly conversion
- **Research exploration workflow** with structured sandbox, fast-track prototyping, and simplified orchestrator
- 10 specialized agents, 14 slash commands, 15 auto-loaded rules

All domain-specific content has been replaced with `[PLACEHOLDER]` markers and `<!-- Customize -->` comments so you can adapt it to your field.

---

## Quick Start (5 minutes)

### 1. Fork & Clone

```bash
# Fork this repo on GitHub, then:
git clone https://github.com/YOUR_USERNAME/claude-code-my-workflow.git
cd claude-code-my-workflow
```

### 2. Customize CLAUDE.md

Open `CLAUDE.md` and fill in:
- Your course name, institution, and instructor name
- Your folder structure (or keep the default)
- Your design principles and preferences

**Tip:** Keep CLAUDE.md under ~150 lines for best results. Move detailed instructions into `.claude/rules/` files instead.

### 3. Create Your Knowledge Base

Open `.claude/rules/knowledge-base-template.md` and start filling in:
- Your notation conventions
- Your lecture progression
- Your running examples/applications

### 4. Test It

```bash
# Create a simple test .tex file in Slides/, then:
claude  # Start Claude Code
# Type: /compile-latex Slides/test.tex
```

If it compiles, your setup is working.

---

## What's Included

### Agents (`.claude/agents/`)

| Agent | What It Does |
|-------|-------------|
| `proofreader` | Grammar, typos, overflow, consistency review |
| `slide-auditor` | Visual layout audit (overflow, font consistency, spacing) |
| `pedagogy-reviewer` | 13-pattern pedagogical review (narrative arc, notation density, pacing) |
| `r-reviewer` | R code quality, reproducibility, and domain correctness |
| `tikz-reviewer` | Merciless TikZ diagram visual critique |
| `beamer-translator` | Beamer-to-Quarto translation specialist |
| `quarto-critic` | Adversarial QA comparing Quarto against Beamer benchmark |
| `quarto-fixer` | Implements fixes from the critic agent |
| `verifier` | End-to-end task completion verification |
| `domain-reviewer` | **Template** for your field-specific substance reviewer |

### Skills (`.claude/skills/`)

| Skill | What It Does |
|-------|-------------|
| `/compile-latex` | 3-pass XeLaTeX compilation with bibtex |
| `/deploy` | Render Quarto + sync to GitHub Pages |
| `/extract-tikz` | TikZ diagrams to PDF to SVG pipeline |
| `/proofread` | Launch proofreader on a file |
| `/visual-audit` | Launch slide-auditor on a file |
| `/pedagogy-review` | Launch pedagogy-reviewer on a file |
| `/review-r` | Launch R code reviewer |
| `/qa-quarto` | Adversarial critic-fixer loop (max 5 rounds) |
| `/slide-excellence` | Combined multi-agent review |
| `/translate-to-quarto` | Full 11-phase Beamer-to-Quarto translation |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/devils-advocate` | Challenge design decisions before committing |
| `/create-lecture` | Full lecture creation workflow |

### Research Workflow

Features for research projects (papers, simulations, empirical analysis):

| Feature | What It Does |
|---------|-------------|
| Exploration folder | Structured `explorations/` sandbox with graduate/archive lifecycle |
| Fast-track workflow | 60/100 quality threshold for rapid prototyping |
| Simplified orchestrator | implement → verify → score → done (no multi-round reviews) |
| Enhanced session logging | Structured tables for changes, decisions, verification |
| Merge-only reporting | Quality reports at merge time only |
| Math line-length exception | Long lines acceptable for documented formulas |
| Workflow quick reference | One-page cheat sheet at `.claude/WORKFLOW_QUICK_REF.md` |

### Rules (`.claude/rules/`)

| Rule | What It Enforces |
|------|-----------------|
| `verification-protocol` | Task completion checklist (compile, verify, report) |
| `single-source-of-truth` | No content duplication; Beamer is authoritative |
| `quality-gates` | 80/90/95 scoring + merge-only reporting + tolerance thresholds |
| `r-code-conventions` | R coding standards + mathematical line-length exception |
| `tikz-visual-quality` | TikZ diagram visual standards |
| `beamer-quarto-sync` | Auto-sync every Beamer edit to Quarto |
| `pdf-processing` | Safe large PDF handling (split, chunk, process) |
| `proofreading-protocol` | Propose-first, then apply with approval |
| `no-pause-beamer` | No overlay commands in Beamer |
| `replication-protocol` | Replicate original results before extending |
| `knowledge-base-template` | Notation/application registry (course + research variants) |
| `plan-first-workflow` | Plan mode for non-trivial tasks + context preservation |
| `orchestrator-protocol` | Contractor mode: full loop (slides) or simple loop (research) |
| `exploration-folder-protocol` | Structured sandbox for experimental work |
| `exploration-fast-track` | Lightweight workflow for explorations (60/100 threshold) |
| `session-logging` | Enhanced logging with structured templates |

---

## The Guide

For a comprehensive walkthrough of the entire workflow, read the **[full guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html)** (or see the [source](guide/workflow-guide.qmd)).

It covers:
1. **Why This Workflow Exists** — the problem and the vision
2. **The Building Blocks** — CLAUDE.md, rules, skills, agents, settings, memory
3. **Setting Up Your Project** — step-by-step from fork to first compile
4. **The Agent Ecosystem** — why specialized agents beat one-size-fits-all prompts
5. **Quality Gates & Verification** — the 80/90/95 scoring system
6. **Workflow Patterns** — lecture creation, translation, replication, multi-agent review, research exploration
7. **Customizing for Your Domain** — creating your own reviewers and knowledge bases

---

## Key Patterns

### Plan-First Workflow

Non-trivial tasks start in **plan mode** before any files are touched:
1. **Plan** — draft approach, list files to modify, identify risks
2. **Save** — persist the plan to `quality_reports/plans/` (survives context compression)
3. **Review** — present to user for approval
4. **Implement** — orchestrator takes over (see below)

Companion rule: **never use `/clear`**. Rely on auto-compression for context management — it preserves important context gracefully, while `/clear` destroys everything.

### Contractor Mode (Orchestrator)

After plan approval, the orchestrator takes over autonomously:
1. **Implement** the plan steps
2. **Verify** — compile, render, check outputs
3. **Review** — select agents by file type (.tex gets proofreader + slide-auditor + pedagogy-reviewer; .qmd adds quarto-critic; .R gets r-reviewer)
4. **Fix** — apply fixes from reviews (critical first)
5. **Re-verify** and **score** against quality gates
6. Loop up to 5 rounds until score meets threshold, then present summary

When the user says "just do it", the orchestrator also auto-commits at score >= 80.

### Quality Gates

Every file gets a score (0-100). Scores below threshold block the action:
- **80** — commit threshold (blocks `git commit` if below)
- **90** — PR threshold (warns if below)
- **95** — excellence (aspirational target)

### Progressive Agent Specialization

Instead of one general-purpose reviewer, use focused agents:
- The **proofreader** only looks at grammar/typos
- The **slide-auditor** only looks at visual layout
- The **pedagogy-reviewer** only looks at teaching quality
- The **domain-reviewer** only looks at field-specific correctness

Each agent is better at its narrow task than a generalist would be.

### The Adversarial Critic-Fixer Loop

Two agents work in opposition:
1. **Critic** reads both Beamer and Quarto, produces harsh findings
2. **Fixer** implements exactly what the critic found
3. Repeat until the critic says "APPROVED" (or 5 rounds max)

This catches notation inconsistencies, overflow, missing content, and visual regressions that single-pass review misses.

### Continuous Learning

Every correction gets tagged with `[LEARN:tag]` format and persists in MEMORY.md across sessions. This prevents Claude from repeating the same mistakes.

### Session Logging (with Automated Reminders)

Claude saves session logs to `quality_reports/session_logs/`. A lightweight **Stop hook** (`scripts/log-reminder.py`) tracks how many responses have passed since the log was last updated. After a threshold, it reminds Claude to update the log. Git records *what* changed; session logs record *why*.

---

## Adapting for Your Field

1. **Fill in the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation, applications, and design principles — use Section 5 (Research Project Variant) for papers
2. **Customize the domain reviewer** (`.claude/agents/domain-reviewer.md`) with review lenses specific to your field
3. **Update the color palette** in `Quarto/emory-clean.scss` — change the 3 color variables at the top
4. **Add field-specific R pitfalls** to `.claude/rules/r-code-conventions.md`
5. **Fill in the lecture mapping** in `.claude/rules/beamer-quarto-sync.md`
6. **Customize the workflow quick reference** (`.claude/WORKFLOW_QUICK_REF.md`) with your non-negotiables and preferences
7. **Set up the exploration folder** (`explorations/`) for experimental work

---

## Additional Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Writing a Good CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code/memory) — official guidance on project memory

---

## Origin

This infrastructure was extracted from **Econ 730: Causal Panel Data** at Emory University, developed by Pedro Sant'Anna using Claude Code over 6+ sessions. The course produced 6 complete PhD lecture decks with 800+ slides, interactive Quarto versions with plotly charts, and full R replication packages — all managed through this multi-agent workflow.

---

## License

MIT License. Use freely for teaching, research, or any academic purpose.
