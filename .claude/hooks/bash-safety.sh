#!/bin/bash
# bash-safety.sh — PreToolUse hook that blocks dangerous Bash commands
#
# Exit codes (Claude Code PreToolUse convention):
#   0 = allow the command to proceed
#   2 = BLOCK the command (stderr message shown to the model)
#
# Design: Block the dangerous *pattern*, not the tool.
# Defense-in-depth: works alongside the deny list in settings.json.
#
# Hook event: PreToolUse (matcher: "Bash")

# Fail CLOSED: if anything unexpected goes wrong, block the command.
trap 'echo "BLOCKED by bash-safety hook: unexpected error in safety check" >&2; exit 2' ERR

# Require jq for JSON parsing — fail closed if missing
if ! command -v jq >/dev/null 2>&1; then
    echo "BLOCKED by bash-safety hook: jq is required for safety checks." >&2
    exit 2
fi

INPUT=$(cat)

if ! TOOL_NAME=$(echo "$INPUT" | jq -er '.tool_name' 2>/dev/null); then
    echo "BLOCKED by bash-safety hook: Failed to parse tool_name." >&2
    exit 2
fi
if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || CMD=""
if [[ -z "$CMD" ]]; then
    exit 0
fi

NORM_CMD=$(echo "$CMD" | tr -s '[:space:]' ' ')

block() {
    echo "BLOCKED by bash-safety hook: $1" >&2
    exit 2
}

# 1. DESTRUCTIVE FILESYSTEM OPERATIONS
# Block rm -rf AND rm -r targeting dangerous roots (/ ~ $HOME . .. *)
if echo "$NORM_CMD" | grep -qiE 'rm\s+(-[a-z]*r[a-z]*f|-[a-z]*f[a-z]*r)\s+(/|/\*|~|\$HOME|\.\.|\.|\*)'; then
    block "Recursive force-delete targeting dangerous path. Use targeted 'rm' on specific files instead."
fi
if echo "$NORM_CMD" | grep -qiE 'rm\s+(-[a-z]*r|-[a-z]*R|--recursive)\s+(/|/\*|~|\$HOME|\.\.)'; then
    block "Recursive delete targeting dangerous root. Use targeted 'rm' on specific files instead."
fi

# 2. DESTRUCTIVE GIT OPERATIONS
if echo "$NORM_CMD" | grep -qiE 'git\s+push\s+.*\s(-f|--force|--force-with-lease)(\s|$)'; then
    block "Force push rewrites remote history. Use regular 'git push' instead."
fi

if echo "$NORM_CMD" | grep -qiE 'git\s+reset\s+--hard'; then
    block "Hard reset destroys uncommitted changes. Use 'git stash' to save work first."
fi

if echo "$NORM_CMD" | grep -qiE 'git\s+clean\s+(-[a-z]*f|--force)'; then
    block "git clean -f permanently deletes untracked files. Review with 'git clean -n' first."
fi

if echo "$NORM_CMD" | grep -qiE 'git\s+(checkout|restore)\s+\.'; then
    block "This discards all working directory changes. Use 'git stash' to save work first."
fi

if echo "$NORM_CMD" | grep -qiE 'git\s+branch\s+-D'; then
    block "Force-deleting a branch is irreversible. Use 'git branch -d' (safe delete) instead."
fi

# 3. PRIVILEGE ESCALATION
if echo "$NORM_CMD" | grep -qiE '(^|\s|;|&&|\|\|)sudo\s'; then
    block "Privilege escalation via sudo is not permitted."
fi

if echo "$NORM_CMD" | grep -qiE 'chmod\s+(777|u\+s)'; then
    block "Setting world-writable (777) or setuid permissions is not permitted."
fi

# 4. DANGEROUS NETWORK PATTERNS
if echo "$NORM_CMD" | grep -qiE '(curl|wget)\s+.*\|\s*(bash|sh|zsh|dash|source)'; then
    block "Piping downloaded content to a shell is arbitrary code execution."
fi

if echo "$NORM_CMD" | grep -qiE 'curl\s+.*(-d\s*@|-F\s*.*=@|--data-binary\s*@|--data\s*@|--upload-file)'; then
    block "Uploading local files via curl is a data exfiltration risk."
fi

# 5. SENSITIVE FILE ACCESS VIA INTERPRETERS
# The deny list in settings.json blocks Read(.env) etc., but interpreters
# like python3 can still read these files. Block interpreter commands that
# reference sensitive file patterns.
SENSITIVE_PATTERNS='(\.env|\.pem|\.key|credentials|secret|id_rsa|id_ed25519|\.aws/|\.ssh/)'
if echo "$NORM_CMD" | grep -qiE "(python3?|ruby|node|perl)\s.*$SENSITIVE_PATTERNS"; then
    block "Interpreter command references a sensitive file. Use the Read tool (which enforces the deny list) instead of shell interpreters for file access."
fi
if echo "$NORM_CMD" | grep -qiE "(cat|head|tail|less|more|bat)\s+[^\|]*$SENSITIVE_PATTERNS"; then
    block "Command reads a sensitive file (.env, .pem, .key, credentials). These files are protected by the deny list."
fi

exit 0
