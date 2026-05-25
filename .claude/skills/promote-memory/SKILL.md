---
name: promote-memory
description: Review candidate `[LEARN]` entries in `.claude/state/personal-memory.md` (gitignored) and run them through a five-critic council in parallel: generality, staleness, redundancy, evidence, format. Majority vote (3+ of 5) promotes the entry to MEMORY.md. Use when user says "promote memory", "review my learnings", "what should graduate to MEMORY.md", "five-critic council", or as monthly memory maintenance.
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[entry-substring or 'all']"
disable-model-invocation: true
allowed-tools: ["Read", "Write", "Glob", "Grep", "Task", "Bash"]
---

<!-- Pattern adapted with attribution from Chris Blattman's claudeblattman v2.1
     "Five-critic council" (claudeblattman.com, Apr 2026 continuous-improvement
     loop). Blattman uses it to decide what enters his MEMORY layer; we adapt
     it to the personal-memory → MEMORY.md promotion question codified in
     .claude/rules/meta-governance.md. -->

# `/promote-memory` — five-critic council for memory promotion

The template's [`meta-governance.md`](../../rules/meta-governance.md) rule splits memory into two tiers:

- **`MEMORY.md`** (committed, ≤ 200 lines) — generic learnings that help all forkers.
- **`.claude/state/personal-memory.md`** (gitignored, no size cap) — machine-specific and user-specific learnings.

The rule says generic patterns should sync via git; personal patterns stay local. **What it doesn't say** is *who decides which is which*. `/promote-memory` operationalizes the call: spawn five critics in parallel, each reviewing the candidate `[LEARN]` entries on a single dimension, and promote on majority vote (3+ of 5).

## When to use

- **Monthly memory maintenance.** Personal-memory accumulates faster than MEMORY.md; the council periodically harvests the genuinely generic learnings.
- **Before sharing a fork.** Someone is about to clone your template — what should they inherit?
- **After a large project ships.** Lessons from a paper or a course cycle deserve curation before the next project starts adding noise.
- **As a `/loop` task.** Wire `/loop monthly /promote-memory all` if you want automated proposal cadence (still requires user approval for each promotion).

## When NOT to use

- **For a single fresh `[LEARN]` after a single correction.** Just add it to personal-memory.md; let it sit until the next council runs.
- **For deleting stale entries.** Use `/learn --revoke` or manual edit. `/promote-memory` only promotes; it doesn't demote.
- **For project-specific context.** That belongs in CLAUDE.md or session logs, not in either memory tier.

## The five critics

Each critic runs in a forked context (`Task` with `context=fork`) — they don't see each other's verdicts or the user's draft. Each casts one **YES/NO** vote per candidate entry with a one-sentence rationale.

### 1. Generality critic

> "Would a non-econ forker benefit from this `[LEARN]` entry — a biology PhD, a sociology postdoc, a CS instructor? If the lesson is specific to *your* setup (your bibliography path, your machine's TeX install, your discipline's notation), vote NO."

### 2. Staleness critic

> "Does this entry contradict the current state of the codebase? Run `grep -r` on the file paths, function names, or settings the entry references. If the referenced thing has been renamed, removed, or significantly changed, vote NO — the entry is stale and would mislead a future session."

### 3. Redundancy critic

> "Is this lesson already encoded in MEMORY.md, CLAUDE.md, or an existing rule? Read the relevant files. If yes (even paraphrased), vote NO — duplication erodes the index's signal."

### 4. Evidence critic

> "Does the entry cite the incident, file path, or specific case that motivated it? If the entry is `[LEARN:foo] always do X` with no anchor to *why*, vote NO. Future Claude can't judge edge cases without the rationale."

### 5. Format critic

> "Does the entry follow the schema in [`.claude/rules/meta-governance.md`](.claude/rules/meta-governance.md): `[LEARN:category] wrong → right` for corrections, structured `**Why:**` + `**How to apply:**` for feedback/project entries? If it's just a free-form note, vote NO — fix the format first, then re-submit."

### Council verdict

Each critic returns YES/NO + rationale. The promotion threshold is **majority (3+ YES)**.

