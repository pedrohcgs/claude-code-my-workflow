# Meta-governance

Repository-wide behavior lives in `AGENTS.md`; detailed policy in `.codex/guidance/`; skills in `.agents/skills/`; agent profiles in `.codex/agents/`; hooks in `.codex/hooks/`; and executable command policy in `.codex/rules/`.

Committed artifacts must be portable, reviewable, and useful to collaborators. Machine paths, credentials, account details, private data, temporary state, caches, and personal preferences stay uncommitted.

`MEMORY.md` is the only repository-level durable memory. Promote a lesson only when general, evidence-backed, nonredundant, unlikely to stale silently, and free of sensitive or machine-local details. Each lesson states the failure/risk, actionable rule, scope, verification evidence, and review trigger.

Changes to `AGENTS.md`, `.agents/skills/`, or `.codex/` are infrastructure changes. Inspect linked references, preserve user-over-skill precedence, update validation inventories, run platform validation, and summarize behavior rather than merely listing files. Never weaken a guardrail to make validation pass.

Project names, institutions, bibliography locations, commands, and outputs belong in project guidance instead of generic rules.
