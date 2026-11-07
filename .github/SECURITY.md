# Security Policy

This is a template for academic research workflows. It ships **hooks that execute locally** (`.claude/hooks/*.py`, `.githooks/pre-commit`), **skills that drive autonomous review loops**, and **guidance for handling restricted/confidential data** — so security reports are taken seriously even though the repo contains no service or secrets itself.

## Reporting a vulnerability

- **Preferred:** open a [private security advisory](https://github.com/pedrohcgs/claude-code-my-workflow/security/advisories/new) on GitHub.
- Please do **not** open a public issue for anything that could expose a forker's data (e.g., a hook that leaks file contents, a guardrail bypass, an unattended-routine footgun).

In scope, for example:

- Bypasses of the destructive-git deny rules in `.claude/settings.json`, of `dirty-tree-guard.py`, or of the pre-commit gate. The rewritten spellings the deny rules are documented not to match (`git -C . push`, `git -c x=y push`, `bash -c '...'`) are known limits, not vulnerabilities.
- A skill/hook that could exfiltrate or overwrite user data outside the repo.
- Incorrect security guidance (e.g., a documented pattern that claims to sandbox but does not — see the `allowed-tools` vs `disallowed-tools` note in `templates/skill-template.md`).
- Flaws in the confidential-data guidance (`.claude/rules/confidential-data.md`) that could lead to restricted-data exposure.

## What to expect

Solo-maintained academic project: acknowledgement within a week is the goal, a fix or documented mitigation as soon as practical. Credit given in the CHANGELOG unless you prefer otherwise.

## Not in scope

- Vulnerabilities in Claude Code itself → report to [Anthropic](https://www.anthropic.com/responsible-disclosure-policy).
- Vulnerabilities in third-party R/Stata/Python packages the skills orchestrate → report upstream.
