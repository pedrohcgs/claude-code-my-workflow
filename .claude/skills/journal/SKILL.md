---
name: journal
description: Regenerate the research journal timeline from quality reports and git history. Shows chronological record of all agent actions, phase transitions, scores, and decisions. Use to review project history or audit the research process.
argument-hint: "[optional: 'full' for complete history, 'recent' for last 7 days]"
allowed-tools: ["Read", "Grep", "Glob", "Bash"]
---

# Research Journal

Regenerate the research journal timeline from project artifacts.

**Input:** `$ARGUMENTS` — `full` for complete history, `recent` for last 7 days. Defaults to `recent`.

---

## Workflow

### Step 1: Gather Sources

1. Read `quality_reports/research_journal.md` if it exists (auto-appended by agents per `research-journal.md` rule)
2. Scan `quality_reports/` for all reports (reviews, audits, specs)
3. Read `git log --oneline -50` for commit history
4. Read `SESSION_REPORT.md` for session summaries
5. Read `quality_reports/session_logs/` for detailed session logs

### Step 2: Build Timeline

For each event, extract:
- **Date/time**
- **Agent** that acted
- **Phase** (Discovery / Strategy / Execution / Peer Review / Submission)
- **Action** (reviewed, created, scored, escalated, approved)
- **Target** (file or artifact)
- **Score** (if applicable)
- **Verdict** (PASS/FAIL/REVISE)

### Step 3: Present Timeline

```markdown
# Research Journal: [Project Name]
**Generated:** [YYYY-MM-DD]
**Scope:** [Full / Last 7 days]

## Timeline

### [Date]
| Time | Agent | Phase | Action | Target | Score | Verdict |
|------|-------|-------|--------|--------|-------|---------|
| HH:MM | Econometrician | Strategy | Reviewed | strategy_memo.md | 85 | PASS |
| HH:MM | Debugger | Execution | Reviewed | analysis.R | 72 | REVISE |

### [Earlier Date]
...

## Phase Summary
| Phase | Status | Last Activity |
|-------|--------|--------------|
| Discovery | Complete | [date] |
| Strategy | Complete | [date] |
| Execution | In Progress | [date] |
| Peer Review | Not Started | — |
| Submission | Not Started | — |

## Score Trajectory
| Date | Aggregate | Identification | Code | Paper |
|------|-----------|---------------|------|-------|
| [date] | XX | XX | XX | XX |

## Escalations
[Any three-strikes escalations that occurred]

## Decisions
[Key decisions made by user or editor]
```

---

## Principles

- **Read-only.** This skill only reads and synthesizes — it never modifies project files.
- **Chronological.** Events ordered by time, not by agent or phase.
- **Audit trail.** This is the evidence that the research process was systematic.
- **Score trajectory.** Show how quality improved over iterations.
