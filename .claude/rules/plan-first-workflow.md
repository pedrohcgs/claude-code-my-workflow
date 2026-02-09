# Plan-First Workflow & Context Preservation

**These rules apply to ALL tasks, regardless of file type.**

---

## Rule 1: Plan Before You Build

**For any non-trivial task, enter Plan Mode FIRST before writing code or making edits.**

A task is "non-trivial" if it involves:
- Creating or modifying more than one file
- Implementing a new feature or workflow
- Translating between formats (Beamer to Quarto, Stata to R)
- Any task the user describes with multiple steps
- Any task where the approach is not immediately obvious

### The Plan-First Protocol

1. **Enter Plan Mode** — use `EnterPlanMode` to switch to planning
1.5. **Check institutional memory** — read `MEMORY.md` for any `[LEARN]` entries relevant to this task
2. **Draft the plan** — outline what will change, which files are affected, and in what order
3. **Save the plan** — write it to `quality_reports/plans/` (see Rule 2)
4. **Present to user** — explain the plan and wait for approval
5. **Only after approval** — exit plan mode
6. **Immediately save initial session log** — capture the goal, plan summary, and key context while it's fresh (see Rule 5)
7. **Implement via orchestrator** — the orchestrator protocol takes over (see `orchestrator-protocol.md`): implement → verify → review → fix → score → present results

### What a Good Plan Includes

- **Task description** — what are we trying to accomplish?
- **Files to modify** — which files will be created, edited, or deleted?
- **Approach** — step-by-step implementation strategy
- **Dependencies** — what must happen before what?
- **Verification steps** — how will we confirm it worked?
- **Risks** — what could go wrong?

### When to Skip Planning

You may skip plan mode for:
- Single-file edits with a clear scope (fix a typo, add a citation)
- Running existing skills/commands (`/compile-latex`, `/deploy`)
- Purely informational questions
- Tasks the user explicitly says to do immediately

---

## Rule 2: Save Plans to Disk

**Every plan must be saved to a file so it survives context compression.**

### Where to Save

```
quality_reports/plans/
├── 2026-02-06_translate-lecture5.md
├── 2026-02-06_fix-tikz-diagrams.md
└── ...
```

### Naming Convention

`YYYY-MM-DD_short-description.md`

### Plan File Format

```markdown
# Plan: [Short Description]

**Date:** [YYYY-MM-DD HH:MM]
**Status:** DRAFT | APPROVED | IN PROGRESS | COMPLETED
**Task:** [What the user asked for]

## Approach

1. [Step 1]
2. [Step 2]
3. ...

## Files to Modify

- `path/to/file1.ext` — [what changes]
- `path/to/file2.ext` — [what changes]

## Verification

- [ ] [How to verify step 1]
- [ ] [How to verify step 2]

## Notes

[Any risks, open questions, or decisions made]
```

### When to Update the Plan

- **Before starting:** Status = APPROVED
- **During implementation:** Check off completed steps
- **After completion:** Status = COMPLETED, add any deviations noted
- **If the plan changes:** Update the file and note what changed and why

---

## Rule 3: Never /clear — Rely on Auto-Compression

**NEVER use `/clear` to reset the conversation. Use auto-compression instead.**

### Why This Matters

- `/clear` is a **nuclear option** — it destroys ALL context, including design decisions, corrections, and the mental model of the project
- Auto-compression is **graceful degradation** — Claude Code's built-in compression preserves the most important context while freeing space
- Saved plans (Rule 2) provide a **safety net** — even if compression loses details, the plan file on disk has the full strategy

### What to Do When Context Gets Long

1. **Let auto-compression handle it.** Claude Code will compress automatically when needed.
2. **Save important context to disk** — plans, decisions, correction logs
3. **Reference saved files** — point Claude to the plan file or quality report if context seems thin
4. **Start a new session if truly needed** — but start by reading the saved plan and recent git log, not from a blank slate

### Session Recovery Protocol

If starting a new session (or after heavy compression):

1. Read `CLAUDE.md` for project context
2. Read the most recent plan in `quality_reports/plans/`
3. Check `git log --oneline -10` for recent changes
4. Check `git diff` for any uncommitted work
5. State what you understand the current task to be

---

## Rule 4: Continuous Learning with [LEARN] Tags

**When a mistake is corrected, immediately save a `[LEARN:tag]` entry to MEMORY.md.**

Format: `[LEARN:category] Incorrect assumption → correct fact`

Common categories: `notation`, `citation`, `r-code`, `workflow`, `latex`. Add a tag whenever the user corrects a factual claim, a compilation error reveals a wrong assumption, or a review agent catches a systematic error. These persist across sessions and prevent repeating the same mistake.

---

## Rule 5: Session Logging

**Session logs live at `quality_reports/session_logs/YYYY-MM-DD_description.md`.** They are a running record of *why* things happened — not what changed (git handles that).

There are **three distinct logging triggers:**

1. **Post-Plan Log** — immediately after plan approval, capture goal, approach, rationale
2. **Incremental Logging** — append 1-3 lines whenever a decision is made, a problem is solved, or the approach changes
3. **End-of-Session Log** — summary, open questions, blockers

**All three are proactive — do not wait to be asked.**

See `.claude/rules/session-logging.md` for the full protocol, enhanced template, and merge-only quality reporting.
