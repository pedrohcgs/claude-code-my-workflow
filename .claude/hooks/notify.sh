#!/bin/bash
# Cross-platform desktop notification when Claude needs attention
# Triggers on: permission prompts, idle prompts, auth events
set -uo pipefail

INPUT="$(cat)"

# Defaults — used if INPUT is empty, jq is missing, or jq fails to parse it.
# (jq is optional: this used to exit when it was absent, so Git for Windows —
# which ships no jq — and a Linux desktop without it never notified at all.)
MESSAGE="Claude needs attention"
TITLE="Claude Code"

if [ -n "$INPUT" ] && command -v jq >/dev/null 2>&1; then
    if parsed_message="$(printf '%s' "$INPUT" | jq -r '.message // "Claude needs attention"' 2>/dev/null)"; then
        [ -n "$parsed_message" ] && MESSAGE="$parsed_message"
    fi
    if parsed_title="$(printf '%s' "$INPUT" | jq -r '.title // "Claude Code"' 2>/dev/null)"; then
        [ -n "$parsed_title" ] && TITLE="$parsed_title"
    fi
fi

case "$(uname -s)" in
  Darwin)
    # Escape double quotes in message/title for osascript
    MESSAGE="${MESSAGE//\"/\\\"}"
    TITLE="${TITLE//\"/\\\"}"
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null
    ;;
  Linux)
    if command -v notify-send &>/dev/null; then
      notify-send "$TITLE" "$MESSAGE" 2>/dev/null
    else
      echo "[$TITLE] $MESSAGE" >&2
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    # Git Bash on Windows: no notifier binary and no /dev/tty, and stderr from a
    # hook that exits 0 reaches only the debug log. Hand Claude Code an OSC 9
    # terminal sequence (Windows Terminal, ConEmu, WezTerm) as hook JSON. The
    # JSON is escaped by hand, since jq may be absent; control characters are
    # dropped, because an ESC or BEL inside the body would end the sequence.
    body="$(printf '%s: %s' "$TITLE" "$MESSAGE" | tr -d '\000-\037\177')"
    body="${body//\\/\\\\}"
    body="${body//\"/\\\"}"
    printf '{"terminalSequence":"\\u001b]9;%s\\u0007"}\n' "$body"
    ;;
  *)
    echo "[$TITLE] $MESSAGE" >&2
    ;;
esac
exit 0
