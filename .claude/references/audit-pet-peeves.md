# Audit Pet Peeves — classes of bug review bots catch that our deep-audit keeps missing

**Purpose.** A living catalogue of drift patterns that Copilot / Codex / human reviewers have flagged on recent PRs. Deep-audit agents read this as additional prompt context so they inherit the accumulated knowledge from past rounds.

**Principle.** Each class of bug we see in review = one entry. Grow the file, don't rewrite it. Mechanical checks (in `scripts/check-skill-integrity.py`) close the obvious holes; this file closes the subtler ones that require judgment.

**How to use.** When writing a deep-audit agent prompt, say "read `.claude/references/audit-pet-peeves.md` and explicitly check for each class before reporting clean." When triaging a Copilot/Codex finding, decide: is this a new class (add entry) or an existing class re-surfacing (bump the evidence list)?

---

## 1. Frontmatter ↔ body tool parity (`Task` missing from `allowed-tools`)

**Example:** PR #92. `/lit-review`, `/research-ideation`, `/respond-to-referees`, `/interview-me` each documented "spawn `claim-verifier` via `Task` with `context=fork`" in their body, but none of them had `Task` in `allowed-tools`. Codex + Copilot both caught; deep-audit missed.

**How to catch.** Automated by `scripts/check-skill-integrity.py` (check 1, Task-only pattern). For other tools (Edit, Write, MultiEdit, NotebookEdit), the script has narrower patterns. WebSearch / WebFetch / Read / Grep / Glob / Bash are intentionally excluded — too many prose false positives.

**Why deep-audit missed it.** Agent 3 prompt said "allowed-tools values are sensible" — didn't cross-check against body invocations.

**When to apply.** Any new skill or modified skill that spawns a subagent. Also triggered when a skill adds a new body section that invokes a tool it didn't previously use.

---

## 2. `argument-hint` ↔ body flag parity

**Example:** PR #92 (Copilot). Skills added a `--no-verify` opt-out in the body but didn't advertise it in `argument-hint`. Users wouldn't discover the documented opt-out from the one-line hint.

**How to catch.** Automated by `scripts/check-skill-integrity.py` (check 2). Detects flags in (a) markdown table first cells, (b) list items, (c) lines with explicit opt-out language. Misses free-form prose descriptions of flags — that's intentional; prose mentions don't imply a real supported option.

**Why deep-audit missed it.** Nobody was looking at `argument-hint` as a coverage surface.

**When to apply.** Whenever a body documents `--flag foo` language.

---

## 3. Broken internal markdown anchors

**Example:** PR #87. `r-code-conventions.md` linked to `r-reviewer.md#category-11-numerical-discipline`, but the actual heading was `### 11. NUMERICAL DISCIPLINE` → GitHub anchor `11-numerical-discipline`. Copilot caught.

**How to catch.** Automated by `scripts/check-skill-integrity.py` (check 3). For every `[text](path#anchor)` link, resolve `path` and check `anchor` against a GitHub-flavored-markdown anchorize of each heading in the target.

**Why deep-audit missed it.** Agent 1 checked "cross-references and anchors resolve" but didn't actually implement the heading → anchor transformation.

**When to apply.** Always on doc changes. Especially after renaming a heading (`## Foo Bar` → `## Foo Baz` changes the anchor).

---

## 4. Unimplemented flag promised in documentation

**Example:** PR #87. `beamer-quarto-sync.md` advised running `/translate-to-quarto --diff [file]` but the skill had no `--diff` option. `cross-artifact-review.md` referenced `--with-scripts` which also didn't exist. Both caught by Copilot.

**How to catch.** Harder to automate — the script would need to parse each skill's argument parsing and compare to every flag mentioned in any rule or other skill. For now: when writing a doc that mentions a skill flag, verify the flag actually exists by grepping the skill's SKILL.md and argument-hint.

**Why deep-audit missed it.** Cross-file flag references are outside Agent 3's per-file scope.

