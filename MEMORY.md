# Project Memory

Corrections and learned facts that persist across sessions.
When a mistake is corrected, append a `[LEARN:category]` entry below; most recent at bottom.

---

## Workflow Patterns

[LEARN:workflow] Requirements specification catches ambiguity before planning → reduces rework 30-50%. Spec-then-plan for complex/ambiguous tasks (>1 hour or >3 files): AskUserQuestion (3-5 questions) → `quality_reports/specs/YYYY-MM-DD_description.md` (not scattered in root — keeps structure) with MUST/SHOULD/MAY requirements → clarity status (CLEAR/ASSUMED/BLOCKED) → approval → then draft plan.

[LEARN:workflow] Plans, specs, and session logs must live on disk (not just in conversation) to survive compression and session boundaries; quality reports only at merge time. Context survival before compression: (1) Update MEMORY.md with [LEARN] entries, (2) Ensure session log current (last 10 min), (3) Active plan saved to disk, (4) Open questions documented. The pre-compact hook displays checklist. *[2026-09-26: now silent; restores only what's on disk.]*

## Documentation Standards

[LEARN:documentation] When adding new features, update BOTH README and guide immediately to prevent documentation drift — stale docs break user trust. Document new templates in README's "What's Included" with their purpose; the inventory must be complete and accurate.

[LEARN:documentation] Date fields in frontmatter and README must reflect latest significant changes. Users check dates to assess currency.

## Design Philosophy

[LEARN:design] Framework-oriented > Prescriptive rules: constitutional governance and requirements specs work as TEMPLATES with examples users customize to their domain. Quality standard for guide additions: useful + pedagogically strong + drives usage + leaves great impression + improves upon starting fresh + no redundancy + not slow — all 7 must hold.

[LEARN:design] Generic means working for any academic workflow: pure LaTeX (no Quarto), pure R (no LaTeX), Python/Jupyter, any domain (not just econometrics) — guide stays framework-oriented: templates users customize, no "thou shalt" rules. Test recommendations across use cases.

## File Organization

[LEARN:files] Templates belong in `templates/` with descriptive names. Don't enumerate the inventory here — a hand-kept list goes stale (this entry's own list was missing three files when audited); `ls templates/` is the inventory.

## Constitutional Governance

[LEARN:governance] Constitutional articles distinguish immutable principles (non-negotiable for quality/reproducibility) from flexible user preferences; keep to 3-7 articles. Examples: Primary Artifact (which file is authoritative), Plan-First Threshold (when to plan), Quality Gate (minimum score), Verification Standard (what must pass), File Organization (where files live). Amendments: ask the user whether deviating from article is "amending Article X (permanent)" or "overriding for this task (one-time exception)". Preserves institutional memory.

## Skill Creation

[LEARN:skills] Effective skill descriptions use trigger phrases users actually say ("check citations", "format results", "validate protocol") → Claude knows when to load skill. Skills need 3 sections minimum: Instructions (step-by-step), Examples (concrete scenarios), Troubleshooting (common errors) → users can debug independently. Domain-specific examples beat generic ones (citation checker — psychology; protocol validator — biology; regression formatter — economics) — they show adaptability. *[2026-09-26: name situations, not synonyms; state outcome, constraints, checks.]*

## Memory System

[LEARN:memory] Two-tier memory solves template vs working project tension: MEMORY.md (generic patterns, committed) + native auto memory (`~/.claude/projects/<project>/memory/`, machine-local) → cross-machine sync + local privacy. *(Second tier was `personal-memory.md` until v2.5; retired for the native mechanism.)*

[LEARN:memory] Hooks prompt reflection, don't auto-append (e.g. the Stop-hook session-log reminder) → user maintains control while building habit.

## Meta-Governance

[LEARN:meta] Repository dual nature requires explicit governance: what's generic (commit) vs specific (gitignore) → prevents template pollution. Dogfooding principles must be enforced: plan-first, spec-then-plan, quality gates, session logs → we follow our own guide. Template work (infrastructure, docs) skipped session logs — those were for user work (slides, analysis), keeping forks clean. *[Superseded 2026-09-26: logs are gitignored; a Stop hook writes them.]*

