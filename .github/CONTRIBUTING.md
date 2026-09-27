# Contributing

This repository is a **template** designed for academic researchers to fork and customize. Contributions back to the template should help **all** users, not just one fork.

## What we welcome

- **Bug fixes** in shared infrastructure (skills, agents, rules, hooks, scripts).
- **New skills/agents/rules** that generalize across academic domains (economics, biology, physics, CS, etc.).
- **Documentation improvements** — guide, README, examples, troubleshooting.
- **Pedagogical improvements** — clearer onboarding, better Day 1 experience.
- **2026+ Claude Code feature integration** — when new hooks, frontmatter fields, or capabilities ship.

## What belongs in your fork (not here)

- Project-specific lectures, papers, or data.
- Custom domain-reviewer content (econometrics-only, biology-only, etc.) — keep yours in your fork; PR back the *template* not the *instance*.
- Personal preferences (your favorite color in `theme-template.scss`).
- Local paths, API keys, machine-specific settings.

## Before you open a PR

1. **Open an issue first** for new features or non-trivial changes. We may already be working on it or have a different design in mind.
2. **Read [CLAUDE.md](../CLAUDE.md) and the [guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html)** so your contribution fits the existing patterns.
3. **Run the validate script** to confirm you don't break the onboarding path:
   ```bash
   ./scripts/validate-setup.sh
   ```
4. **Run quality gates** on any `.qmd`, `.tex`, or `.R` you modify:
   ```bash
   python3 scripts/quality_score.py path/to/file
   ```
5. **Test against ≥2 domains** when adding skills/agents — show that your contribution generalizes.
6. **Install the gate once:** `./scripts/install-hooks.sh` points `core.hooksPath` at `.githooks/`, so every commit runs the **backtest gate suite** (all eleven gates — see `scripts/backtest.sh` — with the hook battery skipped when no hook, its settings or the battery itself is staged) plus the quality (≥80) check locally. CI runs the backtest suite too; quality scoring (which needs Quarto/R) stays local-only.
7. **Keep the surfaces in sync** when adding features. Adding a skill means **adding its row to the README `<!-- surface-sync-table: skills -->` table** *and* keeping the prose counts (the "NN skills / NN rules" phrasings) in sync across `README.md`, `docs/index.html`, the guide, `templates/skill-template.md`, and `.claude/skills/commit/SKILL.md`. `./scripts/check-surface-sync.sh` enforces **both** the counts and the table rows — run it before you open a PR.

## PR style

- **Branch naming**: `feat/short-name`, `fix/short-name`, `chore/short-name`, `docs/short-name`.
- **Commit messages**: imperative mood ("add", "fix", "refactor"), explain *why* in the body.
- **Co-author Claude** if Claude Code helped: `Co-Authored-By: Claude <noreply@anthropic.com>` (version-free — model names drift).
- **Use the PR template** (auto-loaded when you open a PR).
- **Squash before merging** if your branch has many WIP commits.

## Running `/deep-audit` before submitting

We use `/deep-audit` to catch consistency drift across the repo (skill counts, hook configs, doc references). Run it before opening your PR:

```text
/deep-audit
```

If it surfaces issues, fix them in the same PR.

## Code of conduct

Be kind. Academic work is hard enough without rude reviews. If you disagree with a decision, explain why with examples — don't just say "this is wrong."

## Questions?

Open an issue with the `question` label.
