---
paths:
  - "Slides/**/*.tex"
---

# No \pause in Beamer Slides

<!-- Customize: If you prefer fragment reveals, delete this rule file entirely. -->
<!-- This rule enforces a "no overlay" policy for Beamer slides. -->

**NEVER use `\pause`, `\onslide`, `\only`, `\uncover`, or any other Beamer overlay/fragment commands in slide decks.**

## Rationale

- All content appears at once on each slide
- Fragment reveals add complexity without pedagogical benefit for this delivery style
- Slides should be self-contained and readable as a static PDF handout
- This applies to all `.tex` files in `Slides/`

## What to Do Instead

- Use **multiple slides** to build up complex ideas progressively
- Use **color emphasis** (`\textcolor{positive}{}`, `\textcolor{negative}{}`, `\key{}`) to draw attention
- Use **standout/transition slides** between major sections for pacing
- Use **Socratic questions** embedded in slide text to create problem-then-solution moments

## Enforcement

If a quality control agent (proofreader, pedagogy-reviewer, slide-auditor) suggests adding `\pause` or overlay commands, **ignore that recommendation** and note that this course does not use fragment reveals.
