#!/usr/bin/env bash
# Thin wrapper around scripts/check-surface-sync.py so it can be invoked
# from /commit, a git hook, or CI without worrying about python discovery.
#
# Exits 0 if counts are consistent across README.md, CLAUDE.md, the guide
# source, the rendered guide, the landing page, and skill template.
# Exits 1 with a diff if drift is detected. Exits 2 on internal error.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec python3 "$SCRIPT_DIR/check-surface-sync.py" "$@"
