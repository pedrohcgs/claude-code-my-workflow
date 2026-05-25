# Changelog

All notable changes to this template are documented here. We follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and use loose semantic versioning: **major** when fork upgrades require manual migration, **minor** for new skills or features that are additive, **patch** for fixes and docs.

If you have forked this template, see the **Upgrading** section at the bottom for how to pull updates without losing your customizations.

---

## v1.9.0 — 2026-05-20

A **guide-refresh + ecosystem catch-up** minor release shipped in five passes against the plan at `quality_reports/plans/2026-05-20_v1.9.0-guide-refresh.md` (local-only; not tracked in git per the standard `quality_reports/plans/*` ignore rule). No breaking changes.

**Inventory at release: 36 skills, 16 agents, 26 rules, 6 hooks** (was 30 / 14 / 24 / 6 at v1.8.0). The release adds 6 skills (`/humanize`, `/prompt`, `/prompt-only`, `/compress-session`, `/promote-memory`, `/stata-replication`), 2 agents (`humanize-auditor`, `promote-memory-council`), and 2 rules (`model-routing.md`, `stata-code-conventions.md`).

### Pass 1 (PR #114, merged 2026-05-20) — guide refresh mechanical corrections

Eight mechanical corrections that bring the guide in line with Anthropic shipments through May 2026 (Weeks 17–20), reframe three lingering "automatic orchestrator" mentions, refresh the clo-author citation to its current MAS v2 architecture, and add a Models / API section to TROUBLESHOOTING covering the 2026-06-15 Sonnet 4 + Opus 4 retirement and the Agent SDK credit-pool split. No new skills, agents, rules, or hooks. On-disk inventory unchanged.

### Fixed

- **`guide/workflow-guide.qmd` + `TROUBLESHOOTING.md` + `CHANGELOG.md`** — `/less-permission-prompts` → `/fewer-permission-prompts`. Verified against Anthropic's [Week 16 changelog](https://code.claude.com/docs/en/whats-new/2026-w16) and Boris Cherny's launch announcement: the skill shipped under `/fewer-permission-prompts` from day one. The previous template name was a typo, not a rename — historical-changelog wording rewritten for accuracy.
- **`guide/workflow-guide.qmd:46–157`** — three lingering framings of orchestration as automatic ("Claude automatically: → Runs X, → Runs Y...") rewritten to name the invoked skill explicitly ("Claude invokes `/slide-excellence`, which internally..."). Reinforces the [orchestrator-protocol rule](.claude/rules/orchestrator-protocol.md) — there is no repo-wide daemon; orchestration lives inside the invoked skill.

### Added — Anthropic shipments since 2026-04-27

