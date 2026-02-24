#!/bin/bash
# Block accidental edits to protected files
# Customize PROTECTED_PATTERNS below for your project
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
FILE=""

# Extract file path based on tool type
if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
fi

# No file path = not a file operation, allow
if [ -z "$FILE" ]; then
  exit 0
fi

# ============================================================
# CUSTOMIZE: Add patterns for files you want to protect
# Uses basename matching --- add full paths for more precision
# ============================================================
PROTECTED_PATTERNS=(
  "CLAUDE.md"
  "bibliography.bib"
  "settings.json"
)

# Path-based protection for raw data directories
PROTECTED_PATHS=(
  "project/data/build/input/"
  "project/data/media/"
  "project/Testing/"
)

for PPATH in "${PROTECTED_PATHS[@]}"; do
  if [[ "$FILE" == *"$PPATH"* ]]; then
    echo "Protected raw data path: $PPATH. These files should never be modified." >&2
    exit 2
  fi
done

# Raw data directories --- should never be modified by Claude
PROTECTED_PATHS=(
  "project/data/build/input/"
  "project/data/media/"
  "project/Testing/"
)

BASENAME=$(basename "$FILE")
for PATTERN in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$BASENAME" == "$PATTERN" ]]; then
    echo "Protected file: $BASENAME. Edit manually or remove protection in .claude/hooks/protect-files.sh" >&2
    exit 2
  fi
done

# Path-based protection for raw data directories
for PATTERN in "${PROTECTED_PATHS[@]}"; do
  if [[ "$FILE" == *"$PATTERN"* ]]; then
    echo "Protected data path: $FILE. Raw data should not be modified." >&2
    exit 2
  fi
done

exit 0
