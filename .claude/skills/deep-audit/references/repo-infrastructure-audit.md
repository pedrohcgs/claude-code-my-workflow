# Application: auditing this repository's own infrastructure

The general method in `SKILL.md` applied to the template itself — skills, agents, rules,
hooks, scripts, and docs. Read this when the audit target is the repo, not a paper.

Run a comprehensive consistency audit across the entire repository, fix all issues found, and loop until clean.

## When to Use

- After broad changes (new skills, rules, hooks, guide edits)
- Before releases or major commits
- When the user asks to "find inconsistencies", "audit", or "check everything"

## Workflow

### PHASE 0: Mechanical checks (run FIRST, cheap, deterministic)

Before spawning agents, run the full mechanical battery, then the skill-integrity gate on its own for per-check detail:

```bash
./scripts/backtest.sh
python3 scripts/check-skill-integrity.py --verbose   # backtest gate 2, verbose
```

`check-skill-integrity.py` catches five classes of bug that agent-based audits have historically missed:

1. Frontmatter `allowed-tools` ↔ body tool-invocation parity (e.g. body spawns `Task` but `Task` not in `allowed-tools` — the v1.7.0 PR #92 miss).
2. `argument-hint` ↔ body flag parity (flags documented but not advertised, or vice versa).
3. Internal markdown anchors resolve (no broken `[text](path#anchor)` links — the `#category-11-numerical-discipline` miss on PR #87).
4. Rule `paths:` ↔ skill implementation parity (rule claims skill follows protocol but skill body has none of the protocol keywords — the `/interview-me` miss on PR #92).
5. Rule-keyword registry completeness (check 4 only sees rules registered in `RULE_KEYWORDS`, so any rule scoping itself to `.claude/skills/` must be registered, with keywords or with an explicit `[]` and the reason it is not keyword-checkable).

If Phase 0 reports P0 or P1 findings, fix them (or tune the regex if they are false positives) **before** launching the 4 agents. The mechanical layer is cheaper and more precise than agent prompts for these classes.

### PHASE 1: Launch 4 Parallel Audit Agents

Launch these 4 agents simultaneously using `Agent` with `subagent_type=general-purpose`. Each agent's prompt **must** tell it to read `.claude/references/audit-pet-peeves.md` and explicitly check for each class of bug before reporting clean. The pet-peeves file is a living catalogue of drift patterns review bots have caught; it grows with each PR.

#### Agent 1: Guide Content Accuracy
Focus: `guide/workflow-guide.qmd`
- All numeric claims match reality (skill count, agent count, rule count, hook count)
- All file paths mentioned actually exist on disk
- All skill/agent/rule names match actual directory names
- Code examples are syntactically correct
- Cross-references and anchors resolve
- No stale counts from previous versions

#### Agent 2: Executable Code Quality
Focus: **all** executable code in the repo — `.claude/hooks/*.py`, `.claude/hooks/*.sh`, `scripts/*.py`, `scripts/*.sh`, `.claude/scripts/*.sh`, `.githooks/pre-commit`. Not just `.claude/hooks/` — when PR #93 added new code under `scripts/`, the original narrow scope meant Copilot + Codex caught 5 bugs the audit missed.

Hook-specific checks (Stop/PreToolUse/SessionStart protocols, `CLAUDE_PROJECT_DIR` usage, hash-length consistency) apply only to `.claude/hooks/`. Everything below applies to ALL executable code:

- No remaining `/tmp/` usage in anything that manages state (should use `~/.claude/sessions/`)
- Hash length consistency (`[:8]` across all hooks) [hooks only]
- Proper error handling — **fail-open pattern** where the docstring promises it (top-level `try/except` with `sys.exit(0)`). Python `read_text()` must catch `UnicodeError` (not just `OSError`) if the script is promised fail-open for corrupt files. Bash `set -u` without `set -e` or explicit post-command checks does NOT catch command failures — verify.
- **Docstring-claim ↔ implementation parity.** If a function's docstring describes "bidirectional parity" / "fail-open" / "exits 1 on X", the implementation must match. Common drift: one-directional implementation of a claimed-bidirectional contract; exit codes documented as one thing but returning another.
- **Config-map entries point at live targets.** Keyword dicts, path maps, and rule registries should not contain dead entries (e.g. rule files that don't exist, fields the script doesn't actually read). Dead entries mislead maintainers.
- JSON input/output correctness (stdin for input, stdout/stderr for output) [hooks only]
- Exit code correctness. Blocking protocols differ by hook event:
  - **Stop:** (a) **exit 2 + reason on stderr** — legacy, still supported; (b) **exit 0 + JSON `{"decision": "block", "reason": "..."}` on stdout** — modern; this is what `log-reminder.py` uses and it works correctly
  - **PreToolUse:** (a) **exit 2 + reason on stderr** — legacy, still supported; (b) **exit 0 + JSON `{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "..."}}` on stdout** — modern; this is what `dirty-tree-guard.py` and `issue-guard.py` use. A top-level `{"decision": "block"}` on a PreToolUse hook is the deprecated form, not the modern one
  - Non-blocking hooks always exit 0. On PreCompact, exit 2 **blocks compaction** — use it only when blocking is the point; plain stdout goes to the debug log, so a user-visible note goes out as a JSON `systemMessage` and diagnostics go to stderr
- `from __future__ import annotations` for Python 3.8+ compatibility
- Correct field names from hook input schema (`source` not `type` for SessionStart)

#### Agent 3: Skills and Rules Consistency
Focus: `.claude/skills/*/SKILL.md` and `.claude/rules/*.md`
- Valid YAML frontmatter in all files
- `disable-model-invocation: true` only on user-invoked skills (side effects, long or interactive runs) — and no other skill's body *invokes* such a skill (it cannot; it must Read that `SKILL.md` and follow it)
- `allowed-tools` values are sensible
- **`allowed-tools` actually covers every tool the skill body invokes.** For every `Agent` spawn, `Bash` command, `Write`/`Edit` call mentioned in the skill's Steps / Phases / Workflow body, verify the tool appears in the `allowed-tools` array. Common miss: skill body says "spawn `agent-X` via the `Agent` tool with `context=fork`" but `Agent` (alias `Task`) is absent from `allowed-tools` — runtime permission error or silent bypass. Caught this class of bug after Codex/Copilot flagged it on PR #92 (4 skills promised `Task` in their Post-Flight sections but 3 of 4 had no `Task` permission).
- **Rule `paths:` scope matches skill implementation.** If rule X lists skill Y in `paths:`, verify skill Y actually implements the protocol rule X mandates. A rule claiming a skill follows a protocol is meaningless if the skill doesn't.
- Rule `paths:` reference existing directories
- No contradictions between rules
- README.md's skills table matches the skill directories 1:1 (`check-surface-sync.py` enforces it), and every skill named in CLAUDE.md's quick reference exists
- All templates referenced in `.claude/rules/*.md` and the guide (`guide/workflow-guide.qmd`) exist in `templates/`

#### Agent 4: Cross-Document Consistency
Focus: `README.md`, `docs/index.html`, `docs/workflow-guide.html`
- All feature counts agree across all 3 documents
- All links point to valid targets
- License section matches LICENSE file
- Directory tree matches actual structure
- No stale counts from previous versions

### PHASE 2: Triage Findings

Categorize each finding:
- **Genuine bug**: Fix immediately
- **False alarm**: Discard (document WHY it's false for future rounds)

Common false alarms to watch for:
- Quarto callout `## Title` inside `:::` divs — this is standard syntax, NOT a heading bug
- `allowed-tools` linter warning — known linter bug (Claude Code issue #25380), field IS valid
- Counts in old session logs — these are historical records, not user-facing docs
- Counts in `CHANGELOG.md` under past version headings — those are snapshots; do NOT update
- `log-reminder.py` outputting `{"decision": "block"}` with `sys.exit(0)` — this IS the modern Claude Code Stop-hook block protocol, NOT a bug

**Count drift specifically: search for every phrasing variant.** A common failure mode is that `replace_all` on one phrasing (e.g., `"26 skills"`) misses sibling phrasings in the same repo. When checking counts, grep for ALL of:
- `"N skills"`, `"N skill "` (with space)
- `"N slash commands"`
- `"N specialized"` (as in "N specialized agents")
- `"template's N"` (informal count in prose)
- Commas/conjunctions: `"skills,"` vs `"skills, and"` are treated as different strings by `replace_all`
Verify zero matches for the OLD number across the whole tree before declaring clean.

### PHASE 3: Fix All Issues

Apply fixes in parallel where possible. For each fix:
1. Read the file first (required by Edit tool)
2. Apply the fix
3. Verify the fix (grep for stale values, check syntax)

### PHASE 4: Re-render if Guide Changed

If `guide/workflow-guide.qmd` was modified:
```bash
quarto render guide/workflow-guide.qmd
cp guide/workflow-guide.html docs/workflow-guide.html
./scripts/stamp-render.sh   # re-stamp .render-stamp, or the staleness gate fails
```

### PHASE 5: Loop-until-dry or Declare Clean

After fixing, launch a fresh set of 4 agents to verify. This is the **loop-until-dry** primitive ([`orchestrator-protocol.md`](../../../rules/orchestrator-protocol.md)):
- **Converge** after **2 consecutive rounds** surface **0 new genuine issues** (deduped on file+issue) — declare clean and report summary.
- If new issues found → fix and loop again.
- **Fallback cap: 5 loops** bounds a non-converging audit (prevents infinite cycling); a finding that survives rounds N and N+2 is escalated to the user rather than re-patched ([`summary-parity.md`](../../../rules/summary-parity.md)).

## Key Lessons from Past Audits

These are real bugs found across 7 rounds — check for these specifically:

| Bug Pattern | Where to Check | What Went Wrong |
|-------------|---------------|-----------------|
| Stale counts ("19 skills" → "21") | Guide, README, landing page | Added skills but didn't update all mentions |
| Hook exit codes | All Python hooks | Exit 2 in PreCompact silently discards stdout |
| Hook field names | post-compact-restore.py | SessionStart uses `source`, not `type` |
| State in /tmp/ | All Python hooks | Should use `~/.claude/sessions/<hash>/` |
| Hash length mismatch | All Python hooks | Some used `[:12]`, others `[:8]` |
| Missing fail-open | Python hooks `__main__` | Unhandled exception → exit 1 → confusing behavior |
| Python 3.10+ syntax | Type hints like `dict | None` | Need `from __future__ import annotations` |
| Missing directories | quality_reports/specs/ | Referenced in rules but never created |
| Always-on rule listing | Guide + README | meta-governance omitted from listings |
| macOS-only commands | Skills, rules | `open` without `xdg-open` fallback |
| Stale hook references | Rules, guide, CHANGELOG, settings.json | Removed hooks still mentioned somewhere |

## Output Format

After each round, report:

```
## Round N Audit Results

### Issues Found: X genuine, Y false alarms

| # | Severity | File | Issue | Status |
|---|----------|------|-------|--------|
| 1 | Critical | file.py:42 | Description | Fixed |
| 2 | Medium | file.qmd:100 | Description | Fixed |

### Verification
- [ ] No stale counts (grep confirms)
- [ ] All hooks have fail-open + future annotations
- [ ] Guide renders successfully
- [ ] docs/ updated

### Result: [CLEAN | N issues remaining]
```

## Findings are validated, not just written (v2.5)

This skill's reviewers emit findings under the machine-checked contract in
[`finding-schema.json`](../../../references/finding-schema.json). Reports are JSON **arrays**.

**Smoke-test the harness before spending review effort** — a run that fans out reviewers and
then cannot write a valid report has wasted the whole pass:

```bash
echo '[]' | python3 scripts/validate-findings.py
```

Reviewer agents are read-only, so **this skill writes the files**. For each reviewer's final
response: save the prose report to this skill's report path for that reviewer, copy its closing fenced `json` block
to a scratch file, and fill the ids while validating:

```bash
python3 scripts/validate-findings.py --fill-ids block.json > <report>.json.tmp \
  && mv <report>.json.tmp <report>.json || rm -f <report>.json.tmp   # exit 0 required; a failed run keeps no file
python3 scripts/validate-findings.py --check-quotes <report>.json   # each quote must be the file's own text (orchestration-schemas.md §1)
```

A reviewer that returned no `json` block, or a block that does not validate, has not reviewed:
re-dispatch it once with the validator's error text, then report the lens as missing rather
than reducing without it.

What the contract forces, and why:

- **`rule`** — the documented rule or standard violated. A finding citing no rule is an
  opinion, and opinions do not gate a commit.
- **`failing_case`** — a concrete configuration under which the claim breaks, or the exact
  missing hypothesis. *"This could be clearer"* does not validate.
- **`id = sha1("<file>:<line>:<locus>")`** — deterministic, so dedup across rounds is
  exact and the two-strikes rule is checkable rather than eyeballed.
- **`mechanical`** — `true` only for fixes that cannot change a result (typo, cross-reference,
  formatting, label). **Never** for an estimand, assumption, specification, inference
  procedure, sample definition, or reporting language: those return to the researcher.

Apply the **per-lens evidence burdens** and the **"does NOT count" filters** in
[`orchestration-schemas.md` §7](../../../references/orchestration-schemas.md) *before*
verification, so known false alarms never reach the judge. The verifier pass is
**refute-biased** and sets each finding's `verdict` (reviewers leave it unset): only `verdict: "confirmed"` findings ship; anything it cannot ground is
dropped, not downgraded to a warning.
