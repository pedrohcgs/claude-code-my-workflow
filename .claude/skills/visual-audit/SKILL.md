---
name: visual-audit
description: Adversarial visual-layout audit of a Quarto `.qmd` or Beamer `.tex` deck. Flags overflow, font inconsistency, box fatigue, spacing, and alignment issues. Use when user says "visual audit", "check the layout", "does this overflow?", "look for visual issues", "audit the slides", or after reworking a deck's appearance. Does NOT check writing or pedagogy — pair with `/proofread` or `/pedagogy-review`.
argument-hint: "[QMD or TEX filename]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash"]
disallowed-tools: ["Edit", "MultiEdit"]
---

# Visual Audit of Slide Deck

Perform a thorough visual layout audit of a slide deck.

## Steps

1. **Read the slide file** specified in `$ARGUMENTS`

2. **For Quarto (.qmd) files:**
   - Render with `quarto render Quarto/$ARGUMENTS`
   - Measure the render: `"${SLIDE_QA_PYTHON:-python3}" scripts/slide-qa.py Quarto/<deck>.html`. It loads the deck in headless Chrome with every fragment shown and writes `quality_reports/audits/slide-qa/<deck>/report.md` — per-slide pixels past each edge, the offending element, content hidden inside scrolling elements — plus one screenshot per slide, and broken images or local files whose path is missing or in the wrong letter case (these break on GitHub Pages). OVERFLOW findings come from this report, and a broken or wrong-case asset is a finding too; Read the screenshots of flagged and dense slides for the other checks.
   - If it exits 2 (usually Playwright is missing — the script prints the one-time venv install and the `SLIDE_QA_PYTHON` line to set), say so, fall back to reading the rendered HTML of the dense slides and any screenshot the user supplies, and name the slides the user should eyeball

3. **For Beamer (.tex) files:**
   - Compile (see `/compile-latex`), then run `python3 scripts/beamer-qa.py Slides/<deck>.pdf`. It saves one screenshot per page to `quality_reports/audits/beamer-qa/<deck>/`, prints which frame and overlay step each page is, and lists the errors and the warnings that matter from the `.log` beside the PDF (overfull boxes, undefined references, missing characters). Read the screenshots of dense pages and of every page the log names.
   - A frame whose content runs into the footline often compiles with no warning. To flag it, add `--band-mm FROM TO`: any ink between FROM and TO mm above the bottom edge is reported. The band depends on the theme, so measure it once on a screenshot: pick a strip just above the footline that a correct page leaves empty, and add `--band-x-max PCT` to skip a page number or navigation symbols on the right.
   - If it exits 2 (no PDF, or poppler missing; the script prints the install line), fall back to reading the PDF pages that carry figures or dense content

4. **Audit every slide for:**

   **OVERFLOW:** Content exceeding slide boundaries
   **FONT CONSISTENCY:** Inline font-size overrides, inconsistent sizes
   **BOX FATIGUE:** 3+ colored boxes on one slide (INV-7 allows two), wrong box types
   **SPACING:** Missing negative margins, missing fig-align
   **LAYOUT:** Missing transitions, missing framing sentences, semantic colors

5. **Produce a report** organized by slide with severity and recommendations

6. **Follow the spacing-first principle:**
   1. Reduce vertical spacing with negative margins
   2. Consolidate lists
   3. Move displayed equations inline
   4. Reduce image/SVG size
   5. Last resort: font size reduction (never below 0.85em)
