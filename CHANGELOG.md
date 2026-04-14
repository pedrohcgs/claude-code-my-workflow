# Changelog

All notable changes to this template are documented here. We follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and use loose semantic versioning: **major** when fork upgrades require manual migration, **minor** for new skills or features that are additive, **patch** for fixes and docs.

If you have forked this template, see the **Upgrading** section at the bottom for how to pull updates without losing your customizations.

---

## v1.5.0 — 2026-04-14

### Added — Simulated peer review

A new `--peer [journal]` mode for `/review-paper` that runs a full editorial pipeline: **editor desk review → referee selection (2 different dispositions from a 6-way taxonomy) → 2 blind referees in parallel → editorial synthesis (FATAL / ADDRESSABLE / TASTE)**. Calibrated per journal.

- **`.claude/agents/editor.md`** — journal editor persona. Desk-reviews (with optional WebSearch novelty probe, ON by default — opt out with `--no-novelty-check`), selects two referees with *deliberately different* dispositions from the 6-way taxonomy (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC), assigns each referee 1 critical + 1 constructive pet peeve, then synthesizes their reports into an editorial decision with classification and "MUST / SHOULD / MAY push back" response-planning block.
- **`.claude/agents/domain-referee.md`** — substance referee. 5 weighted dimensions (contribution 30 / lit positioning 25 / substance 20 / external validity 15 / journal fit 10). Disposition-primed. Requires "What would change my mind: [specific ask]" on every MAJOR concern — a discipline that separates adversarial review from productive review.
- **`.claude/agents/methods-referee.md`** — methodology referee with **paper-type branching**: reduced-form / structural / theory+empirics / descriptive. Each type has its own dimension weights and mandatory pre-scoring sanity checks (sign / magnitude / parameter plausibility / construct validity / etc.). Same "What would change my mind" requirement.
- **`.claude/references/journal-profiles.md`** — NEW directory. Ships with **5 econ journals** (AER / QJE / JPE / ECMA / ReStud), each with Focus / Bar / Domain-referee adjustments / Methods-referee adjustments / Typical concerns / Referee-pool weights / optional Table-format override. Plus a "Field adaptation" section with detailed instructions for non-econ users.
- **`templates/journal-profile-template.md`** — skeleton for adding your own journal/field. Includes a disposition reference and field-specific paper-type guidance (e.g., biology: observational/experimental/computational/review; political science: case-study/comparative/formal-model/survey).

### Changed

- **`/review-paper`** — now supports three modes: default (single-pass), `--adversarial` (critic-fixer loop from v1.4.0), and the new `--peer <journal>` pipeline. Sub-flags: `--peer --r2` / `--peer --r3` (R&R continuation — reloads prior reports, classifies concerns Resolved / Partial / Not addressed, max 3 rounds), `--peer --stress` (hostile editor — forces SKEPTIC dispositions, doubles critical peeves), `--no-novelty-check` (skip WebSearch probes). Output directory: `quality_reports/peer_review_[paper]/` with `desk_review.md`, `referee_domain.md`, `referee_methods.md`, `editorial_decision.md`.
- **`.claude/rules/cross-artifact-review.md`** — adds `--peer` ordering clause: in `--peer` mode, cross-artifact review runs **before** the editor's desk review so reproducibility FAIL can be cited as desk-reject grounds. In default and `--adversarial` modes, cross-artifact still runs at Step 6b (after the paper review).
- **Counts:** **10 → 13 agents** (editor, domain-referee, methods-referee). Skills (26) and rules (21) unchanged. Synced across README, docs/index.html, guide, templates, CLAUDE.md.

### Attribution

