# My Claude Code Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/See-CHANGELOG-blue.svg)](CHANGELOG.md)
[![Contributing](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](.github/CONTRIBUTING.md)

> **Actively maintained.** A ready-to-fork academic workflow for slides, papers,
> replication packages, and empirical analysis. The empirical layer now treats
> **Stata, Python, and R as first-class options**.

**Live site:** [psantanna.com/claude-code-my-workflow](https://psantanna.com/claude-code-my-workflow/)

This repository packages an academic AI workflow built around Claude Code, with
Codex-compatible skills and agents layered on top. It is designed for users who
want the repo to handle planning, implementation, review, verification, and
quality checks across teaching materials and empirical research.

---

## Quick Start

> **Minimum baseline:** Claude Code + git + Python 3.
>
> **HelloWorld demos:** add XeLaTeX and Quarto.
>
> **Empirical work:** Python is required for the Python workflow and internal
> tooling. R is recommended. Stata is strongly supported but optional.

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-my-workflow.git my-project
cd my-project
./scripts/validate-setup.sh
claude
```

Inside Claude Code, typical first actions are:

```text
/compile-latex HelloWorld
/deploy HelloWorld
/data-analysis-python data/example.csv
/data-analysis-stata data/example.dta
/data-analysis-r data/example.csv
```

If you only need manuscript or empirical workflows, you can skip the Beamer and
Quarto demos and go directly to `/review-paper`, `/lit-review`, or the relevant
language-specific analysis/review skill.

---

## What This Repo Supports

| Academic Task | Workflow Support |
| --- | --- |
| Lecture slides (Beamer/Quarto) | Creation, translation, audit, parity QA, deployment |
| Research papers | Literature review, manuscript review, peer-style critique |
| Data analysis | End-to-end Stata, Python, or R workflows |
| Replication packages | Numeric claim verification and cross-artifact audits |
| Presentation polish | Proofreading, layout audit, pedagogy review |
| Research ideation | Structured question generation and interactive refinement |

---

## Empirical Workflow Layout

The empirical layer is now organized as three parallel tracks:

```text
scripts/
|- R/
|- python/
`- stata/
```

Each track follows the same high-level structure:

1. load raw data
2. clean or transform
3. analyze or estimate
4. export tables
5. export figures
6. write outputs to `scripts/<language>/_outputs/`

Language-specific entry points:

| Skill | Purpose |
| --- | --- |
| `/data-analysis-python` | Python-first empirical workflow |
| `/data-analysis-stata` | Stata-first empirical workflow |
| `/data-analysis-r` | R-first empirical workflow |
| `/data-analysis` | Legacy R compatibility entry point |
| `/review-python` | Static Python empirical code review |
| `/review-stata` | Static Stata do-file review |
| `/review-r` | Static R empirical code review |
| `/audit-reproducibility` | Cross-check manuscript claims against outputs |

---

## Key Skills

This repo currently exposes **33 Codex skills** through `.agents/skills/`.
The most commonly used ones are:

| Skill | What It Does |
| --- | --- |
| `/compile-latex` | 3-pass XeLaTeX build with bibtex |
| `/deploy` | Render Quarto and sync to `docs/` |
| `/proofread` | Grammar, typo, overflow, and terminology review |
| `/visual-audit` | Slide layout and overflow audit |
| `/pedagogy-review` | Narrative and teaching review |
| `/slide-excellence` | Multi-lens slide review with conditional fanout |
| `/review-paper` | Manuscript review with optional peer simulation |
| `/seven-pass-review` | Seven-pass adversarial manuscript review |
| `/verify-claims` | Factual verification workflow |
| `/lit-review` | Literature search and synthesis |
| `/respond-to-referees` | Response-to-referees drafting |
| `/data-analysis-python` | Python empirical pipeline |
| `/data-analysis-stata` | Stata empirical pipeline |
| `/data-analysis-r` | R empirical pipeline |
| `/review-python` | Python code review |
| `/review-stata` | Stata code review |
| `/review-r` | R code review |
| `/audit-reproducibility` | Numeric claim verification against outputs |
| `/deep-audit` | Repository-wide consistency audit |
| `/commit` | Stage, commit, PR, and merge workflow |

---

## What's Included

This repo currently includes:

- **14 custom agents** under `.codex/agents/`
- **33 skills** under `.agents/skills/`
- **26 rules** under `.claude/rules/`
- **3 empirical script templates** under `scripts/R/`, `scripts/python/`, and `scripts/stata/`

Representative custom agents:

- `proofreader`
- `slide-auditor`
- `pedagogy-reviewer`
- `r-reviewer`
- `editor`
- `domain-referee`
- `methods-referee`
- `verifier`

Representative rule families:

- `quality-gates`
- `verification-protocol`
- `replication-protocol`
- `r-code-conventions`
- `python-code-conventions`
- `stata-code-conventions`
- `beamer-quarto-sync`
- `single-source-of-truth`

---

## Prerequisites

| Tool | Required For | Install |
| --- | --- | --- |
| [Claude Code](https://code.claude.com/docs/en/overview) | Everything | [claude.ai/install](https://claude.ai/install) |
| git | Clone and version control | [git-scm.com](https://git-scm.com/downloads) |
| Python 3 (3.9+) | Internal tooling and Python empirical workflow | [python.org](https://www.python.org/) |
| XeLaTeX | Beamer compilation | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| [Quarto](https://quarto.org) | Quarto slides and deployment | [quarto.org/docs/get-started](https://quarto.org/docs/get-started/) |
| R | Optional R empirical workflow | [r-project.org](https://www.r-project.org/) |
| Stata | Strongly supported Stata empirical workflow | [stata.com](https://www.stata.com/) |
| pdf2svg | TikZ to SVG pipeline | platform package manager |
| [gh CLI](https://cli.github.com/) | PR and issue workflow | [cli.github.com](https://cli.github.com/) |

Use `./scripts/validate-setup.sh` to see what is installed and what each tool
unlocks.

---

## Adapting for Your Field

1. Fill in the knowledge base in `.claude/rules/knowledge-base-template.md`.
2. Customize `.claude/agents/domain-reviewer.md` for your field.
3. Update the Beamer and Quarto palette together, then run `./scripts/check-palette-sync.sh`.
4. Add field-specific pitfalls to the relevant language rules:
   - `.claude/rules/r-code-conventions.md`
   - `.claude/rules/python-code-conventions.md`
   - `.claude/rules/stata-code-conventions.md`
5. Customize `.claude/WORKFLOW_QUICK_REF.md` with your preferences.
6. Use `explorations/` for experimental work.

---

## Origin

This infrastructure was extracted from **Econ 730: Causal Panel Data** at Emory
University, developed by Pedro Sant'Anna using Claude Code over multiple
sessions. It began as an R-heavy workflow and now supports Stata, Python, and R
side by side for empirical work.

---

## Additional Resources

- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [Writing a Good CLAUDE.md](https://code.claude.com/docs/en/memory)
- [CHANGELOG.md](CHANGELOG.md)
- [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md)

---

## License

MIT License. See [LICENSE](LICENSE).
