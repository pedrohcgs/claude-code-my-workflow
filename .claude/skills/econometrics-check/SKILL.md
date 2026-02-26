---
name: econometrics-check
description: Causal inference design audit. Dispatches the Econometrician agent in standalone mode for 4-phase review (claim, design validity, inference, polish). Covers DiD, IV, RDD, Synthetic Control, and Event Studies. Use when working on empirical papers, strategy memos, or R scripts with causal estimators.
disable-model-invocation: true
argument-hint: "[paper .tex, strategy memo, R script, or directory path]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Econometrics Check

Run a 4-phase causal inference audit on the target file(s) by dispatching the **Econometrician** agent in standalone mode.

## Workflow

### Step 1: Parse Input

Determine target from `$ARGUMENTS`:
- **`.tex` file:** Review paper for identification claims, assumption statements, estimation descriptions
- **`strategy-memo-*.md`:** Review strategy memo BEFORE code is written (early design check)
- **`.R` / `.do` / `.py` / `.jl` file:** Review script for code-theory alignment, package usage, SE computation
- **Directory (e.g., `scripts/R/`):** Review all scripts, then synthesize
- **No argument:** Review `Paper/main.tex` if it exists, else ask user

### Step 2: Context Gathering

Before launching the reviewer:
1. Read the target file(s)
2. Read `Bibliography_base.bib` to check citation availability
3. Read `.claude/rules/domain-profile.md` for field-specific conventions
4. If reviewing scripts: also read the paper (if available) for code-theory alignment
5. If a strategy memo exists in `quality_reports/`: read it for design intent

### Step 3: Launch Econometrician Agent

Delegate to the `econometrician` agent via Task tool:

```
Prompt: Review [file] through all 4 phases of the econometrics review protocol.
Mode: Standalone (not within pipeline — skip orchestrator routing).
Focus on: [identified causal design if known, otherwise "identify the design first"].
Context: [brief summary of what the paper/script does, from Step 2].
Save report to: quality_reports/[FILENAME_WITHOUT_EXT]_econometrics_review.md
```

The agent runs 4 sequential phases:
1. **Claim identification** — what design, estimand, treatment, control
2. **Core design validity** — design-specific assumptions + sanity check (sign, magnitude, dynamics)
3. **Inference** — SE clustering, multiple testing, code-theory alignment
4. **Polish & completeness** — robustness, sensitivity, citation fidelity

**Early stopping:** If Phase 2 finds CRITICAL issues, the agent focuses there.

### Step 4: Present Summary

Present to the user:
1. **Design(s) identified** (DiD staggered, IV, RDD, etc.)
2. **Overall assessment** (SOUND / MINOR ISSUES / MAJOR ISSUES / CRITICAL ERRORS)
3. **Blocking issues** (CRITICAL severity — must fix)
4. **Priority action list** (top 3-5 fixes, ordered by importance)
5. **Positive findings** (what the analysis does well)

### Step 5: Score

Report the Econometrician's score. In standalone mode, this is the component score (not the weighted aggregate). Reference `scoring-protocol.md` for how this feeds into the overall score when run within the pipeline.

---

## Principles

- **Design-opinionated, package-flexible.** Recommend standard packages but accept and validate alternatives.
- **Respect the researcher.** If this is the researcher's own methodological contribution, focus on implementation, not lectures.
- **Actionable output.** Every issue must have a concrete fix.
- **Proportional.** Not every paper needs every robustness check. Flag missing checks but note when omissions are reasonable.
- **Sequential phases.** Never skip to robustness before verifying the core design holds.
