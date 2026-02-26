---
name: create-talk
description: Generate Beamer presentations by dispatching the Storyteller agent (creator) and Discussant agent (critic). Supports 4 formats — job market, seminar, short, lightning. Derives all content from the paper.
disable-model-invocation: true
argument-hint: "[format: job-market | seminar | short | lightning] [paper path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task", "Bash"]
---

# Create Talk

Generate a Beamer presentation by dispatching the **Storyteller** (creator) and **Discussant** (critic).

**Input:** `$ARGUMENTS` — format name, optionally followed by paper path.

---

## Workflow

### Step 1: Parse Arguments

- **Format** (required): `job-market` | `seminar` | `short` | `lightning`
- **Paper path** (optional): defaults to `Paper/main.tex`
- If no format specified, ask the user.

### Format Constraints

| Format | Slides | Duration | Content Scope |
|--------|--------|----------|---------------|
| Job market | 40-50 | 45-60 min | Full story, all results, mechanism, robustness |
| Seminar | 25-35 | 30-45 min | Motivation, main result, 2 robustness, conclusion |
| Short | 10-15 | 15 min | Question, method, key result, implication |
| Lightning | 3-5 | 5 min | Hook, one result, so-what |

### Step 2: Launch Storyteller Agent

Delegate to the `storyteller` agent via Task tool:

```
Prompt: Create a [format] talk from [paper].
Read the paper and extract: research question, identification strategy, main result,
secondary results, robustness checks, key figures/tables, institutional background.
Design narrative arc for [format] format.
Build Beamer .tex file with shared preamble if available.
Compile with XeLaTeX.
Save to Talks/[format]_talk.tex
```

The Storyteller follows these principles:
- One idea per slide
- Figures > tables (tables in backup)
- Build tension: motivation → question → method → findings → implications
- Transition slides between major sections
- All claims must appear in the paper (single source of truth)

### Step 3: Launch Discussant Agent (Talk Critic)

After Storyteller returns, delegate to the `discussant` agent:

```
Prompt: Review the talk at Talks/[format]_talk.tex.
Check 5 categories:
  1. Narrative flow — does the story build properly?
  2. Visual quality — overflow, readability, consistency
  3. Content fidelity — every claim traceable to paper
  4. Scope for format — right amount of content for duration
  5. Compilation — does it compile cleanly?
Score as advisory (non-blocking).
Save report to quality_reports/[format]_talk_review.md
```

### Step 4: Fix Critical Issues

If Discussant finds Critical issues (compilation failures, content not in paper):
1. Re-dispatch Storyteller with specific fixes (max 3 rounds per three-strikes.md)
2. Re-run Discussant to verify

### Step 5: Present Results

1. Generated `.tex` file path
2. Slide count and format compliance
3. Discussant score (advisory, non-blocking)
4. TODO items (missing figures, tables not yet generated)

---

## Output

Save to `Talks/[format]_talk.tex` (e.g., `Talks/seminar_talk.tex`).

---

## Principles

- **Paper is authoritative.** Every claim must appear in the paper.
- **Less is more.** Especially for short and lightning — ruthlessly cut.
- **Audience calibration.** Job market = rigor. Seminar = interesting result. Lightning = sell the idea.
- **Advisory scoring.** Talk scores don't block commits.
- **Worker-critic pairing.** Storyteller creates, Discussant critiques. Never skip the review.
