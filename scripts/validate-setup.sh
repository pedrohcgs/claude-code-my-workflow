#!/usr/bin/env bash
# =============================================================================
# validate-setup.sh — Verify all dependencies for the academic workflow
#
# Run this after forking the repo to confirm your environment is ready.
# Exits 0 if all required tools are found; non-zero otherwise.
# =============================================================================

set -uo pipefail

# ANSI colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

pass=0
warn=0
fail=0

echo ""
echo -e "${BOLD}Validating Claude Code Academic Workflow setup...${RESET}"
echo ""

check_required() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${RESET} $name found: $("$cmd" --version 2>&1 | head -n1)"
        pass=$((pass + 1))
    else
        echo -e "  ${RED}✗${RESET} $name NOT FOUND — install: ${install_url}"
        fail=$((fail + 1))
    fi
}

check_optional() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${RESET} $name found: $("$cmd" --version 2>&1 | head -n1)"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} $name not found (optional) — install: ${install_url}"
        warn=$((warn + 1))
    fi
}

echo -e "${BOLD}Required tools:${RESET}"
check_required "Claude Code"  "claude"   "https://claude.ai/install"
check_required "XeLaTeX"      "xelatex"  "https://tug.org/texlive/ (or MacTeX: https://tug.org/mactex/)"
check_required "Quarto"       "quarto"   "https://quarto.org/docs/get-started/"
check_required "git"          "git"      "https://git-scm.com/downloads"
check_required "Python 3"     "python3"  "https://python.org (needed for hooks)"
echo ""

echo -e "${BOLD}Recommended tools:${RESET}"
check_optional "R"            "R"        "https://www.r-project.org/"
check_optional "GitHub CLI"   "gh"       "https://cli.github.com/"
# Browser slide QA (scripts/slide-qa.py) runs under SLIDE_QA_PYTHON, usually a venv.
sqa_py="${SLIDE_QA_PYTHON:-python3}"
if "$sqa_py" -c "import playwright" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${RESET} Playwright (browser slide QA) found via $sqa_py"
    pass=$((pass + 1))
else
    echo -e "  ${YELLOW}⚠${RESET} Playwright not found (optional; browser slide QA) — python3 -m venv ~/.venvs/slide-qa && ~/.venvs/slide-qa/bin/pip install playwright, then export SLIDE_QA_PYTHON=~/.venvs/slide-qa/bin/python"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Git configuration:${RESET}"
if command -v git >/dev/null 2>&1; then
    # THIS script's repository, not the shell's: run from elsewhere, a repo-local
    # identity read as "not set", or another repository's was reported as this one's
    # (#171). Outside any repo, git -C still reads the global and system config.
    git_name=$(git -C "$(dirname "$0")/.." config user.name 2>/dev/null || true)
    git_email=$(git -C "$(dirname "$0")/.." config user.email 2>/dev/null || true)
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        echo -e "  ${GREEN}✓${RESET} git user: $git_name <$git_email>"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} git user.name / user.email not set"
        echo -e "    Run: git config --global user.name \"Your Name\""
        echo -e "    Run: git config --global user.email \"you@example.com\""
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} skipped — install git first (see required tools above)"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Claude Code hooks:${RESET}"
# Executable bit only, and only where it matters. settings.json runs every .py hook
# as `python3 <file>`, so their mode is irrelevant (six ship 100644); the .sh hook it
# runs directly (notify.sh) needs +x. Checking the .py hooks warned on every fresh
# clone, and the advised chmod then showed up as a mode change in git status.
# Whether each hook registered in .claude/settings.json — and the
# pre-commit entry point below — is wired to a file that exists, is invocable, and is
# tracked by git is checked by scripts/check-ledger-coverage.py (a gate in backtest.sh).
hook_dir="$(dirname "$0")/../.claude/hooks"
if [ -d "$hook_dir" ]; then
    non_exec=$(find "$hook_dir" -maxdepth 1 -name "*.sh" ! -perm -u+x 2>/dev/null | wc -l | tr -d ' ')
    if [ "$non_exec" -eq 0 ]; then
        echo -e "  ${GREEN}✓${RESET} All hook scripts are executable"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} $non_exec hook script(s) not executable"
        echo -e "    Fix: chmod +x .claude/hooks/*.sh"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} .claude/hooks/ directory not found (are you in the project root?)"
    warn=$((warn + 1))
fi

