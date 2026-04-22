---
name: slide-excellence
description: Multi-agent comprehensive slide review (visual + pedagogy + proofreading, plus TikZ / parity / substance conditionally). It also routes embedded empirical code to the matching R, Python, or Stata review skill when detected.
argument-hint: "[QMD or TEX filename] [--fast] [--skip-substance | --acknowledge-template-domain-reviewer]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Task"]
context: fork
---

# Slide Excellence Review

Run a comprehensive multi-dimensional review of lecture slides. Multiple
reviewers analyze the file independently, then results are synthesized.

## Step 1: Identify the file

Resolve `$ARGUMENTS` in `Quarto/` or `Slides/` and determine the file type.

## Step 2: Detect conditions before fanout

Probe the file before spawning reviewers:

```bash
FILE="$resolved_path"

has_tikz=$(grep -c '\\begin{tikzpicture}' "$FILE" 2>/dev/null); has_tikz=${has_tikz:-0}
has_r=$(grep -cE '```\{r|source\(.*\.R\)|scripts/R/.*\.R' "$FILE" 2>/dev/null); has_r=${has_r:-0}
has_python=$(grep -cE '```\{python|scripts/python/.*\.py|\.py`' "$FILE" 2>/dev/null); has_python=${has_python:-0}
has_stata=$(grep -cE '```\{stata|scripts/stata/.*\.do|\.do`' "$FILE" 2>/dev/null); has_stata=${has_stata:-0}
```

Report the detection summary before review.

## Step 3: Domain-reviewer customization gate

For `.tex` files, verify `.codex/agents/domain-reviewer.toml` is customized
before running the substance reviewer. If it is still a template, stop and ask
whether to skip substance review or proceed knowingly.

## Step 4: Run the relevant reviewers

Always run:

- visual audit
- pedagogy review
- proofreading

Conditionally run:

- TikZ review if the file contains TikZ
- parity review if there is a Beamer/Quarto counterpart
- substance review when the domain reviewer is customized
- code review routing:
  - `/review-r` if R chunks or R scripts are referenced
  - `/review-python` if Python chunks or scripts are referenced
  - `/review-stata` if Stata chunks or scripts are referenced

Save each report to `quality_reports/` with a descriptive suffix.

## Step 5: Synthesize

Write a combined summary that includes:

- file type and detection summary
- which reviewers ran versus were skipped
- critical issues
- medium issues
- recommended next steps

## Step 6: Budget note

Print a short note on how many reviewers ran and why conditional routing was
used.
