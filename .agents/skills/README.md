# Project-Local Skills

This directory contains project-local Codex skills that should travel with the repo.

## Track In Repo And Bridge Into `.claude/skills/`

These are broadly reusable frontend/design helpers. They are useful in both Codex and Claude-style skill discovery, so keeping checked-in bridge symlinks under `.claude/skills/` is intentional.

- `design-review`
- `design-system`
- `frontend-design`
- `landing-page-design`
- `responsive-design`
- `semantic-html`
- `teach-impeccable`
- `web-component-design`
- `web-design-guidelines`
- `web-design-reviewer`

## Track In Repo, Keep Agents-Only

These should stay versioned in `.agents/skills/`, but should not be bridged into `.claude/skills/` by default.

- `knowledge-mgmt-updater`
  Reason: tightly coupled to this repo's `knowledge_mgmt/` structure and deliverables archive.
- `price-comparison-data-hygiene`
  Reason: specific to this repo's retail price-comparison workflow and source files.
- `skill-creator-codex`
  Reason: Codex-specific counterpart to the existing core `.claude/skills/skill-creator`; bridging both would create overlapping triggers.

## Core `.claude/skills/` Directories That Should Also Be Versioned

These are not bridge symlinks from `.agents/skills/`, but they are part of the shared workflow and should remain tracked.

- `.claude/skills/group-meeting-ppt/`
  Reason: explicitly referenced in project workflow and provides a concrete slash-command workflow used by this repo.
- `.claude/skills/skill-creator/`
  Reason: core skill infrastructure with scripts, references, and assets; this is shared workflow logic, not machine-local scratch data.

## Local-Only Exception

Use `.claude/skills/local/` for scratch or machine-specific skills that should not be committed.
