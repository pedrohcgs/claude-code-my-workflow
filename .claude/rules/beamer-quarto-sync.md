---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
---

# Beamer ↔ Quarto Sync — INACTIVE for this project

**This project has no Beamer `.tex` ↔ Quarto `.qmd` bridge to keep in sync.** The deck is authored in a single Quarto `.qmd` and rendered directly to a Beamer **PDF** (`quarto render --to beamer`). There is no hand-authored `.tex` source and no RevealJS-HTML mirror, so the upstream template's two-way auto-sync rule does not apply here.

## What replaces it

There is only one source (`.qmd`) and one derived artifact (the PDF). The "sync" step is simply **re-rendering the PDF** after a content edit. The authoritative protocol is [`single-source-of-truth.md`](single-source-of-truth.md):

1. Edit content in the `.qmd`.
2. `quarto render Quarto/<deck>.qmd --to beamer`.
3. Verify the PDF (render succeeds, no overflow, citations resolve).

Do not hand-edit the intermediate `.tex` Quarto emits, and do not treat any `.tex` as a content source.

## If you restore the HTML path

If a future direction re-adds a RevealJS-HTML mirror (or a hand-authored Beamer source), restore the upstream version of this rule and of `single-source-of-truth.md` together — the two-way sync and the SSOT direction must agree.
