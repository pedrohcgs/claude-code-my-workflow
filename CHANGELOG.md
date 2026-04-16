# Changelog

All notable changes to this template are documented here. We follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and use loose semantic versioning: **major** when fork upgrades require manual migration, **minor** for new skills or features that are additive, **patch** for fixes and docs.

If you have forked this template, see the **Upgrading** section at the bottom for how to pull updates without losing your customizations.

---

## v1.6.1 — 2026-04-16

A **framing honesty + hook friction** patch release. No new skill or rule directories, no new hooks, and no breaking changes (on-disk counts unchanged at 27/22/13/6); existing skills, rules, docs, and hooks are revised to address two classes of issue surfaced by a multi-round audit:

1. **Claim-vs-reality drift:** v1.6.0 docs and rules described the "orchestrator" as if it were a repo-wide daemon that activates automatically after plan approval. In reality, the 6-step loop (IMPLEMENT → VERIFY → REVIEW → FIX → RE-VERIFY → SCORE) is a **pattern** implemented by specific skills (`/commit`, `/qa-quarto`, `/review-paper --adversarial`, `/slide-excellence`, `/create-lecture`, `/data-analysis`, `/review-paper --peer`). Plan approval does NOT trigger an auto-loop. Similarly, quality thresholds are **advisory inside `/commit`**, not enforced by a repo-wide git pre-commit hook.

2. **Hook blocking fatigue:** the Stop hook `log-reminder.py` used `{"decision": "block"}` to force session-log creation. Effective for discipline, disruptive for autonomous flows. Now exits 0 with stderr-only advisories.

### Changed — honest framing

