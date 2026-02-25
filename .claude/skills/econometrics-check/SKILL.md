---
name: econometrics-check
description: Causal inference design audit for econometrics research. Reviews identification assumptions, estimator choice, SE clustering, and robustness protocols for DiD (staggered and classic), IV, RDD, Synthetic Control, and event studies. Use when working on empirical economics papers, R scripts implementing causal estimators, or presentation slides with causal claims.
disable-model-invocation: true
argument-hint: "[paper .tex, R script, or directory path]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Econometrics Check

Run a comprehensive causal inference and econometric validity audit on the target file(s).

## Workflow

### Step 1: Parse Input

Determine target from `$ARGUMENTS`:
- **Single `.tex` file:** Review paper or talk for identification claims, assumption statements, estimation descriptions
- **Single `.R` file:** Review script for code-theory alignment, correct package usage, SE computation
- **Directory (e.g., `scripts/R/`):** Review all `.R` files, then synthesize across scripts
- **No argument:** Review `Paper/main.tex` if it exists, else ask user

### Step 2: Context Gathering

Before launching the reviewer:
1. Read the target file(s)
2. Read `Bibliography_base.bib` to check citation availability
3. Read `.claude/rules/r-code-conventions.md` for known pitfalls
4. If reviewing R scripts: also read the paper (if available) to check code-theory alignment

### Step 3: Launch Econometrician Agent

Delegate to the `econometrician` agent via Task tool:

```
Prompt: Review [file] through all 6 lenses of the econometrics review protocol.
Focus on: [identified causal design if known, otherwise "identify the design first"].
Context: [brief summary of what the paper/script does, from Step 2].
```

The agent will produce a structured report with issues ranked by severity.

### Step 4: Save Report

Save the agent's report to:
```
quality_reports/[FILENAME_WITHOUT_EXT]_econometrics_review.md
```

### Step 5: Present Summary

Present to the user:
1. **Design(s) identified** (DiD staggered, IV, RDD, etc.)
2. **Blocking issues** (CRITICAL severity — prevent submission)
3. **Priority action list** (top 3-5 fixes, ordered by importance)
4. **Positive findings** (what the analysis does well)

## Principles

- **Design-opinionated, package-flexible:** Recommend Callaway-Sant'Anna for staggered DiD, `rdrobust` for RDD, etc. — but accept and validate alternative packages (`fastdid`, `did2s`, `augsynth`, etc.) without flagging them as errors.
- **Respect the researcher:** If this is the researcher's own methodological contribution, focus on implementation correctness, not methodology lectures.
- **Actionable output:** Every issue must have a concrete fix, not just "this could be better."
- **Proportional:** Not every paper needs every robustness check. Flag missing checks but acknowledge when omissions are reasonable for the setting.
