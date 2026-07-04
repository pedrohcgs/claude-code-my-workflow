# `paper/` — Descriptive note

The short descriptive note/paper for this project lives here as a Quarto document
that renders to PDF:

```bash
quarto render paper/ipo_returns_note.qmd
```

The note documents the data sources (WRDS + Jay Ritter's IPO data), situates the
work in the IPO-returns literature (see `Bibliography_base.bib`), and reports the
findings. It shares the single bibliography with the slide deck.

**Status:** scaffold only — the manuscript is authored in a later task. The build
direction and conventions match the deck: the `.qmd` is the single source of truth;
the PDF is the derived artifact (see `.claude/rules/single-source-of-truth.md`).