- **`.claude/rules/orchestrator-protocol.md`** rewritten: opens with "This rule describes the contract that skills implement. The 6-step loop is a *pattern*, not a runtime." Adds a skill-by-skill implementation table (which skill covers which steps; notes where auto-fixing happens and where it doesn't). "Just Do It" mode clarified to explicitly NOT authorize commits on its own — `/commit` invocation is still required.
- **`.claude/rules/quality-gates.md`** renamed to **"Quality Review & Scoring Rubrics"** in practice (header kept for URL stability). Opens with an advisory-framing callout: enforcement is by the `/commit` skill only (halt + ask to override); a direct `git commit` bypasses the review.
- **`.claude/rules/cross-artifact-review.md`** clarifies that detection is **pattern-based** (`\input{scripts/...}` / `%% source:` / filename matches). If the manuscript has none of those signals, nothing auto-invokes — and `--no-cross-artifact` is a no-op. Removed a reference to an unimplemented `--with-scripts` forcing flag.
- **`.claude/rules/beamer-quarto-sync.md`** adds a **precedence-with-SSOT** section for the case where the Quarto file has manual post-translation edits: Beamer remains authoritative; presentation-only divergence (HTML-specific callouts) is allowed; structural drift is a bug.
- **`guide/workflow-guide.qmd`** 4 sections rewritten: "The Orchestrator" → "A Pattern, Not a Daemon"; "Quality Scoring" now advisory; the "Skills vs Orchestrator" callout acknowledges both paths invoke the pattern inside a skill. Removed 5 occurrences of "automatic orchestrator" overselling across the document.
- **`README.md`** contractor-mode framing updated: "runs the orchestrator pattern internally" instead of "runs autonomously." Quality Review section adds an explicit framing-honesty note: "advisory at the harness level — if you bypass the skill, you bypass the review."
- **`docs/index.html`** landing-page bullets reworded: "Contractor mode via skills" (not "Contractor mode orchestrator"), quality-scoring bullet describes halt-and-override inside `/commit`.
- **`CLAUDE.md`** Quality Thresholds table title now reads "(advisory)" with a one-line footnote clarifying `/commit`-only enforcement.

### Changed — hook friction relief

- **`.claude/hooks/log-reminder.py`** no longer blocks. Both block-return branches (no-log-exists and 15-response-counter) converted to stderr-only advisories. `THRESHOLD` raised from 15 → 50. Docstring updated to match the new semantics. The old blocking behavior was effective but disrupted `/loop` and batched-fix flows — stderr reminders preserve the nudge without halting execution.
- **`.claude/hooks/verify-reminder.py`** throttle bumped from 60s → 300s (5 minutes). Same reminder, less noise during iterative `.tex` / `.qmd` / `.R` edits.

### Added — orphan wiring + skill disambiguation

- **`templates/decision-record.md`** (v1.6.0 addition) now wired into `/interview-me`: when the researcher explicitly chooses among alternatives during an interview (e.g. DiD vs IV vs RDD, admin vs survey data), the skill produces an ADR alongside the research spec. Skipped when there's a single uncontested path.
- **Decision trees** added to the top of `/review-paper`, `/seven-pass-review`, and `/slide-excellence` SKILL.md files. Users can now pick the right skill at a glance: review-paper = most drafts; seven-pass = submission-ready / R&R; slide-excellence = slides; plus pointers to single-lens skills.
- **`.claude/agents/domain-reviewer.md`** and **`domain-referee.md`** both prefixed with a scope-disambiguation block. `domain-reviewer` is the general (not disposition-primed) substance reviewer used by `/slide-excellence` and `/seven-pass-review`. `domain-referee` is the disposition-primed variant used by `/review-paper --peer`. Same domain expertise, different calibration.
- **`.claude/rules/r-code-conventions.md`** adds **Section 8: Numerical Discipline** with the project epsilon (`eps <- 1e-12`) for CDF clamping plus 7 headline rules, cross-referenced to `r-reviewer` Category 11. The checklist gains a "numerical discipline" row.

### Added — documentation

- **`TROUBLESHOOTING.md`** +5 sections for v1.5/v1.6 features:
  - **Permissions / bypass / statusline** (6-layer stack diagnosis, why `/permission-check` gates host-global reads, statusline parse-failure recovery)
  - **Peer-review pipeline** (missing journal profile, cloned referee reports, R&R continuation chain breaks)
  - **Surface-sync gate** (count drift resolution, adding a new skill breaks the gate by design)
  - **Pre-Flight Reports** (fail-closed semantics, first-lecture fallback in `/create-lecture`)
  - **Decision records** (where to save, gitignore behavior)
- **`README.md`** Quick Start adds two callouts: Python/R/markdown-only users can skip XeLaTeX/Quarto; `MEMORY.md` vs `personal-memory.md` distinction introduced early (was previously session-2 discovery only).
- **`MEMORY.md`** +6 new `[LEARN]` entries: framing (orchestrator is pattern, quality gates advisory, cross-artifact pattern-based), dogfooding (empty `quality_reports/` dirs is a red flag — Stop hook caught it mid-session), audit (claim-vs-reality is the highest-ROI lens for a governance-heavy template repo). Template inventory refreshed from 6 → 10 files + `tikz-snippets/`.
- **`guide/workflow-guide.qmd`** "All Skills" table adds `/seven-pass-review` and `/permission-check` (were missing).

### Fixed — review-driven polish (from Copilot + Codex on PR #87)

- **Broken anchor:** `r-code-conventions.md` linked to `#category-11-numerical-discipline`, but the actual heading in `r-reviewer.md` is `### 11. NUMERICAL DISCIPLINE`. Dropped the anchor, references by name.
- **Unimplemented flag:** `beamer-quarto-sync.md` advised running `/translate-to-quarto --diff [file]`, but the skill has no `--diff` option. Replaced with "regenerate into a scratch path, diff manually."
- **Contradictory scope:** `domain-reviewer.md` claimed "slides only" while also stating "used by `/seven-pass-review`" (a manuscript skill). Reframed as general reviewer for both artifacts; `domain-referee.md` is the disposition-primed manuscript variant.
- **Stale docstring:** `log-reminder.py` docstring described blocking behavior after the code had been converted to advisory. Updated.
- **Stale docstring:** `verify-reminder.py` said "within 60s" after throttle was bumped to 5 min. Updated.
- **Daemon phrasing in TROUBLESHOOTING:** `sessionInfo.txt` fix referenced "the orchestrator" as if it were a daemon. Points at `00_run_all.R` via `/data-analysis` or the user's pipeline runner instead.
- **`/context-status` regression averted:** intermediate commit had unwired `context-monitor.py` from `PostToolUse`, but `/context-status` reads the cache that hook writes. Codex flagged the dependency; the hook was re-wired before merge.
- **CHANGELOG upgrade example:** pin example updated from `v1.3.0` (2026-04-13) to `v1.6.0` (2026-04-15) to reflect current state.
- **Guide frontmatter date:** stale `2026-03-20` → `2026-04-15` (v1.6.0 release date).
- **v1.6.0 Pre-Flight claim:** CHANGELOG line about "fail-closed if inputs can't be read" now acknowledges `/create-lecture`'s first-lecture fallback (documented exception, not a contradiction).

### Governance note

v1.6.1 establishes the **"claim-vs-reality" audit lens** as a first-class review category going forward. When a template repo oversells itself, the gap is the first thing forkers notice when reality bites. The [LEARN:audit] entry in MEMORY.md captures this: for any governance-heavy feature, the audit question "is the claim mechanically enforced, or is it prose?" catches more real bugs than skill/doc consistency checks.

The Stop hook's conversion from blocking to advisory is a **philosophical tradeoff**: discipline vs. autonomy. v1.6.0 chose discipline (block until the user complies); v1.6.1 chooses autonomy (nudge but don't halt) because the blocking version disrupted `/loop`, batched audits, and autonomous-ship flows. The nudge survives in stderr, the discipline now depends on the user's own habit. If a future release finds this has quietly caused session-log neglect, the blocking form can be restored behind an opt-in setting.

