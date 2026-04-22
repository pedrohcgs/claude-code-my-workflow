#!/usr/bin/env bash
# =============================================================================
# validate-setup.sh - Verify dependencies for the academic workflow
#
# Run this after forking the repo to confirm your environment is ready.
# Exits non-zero only when required baseline tools are missing.
# Stata is strongly supported but optional.
# =============================================================================

set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

pass=0
warn=0
fail=0

echo ""
echo -e "${BOLD}Validating academic workflow setup...${RESET}"
echo ""

command_present() {
    command -v "$1" >/dev/null 2>&1
}

first_available() {
    for candidate in "$@"; do
        if command_present "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

version_line() {
    local cmd="$1"
    if "$cmd" --version >/dev/null 2>&1; then
        "$cmd" --version 2>&1 | head -n1
    else
        echo "$cmd detected"
    fi
}

check_required() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    if command_present "$cmd"; then
        echo -e "  ${GREEN}[OK]${RESET} $name found: $(version_line "$cmd")"
        pass=$((pass + 1))
    else
        echo -e "  ${RED}[MISSING]${RESET} $name not found - install: ${install_url}"
        fail=$((fail + 1))
    fi
}

check_optional() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    if command_present "$cmd"; then
        echo -e "  ${GREEN}[OK]${RESET} $name found: $(version_line "$cmd")"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}[OPTIONAL]${RESET} $name not found - install: ${install_url}"
        warn=$((warn + 1))
    fi
}

echo -e "${BOLD}Required tools:${RESET}"
check_required "Claude Code" "claude" "https://claude.ai/install"
check_required "XeLaTeX" "xelatex" "https://tug.org/texlive/"
check_required "Quarto" "quarto" "https://quarto.org/docs/get-started/"
check_required "git" "git" "https://git-scm.com/downloads"

python_cmd=""
if python_cmd=$(first_available python3 python); then
    echo -e "  ${GREEN}[OK]${RESET} Python found: $(version_line "$python_cmd")"
    pass=$((pass + 1))
else
    echo -e "  ${RED}[MISSING]${RESET} Python 3 not found - install: https://www.python.org/"
    fail=$((fail + 1))
fi
echo ""

echo -e "${BOLD}Recommended tools:${RESET}"
check_optional "R" "R" "https://www.r-project.org/"
check_optional "GitHub CLI" "gh" "https://cli.github.com/"

stata_cmd=""
if stata_cmd=$(first_available stata-mp stata-se stata StataMP-64 StataSE-64); then
    echo -e "  ${GREEN}[OK]${RESET} Stata found: ${stata_cmd}"
    pass=$((pass + 1))
else
    echo -e "  ${YELLOW}[STRONGLY SUPPORTED]${RESET} Stata not found - install or configure your Stata executable if you want the Stata workflow"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Git configuration:${RESET}"
if command_present git; then
    git_name=$(git config user.name 2>/dev/null || true)
    git_email=$(git config user.email 2>/dev/null || true)
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        echo -e "  ${GREEN}[OK]${RESET} git user: $git_name <$git_email>"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}[OPTIONAL]${RESET} git user.name / user.email not set"
        echo -e "    Run: git config --global user.name \"Your Name\""
        echo -e "    Run: git config --global user.email \"you@example.com\""
        warn=$((warn + 1))
    fi
fi
echo ""

echo -e "${BOLD}Claude hooks:${RESET}"
hook_dir="$(dirname "$0")/../.claude/hooks"
if [ -d "$hook_dir" ]; then
    non_exec=$(find "$hook_dir" -maxdepth 1 \( -name "*.py" -o -name "*.sh" \) ! -perm -u+x 2>/dev/null | wc -l | tr -d ' ')
    if [ "$non_exec" -eq 0 ]; then
        echo -e "  ${GREEN}[OK]${RESET} All hook scripts are executable"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}[OPTIONAL]${RESET} $non_exec hook script(s) not executable"
        echo -e "    Fix: chmod +x .claude/hooks/*.py .claude/hooks/*.sh"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}[OPTIONAL]${RESET} .claude/hooks/ not found"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Palette sync:${RESET}"
palette_script="$(dirname "$0")/check-palette-sync.sh"
if [ -x "$palette_script" ]; then
    if "$palette_script" >/dev/null 2>&1; then
        echo -e "  ${GREEN}[OK]${RESET} Preambles/header.tex and Quarto/theme-template.scss agree on the core palette"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}[OPTIONAL]${RESET} Palette drift detected - run ./scripts/check-palette-sync.sh"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}[OPTIONAL]${RESET} scripts/check-palette-sync.sh missing or not executable"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Summary:${RESET} ${GREEN}${pass} passed${RESET}, ${YELLOW}${warn} warnings${RESET}, ${RED}${fail} failed${RESET}"
echo ""

has_claude="false"; command_present claude && has_claude="true"
has_xelatex="false"; command_present xelatex && has_xelatex="true"
has_quarto="false"; command_present quarto && has_quarto="true"
has_r="false"; command_present R && has_r="true"
has_stata="false"; [ -n "${stata_cmd}" ] && has_stata="true"
has_python="false"; [ -n "${python_cmd}" ] && has_python="true"

if [ "$fail" -gt 0 ]; then
    echo -e "${RED}Some required tools are missing.${RESET}"
    echo ""
    echo -e "${BOLD}What you can do right now:${RESET}"
    if [ "$has_claude" = "true" ]; then
        echo "  - Open Claude Code:                      claude"
        echo ""
        echo "  Inside Claude Code:"
        if [ "$has_quarto" = "true" ]; then
            echo "    /deploy HelloWorld                 # render Quarto sample"
        fi
        if [ "$has_xelatex" = "true" ]; then
            echo "    /compile-latex HelloWorld          # compile Beamer sample"
        fi
        if [ "$has_python" = "true" ]; then
            echo "    /data-analysis-python [dataset]    # Python empirical workflow"
        fi
        if [ "$has_stata" = "true" ]; then
            echo "    /data-analysis-stata [dataset]     # Stata empirical workflow"
        fi
        if [ "$has_r" = "true" ]; then
            echo "    /data-analysis-r [dataset]         # R empirical workflow"
        fi
    else
        echo "  - Install Claude Code first: https://claude.ai/install"
    fi
    echo ""
    echo -e "${BOLD}Next:${RESET} install the missing required tool(s) listed above, then re-run this script."
    exit 1
fi

echo -e "${GREEN}Setup looks good!${RESET} Next steps:"
echo "  1. Open Claude Code in this directory:  claude"
echo "  2. Compile the sample deck:              /compile-latex HelloWorld"
echo "  3. Deploy the Quarto sample:             /deploy HelloWorld"
echo "  4. Start empirical work in your language of choice:"
if [ "$has_python" = "true" ]; then
    echo "     /data-analysis-python [dataset]"
fi
if [ "$has_stata" = "true" ]; then
    echo "     /data-analysis-stata [dataset]"
else
    echo "     /data-analysis-stata [dataset]   # after Stata is installed/configured"
fi
if [ "$has_r" = "true" ]; then
    echo "     /data-analysis-r [dataset]"
fi
echo ""
exit 0