echo ""
echo -e "${BOLD}Git pre-commit gate (v2.0):${RESET}"
pchook="$(dirname "$0")/../.githooks/pre-commit"
if [ -f "$pchook" ]; then
    if [ -x "$pchook" ]; then
        echo -e "  ${GREEN}✓${RESET} .githooks/pre-commit is executable"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} .githooks/pre-commit is NOT executable — git silently skips it, disabling the gate"
        echo -e "    Fix: chmod +x .githooks/pre-commit  (or re-run ./scripts/install-hooks.sh)"
        warn=$((warn + 1))
    fi
    if command -v git >/dev/null 2>&1; then
        # Ask THIS script's repository, not the one the shell is in, and compare the
        # folder the setting names, not its text: './.githooks', '.githooks/' and an
        # absolute path all activate the gate, and were reported as "not activated".
        # A relative value is relative to the worktree top, as git reads it; --path
        # expands a leading ~.
        vs_top="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null || true)"
        vs_hp="$(git -C "${vs_top:-.}" config --path --get core.hooksPath 2>/dev/null || true)"
        case "$vs_hp" in
            "")            vs_hp_abs="" ;;
            /*|[A-Za-z]:*) vs_hp_abs="$(cd "$vs_hp" 2>/dev/null && pwd -P)" ;;
            *)             vs_hp_abs="$(cd "$vs_top/$vs_hp" 2>/dev/null && pwd -P)" ;;
        esac
        vs_want="$(cd "$vs_top/.githooks" 2>/dev/null && pwd -P)"
        if [ -n "$vs_top" ] && [ -n "$vs_hp_abs" ] && [ "$vs_hp_abs" = "$vs_want" ]; then
            echo -e "  ${GREEN}✓${RESET} core.hooksPath → $vs_hp (gate active on every commit)"
        else
            echo -e "  ${YELLOW}⚠${RESET} pre-commit gate not activated — run ./scripts/install-hooks.sh"
            warn=$((warn + 1))
        fi
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} .githooks/pre-commit not found"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Palette sync (LaTeX ↔ SCSS):${RESET}"
palette_script="$(dirname "$0")/check-palette-sync.sh"
if [ -x "$palette_script" ]; then
    # Rely on the helper's exit code — stable contract, not text matching.
    # 0 = in sync, 1 = divergence.
    if "$palette_script" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${RESET} Preambles/header.tex ↔ Quarto/theme-template.scss agree on the core palette"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} Palette drift — run ./scripts/check-palette-sync.sh for details"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} scripts/check-palette-sync.sh missing or not executable — skipping"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Summary:${RESET} ${GREEN}${pass} passed${RESET}, ${YELLOW}${warn} warnings${RESET}, ${RED}${fail} failed${RESET}"
echo ""

# Which tools did we actually find? Gate the next-step suggestions accordingly.
# Use string flags (not command names) so shellcheck is happy and `if` bodies
# read naturally.
has_claude="false";  command -v claude  >/dev/null 2>&1 && has_claude="true"
has_xelatex="false"; command -v xelatex >/dev/null 2>&1 && has_xelatex="true"
has_quarto="false";  command -v quarto  >/dev/null 2>&1 && has_quarto="true"
has_r="false";       command -v R       >/dev/null 2>&1 && has_r="true"

if [ "$fail" -gt 0 ]; then
    echo -e "${RED}Some required tools are missing.${RESET}"
    echo ""
    echo -e "${BOLD}What you CAN do right now:${RESET}"
    if [ "$has_claude" = "true" ]; then
        echo "  - Open Claude Code:                      claude"
        echo ""
        echo "  ${BOLD}Inside Claude Code${RESET} (these are slash-commands, NOT shell commands):"
        if [ "$has_quarto" = "true" ]; then
            echo "    /deploy HelloWorld         # render Quarto sample"
        fi
        if [ "$has_xelatex" = "true" ]; then
            echo "    /compile-latex HelloWorld  # compile Beamer sample"
        fi
        if [ "$has_r" = "true" ]; then
            echo "    /data-analysis             # orchestrate R analysis"
        fi
        if [ "$has_xelatex" != "true" ]; then
            echo ""
            echo "  (Beamer workflow disabled until you install XeLaTeX: https://tug.org/texlive/)"
        fi
        if [ "$has_quarto" != "true" ]; then
            echo "  (Quarto deploy disabled until you install Quarto: https://quarto.org/docs/get-started/)"
        fi
    else
        echo "  - Install Claude Code first: https://claude.ai/install"
        echo "    (Everything else in this template is orchestrated through Claude.)"
    fi
    echo ""
    echo -e "${BOLD}Next:${RESET} install the missing required tool(s) listed above, then re-run this script."
    exit 1
fi

echo -e "${GREEN}Setup looks good!${RESET} Next steps:"
echo "  1. Open Claude Code in this directory:  claude"
echo "  2. Compile the sample deck:              /compile-latex HelloWorld"
echo "  3. Deploy the Quarto sample:             /deploy HelloWorld"
echo ""
exit 0
