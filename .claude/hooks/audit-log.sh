#!/bin/bash
# audit-log.sh — PostToolUse hook that logs every tool invocation
#
# Creates an append-only JSONL audit trail at .claude/logs/audit.jsonl.
# Machine-specific runtime data (gitignored via .claude/logs/).
#
# SECURITY: Redacts sensitive content from logged targets to prevent
# at-rest credential leaks. Logs tool type + redacted summary only.
# Audit file created with 600 permissions (owner read/write only).
#
# Hook event: PostToolUse (matcher: "")

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null) || TOOL_NAME="unknown"
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null) || SESSION_ID="unknown"
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
GIT_VERSION=$(git -C "$PROJECT_DIR" describe --always --dirty 2>/dev/null || echo "unknown")

# Redact sensitive patterns from a string
redact() {
    local text="$1"
    # Redact API keys, tokens, passwords, bearer tokens
    text=$(echo "$text" | sed -E \
        -e 's/(sk-)[A-Za-z0-9_-]{8,}/\1[REDACTED]/g' \
        -e 's/(AKIA)[0-9A-Z]{12,}/\1[REDACTED]/g' \
        -e 's/(ghp_|gho_|ghs_|ghr_|github_pat_)[A-Za-z0-9_]{8,}/\1[REDACTED]/g' \
        -e 's/(Bearer\s+)[A-Za-z0-9_\.\-]{20,}/\1[REDACTED]/g' \
        -e 's/(password|passwd|secret|token|key)([=:]["'"'"'[:space:]]*)[^[:space:]"'"'"']{4,}/\1\2[REDACTED]/gi' \
    )
    echo "$text"
}

# Extract human-readable target depending on tool type (with redaction)
case "$TOOL_NAME" in
    Bash)
        # Log only first 120 chars of command, redacted
        RAW=$(echo "$INPUT" | jq -r '.tool_input.command // "" | .[0:120]' 2>/dev/null) || RAW=""
        TARGET=$(redact "$RAW")
        ;;
    Read|Write|Edit)
        # File paths are safe to log (no secrets in paths typically)
        TARGET=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || TARGET=""
        ;;
    Glob)
        TARGET=$(echo "$INPUT" | jq -r '.tool_input.pattern // ""' 2>/dev/null) || TARGET=""
        ;;
    Grep)
        TARGET=$(echo "$INPUT" | jq -r '.tool_input.pattern // ""' 2>/dev/null) || TARGET=""
        ;;
    Agent)
        TARGET=$(echo "$INPUT" | jq -r '.tool_input.description // ""' 2>/dev/null) || TARGET=""
        ;;
    WebFetch)
        # Redact URLs which may contain tokens in query params
        RAW=$(echo "$INPUT" | jq -r '.tool_input.url // ""' 2>/dev/null) || RAW=""
        # Strip query parameters entirely — they commonly contain auth tokens
        TARGET=$(echo "$RAW" | sed 's/\?.*//')
        ;;
    *)
        TARGET=""
        ;;
esac

# Ensure log directory exists with restrictive permissions
if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
    LOG_DIR="$CLAUDE_PROJECT_DIR/.claude/logs"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    LOG_DIR="$(dirname "$SCRIPT_DIR")/logs"
fi

mkdir -p "$LOG_DIR" 2>/dev/null
chmod 700 "$LOG_DIR" 2>/dev/null

LOG_FILE="$LOG_DIR/audit.jsonl"

# Create with restrictive permissions if new
if [[ ! -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE" 2>/dev/null
    chmod 600 "$LOG_FILE" 2>/dev/null
fi

jq -n -c \
    --arg ts "$TIMESTAMP" \
    --arg sid "$SESSION_ID" \
    --arg tool "$TOOL_NAME" \
    --arg target "$TARGET" \
    --arg ver "$GIT_VERSION" \
    '{timestamp: $ts, session_id: $sid, tool: $tool, target: $target, version: $ver}' \
    >> "$LOG_FILE" 2>/dev/null

exit 0
