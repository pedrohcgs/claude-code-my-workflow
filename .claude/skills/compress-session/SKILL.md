---
name: compress-session
description: Distill the current conversation into a structured note (decisions made, open questions, file pointers with line numbers, next 1–3 actions) and save to `quality_reports/session_logs/` before auto-compression. Differs from `/checkpoint` (explicit stop-point snapshot) and from auto-compaction (which truncates rather than distills). Use when context is approaching auto-compact threshold, when a long pipeline has accumulated many decisions, or when the user says "compress", "distil this session", "before we hit auto-compact", "structured handoff before context resets".
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[optional-topic-slug]"
disable-model-invocation: true
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# `/compress-session` — distil, don't truncate

Auto-compaction is **lossy**: it keeps recent turns and drops earlier ones, with no preservation of *what was decided* mid-session. `/compress-session` is the **distil-not-truncate** alternative — produce a structured note that the next session can resume from in under a minute.

## Why this skill exists

Drew Breunig's ["How Long Contexts Fail"](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html) identifies four failure modes for long-context sessions:

1. **Poisoning** — early hallucinated content gets quoted by later turns, compounding the error.
2. **Distraction** — irrelevant earlier context dilutes the model's attention to current task.
3. **Confusion** — contradicted facts pile up; the model doesn't know which to trust.
4. **Clash** — multiple plans, decisions, or specs accumulate without explicit reconciliation.

The template's 200-line `MEMORY.md` cap defends against *distraction*. The plan-on-disk convention defends against *clash*. Nothing currently defends against *poisoning* or directly against *confusion* — that's what this skill is for.

## Distinction from `/checkpoint`

| | `/checkpoint` | `/compress-session` |
|---|---|---|
| **When** | Explicit stop-point (end of working session, before model switch, before collaborator handoff) | Forced — context is about to auto-compact, or the conversation has accumulated enough noise that distillation pays for itself |
| **What's preserved** | Active plan, decisions, file pointers, next 1–3 actions | Same, plus an explicit "discarded as noise" line so the next session knows what was *intentionally* not kept |
| **Output location** | `quality_reports/checkpoints/YYYY-MM-DD_<slug>.md` | `quality_reports/session_logs/YYYY-MM-DD_compression_<slug>.md` |
| **Triggering** | User-invoked at a natural pause | User-invoked when context fatigue shows, OR proposed via PreCompact hook |
| **Memory updates** | Optional auto-proposal of `[LEARN]` entries | Always proposes `[LEARN]` entries — distillation is exactly the moment when generalizable lessons surface |

Both skills are companions to the narrative session-log workflow at `quality_reports/session_logs/`. None replaces the others.

## When to use

- **Context is approaching auto-compact.** `/context-status` reports approaching threshold.
- **A long pipeline has accumulated noise.** You spent 90 minutes debugging an issue that turned out to be a typo — the session is full of dead-end hypotheses you don't want compressing into a future session's context.
- **Mid-plan handoff.** Different model, different machine, different collaborator.
- **PreCompact hook triggered.** The hook can call `/compress-session` automatically if the user has wired it in.

## When NOT to use

- **For a quick stop-point.** Use `/checkpoint`.
- **For narrative session logging.** That happens incrementally via the Stop hook ([session-logging.md](../../rules/session-logging.md)); no skill needed.
- **For starting a fresh session.** Use `/clear`. `/compress-session` is for preserving state, not for resetting.

## Steps

### Step 1: Identify the session

Read the most recent session log under `quality_reports/session_logs/`. If none exists, treat the current conversation as the source.

Optionally use `$ARGUMENTS` as a topic slug for the output filename.

### Step 2: Distil into structured sections

Produce a note with these sections:

```markdown
# Session Compression — <YYYY-MM-DD> <topic-slug>

**Source:** <session-log file or "current conversation">
**Token budget at compression:** <approximate %>
**Why compress now:** <approaching auto-compact | mid-plan handoff | accumulated noise | user-requested>

## Active state

- **Plan:** [link to active plan in `quality_reports/plans/` or "no active plan"]
- **Branch:** <git branch>
- **Last commit:** <SHA + subject>
- **Working tree:** <clean | N modified files>

## Decisions made (this session)

1. [Decision]. **Why:** [one sentence]. **Where recorded:** [file:line, plan, or memory].
2. ...

## Files touched

- [path:line] — [what changed, one sentence]
- ...

## Open questions

- [Question]. **Blocker?** [Yes/No]. **Where to resume:** [pointer].
- ...

## Next actions (1–3 only)

1. [Specific next step with file pointer]
2. ...

## Discarded as noise

Things explored during this session that should NOT carry forward — failed hypotheses, abandoned approaches, debugging dead-ends. Listing them explicitly defends against [Breunig's "poisoning" failure mode](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html) (hallucinated / wrong content from early turns getting quoted later).

- [Hypothesis / approach / dead-end] — [why it didn't work]
- ...

## Proposed `[LEARN]` entries

Lessons worth promoting to MEMORY.md (or personal-memory.md if machine-specific). User reviews; nothing auto-merged.

- `[LEARN:<category>]` <lesson>. **Evidence:** <pointer>.
- ...
```

### Step 3: Save

Write to `quality_reports/session_logs/YYYY-MM-DD_compression_<topic>.md` (slug derived from `$ARGUMENTS` or current plan name).

### Step 4: Surface a summary

Report to the user:

- Saved path.
- Counts (decisions made, files touched, open questions, next actions).
- Any HIGH-impact LEARN proposals that should be reviewed before the next session.

The user reviews. Nothing auto-merges into MEMORY.md — that's `/promote-memory`'s job.

## Pairing with PreCompact hook

Forkers who want automatic compression can wire `/compress-session` into the PreCompact hook:

```json
{
  "hooks": {
    "PreCompact": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'Run /compress-session before compacting' && exit 2",
        "timeout": 5
      }]
    }]
  }
}
```

The hook surfaces a reminder; the user runs `/compress-session` manually. We deliberately don't make the hook *auto-invoke* the skill — that bypasses the user's review step.

## Anti-patterns

- **Do not run `/compress-session` as a routine replacement for `/checkpoint`.** Checkpoints are cheap and frequent; compressions are heavier and reserved for forced compression.
- **Do not let the "Discarded as noise" section grow indefinitely.** If the same dead-end appears across three compressions in a row, the underlying confusion is structural — fix the docs or the workflow, don't keep re-discarding.
- **Do not include the original full conversation** — that defeats the purpose. Distillation is the point.

## Output

- Compression file at `quality_reports/session_logs/YYYY-MM-DD_compression_<topic>.md` (gitignored — session-state, not version-controlled).
- Summary in the conversation: counts + HIGH-impact `[LEARN]` proposals.
- No file edits outside the compression file.
