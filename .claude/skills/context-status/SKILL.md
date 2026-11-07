---
name: context-status
description: |
  Show current context status and session health.
  Use to check how much context has been used, whether auto-compact is
  approaching, and what state will be preserved.
allowed-tools: ["Read", "Bash", "Glob"]
disallowed-tools: ["Edit", "MultiEdit"]
metadata:
  author: Claude Code Academic Workflow
  version: 1.0.0
---

# /context-status — Check Session Health

Show the current session status including context usage, active plan,
and preservation state.

## What This Skill Shows

1. **Context usage** — the % of the context window Claude Code reports
2. **Active plan** — Current plan file and status
3. **Session log** — Most recent session log
4. **Preservation state** — What will survive compaction

## Workflow

### Step 1: Check Context Usage

Claude Code reports it itself: the status line shows `ctx N%` (Claude Code's `context_window.used_percentage`), and the built-in `/context` command shows the full breakdown. Read the figure from either; this skill does not estimate it. (Until v2.9.1 a context-monitor hook kept its own estimate; it was removed.)

### Step 2: Find Active Plan

```bash
ls -lt quality_reports/plans/*.md 2>/dev/null | head -3
```

### Step 3: Find Session Log

```bash
ls -lt quality_reports/session_logs/*.md 2>/dev/null | head -1
```

### Step 4: Report Status

Format the output:

```
📊 Session Status
─────────────────────────────────
Context Usage:  XX% (from the status line or /context)
Auto-compact:   [approaching | not imminent]

📋 Active Plan
File:   quality_reports/plans/YYYY-MM-DD_description.md
Status: [draft | approved | in_progress | completed]
Task:   [current unchecked task or "none"]

📝 Session Log
File:   quality_reports/session_logs/YYYY-MM-DD_description.md

✓ Preservation Check
  • Pre-compact hook: [configured | missing]
  • Post-compact restore: [configured | missing]
  • Session state will be saved before compaction
```

## Notes

- Context % comes from Claude Code's own `context_window.used_percentage`, shown by the status line; it can be empty early in a session. The built-in `/context` shows exact usage
- Actual compaction is triggered by Claude Code automatically
- All important state is saved to disk (plans, logs, MEMORY.md)