**When to apply.** When a rule or another skill references a flag of some skill (e.g. "pass `--foo` to `/skill-name`"). Grep the target skill's argument-hint and body for that flag.

---

## 5. Stale docstring vs code behavior

**Example:** PR #87. `.claude/hooks/log-reminder.py` docstring said "blocks Claude from stopping" but the code had been rewritten to stderr-only advisories. Copilot caught.

**How to catch.** Hard to mechanize. Look for key behavioral claims in docstrings (blocks, fails, exits, returns) and cross-check them against the actual code control flow. When changing a function's behavior, always re-read its docstring.

**Why deep-audit missed it.** Agent 2 focuses on hook exit codes and imports; didn't compare docstrings against behavior.

**When to apply.** After any change to a hook's exit path or a function's return/side-effect behavior.

---

## 6. Rule ↔ skill implementation parity

**Example:** PR #92. `post-flight-verification.md` listed `/interview-me` in its `paths:`, claiming the skill runs Post-Flight. But `/interview-me/SKILL.md` had no Post-Flight section — silent drift between rule and implementation.

**How to catch.** Automated by `scripts/check-skill-integrity.py` (check 4). For each rule, a keyword map declares which body keywords the skill must contain (e.g. `post-flight-verification.md` → body must mention `claim-verifier` or `Post-Flight`). Update the keyword map whenever a new rule ships.

**Why deep-audit missed it.** Agent 3 checked "rule paths: reference existing directories" but not whether skills in those paths actually implement the rule.

**When to apply.** Whenever a rule expands its `paths:` or a skill is added to a rule's scope.

---

## 7. Enumerative summary paragraph drift from body (whack-a-mole)

**Example:** PRs #88–#90. Every time Copilot flagged one phrase in the v1.6.1 CHANGELOG opening ("no new skills, rules, hooks" → "no new directories" → "27/22/13/6" → "no agents in the enumeration"), the surgical fix introduced a new drift elsewhere in the same paragraph. Three rounds of patching, same paragraph.

**How to catch.** Not mechanical — it's a judgment pattern. The rule `.claude/rules/summary-parity.md` encodes it: two review-bot flags on the same summary paragraph = rewrite structurally (abstract up), don't patch.

**Why deep-audit missed it.** Enumerative summaries are "technically correct" at every version — the drift is between summary and body across time.

**When to apply.** CHANGELOG ledes, README taglines, PR `## Summary` blocks, skill/rule/agent frontmatter `description:` fields, guide section abstracts, MEMORY.md `[LEARN]` headlines.

---

## 8. Count shorthand in non-canonical order

**Example:** PR #89. I wrote `27/22/13/6` which reordered the canonical convention (`27 skills / 13 agents / 22 rules / 6 hooks` — agents before rules) and dropped the labels. Copilot caught.

**How to catch.** Use only the canonical labeled form `N skills / M agents / K rules / L hooks`. Avoid bare digit shorthands like `27/13/22/6` — they drift every time someone reorders them.

**Why deep-audit missed it.** Surface-sync checks that counts match disk, not that phrasings are canonical.

**When to apply.** Any summary that mentions all four counts. For single-count mentions, labels are sufficient.

---

## 9. Agent ↔ skill scope contradiction

**Example:** PR #87. `domain-reviewer.md` scope note said "for lecture slides, not manuscripts" but also listed `/seven-pass-review` (a manuscript skill) as a user. Internally contradictory. Copilot caught.

**How to catch.** When adding scope notes to agent files, cross-check each listed user-skill to confirm the scope claim holds across all of them. If a multi-artifact agent describes itself as "single-artifact", that's the bug.

**Why deep-audit missed it.** Agent 3 checked file existence but not cross-reference semantic consistency.

**When to apply.** Scope notes on agent files. Also applies when a skill's description claims exclusivity ("only for slides") while being used by a manuscript-oriented caller.

