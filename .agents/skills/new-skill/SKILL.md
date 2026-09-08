---
name: new-skill
description: Create a repository-native Codex skill from a clearly defined repeated workflow. Use when the user asks to scaffold or write a skill; use $learn when converting a demonstrated session discovery.
---

# Create a Codex skill

Read the native skill-creator instructions and `templates/codex-skill-template.md`. Resolve the capability, activation cases, exclusions, outputs, side effects, and verification before writing.

Create `.agents/skills/<kebab-case-name>/SKILL.md` with only supported frontmatter: required `name` and `description`, plus supported metadata only when useful. Keep the entrypoint concise; put conditional detail in `references/`, repeated deterministic work in `scripts/`, and output assets in `assets/`. Use `$skill-name` for cross-skill invocation.

Add `agents/openai.yaml` only when UI metadata, dependencies, or explicit-only policy is needed. Never infer explicit-only policy merely because a workflow is sensitive.

Validate with the bundled `quick_validate.py`, inspect every referenced resource, and run any new scripts. Do not modify `AGENTS.md`, hooks, rules, or unrelated documentation unless separately requested.

