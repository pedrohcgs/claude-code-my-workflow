---
name: slide-excellence
description: Multi-agent slide review (visual, pedagogy, proofreading, plus TikZ/parity/substance conditionally). Use for comprehensive quality check before milestones.
argument-hint: "[QMD or TEX filename]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Task"]
context: fork
---

# Slide Excellence Review

Run a comprehensive multi-dimensional review of lecture slides. Multiple agents analyze the file independently, then results are synthesized.

**Important:** this orchestrator does **conditional** dispatch — it only spawns the subagents that can actually produce useful output for the given file. No more running `tikz-reviewer` on a file with zero TikZ, or `quarto-critic` on a deck without a counterpart.

## Step 1: Identify the File

Parse `$ARGUMENTS` for the filename. Resolve path in `Quarto/` or `Slides/`.

Determine the file type:

- `.tex` → Beamer
- `.qmd` → Quarto
- `.md` → Markdown slides

## Step 2: Pre-flight — Detect Conditions

Before spawning any agent, probe the file to determine which reviews make sense:

```bash
FILE="$resolved_path"

# Has TikZ diagrams?
has_tikz=$(grep -c '\\begin{tikzpicture}' "$FILE" 2>/dev/null); has_tikz=${has_tikz:-0}

# For .qmd: is there a paired .tex in Slides/?
has_tex_pair="false"
if [[ "$FILE" == *.qmd ]]; then
  base="$(basename "$FILE" .qmd)"
  # Common Beamer suffixes: _Topic, _Lecture, exact match
  for candidate in "Slides/${base}.tex" "Slides/Lecture${base}.tex"; do
    if [ -f "$candidate" ]; then
      has_tex_pair="true"
      tex_pair="$candidate"
      break
    fi
  done
fi

# For .tex: is there a paired .qmd in Quarto/?
has_qmd_pair="false"
if [[ "$FILE" == *.tex ]]; then
  base="$(basename "$FILE" .tex)"
  for candidate in "Quarto/${base}.qmd" "Quarto/${base#Lecture}.qmd"; do
    if [ -f "$candidate" ]; then
      has_qmd_pair="true"
      qmd_pair="$candidate"
      break
    fi
  done
fi

# Has R code chunks or referenced R scripts?
has_r="false"
if grep -qE '```\{r|source\(.*\.R\)' "$FILE" 2>/dev/null; then
  has_r="true"
fi
```

Report the detection:

```
File:         path/to/file.tex
Type:         Beamer (.tex)
TikZ blocks:  3
Quarto pair:  Quarto/Lecture2.qmd (found)
R chunks:     none
```

## Step 3: Domain-reviewer customization check (MANDATORY for .tex)

Before spawning the substance-review agent on a `.tex` file, verify `.claude/agents/domain-reviewer.md` has been customized for this project. The ship-state domain-reviewer is a **template** — running it unmodified produces generic "are assumptions stated?" feedback, not real domain review.

Detection heuristic (any of these → still template):

- Contains the marker token `AUTO-DETECT-TEMPLATE-MARKER` anywhere in the file (present in the shipped template; removed/replaced when customized). Detection is a substring match — the marker can span lines.
- Contains any `<!-- Customize: ... -->` or `[Customize: ...]` placeholder (both forms are checked).
- The five lenses are identical to the shipped template's wording (diff against `.claude/agents/domain-reviewer.md` on the v1.3.0 tag — if zero lines changed, it's still template).

If the template marker is present:

```
⚠️  domain-reviewer.md has not been customized for your field.

Running it in its shipped state produces generic checks ("are assumptions
stated?") rather than field-specific review. Options:

  1. Customize .claude/agents/domain-reviewer.md — replace the 5 lenses
     with checks for your field. The /configure-project skill will scaffold
     this interactively (coming in PR D of the plan).
  2. Run slide-excellence with --skip-substance to proceed without the
     substance-review agent. Other reviewers still run.
  3. Run slide-excellence with --acknowledge-template-domain-reviewer to
     proceed anyway (you'll get generic feedback from the substance agent).

What would you like to do?
```

Wait for user input. Do NOT silently run domain-reviewer on a template.

## Step 4: Run Review Agents in Parallel

Spawn only the agents whose conditions hold:

**Always-on for slides (`.tex` or `.qmd`):**

- **Agent A: Visual Audit** (`slide-auditor`)
  Overflow, font consistency, box fatigue, spacing, images.
  Save: `quality_reports/[FILE]_visual_audit.md`.

- **Agent B: Pedagogical Review** (`pedagogy-reviewer`)
  13 pedagogical patterns, narrative, pacing, notation.
  Save: `quality_reports/[FILE]_pedagogy_report.md`.

- **Agent C: Proofreading** (`proofreader`)
  Grammar, typos, consistency, academic quality, citations.
  Save: `quality_reports/[FILE]_proofread_report.md`.

**Conditional:**

- **Agent D: TikZ Review** (`tikz-reviewer`) — only if `has_tikz > 0`.
  Measurement-based collision audit (Bézier, gaps, boundaries, margins).
  Save: `quality_reports/[FILE]_tikz_review.md`.

- **Agent E: Content Parity** (`quarto-critic`) — only if the file has a counterpart (`has_tex_pair` or `has_qmd_pair`).
  Frame count comparison, environment parity, content drift between `.tex` ↔ `.qmd`.
  Save: `quality_reports/[FILE]_parity_report.md`.

- **Agent F: R Code Review** (`r-reviewer`) — only if `has_r == true`.
  Code correctness for any embedded R chunks or referenced scripts.
  Save: `quality_reports/[FILE]_r_review.md`.

- **Agent G: Substance Review** (`domain-reviewer`) — MANDATORY for `.tex`, OPTIONAL for `.qmd`, GATED by Step 3.
  Domain correctness via the 5-lens framework.
  Save: `quality_reports/[FILE]_substance_review.md`.

**De-duplication:** if the user has already run one of these skills on this file in the current session (e.g., ran `/proofread` first, now running `/slide-excellence`), ask whether to reuse the existing report or re-run. Default: reuse (saves tokens).

## Step 5: Synthesize Combined Summary

Only include sections for agents that actually ran.

```markdown
# Slide Excellence Review: [Filename]

**File:** [path]
**Type:** [Beamer / Quarto / Markdown]
**Detected:** TikZ=N | pair=[path or none] | R=[yes/no]
**Agents spawned:** [A, B, C, D, G] (skipped: E [no pair], F [no R])

## Overall Quality Score: [EXCELLENT / GOOD / NEEDS WORK / POOR]

| Dimension | Critical | Medium | Low |
|-----------|----------|--------|-----|
| Visual/Layout | | | |
| Pedagogical | | | |
| Proofreading | | | |
| TikZ (if ran) | | | |
| Substance (if ran) | | | |

### Critical Issues (Immediate Action Required)
### Medium Issues (Next Revision)
### Recommended Next Steps
```

## Step 6: Report Token/Time Budget

After completion, print an estimate:

```
Spawned N agents; approx token usage ~XXk. Sequential fallback
(one agent at a time) would cost ~XXk but take ~5× longer. For
cost-conscious reviews, run individual subagent skills directly
(/proofread, /visual-audit, /pedagogy-review).
```

## Flag Reference

| Flag | Effect |
|---|---|
| `--skip-substance` | Don't spawn Agent G (domain-reviewer). Useful if you haven't customized domain-reviewer.md yet. |
| `--acknowledge-template-domain-reviewer` | Proceed with the un-customized domain-reviewer anyway; you accept that the substance review will be generic. |
| `--fast` | Spawn a single synthesis agent reading the file directly, rather than parallel subagents. Cheaper (~8k vs ~50k tokens) but less thorough. |

## Quality Score Rubric

| Score | Critical | Medium | Meaning |
|-------|----------|--------|---------|
| Excellent | 0-2 | 0-5 | Ready to present |
| Good | 3-5 | 6-15 | Minor refinements |
| Needs Work | 6-10 | 16-30 | Significant revision |
| Poor | 11+ | 31+ | Major restructuring |

## Why conditional dispatch matters

The previous version of this orchestrator spawned **all 6** subagents regardless of file type. Running `tikz-reviewer` on a TikZ-free deck produced an empty report (wasted tokens). Running `quarto-critic` without a counterpart file produced a "no pair to compare" report (wasted tokens). And running `domain-reviewer` without customization produced generic "are assumptions stated?" feedback that authors learned to ignore (eroded trust in the whole orchestrator).

Conditional dispatch cuts token cost roughly in half on typical `.qmd`-only files and doubles trust by never running a reviewer that can't produce useful output.
