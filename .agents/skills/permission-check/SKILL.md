---
name: permission-check
description: Diagnose why Codex is or is not prompting for approval. By default, read only repo-local config (`.codex/config.toml` if present and `.vscode/settings.json`). Read host-global config (`~/.codex/config.toml` and VSCode user settings) only after the user explicitly confirms. Read-only diagnostic.
argument-hint: "(no arguments)"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Permission Check

## Purpose

Show the effective Codex permission picture across the settings layers that matter in a modern Codex setup:

- VSCode user settings
- VSCode workspace settings
- `~/.codex/config.toml`
- `<repo>/.codex/config.toml`
- any live in-session override the user applied after launch

This skill is diagnostic only. It never edits configuration.

## Privacy contract

Run in two phases:

1. **Repo-local only**: inspect files inside the repository without asking.
2. **Host-global**: inspect `~/.codex/config.toml` or VSCode user settings only after explicit user confirmation, because those files may contain unrelated paths, credentials, or org policy.

When reading host-global files, report only approval-, sandbox-, and Codex-related keys. Do not dump the full file.

## Phase A: Repo-local layers

Resolve the repo root first:

```bash
git rev-parse --show-toplevel
```

Then inspect these files if they exist:

```bash
<repo>/.vscode/settings.json
<repo>/.codex/config.toml
```

Extract only:

- VSCode workspace keys starting with `codex.` or `Codex.`
- Codex config keys such as `approval_policy`, `sandbox_mode`, `web_search`, `model`, and other directly relevant run-behavior settings

If a file is missing, report `not present`.

If the repo-local layer already explains the behavior, stop and return the diagnosis.

## Phase B: Host-global layers

Only if Phase A is inconclusive, ask before reading:

- `~/.codex/config.toml`
- VSCode user settings

Typical VSCode user paths:

- macOS: `~/Library/Application Support/Code/User/settings.json`
- Linux: `~/.config/Code/User/settings.json`
- Windows: `%APPDATA%/Code/User/settings.json`

Again, extract only Codex-relevant keys.

## Diagnosis checklist

Report:

- which file most likely controls the current approval behavior
- whether the repo has no `.codex/config.toml`
- whether VSCode settings and Codex config disagree
- whether the likely issue is a stale session or a mid-session override
- whether the user is looking at editor-specific behavior versus app/CLI behavior

## Runtime note

Tell the user to compare the file-based diagnosis with the live mode shown in the Codex UI. If they differ, the active session was overridden after launch and they need a new session to test config changes cleanly.

## Output format

```text
=== PERMISSION STATE ===

VSCode user:          [value or not checked]
VSCode workspace:     [value or not present]
~/.codex/config.toml: [value or not checked]
<repo>/.codex/config.toml: [value or not present]

Effective behavior: [best grounded explanation]

=== DIAGNOSIS ===

- [specific cause]
- [specific next step]
```

## Common outcomes

- Repo has no `.codex/config.toml`, so behavior is inherited from user/global config.
- File settings were updated after the session started, so the session is stale.
- VSCode settings and Codex config disagree; the user is comparing different surfaces.
- The UI mode was changed mid-session, so file settings are not the current truth.