### Verification

Pre-merge deep audit launched 4 parallel agents (guide content, hook code, skills/rules consistency, cross-doc). 1 genuine finding (stale docstring), 1 false alarm (log-reminder fail-open is correct). Fixed on branch before merge.

Surface-sync gate: 27 skills / 13 agents / 22 rules / 6 hooks matched across 6 surfaces. `quality_score.py` on `guide/workflow-guide.qmd`: 100/100.

---

## v1.6.0 — 2026-04-15

A **discipline-layer release**: the template's infrastructure now actively catches the class of bugs that produced reviewer-driven fix PRs in v1.5.x. Also adds two observability/diagnosis tools (statusline, `/permission-check`), doubles the referee pet-peeve pools, and ports three quality patterns from clo-author (Pre-Flight Reports, Content Invariants, Numerical Discipline). No breaking changes.

### Added — observability + diagnostics

- **`.claude/scripts/statusline.sh`** — always-visible mode badge (`[BYPASS] / [PLAN] / [AUTO-EDIT] / [PROMPT]`) + model + git branch. Renders on every turn. Wired via `.claude/settings.json` `statusLine`. Parses session JSON in a single `python3` invocation (per-turn perf).
- **`.claude/skills/permission-check/`** — new `/permission-check` skill. Read-only diagnostic: reads repo-local settings layers auto, requires explicit user confirmation before reading host-global (`~/.claude/settings.json`, VSCode user settings). Redacts unrelated keys. Surfaces drift across the 6-tier permission stack (VSCode user / workspace / CLI user / project / project-local / in-session runtime).
- **Six-Layer Permission Stack + Plan→Bypass Handoff** in the guide. Troubleshooting checklist for "prompts fire despite bypass." Explicit `callout-warning` that plan approval is NOT an enforcement boundary — exiting plan mode returns to `defaultMode` with full bypass authority.

### Added — surface-sync gate

- **`scripts/check-surface-sync.py` + `scripts/check-surface-sync.sh`** — cross-document count consistency gate. Counts `.claude/{skills,agents,rules,hooks}` on disk, scans 6 surfaces (README, CLAUDE.md, guide .qmd + .html, docs/index.html, skill-template) for count assertions using compound regex patterns (avoids false positives on unrelated phrases like "3 parallel agents" or attribution lines). Fails closed on drift — no `"commit anyway"` override. Wired into `/commit` as Step 0b.
- Addresses the systemic drift pattern that produced PRs #70, #76, #78 in v1.5.x (adding a skill updated `.claude/` but left stale counts in prose).

### Added — referee quality polish

- **Expanded editor pet-peeve pools:** 25 → 29 critical peeves (added: notation drift, seed-dependent results, covariate balance absent, overlap/common-support missing); 20 → 25 constructive peeves (added: "what this paper does not show" paragraph, raw-data figures, alternative specs, notation tables, careful attribution). Now exceeds clo-author v3.1 baseline (27/24).
- **`quality_reports/decisions/` + `templates/decision-record.md`** — ADR-style decision records. Template with Status / Problem / Options considered / Decision + rationale / Consequences / Rejected alternatives. Gitignored like plans/specs.

### Added — discipline patterns (ported from clo-author, adapted)

- **Pre-Flight Reports** in `/data-analysis`, `/create-lecture`, `/review-paper --peer`. Each skill now requires a structured output block proving inputs were read before doing work (dataset fields, project conventions, notation registry checks, journal profile, cross-artifact status). Fail-closed if inputs can't be read, **with a documented first-lecture fallback** in `/create-lecture` (proposes a minimal knowledge base when the template is still empty, to avoid deadlocking fresh forks).
- **`.claude/rules/content-invariants.md`** — new rule, path-scoped to `Slides/**/*.tex`, `Quarto/**/*.qmd`, `Quarto/**/*.scss`, `Preambles/header.tex`, `scripts/R/**/*.R`. Defines **INV-1 through INV-12**: palette sync, Beamer↔Quarto notation parity, Quarto CSS override contract, TikZ-as-SVG, single bibliography, no `\pause`, max 2 boxes per slide, motivation-before-formalism, `set.seed` once, relative paths only, transparent-bg figures, project theme on all plots. Critics can now cite invariants by number.
- **`r-reviewer` agent — category 11 "Numerical Discipline":** no float `==`, CDF clamping to open interval with named epsilon (not `[0,1]` — exact 0/1 to `qnorm` yields ±Inf), integer literals for counts (`1L`), pre-allocated vectors, deterministic bootstrap seeding, explicit `na.rm`, no `T`/`F` shorthands.

