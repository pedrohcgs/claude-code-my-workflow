# Clo-Author

[![Version](https://img.shields.io/github/v/release/hugosantanna/clo-author?style=flat-square&color=b44dff&label=version)](CHANGELOG.md)

A Claude Code scaffold for empirical economics research. Literature review to journal submission, with 18 agents that review each other's work.

Guide: [hugosantanna.github.io/clo-author](https://hugosantanna.github.io/clo-author/)

---

## To Get Started

```bash
# Fork and clone
gh repo fork hugosantanna/clo-author --clone
cd clo-author

# Open Claude Code (terminal, VS Code, or JetBrains)
claude
```

Then:

```
I am starting a research project on [YOUR TOPIC]. Read CLAUDE.md and help me set up.
```

Claude reads the config, plans the approach, you approve, it runs. Works in the terminal, VS Code extension, or JetBrains.

---

## Setup

1. Fill in `CLAUDE.md` — replace `[BRACKETED PLACEHOLDERS]` with your project details
2. Fill in `.claude/references/domain-profile.md` — your field, journals, data, methods. Or run `/discover interview` to do it interactively.
3. Configure your language — R is the default. Python and Julia also supported.

**Other fields:** Economics by default. Adapts to labor, public, health, development, trade, IO, and other applied fields by customizing the domain profile and journal profiles.

---

## Commands

13 skills, each with modes:

| Skill | What It Does |
|-------|-------------|
| `/new-project` | Full pipeline: idea to paper |
| `/discover` | Literature search, data discovery, research interviews |
| `/strategize` | Identification strategy, pre-analysis plan, formal theory |
| `/analyze` | Data analysis (R, Python, Julia) |
| `/write` | Draft paper sections with humanizer pass |
| `/review` | Quality review — routes by target (paper, code, peer) |
| `/revise` | R&R cycle: classify referee comments and route fixes |
| `/talk` | Presentations (Quarto RevealJS or Beamer) |
| `/submit` | Journal targeting, replication package, final gate |
| `/tools` | Utilities: commit, compile, validate-bib, journal, deploy |
| `/checkpoint` | Session handoff: saves progress to memory + Obsidian |
| `/freeze` | Lock directories from accidental edits |
| `/careful` | Block destructive shell commands |

---

## Agents

18 agents in worker-critic pairs. Critics can't edit files. Creators can't score themselves. If they disagree after 3 rounds, it escalates.

| Phase | Worker | Critic |
|-------|--------|--------|
| Discovery | Librarian | librarian-critic |
| Discovery | Explorer | explorer-critic |
| Strategy | Strategist | strategist-critic |
| Strategy | Theorist | theorist-critic |
| Execution | Coder | coder-critic |
| Execution | Data-engineer | coder-critic |
| Paper | Writer | writer-critic |
| Peer Review | Editor + domain-referee + methods-referee | — |
| Presentation | Storyteller | storyteller-critic |
| Infrastructure | Orchestrator, Verifier | — |

---

## Peer Review

`/review --peer [journal]` simulates a full journal submission:

1. Editor desk review — novelty check via web search, decides desk reject or send out
2. Two blind referees with intellectual dispositions (Structuralist, Credibility, Measurement, Policy, Theory, Skeptic) weighted by journal culture
3. Independent scored reports — every major comment includes "what would change my mind"
4. Editorial decision — FATAL / ADDRESSABLE / TASTE classification, MUST / SHOULD / MAY action items

Additional modes:
- `--stress` — adversarial referees for pre-submission battle testing
- `--r2` — R&R second round with referee memory
- Max 3 rounds, then the editor's patience runs out

30 journal profiles across economics and adjacent fields.

---

## HTML Dashboard

One command generates a self-contained HTML dashboard of your entire project — sections, data, scripts, quality scores, review history. No server, no dependencies. Double-click to open.

```bash
python3 scripts/generate_dashboard.py
```

Detail reports drill down into individual components:

```bash
python3 scripts/generate_html_report.py peer-review [files...]
python3 scripts/generate_html_report.py code-audit [files...]
python3 scripts/generate_html_report.py strategy [files...]
python3 scripts/generate_html_report.py quality-gate [files...]
python3 scripts/generate_html_report.py literature [files...]
```

Self-contained HTML with dark mode, collapsible sections, and print support. Works on `file://`.

---

## Quality Gates

Weighted aggregate scoring across all components:

| Score | Gate |
|-------|------|
| 80 | Commit allowed |
| 90 | PR allowed |
| 95 | Submission allowed (all components >= 80) |

Nothing ships below 80.

---

## Project Structure

```
your-project/
├── CLAUDE.md                    # Project config (fill in placeholders)
├── .claude/                     # Agents, skills, rules, hooks
├── paper/                       # LaTeX manuscript (source of truth)
│   ├── main.tex
│   ├── sections/
│   ├── figures/
│   ├── tables/
│   ├── talks/
│   └── replication/
├── data/                        # Raw and cleaned datasets
├── scripts/                     # Analysis code (R, Python, Julia)
├── quality_reports/             # Reviews, scores, plans, traces
├── templates/html/              # HTML report design system
└── explorations/                # Research sandbox
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` |
| XeLaTeX | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| R | [r-project.org](https://www.r-project.org/) |

Optional: Python, Julia, [Quarto](https://quarto.org), [gh CLI](https://cli.github.com/).

---

## Upgrading

The upgrade only touches `.claude/` (infrastructure). Your paper, scripts, data, and bibliography are never modified.

```bash
# Download latest, replace .claude/, done
```

Or use `/tools upgrade` from within Claude Code.

---

## This is a Scaffold

Every output needs human review. Claude plans and executes; you decide what ships. The peer review catches structural issues but doesn't replicate actual referee expertise. Quality scores flag problems but don't measure publishability. The writer produces drafts, not final prose.

---

## Origin

Maintained by [Hugo Sant'Anna](https://hsantanna.org) at UAB.

MIT License.
