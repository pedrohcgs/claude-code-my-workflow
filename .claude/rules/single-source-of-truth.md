---
paths:
  - "Figures/**/*"
  - "Quarto/**/*.qmd"
  - "Slides/**/*.tex"
  - "paper/**/*.qmd"
---

# Single Source of Truth: Enforcement Protocol

**The Quarto `.qmd` file is the authoritative source for ALL slide and paper content. The Beamer PDF is a *derived* artifact rendered from it.**

> **Project-specific inversion.** This project authors a single Quarto `.qmd` that renders directly to a **Beamer PDF** (`format: beamer`, `pdf-engine: xelatex`). There is no hand-authored Beamer `.tex` and no RevealJS-HTML / GitHub-Pages target. This inverts the upstream template's default (where a Beamer `.tex` was authoritative and Quarto produced a derived HTML mirror). If you ever restore the HTML path, restore the upstream version of this rule.

## The SSOT Chain

```
Quarto .qmd (SOURCE OF TRUTH)
  ├── quarto render --to beamer → Beamer PDF (derived deliverable)
  │       uses  Preambles/header.tex  (include-in-header, xelatex)
  ├── Bibliography_base.bib (shared)
  └── Figures/**, scripts/R/_outputs/*.{pdf,rds} (data source for figures)

NEVER hand-edit the rendered PDF or any intermediate .tex Quarto emits.
ALWAYS change content in the .qmd, then re-render.
```

The intermediate `.tex` Quarto produces on the way to the PDF is a build artifact — do not edit it, do not commit it, and do not treat it as a source.

---

## Styling lives in the LaTeX preamble, not SCSS

`Quarto/theme-template.scss` styles **RevealJS HTML only**. Beamer PDF output ignores SCSS entirely — its colors, fonts, and theme come from the LaTeX preamble in `Preambles/header.tex`, pulled in via the deck's `include-in-header:`. Under this project's QMD→Beamer build, **`theme-template.scss` is vestigial**; to change a color or font, edit `Preambles/header.tex`.

---

## Render-and-Verify Protocol (MANDATORY)

**Content only counts once it has rendered.** After any content edit to a `.qmd`:

1. Re-render to Beamer PDF:
   ```bash
   quarto render Quarto/<deck>.qmd --to beamer
   ```
2. Open the PDF and confirm: no overfull boxes / overflow, every equation renders, every `[@key]` citation resolves, figures appear at the right size.
3. If the render fails or a slide overflows, fix the `.qmd` and re-render — never patch the emitted `.tex`.

### When to Re-Render

- Any edit to the `.qmd` content, preamble include, or a referenced figure.
- Before any commit that includes `.qmd` changes (the quality gate scores the source; the PDF is your visual proof).
- After changing `Preambles/header.tex` (theme/color/font changes only show up on re-render).

---

## Figures

Figures come from `scripts/R/_outputs/` (ggplot PDFs) or `Figures/`. Beamer embeds **PDF** figures natively — no SVG conversion is needed (SVG was an HTML-only requirement). Regenerate figures from their R source, never hand-edit a committed figure.

---

## Content Fidelity Checklist

```
[ ] Render check: `quarto render --to beamer` produces a PDF with no errors
[ ] Math check: every equation renders correctly in the PDF
[ ] Citation check: every [@key] resolves against Bibliography_base.bib
[ ] Figure check: every figure referenced by the .qmd exists and renders
[ ] Overflow check: no slide overflows its frame in the PDF
[ ] Source-only edits: the .qmd is the only file edited; no intermediate .tex touched
```
