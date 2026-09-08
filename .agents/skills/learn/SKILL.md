---
name: learn
description: Convert a non-obvious, reusable workflow discovered during the current session into a repository Codex skill. Use only when explicitly invoked with $learn; use $checkpoint for task state rather than reusable procedure.
---

# Learn a reusable workflow

Identify the demonstrated problem, the reliable approach, its trigger conditions, and the evidence that the approach works. Do not generalize from a one-off accident.

Create or update `.agents/skills/<name>/SKILL.md` using `templates/codex-skill-template.md` and the native skill-creator conventions. Keep only supported frontmatter. Add `agents/openai.yaml` with `allow_implicit_invocation: false` when the user wants explicit-only invocation. Use `$skill-name` for skill references and repository-native paths.

Validate the result with:

```bash
python3 /Users/tannera.parsons/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/<name>
```

Report the evidence behind the learning and the validation result.