## Drift Prevention

[LEARN:drift] `replace_all` on one phrasing (e.g., `"26 skills"`) misses sibling phrasings — `"26 skills, and 21 rules"` (extra "and"), `"26 slash commands"`, `"template's 26"`, `"N skills on day one"` (prose). Count drift hit us 3 times in v1.5.x (PRs #70, #76, #78). Solution: `scripts/check-surface-sync.py` with compound regex patterns as a pre-commit gate. Adding a new phrasing to documentation requires adding a matching regex to the script, otherwise it won't be caught. Conversely, guard against false positives when scanning for template counts: `"3 parallel agents"`, `"17 specialized agents"` (clo-author attribution), `"start with 2-3 skills"` are all legitimate non-template uses of `N + category` phrases. Use compound patterns requiring multiple template-specific tokens on the same line.

## Claude Code Hooks

[LEARN:hooks] Stop-hook block protocol has TWO valid forms: (a) legacy — `exit 2` + reason on stderr; (b) modern — `exit 0` + JSON `{"decision":"block","reason":"..."}` on stdout. `log-reminder.py` uses the modern form. Audit agents unfamiliar with the modern protocol will flag this as "should exit 2" — false alarm. Documented in `/deep-audit` skill's false-alarm list.

[LEARN:hooks] `initialPermissionMode` in VSCode settings only fires at **session start**. Mid-session mode toggles (via `Shift+Tab` or `/permission-mode`) override the file settings until session end. The 6-tier permission stack: VSCode user / workspace / CLI user / project / project-local / in-session runtime — the last is authoritative. "Prompts fire despite bypass config" is almost always a stale session, not a settings bug. *[2026-09-26: no `/permission-mode` command; a project-settings bypass (not honoured) is as common a cause.]*

## Plan→Bypass Framing

[LEARN:safety] Do NOT frame Plan→Bypass as a "safety boundary" or "safety guarantee." Plan approval gives you a chance to review the APPROACH before execution, but exiting plan mode returns the session to `defaultMode` (bypassPermissions *[2026-09-26: the mode the approval prompt picks; no bypass default]*), at which point any tool call runs under the full allowlist. Frame as "review-before-execute convenience." If a user needs a real enforcement boundary, they should keep `defaultMode: "default"` and approve each high-risk tool individually.

## Privacy in Diagnostic Skills

[LEARN:privacy] Diagnostic skills that read host-global config (e.g., `~/.claude/`, VSCode user settings) must require **explicit user confirmation** before crossing the repo boundary — especially in template repos that get forked. Phase the skill: repo-local auto, host-global opt-in with key redaction. Codex correctly flagged this pattern as a template-adopter privacy risk in PR #75.

## Claim-vs-Reality Framing

[LEARN:framing] **The orchestrator became a real runtime in v2.0.0 (2026-06-09)** (fan-out → reduce → judge + hallucination gate → loop-until-dry), superseding its earlier "pattern, not a runtime" framing, retired 2026-08-21. What holds regardless: there is **no daemon and no post-plan-approval trigger** — the loop is always user- or skill-initiated, a documented non-goal. Any doc claiming it "activates automatically after plan approval" is wrong.

[LEARN:framing] **A gate is only as enforced as its installation.** v2.0.0 replaced the "quality gates" claim (then enforced only inside `/commit`) with a real pre-commit hook — but it is live only **after the user runs `./scripts/install-hooks.sh`**, and `SKIP_QUALITY_GATE=1` / `--no-verify` bypass it. Docs must say "enforced once installed", never "always enforced". *(v2.0.0; retired the older framing 2026-08-21.)*

[LEARN:framing] Cross-artifact review is **pattern-based detection**, not universal auto-invocation. If the manuscript has no `\input{scripts/...}` signals, no cross-artifact work happens even without `--no-cross-artifact`. Document detection signals explicitly.

## Dogfooding Gaps Found in Round-1 Audit (2026-04-16)

[LEARN:dogfooding] Empty `quality_reports/plans/`, `specs/`, `session_logs/` directories in a WORKING FORK are a red flag — claimed dogfooding nobody follows. (In the shipped template these dirs are gitignored by design, so the heuristic applies to your own fork, not the clean tree.) The Stop-hook log reminder validates itself by catching missing logs; plan-first has no equivalent automation.

[LEARN:audit] "Claim-vs-reality" is the highest-ROI audit lens for a governance-heavy template repo. More valuable than skill-consistency or doc-drift checks because it surfaces where the template oversells itself — the exact thing forkers will discover and call out.

[LEARN:audit] Whack-a-mole anti-pattern: surgically fixing a bot-flagged phrase in a summary paragraph usually introduces new drift in the same paragraph (3× on v1.6.1). Two flags on one paragraph = rewrite it structurally, don't patch word-by-word. See `summary-parity.md`.

## Verification Architecture (three complementary patterns)

[LEARN:pattern] Verification here operates at three architectural levels, each addressing a different failure mode. Do NOT collapse them — they are complementary, not redundant:

1. **Critic-fixer loop** (`/qa-quarto`, `/review-paper --adversarial`) — **two agents, serial** — one flags issues, the other applies fixes; loop until APPROVED. Best for **presentation + structural** bugs (Beamer↔Quarto parity, manuscript completeness). Both see the full artifact; the tension comes from role assignment.

2. **Cross-artifact review** (`/review-paper` + `/review-r` + `/audit-reproducibility`) — **horizontal dependency traversal** — a manuscript's claims depend on scripts' outputs, so the paper reviewer spawns script reviewers and reproducibility checkers alongside it. Best for **paper ↔ code consistency** (ATTs, coefficients, N match the outputs that produced them).

3. **Post-Flight Verification / CoVe** (`/verify-claims` + `claim-verifier` agent, v1.7.0) — **single agent, fresh-context fork** — the verifier has never seen the draft; it answers verification questions from the source material alone, using `context: fork` to architecturally enforce independence. Best for **factual hallucination** (fabricated citations, wrong dataset fields, misattributed findings). Adapted from Dhuliawala et al. 2023 ([arXiv:2309.11495](https://arxiv.org/abs/2309.11495)). *[2026-09-26: use a fresh Agent call; a fork inherits the draft.]*

The key insight: each enforces independence differently — role tension, dependency-graph traversal, context isolation. A skill needing all three (e.g. `/review-paper --peer`) invokes them at different phases.

[LEARN:pattern] Post-Flight Reports (v1.7.0) are the output-side twin of Pre-Flight Reports (v1.6.0). Pre-Flight proves inputs were read, Post-Flight proves claims hold, and both use structured output blocks, fail-closed fallbacks, and explicit opt-outs. With summary-parity (v1.6.1) they form the **discipline-pattern trilogy** — input, framing, output discipline. Ask of a new text-generating skill: does it need all three?

[LEARN:audit] **Skill frontmatter `allowed-tools` must cover every tool the body invokes** — easy to miss, because the body reads as English ("spawn the verifier via Agent") while the frontmatter reads as a bureaucratic array. Four skills promised a tool in prose their `allowed-tools` omitted (PR #92, flagged by two external reviewers); the runtime failure is a permission error or a silent bypass. Sibling check: if rule X's `paths:` names skill Y, confirm Y actually implements X — rule-vs-implementation drift is the same bug one layer up.

[LEARN:audit] Deterministic bug classes (field exists, anchor resolves, count matches disk) belong in mechanical scripts — agent attention drifts, scripts don't. Reserve audit agents for judgment calls. `check-skill-integrity.py` ships the mechanical batch; `audit-pet-peeves.md` catalogues the judgment classes.

[LEARN:audit] When writing a parity-check regex, always strip inline code spans (` `` `) and fenced code blocks (` ``` `) before pattern-matching. Docs use example syntax like `[text](path#anchor)` inside backticks to illustrate; a naive regex treats those as real links. Replace matched code with spaces (preserving line numbers) before running the rest of the check.

[LEARN:audit] Audit-scope ATROPHY: audit agents only check what their prompt scopes, so any new code directory bypasses audit by default (6 bot-caught bugs in unscoped `scripts/`). **When adding a code location, expand audit scope first** — audit-debt accumulates silently.

## Scheduling Autonomous Work

[LEARN:scheduling] `CronCreate` is session-only in practice — it dies with the REPL (hit 2026-04-16 via a rate-limit termination). Work that must survive session death uses **Routines** (cloud-side). CronCreate is fine for short polling inside a live session, not "run this in an hour".

[LEARN:hooks] PreCompact hooks can BLOCK (modern protocol), which is how `pre-compact.py` can hold compaction while a plan is still DRAFT. Any such block must be opt-in, must fire at most once, and must fail open — a guard that can wedge a session is worse than the context it saves.

## v1.8.0 Cycle Lessons (2026-04-27)

[LEARN:permissions] **Protected-path behavior is mode-dependent — re-verify, never assume** (re-verified 2026-08-22 vs the permission-modes doc: `bypassPermissions` disables prompts and safety checks INCLUDING protected paths — the earlier "`.claude/` always prompts" version of this entry was stale). Auto mode classifier-gates risky actions and since 2026-08-14 is the built-in starting mode on Pro/Max/Team. Forkers in default mode still see prompts on `.claude/` edits. Batch 5+ edits to protected `.claude/` paths with one Bash `python3` heredoc (Edit fires the protected-paths gate; Bash does not). *[2026-09-26: not for settings/hooks — `root-of-trust-guard` blocks it.]* *[2026-11-06: root-of-trust-guard was removed in v2.9.1; a shell write to settings or hooks is no longer refused by a hook. Claude Code itself (`blockWritesOutsideWorkingDirectories`, ≥ 2.1.314) still refuses file-tool writes to its settings files.]* *[2026-11-07: v2.9.1 also drops that key. A `true` in any file applies and a local `false` cannot lift it, so the owner removed it from the committed file and restarted.]*

[LEARN:vscode] **`claudeCode.allowDangerouslySkipPermissions` is a typo trap** — the canonical key has NO `claudeCode.` prefix (unlike `claudeCode.initialPermissionMode`). The wrong key is silently ignored. Documented in `TROUBLESHOOTING.md`.

[LEARN:audit] **Surface-sync checks counts and MARKED tables** (`<!-- surface-sync-table: ... -->`, since v2.0) — tables without the marker are invisible to it (the guide appendix shipped 58 of 60 rows in v2.5 until a semantic sweep caught it). New skill/agent: add the row AND confirm the table is marker-covered or hand-checked.

[LEARN:pattern] **`disable-model-invocation: true` is load-bearing-write discipline.** Set it on skills writing persistent files the user must intend (lecture .tex, SKILL.md, preregistration); not on transient-report skills. It only blocks model auto-trigger; `/skill-name` still works. (Codified in `templates/skill-template.md`.)

## v1.9.0 Cycle Lessons (2026-05-20)

[LEARN:workflow] **Plan-first scales to multi-pass releases.** v1.9.0 shipped 6 skills + 2 agents + 2 rules across 9 PRs from one comprehensive plan file; each pass became a small reviewable PR, and mid-flight additions got a Pass slot in the plan. For multi-PR releases, the plan file is the navigation, not the conversation.

[LEARN:pattern] **Detect-only beats auto-rewrite for prose quality.** `/humanize` ships without `--rewrite`: cross-vendor findings show auto-rewriting AI-voice tells degrades quality and adds new tells. For any "fix my prose" skill, detect-and-flag with line numbers; the author edits. Same rationale keeps `/proofread` advisory.

[LEARN:pattern] **Distil-don't-truncate for long sessions.** Auto-compaction drops early turns; `/compress-session` writes a structured note instead (decisions, files, open questions, next actions, **discarded-as-noise**). Listing failed hypotheses explicitly stops them ghost-haunting future context. Companion to `/checkpoint`, not a replacement.

[LEARN:pattern] **Five-critic isolated voting beats single-critic composite judgment.** `/promote-memory` graduates `[LEARN]` entries via 5 forked critics (generality / staleness / redundancy / evidence / format), one dimension each, votes hidden from each other — isolation prevents groupthink. The user is the final gate even at 5-of-5. (Adapted with attribution from claudeblattman v2.1.)

[LEARN:pattern] **Provenance as a YAML artifact, not a folder.** `templates/passport-template.yaml`: per-paper numeric claims with source line, output field, tolerance, status; `/audit-reproducibility` rewrites it in place. Queryable beats folder reports. (Scope-reduced from Imbad0202/ARS "Material Passport" to numeric claims only.)

[LEARN:pattern] **Variance reporting > point estimate for peer review.** ~37% of verdicts vary purely from referee-disposition sampling (AgentReview, arXiv:2406.12708), so `--variance N` returns a verdict distribution + K-of-N concern table instead of one verdict. Bimodal spreads and tight majorities are both information. Referees route to Sonnet; hard cap N=5. *[Fixed 2026-09-26: referees stay on Opus (do-not-demote).]*

[LEARN:pattern] **HIGH-WARN must-fix for fabricated citations.** `/verify-claims` tiers: HIGH-WARN (fabricated reference / numerical or directional contradiction) is must-fix before commit; MED-WARN transient; LOW-WARN inaccessible source. Be conservative assigning HIGH-WARN — false positives erode the gate. The CoVe forked verifier (never sees the draft) is the architecture; the must-fix policy makes it consequential. *[2026-09-26: no /commit gate reads it; verifier = fresh Agent call, not a fork.]*

[LEARN:pattern] **70/20/10 model routing for cost discipline** (`model-routing.md`): Haiku tier mechanical, Sonnet tier review/critique, Opus tier high-judgment. 50–80% savings with no quality loss on the mechanical tier. Anti-pattern: down-tiering claim-verifier / methods-referee / editor — one false-positive PASS costs more than the routing saves. (Primary source: Anthropic "Decoupling brain from hands", Apr 2026.)

[LEARN:research] **Research-grounded plans beat eyeballed roadmaps.** When scope is "what should we add?", run parallel research agents first (ecosystem / community / cross-vendor / internal audit) and verify uncertainties before planning — the plan becomes traceable to URLs and verified facts instead of opinions. ~30 min of dispatch buys non-redundant, currently-true items.

[LEARN:workflow] **Surface-sync must check enumerative tables, not just counts.** Count assertions catch "N skills" drift but not missing table rows (the v1.5.0 agent trio was absent from README for 3 releases; the guide appendix shipped 58 of 60 rows in v2.5 until a semantic sweep caught it). Every skill/agent addition: update count assertions AND the guide appendix AND the README table.

## v2.5 Cycle Lessons (2026-08-21)

[LEARN:process] **Plan mode is not optional on a vague, multi-hour ask.** A vague "update our workflow" session with no plan mode, no spec, no `AskUserQuestion` paid the documented 30-50% rework: north star, guide plan, version scheme, and phase framing all rewritten mid-flight — each fixable by a 5-question spec in one turn. **Trigger: vague ask, multiple readings, >1 hour or >3 files → spec first, via `AskUserQuestion`.**

[LEARN:process] **Survey the machine before the world.** An ecosystem review searched the web first and found the owner's own `~/.claude/skills/` and private repos only after being asked — three times; the strongest material was local every time. **Order: own repos and `~/.claude/` → ecosystem → literature.**

[LEARN:framing] **Never write an exclusivity claim into a plan — it propagates to the webpage.** "The only public workflow that..." is unfalsifiable marketing. Use a dated survey finding plus repo-checkable claims. Banned in shipped copy: *the only, the first, nobody else, unmatched, best-in-class*.

[LEARN:process] **Do not propose restructuring an artifact you have not read.** A guide restructure drafted from its heading tree would have destroyed field-tested patterns that already solved the problem and handed every fork a merge conflict. **Headings are not the artifact.**

[LEARN:audit] **A green gate proves internal consistency, not external truth.** The model gate exited 0 while the SSoT named superseded tiers — surfaces merely agreed with each other. Currency gates need an external oracle plus a staleness expiry, or stale-but-consistent is indistinguishable from current.

[LEARN:audit] **Tool-name drift silently disarms hooks and gates.** When `Task` became `Agent`, 33 skills still declared `Task`, a `Bash|Task` hook matcher stopped firing, and the integrity checker certified the dead contract green. **Migrate tool names by registering both matchers, and source checker tool lists from the current reference, never hard-coded.**

[LEARN:safety] **Promoting a global skill into a public repo is a higher-blast-radius edit than it looks.** A candidate carried an unpublished paper's title and authors in its `description:` — and that field is a shared contract governing model auto-invocation machine-wide, so a global `~/.claude/skills/` edit has *wider* reach than a project one. **Scrub attributions with a fail-closed deny-list scan over publishable surfaces (pre-commit + CI, term list gitignored) before the port begins, and edit `description:` under `blast-radius`.**

[LEARN:audit] **A gate you did not re-qualify is a gate you may no longer have.** It goes quiet two ways: editing a *checked surface* can drop it out of coverage (a rewrite changed the count phrasing, gates stayed green because nothing matched — a gate that matches nothing reports nothing), and tuning a *checker* one way blinds the other. **After editing either, re-seed both directions: a planted defect must still be caught AND legitimate prose must still pass. A falling assertion count is the investigate signal.**

[LEARN:process] **Verify the branch actually changed before committing.** A `git checkout -b` bundled with a hook-blocked command never ran; ten commits landed on `main`. **A blocked hook fails the WHOLE call — anything bundled with it silently did not happen. After any branch op, echo `git rev-parse --abbrev-ref HEAD` and read it.**

[LEARN:governance] **Methodological content in the owner's own field ships only with the owner's CURRENT sign-off.** A skill was vetoed despite earlier commits recording sign-off: **a sign-off attaches to the content it reviewed, not to the surface's name** — after substantial edits or promotion into a public template it is void until renewed, however well the surface evals. Scope widened twice (2026-08-22/23): all prescriptive empirical-practice content, then causal methods generally. Taxonomy and conditional package pointers ship; prescriptions do not. Dated rulings: [`meta-governance.md`](.claude/rules/meta-governance.md).

## v2.5.1 Cycle Lessons (2026-08-23)

[LEARN:audit] **Gate every number you publish — including in the release that adds the rule.** A release stating *a count is a computation, not a reading* shipped three counts of its own test battery: one agent wrote the prose while another was still adding cases. **Sequence the change and its count — never parallelize them — and make the count derived**, so a checker recomputing it from source turns silent drift into a red gate.

[LEARN:safety] **When a check keeps leaking, stop patching cases — stop predicting.** A clean-tree guard tried to infer from a chained command whether the tree would still be dirty by the merge. Enumerating safe forms leaked; deny-on-doubt leaked less but still leaked, because each round found one more unmodelled dimension — flags, subcommands, segments, redirection, substitution — then a semantic one: `git stash` does not stash untracked files, so a correctly-parsed *this cleans the tree* was false. Deleting the prediction was necessary and not sufficient: a reading taken before execution proves only that the tree was clean when the command was *authorized*, and a referee chained a write ahead of the op on a clean tree. The class closed only once the op was also required to be a **standalone simple command** — nothing left on the line that could write in between. **Predicting an effect you could measure is itself the defect — and a measurement taken before the effect is not a measurement of it.**
