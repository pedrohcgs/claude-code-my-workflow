#!/usr/bin/env bash
set -euo pipefail

# build_manuscript.sh — latexmk wrapper with diagnostics
# Usage: ./scripts/build_manuscript.sh Evaluating_GLPT_RCT_Manuscript_Draft
# On Windows (Git Bash), ensure latexmk, xelatex, rg, and pdfinfo are available in PATH.

main=${1:-}
if [ -z "$main" ]; then
  echo "Usage: $0 <main-tex-without-extension>" >&2
  exit 2
fi

cd "$(dirname "$0")/.."

pushd Manuscript >/dev/null 2>&1 || { echo "Manuscript/ dir not found" >&2; exit 2; }

# Determine kpathsea path separator (Windows uses ';', Unix uses ':')
sep=":"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) sep=";" ;;
  *) sep=":" ;;
esac

# Prepend project paths and preserve defaults via trailing separator
export TEXINPUTS="../Preambles${sep}"
export BIBINPUTS="..${sep}"

set +e
latexmk -g -f -xelatex -interaction=nonstopmode "$main.tex"
status=$?
set -e

# Exit codes: treat latexmk code 12 (warnings/nonfatal) as success for summary output
if [ "${status}" -ne 0 ] && [ "${status}" -ne 12 ]; then
  echo "latexmk failed with exit code ${status}. See ${main}.log" >&2
  # If log missing, exit now
  if [ ! -f "$main.log" ]; then
    exit ${status}
  fi
fi

log="$main.log"
pdf="$main.pdf"

if command -v rg >/dev/null 2>&1; then
  ucits=$(rg -n "Citation .* undefined|LaTeX Warning: Citation .* undefined" "$log" | wc -l || true)
  urefs=$(rg -n "Reference .* undefined|LaTeX Warning: Reference .* undefined" "$log" | wc -l || true)
  overfull=$(rg -nF 'Overfull \hbox' "$log" | wc -l || true)
  missing=$(rg -n "! LaTeX Error: File .* not found" "$log" | wc -l || true)
  pages=$(pdfinfo "$pdf" 2>/dev/null | rg "^Pages:" | awk '{print $2}' || echo "?")
else
  ucits=$(grep -En "Citation .* undefined|LaTeX Warning: Citation .* undefined" "$log" | wc -l || true)
  urefs=$(grep -En "Reference .* undefined|LaTeX Warning: Reference .* undefined" "$log" | wc -l || true)
  overfull=$(grep -Fn "Overfull \\hbox" "$log" | wc -l || true)
  missing=$(grep -En "! LaTeX Error: File .* not found" "$log" | wc -l || true)
  pages=$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/ {print $2}' || echo "?")
fi

cat <<EOF
# Manuscript Build Summary
file: $pdf
undefined_citations: $ucits
undefined_refs: $urefs
overfull_hbox: $overfull
missing_files: $missing
pages: $pages
EOF

popd >/dev/null 2>&1
