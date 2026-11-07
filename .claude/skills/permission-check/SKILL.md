---
name: permission-check
description: Diagnose why Claude Code is (or isn't) prompting for permission. By default reads only repo-local layers (CLI project, CLI project-local, VSCode workspace). Host-global layers (CLI user `~/.claude/`, VSCode user settings) are read ONLY when the user explicitly confirms — those files may contain unrelated paths or secrets. Use when user says "why is it asking me to approve?", "permission check", "why am I getting prompts?", "bypass isn't working", "check my permissions". Read-only diagnostic.
argument-hint: "(no arguments)"
allowed-tools: ["Read", "Bash", "Glob"]
disallowed-tools: ["Edit", "MultiEdit"]
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
6. **In-session mode** — set at session start from layers 1-5, then mutable via `Shift+Tab` (CLI) or the mode indicator (VS Code / Desktop); `/permissions` manages allow/deny rules, not the mode. Authoritative until session ends.

**Two rules that override the stack** (Anthropic's permission-modes docs, re-verified 2026-09-26):

- Layers 4 and 5 do **not** honor `auto` or `bypassPermissions` as a starting mode. A `bypassPermissions` there is ignored and the terminal session starts in Manual (`default`); an `auto` there is ignored in favour of the built-in default. Every other mode value applies from any layer.
- The VS Code extension does **not** read layers 4–5 for its starting mode; it uses `claudeCode.initialPermissionMode` (which does not accept `auto`), and a bypass value needs the extension's *Allow dangerously skip permissions* toggle. With no override, Claude Code ≥ 2.1.283 starts in auto mode.

So check first for "bypass set in the project settings, where it cannot take effect" — then for the mid-session override below.

**Key insight:** `initialPermissionMode` only fires at session start. If you toggled mid-session (or the session started before a settings change), the file-level settings are correct but the *runtime* mode differs. That, and a bypass set only in project settings, are the two usual sources of "bypass isn't working" confusion.

## Privacy contract

Host-global settings files (`~/.claude/settings.json`, VSCode user settings) may contain:
- Paths to unrelated projects and secrets
- API keys, tokens, or provider credentials added outside this repo
- Permission policies set by the user's org or employer

This skill is designed for defense-in-depth: **Phase A runs automatically and reads only repo-local files.** Phase B reads host-global files **only after the user explicitly confirms** — never silently. When reporting host-global layers, redact any key that is not directly relevant to `permissions.*`, `claudeCode.*`, or `allowDangerouslySkipPermissions`.

## Protocol

### Phase A: Repo-local layers (auto-runs)

Read these immediately — they are checked into (or gitignored inside) the repo and do not cross the trust boundary:

```bash
VSCODE_WS="${CLAUDE_PROJECT_DIR}/.vscode/settings.json"
CLI_PROJECT="${CLAUDE_PROJECT_DIR}/.claude/settings.json"
CLI_LOCAL="${CLAUDE_PROJECT_DIR}/.claude/settings.local.json"
```

For each file that exists, extract:
- **VSCode workspace:** `claudeCode.initialPermissionMode` and `allowDangerouslySkipPermissions` (no `claudeCode.` prefix — flag the prefixed `claudeCode.allowDangerouslySkipPermissions` as a silently-ignored typo if you see it)
- **CLI project / project-local:** `permissions.defaultMode`, `permissions.allow`, `permissions.deny`

Missing files are fine — report "not present" rather than erroring.

Print the resolved defaultMode from these three layers alone, applying the two override rules above — a `bypassPermissions` or `auto` found only in layer 4 or 5 is reported as **ignored**, not as the resolved mode. If that already explains the prompt behavior (e.g. bypass set only in `.claude/settings.json`), stop here and surface the diagnosis with the fix: move it to `~/.claude/settings.json`, pass `--permission-mode bypassPermissions`, or use auto mode.

### Phase B: Host-global layers (requires explicit user confirmation)

If Phase A is inconclusive — e.g., all repo-local layers agree on bypass but the user is still being prompted — ask the user:

> "To complete the diagnosis, I need to read two files outside this repo:
> - `~/.claude/settings.json` (CLI user-level)
> - your VSCode user settings (`~/Library/Application Support/Code/User/settings.json` on macOS; Linux/Windows vary)
>
> These may contain unrelated paths or secrets. I will redact any key that isn't in `permissions.*`, `claudeCode.*`, or `allowDangerouslySkipPermissions`. Proceed?"

Only after the user confirms, read:

```bash
# VSCode user (platform-dependent path; try all three)
case "$(uname -s)" in
    Darwin)  VSCODE_USER="${HOME}/Library/Application Support/Code/User/settings.json" ;;
    Linux)   VSCODE_USER="${HOME}/.config/Code/User/settings.json" ;;
    MINGW*|MSYS*|CYGWIN*) VSCODE_USER="${APPDATA}/Code/User/settings.json" ;;
    *)       VSCODE_USER="" ;;
esac

CLI_USER="${HOME}/.claude/settings.json"
```

When reporting their contents, **extract only the relevant keys**:
- CLI user: `permissions.defaultMode`, `permissions.allow`, `permissions.deny`
- VSCode user: any key starting with `claudeCode.`

Never print the full file. Redact everything else to `(other keys redacted)`.

### Step 2: Compute resolved state

The resolved `defaultMode` is the value from the highest-precedence layer that sets it. Report:

- Which layer won the `defaultMode` contest.
- Merged `allow` list (union across CLI tiers).
- Merged `deny` list (union; any `deny` blocks the action even if allowed elsewhere).
- Whether VSCode says `bypass` but CLI says otherwise (or vice versa) — this is a legitimate conflict to flag.

### Step 3: Report runtime mode

The live in-session mode is exposed via the status line (see `.claude/scripts/statusline.sh`). Tell the user:

> "If your status line shows a mode badge (`[AUTO]`, `[BYPASS]`, `[PLAN]`, `[AUTO-EDIT]`, `[PROMPT]`), that is the live in-session mode. If it disagrees with the resolved `defaultMode` above, either a mid-session toggle (Shift+Tab) changed it, or the resolution above already explains it — e.g. `[PROMPT]` from a bypass set only in project settings. No badge means Claude Code did not report the mode; the mode indicator in the Claude Code panel shows it."

If the status line isn't configured, emit a warning and point at `.claude/scripts/statusline.sh`.

### Step 4: Flag common failure modes

Check for and explicitly call out:

1. **Bypass or auto set only in project settings:** layers 4–5 cannot set these starting modes. A bypass there starts the session in Manual; an `auto` there falls back to the built-in default (auto on ≥ 2.1.283). Fix: remove it from the project files and set bypass in user settings or with the CLI flag — or rely on the built-in auto default.
2. **Layer drift:** CLI user says bypass but CLI project-local says `default` → the project-local `default` wins (it is an honoured value), which explains the prompts.
3. **VSCode-only bypass:** VSCode layers say bypass but no CLI layer does → terminal Claude Code will still prompt; the extension honours it only with *Allow dangerously skip permissions* on.
4. **Empty allowlist + default mode:** `defaultMode: "default"` with empty `allow` → every tool prompts, as designed.
5. **Stale session:** settings are correct but user reports prompts → almost always a session that pre-dates the fix. Advise "Cmd+Shift+P → Developer: Reload Window, then new Claude Code session."
6. **`deny` wins:** any match in a `deny` list blocks the tool regardless of `allow`, in every mode including bypass — which is exactly why restricted-data projects use deny rules. Exception: an installed *mod* can approve a call a deny rule refused, unless managed settings or a Team or Enterprise login are in place; check `/plugin` for active mods.

## Output format

```
=== PERMISSION STATE ===

Layer 1 — VSCode user:       bypassPermissions      (allowDangerouslySkipPermissions: true)
Layer 2 — VSCode workspace:  (not set)
Layer 3 — CLI user:          bypassPermissions      (allow: ["*"])
Layer 4 — CLI project:       (not set)              (allow: ["Edit(**)", "Bash(*)", ...])
Layer 5 — CLI project-local: bypassPermissions      NOT HONOURED — a project-layer bypass starts the session in Manual

Resolved defaultMode: default (Manual) — Layer 5's bypass overrides Layer 3 and is not honoured
Merged allow:         Edit(**), Write(**), Bash(*), ...
Merged deny:          (none)

=== RUNTIME ===

Check the status line (or the mode indicator). Expected here: [PROMPT] — the ignored Layer 5 bypass explains it.
Remove the bypass from Layer 5 and keep it in Layer 3 (or rely on auto mode) to get [BYPASS] / [AUTO].
Any other mismatch with the resolved mode is an in-session override — Shift+Tab cycles modes.

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
