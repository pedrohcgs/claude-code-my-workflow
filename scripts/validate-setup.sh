#!/usr/bin/env bash
# Validate dependencies for the Claude Code and/or Codex workflow.
# Default remains Claude for backward compatibility.
set -uo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

usage() {
    cat <<'EOF'
Usage: ./scripts/validate-setup.sh [--platform claude|codex|all]

  claude  Validate the original Claude Code workflow (default).
  codex   Validate the native Codex research workflow.
  all     Validate both runtimes.
EOF
}

platform="claude"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --platform)
            if [ "$#" -lt 2 ]; then
                echo "validate-setup: --platform requires claude, codex, or all" >&2
                usage >&2; exit 2
            fi
            platform="$2"; shift 2 ;;
        --platform=*) platform="${1#*=}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "validate-setup: unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done
case "$platform" in
    claude|codex|all) ;;
    *) echo "validate-setup: unsupported platform '$platform' (expected claude, codex, or all)" >&2; exit 2 ;;
esac

pass=0; warn=0; fail=0
check_required() {
    local name="$1" cmd="$2" install_url="$3" version
    if command -v "$cmd" >/dev/null 2>&1; then
        version=$("$cmd" --version 2>&1 | sed '/^WARNING:/d' | head -n1)
        echo -e "  ${GREEN}✓${RESET} $name found: ${version:-version unavailable}"
        pass=$((pass + 1))
    else
        echo -e "  ${RED}✗${RESET} $name NOT FOUND — install: ${install_url}"
        fail=$((fail + 1))
    fi
}
check_optional() {
    local name="$1" cmd="$2" install_url="$3" version
    if command -v "$cmd" >/dev/null 2>&1; then
        version=$("$cmd" --version 2>&1 | sed '/^WARNING:/d' | head -n1)
        echo -e "  ${GREEN}✓${RESET} $name found: ${version:-version unavailable}"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} $name not found (optional) — install: ${install_url}"
        warn=$((warn + 1))
    fi
}
check_hook_dir() {
    local label="$1" hook_dir="$2" non_exec
    echo -e "${BOLD}${label} hooks:${RESET}"
    if [ -d "$hook_dir" ]; then
        non_exec=$(find "$hook_dir" -maxdepth 1 -type f \( -name "*.py" -o -name "*.sh" \) ! -perm -u+x 2>/dev/null | wc -l | tr -d ' ')
        if [ "$non_exec" -eq 0 ]; then
            echo -e "  ${GREEN}✓${RESET} All hook scripts are executable"; pass=$((pass + 1))
        else
            echo -e "  ${YELLOW}⚠${RESET} $non_exec hook script(s) not executable"
            echo -e "    Fix: chmod +x ${hook_dir}/*.py ${hook_dir}/*.sh"; warn=$((warn + 1))
        fi
    else
        echo -e "  ${YELLOW}⚠${RESET} ${hook_dir}/ directory not found (are you in the project root?)"
        warn=$((warn + 1))
    fi
    echo ""
}

case "$platform" in
    claude) title="Claude Code Academic Workflow" ;;
    codex) title="Codex Research Workflow" ;;
    all) title="Claude Code + Codex Research Workflows" ;;
esac
echo ""; echo -e "${BOLD}Validating ${title} setup...${RESET}"; echo ""

echo -e "${BOLD}Required tools:${RESET}"
if [ "$platform" = "claude" ] || [ "$platform" = "all" ]; then
    check_required "Claude Code" "claude" "https://claude.ai/install"
    check_required "XeLaTeX" "xelatex" "https://tug.org/texlive/ (or MacTeX: https://tug.org/mactex/)"
    check_required "Quarto" "quarto" "https://quarto.org/docs/get-started/"
fi
if [ "$platform" = "codex" ] || [ "$platform" = "all" ]; then
    check_required "Codex" "codex" "https://developers.openai.com/codex/cli/"
fi
check_required "git" "git" "https://git-scm.com/downloads"
check_required "Python 3" "python3" "https://python.org (needed for hooks and checks)"
echo ""

