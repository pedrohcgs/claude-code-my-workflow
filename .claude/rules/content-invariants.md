---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "Quarto/**/*.scss"
  - "Preambles/header.tex"
  - "scripts/R/**/*.R"
---

# Content Invariants (INV-1 through INV-12)

Numbered non-negotiable rules for content produced in this repository. Critic agents, reviewers, and audit agents should cite invariants by number (e.g., "violates INV-3") when flagging issues. Adapted from clo-author's enforcement pattern.

## Slide invariants

> **Build-direction note.** This project renders a single Quarto `.qmd` to a **Beamer PDF** (no RevealJS-HTML target). INV-1 through INV-4 below were written for the upstream HTML-mirror workflow; their status under QMD→Beamer-PDF is annotated inline. See [`single-source-of-truth.md`](single-source-of-truth.md).

- **INV-1: Styling source (was: palette sync).** Beamer styling comes solely from `Preambles/header.tex`; `Quarto/theme-template.scss` is HTML-only and vestigial here. Change colors/fonts in `header.tex`. The `header.tex ↔ SCSS` palette contract (`./scripts/check-palette-sync.sh`) is now **advisory** — keep it in sync only if you ever restore an HTML target.
- **INV-2: PDF fidelity to source.** The rendered Beamer PDF must faithfully reflect the `.qmd`: every equation, symbol, and citation in the source appears correctly in the PDF. (There is no separate `.tex` mirror to drift from — the risk is a stale/failed render, so re-render after every content edit.)
- **INV-3: Quarto CSS override contract — INACTIVE.** Applies only to RevealJS-HTML output (Bootstrap cascade). Not relevant to Beamer PDF.
- **INV-4: Figures are PDF, not SVG.** Beamer embeds **PDF** figures and renders TikZ natively; no SVG conversion is needed (SVG was an HTML-only requirement). Reference `.pdf` figures directly from the `.qmd`.
- **INV-5: Single bibliography.** `Bibliography_base.bib` is the canonical bibliography. No per-deck `.bib` files. All citations must resolve against this one file.

## Slide design invariants

- **INV-6: No `\pause` or overlays.** Beamer `\pause`, `\only`, `\visible`, `\onslide` commands are forbidden. See `.claude/rules/no-pause-beamer.md` for rationale.
- **INV-7: Max 2 colored boxes per slide.** Overusing `keybox`, `definitionbox`, or callout environments creates "box fatigue." Two per slide maximum.
- **INV-8: Motivation before formalism.** Every definition must be preceded by a motivating example, intuition, or real-world question. No unmotivated math.

## R script invariants

- **INV-9: `set.seed()` once at top.** Every R script that uses randomness must call `set.seed(N)` exactly once, at the top of the script, before any stochastic code. Never inside loops or functions.
- **INV-10: Relative paths only.** No absolute paths (`/Users/...`, `C:\...`, `~` expansion). All paths relative to the repository root. Use `file.path()` for cross-platform compatibility.
- **INV-11: Transparent backgrounds for Beamer figures.** All `ggsave()` calls producing figures for Beamer slides must include `bg = "transparent"`.
- **INV-12: Project theme on all plots.** Every ggplot figure must use the project's custom theme. No default ggplot2 gray backgrounds should appear in any committed figure.
