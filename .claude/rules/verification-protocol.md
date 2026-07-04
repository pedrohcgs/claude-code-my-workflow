---
paths:
  - "Quarto/**/*.qmd"
  - "paper/**/*.qmd"
  - "scripts/R/**/*.R"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

> **Build direction (this project):** a Quarto `.qmd` renders to a **Beamer PDF**. There is no RevealJS-HTML / `docs/` deploy and no Beamer-`.tex` source. The HTML/SVG/`sync_to_docs` steps from the upstream template are INACTIVE here (kept below, struck through in intent, only for a future HTML restore). See [`single-source-of-truth.md`](single-source-of-truth.md).

## For the Quarto → Beamer PDF deck (and the paper note):
1. Render: `quarto render Quarto/<deck>.qmd --to beamer` (or `quarto render paper/<note>.qmd`)
2. Confirm the PDF was produced with non-zero size and open it (`open <file>.pdf` on macOS, `xdg-open` on Linux)
3. Check for **overfull hbox** warnings / slide overflow in the render log and the PDF
4. Verify every equation renders and every `[@key]` citation resolves against `Bibliography_base.bib`
5. Verify figures appear at the right size; fix in the `.qmd`, never in the emitted `.tex`
6. Report verification results

## For figures / diagrams:
1. Beamer embeds **PDF** figures natively and renders TikZ directly — no SVG conversion needed (SVG was an HTML-only requirement)
2. Regenerate figures from their R source; never hand-edit a committed figure
3. Confirm the figure file exists with non-zero size before referencing it

## For R Scripts:
1. Run `Rscript scripts/R/filename.R` (or the pipeline via `scripts/R/00_run_all.R`)
2. Verify output files (PDF, RDS, `.tex` tables) were created with non-zero size
3. Spot-check estimates for reasonable magnitude
4. Confirm no raw WRDS/licensed data is written to a tracked path (see [`confidential-data.md`](confidential-data.md))

## Verification Checklist:
```
[ ] Output file (PDF / figure / table) created with non-zero size
[ ] No render or compilation errors; no overfull-hbox / overflow
[ ] Equations render; citations resolve; figures display correctly
[ ] Only the .qmd / R source was edited — no intermediate .tex touched
[ ] No licensed data committed
[ ] Opened the PDF to confirm visual appearance
[ ] Reported results to the user
```

---

## INACTIVE (upstream HTML path — restore only if you re-add a RevealJS target)

<details>
<summary>RevealJS-HTML verification (not used in this project)</summary>

- `./scripts/sync_to_docs.sh` render+deploy, open `docs/slides/*.html`, TikZ-as-SVG via
  `pdf2svg`, `docs/Figures/` sync, and Beamer↔Quarto environment parity. These apply only
  when the deck targets RevealJS HTML, which this project does not produce.
</details>
