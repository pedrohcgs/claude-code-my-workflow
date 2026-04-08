#!/bin/bash
# enforce-isolation.sh — PreToolUse hook enforcing pipeline isolation
#
# Reviewer agents are READ-ONLY. They may only write to quality_reports/
# for their reports. Enforced for Edit, Write, AND Bash tools to close
# the shell-based write bypass (sed -i, python3 -c, redirections, etc.).
#
# Fails CLOSED on parse errors (security hook — block if unsure).
#
# Principle: "Critics never create. Creators never self-score."
# See: .claude/rules/pipeline-isolation.md
#
# Hook event: PreToolUse (matcher: "Edit|Write" AND "Bash")

# Fail closed: if jq is missing or parsing fails, block
if ! command -v jq >/dev/null 2>&1; then
    echo "BLOCKED by enforce-isolation: jq is required to validate hook input." >&2
    exit 2
fi

INPUT=$(cat)

if ! TOOL_NAME=$(echo "$INPUT" | jq -er '.tool_name' 2>/dev/null); then
    echo "BLOCKED by enforce-isolation: Failed to parse tool_name from hook input." >&2
    exit 2
fi

# Check if we're in a subagent context (agent_name field present)
AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_name // empty' 2>/dev/null)
if [[ $? -ne 0 ]]; then
    echo "BLOCKED by enforce-isolation: Failed to parse hook input." >&2
    exit 2
fi

# If no agent context, allow (main session can edit anything)
if [[ -z "$AGENT_NAME" ]]; then
    exit 0
fi

# Reviewer agents: read-only except for quality_reports/
REVIEWER_AGENTS="proofreader|slide-auditor|pedagogy-reviewer|domain-reviewer|tikz-reviewer|quarto-critic|r-reviewer"

if ! echo "$AGENT_NAME" | grep -qiE "$REVIEWER_AGENTS"; then
    # Not a reviewer agent — allow
    exit 0
fi

# --- Reviewer agent detected — enforce isolation ---

# Helper: check if a path is under the quality_reports/ directory (anchored match)
is_quality_reports_path() {
    local path="$1"
    # Normalize: strip leading ./ if present
    path="${path#./}"
    # Anchored check: must start with quality_reports/
    [[ "$path" == quality_reports/* || "$path" == */quality_reports/* ]]
}

# For Edit/Write: block unless targeting quality_reports/
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
    if ! FILE_PATH=$(echo "$INPUT" | jq -er '.tool_input.file_path' 2>/dev/null); then
        echo "BLOCKED by enforce-isolation: Failed to parse file_path from hook input." >&2
        exit 2
    fi
    if is_quality_reports_path "$FILE_PATH"; then
        exit 0
    fi
    echo "BLOCKED by enforce-isolation: Reviewer agent '$AGENT_NAME' cannot edit files outside quality_reports/. File the issue in your report; a fixer agent will implement it." >&2
    exit 2
fi

# For Bash: block commands that write to the filesystem
if [[ "$TOOL_NAME" == "Bash" ]]; then
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || CMD=""
    if [[ -z "$CMD" ]]; then
        exit 0
    fi

    # Allow read-only commands (grep, cat, head, tail, ls, wc, find, diff, git log/status/diff)
    # Block anything that could mutate files
    WRITE_PATTERNS='(>|>>|tee\s|sed\s+-i|perl\s+-[a-z]*i|python3?\s+-c|ruby\s+-e|git\s+(add|commit|push|checkout|reset|rm|mv)|mv\s|cp\s|rm\s|mkdir\s|touch\s|chmod\s|chown\s|ln\s|install\s)'

    if echo "$CMD" | grep -qiE "$WRITE_PATTERNS"; then
        # Exception: allow writes targeting quality_reports/ (anchored)
        if echo "$CMD" | grep -qE '(^|[\s;|&])quality_reports/'; then
            exit 0
        fi
        echo "BLOCKED by enforce-isolation: Reviewer agent '$AGENT_NAME' cannot run write commands. Use quality_reports/ for output, or file the issue in your report for a fixer agent." >&2
        exit 2
    fi
fi

exit 0
