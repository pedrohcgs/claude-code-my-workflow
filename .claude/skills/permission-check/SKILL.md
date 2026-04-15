---
name: permission-check
description: Diagnose why Claude Code is (or isn't) prompting for permission. Reads all 5 settings layers (VSCode user, VSCode workspace, CLI user, CLI project, CLI project-local), reports `defaultMode`/`allow`/`deny` per layer, flags drift and conflicts, and prints the resolved merged state. Use when user says "why is it asking me to approve?", "permission check", "why am I getting prompts?", "bypass isn't working", "check my permissions", or whenever approval prompts appear despite `bypassPermissions` being configured. Read-only diagnostic.
argument-hint: "(no arguments)"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Permission Check

## Purpose

Surface the full permission-mode picture across every layer Claude Code honors, so the user can see at a glance why prompts are (or aren't) firing. Claude Code resolves permission mode from a 6-tier stack; a single misconfigured layer produces silent overrides that are hard to debug by eye.

## The 6 layers (precedence: bottom wins)

1. **VSCode user settings** — `~/Library/Application Support/Code/User/settings.json` (macOS), `%APPDATA%/Code/User/settings.json` (Windows), `~/.config/Code/User/settings.json` (Linux). Key: `claudeCode.initialPermissionMode`.
2. **VSCode workspace settings** — `<repo>/.vscode/settings.json`. Same key. Wins over user.
3. **CLI user settings** — `~/.claude/settings.json`. Key: `permissions.defaultMode`.
4. **CLI project settings** — `<repo>/.claude/settings.json`. Same key. Wins over user.
5. **CLI project-local settings** — `<repo>/.claude/settings.local.json`. Same key. Wins over project.
6. **In-session mode** — set at session start from layers 1-5, then mutable via `Shift+Tab` or `/permission-mode`. Authoritative until session ends.

**Key insight:** `initialPermissionMode` only fires at session start. If you toggled mid-session (or the session started before a settings change), the file-level settings are correct but the *runtime* mode differs. That's the #1 source of "bypass isn't working" confusion.

## Protocol

### Step 1: Collect every layer

```bash
# VSCode user (platform-dependent path; try all three)
case "$(uname -s)" in
    Darwin)  VSCODE_USER="${HOME}/Library/Application Support/Code/User/settings.json" ;;
    Linux)   VSCODE_USER="${HOME}/.config/Code/User/settings.json" ;;
    MINGW*|MSYS*|CYGWIN*) VSCODE_USER="${APPDATA}/Code/User/settings.json" ;;
    *)       VSCODE_USER="" ;;
esac

# VSCode workspace
VSCODE_WS="${CLAUDE_PROJECT_DIR}/.vscode/settings.json"

# CLI tiers
CLI_USER="${HOME}/.claude/settings.json"
CLI_PROJECT="${CLAUDE_PROJECT_DIR}/.claude/settings.json"
CLI_LOCAL="${CLAUDE_PROJECT_DIR}/.claude/settings.local.json"
```

For each file that exists, extract:
- **VSCode tiers:** `claudeCode.initialPermissionMode`, `claudeCode.allowDangerouslySkipPermissions`
- **CLI tiers:** `permissions.defaultMode`, `permissions.allow`, `permissions.deny`

Missing files are fine — report "not present" rather than erroring.

### Step 2: Compute resolved state

The resolved `defaultMode` is the value from the highest-precedence layer that sets it. Report:

- Which layer won the `defaultMode` contest.
- Merged `allow` list (union across CLI tiers).
- Merged `deny` list (union; any `deny` blocks the action even if allowed elsewhere).
- Whether VSCode says `bypass` but CLI says otherwise (or vice versa) — this is a legitimate conflict to flag.

### Step 3: Report runtime mode

The live in-session mode is exposed via the status line (see `.claude/scripts/statusline.sh`). Tell the user:

> "Your status line shows the current in-session mode in the top-right of the Claude Code panel. If that disagrees with the resolved `defaultMode` above, you (or Shift+Tab) overrode it mid-session. Press Shift+Tab to cycle back."

If the status line isn't configured, emit a warning and point at `.claude/scripts/statusline.sh`.

### Step 4: Flag common failure modes

Check for and explicitly call out:

1. **Layer drift:** CLI project says bypass but CLI local says default → local wins, explains the prompts.
2. **VSCode-only bypass:** VSCode layers say bypass but no CLI layer does → terminal Claude Code will still prompt; extension may or may not.
3. **Empty allowlist + default mode:** `defaultMode: "default"` with empty `allow` → every tool prompts, as designed.
4. **Stale session:** settings are correct but user reports prompts → almost always a session that pre-dates the fix. Advise "Cmd+Shift+P → Developer: Reload Window, then new Claude Code session."
5. **`deny` wins:** any match in a `deny` list blocks the tool regardless of `allow`. Rare but deadly.

## Output format

```
=== PERMISSION STATE ===

Layer 1 — VSCode user:       bypassPermissions      (allowDangerouslySkipPermissions: true)
Layer 2 — VSCode workspace:  bypassPermissions
Layer 3 — CLI user:          bypassPermissions      (allow: ["*"])
Layer 4 — CLI project:       bypassPermissions      (allow: ["Edit(**)", "Bash(*)", ...])
Layer 5 — CLI project-local: bypassPermissions      (allow: [...], deny: [])

Resolved defaultMode: bypassPermissions (set by Layer 5)
Merged allow:         Edit(**), Write(**), Bash(*), ...
Merged deny:          (none)

=== RUNTIME ===

Check the status line at the top of the Claude Code panel. Expected: [BYPASS].
If it shows [PROMPT], [AUTO-EDIT], or [PLAN] — that's an in-session override. Press Shift+Tab to cycle.

=== DIAGNOSIS ===

No layer drift detected. If you are still seeing prompts:
  1. Session is stale (started before settings were applied) — reload window + new session.
  2. VSCode extension bug — check extension version and file an issue.
  3. Tool was previously denied in this session — that denial is remembered. New session clears it.
```

If any layer disagrees, replace the "No layer drift detected" line with a specific flagged issue.

## Notes

- This skill is read-only. It never modifies settings.
- If `$CLAUDE_PROJECT_DIR` is unset, fall back to `git rev-parse --show-toplevel`.
- Platform-aware: detect macOS vs Linux vs Windows for the VSCode user path.
