---
name: proofread
description: Manuscript proofreading dispatching the Proofreader agent. Checks 6 categories — structure, claims-evidence alignment, identification fidelity, writing quality, grammar, and compilation. Produces report without editing files.
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Proofread Manuscript

Run the proofreading protocol by dispatching the **Proofreader** agent.

## Workflow

### Step 1: Identify Files

- If `$ARGUMENTS` is a specific `.tex` file: review that file
- If `$ARGUMENTS` is `all`: review `Paper/main.tex` and all files in `Paper/sections/`
- If `$ARGUMENTS` is a talk file in `Talks/`: review as **advisory** (non-blocking)

### Step 2: Launch Proofreader Agent

Delegate to the `proofreader` agent via Task tool:

```
Prompt: Review [file] through all 6 check categories.
Categories:
  1. Structure — contribution in first 2 pages, standard sequence, transitions
  2. Claims-Evidence — numbers match tables exactly, effect sizes with units
  3. Identification Fidelity — paper matches strategy memo, estimand correct
  4. Writing Quality — anti-hedging, notation consistency, terminology
  5. Grammar & Polish — agreement, articles, tense, artifacts, informality
  6. Compilation & LaTeX — overfull hbox, undefined refs/cites, XeLaTeX errors
Save report to quality_reports/[FILENAME_WITHOUT_EXT]_proofread_report.md
```

### Step 3: Scoring

The Proofreader applies deductions (0-100 scale):

| Issue | Deduction |
|-------|-----------|
| Numbers don't match tables | -25 |
| Paper doesn't compile | -20 |
| Broken citations | -15 |
| Broken references | -15 |
| Overfull hbox > 10pt | -10 per |
| Hedging language | -5 per (max -15) |
| Notation inconsistency | -5 |
| Overfull hbox 1-10pt | -1 per |

### Step 4: Format-Aware Severity

| Context | Scoring |
|---------|---------|
| Paper manuscript | **Blocking** — score gates commits and PRs |
| Talks | **Advisory** — reported but non-blocking |

### Step 5: Present Summary

- Total issues by category
- Score with deductions listed
- Top 3 most critical issues
- Three-strikes escalation (if applicable):
  - Claims don't match → escalate to Coder
  - Strategy misrepresented → escalate to Strategist
  - Framing issues → escalate to User

### IMPORTANT

**Do NOT edit any source files.** Only produce the report. Fixes are applied separately.

---

## Principles

- **Proofreader is a CRITIC, not a creator.** It never writes or revises.
- **Be precise.** Quote exact text, cite exact line numbers.
- **Proportional severity.** A missing comma is Minor. Numbers that don't match tables is Critical.
- **Format-aware.** Papers are blocking; talks are advisory.
