---
name: extract-tikz
description: Extract TikZ diagrams from Beamer `.tex` source, compile each to a standalone PDF, and convert to SVG with 0-based indexing. Use when user says "extract the tikz", "regenerate the diagrams", "rebuild the SVGs", "sync tikz to quarto", or after editing TikZ blocks in a Beamer deck that also has a Quarto mirror.
argument-hint: "[LectureN, e.g., Lecture2]"
allowed-tools: ["Read", "Bash", "Glob", "Task"]
---

# Extract TikZ Diagrams to SVG

Extract TikZ diagrams from the Beamer source, compile to multi-page PDF, and convert each page to SVG for use in Quarto slides.

> **Creating a brand-new diagram instead of extracting?** Use [`/new-diagram`](../new-diagram/SKILL.md) — it scaffolds from `templates/tikz-snippets/` with the prevention rules pre-applied.

## Steps

### Step 0: Freshness Check (MANDATORY)

**Before compiling, verify that `extract_tikz.tex` matches the current Beamer source.**

1. Find the Beamer source: `ls Slides/$ARGUMENTS*.tex`
2. Extract all `\begin{tikzpicture}` blocks from Beamer
3. Compare with `Figures/$ARGUMENTS/extract_tikz.tex`
4. If ANY difference exists: update extract_tikz.tex from the Beamer source
5. If extract_tikz.tex doesn't exist: create it from scratch

### Step 1: Prevention pre-check (MANDATORY — halt on violation)

Before compiling, verify every `\begin{tikzpicture}` block in `Figures/$ARGUMENTS/extract_tikz.tex` satisfies the prevention rules in [`.claude/rules/tikz-prevention.md`](../../rules/tikz-prevention.md). The pre-check is a small Python script shared with `/new-diagram` so both skills enforce identical behavior:

```bash
python3 scripts/check-tikz-prevention.py "Figures/$ARGUMENTS/extract_tikz.tex"
```

What it checks:

- **P3 — `scale=X` without node scaling.** Bare `scale=` shrinks coordinates but not text. Allowed forms: `scale=X, every node/.style={scale=X}` or `scale=X, transform shape`. The checker parses the full `\begin{tikzpicture}[...]` options block even when it spans multiple lines.
- **P4 — Directional keyword on edge labels.** Every edge label (`node` inside a `\draw`) must carry `above`, `below`, `left`, `right`, or a compound (e.g. `above left`). `midway` alone is a path position, not a direction. The checker scans the full `\draw ...;` statement so `\draw` on one line and `node[...]{...}` on the next line are still linked.

Note what the pre-check does NOT enforce: P1 (boxed-node explicit dimensions) and P2 (coordinate-map comment) are structural and get flagged by `tikz-reviewer` in Step 8, not here.

Exit codes: `0` = all files pass, `1` = one or more P3/P4 violations (stderr lists file, line, snippet, rule), `2` = usage error.

If exit is non-zero: halt, report the offending lines, and ask the user to fix the Beamer source (single source of truth). Do NOT compile.

### Step 2: Navigate to the lecture's Figures directory
```bash
cd Figures/$ARGUMENTS
```

### Step 3: Compile the extract_tikz.tex file
```bash
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode extract_tikz.tex
```

### Step 4: Count the number of pages
```bash
pdfinfo extract_tikz.pdf | grep "Pages:"
```

### Step 5: Convert each page to SVG using 0-BASED INDEXING

**CRITICAL: PDF pages are 1-indexed, but output SVG files are 0-indexed!**

```bash
PAGES=$(pdfinfo extract_tikz.pdf | grep "Pages:" | awk '{print $2}')
for i in $(seq 1 $PAGES); do
  idx=$(printf "%02d" $((i-1)))
  pdf2svg extract_tikz.pdf tikz_exact_$idx.svg $i
done
```

### Step 6: Sync to docs/ for deployment
```bash
cd ../..
./scripts/sync_to_docs.sh $ARGUMENTS
```

### Step 7: Verify SVG files
- Read 2-3 SVG files to confirm they contain valid SVG markup
- Confirm file sizes are reasonable (not 0 bytes)

### Step 8: Visual Quality Review (tikz-reviewer)

Spawn the **tikz-reviewer** agent (via `Task` with `subagent_type=tikz-reviewer`) on the TikZ source blocks to catch label overlaps, geometric errors, and visual inconsistencies. The reviewer cites specific passes and formulas from [`.claude/rules/tikz-measurement.md`](../../rules/tikz-measurement.md). If it returns **NEEDS REVISION** or **REJECTED**, loop:

1. Apply the recommended fixes to the Beamer `.tex` source (single source of truth).
2. Re-copy the updated block to `extract_tikz.tex`.
3. Re-run the prevention pre-check (Step 1) and compile.
4. Regenerate SVGs, re-sync.
5. Re-invoke tikz-reviewer.

Stop when tikz-reviewer returns **APPROVED** (max 5 rounds).

### Step 9: Report results

## Source of Truth Reminder
TikZ diagrams MUST be edited in the Beamer `.tex` file first, then copied verbatim to `extract_tikz.tex`. See `.claude/rules/single-source-of-truth.md`.
