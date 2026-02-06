# Claude Code Academic Workflow

A ready-to-fork starter kit for academics using [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with **LaTeX/Beamer + R + Quarto**. Contains a complete multi-agent infrastructure — specialized reviewers, quality gates, adversarial QA loops, and automated workflows — extracted and genericized from a production PhD course.

---

## What This Is

This repository provides the **transportable infrastructure** behind a Claude Code workflow used to develop 6 complete PhD lecture decks (800+ slides) with:

- 10 specialized agents (proofreader, slide auditor, pedagogy reviewer, R code reviewer, TikZ critic, adversarial QA, and more)
- 13 slash-command skills (`/compile-latex`, `/proofread`, `/translate-to-quarto`, `/qa-quarto`, etc.)
- 11 context-aware rules (quality gates, notation consistency, auto-sync, replication protocol)
- Quality scoring with commit/PR/excellence thresholds (80/90/95)
- Adversarial critic-fixer QA loops that catch errors humans miss
- Automated Beamer-to-Quarto translation workflow

All domain-specific content has been replaced with `[PLACEHOLDER]` markers and `<!-- Customize -->` comments so you can adapt it to your field.

---

## Quick Start (5 minutes)

### 1. Fork & Clone

```bash
# Fork this repo on GitHub, then:
git clone https://github.com/YOUR_USERNAME/claude-code-academic-workflow.git
cd claude-code-academic-workflow
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

### Rules (`.claude/rules/`)

| Rule | What It Enforces |
|------|-----------------|
| `verification-protocol` | Task completion checklist (compile, verify, report) |
| `single-source-of-truth` | No content duplication; Beamer is authoritative |
| `quality-gates` | 80/90/95 scoring thresholds for commit/PR/excellence |
| `r-code-conventions` | R coding standards (structure, reproducibility, style) |
| `tikz-visual-quality` | TikZ diagram visual standards |
| `beamer-quarto-sync` | Auto-sync every Beamer edit to Quarto |
| `pdf-processing` | Safe large PDF handling (split, chunk, process) |
| `proofreading-protocol` | Propose-first, then apply with approval |
| `no-pause-beamer` | No overlay commands in Beamer |
| `replication-protocol` | Replicate original results before extending |
| `knowledge-base-template` | Notation/application/design principle registry |

---

## The Guide

For a comprehensive walkthrough of the entire workflow, see the **[Workflow Guide](guide/workflow-guide.qmd)**.

It covers:
1. **Why This Workflow Exists** — the problem and the vision
2. **The Building Blocks** — CLAUDE.md, rules, skills, agents, settings, memory
3. **Setting Up Your Project** — step-by-step from fork to first compile
4. **The Agent Ecosystem** — why specialized agents beat one-size-fits-all prompts
5. **Quality Gates & Verification** — the 80/90/95 scoring system
6. **Workflow Patterns** — lecture creation, translation, replication, multi-agent review
7. **Customizing for Your Domain** — creating your own reviewers and knowledge bases

To render the guide:
```bash
cd guide
quarto render workflow-guide.qmd
open workflow-guide.html
```

---

## Key Patterns

### The Adversarial Critic-Fixer Loop

The most powerful pattern in this workflow. Two agents work in opposition:
1. **Critic** reads both Beamer and Quarto, produces harsh findings
2. **Fixer** implements exactly what the critic found
3. Repeat until the critic says "APPROVED" (or 5 rounds max)

This catches notation inconsistencies, overflow, missing content, and visual regressions that single-pass review misses.

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

---

## Adapting for Your Field

1. **Fill in the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation, applications, and design principles
2. **Customize the domain reviewer** (`.claude/agents/domain-reviewer.md`) with review lenses specific to your field
3. **Update the color palette** in `Quarto/emory-clean.scss` — change the 3 color variables at the top
4. **Add field-specific R pitfalls** to `.claude/rules/r-code-conventions.md`
5. **Fill in the lecture mapping** in `.claude/rules/beamer-quarto-sync.md`

---

## Additional Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Best Practices](https://github.com/shanraisshan/claude-code-best-practice) — community-curated tips on context engineering, workflows, and debugging
- [Writing a Good CLAUDE.md](https://docs.anthropic.com/en/docs/claude-code/memory) — official guidance on project memory

---

## Origin

This infrastructure was extracted from **Econ 730: Causal Panel Data** at Emory University, developed by Pedro Sant'Anna using Claude Code over 6+ sessions. The course produced 6 complete PhD lecture decks with 800+ slides, interactive Quarto versions with plotly charts, and full R replication packages — all managed through this multi-agent workflow.

---

## License

MIT License. Use freely for teaching, research, or any academic purpose.
