---
name: skill-name
description: State what the skill does and the concrete requests that should activate it. Include a boundary only when it prevents likely misrouting.
---

# Skill title

State the outcome this skill should produce and any non-obvious context another Codex instance needs.

## Workflow

Describe only the decisions and steps that materially improve the work. Preserve user intent and authorization boundaries.

## Verification

Name observable checks that establish success. Do not claim completion when required evidence is unavailable.

<!--
Optional structure:
- agents/openai.yaml for UI metadata or explicit-only invocation policy
- scripts/ for deterministic repeated operations
- references/ for conditional, substantial guidance
- assets/ for files copied into generated output

Invoke other skills with $skill-name. Repository skills live under .agents/skills/.
-->
