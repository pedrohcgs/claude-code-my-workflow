# My Claude Code Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/See-CHANGELOG-blue.svg)](CHANGELOG.md)
[![Contributing](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](.github/CONTRIBUTING.md)

> **Actively maintained.** A summary of how I use Claude Code for academic work — slides, papers, data analysis, and more — packaged so you can fork it for your own research. See [CHANGELOG.md](CHANGELOG.md) for the latest changes.

**Live site:** [psantanna.com/claude-code-my-workflow](https://psantanna.com/claude-code-my-workflow/)

A ready-to-fork foundation for AI-assisted academic work. You describe what you want — lecture slides, a research paper, a data analysis, a replication package — and Claude plans the approach, runs specialized agents, fixes issues, verifies quality, and presents results. Like a contractor who handles the entire job. Extracted from a production PhD course and extended by a growing [community](#community--extensions).

---

## Quick Start (5–10 minutes, plus ~30 min for first-time installs)

> **Before you start:** Claude Code + git are the minimum. To run the included `HelloWorld` demos end-to-end you also need XeLaTeX (Beamer sample) and Quarto (Quarto sample). R and the GitHub CLI are recommended. Python 3 is used by a few internal scripts (`check-palette-sync.py`, `check-tikz-prevention.py`) and is pre-installed on macOS/Linux. Full list in [Prerequisites](#prerequisites) below. Fastest path: clone first, then run `./scripts/validate-setup.sh` — it reports exactly what's missing with install links.
>
> **Only need Python/R/markdown?** You don't need XeLaTeX or Quarto. The agents, rules, skills, and orchestration patterns work for any text/code artifact. Skip the `HelloWorld` demos and head straight to `/data-analysis`, `/review-paper`, `/lit-review`, or `/review-r`.
>
> **Session 2 onwards:** [MEMORY.md](MEMORY.md) (committed) collects generic `[LEARN]` entries that help all forkers; `.claude/state/personal-memory.md` (gitignored) is for machine-specific notes. See [`.claude/rules/meta-governance.md`](.claude/rules/meta-governance.md) for the distinction.

### 1. Fork & Clone

```bash
# Fork this repo on GitHub (click "Fork" on the repo page), then:
git clone https://github.com/YOUR_USERNAME/claude-code-my-workflow.git my-project
cd my-project
./scripts/validate-setup.sh        # reports missing tools with install links
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Start Claude Code and Paste This Prompt

```bash
claude
```

**Using VS Code?** Open the Claude Code panel instead. Everything works the same — see the [full guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-setup) for details.

> **Avoid prompt fatigue.** Out of the box, Claude Code asks permission for every tool invocation. After the first few approvals, toggle **Auto-accept edits** mode (a keybinding; see the [permission modes section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#settings---permissions-and-hooks) of the guide) or run `claude --permission-mode acceptEdits`. For fully-autonomous runs on a trusted repo, **Bypass** mode skips prompts entirely. The template's `.claude/settings.json` pre-approves ~100 common Bash and Edit/Write patterns, so even at default permissions most work is unattended.

Then paste the [starter prompt](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-first-session) from the guide, filling in your project details:

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2–3 sentences.]** I've set up the Claude Code academic workflow... Please read the configuration files and adapt them for my project. Enter plan mode and start.

The [full guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-first-session) has the complete starter prompt with all the details.

**What this does:** Claude reads all the configuration files, fills in your project name, institution, and preferences, then enters contractor mode — planning, implementing, and (within the skill you invoke) running the review + verify loop. You approve the plan, invoke a skill, and the skill handles the rest within its scope.

> **Heavily adapting CLAUDE.md for a non-academic project?** Anthropic's built-in `/init` command will re-derive a `CLAUDE.md` from your codebase as a starting point. The pre-shipped CLAUDE.md in this template already covers the academic setup — you only need `/init` if your fork diverges substantially (e.g., a Python/ML project that doesn't use LaTeX or Quarto).

### 3. Verify Your Setup

Before building real lectures, confirm your environment works:

```bash
./scripts/validate-setup.sh        # Checks XeLaTeX, Quarto, Python, git, etc.
```

Then inside Claude:

```text
/compile-latex HelloWorld          # Compiles Slides/HelloWorld.tex to PDF
/deploy HelloWorld                 # Renders Quarto/HelloWorld.qmd to HTML
```

If both succeed, delete `Slides/HelloWorld.tex` and `Quarto/HelloWorld.qmd` and start on your real work.

---

## How It Works

### Contractor Mode

You describe a task. For complex or ambiguous requests, Claude first creates a requirements specification with MUST/SHOULD/MAY priorities and clarity status (CLEAR/ASSUMED/BLOCKED). You approve the spec, then Claude plans the approach and invokes the right skill (e.g. `/create-lecture`, `/qa-quarto`, `/review-paper --adversarial`). That skill implements the orchestrator pattern internally — implement, verify, review, fix, re-verify, score — and returns a summary when the work meets quality standards. Say "just do it" and it auto-commits when the score clears 80.

### Specialized Agents

Instead of one general-purpose reviewer, 14 focused agents each check one dimension. A representative sample:

- **proofreader** — grammar/typos
- **slide-auditor** — visual layout
- **pedagogy-reviewer** — teaching quality
- **r-reviewer** — R code quality
- **domain-reviewer** — field-specific correctness, slides (template — customize for your field)
- **domain-referee** / **methods-referee** / **editor** — manuscript peer-review pipeline (`/review-paper --peer`)

Each is better at its narrow task than a generalist would be. The `/slide-excellence` skill runs the slide-review agents in parallel; `/review-paper --peer` runs the paper-review pipeline. The same pattern extends to any academic artifact — manuscripts, data pipelines, proposals.

### Adversarial QA

Two agents work in opposition: the **critic** reads both Beamer and Quarto and produces harsh findings. The **fixer** implements exactly what the critic found. They loop until the critic says "APPROVED" (or 5 rounds max). This catches errors that single-pass review misses.

### Quality Review

Every artifact gets a score (0–100). Scores below threshold halt the workflow and surface the findings — the user decides whether to fix or explicitly override:

- **80** — commit threshold
- **90** — PR threshold
- **95** — excellence (aspirational)

> **Framing honesty:** Thresholds are advisory at the harness level — the `/commit` skill runs quality checks and halts on failure, but there is no pre-commit git hook that blocks a direct `git commit`. If you bypass the skill, you bypass the review. For hard enforcement, configure a git pre-commit hook.

### Context Survival

Plans, specifications, and session logs survive auto-compression and session boundaries. The PreCompact hook saves a context snapshot before Claude's auto-compression triggers, ensuring critical decisions are never lost. MEMORY.md accumulates learning across sessions, so patterns discovered in one session inform future work.

For *forced* compression (long pipelines, mid-plan handoffs), `/compress-session` (v1.9.0) distils the conversation into a structured note — decisions, next actions, and **discarded-as-noise** — instead of letting auto-compaction truncate. `/promote-memory` (v1.9.0) periodically harvests generic learnings from gitignored personal-memory.md to committed MEMORY.md via a five-critic council.

### Verification Discipline (v1.7.0+)

Multiple complementary verification layers run before submission:

- **`/verify-claims`** (v1.7.0) — Chain-of-Verification with a forked verifier that cannot self-confirm because it has never seen the draft. v1.9.0 adds HIGH/MED/LOW-WARN severity tiers; HIGH-WARN (fabricated citation, numerical contradiction) gate-refuses `/commit`.
- **`/audit-reproducibility`** (v1.7.0; Stata coverage v1.9.0) — every numeric claim in the manuscript is cross-checked against the script output that produced it. v1.9.0 adds `passport.yaml` — a per-paper YAML state file with PASS/FAIL/STALE/UNVERIFIED status per claim.
- **`/humanize`** (v1.9.0) — detect AI-voice tells (boilerplate transitions, hedging stacking, sycophancy) before submission. Read-only by design; auto-rewriting degrades quality.
- **`/review-paper --variance N`** (v1.9.0) — runs N referees with sampled dispositions and reports a **decision distribution**, not a point estimate. Motivated by AgentReview (ACL 2024) finding 37% of decisions vary purely from disposition sampling.

---

## The Guide

For a comprehensive walkthrough, read the **[full guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html)** (or see the [source](guide/workflow-guide.qmd)).

It covers:
1. **Why This Workflow Exists** — the problem and the vision
2. **Getting Started** — fork, paste one prompt, and Claude sets up the rest
3. **The System in Action** — specialized agents, adversarial QA, quality scoring
4. **The Building Blocks** — CLAUDE.md, rules, skills, agents, hooks, memory
5. **Workflow Patterns** — slides, research, reproducibility, presentation rhetoric, sequential adversarial audits, and more
6. **The Ecosystem** — extensions by clo-author, claudeblattman, MixtapeTools, autoresearch, ClaudeCodeTools, and a growing community
7. **Customizing for Your Domain** — creating your own reviewers and knowledge bases

### 2026 Features

The guide covers Claude Code's latest capabilities:

- **Model lineup** (v1.9.0) — Opus 4.7 as Max/Team Premium default (GA 2026-04-16); Sonnet 4.6 workhorse (1M context); Haiku 4.5 fast tier. Sonnet 4 + original Opus 4 retire 2026-06-15.
- **Effort levels** — `/effort` command for cost vs. thoroughness tradeoffs (`low` / `medium` / `high` / `xhigh` (v1.9.0 — recommended for Opus 4.7 coding) / `max`)
- **`/goal <verifiable condition>`** (v1.9.0; Anthropic May 2026) — keep working across turns until a fast model confirms the condition holds. Pairs with `/commit` quality gates for verified-end-state runs.
- **`claude agents` dashboard** (v1.9.0; Anthropic May 2026) — single screen for parallel review work (`/review-paper --peer`, `/slide-excellence`).
- **Cost-Conscious Composition** (v1.9.0) — prompt-cache TTL change (60min → 5min), 70/20/10 model routing (Haiku/Sonnet/Opus), `/cost` + `/usage` monitoring, Agent SDK credit-pool split (2026-06-15).
- **Skill frontmatter** — `effort`, `context: fork`, `agent`, `hooks`, `disable-model-invocation` (v1.8.0+), and dynamic content (`$ARGUMENTS`, `!command` syntax)
- **Permission modes** — Normal, Auto-accept, Plan, Auto (Mar 2026; flag-free for Max+Opus 4.7 as of Apr 2026), Bypass
- **Hook handler types** — command, prompt, and HTTP handlers with 20+ hook events; hooks see `effort.level` and `$CLAUDE_EFFORT` (Apr 2026 Week 19)
- **Advanced agent configuration** — model, maxTurns, isolation, tool restrictions; `model-routing.md` rule codifies per-agent tier (v1.9.0)
- **Worktree base ref** (v1.9.0; Anthropic Apr 2026) — `worktree.baseRef` setting controls `fresh` (default; remote default-branch) vs `head` (local HEAD) for new worktrees
- **Built-in skills** — `/fewer-permission-prompts`, `/team-onboarding`, `/autofix-pr`, `/powerup`, Ultraplan, `/loop` (self-pacing)
- **Plugins** — `/discover-plugins` for third-party extensions

---

## Use Cases

| Academic Task | How This Workflow Helps |
|---------------|----------------------|
| Lecture slides (Beamer/Quarto) | Full creation, translation, multi-agent review, deployment |
| Research papers | Literature review, manuscript review, simulated peer review (`/review-paper --peer [journal]`), reviewer-disposition variance reporting (`--variance N`) |
| Data analysis | End-to-end R pipelines (`/data-analysis`) or Stata pipelines via `stata-mcp` (`/stata-replication`, v1.9.0), replication verification, publication-ready output |
| Replication packages | AEA-compliant packaging, reproducibility audit trails, `passport.yaml` claims provenance (v1.9.0) |
| Presentations | Rhetoric of decks principles, visual audit, cognitive load review |
| Research proposals | Structured drafting with adversarial critique |
| Preregistration | OSF / AsPredicted / AEA RCT Registry-ready document (`/preregister --style`) — full workflow in Pattern 16 |
| Manuscript submission discipline | `/humanize` (detect AI voice), `/verify-claims` HIGH-WARN gate (block fabricated citations), reviewer-disposition variance |

**Disciplines preloaded:** Economics (top-5 journal profiles, R conventions) and Political Science (APSR / AJPS / JOP profiles, formal-theory + survey-experiment paper types, conjoint/`cjoint` conventions). Forkers extend for psych / sociology / public-health via journal profiles + paper types + discipline cards.

---

## What's Included

<details>
<summary><strong>16 agents, 36 skills, 27 rules, 7 hooks</strong> (click to expand)</summary>

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
| `claim-verifier` (v1.7.0) | Chain-of-Verification fact-checker in a forked context |
| `editor` (v1.5.0) | Journal editor for `/review-paper --peer` (desk review + referee selection + synthesis) |
| `domain-referee` (v1.5.0) | Disposition-primed substance referee for `--peer` mode |
| `methods-referee` (v1.5.0+) | Paper-type-aware methodology referee (6 paper types) |
| `humanize-auditor` (v1.9.0) | Read-only AI-voice auditor invoked by `/humanize` |
| `promote-memory-council` (v1.9.0) | Five-critic council for `[LEARN]` promotion to MEMORY.md |

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
| `/commit` | Stage, commit, create PR, and merge to main |
| `/lit-review` | Literature search, synthesis, and gap identification |
| `/research-ideation` | Generate research questions and empirical strategies |
| `/interview-me` | Interactive interview to formalize a research idea |
| `/review-paper` | Manuscript review: structure, econometrics, referee objections |
| `/data-analysis` | End-to-end R analysis with publication-ready output |
| `/learn` | Extract non-obvious discoveries into persistent skills |
| `/context-status` | Show session health and context usage |
| `/deep-audit` | Repository-wide consistency audit |
| `/permission-check` | Diagnose permission layers when prompts fire unexpectedly |
| `/audit-reproducibility` | Enforce tolerance thresholds on paper ↔ code numeric claims |
| `/new-diagram` | Scaffold a TikZ diagram from the snippet gallery with prevention + review |
| `/respond-to-referees` | R&R response-letter generator (maps referee comments to revisions) |
| `/seven-pass-review` | Seven-pass adversarial manuscript review (parallel forked subagents) |
| `/checkpoint` | Structured session-handoff snapshot (state + plan pointers + next actions). Companion to narrative session logs. |
| `/preregister` | Generate a preregistration document (OSF / AsPredicted / AEA RCT Registry style) from a research spec |
| `/verify-claims` (v1.7.0) | Chain-of-Verification fact-check (forked verifier, fresh context). HIGH/MED/LOW-WARN severity tiers (v1.9.0); HIGH-WARN gate-refuses `/commit`. |
| `/humanize` (v1.9.0) | Detect AI-voice tells in academic prose (10 detection categories; read-only, no rewrite) |
| `/prompt` (v1.9.0) | Reformat informal/dictated input into a structured six-section prompt, then execute (ported from Blattman with stripping) |
| `/prompt-only` (v1.9.0) | Same formatting as `/prompt` but emits the prompt as a reusable artifact (no execution) |
| `/compress-session` (v1.9.0) | Distil current session into structured notes (decisions, next actions, *discarded-as-noise*) before auto-compaction |
| `/promote-memory` (v1.9.0) | Five-critic council that votes on which `[LEARN]` entries graduate from personal-memory.md to MEMORY.md |
| `/stata-replication` (v1.9.0) | End-to-end Stata pipeline via the `stata-mcp` MCP server (mirrors `/data-analysis` for R-first projects) |

### Research Workflow

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

Rules use path-scoped loading: **always-on** rules load every session (~100 lines total); **path-scoped** rules load only when Claude works on matching files. Claude follows ~150 instructions reliably, so less is more.

**Always-on** (no `paths:` frontmatter — load every session):

| Rule | What It Enforces |
|------|-----------------|
| `plan-first-workflow` | Plan mode for non-trivial tasks + context preservation |
| `orchestrator-protocol` | Contractor mode: implement → verify → review → fix → score |
| `session-logging` | Three logging triggers: post-plan, incremental, end-of-session |
| `meta-governance` | Template vs. working project distinctions |

**Path-scoped** (load only when working on matching files):

| Rule | Triggers On | What It Enforces |
|------|------------|-----------------|
| `verification-protocol` | `.tex`, `.qmd`, `docs/` | Task completion checklist |
| `single-source-of-truth` | `Figures/`, `.tex`, `.qmd` | No content duplication; Beamer is authoritative |
| `quality-gates` | `.tex`, `.qmd`, `*.R` | 80/90/95 scoring + tolerance thresholds |
| `r-code-conventions` | `*.R` | R coding standards + math line-length exception |
| `tikz-visual-quality` | `.tex` | TikZ diagram visual standards |
| `beamer-quarto-sync` | `.tex`, `.qmd` | Auto-sync Beamer edits to Quarto |
| `pdf-processing` | `master_supporting_docs/` | Safe large PDF handling |
| `proofreading-protocol` | `.tex`, `.qmd`, `quality_reports/` | Propose-first, then apply with approval |
| `no-pause-beamer` | `.tex` | No overlay commands in Beamer |
| `replication-protocol` | `*.R` | Replicate original results before extending |
| `knowledge-base-template` | `.tex`, `.qmd`, `*.R` | Notation/application registry template |
| `orchestrator-research` | `*.R`, `explorations/` | Simple orchestrator for research (no multi-round reviews) |
| `exploration-folder-protocol` | `explorations/` | Structured sandbox for experimental work |
| `exploration-fast-track` | `explorations/` | Lightweight exploration workflow (60/100 threshold) |
| `tikz-prevention` (v1.4.x) | `Slides/**`, `Figures/**`, `Preambles/**` | TikZ pre-flight grep checks (P3/P4 collision avoidance) |
| `tikz-measurement` (v1.5.x) | `Slides/**`, `Figures/**`, `Preambles/**`, `scripts/**` | Bézier curve depth math + 6-pass collision protocol (from MixtapeTools) |
| `content-invariants` (v1.6.x) | `.tex`, `.qmd`, `Preambles/`, `code/**` | Pre-Flight Reports — proves inputs were read before work |
| `cross-artifact-review` (v1.7.0) | `master_supporting_docs/`, `.tex`, `.qmd` | Paper ↔ code dependency graph; auto-invokes `/review-r` + `/audit-reproducibility` |
| `post-flight-verification` (v1.7.0) | Skills generating factual claims | Chain-of-Verification protocol with forked verifier |
| `summary-parity` (v1.8.x) | `CHANGELOG.md`, `README.md`, `.qmd`, skill/rule/agent `.md` | Anti-whack-a-mole: re-verify summaries against their bodies |
| `model-routing` (v1.9.0) | `.claude/agents/**/*.md`, `.claude/skills/**/SKILL.md` | 70/20/10 architect/editor split (Haiku/Sonnet/Opus) |
| `stata-code-conventions` (v1.9.0) | `**/*.do`, `code/stata/**` | Stata header scaffold, numbered pipeline, esttab, clustering discipline, AEA compliance |

### Templates (`templates/`)

| Template | What It Does |
|----------|-------------|
| `session-log.md` | Structured session logging format |
| `quality-report.md` | Merge-time quality report format |
| `exploration-readme.md` | Exploration project README template |
| `archive-readme.md` | Archive documentation template |
| `requirements-spec.md` | MUST/SHOULD/MAY requirements framework with clarity status |
| `constitutional-governance.md` | Template for defining non-negotiable principles vs. preferences |
| `skill-template.md` | Academic skill creation template with domain-specific examples |
| `decision-record.md` | Architectural decision record (ADR) template |
| `journal-profile-template.md` | Journal profile for `/review-paper --peer` editor calibration |
| `preregistration-template.md` (v1.8.0) | Preregistration document scaffold (OSF / AsPredicted / AEA RCT) |
| `passport-template.yaml` (v1.9.0) | Per-paper YAML passport for numeric-claim provenance (used by `/audit-reproducibility`) |
| `response-to-referees.md` | R&R response document scaffold |

</details>

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://code.claude.com/docs/en/overview) | Everything | [claude.ai/install](https://claude.ai/install) |
| git | Clone + version control | [git-scm.com](https://git-scm.com/downloads) |
| Python 3 (3.9+) | Internal checkers (palette sync, TikZ prevention) | Preinstalled on macOS/Linux; [python.org](https://www.python.org/) for Windows |
| XeLaTeX | LaTeX compilation (Beamer `HelloWorld`, real lectures) | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| [Quarto](https://quarto.org) | Web slides (Quarto `HelloWorld`, real lectures) | [quarto.org/docs/get-started](https://quarto.org/docs/get-started/) |
| R | Figures and analysis (`/data-analysis`, `code/` directory) | [r-project.org](https://www.r-project.org/) |
| pdf2svg | TikZ → SVG for Quarto (`/extract-tikz`) | `brew install pdf2svg` (macOS), `apt install pdf2svg` (Debian) |
| [gh CLI](https://cli.github.com/) | PR / issue workflow | `brew install gh` (macOS), `apt install gh` (Debian) |

**Minimum to fork this template:** Claude Code + git + Python 3 (Python is already installed on macOS/Linux).

**Minimum to run the included HelloWorld demos end-to-end:** add XeLaTeX (for `/compile-latex HelloWorld`) and Quarto (for `/deploy HelloWorld`).

**Your real lectures may need more** — R for `code/` analyses, pdf2svg if you use TikZ extraction, gh CLI if you use the PR-based commit workflow. `./scripts/validate-setup.sh` reports which of these are installed and what each unlocks.

---

## Adapting for Your Field

1. **Fill in the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation, applications, and design principles
2. **Customize the domain reviewer** (`.claude/agents/domain-reviewer.md`) with review lenses specific to your field
3. **Update the color palette** — this is a **two-surface contract**: change the HEX values at the top of **both** [`Preambles/header.tex`](Preambles/header.tex) (Beamer/TikZ) **and** [`Quarto/theme-template.scss`](Quarto/theme-template.scss) (Quarto slides) so they agree. Then run `./scripts/check-palette-sync.sh` to verify. Forgetting one surface silently produces mismatched Beamer vs. Quarto renderings. See [`Preambles/README.md`](Preambles/README.md) for the full contract and the TikZ style library.
4. **Add field-specific R pitfalls** to `.claude/rules/r-code-conventions.md`
5. **Fill in the lecture mapping** in `.claude/rules/beamer-quarto-sync.md`
6. **Customize the workflow quick reference** (`.claude/WORKFLOW_QUICK_REF.md`) with your non-negotiables and preferences
7. **Set up the exploration folder** (`explorations/`) for experimental work

---

## Additional Resources

- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [Writing a Good CLAUDE.md](https://code.claude.com/docs/en/memory) — official guidance on project memory

---

## Origin

This infrastructure was extracted from **Econ 730: Causal Panel Data** at Emory University, developed by Pedro Sant'Anna using Claude Code over 6+ sessions. The course produced 6 complete PhD lecture decks with 800+ slides, interactive Quarto versions with plotly charts, and full R replication packages — all managed through this multi-agent workflow. The patterns are domain-agnostic: the same agents, rules, and orchestrator work for any academic project.

---

## Community & Extensions

As of March 2026, **15+ research groups** across economics, energy, political science, and engineering have forked and adapted this workflow. The infrastructure (orchestrator, hooks, quality gates) transfers without modification.

**Extended workflows:**

- **[clo-author](https://github.com/hugosantanna/clo-author)** by Hugo Sant'Anna (UAB) — Paper-centric research workflows with 17 specialized agents (6 worker-critic pairs plus referees, data-engineer, verifier), simulated blind peer review, AEA replication compliance, and full research lifecycle management. **The `/review-paper --peer <journal>` pipeline in this template is adapted from clo-author with Hugo's permission** (pipeline shape, 6-way disposition taxonomy, journal-calibration schema, paper-type branching). Thanks, Hugo.
- **[claudeblattman](https://github.com/chrisblattman/claudeblattman)** by Chris Blattman (U Chicago) — Comprehensive guide for non-technical academics: executive assistant workflows, proposal writing, agent debates, and self-improving configuration
- **[MixtapeTools](https://github.com/scunning1975/MixtapeTools)** by Scott Cunningham (Baylor) — The Rhetoric of Decks: philosophy and practice of beautiful, rhetorically effective academic presentations
- **[autoresearch](https://github.com/karpathy/autoresearch)** by Andrej Karpathy — Constraint-based autonomous research with `program.md` as constitutional document
- **[ClaudeCodeTools](https://github.com/aspi6246/ClaudeCodeTools)** — "The Editor" persona: seven-audit sequential paper review protocol

See the [guide's ecosystem section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-ecosystem) for detailed descriptions, design principles, and more resources.

---

## Versioning & Contributing

- **What's new:** see [CHANGELOG.md](CHANGELOG.md). We follow loose semver — breaking changes get major bumps so you can decide when to pull updates.
- **How to contribute:** see [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md). PRs welcome for generalizable improvements; fork-specific work stays in your fork.
- **Pin to a version:** `git checkout v1.8.0` (current as of 2026-04-27).

---

## License

MIT License. See [LICENSE](LICENSE).