- **5 YES** — promote without modification.
- **4 YES** — promote with a one-line note about the dissenting concern.
- **3 YES** — promote but address the dissenting critics' concerns first (typically: trim, add evidence, fix format).
- **2 or fewer YES** — do not promote. Either fix the entry per the dissenting critics' feedback and re-submit, or leave in personal-memory.md.

## Steps

### Step 1: Read candidate entries

If `$ARGUMENTS` is `all`, read every `[LEARN:*]` entry in `.claude/state/personal-memory.md`. Otherwise treat `$ARGUMENTS` as a substring filter (e.g., `r-code` matches all `[LEARN:r-code]` entries).

### Step 2: Spawn the council

Five `Task` invocations in parallel, one per critic, each with `context: fork`:

- **Generality critic** — context: the candidate entry + a one-paragraph description of who the template's audience is (academic researchers across disciplines).
- **Staleness critic** — context: the candidate entry + the ability to `Read` / `Grep` the codebase. Should explicitly check any file paths / function names / settings the entry references.
- **Redundancy critic** — context: the candidate entry + the current `MEMORY.md` + `CLAUDE.md` + relevant rule files.
- **Evidence critic** — context: the candidate entry only. Vote based on whether the entry self-describes its motivation.
- **Format critic** — context: the candidate entry + [`.claude/rules/meta-governance.md`](.claude/rules/meta-governance.md) for the schema reference.

Use **Haiku 4.5** for all five critics (per [`.claude/rules/model-routing.md`](../../rules/model-routing.md): mechanical-ish review work). The user can override via the agent's `model:` field if they want Sonnet for the harder calls.

### Step 3: Aggregate votes

Collect verdicts. For each candidate entry, compute the vote count + per-critic verdicts.

### Step 4: Present the verdicts

For each entry:

```markdown
## `[LEARN:foo] <summary>`

**Vote:** 4-of-5 YES (promote with note)

| Critic | Vote | Rationale |
|---|:---:|---|
| Generality | YES | ... |
| Staleness | YES | ... |
| Redundancy | YES | ... |
| Evidence | NO  | Entry doesn't cite the originating incident. Add a one-line "Incident:" pointer before promoting. |
| Format | YES | ... |

**Recommendation:** Address Evidence critic, then promote.

**Proposed MEMORY.md addition:**
```text
[LEARN:foo] <full proposed text>
```
```

### Step 5: User approves the promotions

The user reviews the report and explicitly approves which entries to promote. The skill writes approved entries to MEMORY.md, removes the same entries from personal-memory.md (or marks them with `# promoted YYYY-MM-DD` for audit), and surfaces a summary.

Do **not** auto-promote — even on 5-of-5 YES votes. The user's approval is the final gate.

## Output

- Per-entry council report (verdicts, rationales, recommendations) — to the conversation.
- On approval: MEMORY.md updated (append at appropriate `[LEARN:category]` section), personal-memory.md updated (entry marked promoted).
- A `quality_reports/memory_promotion_<date>.md` audit file recording the full council session for forensics.

## Anti-patterns

- **Auto-promoting on 5-of-5 YES.** Even unanimous critic agreement can be wrong; the user's domain judgment is the final gate.
- **Re-running the council on the same entry repeatedly** hoping for a different result. If 4 critics consistently say NO, the entry doesn't belong in MEMORY.md — file it in personal-memory.md and stop.
- **Skipping the Evidence critic** because the entry "looks obvious." Evidence is what makes the entry portable across forkers; obvious-to-you ≠ obvious-to-them.
- **Demoting via this skill.** It only promotes. Demotion is a manual edit + commit.

## Cross-references

- [`.claude/rules/meta-governance.md`](../../rules/meta-governance.md) — the two-tier memory contract this skill operationalizes.
- [`.claude/agents/promote-memory-council.md`](../../agents/promote-memory-council.md) — the five-critic implementation (one agent file with five role specs, dispatched in parallel via `Task`).
- [`.claude/rules/model-routing.md`](../../rules/model-routing.md) — why critics default to Haiku tier.
- `/learn` (existing skill) — captures new `[LEARN]` entries; pairs with `/promote-memory` (which decides what graduates).
