---
paths:
  - "slides/**/*.tex"
  - "scripts/**/*.py"
  - "scripts/stata/**/*.do"
  - "project/**/*.do"
  - "project/**/*.py"
  - "project/**/*.do"
  - "project/**/*.py"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For LaTeX/Beamer Slides:
1. Compile with xelatex (MikTeX `--include-directory` syntax) and check for errors
2. Open the PDF to verify figures render: `start slides/FILENAME.pdf`
3. Check for overfull hbox warnings

## For Python Scripts:
1. Run `python scripts/python/filename.py`
2. Verify output files (PDF, pickle, parquet, CSV) were created with non-zero size
3. Spot-check estimates for reasonable magnitude

## For Stata Scripts:
1. Run `stata-mp -b do scripts/stata/filename.do`
2. Check the log file in `scripts/stata/logs/` for errors
3. Verify output files (tables, figures) were created

## For TikZ Diagrams:
1. Browsers **cannot** display PDF images inline --- ALWAYS convert to SVG
2. Use SVG (vector format) for crisp rendering: `pdf2svg input.pdf output.svg`
3. Verify SVG files contain valid XML/SVG markup
4. **Freshness check:** Before using any TikZ SVG, verify extract_tikz.tex matches current Beamer source

## Common Pitfalls:
- **PDF images in HTML**: Browsers don't render PDFs inline --- convert to SVG
- **Assuming success**: Always verify output files exist AND contain correct content
- **Stale TikZ SVGs**: extract_tikz.tex diverges from Beamer source --- always diff-check

## Verification Checklist:
```
[ ] Output file created successfully
[ ] No compilation/render errors
[ ] Images/figures display correctly
[ ] Opened in viewer to confirm visual appearance
[ ] Reported results to user
```
