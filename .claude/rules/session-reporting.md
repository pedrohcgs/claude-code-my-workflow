# Session Reporting (Consolidated)

**File:** `SESSION_REPORT.md` in project root
**Mirror:** `.claude/SESSION_REPORT.md` (kept in sync)

## Purpose

Maintain a single, append-only MD file that consolidates everything Claude does across sessions. Unlike session logs (which are per-session files in `quality_reports/session_logs/`), this is one living document that accumulates the full project history.

## Triggers

1. **End of every session** — proactively append a new entry before wrapping up
2. **On user request** — "update the report", "log what we did", "add to the report"
3. **After significant milestones** — commits, completed analyses, major decisions

## Entry Format

Each entry is a dated section appended to the file:

```markdown
## YYYY-MM-DD HH:MM — [Brief Title]

**Operations:**
- [Scripts run, files created/modified/deleted]
- [Commands executed, packages installed]

**Decisions:**
- [Choice made] — [rationale]

**Results:**
- [Key findings, outputs produced]
- [Errors encountered → how resolved]

**Commits:**
- `[hash]` [commit message]

**Status:**
- Done: [what's complete]
- Pending: [what remains]
```

## Rules

1. **Append only** — never overwrite or edit previous entries
2. **Concise** — bullet points, not prose; 5–15 lines per entry
3. **Include commit hashes** when commits are made during the session
4. **Include file paths** for any files created or significantly modified
5. **Create the file** if it doesn't exist; add a title header: `# Session Report — [Project Name]`
6. **Sync both copies** — root `SESSION_REPORT.md` and `.claude/SESSION_REPORT.md` must match
7. **Do not duplicate** session logs — this report is a higher-level summary; detailed session logs remain in `quality_reports/session_logs/`
