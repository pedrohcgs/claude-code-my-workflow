# Inter-Agent Communication Protocol

Agents communicate through the mailbox system (`quality_reports/mailbox.jsonl`), an append-only structured log. This replaces ad-hoc report files for cross-agent coordination.

## When to Use

| Scenario | Use Mailbox | Use quality_reports/ file |
|----------|------------|--------------------------|
| Single issue found by reviewer | Mailbox (type: issue) | -- |
| Full audit report | -- | Traditional report file |
| Fix applied by fixer | Mailbox (type: fix) | -- |
| Escalation after 3 rounds | Mailbox (type: escalation) | -- |
| Complex multi-issue report | -- | Traditional report file + mailbox summary |

## Orchestrator Integration

The lead orchestrator reads the mailbox at each step:
1. After reviewer runs -> read `type: issue` messages
2. After fixer runs -> read `type: fix` messages
3. After re-review -> read `type: approval` or `type: issue` for remaining problems
4. If `type: escalation` -> present to user

## Backward Compatibility

Existing `quality_reports/*_report.md` files continue to work. The mailbox is an additional channel for structured, machine-readable communication.
