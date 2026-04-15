#!/usr/bin/env bash
# Claude Code status line: shows permission mode, model, and git branch.
#
# Claude Code pipes a JSON session snapshot to stdin. Relevant keys:
#   .model.display_name      e.g. "Opus 4.6"
#   .permission_mode         e.g. "bypassPermissions" | "plan" | "acceptEdits" | "default"
#   .workspace.current_dir   absolute path of the cwd
#
# Design goal: always show permission mode so prompt-fatigue is diagnosable at a glance.

set -euo pipefail

INPUT="$(cat)"

mode="$(printf '%s' "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('permission_mode','?'))" 2>/dev/null || echo "?")"
model="$(printf '%s' "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('model',{}).get('display_name','?'))" 2>/dev/null || echo "?")"
cwd="$(printf '%s' "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('workspace',{}).get('current_dir','.'))" 2>/dev/null || pwd)"

case "$mode" in
    bypassPermissions) mode_badge="[BYPASS]" ;;
    acceptEdits)       mode_badge="[AUTO-EDIT]" ;;
    plan)              mode_badge="[PLAN]" ;;
    default)           mode_badge="[PROMPT]" ;;
    *)                 mode_badge="[$mode]" ;;
esac

branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch="$(git -C "$cwd" branch --show-current 2>/dev/null || true)"
fi

line="$mode_badge  $model"
[ -n "$branch" ] && line="$line  @ $branch"

printf '%s' "$line"