- **Model lineup callout** (Multi-Model Strategy section) — documents Opus 4.7 as the Max/Team Premium default (GA 2026-04-16, same pricing as 4.6: \$5/\$25 per MTok), Sonnet 4.6 as workhorse (1M context still available; the 4.5 1M beta retired 2026-04-30), Haiku 4.5 as the fast tier. Sources: [Opus 4.7 announcement](https://www.anthropic.com/news/claude-opus-4-7), [Platform release notes](https://platform.claude.com/docs/en/release-notes/overview).
- **`xhigh` effort level** (Effort Levels table + How-to-set list) — introduced Week 16 (Apr 13–17, v2.1.105–113); recommended for Opus 4.7 coding work. Bare `/effort` now opens an interactive slider. Hooks see `effort.level` and `$CLAUDE_EFFORT` is set in Bash subprocess env (Week 19).
- **Auto mode flag retirement** (Permission Modes table) — `--enable-auto-mode` no longer required for Max + Opus 4.7 users as of Week 16.
- **`/goal <verifiable condition>`** (Session Management + Anthropic Utilities) — shipped Week 20, v2.1.139 (May 11). "Keep working until X holds" command, distinct from `/loop` (interval) and plan mode (strategy approval). Pairs with `/commit` quality gates. Source: [`docs.claude.com/en/goal`](https://code.claude.com/docs/en/goal).
- **`claude agents` dashboard** (Cost-Conscious Parallelism + Anthropic Utilities) — also Week 20, v2.1.139. Single screen for all background sessions; aligned with the `/review-paper --peer` parallel-referee pattern.
- **`/loop` alias `/proactive`** noted (Week 16).
- **`worktree.baseRef` setting** (Pattern 12) — Week 19. New callout explains `fresh` (default; branch from remote default) vs `head` (branch from local HEAD). Surprises users with uncommitted in-flight edits — documented inline.

### Added — TROUBLESHOOTING entries (Models and API section)

- **Sonnet 4 / original Opus 4 retire 2026-06-15** — migration checklist covering `ANTHROPIC_MODEL` env, `.claude/settings.json` model overrides, agent frontmatter pins, and CI `claude -p --model` calls. Recommended replacements: Sonnet 4.6 and Opus 4.7 respectively.
- **Agent SDK credit-pool split (2026-06-15)** — heads-up that `claude -p` headless subprocess calls (used by `/coarse-review` and any other `claude -p`-based skill) draw from a separate monthly Agent SDK credit pool after the cutover. Anthropic posts cited: [Apr 8 "Decoupling Brain from Hands"](https://www.anthropic.com/engineering), [Platform release notes](https://platform.claude.com/docs/en/release-notes/overview).

### Changed — ecosystem references

- **clo-author** (Ecosystem section) — new callout documenting v26.05 (2026-05-10): MAS v2 (second-generation multi-agent system), Skill-Centric Restructure (13 skills + 18 agents, up from 17), HTML Dashboard. The `/checkpoint` attribution to v4.2.0 remains accurate as historical record (that's where the pattern was adapted from); the callout makes clear that current forkers of clo-author get the MAS v2 / skill-centric layout.

### Provenance

This pass is the first slice of a research-grounded refresh. Four parallel research agents (Anthropic ecosystem, community repos, cross-vendor coding agents, internal guide audit) plus two verification agents (Anthropic claim verification, ARS source-code audit) ran on 2026-05-20. Findings, ranked recommendations, and source URLs are in `quality_reports/plans/2026-05-20_v1.9.0-guide-refresh.md` (local-only; not tracked in git per the standard `quality_reports/plans/*` ignore rule). Passes 2–5 add capability (B Cost & Caching section, C poli-sci breadth woven into guide body, D `/preregister` + `/checkpoint` patterns, E `/review-paper --variance N`, F `passport.yaml` claims provenance, G architect/editor cost-routing, H `/promote-memory` five-critic council, I HIGH-WARN claim-faithfulness blocking, J `/compress-session`, K SDK credit awareness, L Anthropic engineering-post citations, M `/prompt` port from Blattman, N `/humanize` detect-and-flag skill, plus Stata-MCP integration). All deferred to follow-up commits; nothing in this commit adds new on-disk infrastructure.

### Verification

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts unchanged (30 skills / 14 agents / 24 rules / 6 hooks)
- `./scripts/check-palette-sync.sh` — palette in sync
- `./scripts/check-skill-integrity.py` — all checks pass

### Pass 2A — guide-only capability adds (2026-05-20)

Two guide-body additions: weaves the v1.8.0 political-science breadth into the user-facing guide body (previously documented only in the v1.8.0 CHANGELOG entry), and introduces a new "Cost-Conscious Composition" subsection that documents prompt-cache TTL behaviour, per-agent model routing (70/20/10 pattern), and `/cost` / `/usage` monitoring. No new skills, agents, rules, or hooks. On-disk inventory still unchanged.

#### Added — political-science breadth surfaced in guide body

- **5-Lens Framework table** — added Political Science as a third worked example column alongside Economics and Physics. Lens entries reflect poli-sci norms (ignorability, conjoint AMCEs under Hainmueller–Hopkins–Yamamoto, `cjoint`/`survey::svyglm` defaults, manipulation-check fidelity).
- **Domain-reviewer ship status callout** — documents that the template ships *two* concrete customizations of `.claude/agents/domain-reviewer.md` (econ + poli-sci), both viable starting points for forkers' own fields.
- **`/review-paper --peer [journal]` callout** (Research Skills section) — new explainer covering the editor + 2-referee + editorial-decision pipeline, the journal-profiles starter set (AER, QJE, JPE, ECMA, JoE, APSR, AJPS, JOP), and the full 6-paper-type methods-referee taxonomy with sanity checks per type (reduced-form, structural, theory+empirics, descriptive, formal-theory, survey-experiment). The v1.8.0 formal-theory + survey-experiment additions are now discoverable from the main guide, not just from the CHANGELOG.
- **"What ships preloaded vs. what you customize" callout** (§7 Customizing for Your Domain) — explains what already ships for econ + poli-sci (journal profiles, paper types, discipline cards) and what forkers add for psych / sociology / public-health (~3 profiles + 2–3 paper types + 1 card per discipline). Points at `.claude/references/v1.9-backlog.md` as the candidate-next-breadth roadmap.

#### Added — Cost-Conscious Composition subsection (§ between Multi-Model Strategy and Permissions)

- **Prompt-cache TTL guidance** — documents the 60 min → 5 min default-TTL change and the opt-in `ENABLE_PROMPT_CACHING_1H` environment variable on API/Bedrock/Vertex/Foundry plans. Cites Apr 2026 community cost-analysis showing 30–60% effective input-cost increase for long pipelines without the 1-hour opt-in. Documents `cache_miss_reason` (public beta 2026-05-13) as the diagnostic.
- **70/20/10 model-routing pattern** — explicit table of Haiku (70%, mechanical work) / Sonnet (20%, review and critique) / Opus (10%, high-judgment work). Maps each tier to specific template agents (TikZ extraction → Haiku; r-reviewer → Sonnet; editor/methods-referee → Opus). Cites Anthropic's Apr 8 2026 "Decoupling brain from hands" post for primary-source endorsement.
- **Effort-budgeting guidance** — reach for `xhigh` (Opus 4.7) only when verified that the cheaper tier failed.
- **`/cost` and `/usage` monitoring callout** — when to run each and how to read cache hit-rate as a TTL-misconfiguration signal.
- **Agent SDK credit-pool 2026-06-15 callout** — links to the TROUBLESHOOTING Models / API section landed in Pass 1.

#### Verification — Pass 2A

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts still unchanged (30/14/24/6)
- `./scripts/check-skill-integrity.py` — all checks pass
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 2B — `/preregister` + `/checkpoint` promoted to Pattern entry (2026-05-20)

Promotes the v1.8.0 `/preregister` and `/checkpoint` skills from appendix entries to a first-class **Pattern 16: Preregistration and Submission Discipline** in the Workflow Patterns section. ~85 lines of new prose. Still no new skills, agents, rules, or hooks — Pattern 16 documents what already ships.

#### Added — Pattern 16: Preregistration and Submission Discipline

- **When-preregistration-matters checklist** — launch of experiment, observational analysis before outcome inspection, R&R PAP request, funding pre-submission.
- **Registry-comparison table** — OSF / AsPredicted / AEA RCT side-by-side (field, length, editability). Public-health / clinical-trial registries explicitly out of scope (on v1.9-backlog).
- **End-to-end workflow diagram** — `/interview-me` spec → `/preregister --style` → user uploads → `/checkpoint preregistration-submitted` → data collection begins.
- **Per-registry mandatory-field matrix** — 10 rows × 3 styles, showing MUST / SHOULD / MAY for each field. Captures registry-specific differences (e.g., AEA mandates intervention description and data-sharing plan; AsPredicted allows looser covariate specification).
- **`/checkpoint` pairing protocol** — explicit `pre-submit` → `submitted [registration-id]` → `data-arrived` snapshot sequence so the boundary between confirmatory and exploratory is structurally visible.
- **Post-flight `/verify-claims` integration** — every cited reference in the preregistration runs through Chain-of-Verification before submission. Hallucinated citations are the most common preregistration failure mode.
- **Anti-pattern protections enumerated** — HARKing, p-hacking, forking paths, selective reporting — and which fields of the preregistered document defend against each.
- **Field-specific guidance** — pointers to Christensen & Miguel (2018) for development economics, Monogan (2015) for political science, OSF Preregistration Guide for psychology.

#### Verification — Pass 2B

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts unchanged (30/14/24/6)
- `./scripts/check-skill-integrity.py` — all checks pass
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 2C — `/review-paper --variance N` reviewer-disposition variance mode (2026-05-20)

Adds a fourth `--peer` mode to `/review-paper`: **`--variance` (with integer N, default 3)** runs N referees with independently sampled dispositions from the 6-way taxonomy, then the editor synthesizes the results into a **decision distribution** (not a point estimate). Motivated by AgentReview (ACL 2024, [arXiv:2406.12708](https://arxiv.org/abs/2406.12708)), which found ~37% of paper decisions vary purely from reviewer-disposition sampling.

#### Changed — `/review-paper` SKILL.md

- New `--variance` flag in argument-hint and the sub-flags list under "Peer-review mode."
- New "Variance mode (`--peer --variance N`)" subsection: motivation (AgentReview), procedure (sample with replacement + stratification override that always includes a SKEPTIC if none drawn for N ≥ 3), output files (`referee_1.md` … `referee_N.md`, `decision_distribution.md`, `editor_synthesis.md`), cost discipline (referee-tier cost × N relative to default `--peer`; hard cap N=5; route referees to Sonnet for variance runs), and mutual-exclusivity rules (cannot combine with `--stress` or `--r2`/`--r3`).
- When-to-reach-for-it guidance: pre-submission "how confidently will this survive," cross-journal target comparison, post-rejection sanity check.

#### Changed — `editor.md` agent

- **Phase 1b (Referee selection)** now branches: default 2-referee deliberate-diversity sampling (existing) vs. variance-mode N-referee independent sampling **with replacement** (new). Stratification rule: if N ≥ 3 and the realised draw includes no SKEPTIC, replace one randomly chosen referee with a SKEPTIC. Realised-disposition table and stratification-override metadata are recorded for `decision_distribution.md`.
- **New "Variance synthesis mode" section** documents the two-file output (`decision_distribution.md` + `editor_synthesis.md`). The distribution file contains a realised-disposition table, a verdict-distribution table (counts and shares), a concern-frequency table (K-of-N), and an interpretation guide (tight modal majority + robust concerns; wide spread + high-K skeptic objection; bimodal "love-it-or-hate-it"). The editorial letter explicitly references the variance instead of collapsing it.

#### Verification — Pass 2C

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts unchanged (30/14/24/6)
- `./scripts/check-skill-integrity.py` — all checks pass (forward + reverse flag-parity OK after one cycle of integrity feedback — original `` `--variance N` `` single code-span fixed to ``--variance`` standalone code-span with `N` documented in prose)
- No on-disk inventory change

### Pass 2D — `/humanize` detect-and-flag skill (2026-05-20)

Ships a new skill and a new agent to audit academic prose for AI-voice tells. **Detect-only by design** — there is no `--rewrite` mode. The author edits manually after reading the report; auto-rewriting prose to strip AI tells degrades quality (cross-vendor research finding) and introduces *new* AI tells.

#### Added — new skill

- **`.claude/skills/humanize/`** — `/humanize [file] [--severity low|med|high]` runs a read-only audit on `.tex`, `.qmd`, or `.md` prose against 10 detection categories: (1) boilerplate transitions, (2) AI-cliché lexicon, (3) em-dash/punctuation overuse, (4) symmetric paragraph shapes, (5) tricolon abuse, (6) hedging stacking, (7) "Not only X, but also Y" frames, (8) formulaic openers, (9) hyphenation excess, (10) sycophancy/self-important framing. Output: `quality_reports/humanize_<filename>_report.md` (gitignored) with per-finding line numbers, severity (LOW / MED / HIGH), and suggested rewrites. Carries `disable-model-invocation: true`. Documents the no-`--rewrite` anti-pattern explicitly in the SKILL body.

#### Added — new agent

- **`.claude/agents/humanize-auditor.md`** — read-only auditor that runs the 10-category protocol and returns a structured report (per-category counts, per-finding table, concentration analysis identifying the top-3 most-affected paragraphs, recommendation thresholds for "rewrite" vs "strip" vs "cosmetic"). Calibration heuristics built in (~1000 words: 0 HIGH clean; 3 HIGH manageable; 8+ HIGH recommend rewrite). Reads `style-profile.md` if present to respect documented author preferences. Will not auto-flag single-mention idioms or discipline-legitimate constructions.

#### Changed — count-bearing surfaces

- **Inventory:** **31 skills, 15 agents, 24 rules, 6 hooks** (was 30 / 14 / 24 / 6). All count-bearing surfaces updated: `README.md`, `CLAUDE.md`, `guide/workflow-guide.qmd` (×3 places: capability table, You-Don't-Need-All-Of-This callout, Customizing-Skills section), `docs/index.html` (landing page), `templates/skill-template.md`. Verified via `./scripts/check-surface-sync.sh`.
- **`CLAUDE.md` Skills Quick Reference** — added `/humanize` row.
- **`guide/workflow-guide.qmd` Appendix** — added `Humanize Auditor` row to All Agents; added `/humanize` row to All Skills.

#### Verification — Pass 2D

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **31 / 15 / 24 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on the new SKILL.md
- `quarto render guide/workflow-guide.qmd` — clean render

### Pass 3A — claims provenance + HIGH-WARN gate + `/prompt` port (2026-05-20)

Strategic additions to the paper-pipeline lens: (a) machine-readable claims provenance via a new `passport.yaml` contract, (b) HIGH/MED/LOW-WARN severity tiers on `/verify-claims` with HIGH-WARN gate-refusing `/commit`, and (c) two new skills (`/prompt`, `/prompt-only`) ported from Chris Blattman's claudeblattman v2.1 with the Blattman-specific tool-routing and council elements stripped.

#### Added — new template

- **`templates/passport-template.yaml`** — starter passport file for per-paper claims provenance. Forkers copy once per paper to `quality_reports/passports/<paper-slug>.yaml`. Schema records claim text, manuscript location, source script + line, output file + field, tolerance overrides, last-verified timestamp, and PASS / FAIL / STALE / UNVERIFIED status per claim.

#### Added — new skills (2)

- **`.claude/skills/prompt/`** — `/prompt [text] [depth:light|standard|deep]` reformats an informal or dictated request into a structured six-section prompt (Role / Task / Context / Constraints / Output format / Bookend) then **executes** it immediately. Depth heuristic: Light (< 40 words, no jargon) emits Role + Task + Output + Bookend; Standard (40–200 words, 1+ domain term) adds Context + Constraints + Assumptions block; Deep (> 200 words, specific paper/dataset/submission target) adds Investigation pre-step. Always shows the formatted prompt to the user before executing.
- **`.claude/skills/prompt-only/`** — `/prompt-only [text] [depth] [--save path]` is the same skill **without execution**. Emits the formatted prompt as a reusable artifact. Optional `--save` writes to disk. Use for prompts you'll run later (different conversation, different model, recurring task).

Both ported with attribution from [`chrisblattman/claudeblattman`](https://github.com/chrisblattman/claudeblattman) v2.1. **Deliberately stripped:** Blattman's tool-routing table (ChatGPT / Perplexity / Gemini dispatch) and his `council` token (his `/council` skill is not in this template). Documented in [`.claude/references/prompt-formatting-core.md`](.claude/references/prompt-formatting-core.md) "What we don't ship" section.

#### Added — new reference

- **`.claude/references/prompt-formatting-core.md`** — shared reference used by `/prompt` and `/prompt-only`. Defines the six-section skeleton (Role / Task / Context / Constraints / Output format / Bookend), the depth-calibration heuristic, a worked example, and the explicit boundary with `/interview-me` (single-shot input shaping vs. multi-turn project specification).

#### Changed — claims provenance integration

- **`.claude/rules/replication-protocol.md`** — new "Claims Provenance: `passport.yaml`" section. Documents the YAML schema (paper metadata + per-claim entries with `id`, `claim`, `location`, `source_file`, `source_line`, `output_file`, `output_field`, `tolerance`, `last_verified_on`, `status`, `notes`), the `status` semantics (PASS / FAIL / STALE / UNVERIFIED), integration with `/audit-reproducibility` (passport-mode), `/commit` (advisory by default, gate-refuse on `--strict-passport`), and `/review-paper` (summary section). Attributes the pattern to [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) "Material Passport" while scoping our schema to numeric-claim provenance only (theirs threads ~13 contracts through ~6 agents; ours stays narrow).
- **`.claude/skills/audit-reproducibility/SKILL.md`** — new "Passport-mode (v1.9.0)" section. When a passport file exists, the skill reads + updates + rewrites it in place rather than emitting a one-shot report. Updates `status` per claim (PASS / FAIL / STALE), records discrepancies in `notes`, refreshes timestamps, refuses to auto-populate (passport scope is author-curated to avoid bad inferences).

#### Changed — HIGH-WARN claim-faithfulness tier

- **`.claude/skills/verify-claims/SKILL.md`** Phase 4 — three severity tiers introduced (HIGH-WARN: fabricated reference / direct contradiction / not-found retrieval interpreted as hallucination; MED-WARN: transient retrieval failure; LOW-WARN: source genuinely inaccessible). Tier aggregation table maps to PASS / PARTIAL / FAIL outcomes. **HIGH-WARN gate-refuses `/commit`** for files the skill was just run against unless `--no-fail-closed` or `verifyClaims.allowHighWarn: true` in settings.
- **`.claude/agents/claim-verifier.md`** — output schema extended to include a per-claim `Tier` column (HIGH / MED / LOW / —). New "Tier-assignment rules" section codifies the assignment logic: fabricated citation → HIGH; numerical contradiction → HIGH; directional contradiction → HIGH; transient retrieval failure → MED; genuine inaccessibility → LOW; reasonable paraphrase → no tier. "Be conservative on HIGH-WARN" — false positives erode the gate's authority.

#### Changed — count-bearing surfaces

- **Inventory:** **33 skills, 15 agents, 24 rules, 6 hooks** (was 31 / 15 / 24 / 6 after Pass 2D). Both new skills (`/prompt`, `/prompt-only`) propagated through README.md, CLAUDE.md, guide capability table, You-Don't-Need-All-Of-This callout, Customizing-Skills section, docs/index.html, templates/skill-template.md, guide appendix tables.
- **CLAUDE.md Skills Quick Reference** — added `/prompt` and `/prompt-only` rows.
- **Guide Appendix** — added `/prompt` and `/prompt-only` rows to All Skills table.

#### Verification — Pass 3A

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **33 / 15 / 24 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on both new SKILL.md files
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 3B — per-agent model routing + `/compress-session` + `/promote-memory` (2026-05-20)

Three additions to the cost-discipline and memory-management lenses:

- **G** — new `.claude/rules/model-routing.md` codifying the 70/20/10 architect/editor split (Haiku for mechanical work; Sonnet for review/critique; Opus for high-judgment work). Cites the Anthropic Apr 8 "Decoupling brain from hands" post for primary-source endorsement.
- **J** — new `/compress-session` skill that distils a long-session into a structured note before auto-compaction (motivated by Drew Breunig's "How Long Contexts Fail" four-mode taxonomy). Distinct from `/checkpoint` (explicit stop-point) and from auto-compaction (lossy truncation).
- **H** — new `/promote-memory` skill that runs a five-critic council (generality / staleness / redundancy / evidence / format) on candidate `[LEARN]` entries in `.claude/state/personal-memory.md` to decide what graduates to MEMORY.md. Pattern adapted from Chris Blattman's claudeblattman v2.1 five-critic council with attribution.

#### Added — new rule

- **`.claude/rules/model-routing.md`** — path-scoped on `.claude/agents/**/*.md` and `.claude/skills/**/SKILL.md`. Documents the 70/20/10 pattern with per-tier recipe (mechanical → Haiku 4.5; review/critique → Sonnet 4.6; high-judgment → Opus 4.7). Tags agents per tier (e.g., editor / methods-referee / claim-verifier / quarto-critic → Opus; r-reviewer / slide-auditor / proofreader / humanize-auditor → Sonnet; quarto-fixer / mechanical TikZ extraction → Haiku). Documents two anti-patterns: pushing Opus down a tier (defeats hallucination defence) and the self-as-architect-and-editor pairing (same-model self-pairings produce correlated errors).

#### Added — new skills (2)

- **`.claude/skills/compress-session/`** — `/compress-session [slug]` distils the current session into a structured note (Active state, Decisions made, Files touched, Open questions, Next actions, **Discarded as noise**, Proposed `[LEARN]` entries) and writes to `quality_reports/session_logs/YYYY-MM-DD_compression_<slug>.md`. Defends against [Drew Breunig's four failure modes](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html): poisoning, distraction, confusion, clash. Explicit "Discarded as noise" section is the novel contribution — failed hypotheses don't carry forward as ghost context. Optional PreCompact-hook integration that surfaces a reminder (does NOT auto-invoke — preserves the user's review step).
- **`.claude/skills/promote-memory/`** — `/promote-memory [filter]` runs a five-critic council in parallel (forked contexts via `Task`) on candidate `[LEARN]` entries. Each critic votes YES/NO on one dimension; majority (3+ of 5) promotes. Critics run on Haiku by default (per `model-routing.md`); the user is the final gate even on 5-of-5 unanimous votes. Saves an audit file at `quality_reports/memory_promotion_<date>.md` for forensics. Pattern adapted from Chris Blattman's claudeblattman v2.1 with attribution.

#### Added — new agent

- **`.claude/agents/promote-memory-council.md`** — implements the five-critic protocol. One agent file, five role specs (Generality / Staleness / Redundancy / Evidence / Format), dispatched in parallel via `Task` with `context: fork`. Each critic returns a strict `**Vote:** YES | NO` + one-sentence rationale; the calling skill aggregates. Architectural isolation: each critic sees only its dimension's relevant context (no cross-pollination, no groupthink).

#### Changed — count-bearing surfaces

- **Inventory:** **35 skills, 16 agents, 25 rules, 6 hooks** (was 33 / 15 / 24 / 6 after Pass 3A). All 6 count-bearing surfaces updated: README.md, CLAUDE.md, guide capability table, You-Don't-Need-All-Of-This callout, Customizing-Skills section, docs/index.html, templates/skill-template.md, guide appendix tables.
- **CLAUDE.md Skills Quick Reference** — added `/compress-session` and `/promote-memory` rows.
- **Guide Appendix** — added `Promote-Memory Council` row to All Agents, `/compress-session` + `/promote-memory` rows to All Skills, `Model Routing` row to path-scoped All Rules.

#### Verification — Pass 3B

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **35 / 16 / 25 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on both new SKILL.md files
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]
- `./scripts/check-skill-integrity.py` — all checks pass on both new SKILL.md files
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 4 — Stata expansion: stata-mcp + `/stata-replication` + audit-reproducibility extension (2026-05-20)

User-driven expansion of the template to support Stata-first projects (correction to the original v1.9.0 plan: AEA does not *mandate* Stata; the expansion targets users whose pipelines are Stata-first for reasons of audience reach or original-replication-package fidelity). Three sub-items:

#### Added — new skill

- **`.claude/skills/stata-replication/`** — `/stata-replication [paper-or-data]` scaffolds a numbered Stata pipeline (`00_install.do` through `99_run_all.do`) in `scripts/stata/` and executes via the [`stata-mcp`](https://github.com/SepineTam/stata-mcp) MCP server. Mirrors `/data-analysis` for R-first projects. `--from-r` flag ports an existing R pipeline. `--no-execute` produces scaffolding only. Phase 0 pre-flight halts if `stata-mcp` is not registered (with install instructions); Phase 4 (optional) runs R cross-check on `--from-r` translations to surface clustering-df / default-option drift.

#### Added — new rule

- **`.claude/rules/stata-code-conventions.md`** — path-scoped on `**/*.do` and `scripts/stata/**`. Codifies: standard header (`version 18`, `clear all`, `set seed`, `set sortseed`, `cap log close`, log capture); numbered pipeline (00–99); outputs convention (`scripts/stata/_outputs/` with `sessionInfo.txt`); `esttab` for publication-ready tables with `\input{}` mechanical-update pattern; significance-stars convention (`* 0.10 ** 0.05 *** 0.01`); clustering / SE discipline (`reghdfe`, cluster bootstrap for < 50 groups); balance + attrition via `iebaltab`; graph export to vector + raster; AEA Data Editor compliance checklist. Common Stata-to-R-or-AEA traps table.

#### Changed — `/audit-reproducibility` source-language coverage

- **`.claude/skills/audit-reproducibility/SKILL.md`** — new "Source-language coverage" section documents the three supported ecosystems (R / Stata / Python) with default outputs directories and read-output method per language. Stata-specific notes added: `.dta` outputs read via `haven::read_dta()` (R) or `pyreadstat.read_dta()` (Python); `esttab` `.tex` table-cell values as strongest provenance signal when manuscript uses `\input{}`; clustering-df discrepancy diagnosis (`reghdfe` vs `reg, cluster()`).

#### Added — TROUBLESHOOTING entry

- **`TROUBLESHOOTING.md`** — new "/stata-replication halts at 'stata-mcp not registered'" section. Documents the one-command install (`claude mcp add stata-mcp --scope user -- uvx stata-mcp`), the `uv` prerequisite, and the verify step (`claude mcp list`).

#### Added — Ecosystem entry

- **`guide/workflow-guide.qmd` Ecosystem section** — new "stata-mcp: MCP server for Stata execution" subsection (before ClaudeCodeTools). Documents SepineTam's project, install command, why it matters for v1.9.0's Stata expansion, and the parallel-skill relationship between `/data-analysis` (R) and `/stata-replication` (Stata).

#### Changed — count-bearing surfaces

- **Inventory:** **36 skills, 16 agents, 26 rules, 6 hooks** (was 35 / 16 / 25 / 6 after Pass 3B). All 6 count-bearing surfaces updated. Note: rules count rises only by 1 (the Stata convention rule); skills count rises only by 1 (`/stata-replication` itself); agents unchanged.
- **`CLAUDE.md` Skills Quick Reference** — added `/stata-replication` row.
- **Guide Appendix** — added `/stata-replication` row to All Skills, `Stata Code Conventions` row to path-scoped All Rules.

#### Verification — Pass 4

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **36 / 16 / 26 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on the new SKILL.md
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 5 — verification follow-ups: SDK credit awareness + Anthropic engineering-post citations (2026-05-20)

Closes the v1.9.0 cycle with two small but load-bearing additions:

#### K — Agent SDK credit-pool split (2026-06-15)

Already partially shipped in **Pass 1** (TROUBLESHOOTING "Models and API" section) and **Pass 2A** (Cost-Conscious Composition callout in the guide). Pass 5 confirms the coverage is complete — the `/coarse-review` skill is a Claude Code plugin (not in this template's `.claude/skills/`), so no SKILL.md callout was needed; the TROUBLESHOOTING entry and the guide callout already document the cutover, the affected pattern (`claude -p` headless subprocesses), and the diagnostic ("check the Agent SDK credit balance separately if `/coarse-review` fails with credit-exhaustion errors even though your interactive session works"). **K is closed.**

#### L — Anthropic engineering-post citations

- **Apr 8, 2026 — "Scaling Managed Agents: Decoupling the brain from the hands."** Already cited as primary-source endorsement of the architect/editor split in `.claude/rules/model-routing.md` (Pass 3B) and in the guide's Cost-Conscious Composition section (Pass 2A). No additional citation needed.
- **Apr 23, 2026 — "An update on recent Claude Code quality reports."** New callout added to the guide between the "Mandatory Verification" / "Don't Skip Verification" section and "Creating Your Own Domain Reviewer." Frames the post as a reminder that **model quality can regress** and that the template's verification patterns (`/verify-claims` with forked verifier, `/audit-reproducibility` with `passport.yaml`, cross-artifact review, HIGH-WARN gate-refuse, `/review-paper --variance N`) all assume drift rather than treating any specific checkpoint as a stable baseline.

#### Verification — Pass 5 (and final v1.9.0)

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts at release: **36 skills / 16 agents / 26 rules / 6 hooks**
- `./scripts/check-skill-integrity.py` — all checks pass
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Release summary

| Pass | PR | Net additions to disk | What it shipped |
|---:|---:|---|---|
| 1 | #114 | 0 | Mechanical guide refresh, Anthropic Apr–May 2026 catch-up, clo-author v26.05 citation, Models / API TROUBLESHOOTING section |
| 2A | #115 | 0 | Poli-sci breadth woven into guide body, Cost-Conscious Composition subsection |
| 2B | #116 | 0 | Pattern 16: Preregistration and Submission Discipline |
| 2C | #117 | 0 | `/review-paper --variance N` reviewer-disposition variance mode |
| 2D | #118 | +1 skill, +1 agent | `/humanize` detect-and-flag for AI-voice tells |
| 3A | #119 | +2 skills, +1 template | `passport.yaml` claims provenance, HIGH-WARN claim-faithfulness gate, `/prompt` + `/prompt-only` port from Blattman |
| 3B | #120 | +2 skills, +1 agent, +1 rule | Model-routing rule (70/20/10), `/compress-session`, `/promote-memory` five-critic council |
| 4 | #121 | +1 skill, +1 rule | Stata expansion: `/stata-replication`, `stata-code-conventions.md`, `audit-reproducibility` source-language coverage, stata-mcp ecosystem entry |
| 5 | (this PR) | 0 | Apr 23 Anthropic post citation in verification section; closes SDK-credit awareness loop |

**Total v1.9.0 additions:** 6 skills, 2 agents, 2 rules, 1 reference, 1 template. No breaking changes. All count-bearing surfaces verified in sync. Provenance: every addition traceable to the research-grounded plan at `quality_reports/plans/2026-05-20_v1.9.0-guide-refresh.md` (local-only).

---

## v1.8.0 — 2026-04-27

A **disciplinary breadth + audit-hardening + Apr 2026 incorporation** minor release. The cycle landed in two passes: (1) infrastructure-only audit-hardening (mechanical parity checks via `check-skill-integrity.py`, living pet-peeves catalogue, PreCompact blocking, Routines awareness) and (2) capability work (two new skills `/checkpoint` and `/preregister`, political-science breadth via three journal profiles + two paper types + a discipline-cards reference, and Apr 2026 documentation: auto mode promotion, protected-paths gate explainer, session-management commands, Computer Use sidebar, Monitor tool integration, `disable-model-invocation` discipline). No breaking changes; counts updated across all monitored surfaces.

### Added — new skills

- **`.claude/skills/checkpoint/`** — `/checkpoint` produces a structured state snapshot (active plan, recent decisions, file pointers with line numbers, open questions, next 1–3 actions) into `quality_reports/checkpoints/YYYY-MM-DD_<slug>.md`. Companion to (NOT replacement for) the narrative session-log workflow under `quality_reports/session_logs/`. Carries `disable-model-invocation: true` (writes to a persistent state file — must be user-intent). Pattern adapted from Hugo Sant'Anna's [clo-author v4.2.0](https://github.com/hugosantanna/clo-author) with permission; reimplemented in original prose against this template's narrative-session-log + plan-on-disk + auto-memory architecture. Attribution header on the SKILL.md.
- **`.claude/skills/preregister/`** + **`templates/preregistration-template.md`** — `/preregister` drafts a registry-ready preregistration document in OSF, AsPredicted, or AEA RCT Registry style. Extracts hypotheses, design, sampling plan, exclusions, and analysis plan from a research spec (`/interview-me` output) or free-form description. MUST/SHOULD/MAY clarity annotation per section. Pre-flight cross-checks: directional hypothesis, named estimator, ex-ante exclusion rules, sample-size stopping rule. Post-flight CoVe verification of any cited literature (re-uses `/verify-claims`). Output: `quality_reports/preregistrations/YYYY-MM-DD_<slug>.md` (gitignored). Refuses retrospective preregistration (description containing realised results). Greenfield — not ported.

### Added — political-science breadth

- **`.claude/references/journal-profiles.md`** +3 profiles: **APSR** (highest theoretical bar; THEORY-disposition pool weight 0.30; methods-referee tilts toward formal-theory comparative-static sharpness), **AJPS** (methods-emphasis; CREDIBILITY 0.30, replication policy enforced), **JOP** (clarity-of-contribution bar; SKEPTIC 0.25). Each profile is ~40–45 lines following the existing schema.
- **`.claude/agents/methods-referee.md`** +2 paper types: **`formal-theory`** (pure theory; weights tilt toward model originality and comparative-static sharpness; sanity checks include equilibrium existence, assumption tractability, robustness to assumption relaxation) and **`survey-experiment`** (vignette/conjoint/list/factorial; weights tilt toward design, sampling, and attrition+manipulation checks; sanity checks include balance, manipulation-check pass rate, attrition asymmetry, sampling-frame validity). The 4 prior paper types (reduced-form / structural / theory+empirics / descriptive) are unchanged — additions are purely additive.
- **`.claude/agents/domain-reviewer.md`** template-marker comment now ships **two** customization examples (econ + poli-sci) to illustrate that the 5-lens structure is field-agnostic. Lens content under each example reflects field-specific norms (poli-sci: ignorability, conjoint AMCE algebra, Hainmueller-Hopkins-Yamamoto for cross-reference, `cjoint`/`survey::svyglm` package defaults).
- **`.claude/references/discipline-cards.md`** — new reference. Two cards: `econ` and `poli-sci`. Each card: paper-type frequency table, dominant journals (cross-referenced to `journal-profiles.md`), preregistration norms (cross-referenced to `/preregister --style`), method conventions (significance-stars conventions, SE conventions, dominant code language). Read by `/research-ideation`, `/interview-me`, `/preregister`, and the `editor` agent when paper-type or discipline is given without a target journal. Forkers extend for psych / sociology / public-health / etc.

### Changed — research-side skill paper-type awareness

- **`.claude/skills/research-ideation/SKILL.md`** — new Step 3 tags each generated RQ with a likely paper type from the 6-type taxonomy. Output format adds a `**Paper type:**` field per RQ. `discipline-cards.md` informs the default distribution.
- **`.claude/skills/interview-me/SKILL.md`** — Phase 1 ("Big Picture") now optionally asks the researcher what kind of paper they envision (same 6-type taxonomy). Saved to spec frontmatter as `paper_type:` so downstream skills (`/preregister`, `/data-analysis`, `/review-paper --peer`) can read it.

### Added — Apr 2026 feature documentation

- **`TROUBLESHOOTING.md`** +2 sections under Permissions:
  - **Bypass mode still prompts on protected paths** — explains the protected-path list (`.git`, `.vscode`, `.idea`, `.husky`, `.claude` with carve-outs for `commands/agents/skills/worktrees`) and that **auto mode** is the only mode that routes protected paths through the classifier instead of prompting. Documents the auto-mode requirements (Max/Team/Enterprise/API + Sonnet 4.6 / Opus 4.6 / Opus 4.7 + Anthropic API). Includes two workarounds for users without auto-mode access: edit through Bash (`python3` heredoc) or move edits out of `.claude/`.
  - **`.vscode/settings.json` key typo** — `claudeCode.allowDangerouslySkipPermissions` is silently ignored; the canonical key is `allowDangerouslySkipPermissions` (no `claudeCode.` prefix). The typo leaves the protected-paths gate active even with broad CLI bypass. Reload window after fixing.
- **`.vscode/settings.json`** — fixed the typo: `allowDangerouslySkipPermissions: true` (was incorrectly prefixed). Takes effect on next VSCode window reload.

### Changed — `disable-model-invocation` audit

- **`.claude/skills/create-lecture/`**, **`.claude/skills/new-diagram/`**, **`.claude/skills/learn/`** — added `disable-model-invocation: true` to frontmatter. Rationale: each writes a load-bearing persistent file (a new lecture `.tex`, a new TikZ source, a new SKILL.md respectively) that should only be created on explicit user intent. `/deep-audit` also gains the flag in this release (its body writes audit reports + applies fixes). The new `/checkpoint` and `/preregister` skills carry the flag too.

### Added — Apr 2026 doc additions (guide + onboarding)

- **`guide/workflow-guide.qmd`** — new `### Session Management` subsection under "Settings — Permissions and Hooks": `/btw` for side questions outside conversation history, `/rewind` and `Esc+Esc` for checkpoint navigation, `/clear` and `/compact <instruction>` for context resets, `Ctrl+G` for in-editor plan editing, `claude --continue` / `--resume` / `/rename` for cross-session continuity, plus `/checkpoint <slug>` (this template). Three composition patterns documented.
- **`guide/workflow-guide.qmd`** — added `auto` mode row to the permission-modes table; documented bypass mode's protected-path gate inline (`.git`, `.vscode`, `.idea`, `.husky`, `.claude` minus `commands/agents/skills/worktrees` carve-outs).
- **`guide/workflow-guide.qmd`** — Computer Use callout in the Adversarial Pattern section (Apr 2026 Week 14, research preview, optional). Frames Computer Use as the *visual loop* extension when text-level `/qa-quarto` and `/visual-audit` aren't enough.
- **`guide/workflow-guide.qmd`** — Monitor-tool subsection in "Cost-Conscious Parallelism" (Apr 2026 Week 15). Replaces polling-loop anti-pattern for long-running R fits, replication batch reruns, etc.
- **`guide/workflow-guide.qmd`** — new "Anthropic-Shipped Apr 2026 Utilities" section in the ecosystem area: `/team-onboarding`, `/autofix-pr`, `/powerup`, Ultraplan, `/fewer-permission-prompts`. Framed as off-ramps when this template's scope doesn't fit.
- **`README.md`** — Quick Start callout pointing forkers heavily diverging from academic content at Anthropic's `/init` to re-derive `CLAUDE.md`.
- **`templates/skill-template.md`** — new "When to set `disable-model-invocation: true`" subsection codifying the rule (write-load-bearing-persistent-file → set the flag) and the new "CLAUDE.md `@import` syntax" subsection documenting the Anthropic Apr 2026 import feature, with explicit guidance that this template's CLAUDE.md deliberately does NOT use it (under-150-line CLAUDE.md is better monolithic).
- **`.claude/skills/data-analysis/SKILL.md`**, **`.claude/skills/audit-reproducibility/SKILL.md`** — new "Long-running fits / batch reruns: use the Monitor tool" subsections. Document the background-launch + Monitor pattern for jobs that take more than a couple of minutes.

### Surface-sync

- Skills 28 → 30 (`/checkpoint`, `/preregister`). Agents unchanged at 14. Rules unchanged at 24. Hooks unchanged at 6. Counts updated across all 6 monitored surfaces (README, CLAUDE.md, guide `.qmd` + rendered `.html`, `docs/index.html`, `docs/workflow-guide.html`, `templates/skill-template.md`). `scripts/check-surface-sync.sh` clean; `scripts/check-skill-integrity.py` clean. Guide re-rendered with Quarto 1.8.x; `docs/workflow-guide.html` synced.

### Attribution

`/checkpoint` shape: adapted from Hugo Sant'Anna's [clo-author v4.2.0](https://github.com/hugosantanna/clo-author) with permission. Attribution header on `.claude/skills/checkpoint/SKILL.md`.

---

### Pre-v1.8.0 infrastructure (folded into this release)

Two themes that landed in the working tree before the v1.8.0 capability work: audit-hardening (mechanical parity checks + living pet-peeves catalogue that close classes of bug the agent-based `/deep-audit` was missing) and selective incorporation of Claude Code Apr 2026 features (Routines for AFK scheduling, PreCompact blocking, `/fewer-permission-prompts` as a sibling to our `/permission-check`).

### Added — mechanical integrity checks

- **`scripts/check-skill-integrity.py`** — deterministic parity checks that run in under a second. Four checks: (1) frontmatter `allowed-tools` ↔ body tool-invocation parity — catches the v1.7.0 PR #92 class of bug where 4 skills promised `Task` in their body but had no `Task` permission; (2) `argument-hint` ↔ body flag parity — documented flags advertised in the one-line hint; (3) internal markdown anchor resolution — no broken `[text](path#anchor)` links (the `#category-11-numerical-discipline` miss on PR #87); (4) rule `paths:` ↔ skill implementation parity — rule claims skill follows protocol, so skill body must reference the protocol's keywords (the `/interview-me` miss on PR #92).
- **`scripts/check-surface-sync.sh`** now runs both `check-surface-sync.py` (count assertions) and `check-skill-integrity.py` (parity). Either gate failing blocks `/commit` Step 0b.
- **`.claude/skills/slide-excellence/SKILL.md`** `argument-hint` updated to advertise `--fast`, `--skip-substance`, `--acknowledge-template-domain-reviewer` — the first real P2 the new check caught on baseline.

### Added — living pet-peeves catalogue

- **`.claude/references/audit-pet-peeves.md`** — 12-entry seed document cataloguing classes of bug review bots (Copilot / Codex) have caught on recent PRs that `/deep-audit` missed. Each entry: example + how to catch + why deep-audit missed it + when to apply. Grows with each PR — the meta-fix for the "audit agents keep missing this one thing" pattern.
- **`.claude/skills/deep-audit/SKILL.md`** now has a Phase 0 that runs the mechanical checks first (cheapest, most precise), and every agent in Phase 1 is instructed to read the pet-peeves file before reporting clean.

### Changed — documentation

- MEMORY.md `[LEARN:audit]` entry on the mechanical-vs-agent tradeoff (catch classes of bug where precision matters with deterministic checks; use agents for judgment calls).
- TROUBLESHOOTING.md section for `check-skill-integrity` failures — what each P0/P1/P2 means, how to resolve or tune.

### Fixed

- Self-referential false positive in the pet-peeves doc: example `[text](path#anchor)` markdown inside prose was matched by the anchor-resolution check. Script now strips inline code spans and fenced code blocks before scanning, so illustrative examples don't trigger the check.

### Added — Apr 2026 Claude Code incorporation

- **PreCompact hook can now block compaction** (`.claude/hooks/pre-compact.py`). Opt-in via env var `CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT=1`: blocks once per DRAFT plan so the user can approve before losing mid-plan context. Uses the modern Claude Code block protocol (exit 0 + JSON `{"decision":"block","reason":"..."}` on stdout). Fires at most once per plan path — no lock-out loops. Default off; existing users get no change.
- **MEMORY.md `[LEARN:scheduling]` + `[LEARN:hooks]`** capturing two lessons from Apr 2026: (a) `CronCreate` is session-only in practice — use Claude Code Routines (launched Apr 14) for any autonomous work that must survive session termination; (b) PreCompact hooks can now block, which is the right primitive for "don't lose this context."
- **`.claude/references/audit-pet-peeves.md` entry 17** — don't use `CronCreate` for long-delay autonomous work; Routines is the right primitive.
- **TROUBLESHOOTING.md scheduling section** — explains `CronCreate` vs Routines tradeoff (short-delay in-session vs AFK work on web infra) and documents the PreCompact blocking guard. Plus a pointer to the built-in `/fewer-permission-prompts` skill as a sibling to our `/permission-check` (diagnose with `/permission-check`, remediate with `/fewer-permission-prompts`).

No stale model references audited — all 14 agents already use `model: inherit`, so they auto-adapt to Opus 4.7 / Sonnet 4.6 / Haiku 4.5 without changes.

---

## v1.7.0 — 2026-04-16

A **discipline-patterns** minor release. Additive infrastructure for anti-drift (summary-parity) and anti-hallucination (Post-Flight Verification / Chain-of-Verification). Full details below; no breaking changes for forks.

### Added — Post-Flight Verification (Chain-of-Verification)

Mirror of v1.6.0's Pre-Flight Reports, at the output side. Where Pre-Flight proves inputs were read before work, Post-Flight proves factual claims hold after drafting — before the skill returns to the user. Adapted from **Dhuliawala et al. 2023, "Chain-of-Verification Reduces Hallucination in Large Language Models" ([arXiv:2309.11495](https://arxiv.org/abs/2309.11495))**. The core CoVe idea — answer verification questions in a context that does NOT contain the original draft — is architecturally enforced here via `context: fork` on the verifier agent.

- **`.claude/rules/post-flight-verification.md`** — new path-scoped rule. Defines the 4-step CoVe protocol (draft → extract claims → generate verification questions → answer independently in fresh context → reconcile). Scoped to skills that generate factual claims. Fail-closed: if the verifier errors or times out, the draft is surfaced as provisional rather than shipped silently. Opt-out via `--no-verify`.
- **`.claude/agents/claim-verifier.md`** — new forked agent. Never sees the draft (enforced by `context: fork` at the Task boundary). Receives only: claims, verification questions, source-material pointers. Uses `Read`, `Grep`, `Glob`, `WebFetch`, `WebSearch`, `Bash`. Returns a structured verification report (PASS / PARTIAL / FAIL per claim, with evidence quotes + source locations).
- **`.claude/skills/verify-claims/`** — new user-facing skill. Runs Post-Flight on any draft the user hands to it (a `.md`, `.qmd`, `.tex`, `.txt` file). Accepts `--source <path-or-url>` to point at source material. Callable directly by users or spawned by other skills via `Task`.
- **Four skill integrations** — `/lit-review`, `/research-ideation`, `/respond-to-referees`, `/review-paper` (novelty probe in `--peer` mode). Each now runs Post-Flight internally before returning. Skip conditions documented per skill (e.g., `--no-verify`, user pre-verifies).

Rationale: `/lit-review` citations from WebSearch were hallucination-prone (already flagged in SKILL.md); `/research-ideation` negative-literature claims (e.g., "no prior work studies X") and dataset-structure claims are classic hallucination vectors; `/respond-to-referees` "we added X on page Y" claims can be wrong or out-of-date after revision; `/review-paper --peer` editor novelty probe depends on WebSearch.

### Added — anti–whack-a-mole rule (from earlier in v1.7.0 cycle)

- **`.claude/rules/summary-parity.md`** — path-scoped rule preventing surgical word-level fixes on summary paragraphs from introducing new drift elsewhere in the same paragraph. Triggers on CHANGELOG ledes, README taglines, PR `## Summary` blocks, skill/rule/agent frontmatter `description` fields, guide section abstracts, MEMORY.md `[LEARN]` headlines. Core heuristic: two review-bot flags on the same paragraph = rewrite structurally (abstract up), don't patch. Motivated by 3 consecutive Copilot findings on the v1.6.1 CHANGELOG opening (PRs #88–#90), each surgical fix introducing a new drift elsewhere.

### Added — audit learnings

- **`MEMORY.md`** new `[LEARN:audit]` entries capturing the whack-a-mole anti-pattern (summary-parity) and the CoVe vs critic-fixer vs cross-artifact distinction (three complementary verification mechanisms at three different architectural levels). Future sessions inherit both lessons on fresh context.

### Added — guide coverage

- `/verify-claims` and the new `claim-verifier` agent added to the guide's "All Skills" / "All Agents" tables. `post-flight-verification.md` and `summary-parity.md` added to "All Rules." Pre-existing gap in the rules table closed as well: `content-invariants.md` and `cross-artifact-review.md` were on disk but missing from the table; now listed. Path-scoped rule callout updated (16 → 20 path-scoped rules total).

### Changed — counts

- Skills 27 → 28 (`/verify-claims`). Agents 13 → 14 (`claim-verifier`). Rules 22 → 24 (`summary-parity.md` + `post-flight-verification.md`). Hooks unchanged at 6. Surface-sync gate propagates the new counts across all 6 monitored surfaces (README, CLAUDE.md, guide `.qmd` + `.html`, `docs/index.html`, `docs/workflow-guide.html`, `templates/skill-template.md`, `/commit` SKILL internal example).

### Changed — drift-proofing the v1.6.1 CHANGELOG lede (applied the new summary-parity rule)

- Rewrote the v1.6.1 opening paragraph abstraction-first ("No breaking changes. No new directories were added to `.claude/`; existing infrastructure was revised …"). First test of the new summary-parity rule on an existing entry. GitHub release notes for v1.6.1 synced to match.

### Governance note

v1.7.0 establishes the **discipline-pattern trilogy**:

1. **v1.6.0 Pre-Flight** (input discipline) — inputs were read before work.
2. **v1.6.1 summary-parity** (framing discipline) — summaries don't drift from bodies.
3. **v1.7.0 Post-Flight** (output discipline) — factual claims hold before work ships.

All three share a shape: **fail-closed, structured output block, honest fallbacks**. All three address classes of bugs a human reviewer would catch but the agent loop should catch earlier.

---

## v1.6.1 — 2026-04-16

A **framing honesty + hook friction** patch release. No breaking changes. No new directories were added to `.claude/`; existing infrastructure was revised to address two classes of issue surfaced by a multi-round audit:

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

To pin to a specific version: `git checkout v1.8.0` (latest as of 2026-04-27).