echo -e "${BOLD}Recommended tools:${RESET}"
check_optional "R" "R" "https://www.r-project.org/"
check_optional "GitHub CLI" "gh" "https://cli.github.com/"
if [ "$platform" = "codex" ]; then
    check_optional "XeLaTeX" "xelatex" "https://tug.org/texlive/ (needed only for LaTeX/Beamer work)"
    check_optional "Quarto" "quarto" "https://quarto.org/docs/get-started/ (needed only for optional RevealJS research talks)"
fi
echo ""

echo -e "${BOLD}Git configuration:${RESET}"
if command -v git >/dev/null 2>&1; then
    git_name=$(git config user.name 2>/dev/null || true); git_email=$(git config user.email 2>/dev/null || true)
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        echo -e "  ${GREEN}✓${RESET} git user: $git_name <$git_email>"; pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} git user.name / user.email not set"
        echo "    Run: git config --global user.name \"Your Name\""
        echo "    Run: git config --global user.email \"you@example.com\""; warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} skipped — install git first"; warn=$((warn + 1))
fi
echo ""

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
if [ "$platform" = "claude" ] || [ "$platform" = "all" ]; then check_hook_dir "Claude Code" "$repo_root/.claude/hooks"; fi
if [ "$platform" = "codex" ] || [ "$platform" = "all" ]; then check_hook_dir "Codex" "$repo_root/.codex/hooks"; fi

echo -e "${BOLD}Git pre-commit gate (v2.0):${RESET}"
pchook="$repo_root/.githooks/pre-commit"
if [ -f "$pchook" ]; then
    if [ -x "$pchook" ]; then
        echo -e "  ${GREEN}✓${RESET} .githooks/pre-commit is executable"; pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} .githooks/pre-commit is NOT executable — git silently skips it"
        echo "    Fix: chmod +x .githooks/pre-commit (or re-run ./scripts/install-hooks.sh)"; warn=$((warn + 1))
    fi
    if command -v git >/dev/null 2>&1; then
        if [ "$(git config core.hooksPath 2>/dev/null || true)" = ".githooks" ]; then
            echo -e "  ${GREEN}✓${RESET} core.hooksPath → .githooks (gate active on every commit)"; pass=$((pass + 1))
        else
            echo -e "  ${YELLOW}⚠${RESET} pre-commit gate not activated — run ./scripts/install-hooks.sh"; warn=$((warn + 1))
        fi
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} .githooks/pre-commit not found"; warn=$((warn + 1))
fi
echo ""

# Palette parity belongs to the original LaTeX/Quarto workflow, not the Codex prerequisite set.
if [ "$platform" = "claude" ] || [ "$platform" = "all" ]; then
    echo -e "${BOLD}Palette sync (LaTeX ↔ SCSS):${RESET}"
    palette_script="$repo_root/scripts/check-palette-sync.sh"
    if [ -x "$palette_script" ] && "$palette_script" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${RESET} Preambles/header.tex ↔ Quarto/theme-template.scss agree on the core palette"; pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} Palette drift or checker unavailable — run ./scripts/check-palette-sync.sh"
        warn=$((warn + 1))
    fi
    echo ""
fi

echo -e "${BOLD}Summary:${RESET} ${GREEN}${pass} passed${RESET}, ${YELLOW}${warn} warnings${RESET}, ${RED}${fail} failed${RESET}"; echo ""
if [ "$fail" -gt 0 ]; then
    echo -e "${RED}Some required tools are missing.${RESET}"
    echo -e "${BOLD}Next:${RESET} install the missing required tool(s), then re-run this script."
    exit 1
fi

echo -e "${GREEN}Setup looks good!${RESET} Next steps:"
case "$platform" in
    claude)
        echo "  1. Open Claude Code in this directory:  claude"
        echo "  2. Compile the sample deck:             /compile-latex HelloWorld"
        echo "  3. Deploy the Quarto sample:            /deploy HelloWorld" ;;
    codex)
        echo "  1. Review AGENTS.md and .codex/config.toml"
        echo "  2. Open Codex in this directory:        codex"
        echo '  3. Invoke a research skill by name:      $data-analysis' ;;
    all)
        echo "  1. Review CLAUDE.md and AGENTS.md"
        echo "  2. Start the runtime you want:           claude  or  codex"
        echo "  3. Run the shared gates:                 ./scripts/backtest.sh" ;;
esac
echo ""; exit 0
