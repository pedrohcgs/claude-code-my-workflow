#!/bin/bash
# install.sh --- Sync workflow infrastructure to user-level ~/.claude/
#
# Run after pulling updates from the workflow repo:
#   cd C:/git/fresh-workflow && bash install.sh
#
# Copies ALL skills, agents, rules, and hook scripts to ~/.claude/
# so they apply to every project automatically.
#
# Does NOT touch:
#   - ~/.claude/settings.json (hook wiring --- manage manually)
#   - ~/.claude/CLAUDE.md (global preferences)
#   - ~/.claude/skills/data-analysis/ (user-level Stata skill)
#   - ~/.claude/skills/research-feedback/ (user-level skill)
#   - ~/.claude/skills/skill-creator/ (user-level skill)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW_CLAUDE="$SCRIPT_DIR/.claude"
USER_CLAUDE="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Installing fresh-workflow infrastructure to ~/.claude/${NC}"
echo ""

# --- Skills ---
echo -e "${GREEN}Skills${NC}"
mkdir -p "$USER_CLAUDE/skills"

SKILLS=(
  commit compile-latex context-status create-lecture devils-advocate
  extract-tikz interview-me learn lit-review pedagogy-review proofread
  research-ideation review-paper review-plan review-python review-stata
  slide-excellence validate-bib visual-audit
)

for skill in "${SKILLS[@]}"; do
  if [ -d "$WORKFLOW_CLAUDE/skills/$skill" ]; then
    cp -r "$WORKFLOW_CLAUDE/skills/$skill" "$USER_CLAUDE/skills/"
    echo "  $skill"
  fi
done

# Rename workflow data-analysis → python-analysis (Stata skill stays as data-analysis)
if [ -d "$WORKFLOW_CLAUDE/skills/data-analysis" ]; then
  cp -r "$WORKFLOW_CLAUDE/skills/data-analysis" "$USER_CLAUDE/skills/python-analysis"
  echo "  data-analysis → python-analysis"
fi

echo ""

# --- Agents ---
echo -e "${GREEN}Agents${NC}"
mkdir -p "$USER_CLAUDE/agents"
cp "$WORKFLOW_CLAUDE/agents/"*.md "$USER_CLAUDE/agents/"
echo "  $(ls "$WORKFLOW_CLAUDE/agents/"*.md 2>/dev/null | wc -l) agents copied"
echo ""

# --- Rules ---
echo -e "${GREEN}Rules${NC}"
mkdir -p "$USER_CLAUDE/rules"
cp "$WORKFLOW_CLAUDE/rules/"*.md "$USER_CLAUDE/rules/"
echo "  $(ls "$WORKFLOW_CLAUDE/rules/"*.md 2>/dev/null | wc -l) rules copied"
echo ""

# --- Hook scripts ---
echo -e "${GREEN}Hook scripts${NC}"
mkdir -p "$USER_CLAUDE/hooks"
for hook in "$WORKFLOW_CLAUDE/hooks/"*; do
  cp "$hook" "$USER_CLAUDE/hooks/"
  echo "  $(basename "$hook")"
done

echo ""
echo -e "${CYAN}Done.${NC}"
echo ""
echo -e "${YELLOW}Reminder:${NC} This script copies hook scripts but does NOT update"
echo "~/.claude/settings.json. If you added new hooks, wire them manually"
echo "using absolute paths (C:/Users/maand/anaconda3/python.exe ...)."