---

## 10. Daemon phrasing for patterns that aren't daemons

**Example:** PR #87. `TROUBLESHOOTING.md` said "go through the orchestrator" as if the orchestrator were a runtime service you invoke. But the orchestrator is a *pattern* specific skills implement — not a daemon. Copilot flagged after we'd just rewritten this framing for v1.6.1.

**How to catch.** Grep docs for daemon-like verbs applied to things that aren't daemons: "invoke the X", "X activates when", "X runs after Y". When "X" is a pattern/rule/protocol, those phrasings are wrong. When "X" is a hook/service/skill, they may be correct.

**Why deep-audit missed it.** Framing-honesty audits catch most of this but can miss stray daemon phrasing in file-level TROUBLESHOOTING sections.

**When to apply.** Anywhere the orchestrator, a protocol, or a pattern is described. Especially after reframing work (e.g. v1.6.1's "orchestrator is a pattern, not a daemon").

---

## 11. Stale prose counts outside the surface-sync regex

**Example:** PR #92 Round 1. Four locations in README.md and the guide said "13 specialized agents" / "13 focused agents" / "reviewed by 13 specialized agents" even after counts moved to 14. Surface-sync didn't catch these because its regex only matches the canonical `N agents, M skills, K rules, L hooks` form. Bots caught all four.

**How to catch.** Grep for the old count in any modifier context: `N specialized`, `N focused`, `reviewed by N`, `template's N`. Also consider updating surface-sync to match a wider set of phrasings — but beware of false positives on unrelated numerics.

**Why deep-audit missed it.** Agent 1's "counts match reality" check relied on surface-sync.

**When to apply.** Any count change. Grep the whole tree for the OLD value, not just the canonical phrasing.

---

## 12. Historical CHANGELOG entries — DO NOT UPDATE

**Example:** Most PRs. CHANGELOG entries under past version headings are snapshots of what shipped at that version. They should NOT be updated when counts change. An audit agent that says "CHANGELOG line 122 has stale count 22" on a v1.5.x entry is wrong — that version shipped with 22 rules and the record must reflect that.

**How to catch.** When the surface-sync script or an audit agent flags a count in CHANGELOG.md, check the version heading above it. If the heading is a past version, it's a historical snapshot — skip.

**Why deep-audit missed it.** Agents sometimes don't distinguish "current surfaces" from "historical records".

**When to apply.** CHANGELOG audits.

---

---

## 13. Docstring contract ↔ implementation drift

**Example:** PR #93 (Copilot + Codex). `check-skill-integrity.py` docstring described flag parity as "argument-hint ↔ body flag parity … and vice versa" but the implementation only reported the body→hint direction. Independently flagged by both bots. Separate instance: exit-code docstring said "1 = P0 failures" but code returned 1 for P0 OR P1.

**How to catch.** When reading a function's docstring, extract every behavioral claim (bidirectional, fail-open, exits 1 on X, returns Y when Z) and verify the implementation matches. Contracts lie by omission: if the docstring says "X … and vice versa", the code must actually do both.

**Why deep-audit missed it.** Agent 2's original scope was `.claude/hooks/` only. New code in `scripts/` bypassed the audit entirely. Even with correct scope, "docstring claims X but code does Y" is a class that requires reading both carefully — easy to miss on a skim.

**When to apply.** Any function or script whose docstring makes a behavioral claim. Especially critical for code that's about to be shipped as part of audit infrastructure itself — a bug here undermines everything the code is meant to check.

---

## 14. Python fail-open promise broken by narrow `except`

**Example:** PR #93 (Copilot). `check-skill-integrity.py` promised "fail-open on parser errors: a corrupt/unparseable file prints a P2 warning but does not fail the build." Implementation caught only `OSError` on `read_text()` — `UnicodeDecodeError` would bubble to the top-level `except Exception` in `main()` and exit 2, failing the gate contrary to the docstring.

**How to catch.** When a Python script documents fail-open behavior, check that every `read_text()` / `open()` / `json.loads()` catches the realistic failure modes (`OSError`, `UnicodeError`, `json.JSONDecodeError`). Better: use explicit `encoding="utf-8"` and catch `(OSError, UnicodeError)` together.

**Why deep-audit missed it.** Scope gap (scripts/) plus no explicit check for encoding-error handling.

**When to apply.** Any Python script that reads files and claims fail-open behavior. Especially audit/gate scripts where a false hard-fail blocks commits.

---

## 15. Bash `set -u` does not catch command failures

**Example:** PR #93 (Copilot). `check-surface-sync.sh` used `set -u` (treat unset variables as errors) but not `set -e` (exit on command failure). If the `SCRIPT_DIR="$(cd ... && pwd)"` command had failed (e.g. the script was moved, `cd` errored), `SCRIPT_DIR` would have been empty and subsequent `python3 "$SCRIPT_DIR/..."` invocations would have run with a bogus path.

**How to catch.** In bash scripts, `set -u` only guards against unset variables, NOT command failures. If you can't use `set -e` (because you want subsequent commands to run even if earlier ones fail — e.g. running two gates sequentially and wanting both outputs), you must explicitly check return codes or use `|| { ...; exit 2; }` after each critical command.

**Why deep-audit missed it.** Scope gap (scripts/) plus Agent 2's hook-focused checks don't cover bash safety idioms beyond exit-code protocols.

**When to apply.** Any bash script that does path resolution, variable derivation, or sequential command dispatch. Especially when the script runs as a git hook or commit gate.

---

## 16. Dead config-map entries that mislead maintainers

**Example:** PR #93 (Copilot). `check-skill-integrity.py` had `RULE_KEYWORDS` entries for `cross-artifact-review.md` and `content-invariants.md`, but neither rule's scope frontmatter (one uses `globs:`, both target `.tex`/`.qmd` files not `.claude/skills/*`) actually fires the check. The entries were no-ops. A future maintainer reading the code would reasonably assume the check was exercising those rules.

**How to catch.** When adding an entry to a config map, keyword dict, or registry, verify at least one execution path actually reaches the entry. Dead entries rot in place — they're worse than omitting them because they imply coverage that doesn't exist.

**Why deep-audit missed it.** No check for "config entries reach their referents." Scope gap compounded it.

**When to apply.** When editing any file that has a `{key: config}` map, path-pattern list, or rule-reference registry. Run a quick trace: given this input, does the entry get used? If not, remove or document why it's parked.

---

## 17. `CronCreate` for long-delay autonomous work

**Example:** 2026-04-16. The user's usage was about to be rate-limited and they needed autonomous work to fire ~1 hour later. We used `CronCreate` with `durable: true`, but the cron is tied to the Claude Code REPL's own event loop — when the session died (rate limit + user walked away + VSCode closed the panel), the cron went with it. Plan survived on disk; the scheduled trigger did not. User had to invoke manually on return.

**How to catch.** Any time you use `CronCreate` with a delay > 10 minutes, ask: "will the Claude Code session definitely be running at fire time?" If not, switch to **Claude Code Routines** (released Apr 14, 2026) — they run on Anthropic's web infrastructure and don't depend on the local REPL. Routines are the right primitive for overnight work, scheduled audits, and autonomous runs while the user is away. `CronCreate` is for short-delay polling within an active session.

**Why deep-audit missed it.** Not a code-quality issue — it's a primitive-selection issue. Add to pet-peeves because it's the kind of subtle gotcha that bites you exactly when you can't afford it (user away, session dying).

**When to apply.** Any scheduling decision. Rule of thumb: `CronCreate` for minutes, Routines for hours. If the user is actively watching, either works; if they're AFK, use Routines.

---

## 18. Enumerative-table drift (surface-sync's blind spot)

**Example:** v1.8.0 deep-audit. Lede counts said "30 skills, 14 agents" and `check-surface-sync.py` confirmed all 26 numeric-count assertions matched disk. But the guide's appendix "All Skills" table tabulated 28 rows (missing `/checkpoint` + `/preregister`) and "All Agents" table tabulated 11 rows (missing the v1.5.0 peer-review trio editor / domain-referee / methods-referee — pre-existing drift inherited across 3 releases). Surface-sync gate is blind to this class because it looks for phrasing patterns like `"30 skills, 14 agents"`, not at whether enumerative tables actually contain N items.

**How to catch.** When adding a skill/agent/rule/hook, audit ALL these surfaces, not just count phrasings:
- `guide/workflow-guide.qmd` "All Skills" / "All Agents" / "All Rules" appendix tables (count rows = expected N).
- `CLAUDE.md` "Skills Quick Reference" table (rows = N).
- `README.md` skills/agents tables.
- `docs/index.html` inline bullet lists that enumerate skills.
A future mechanical check could count `.claude/{skills,agents,rules}/*` and grep table rows in these surfaces; until then, deep-audit Agent 1 + Agent 4 should explicitly check appendix table row counts.

**Why deep-audit missed it (until v1.8.0).** Agent 1's prompt asked about counts, not row counts. Agent 4's prompt asked about feature counts agreeing across documents, not about whether enumerative tables tabulate the same set as the count claims. Both agents looked at the lede counts (which were correct) and stopped.

**When to apply.** Whenever a release adds or removes a skill/agent/rule/hook. Surface-sync clean ≠ enumerative tables current. Run a quick `wc -l` style check of appendix tables vs `ls .claude/skills/ | wc -l`.

---

## 19. Tool-name parity beyond `Task` (generalize peeve #1)

**Example:** v1.8.0 deep-audit. Two skills (`/data-analysis`, `/audit-reproducibility`) gained "use the Monitor tool" guidance in their bodies but didn't add `Monitor` to `allowed-tools`. Same class as PR #92's `Task` parity bug from v1.7.0 (peeve #1) but a different tool, so the `check-skill-integrity.py` regex (which specifically looks for `Task` patterns) didn't catch it.

**How to catch.** Generalize the parity check: for EVERY tool name mentioned in a skill body (`Task`, `Bash`, `Edit`, `Write`, `Read`, `Grep`, `Glob`, `WebFetch`, `WebSearch`, `Monitor`, `NotebookEdit`, `TodoWrite`, etc.), verify it appears in `allowed-tools`. The script should maintain a list of known tool names rather than hard-coding `Task` only. New Anthropic tools (Monitor in Apr 2026 Week 15) ship faster than the audit script.

**Why deep-audit missed it (until v1.8.0).** `check-skill-integrity.py` Phase 0 check 1 is hard-coded to look for `Task`. Body language like "use the Monitor tool" reads as English; the script doesn't pattern-match it. Audit Agent 3's prompt now explicitly checks for non-`Task` tool references too — but the right fix is to extend the mechanical script with a known-tool list.

**When to apply.** When adding a body reference to any Anthropic-shipped tool, add the tool to the skill's `allowed-tools` array as you write the body. When extending `check-skill-integrity.py`, add new tool names to the parity check whenever Anthropic ships a new tool primitive.

---

## Meta — how this file is maintained

- After any PR where a review bot catches something deep-audit missed, append a new entry (or extend an existing one with new evidence).
- When an entry's class is automated by `scripts/check-skill-integrity.py` or another mechanical check, note it — but keep the entry, it's still useful context for reviewers.
- Target ≤ 20 entries; if we hit 25, review + merge related classes or archive resolved ones to a `_resolved.md` sibling.
- Reference this file from `.claude/skills/deep-audit/SKILL.md` so all 4 agents load it.
- Link from MEMORY.md `[LEARN:audit]` entries when a specific lesson ties to an entry here.
