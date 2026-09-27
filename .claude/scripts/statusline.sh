#!/usr/bin/env bash
# Claude Code status line: shows permission mode, model, and git branch.
#
# Claude Code pipes a JSON session snapshot to stdin. Relevant keys
# (https://code.claude.com/docs/en/statusline):
#   .model.display_name              e.g. "Opus"
#   .effort.level                    e.g. "medium" (absent on models without effort)
#   .context_window.used_percentage  native context %, may be null early in a session
#   .workspace.current_dir           absolute path of the cwd
#   .permission_mode                 read when present ("auto" | "plan" | ...); not in the
#                                    documented field list, so the badge is dropped if absent
#
# Design goal: show mode, model/effort, and context at a glance.

set -euo pipefail

INPUT="$(cat)"

# Parse every field in a single python3 invocation. Status line renders
# on every turn; avoid several forks when one suffices.
# The JSON is UTF-8 bytes and bash reads the fields back as UTF-8 bytes, so both
# ends are pinned: Windows Python decodes and encodes a pipe with the ANSI code
# page, and on a CJK one (cp932/936/950) a multibyte character swallowed the
# backslash of the next JSON escape — the parse failed and the [BYPASS] badge,
# the model and ctx % all vanished. newline='\n' keeps a CR off each field.
parsed="$(printf '%s' "$INPUT" | python3 -c "
import sys, json
sys.stdout.reconfigure(encoding='utf-8', newline='\n')
try:
    d = json.loads(sys.stdin.buffer.read().decode('utf-8', 'replace'))
except Exception:
    d = {}
pct = (d.get('context_window') or {}).get('used_percentage')
print(d.get('permission_mode') or '')
print((d.get('model') or {}).get('display_name') or '?')
print((d.get('workspace') or {}).get('current_dir') or '.')
print((d.get('effort') or {}).get('level') or '')
print('' if pct is None else int(float(pct)))
" 2>/dev/null || printf '\n?\n\n\n\n')"

mode="$(printf '%s' "$parsed" | sed -n '1p')"
model="$(printf '%s' "$parsed" | sed -n '2p')"
cwd="$(printf '%s' "$parsed" | sed -n '3p')"
effort="$(printf '%s' "$parsed" | sed -n '4p')"
native_pct="$(printf '%s' "$parsed" | sed -n '5p')"
[ -n "$model" ] || model="?"
[ -n "$cwd" ] && [ "$cwd" != "." ] || cwd="$(pwd)"

case "$mode" in
    bypassPermissions) mode_badge="[BYPASS]" ;;
    auto)              mode_badge="[AUTO]" ;;
    acceptEdits)       mode_badge="[AUTO-EDIT]" ;;
    plan)              mode_badge="[PLAN]" ;;
    default|manual)    mode_badge="[PROMPT]" ;;
    "")                mode_badge="" ;;
    *)                 mode_badge="[$mode]" ;;
esac
[ -n "$effort" ] && model="${model}·${effort}"

# Optional enrichment (branch, dirty count, plan status, context %).
# Wrapped in `set +e` so a probe failure can never blank the status line.
set +e
branch=""
dirty=""
gate=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch="$(git -C "$cwd" branch --show-current 2>/dev/null)"
    n="$(git -C "$cwd" status --porcelain 2>/dev/null | grep -c '.')"
    [ "${n:-0}" -gt 0 ] 2>/dev/null && dirty="±${n}"
    # The repo ships a pre-commit gate, but git is not pointed at it: a plain
    # `git commit` skips every check. Fixed by ./scripts/install-hooks.sh.
    # Resolved from the repo root (the session may sit in a subdirectory), and the
    # configured path resolved too, so a global hooks folder that merely shares the
    # name does not count.
    top="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"
    if [ -n "$top" ] && [ -f "$top/.githooks/pre-commit" ]; then
        hp="$(git -C "$top" config --get core.hooksPath 2>/dev/null)"
        case "$hp" in
            "") hp_abs="" ;;
            /*|~*) hp_abs="$(cd "${hp/#\~/$HOME}" 2>/dev/null && pwd -P)" ;;
            *) hp_abs="$(cd "$top/$hp" 2>/dev/null && pwd -P)" ;;
        esac
        [ "$hp_abs" = "$(cd "$top/.githooks" && pwd -P)" ] || gate="gate:off"
    fi
fi

# Most-recent plan's status (DRAFT / APPROVED / COMPLETED), read from its
# Status FIELD — the same rule as pre-compact.py / post-compact-restore.py. A
# whole-file grep mis-read a DRAFT plan whose body mentioned "COMPLETED".
# Looked up from the repo top, like the gate above: from the session cwd, a
# session sitting in Slides/ or scripts/R/ lost the badge.
plan_badge=""
latest_plan="$(ls -t "${top:-$cwd}"/quality_reports/plans/*.md 2>/dev/null | head -1)"
if [ -n "$latest_plan" ]; then
    pstatus="$(grep -m1 -oiE '^[[:space:]]*\**[[:space:]]*status[[:space:]]*\**[[:space:]]*:[[:space:]]*\**[[:space:]]*(draft|approved|completed|implemented|in[ -]?progress)' "$latest_plan" 2>/dev/null \
               | sed -E 's/.*:[[:space:]]*\**[[:space:]]*//' | tr '[:upper:]' '[:lower:]')"
    case "$pstatus" in
        completed*|implemented*) plan_badge="plan:done" ;;
        approved*)               plan_badge="plan:approved" ;;
        draft*)                  plan_badge="plan:DRAFT" ;;
    esac
fi

# Context % — prefer the native field Claude Code passes on stdin; fall back to
# the estimate context-monitor.py persists under the session dir keyed by
# md5(project_dir)[:8] (older Claude Code versions, or null early in a session).
ctx=""
[ -n "$native_pct" ] && ctx="ctx ${native_pct}%"
# Mirror context-monitor.py's get_session_dir() EXACTLY: CLAUDE_PROJECT_DIR set →
# hash it; unset/empty → the writer falls back to sessions/default/, so do the same
# (hashing the git toplevel here would point at the wrong folder on that path).
# Read from the ENVIRONMENT, as the writer reads it: piped through stdin, Windows
# Python decoded the path with the ANSI code page, so a non-ASCII project path
# hashed to a different folder (or to "" on a byte cp1252 leaves undefined).
if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    hash="$(python3 -c 'import os,sys,hashlib; sys.stdout.write(hashlib.md5(os.environ.get("CLAUDE_PROJECT_DIR","").encode()).hexdigest()[:8])' 2>/dev/null)"
else
    hash="default"
fi
pct_file="$HOME/.claude/sessions/${hash}/context-pct.txt"
[ -z "$ctx" ] && [ -f "$pct_file" ] && ctx="ctx ~$(cat "$pct_file" 2>/dev/null)%"
set -e

line="$model"
[ -n "$mode_badge" ] && line="$mode_badge  $line"
[ -n "$branch" ] && line="$line  @ $branch"
[ -n "$dirty" ] && line="$line $dirty"
[ -n "$gate" ] && line="$line  $gate"
[ -n "$plan_badge" ] && line="$line  $plan_badge"
[ -n "$ctx" ] && line="$line  $ctx"

printf '%s' "$line"
