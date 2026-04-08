---
name: mailbox
description: Structured inter-agent communication via append-only JSONL log. Send and read messages between agents.
allowed-tools:
  - Read
  - Write
  - Grep
  - Bash
---

# Mailbox -- Inter-Agent Communication

Structured, append-only communication between agents. Replaces ad-hoc quality report files for cross-agent coordination.

See: `.claude/rules/inter-agent-communication.md`

## Operations

### SEND

Append a message to `quality_reports/mailbox.jsonl`:

```json
{
  "timestamp": "2026-04-07T14:30:00Z",
  "sender": "proofreader",
  "recipient": "quarto-fixer",
  "type": "issue",
  "subject": "Notation mismatch on slide 42",
  "body": "Line 523: uses inconsistent notation",
  "ref_file": "Quarto/Lecture2_Topic.qmd",
  "ref_line": 523,
  "severity": "critical"
}
```

### READ

Filter messages by recipient, type, severity, or time range:

```bash
# All messages for a specific agent
grep '"recipient":"quarto-fixer"' quality_reports/mailbox.jsonl

# All critical issues
grep '"severity":"critical"' quality_reports/mailbox.jsonl

# All unresolved issues (no matching fix)
# Compare issue messages against fix messages by subject
```

## Message Types

| Type | From | To | Purpose |
|------|------|----|---------|
| `issue` | Reviewer | Fixer/Orchestrator | Report a problem found |
| `fix` | Fixer | Reviewer | Report fix applied |
| `approval` | Reviewer | Orchestrator | Issue verified as resolved |
| `escalation` | Any agent | User | Cannot resolve after 3 rounds |
| `info` | Any agent | All | Status update, discovery |

## Rules

1. **Append-only** -- no edits, no deletions (audit trail)
2. **Structured** -- every message has all required fields
3. **Timestamped** -- UTC ISO 8601
4. **Severity levels** -- critical, major, minor (matches quality-gates.md)

## Backward Compatibility

Existing `quality_reports/*_report.md` files continue to work. The mailbox is an additional channel for structured, machine-readable communication.
