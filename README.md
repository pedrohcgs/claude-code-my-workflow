# My Claude Code + Codex Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/See-CHANGELOG-blue.svg)](CHANGELOG.md)
[![Contributing](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](.github/CONTRIBUTING.md)

> **Actively maintained.** A dual-runtime research workflow for Claude Code and Codex—papers, data analysis, presentations, reproducibility, and more—packaged so you can fork it for your own work. See [CHANGELOG.md](CHANGELOG.md) for the latest changes.

**Live site:** [psantanna.com/claude-code-my-workflow](https://psantanna.com/claude-code-my-workflow/)

A ready-to-fork foundation for AI-assisted academic work. The original Claude Code setup remains intact, and a native Codex setup now supports research papers, data analysis, replication packages, and research presentations with the same plan-review-verify discipline.

---

## Codex Quick Start

The Codex port is native rather than a compatibility shim: `AGENTS.md` supplies repository guidance, `.agents/skills/` contains `$skill` workflows, and `.codex/` contains project configuration, custom agents, hooks, command rules, and deeper guidance. See OpenAI's documentation for [Codex customization](https://learn.chatgpt.com/docs/customization/overview), [AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md), and [Agent Skills](https://learn.chatgpt.com/docs/build-skills).

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-my-workflow.git my-project
cd my-project
./scripts/validate-setup.sh --platform codex
codex
```

Trust the project when Codex asks, review `AGENTS.md` and `.codex/config.toml`, then inspect registered hooks with `/hooks`. Invoke a workflow with `$skill-name`—for example, `$strategize`, `$draft-paper`, `$create-talk`, or `$data-analysis`. Use `/status` or `/statusline` for live context instead of a custom context-monitor hook. To validate both installations, run `./scripts/validate-setup.sh --platform all`; calling the script without `--platform` retains the original Claude-only behavior.

This Codex edition is deliberately research-focused for a PhD student. R,
Python, Markdown, LaTeX/Beamer, TikZ, manuscripts, reproducibility, and seminar
preparation are supported. Quarto RevealJS is an explicit option for creating
research talks only; lecture translation, Beamer-to-Quarto synchronization,
Quarto QA/deployment, course sites, Stata, syllabus and lecture creation, and
pedagogy/evaluation workflows remain excluded. Quarto, XeLaTeX, and R are
optional unless the workflow you invoke needs them.

The creation-side path is intentionally staged: `$strategize` records an
estimand-first analysis contract, `$draft-paper` writes from verified evidence,
and `$create-talk` derives a finished Beamer or Quarto research deck from the
approved manuscript and analysis outputs. Project-specific conventions live in
`.codex/references/project-profile.md`; the stages do not auto-chain.

The Codex model pins are intentional defaults recorded in `.codex/port-manifest.toml`. Review them on the manifest's stated review date, and override them in the relevant `.codex/agents/*.toml` file when your account or workload calls for a different supported model.

<!-- surface-sync-counts: codex -->
| Codex component | Count |
|-----------------|------:|
| Skills | 54 |
| Agents | 17 |
| Guidance | 36 |
| Hooks | 7 |

---

## Quick Start (5–10 minutes, plus ~30 min for first-time installs)

> **Before you start:** Claude Code + git are the minimum. To run the included `HelloWorld` demos end-to-end you also need XeLaTeX (Beamer sample) and Quarto (Quarto sample). R and the GitHub CLI are recommended. Python 3 runs the gate suite (`./scripts/backtest.sh` — 10 checkers) and the quality scorer, and is pre-installed on macOS/Linux. Full list in [Prerequisites](#prerequisites) below. Fastest path: clone first, then run `./scripts/validate-setup.sh` — it reports exactly what's missing with install links.
>
> **Only need Python/R/markdown?** You don't need XeLaTeX or Quarto. The agents, rules, skills, and orchestration patterns work for any text/code artifact. Skip the `HelloWorld` demos and head straight to `/data-analysis`, `/review-paper`, `/lit-review`, or `/review-r`.
>
> **Session 2 onwards:** [MEMORY.md](MEMORY.md) (committed) collects generic `[LEARN]` entries that help all forkers; machine-specific notes accumulate in Claude Code's native auto memory (`~/.claude/projects/<project>/memory/`, machine-local, never committed). See [`.claude/rules/meta-governance.md`](.claude/rules/meta-governance.md) for the distinction.

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

> **Avoid prompt fatigue.** New interactive sessions on Pro/Max/Team start in **auto mode** (classifier-gated — most actions run, risky ones prompt); on plans and providers without auto, Normal mode prompts per risky tool call. If you still see too many prompts, toggle **Auto-accept edits** mode (a keybinding; see the [permission modes section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#settings---permissions-and-hooks) of the guide) or run `claude --permission-mode acceptEdits`. For fully-autonomous runs on a trusted repo, **Bypass** mode skips prompts entirely. The template's `.claude/settings.json` ships `defaultMode: bypassPermissions` with broad catch-all allows (`Bash(*)`, `Edit(**)`, `Write(**)` — 7 wildcard rules, not a curated list), so out of the box almost nothing prompts. That is a deliberate power-user default: to tighten it, set `defaultMode: "default"` in `.claude/settings.json` and approve tools as you go, or remove the override to fall back to the platform's auto mode.

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

### Goal-first, gate-enforced (the v2.0 shift)

You don't craft a perfect prompt — you **state a goal and let the work loop toward it under gates**. Specialist agents do the labor; enforcing gates decide when it's good enough; you adjudicate the disagreements they surface. Three things make that trustworthy:

- **Real gates, not reminders.** One command — `./scripts/backtest.sh` — runs **ten gates**: surface-sync, skill integrity, model currency against the SSoT, link and anchor resolution, Agent Skills spec conformance, staleness (including source-vs-published divergence), repo hygiene, derived counts (enumerable claims re-counted from disk), ledger coverage (the qualification ledger and the checks that actually run must agree in both directions, and every hook declared in settings must exist and be invocable — a one-character path typo no longer disables a hook in silence), and a seeded hook battery (every active guard hook is re-fired against the failure it targets, alongside clean controls, on every run). A version-controlled pre-commit hook (run `./scripts/install-hooks.sh` once) runs it plus the quality check (≥80) on *every* commit — bypassing the skill no longer bypasses the review. A `git-guardrails` hook blocks destructive git (`reset --hard`, `clean -f`, `push --force`, `add -A`) and refuses a merge, rebase, or pull while the tree is dirty — reading the tree as it is rather than predicting what a chained command might do to it, so `git stash && git merge` is denied too and you run the two steps separately (`ALLOW_DIRTY_MERGE=1` if you mean it); like its sibling it is a textual check over the command line, so an op carried inside an interpreter, an alias, or a script is outside what it can see, and its docstring says which forms those are. Its sibling `root-of-trust-guard` denies the common shell write paths into the files that define the gates themselves (`.claude/settings*.json`, `.claude/hooks/`, `.githooks/`) — redirection, `tee`, `cp`/`mv`/`rm`, in-place `sed` — and, because it already unwraps `bash -c` and `env -S` payloads for those rules, it hands the unwrapped payload to the *same* destructive-git deny list, so `bash -c 'git reset --hard'` and `bash -c 'git clean -fdx'` no longer fall between the two hooks. **Read that one as a tripwire, not a lock, and read the name as a filename rather than a claim:** it is a best-effort textual scan that fails open on its own errors, and the files it watches stay replaceable through channels the template deliberately allows — an `Edit`/`Write`/`MultiEdit`, a branch switch, a clean merge, or a bug in the hook itself. What it buys is a change of *channel* — a change to a gate arrives as a reviewable diff instead of an invisible overwrite — not a guarantee that the gates cannot be disabled. Nothing here recovers anything either: the transcript and `git reflog` are an audit trail and a commit-history aid, and neither holds the bytes of an uncommitted edit or an untracked file. The review runtime re-checks any reviewer-introduced "fatal" finding before it counts.
- **Every gate is qualified, and the ledger is itself a gate.** Each one has been shown a planted defect and confirmed to go red, with recall and false-alarm rate recorded in [`quality_reports/qualification/LEDGER.md`](quality_reports/qualification/LEDGER.md) — and that ledger is now load-bearing rather than aspirational: a registered check with no row there fails the build, and a row naming a checker that no longer exists fails too. Checks that have *not* been qualified are listed there by name as visible debt — because an unqualified check is not weak evidence, it is none. Run [`/vaccinate`](.claude/skills/vaccinate/SKILL.md) to qualify one.
- **A real orchestration runtime.** Reviews fan out to forked specialist agents, reduce over a shared finding schema, judge with a hallucination gate, and loop until dry — see [`orchestrator-protocol.md`](.claude/rules/orchestrator-protocol.md).
- **Ground truth as a process.** A mismatch isn't always a failure: a defensible, *named* alternative is recorded as `EXPLAINED` and carried into your response-to-referees, while genuine errors stay fail-closed.

This is **not** an autonomous daemon — the loop is always you- or skill-initiated, and you stay the auditor. Scheduled automation handles recurring chores and notifies only on findings — cloud [Routines](.claude/references/scheduled-routines.md) for committed-repo checks (weekly lit-delta, inbox triage), Desktop scheduled tasks for anything touching local data (the nightly reproducibility check's home).

### Contractor Mode

You describe a task. For complex or ambiguous requests, Claude first creates a requirements specification with MUST/SHOULD/MAY priorities and clarity status (CLEAR/ASSUMED/BLOCKED). You approve the spec, then Claude plans the approach and invokes the right skill (e.g. `/create-lecture`, `/qa-quarto`, `/review-paper --adversarial`). That skill implements the orchestrator runtime internally — implement, verify, review, fix, re-verify, score — and returns a summary when the work meets quality standards. Say "just do it" and it runs the full loop; commits still require an explicit `/commit` (which the pre-commit hook then gates).

### Specialized Agents

Instead of one general-purpose reviewer, 18 focused agents each check one dimension. A representative sample:

- **proofreader** — grammar/typos
- **slide-auditor** — visual layout
- **pedagogy-reviewer** — teaching quality
- **r-reviewer** — R code quality
- **domain-reviewer** — field-specific correctness, slides (template — customize for your field)
- **domain-referee** / **methods-referee** / **editor** — manuscript peer-review pipeline (`/review-paper --peer`)

Each is better at its narrow task than a generalist would be. The `/slide-excellence` skill runs the slide-review agents in parallel; `/review-paper --peer` runs the paper-review pipeline. The same pattern extends to any academic artifact — manuscripts, data pipelines, proposals.

### Adversarial QA

Two agents work in opposition: the **critic** reads both Beamer and Quarto and produces harsh findings. The **fixer** implements exactly what the critic found. They **loop until dry** — converging when a round surfaces no new issue (a 5-round cap is the fallback, not the primary stop). This catches errors that single-pass review misses.

### Quality Review

Every artifact gets a score (0–100). Scores below threshold halt the workflow and surface the findings — the user decides whether to fix or explicitly override:

- **80** — commit threshold
- **90** — PR threshold
- **95** — excellence (aspirational)

> **Framing honesty:** Thresholds are advisory at the harness level — the `/commit` skill runs quality checks and halts on failure. **And** as of v2.0, running `./scripts/install-hooks.sh` once installs a real pre-commit hook (`.githooks/pre-commit`) that runs the full backtest gate suite plus the quality (≥80) gate on *every* commit, so bypassing the skill no longer bypasses the review. Opt out per-commit with `SKIP_QUALITY_GATE=1` or `git commit --no-verify`.

### Context Survival

Plans, specifications, and session logs survive auto-compression and session boundaries. The PreCompact hook saves a context snapshot before Claude's auto-compression triggers, ensuring critical decisions are never lost. MEMORY.md accumulates learning across sessions, so patterns discovered in one session inform future work.

For *forced* compression (long pipelines, mid-plan handoffs), `/compress-session` (v1.9.0) distils the conversation into a structured note — decisions, next actions, and **discarded-as-noise** — instead of letting auto-compaction truncate. `/promote-memory` (v1.9.0) periodically harvests generic learnings from native auto memory to committed MEMORY.md via a five-critic council.

### Verification Discipline (v1.7.0+)

Multiple complementary verification layers run before submission:

- **`/verify-claims`** (v1.7.0) — Chain-of-Verification with a forked verifier that cannot self-confirm because it has never seen the draft. v1.9.0 adds HIGH/MED/LOW-WARN severity tiers; HIGH-WARN findings (fabricated citation, numerical contradiction) are must-fix — resolve them before committing.
- **`/audit-reproducibility`** (v1.7.0; Stata coverage v1.9.0) — every numeric claim in the manuscript is cross-checked against the script output that produced it. v1.9.0 adds `passport.yaml` — a per-paper YAML state file with PASS/FAIL/STALE/UNVERIFIED status per claim.
- **`/humanize`** (v1.9.0) — detect AI-voice tells (boilerplate transitions, hedging stacking, sycophancy) before submission. Read-only by design; auto-rewriting degrades quality.
- **`/review-paper --variance N`** (v1.9.0) — runs N referees with sampled dispositions and reports a **decision distribution**, not a point estimate. Motivated by AgentReview (EMNLP 2024) finding 37% of decisions vary purely from disposition sampling.

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

- **Model lineup** — **Fable 5** (`claude-fable-5`, opt-in via `/model fable` or the `best` alias) is the top tier for long-horizon work. Current Opus/Sonnet point versions and the **provider-dependent alias table** live in the single source of truth, [`model-versions.md`](.claude/references/model-versions.md) — surfaces here stay tier-abstract so they cannot go stale, and the staleness gate fails the build when the SSoT's own expiry passes.
- **Effort levels** — `/effort` sets cost vs. thoroughness (`low` / `medium` / `high` / `xhigh` / `max`). **Fable 5 defaults to `high`** (per the [model SSoT](.claude/references/model-versions.md)); set effort explicitly on other tiers — reserve `xhigh` for extended exploration and `ultracode` (xhigh + dynamic workflows) for the largest autonomous runs.
- **`/goal <verifiable condition>`** (v1.9.0; Anthropic May 2026) — keep working across turns until a fast model confirms the condition holds. Pairs with `/commit` quality gates for verified-end-state runs.
- **`claude agents` dashboard** (v1.9.0; Anthropic May 2026) — single screen for parallel review work (`/review-paper --peer`, `/slide-excellence`).
- **Cost-Conscious Composition** — prompt-cache TTL (5-min default on API keys; **1-hour automatic on Claude subscriptions**), 70/20/10 model routing (Haiku/Sonnet/Opus), `/cost` + `/usage` monitoring, Agent SDK credit-pool split (2026-06-15).
- **Skill frontmatter** — `effort`, `context: fork`, `agent`, `hooks`, `disable-model-invocation` (v1.8.0+), `disallowed-tools` (the *actual* tool restriction — `allowed-tools` only pre-approves), `paths` (glob-scoped auto-activation), and dynamic content (`$ARGUMENTS`, `!command` syntax)
- **Permission modes** — Normal, Auto-accept, Plan, **Auto** (classifier-gated; since 2026-08-14 the *default* starting mode for new interactive sessions on Pro, Max, and Team, and available on Bedrock / Google Cloud / Foundry without an opt-in flag), Bypass
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
| Monte Carlo simulations | Reproducible simulation studies (`/simulation-study`, v1.10.0) — parameterized DGP, estimator grid, bias/RMSE/coverage/size/power with Monte Carlo SEs, dedicated `sim-reviewer` review pass |
| Package development | R package release gate (`/r-package-check`, v1.10.0) — `devtools::document()` + tests + `R CMD check --as-cran` + CRAN-policy triage + `r-package-reviewer` (Stata / Python checks on the roadmap) |
| Replication packages | AEA-compliant packaging, reproducibility audit trails, `passport.yaml` claims provenance (v1.9.0) |
| Presentations | Rhetoric of decks principles, visual audit, cognitive load review |
| Research proposals | Structured drafting with adversarial critique |
| Preregistration | OSF / AsPredicted / AEA RCT Registry-ready document (`/preregister --style`) — full workflow in Pattern 16 |
| Manuscript submission discipline | `/humanize` (detect AI voice), `/verify-claims` HIGH-WARN gate (block fabricated citations), reviewer-disposition variance |

**Disciplines preloaded:** Economics (top-5 journal profiles, R conventions) and Political Science (APSR / AJPS / JOP profiles, formal-theory + survey-experiment paper types, conjoint/`cjoint` conventions). Forkers extend for psych / sociology / public-health via journal profiles + paper types + discipline cards.

### One repo, many project types

This workflow is designed as a **single hub for an entire research program** — not one paper at a time. The same `CLAUDE.md`, rules, agents, and quality gates serve courses and lectures, papers and referee reports, data analysis and replication packages, **Monte Carlo simulation studies** (`/simulation-study` + `sim-reviewer`), and the **R package release gate** (`/r-package-check` + `r-package-reviewer`) — all new in v1.10.0. *On the roadmap:* Stata / Python package checks (SSC / PyPI) and personal-productivity workflows. See [`.claude/references/v2.0-backlog.md`](.claude/references/v2.0-backlog.md) for what's next.

---

## What's Included

<details>
<summary><strong>18 agents, 60 skills, 37 rules, 8 hooks</strong> (click to expand)</summary>

### Agents (`.claude/agents/`)

<!-- surface-sync-table: agents -->
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
| `sim-reviewer` (v1.10.0) | Monte Carlo simulation reviewer — DGP/estimand match, Monte Carlo SE, coverage-vs-truth, claims↔tables parity |
| `r-package-reviewer` (v1.10.0) | R package-source reviewer — DESCRIPTION/NAMESPACE hygiene, roxygen completeness, testthat coverage, CRAN-policy red flags |

### Skills (`.claude/skills/`)

<!-- surface-sync-table: skills -->
| Skill | What It Does |
|-------|-------------|
| `/compile-latex` | Three-pass XeLaTeX compilation, with BibTeX when cited |
| `/deploy` | Render Quarto + sync to GitHub Pages |
| `/extract-tikz` | TikZ diagrams to PDF to SVG pipeline |
| `/proofread` | Launch proofreader on a file |
| `/visual-audit` | Launch slide-auditor on a file |
| `/pedagogy-review` | Launch pedagogy-reviewer on a file |
| `/review-r` | Launch R code reviewer |
| `/qa-quarto` | Adversarial critic-fixer loop (loops until dry; 5-round cap is a fallback) |
| `/slide-excellence` | Combined multi-agent review |
| `/translate-to-quarto` | Full Beamer-to-Quarto translation — Phase 0 pre-flight plus 11 translation phases |
| `/vaccinate` | Measure whether a check, gate, or AI reviewer actually detects the failure it targets — seeds defects + a clean control, reports recall and false-positive rate into a qualification ledger |
| `/adjudicate-review` | Turn incoming findings — AI review, referee report, linter, second model — into verified fixes. Every finding is a CANDIDATE until checked against the source |
| `/blast-radius` | Before and after changing anything shared (return value, schema, default, units), enumerate every consumer and actually run them |
| `/credible-claims` | Research brief before delegating, claim record after. Keeps faster execution from being mistaken for credible evidence |
| `/differential-audit` | Compare two implementations — a port, a replication, a refactor, a version upgrade — so that agreement means something |
| `/oracle-review` | Run an external frontier-model referee (Claude Code → GPT-5.6 Sol Pro) and adjudicate what comes back |
| `/verify-artifact` | Prove the file you are about to send IS the thing you mean — rebuild, verify integrity, diff against source |
| `/voice-profile` | Extract a written voice profile from your own prior papers, then audit drafts against it — the positive counterpart to `/humanize`, which only detects AI tells |
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
| `/compress-session` (v1.9.0) | Distil current session into structured notes (decisions, next actions, *discarded-as-noise*) before auto-compaction |
| `/promote-memory` (v1.9.0) | Five-critic council that votes on which `[LEARN]` entries graduate from native auto memory to MEMORY.md |
| `/stata-replication` (v1.9.0) | End-to-end Stata pipeline via the `stata-mcp` MCP server (mirrors `/data-analysis` for R-first projects) |
| `/simulation-study` (v1.10.0) | Scaffold + run a reproducible Monte Carlo study — parameterized DGP, estimator grid, seeded replications, bias/RMSE/coverage/size/power with Monte Carlo SEs |
| `/r-package-check` (v1.10.0) | R package release gate — `devtools::document()` + tests + `R CMD check --as-cran`, triage ERROR/WARNING/NOTE vs CRAN policy, `r-package-reviewer` pass |
| `/replication-package` (v2.0) | Assemble a submission-ready DCAS / openICPSR replication package — standard README, dataset manifest, computational-requirements capture, Table/Figure → script:line map, confidential-data deposit note (blocks on `/audit-reproducibility` FAIL) |
| `/challenge` | Stress-test a finding against the choices you didn't make — specification curve over the discrete forks, then named sensitivity statistics (E-value, Cinelli–Hazlett RV, Oster δ) against the identifying assumption |
| `/capture-environment` (v2.0) | Snapshot the computational environment for a replication package — renv.lock + sessionInfo.txt (R), requirements.txt / environment.yml / uv.lock (Python), Stata version + ado list, seeds/RNG, optional pinning Dockerfile |
| `/power-analysis` (v2.0) | Power / required-N / minimum-detectable-effect for study design — two-arm RCT (clustering/ICC, unequal allocation), multi-arm corrections, simulation-based power for non-standard designs; feeds `/preregister` |
| `/disclosure-check` (v2.0) | Statistical-disclosure-limitation pre-screen for restricted/confidential-data outputs (small cells, complementary-suppression gaps, dominance, PII); CRITICAL/WARNING/OK + gate |
| `/grant-proposal` (v2.0) | Scaffold an NSF/NIH/ERC/foundation grant proposal by composing primitives (spec → aims/methods, delegated DMP + facilities, coherence pass + requirements checklist) |
| `/data-management-plan` (v2.0) | Funder-compliant Data Management Plan (NSF / NIH DMS 2023 / ERC / Horizon Europe) — folds in disclosure-avoidance + IRB constraints and a replication-package/environment plan; outputs a draft + funder checklist |
| `/coauthor-brief` (v2.0) | Collaborator handoff brief — what changed since last brief, per-artifact state, open questions, reproduce-locally + restricted-data access steps |
| `/triage-inbox` (v2.0) | Schedulable academic inbox + calendar triage via Gmail/Calendar MCP — classifies referee requests, R&R/editor, co-author threads, seminar/conference invites, grant/admin deadlines; proposes one human-gated action each (draft reply, calendar hold, scaffold a referee project, `/coauthor-brief`, snooze); emits a digest + referee-obligations tracker; degrades gracefully when MCP is absent; never auto-sends |
| `/diagnose` (v2.0) | Root-cause a wrong/failing empirical result — disciplined reproduce → minimise → hypothesise → instrument → fix loop; tuned for research-code bugs (type coercion, NA/merge blow-ups, clustering/SE choice, seed/package-version drift); `--no-fix` localizes without editing |
| `/submission-disclosures` (v2.1) | The submission-time disclosure block: AI-use disclosure matched to the target journal's verified-current policy, CRediT contributor roles, conflict-of-interest, and data-availability statements (NOT statistical disclosure — that's `/disclosure-check`) |
| `/syllabus` (v2.0) | Build/restructure a course syllabus from a topic or reading list — course description + prerequisites, week-by-week schedule (topic→readings→deliverables), measurable learning objectives, assessment scheme + rubric, standard policies (late work / AI use / integrity / accessibility), and a per-week work-list mapping weeks to `/create-lecture` decks; economics-aware (PhD metrics/micro/macro sequences, undergrad) |
| `/teach-from-paper` (v2.0) | Reads a paper end-to-end and pitches it to a stated audience level — lecture outline (motivation → setup → key result → method → takeaways), the 3-5 results worth presenting with intuition, a slide skeleton for `/create-lecture`, discussion questions, and a problem-set brief for `/scaffold-exercises` |
| `/respond-to-eval` (v2.0) | Teaching analogue of `/respond-to-referees` — clusters course-eval comments into themes, weights by frequency (signal vs noise), classifies Keep / Change / Investigate / Out-of-scope, and drafts concrete changes mapped to the syllabus + slide decks; saves the plan to `quality_reports/teaching/` |
| `/scaffold-exercises` (v2.0) | Scaffold a graded problem set across analytical/empirical/coding types, with worked solutions and "why this matters" explainers emitted to a separate solution key |
| `/new-skill` (v2.0) | Scaffold a new skill that follows this repo's conventions — interviews for purpose, triggers, and tools, writes `.claude/skills/<name>/SKILL.md` from the template with frontmatter/body that pass `check-skill-integrity.py` first try, then reminds to add the surface-table rows |

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

Rules use path-scoped loading: **always-on** rules load every session; **path-scoped** rules load only when Claude works on matching files. Adherence degrades as instruction files grow (official guidance: keep `CLAUDE.md` under ~200 lines), so less is more.

**Always-on** (no `paths:` frontmatter — load every session):

| Rule | What It Enforces |
|------|-----------------|
| `plan-first-workflow` | Plan mode for non-trivial tasks + context preservation |
| `orchestrator-protocol` | Goal-first review runtime: fan-out → reduce → judge (+ hallucination gate) → loop-until-dry (the contractor loop, now a real runtime) |
| `session-logging` | Three logging triggers: post-plan, incremental, end-of-session |
| `meta-governance` | Template vs. working project distinctions |
| `progress-reports` | GitHub as memory — issues as defect memory, `quality_reports/` as work memory, `MEMORY.md` as lesson memory |
| `repo-hygiene` | Scratch must not become main — enforced by `check-repo-hygiene.py` on every commit |
| `prompt-shaping` (v2.0) | Ambient habit — shape informal/ambiguous requests before acting (replaces the retired `/prompt` + `/prompt-only` skills) |

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
| `agent-authored-code` (v2.5) | `**/*.sh`, `**/*.py`, `**/*.R`, `**/*.do` | The bugs are usually ours: dry-run before any bulk edit, resolve paths before `cd`, monitor by PID file not `pgrep`, cover every terminal state |
| `writing-with-ai` (v2.5) | `**/*.tex`, `**/*.qmd`, `**/*.md`, `**/*.Rmd` | Internal vs external-facing documents; why a model cannot make its own output stop reading as model output; the human-readable standard |
| `issue-ledger` (v2.5) | `.github/**` | Evidence standard for an issue: denominator, positive/negative control, explicit non-scope, and a seven-section closure comment |
| `tikz-measurement` (v1.5.x) | `Slides/**`, `Figures/**`, `Preambles/**`, `scripts/**` | Bézier curve depth math + 6-pass collision protocol (from MixtapeTools) |
| `content-invariants` (v1.6.x) | `.tex`, `.qmd`, `Preambles/`, `scripts/R/**` | Pre-Flight Reports — proves inputs were read before work |
| `cross-artifact-review` (v1.7.0) | `master_supporting_docs/`, `.tex`, `.qmd` | Paper ↔ code dependency graph; auto-invokes `/review-r` + `/audit-reproducibility` |
| `post-flight-verification` (v1.7.0) | Skills generating factual claims | Chain-of-Verification protocol with forked verifier |
| `summary-parity` (v1.8.x) | `CHANGELOG.md`, `README.md`, `.qmd`, skill/rule/agent `.md` | Anti-whack-a-mole: re-verify summaries against their bodies |
| `model-routing` (v1.9.0) | `.claude/agents/**/*.md`, `.claude/skills/**/SKILL.md` | 70/20/10 architect/editor split (Haiku/Sonnet/Opus) |
| `review-fencing` (v2.5.1) | `.claude/agents/**/*.md`, `.claude/skills/**/SKILL.md` | Reviewer independence is a property of the environment — neutral copy outside the checkout, prior verdicts excluded, own reading first, positive controls fenced from committed answer keys |
| `stata-code-conventions` (v1.9.0) | `**/*.do`, `scripts/stata/**` | Stata header scaffold, numbered pipeline, esttab, clustering discipline, AEA compliance |
| `simulation-conventions` (v1.10.0) | `**/*simulation*.R`, `**/*_sim.R`, `explorations/**` | Monte Carlo discipline: DGP/estimand, L'Ecuyer seeding, Monte Carlo SE, coverage-vs-truth, raw-result storage |
| `r-package-conventions` (v1.10.0) | `R/**`, `tests/**`, `DESCRIPTION`, `NAMESPACE`, `man/**` | R package-source standards: no `library()` in `R/`, roxygen NAMESPACE, Imports/Suggests, testthat 3e, CRAN policy |
| `confidential-data` (v2.0) | `data/**`, `**/*.dta`, `**/restricted/**`, `**/confidential/**` | Restricted/IRB-data protocol: never commit raw data, disclosure clearance before release, restricted-data-safe multi-author git topology |
| `inference-robustness` (v2.0) | `scripts/**/*.R`, `**/*.do`, `**/*.py` | Multiple-testing (FWER/Romano-Wolf vs FDR/Anderson sharpened-q, pre-register the family) + specification-curve / leave-one-out / wild-cluster-bootstrap robustness |

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
| `executor-contract.md` (v2.5.1) | Dispatchable goal contract for a delegated task — goal, acceptance bar, exact paths, gates it must pass, output contract, and the mechanisms the executor may refuse |
| `screening-rubric.md` (v2.5.1) | Screening rubric — written before the screen runs, with per-candidate evidence, an adjudication table, and a dispatcher spot-check |

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
| R | Figures and analysis (`/data-analysis`, `scripts/R/` template) | [r-project.org](https://www.r-project.org/) |
| pdf2svg | TikZ → SVG for Quarto (`/extract-tikz`) | `brew install pdf2svg` (macOS), `apt install pdf2svg` (Debian) |
| [gh CLI](https://cli.github.com/) | PR / issue workflow | `brew install gh` (macOS), `apt install gh` (Debian) |

**Minimum to fork this template:** Claude Code + git + Python 3 (Python is already installed on macOS/Linux).

**Minimum to run the included HelloWorld demos end-to-end:** add XeLaTeX (for `/compile-latex HelloWorld`) and Quarto (for `/deploy HelloWorld`).

**Your real lectures may need more** — R for `scripts/R/` analyses, pdf2svg if you use TikZ extraction, gh CLI if you use the PR-based commit workflow. `./scripts/validate-setup.sh` reports which of these are installed and what each unlocks.

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

Research groups across economics, energy, political science, and engineering have forked and adapted this workflow — **15+ research groups at the March 2026 survey**; the repository has since passed **2,900 forks** and 1,500 stars (GitHub, 2026-08-24 — a fork is not a research group, so read the survey figure and the fork count as different things). The infrastructure (orchestrator, hooks, quality gates) transfers without modification.

**Extended workflows:**

- **[clo-author](https://github.com/hugosantanna/clo-author)** by Hugo Sant'Anna (UAB) — Paper-centric research workflows with 21 specialized agents (7 worker-critic pairs plus referees, data-engineer, verifier), simulated blind peer review, AEA replication compliance, and full research lifecycle management. **The `/review-paper --peer <journal>` pipeline in this template is adapted from clo-author with Hugo's permission** (pipeline shape, 6-way disposition taxonomy, journal-calibration schema, paper-type branching). Thanks, Hugo.
- **[claudeblattman](https://github.com/chrisblattman/claudeblattman)** by Chris Blattman (U Chicago) — Comprehensive guide for non-technical academics: executive assistant workflows, proposal writing, agent debates, and self-improving configuration
- **[MixtapeTools](https://github.com/scunning1975/MixtapeTools)** by Scott Cunningham (Baylor) — The Rhetoric of Decks: philosophy and practice of beautiful, rhetorically effective academic presentations
- **[autoresearch](https://github.com/karpathy/autoresearch)** by Andrej Karpathy — Constraint-based autonomous research with `program.md` as constitutional document
- **[ClaudeCodeTools](https://github.com/aspi6246/ClaudeCodeTools)** — "The Editor" persona: seven-audit sequential paper review protocol

See the [guide's ecosystem section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-ecosystem) for detailed descriptions, design principles, and more resources.

---

## Versioning & Contributing

- **What's new:** see [CHANGELOG.md](CHANGELOG.md). We follow loose semver — breaking changes get major bumps so you can decide when to pull updates.
- **How to contribute:** see [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md). PRs welcome for generalizable improvements; fork-specific work stays in your fork.
- **Pin to a version:** `git checkout $(git describe --tags --abbrev=0)` pins the newest tag (v2.5.1 at this writing — see [CHANGELOG.md](CHANGELOG.md)).

---

## License

MIT License. See [LICENSE](LICENSE).
