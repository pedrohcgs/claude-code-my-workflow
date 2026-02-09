# Session Logging Protocol

## Why Log?

- **Git** captures WHAT changed (commit diffs)
- **Session logs** capture WHY it changed and reflect on decisions
- **Prevents rework:** `[LEARN:tag]` annotations prevent repeated mistakes
- **Survives compression:** Saved in `quality_reports/session_logs/` (not in context window)
- **Multi-session continuity:** Pick up where you left off without re-reading conversation

---

## Where Session Logs Live

```
quality_reports/session_logs/
├── 2026-02-08_workflow_integration.md
├── 2026-02-09_add_simulation.md
└── [YYYY-MM-DD_description].md
```

**Naming:** `YYYY-MM-DD_short-description.md`

---

## Log Entry Template

```markdown
# Session Log: [Date] — [Brief Title]

**Status:** IN PROGRESS | COMPLETED

## Objective
[What we set out to accomplish this session]

## Changes Made

| File | Change | Reason | Quality Score |
|------|--------|--------|---|
| `path/to/file` | [What changed] | [Why] | [N]/100 |

## Design Decisions

| Decision | Alternatives Considered | Rationale |
|----------|------------------------|-----------|
| [Choice made] | [Other options] | [Why this one] |

## Incremental Work Log

**HH:MM UTC:** [event description]
**HH:MM UTC:** [event description]

## Learnings & Corrections

- [LEARN:category] What you learned for future reference

## Verification Results

| Check | Result | Status |
|-------|--------|--------|
| [What was checked] | [Result] | PASS / FAIL |

## Quality Gate Status

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| [Metric] | [Score] | >= [N] | PASS / FAIL |

## Open Questions / Blockers

- [ ] [Question or blocker]

## Next Steps

- [ ] [What remains]
```

---

## Three Logging Triggers

### 1. Post-Plan Log (Immediate)

**When:** Plan is approved, BEFORE implementation starts

**Content:** Capture decisions while discussion context is richest
- Task description
- Approved approach + rejected alternatives
- Key assumptions + design rationale
- Verification strategy

### 2. Incremental Logging (During Implementation)

**When:** As you work, append whenever something worth remembering happens

**Triggers:**
- Design decision made or changed mid-implementation
- Unexpected problem discovered and solved
- User expresses preference or corrects assumption
- Review agent catches something significant
- Approach deviates from original plan
- Bug found and fixed

**Append immediately — do not batch.** 1-3 lines per entry.

### 3. End-of-Session Log (Closing)

**When:** Session is ending (user says "wrap up", "commit this", "done")

**Content:**
- High-level summary (2-3 sentences)
- Quality score(s)
- Open questions for next session
- Any blockers or issues

**Do not wait to be asked for any of these.** All three behaviors are proactive.

---

## Quality Reports: Merge Only

**Quality reports are generated ONLY at merge time** (not at every commit or PR):

- **Before commit:** No quality report (too frequent, creates overhead)
- **Before PR:** No quality report (use session logs instead)
- **Before merge to main:** Generate quality report and save to `quality_reports/merges/`

**Why:** Commits are frequent and incremental. Session logs capture the thinking during development. Merge quality reports provide a permanent, high-level snapshot of what was merged and why.

See `.claude/rules/quality-gates.md` for the merge quality report template.

---

## Integration with Plan-First Workflow

```
1. User requests task
   ↓
2. Plan mode: draft + approve
   ↓
3. POST-PLAN LOG: Save goal, approach, rationale
   ↓
4. Orchestrator activates: implement → verify → review → fix
   ↓
5. INCREMENTAL LOGS: Append design decisions, bugs fixed, surprises
   ↓
6. Orchestrator loop: quality gates, agent feedback
   ↓
7. More INCREMENTAL LOGS: Fixes applied, tolerance checks
   ↓
8. Loop complete: score >= 80 or max rounds reached
   ↓
9. END-OF-SESSION LOG: Summary, open questions, blockers
   ↓
10. Commits (lightweight, no quality reports per commit)
   ↓
11. Merge to main
   ↓
12. MERGE QUALITY REPORT: Final verification + permanent snapshot
```

---

## Stop Hook: Reminder to Update Logs

A lightweight Stop hook runs every N responses and reminds you to update the session log:

```
Reminder: Have you updated your session log?
Location: quality_reports/session_logs/[date].md
```

Configure the threshold in `.claude/settings.json` via the `scripts/log-reminder.py` hook.

---

## Quick Reference

- **Log location:** `quality_reports/session_logs/YYYY-MM-DD_description.md`
- **Three triggers:** Post-plan (once) + incremental (as you work) + end-of-session (once)
- **Append immediately:** Don't batch; append 1-3 lines as events happen
- **Survives context compression:** Saved to disk, not affected by auto-compression
- **Linked to MEMORY.md:** Important learnings move to MEMORY.md for next session
