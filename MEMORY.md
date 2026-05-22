# Project Memory

Corrections and learned facts that persist across sessions.
When a mistake is corrected, append a `[LEARN:category]` entry below.

---

<!-- Append new entries below. Most recent at bottom. -->

## Workflow Patterns

[LEARN:workflow] Requirements specification phase catches ambiguity before planning → reduces rework 30-50%. Use spec-then-plan for complex/ambiguous tasks (>1 hour or >3 files).

[LEARN:workflow] Spec-then-plan protocol: AskUserQuestion (3-5 questions) → create `quality_reports/specs/YYYY-MM-DD_description.md` with MUST/SHOULD/MAY requirements → declare clarity status (CLEAR/ASSUMED/BLOCKED) → get approval → then draft plan.

[LEARN:workflow] Context survival before compression: (1) Update MEMORY.md with [LEARN] entries, (2) Ensure session log current (last 10 min), (3) Active plan saved to disk, (4) Open questions documented. The pre-compact hook displays checklist.

[LEARN:workflow] Plans, specs, and session logs must live on disk (not just in conversation) to survive compression and session boundaries. Quality reports only at merge time.

## Documentation Standards

[LEARN:documentation] When adding new features, update BOTH README and guide immediately to prevent documentation drift. Stale docs break user trust.

[LEARN:documentation] Always document new templates in README's "What's Included" section with purpose description. Template inventory must be complete and accurate.

[LEARN:documentation] Guide must be generic (framework-oriented) not prescriptive. Provide templates with examples for multiple workflows (LaTeX, R, Python, Jupyter), let users customize. No "thou shalt" rules.

[LEARN:documentation] Date fields in frontmatter and README must reflect latest significant changes. Users check dates to assess currency.

## Design Philosophy

[LEARN:design] Framework-oriented > Prescriptive rules. Constitutional governance works as a TEMPLATE with examples users customize to their domain. Same for requirements specs.

[LEARN:design] Quality standard for guide additions: useful + pedagogically strong + drives usage + leaves great impression + improves upon starting fresh + no redundancy + not slow. All 7 criteria must hold.

[LEARN:design] Generic means working for any academic workflow: pure LaTeX (no Quarto), pure R (no LaTeX), Python/Jupyter, any domain (not just econometrics). Test recommendations across use cases.

## File Organization

[LEARN:files] Specifications go in `quality_reports/specs/YYYY-MM-DD_description.md`, not scattered in root or other directories. Maintains structure.

[LEARN:files] Templates belong in `templates/` directory with descriptive names. Currently have: session-log.md, quality-report.md, exploration-readme.md, archive-readme.md, requirements-spec.md, constitutional-governance.md, decision-record.md (v1.6.0), journal-profile-template.md (v1.5.0), response-to-referees.md, skill-template.md, plus `tikz-snippets/` directory.

## Constitutional Governance

[LEARN:governance] Constitutional articles distinguish immutable principles (non-negotiable for quality/reproducibility) from flexible user preferences. Keep to 3-7 articles max.

[LEARN:governance] Example articles: Primary Artifact (which file is authoritative), Plan-First Threshold (when to plan), Quality Gate (minimum score), Verification Standard (what must pass), File Organization (where files live).

[LEARN:governance] Amendment process: Ask user if deviating from article is "amending Article X (permanent)" or "overriding for this task (one-time exception)". Preserves institutional memory.

## Skill Creation

[LEARN:skills] Effective skill descriptions use trigger phrases users actually say: "check citations", "format results", "validate protocol" → Claude knows when to load skill.

[LEARN:skills] Skills need 3 sections minimum: Instructions (step-by-step), Examples (concrete scenarios), Troubleshooting (common errors) → users can debug independently.

[LEARN:skills] Domain-specific examples beat generic ones: citation checker (psychology), protocol validator (biology), regression formatter (economics) → shows adaptability.

## Memory System

[LEARN:memory] Two-tier memory solves template vs working project tension: MEMORY.md (generic patterns, committed), personal-memory.md (machine-specific, gitignored) → cross-machine sync + local privacy.

[LEARN:memory] Post-merge hooks prompt reflection, don't auto-append → user maintains control while building habit.

## Meta-Governance

[LEARN:meta] Repository dual nature requires explicit governance: what's generic (commit) vs specific (gitignore) → prevents template pollution.

[LEARN:meta] Dogfooding principles must be enforced: plan-first, spec-then-plan, quality gates, session logs → we follow our own guide.

[LEARN:meta] Template development work (building infrastructure, docs) doesn't create session logs in quality_reports/ → those are for user work (slides, analysis), not meta-work. Keeps template clean for users who fork.

## Drift Prevention

