---
name: ship
description: Full commit-push-PR-merge workflow in one command. Stages files, commits with message, creates PR, and merges to main.
argument-hint: "[brief description of changes]"
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Ship: Commit -> Push -> PR -> Merge

Fast-track workflow for committing changes, creating a PR, and merging to main in a single command.

## Usage

```
/ship Add security hooks and inter-agent communication
/ship Fix notation inconsistency in Lecture 3 slides
```

## Workflow

1. **Gather context** -- `git status`, `git diff`, recent commits
2. **Stage files** -- Add modified and new files (exclude large binaries, credentials)
3. **Create branch** -- Auto-derived from description
4. **Commit** -- Create commit with description as message
5. **Push** -- Push to remote with `-u` flag
6. **Create PR** -- Use `gh pr create` with auto-generated body
7. **Merge** -- Merge PR to main via `gh pr merge`

## What Gets Committed

- Modified files (`.tex`, `.qmd`, `.R`, `.md`, `.json`, etc.)
- New files (except large binaries)
- **Excluded:** `.env` files, large PDFs (>50MB), node_modules, build artifacts

## Branch Naming

Branch name is auto-derived from description:
- Input: `"Add security hooks and inter-agent communication"`
- Branch: `add-security-hooks-inter-agent-communication`

## PR Body

Includes:
- Summary (auto-generated from commit message and diff)
- Test plan checklist
- Generated-by footer

## Requirements

- `gh` CLI installed and authenticated
- Git repository with remote configured
- Changes to commit (won't create empty commits)

## Comparison with /commit

| Feature | /commit | /ship |
|---------|---------|-------|
| Stage + commit | Yes | Yes |
| Create branch | Yes | Yes |
| Push | Yes | Yes |
| Create PR | Yes | Yes |
| **Merge to main** | Manual | **Automatic** |
| **Speed** | ~5 min | **~2 min** |

Use `/commit` when you want to review the PR before merging. Use `/ship` when you're confident and want the full cycle automated.
