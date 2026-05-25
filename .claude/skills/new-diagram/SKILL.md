---
name: new-diagram
description: Scaffold a new TikZ diagram from the snippet gallery with prevention rules pre-applied (explicit node dimensions, coordinate map, directional edge labels). Compiles standalone, invokes tikz-reviewer with citations from tikz-measurement.md, and loops on revisions until APPROVED.
argument-hint: "[snippet-name] [output.tex] (both optional; interactive if omitted)"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Task"]
effort: high
disable-model-invocation: true
---

# Create a New TikZ Diagram

Scaffold a diagram from `templates/tikz-snippets/`, check it against the prevention rules, compile standalone, run the reviewer with measurement citations, and loop until the diagram passes. Use this **instead of** writing TikZ from scratch; the snippets embed the invariants that `tikz-prevention.md` requires.

## Inputs

- `$0` (optional) — snippet name (without `.tex`). One of the filenames in `templates/tikz-snippets/`. If omitted, list the gallery and ask the user to pick.
- `$1` (optional) — output path. Defaults to `Figures/new_diagram.tex` — ask the user if this target exists so we don't clobber.

## Workflow

### Step 1: Pick a snippet

```bash
ls -1 templates/tikz-snippets/*.tex
```

Current gallery (see [`templates/tikz-snippets/README.md`](../../../templates/tikz-snippets/README.md) for descriptions):

- `dag-basic` — 3-node causal DAG (X → Y with confounder U)
- `dag-mediation` — X → M → Y with direct path
- `did-two-period` — two-period difference-in-differences
- `event-study` — event-time coefficients with 95% CIs
- `timeline` — horizontal timeline with staggered events
- `regression-scatter` — scatter + OLS fit + confidence band
- `flowchart-3step` — vertical flow with decision diamond
- `supply-demand` — supply/demand with shifted demand

If `$0` is not one of these, or is omitted, ask the user which to use.

### Step 2: Copy the snippet to the output path

```bash
SRC="templates/tikz-snippets/$0.tex"
DST="${1:-Figures/new_diagram.tex}"

# Confirm before overwriting
if [ -f "$DST" ]; then
  echo "Output path already exists: $DST"
  # Ask the user whether to overwrite. Do NOT clobber silently.
fi

mkdir -p "$(dirname "$DST")"
cp "$SRC" "$DST"
```

### Step 3: Edit the content to fit the user's intent

Ask the user what the diagram should show. Edit `$DST` with the `Edit` tool:

1. Update the comment block at the top so the **intent sentence** matches the user's goal.
2. Update the **coordinate map** comment if coordinates change.
3. Rename nodes and edit labels. Keep node style (`dag-node`, `flow-node`, etc.) unless the meaning actually changes.
4. **Do not** add a bare `scale=X` to the tikzpicture options. Coordinates shrink, text does not — collisions follow. Allowed forms: `scale=X, every node/.style={scale=X}` or `scale=X, transform shape`. See [`tikz-prevention.md` P3](../../rules/tikz-prevention.md) for the full rule and `tikz-visual-quality.md` for the `scale=1.1` convention.
5. **Every** new edge label must carry a directional keyword (`above`, `below`, `left`, `right`, `above left`, etc.). `midway` alone is a path position, not a direction — P4 violation.

### Step 4: Prevention pre-check (MANDATORY)

Run the same shared Python checker `/extract-tikz` uses — this is the one tool that enforces both P3 and P4 consistently across the two skills:

```bash
python3 scripts/check-tikz-prevention.py "$DST"
```

- Exit `0` → passed, continue.
- Exit `1` → violations (stderr reports line, rule, snippet). Fix `$DST` and re-run until zero.
- Exit `2` → usage error (missing file etc.).

Do NOT re-implement the grep inline. The Python checker correctly handles multi-line `\begin{tikzpicture}[...]` options and multi-line `\draw ... node {...}` spans that a line-oriented grep cannot see.

### Step 5: Standalone compile

All snippets are `\documentclass[border=4pt]{standalone}` so they compile without a Beamer frame and without `Preambles/header.tex`:

```bash
cd "$(dirname "$DST")"
xelatex -interaction=nonstopmode "$(basename "$DST")" > /tmp/tikz-compile.log 2>&1
```

Check exit code and `*.pdf` file size. If compile fails, read `/tmp/tikz-compile.log` and fix the `.tex` source.

### Step 6: Visual review via tikz-reviewer

Spawn the `tikz-reviewer` agent with `Task` (`subagent_type=tikz-reviewer`). Pass the `.tex` source and the compiled `.pdf` path. The reviewer is now required to cite the pass and formula from [`tikz-measurement.md`](../../rules/tikz-measurement.md) for every CRITICAL/MAJOR finding — vague reports are rejected.

Loop:

1. If `APPROVED` → go to Step 7.
2. If `NEEDS REVISION` or `REJECTED` → apply fixes to `$DST`, re-run Step 4 (prevention pre-check), re-compile (Step 5), re-invoke reviewer.

**Max 5 rounds.** If after 5 rounds the reviewer is still reporting CRITICAL issues, surface the situation to the user — the snippet or the requested content may need redesign, not just tweaking.

### Step 7: Optional — convert to SVG for Quarto

If the user plans to use the diagram in Quarto slides (not just Beamer), convert the compiled PDF to SVG:

```bash
pdf2svg "${DST%.tex}.pdf" "${DST%.tex}.svg" 1
```

Snippet-based diagrams are single-page, so a single `.svg` with the same basename as `.tex` is correct here. This differs from `/extract-tikz`, which produces a multi-page PDF from a `Figures/LectureN/extract_tikz.tex` master and names outputs `tikz_exact_00.svg, tikz_exact_01.svg, ...` (0-based filenames over 1-indexed PDF pages). If you need multi-page output for slide-by-slide reveals, use `/extract-tikz` instead.

### Step 8: Clean up build artifacts

```bash
cd "$(dirname "$DST")"
rm -f *.aux *.log *.out *.synctex.gz
```

Leave the `.pdf` and `.svg` (if generated). They're what downstream tools use.

### Step 9: Report

Print a summary:

- Snippet used → output path
- Reviewer verdict and number of rounds
- `.pdf` size and page count
- `.svg` path if generated
- Reminder to `\input` or `\includegraphics` the diagram in the target Beamer/Quarto file

## Why start from a snippet?

Writing TikZ from scratch reliably produces collisions because the author cannot visually estimate where curves and labels will land. The snippets embed the invariants that `tikz-prevention.md` requires — coordinate maps, explicit node dimensions, directional edge labels — so the diagram passes the prevention pre-check by construction. You can always deviate from the snippet; the rules still apply.

## Cross-references

- [`.claude/rules/tikz-prevention.md`](../../rules/tikz-prevention.md) — the P1–P6 authoring rules.
- [`.claude/rules/tikz-measurement.md`](../../rules/tikz-measurement.md) — the six-pass protocol with formulas the reviewer cites.
- [`.claude/rules/tikz-visual-quality.md`](../../rules/tikz-visual-quality.md) — general visual standards.
- [`.claude/skills/extract-tikz/SKILL.md`](../extract-tikz/SKILL.md) — for pulling TikZ out of an existing Beamer deck instead of creating new.
- [`templates/tikz-snippets/README.md`](../../../templates/tikz-snippets/README.md) — gallery inventory and adaptation guide.
