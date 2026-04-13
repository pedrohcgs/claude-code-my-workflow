#!/bin/bash
# enforce-isolation.sh — PreToolUse hook enforcing pipeline isolation
#
# Reviewer agents are READ-ONLY. They may only write to quality_reports/
# for their reports. Enforced for Edit, Write, AND Bash tools.
#
# For Edit/Write: uses realpath canonicalization to prevent path traversal
# (e.g., quality_reports/../CLAUDE.md would resolve outside the allowed dir).
#
# For Bash: blocks ALL write-capable commands from reviewer agents.
# No substring exceptions — too easy to bypass with command padding.
# Reviewers should document issues in reports; fixers implement changes.
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

# For Edit/Write: block unless targeting quality_reports/ (with realpath check)
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
    if ! FILE_PATH=$(echo "$INPUT" | jq -er '.tool_input.file_path' 2>/dev/null); then
        echo "BLOCKED by enforce-isolation: Failed to parse file_path from hook input." >&2
        exit 2
    fi

    # Resolve the canonical path to prevent traversal attacks
    # (e.g., quality_reports/../CLAUDE.md → /project/CLAUDE.md)
    PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
    ALLOWED_DIR="$PROJECT_DIR/quality_reports"

    # Handle both absolute and relative paths
    if [[ "$FILE_PATH" == /* ]]; then
        CANONICAL="$FILE_PATH"
    else
        CANONICAL="$PROJECT_DIR/$FILE_PATH"
    fi

    # Resolve .. and symlinks. Use Python as portable realpath fallback.
    if command -v realpath >/dev/null 2>&1; then
        # realpath may fail if parent dirs don't exist yet; use -m for logical resolution
        CANONICAL=$(realpath -m "$CANONICAL" 2>/dev/null) || CANONICAL=""
    else
        CANONICAL=$(python3 -c "import os; print(os.path.normpath('$CANONICAL'))" 2>/dev/null) || CANONICAL=""
    fi

    if [[ -z "$CANONICAL" ]]; then
        echo "BLOCKED by enforce-isolation: Could not resolve path '$FILE_PATH'." >&2
        exit 2
    fi

    # Check: resolved path must be under quality_reports/
    if [[ "$CANONICAL" == "$ALLOWED_DIR"/* ]]; then
        exit 0
    fi

    echo "BLOCKED by enforce-isolation: Reviewer agent '$AGENT_NAME' cannot edit files outside quality_reports/. File the issue in your report; a fixer agent will implement it." >&2
    exit 2
fi

# For Bash: block ALL write-capable commands from reviewer agents.
# No exceptions — substring-based allowlists for Bash are too easy to bypass.
# Reviewers use Bash only for read-only operations (grep, cat, ls, diff, git log).
if [[ "$TOOL_NAME" == "Bash" ]]; then
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || CMD=""
    if [[ -z "$CMD" ]]; then
        exit 0
    fi

    # Block any command that could mutate the filesystem
    WRITE_PATTERNS='(>|>>|tee\s|sed\s+-i|perl\s+-[a-z]*i|python3?\s+-c|ruby\s+-e|node\s+-e|git\s+(add|commit|push|checkout|reset|rm|mv)|mv\s|cp\s|rm\s|mkdir\s|touch\s|chmod\s|chown\s|ln\s|install\s|curl\s.*-o|wget\s.*-O)'

    if echo "$CMD" | grep -qiE "$WRITE_PATTERNS"; then
        echo "BLOCKED by enforce-isolation: Reviewer agent '$AGENT_NAME' cannot run write commands via Bash. Document the issue in your quality_reports/ file; a fixer agent will implement changes." >&2
        exit 2
    fi
fi

exit 0