The simulated-peer-review pipeline is **adapted from [Hugo Sant'Anna's clo-author](https://github.com/hugosantanna/clo-author) with his explicit permission**. Hugo's work contributed:
- The pipeline shape (editor desk → 2 referees → editorial synthesis).
- The 6-way disposition taxonomy (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC).
- The journal-calibration schema (Focus / Bar / Typical concerns / Referee-pool weights / Table-format overrides).
- The paper-type branching in the methods referee (reduced-form / structural / theory+empirics / descriptive) with per-type dimension weights and sanity checks.
- The "What would change my mind" requirement on every major concern.
- The R&R continuation pattern (reload prior round, classify Resolved / Partial / Not addressed).

We reimplemented all files rather than copying verbatim (clo-author has no LICENSE file at time of adaptation; our version is original text under MIT). All new files carry an attribution header pointing back to clo-author.

Thanks to Hugo for both the inspiration and the permission. The fork is doing great work on the authoring side of the pipeline — complementary to our template's authoring + review orientation.

### Governance note

With v1.5.0, the template's review story is now the strongest single feature: single-pass review (fast feedback), adversarial loop (iterative revision), seven-pass parallel review (broad coverage), simulated peer review (journal-calibrated editorial pipeline), R&R continuation (R&R rehearsal), stress mode (hostile editor). Four complementary review modes, one skill.

---

## v1.4.0 — 2026-04-14

### Added — review-skills hardening

- **`.claude/skills/audit-reproducibility/`** — enforces `replication-protocol.md` by cross-checking numeric claims in a manuscript (`ATT = -1.632 (0.584)`, `N = 2,847`, p-values, percentages) against the actual R / Stata / Python outputs. Tolerance-graded PASS/FAIL per claim. Usable as a `/commit` gate (exit 1 on FAIL). Addresses the "I updated the analysis but forgot to update Table 2" bug.
- **`.claude/skills/seven-pass-review/`** — mechanizes Pattern 15. Seven forked subagents, one per lens (abstract, intro, methods, results, robustness, prose, citations), run in parallel, then a synthesizer produces a prioritized revision checklist with cross-lens contradictions surfaced.
- **`.claude/rules/cross-artifact-review.md`** — paper ↔ code dependency-graph protocol. When `/review-paper` runs, auto-invokes `/review-r` on referenced scripts and `/audit-reproducibility` on the pair. Surfaces critical cross-artifact findings (code bug invalidates paper claim) at the top of the review report. Opt-out: `--no-cross-artifact`.

### Changed

- **`/review-paper`** — new `--adversarial` mode runs the critic-fixer loop from `/qa-quarto` (up to 5 rounds). Single-pass default unchanged. Now also auto-invokes cross-artifact review (Step 6b).
- **`/slide-excellence`** — conditional dispatch: only spawns subagents that can produce useful output (`tikz-reviewer` only on TikZ-bearing files, content-parity only when both `.tex` and `.qmd` counterparts exist, R reviewer only when R chunks are present). Pre-flight check refuses to run `domain-reviewer` if the agent is still the shipped template. New flags: `--skip-substance`, `--acknowledge-template-domain-reviewer`, `--fast`. Cuts token cost ~50% on typical `.qmd`-only files.
- **`/validate-bib`** — new `--semantic` mode: citation-drift detection (duplicate `.bib` entries for the same paper), crossref DOI verification with caching and rate limiting, within-file citation-style consistency, optional `--cite-claim` abstract surfacing. Structural mode unchanged. `--skip-doi` for offline.
- **`.claude/agents/domain-reviewer.md`** — adds `AUTO-DETECT-TEMPLATE-MARKER` so `/slide-excellence` can detect un-customized templates and warn before running generic substance review.
- **Counts:** 24 → 26 skills, 20 → 21 rules. Synced across README, `docs/index.html`, guide, templates, and `docs/workflow-guide.html`.

### Fixed — Codex round-2 regressions

- **Trust-boundary porousness (PR U1):** The `permissions.deny` on `.claude/settings.json` and `.claude/hooks/**` was bypassable via allowlisted shell tools (`Bash(python3 *)`, `Bash(cp *)`, etc.). Narrowed the broad shell allows and added a `PreToolUse` guard. *(Later removed in the bypass-mode directive — see "Removed" below.)*
- **TikZ prevention bypasses (PR U2):** `check_p3` missed `scale={0.8}` and `scale=\myscale`; `check_p4` incorrectly flagged `align=left` (treated `left` as a direction). Rewrote with a brace/bracket-balanced tokenizer that matches standalone option keys. Parse errors now exit 2 (visible) instead of silent 0.
- **R stale-state leak (PR U3):** `scripts/R/03_analyze.R` used `exists("df")` without `inherits = FALSE`, allowing a stale globalenv to satisfy the guard. Added `inherits = FALSE` to match the contract already applied to `02_clean.R` and `05_figures.R`.
- **R template silent-skip (PR U4):** `05_figures.R` silently switched to base-R PDF if `ggplot2` was missing and silently skipped SVG if `svglite` was missing. Made `ggplot2` a hard dependency (fail loudly); kept `svglite` optional but emits an explicit "SKIPPED" warning. Rewrote `scripts/R/README.md` to document hard vs. optional deps.

### Removed

- **`.claude/hooks/protect-sensitive-paths.sh`** — added in PR U1, removed the same release under explicit user directive: "bypass mode means bypass." Bypass permissions (`defaultMode: bypassPermissions`) is the user's chosen high-autonomy workflow; re-adding approval gates during autonomous runs is a regression. Persisted to memory as `feedback_bypass_permissions.md` so this decision isn't re-litigated.

### Governance note

When adversarial reviewers (Codex, Copilot) flag the absence of approval gates as a risk under bypass mode, the template now treats that as a documented tradeoff, not a bug. Hardening under bypass mode is limited to non-blocking signals (PostToolUse reminders, notifications, logging). See `feedback_bypass_permissions.md` in the project's memory directory.

---

## v1.3.0 — 2026-04-13

### Added — TikZ story overhaul

Ported the best parts of Scott Cunningham's [MixtapeTools](https://github.com/scunning1975/MixtapeTools) TikZ infrastructure and wired them into our pipeline end-to-end.

- **`.claude/rules/tikz-prevention.md`** — 6 authoring rules (P1–P6) that stop collisions at write-time: explicit node dimensions, coordinate-map comments, prohibition on `scale=`, directional keyword on every edge label, use the snippet gallery, one tikzpicture per idea.
- **`.claude/rules/tikz-measurement.md`** — six-pass protocol with concrete formulas: Bézier `max_depth = (chord/2)·tan(bend/2)`, character-width table by font size, label-gap calculation, 0.4 cm shape-boundary rule, matplotlib `arc3` Bézier helpers, full margin matrix.
- **`templates/tikz-snippets/`** — 8 production-ready standalone `.tex` diagrams (DAG basic, DAG mediation, two-period DiD, event study, timeline, regression scatter, 3-step flowchart, supply-demand). Every snippet compiles on the first try and passes the prevention grep checks.
- **`Preambles/header.tex`** — production-ready Beamer preamble (previously empty): 11-color palette matching the SCSS, shared TikZ styles (`dag-node`, `decision-node`, `observed-edge`, `counterfactual-edge`, `confound-edge`, `observed-dot`, `counterfactual-dot`), Beamer theme assignments, convenience macros (`\muted`, `\key`, `\good`, `\bad`, `\transitionslide`).
- **`Preambles/README.md`** — usage + palette contract + inventory.
- **`scripts/check-palette-sync.sh`** — greps `Preambles/header.tex` and `Quarto/theme-template.scss`, enforces that the five core palette names exist on both sides. Wired into `validate-setup.sh`.
- **`.claude/skills/new-diagram/`** — scaffold a new TikZ diagram from the gallery with prevention checks pre-applied; compiles standalone, invokes `tikz-reviewer` with measurement citations, loops until APPROVED (max 5 rounds).

### Changed

- **`/extract-tikz`** — mandatory Step 1 prevention pre-check (greps for bare edge labels and `scale=`) before the expensive compile + SVG cycle.
- **`tikz-reviewer`** agent now requires citing the specific pass and formula from `tikz-measurement.md` for every CRITICAL/MAJOR finding. Vague reports are rejected.
- **`settings.json`** allowlist expanded substantially (+23 Bash tools, +36 Edit/Write path rules): read-only tools (grep/cat/head/tail/awk/find/tree/basename/dirname/file), file ops (cp/mv/touch/mktemp), pipeline tools (pandoc/docx2txt/pdftotext), missing git/gh subcommands (tag/rm/mv/remote, issue/release), and Edit/Write pre-approvals for every directory we normally edit (.claude/**, templates/**, guide/**, docs/**, scripts/**, Preambles/**, Slides/**, Quarto/**, Figures/**, quality_reports/**, explorations/**, master_supporting_docs/**, .github/**, plus CLAUDE.md, README.md, CHANGELOG.md, MEMORY.md, .gitignore).
- **Counts:** 23 → 24 skills, 18 → 20 rules, 7 → 6 hooks. Synced across README, `docs/index.html`, guide body, guide appendix, and CLAUDE.md.
- **Guide** Step 3 "Adapt Your Theme" rewritten to document the two-surface palette contract and the sync script.

### Removed

- **`.claude/hooks/protect-files.sh`** and its `PreToolUse` registration. The hook used to block `Edit`/`Write` on `Bibliography_base.bib` and `settings.json` unless bypass was signalled. With the explicit `Edit(...)` / `Write(...)` allow-rules added to `settings.json` (above), Claude Code's permission system handles this cleanly and the extra hook was redundant friction. Removing it also cuts a failure mode (earlier sessions had to work around the hook with `python3 -c` writes).

### Attribution

TikZ prevention + measurement rules adapted from `tikz_rules.md` in [scunning1975/MixtapeTools](https://github.com/scunning1975/MixtapeTools). The source repo has no LICENSE file; its README says "Use freely. Attribution appreciated but not required." Both ported rule files cite Scott at the top.

### Copilot review follow-up (same day)

This release shipped as a sequence of small PRs (#53–#56) plus an end-of-day Copilot-review cleanup PR that fixed 15 issues Copilot caught across those four PRs, removed `protect-files.sh` per user preference, and unified cross-skill grep patterns. Summary of the biggest catches:

- LaTeX load order in `Preambles/header.tex` (xcolor before hyperref; `\makeatletter` around `\@ifclassloaded`; `inputenc` gated by `\ifPDFTeX`).
- `protect-files.sh` env-var bypass moved above `$(cat)` so it exits immediately.
- `/extract-tikz` and `/new-diagram` grep patterns unified character-for-character.
- P1 scoped to boxed nodes; P3 reconciled with the `scale=1.1` convention.
- `check-palette-sync.sh` uses absolute paths (`$(dirname "$0")/..`) and a stable exit-code contract.
- Removed `Bash(npm *)` from the allowlist (too broad — npm run executes arbitrary scripts).

---

## v1.2.0 — 2026-04-13

### Added

- **`/respond-to-referees` skill** — parses a referee report, classifies each concern (addressed / partially / deferred / disagreement), points to specific revisions, and drafts a complete response document using `templates/response-to-referees.md`. Use during the R&R stage of paper revision.
- **HelloWorld sample** — `Slides/HelloWorld.tex` and `Quarto/HelloWorld.qmd` — minimal decks that compile/render on a fresh fork before any project customization.
- **`scripts/validate-setup.sh`** — colored dependency checker for Claude Code, XeLaTeX, Quarto, R, Python, git, gh, and hook permissions.
- **GitHub templates** — `.github/CONTRIBUTING.md`, issue templates, and PR template.
- **CHANGELOG.md** — this file.

### Changed

- **`/commit` skill** — now runs `scripts/quality_score.py` and the `verifier` agent on changed files as a pre-commit gate. Halts on score < 80 unless the user explicitly overrides.
- **`/extract-tikz` skill** — now invokes the `tikz-reviewer` agent after SVG generation and loops on revisions to the Beamer source until APPROVED.
- **`/slide-excellence` skill** — `domain-reviewer` agent is now MANDATORY for `.tex` files (was optional).
- **`CLAUDE.md`** — example rows in the Beamer environments and Quarto CSS classes tables are now visible (not hidden in HTML comments). Added links to `MEMORY.md` and `quality_reports/` so Claude knows where cross-session context lives.
- **`README.md`** — added "Verify Your Setup" step in the Quick Start; replaced "Work in progress" disclaimer; added badges and CHANGELOG link.
- **`docs/index.html`** — added SEO metadata (description, keywords, Open Graph, JSON-LD `SoftwareApplication` schema).
- **Skill count: 22 → 23** across all surfaces.

### Fixed

- `scripts/quality_score.py` — Quarto compilation check no longer doubles the path when `cwd` is set to the file's parent (was producing spurious 0/100 scores).
- `scripts/validate-setup.sh` — git config check now guards behind `command -v git` to avoid misleading warnings when git is missing.
- `Slides/HelloWorld.tex` — added a citation and bibliography slide so `/compile-latex`'s 3-pass + bibtex pipeline completes cleanly on the onboarding sample.

---

## v1.1.0 — 2026-03-20

### Added

- **`/deep-audit` skill** — repository-wide consistency audit (4 parallel specialist agents).
- **2026 Claude Code feature support** — effort levels (`/effort low|medium|high|max`), 5 permission modes, 4 hook handler types, 11 new hook events documented.
- **Skill frontmatter reference** — `effort`, `context: fork`, `agent`, `hooks`, dynamic `!\`command\`` injection.
- **Pattern 15: Sequential Adversarial Audits** — seven-audit protocol for paper review (inspired by ClaudeCodeTools).
- **Ecosystem section** — autoresearch (Karpathy), ClaudeCodeTools, clo-author, claudeblattman, MixtapeTools.
- **Prerequisites section** — install command (`curl -fsSL https://claude.ai/install.sh | bash`), Node.js, Claude account, cost notes.
- **`plansDirectory` setting** — explicit `quality_reports/plans/` location.
- **Automatic "Last Modified" date** — `date-modified: last-modified` in guide YAML.

### Changed

- Major guide refresh: 2400+ lines, all 25 factual claims verified against official docs across two deep-audit rounds.
- Template cleanup for fork-friendliness — removed project-specific session logs, emptied `Bibliography_base.bib`, renamed Emory SCSS to generic `theme-template.scss`.

### Fixed

- All 5 Python hooks: `from __future__ import annotations`, fail-open `try/except`, `~/.claude/sessions/` storage, hash length consistency.
- `pre-compact.py` exit code (2 → 0) and stdout → stderr (PreCompact ignores stdout).
- `post-compact-restore.py` reads `source` field (was reading `type`, never ran).

---

## v1.0.0 — 2026-02-28

### Initial Release

- 10 specialized agents: proofreader, slide-auditor, pedagogy-reviewer, r-reviewer, tikz-reviewer, beamer-translator, quarto-critic, quarto-fixer, verifier, domain-reviewer.
- 22 skills covering LaTeX, Quarto, R, reproducibility, research, and meta-workflows.
- 18 rules (4 always-on, 14 path-scoped) for quality gates, verification, and domain standards.
- Hooks for notifications, context monitoring, session logging, and compaction state.
- Orchestrator protocol (contractor mode) with adversarial critic-fixer loop (max 5 rounds).
- Plan-first workflow with on-disk plan persistence across context compaction.
- Three-tier memory system: `CLAUDE.md` (project), `MEMORY.md` (auto-memory), session logs.
- GitHub Pages deployment via `scripts/sync_to_docs.sh`.

---

## Upgrading Your Fork

If you forked this repo and want to pull our updates:

```bash
git remote add upstream https://github.com/pedrohcgs/claude-code-my-workflow.git
git fetch upstream
git merge upstream/main           # or: git rebase upstream/main
```

Files you almost certainly customized — `CLAUDE.md`, `Bibliography_base.bib`, `Quarto/theme-template.scss`, your lecture files in `Slides/` and `Quarto/`, `.claude/agents/domain-reviewer.md` — may produce merge conflicts. Resolve in favor of your customizations; pull only the infrastructure improvements.

To pin to a specific version: `git checkout v1.3.0` (latest as of 2026-04-13).