### Changed — skill trigger descriptions

- **17 `.claude/skills/*/SKILL.md` frontmatter rewrites** for reliable auto-invocation. Verb+object + "Use when: …" trigger phrases + disambiguation from sibling skills (e.g., `/interview-me` explicitly says NOT for lit review, pairs with `/research-ideation`). Follows the `deep-audit` gold-standard pattern. Cold-prompt auto-invocation is now reliable for `/commit`, `/deploy`, `/proofread`, `/data-analysis`, and siblings.
- **`commit` skill triggers tightened** after Codex flagged vague end-of-task phrases as risky: now only explicit commit intent ("commit", "ship it", "push this", "open a PR", "merge to main", "let's commit this"). Removed "wrap up these changes" and end-of-task-signal trigger.
- **Guide: "Writing Effective Trigger Descriptions"** expanded with the 3-part pattern (verb+object → "Use when:" phrases → disambiguation), A/B rewrite example, and a pre-ship checklist.

### Changed — documentation

- **Counts:** skills 26 → 27 (added `/permission-check`), rules 21 → 22 (added `content-invariants`). Agents and hooks unchanged. Synced across all 6 surfaces via the new sync gate.
- **Guide re-rendered** with the new sections (statusline, permission stack, Plan→Bypass handoff, expanded trigger-description guidance). `docs/workflow-guide.html` synced.

### Fixed — systemic quality during development

This release absorbed an unusual volume of reviewer-driven fixes from Codex and Copilot. Representative samples:

- **Count drift:** a single `replace_all` on `"26 skills"` missed `"26 skills, and 21 rules"` (extra "and"), missed `"26 slash commands"`, missed `"template's 26"`. The deep-audit skill now documents the phrasing-variant trap; the surface-sync gate prevents the class of bug.
- **Stop-hook block protocol:** some audit guidance implied non-zero exit codes are required to block. Actually, modern Claude Code accepts BOTH `exit 2 + stderr reason` (legacy) AND `exit 0 + JSON {"decision":"block","reason":"..."}` on stdout (modern — what `log-reminder.py` uses). Deep-audit skill now documents both protocols explicitly so future audit agents don't re-flag `log-reminder.py`.
- **Statusline parse-failure fallback:** parse error emitted `cwd="."` which wasn't empty, bypassing the `pwd` fallback. Fixed to emit empty third line and tightened the bash guard to treat `"."` as invalid.
- **`notify.sh` robustness:** best-effort notification now fails open on missing `jq` AND on malformed JSON input (defaults before jq attempt, silent stderr on parse).
- **Plan→Bypass framing:** initial guide text said "combines safety and prompt-free execution." Codex correctly flagged this as overselling — plan approval doesn't bind later execution to the approved plan. Reworded as "review-before-execute convenience" with a callout warning.
- **`/permission-check` privacy boundary:** first draft read `~/.claude/` and VSCode user settings unconditionally on ambiguous prompts like "why am I getting prompts?". In a shared/corporate environment this could leak host-global config. Restructured into Phase A (repo-local, auto) + Phase B (host-global, explicit user confirmation + key redaction).
- **CDF clamping math bug** in the new Numerical Discipline checklist: initial draft said `pmin(1, pmax(0, p))` but exact 0/1 to `qnorm` yields ±Inf. Fixed to open interval with named `eps`.
- **Content-invariants path globs:** initial frontmatter used bare directories; other rule files use quoted glob patterns. Aligned.
- **Seed format conflict** in `/data-analysis`: Phase 1 required YYYYMMDD (per `r-code-conventions.md`) but the template example still showed `set.seed(42)`. Made self-consistent.

### Attribution

The discipline patterns in this release (Pre-Flight Reports, Content Invariants, Numerical Discipline rules) are **ported from [Hugo Sant'Anna's clo-author](https://github.com/hugosantanna/clo-author) with adaptation to our lecture-shaped surface**. Hugo's v4.1.x has moved to a 10-verb skill consolidation + full paper-type branching we deliberately didn't port (doesn't fit our primary artifact). Invariants have lecture-specific codes (INV-1..INV-12) rather than clo-author's paper-centric ones.

### Governance note

v1.6.0 establishes the "discipline layer" as a first-class template concern. The surface-sync gate makes count drift a pre-commit error, not a reviewer catch. The statusline + `/permission-check` turn permission debugging from detective work into a 2-second glance. The Pre-Flight Report pattern makes "agent hallucinated your variable names" a category of failure that can't happen silently.

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

To pin to a specific version: `git checkout v1.6.0` (latest as of 2026-04-15).
