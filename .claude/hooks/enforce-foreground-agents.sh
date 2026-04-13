#!/bin/bash
# enforce-foreground-agents.sh — blocks background agents
#
# Background agents cannot prompt for user permissions, causing silent failures.
# This hook denies any Agent tool call with run_in_background=true.
#
# Fails CLOSED on errors (consistent with other PreToolUse enforcement hooks).
#
# Hook event: PreToolUse (matcher: "Agent")

trap 'echo "BLOCKED by enforce-foreground-agents: unexpected error in safety check" >&2; exit 2' ERR

# Require jq — fail closed if missing
if ! command -v jq >/dev/null 2>&1; then
    echo "BLOCKED by enforce-foreground-agents: jq is required for safety checks." >&2
    exit 2
fi

INPUT=$(cat)

if ! RUN_IN_BG=$(echo "$INPUT" | jq -er '.tool_input.run_in_background // empty' 2>/dev/null); then
    RUN_IN_BG=""
fi

if [ "$RUN_IN_BG" = "true" ]; then
    echo "BLOCKED by enforce-foreground-agents: Background agents are not permitted. Background agents cannot prompt for user permissions, causing silent tool call failures. Remove run_in_background or set it to false." >&2
    exit 2
fi

exit 0
