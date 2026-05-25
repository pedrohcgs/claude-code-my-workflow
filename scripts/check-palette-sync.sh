#!/usr/bin/env bash
# =============================================================================
# check-palette-sync.sh — thin wrapper around check-palette-sync.py.
#
# Kept for backwards compatibility with existing documentation. The real
# comparison lives in the Python script because it compares HEX VALUES,
# not just color names (name-only comparison silently missed value drift —
# see Codex adversarial review of v1.3.0).
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd -P)"
if [ -z "$SCRIPT_DIR" ] || [ ! -d "$SCRIPT_DIR" ]; then
    echo "check-palette-sync.sh: cannot resolve script directory" >&2
    exit 2
fi
exec python3 "$SCRIPT_DIR/check-palette-sync.py" "$@"
