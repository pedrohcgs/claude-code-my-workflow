#!/usr/bin/env bash
# Drift guard for the scripts/{R,stata,python}/ -> code/ migration (this fork's convention).
#
# This fork keeps all analysis code under code/ (R at code/, Stata at
# code/stata/, Python at code/python/). Upstream uses scripts/R/,
# scripts/stata/, scripts/python/. When upstream merges land, they may
# reintroduce those paths. This script greps for any remaining live
# references (excluding archival files that legitimately mention historical
# paths) and reports them so the user can fix the drift before it propagates.
#
# Wired in two places:
#   1. .claude/settings.json -> SessionStart hook (Claude-side coverage)
#   2. .githooks/post-merge   (terminal-side coverage; needs core.hooksPath)
#
# Exits 0 unconditionally so it never blocks a session start. Drift is
# reported via stdout/stderr to surface the warning without halting work.

set -u

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# Files where archival mentions of scripts/R/ are expected and fine.
EXCLUDES='(CHANGELOG\.md|MEMORY\.md|quality_reports/|session_logs/|\.claude/hooks/check-code-path\.sh|\.githooks/post-merge)'

drift=$(grep -rnE "scripts/(R|stata|python)" \
  --include='*.md' \
  --include='*.qmd' \
  --include='*.tex' \
  --include='*.py' \
  --include='*.sh' \
  --include='*.json' \
  --include='*.R' \
  --include='*.do' \
  "$REPO_ROOT" 2>/dev/null \
  | grep -vE "$EXCLUDES" \
  || true)

if [ -n "$drift" ]; then
  echo "[code-path-drift] References to scripts/{R,stata,python}/ found — this fork uses code/." >&2
  echo "$drift" >&2
  echo "" >&2
  echo "Fix by replacing scripts/R/ -> code/, scripts/stata/ -> code/stata/, scripts/python/ -> code/python/ in the lines above." >&2
fi

exit 0