[LEARN:drift] `replace_all` on one phrasing (e.g., `"26 skills"`) misses sibling phrasings — `"26 skills, and 21 rules"` (extra "and"), `"26 slash commands"`, `"template's 26"`, `"N skills on day one"` (prose). Count drift hit us 3 times in v1.5.x (PRs #70, #76, #78). Solution: `scripts/check-surface-sync.py` with compound regex patterns as a pre-commit gate. Adding a new phrasing to documentation requires adding a matching regex to the script, otherwise it won't be caught.

[LEARN:drift] Guard against false positives when scanning for template counts: `"3 parallel agents"`, `"17 specialized agents"` (clo-author attribution), `"start with 2-3 skills"` are all legitimate non-template uses of `N + category` phrases. Use compound patterns requiring multiple template-specific tokens on the same line.

## Claude Code Hooks

[LEARN:hooks] Stop-hook block protocol has TWO valid forms: (a) legacy — `exit 2` + reason on stderr; (b) modern — `exit 0` + JSON `{"decision":"block","reason":"..."}` on stdout. `log-reminder.py` uses the modern form. Audit agents unfamiliar with the modern protocol will flag this as "should exit 2" — false alarm. Documented in `/deep-audit` skill's false-alarm list.

[LEARN:hooks] `initialPermissionMode` in VSCode settings only fires at **session start**. Mid-session mode toggles (via `Shift+Tab` or `/permission-mode`) override the file settings until session end. The 6-tier permission stack: VSCode user / workspace / CLI user / project / project-local / in-session runtime — the last is authoritative. "Prompts fire despite bypass config" is almost always a stale session, not a settings bug.

## Plan→Bypass Framing

[LEARN:safety] Do NOT frame Plan→Bypass as a "safety boundary" or "safety guarantee." Plan approval gives you a chance to review the APPROACH before execution, but exiting plan mode returns the session to `defaultMode` (bypassPermissions), at which point any tool call runs under the full allowlist. Frame as "review-before-execute convenience." If a user needs a real enforcement boundary, they should keep `defaultMode: "default"` and approve each high-risk tool individually.

## Privacy in Diagnostic Skills

[LEARN:privacy] Diagnostic skills that read host-global config (e.g., `~/.claude/`, VSCode user settings) must require **explicit user confirmation** before crossing the repo boundary — especially in template repos that get forked. Phase the skill: repo-local auto, host-global opt-in with key redaction. Codex correctly flagged this pattern as a template-adopter privacy risk in PR #75.

## Claim-vs-Reality Framing

[LEARN:framing] The "orchestrator" is a **pattern** implemented by specific skills (`/commit`, `/qa-quarto`, `/review-paper --adversarial`, `/slide-excellence`, `/create-lecture`, `/data-analysis`, `/review-paper --peer`), not a runtime daemon. Plan approval does NOT auto-trigger the 6-step loop. User invokes a skill; skill runs the loop internally. Docs that say "orchestrator activates automatically after plan approval" are misleading — catch them in review.

[LEARN:framing] "Quality gates" is overselling when the only enforcement is inside `/commit` skill (halt-and-ask, not block). A direct `git commit` bypasses the review. Use "quality review" in docs or add an "(advisory)" qualifier. Hard enforcement requires an actual git pre-commit hook — document the gap honestly.

[LEARN:framing] Cross-artifact review is **pattern-based detection**, not universal auto-invocation. If the manuscript has no `\input{scripts/...}` signals, no cross-artifact work happens even without `--no-cross-artifact`. Document detection signals explicitly.

## Dogfooding Gaps Found in Round-1 Audit (2026-04-16)

[LEARN:dogfooding] Empty `quality_reports/plans/`, `specs/`, `session_logs/` directories are a red flag — they mean the repo claims to enforce dogfooding rules that nobody is following. Stop hook on `log-reminder.py` did catch the missing session log this session, which validates the hook's value. Plan-first has no equivalent automation.

[LEARN:audit] "Claim-vs-reality" is the highest-ROI audit lens for a governance-heavy template repo. More valuable than skill-consistency or doc-drift checks because it surfaces where the template oversells itself — the exact thing forkers will discover and call out.

[LEARN:audit] Whack-a-mole anti-pattern on summary paragraphs: when Copilot/Codex flag a summary paragraph, surgically fixing the flagged phrase almost always introduces a new drift elsewhere in the same paragraph (observed 3× in a row on the v1.6.1 CHANGELOG opening, PRs #88–#90). Rule: two review-bot flags on the same paragraph = rewrite structurally (abstract up, remove enumeration), don't patch word-by-word. Prefer "no new directories on disk" over "no new skills, rules, or hooks." See `.claude/rules/summary-parity.md`.

## Verification Architecture (three complementary patterns)

[LEARN:pattern] Verification in this repo now operates at three architectural levels, each addressing a different failure mode. Do NOT collapse them — they are complementary, not redundant:

1. **Critic-fixer loop** (`/qa-quarto`, `/review-paper --adversarial`) — **two agents, serial** — one reads the artifact and flags issues, the other applies fixes; loop until APPROVED. Best for **presentation + structural** bugs (Beamer↔Quarto parity, manuscript completeness). Agents see the full artifact; adversarial tension comes from role assignment.

2. **Cross-artifact review** (`/review-paper` + `/review-r` + `/audit-reproducibility`) — **horizontal dependency traversal** — a manuscript's claims depend on scripts' outputs, so the manuscript reviewer spawns script reviewers and reproducibility checkers alongside the paper review. Best for **paper ↔ code consistency** (ATTs, coefficients, N match the outputs that produced them).

3. **Post-Flight Verification / CoVe** (`/verify-claims` + `claim-verifier` agent, v1.7.0) — **single agent, fresh-context fork** — the verifier has never seen the draft; it answers verification questions from the source material alone, using `context: fork` to architecturally enforce independence. Best for **factual hallucination** (fabricated citations, wrong dataset fields, misattributed findings). Adapted from Dhuliawala et al. 2023 ([arXiv:2309.11495](https://arxiv.org/abs/2309.11495)).

The key insight: each pattern enforces independence differently. Critic-fixer uses role tension; cross-artifact uses dependency graph traversal; CoVe uses context isolation. A skill that needs all three (e.g., `/review-paper --peer`) invokes them at different phases.

[LEARN:pattern] Post-Flight Reports (v1.7.0) are the output-side twin of Pre-Flight Reports (v1.6.0). Pre-Flight proves inputs were read; Post-Flight proves claims hold. Both use structured output blocks, fail-closed fallbacks, and explicit opt-outs. Together with summary-parity (v1.6.1), they form the **discipline-pattern trilogy**: input discipline + framing discipline + output discipline. When designing a new skill that generates text, ask: does it need all three?

[LEARN:audit] Skill frontmatter `allowed-tools` must cover every tool the skill body invokes, but this is easy to miss — the body reads as English ("spawn the verifier via Task") while the frontmatter reads as a bureaucratic array. Caught on PR #92 when Codex + Copilot both flagged 4 skills that promised `Task` in the body but had no `Task` in `allowed-tools`. Runtime failure mode: tool-permission error, or silent bypass of the promised protocol. Deep-audit Agent 3 now includes this check explicitly. Sibling check: if rule X's `paths:` includes skill Y, confirm skill Y actually implements rule X's protocol (rule-vs-implementation drift is the same class of bug at a different layer).

[LEARN:audit] Mechanical vs agent-based audits: classes of bug that are deterministic (frontmatter field exists, anchor resolves, count matches disk) belong in a mechanical script, not an agent prompt. Agents miss these because the prompt lists them as one of many checks, and agent attention drifts. The script never drifts. Reserve audit agents for judgment calls (is this claim misleading? does this rule contradict that one?). `scripts/check-skill-integrity.py` shipped the first batch (frontmatter↔body tool parity, argument-hint↔body flag parity, anchor resolution, rule↔skill keyword parity). `.claude/references/audit-pet-peeves.md` catalogues the subtler classes that still need agent judgment so /deep-audit agents inherit past bot findings.

[LEARN:audit] When writing a parity-check regex, always strip inline code spans (` `` `) and fenced code blocks (` ``` `) before pattern-matching. Docs use example syntax like `[text](path#anchor)` inside backticks to illustrate; a naive regex treats those as real links. Replace matched code with spaces (preserving line numbers) before running the rest of the check.

[LEARN:audit] Audit-scope creep — or rather, audit-scope ATROPHY. Deep-audit Agent 2 was scoped to `.claude/hooks/*.py|sh`. When PR #93 added new Python + bash code under `scripts/`, the audit didn't look. Copilot + Codex caught 6 bugs the audit missed, all five of which were in `scripts/`. Root cause: audit agents only check what their prompt scopes; any new directory bypasses audit by default. **Rule: when adding a new code location, expand audit scope first, or audit-debt accumulates silently.** Agent 2 now scoped to all executable code (hooks + scripts + .claude/scripts). Pet-peeves entries 13-16 capture the specific classes that motivated this widening (docstring-contract drift, fail-open narrow-except, bash set-u not enough, dead config-map entries).

## Scheduling Autonomous Work

[LEARN:scheduling] `CronCreate` (the local Claude Code cron) is **session-only** in practice even with `durable: true` — it dies if the Claude Code REPL isn't running when the cron time arrives. Hit this on 2026-04-16 when the user's usage got rate-limited, the session terminated, and the scheduled audit-hardening trigger never fired. For any autonomous work that must survive session termination (rate limits, Claude Code restarts, sleep), use **Claude Code Routines** (released Apr 14, 2026) instead — they run on Anthropic's web infrastructure, not the local REPL. `CronCreate` is fine for short-delay polling within an active session (check a build every 5 min), but not for "run this in an hour." See `.claude/references/audit-pet-peeves.md` entry 17.

[LEARN:hooks] PreCompact hooks now support blocking via the modern protocol (exit 0 + `{"decision":"block","reason":"..."}` on stdout). `.claude/hooks/pre-compact.py` gained an opt-in DRAFT-plan guard (env var `CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT=1`): blocks compaction once when an active plan is still marked DRAFT, so the user has a chance to approve the plan before losing mid-plan context. Default off — users who prefer the old save-and-continue behavior get no change. Fires at most once per plan to avoid lock-out loops.
