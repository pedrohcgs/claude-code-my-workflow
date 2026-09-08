---
name: proofread
description: "Read-only proofreading pass over research presentation `.tex`, `.qmd`, or `.md` files. Checks grammar, typos, likely overflow, terminology consistency, and academic writing quality; produces a report without editing. Use when user says \"proofread\", \"check for typos\", \"look for grammar issues\", \"copy-edit this\", \"any writing errors?\", or before a research presentation."
---



# Proofread Presentation Files

Run the mandatory proofreading protocol on research presentation files. This produces a report of all issues found WITHOUT editing any source files.

## Steps

1. **Identify files to review:**
   - If `the arguments supplied with the invocation` is a specific filename: review that file only
   - If `the arguments supplied with the invocation` is "all": review all research presentation files in `Slides/` and `Markdown/`

2. **For each file, launch the proofreader agent** that checks for:

   **GRAMMAR:** Subject-verb agreement, articles (a/an/the), prepositions, tense consistency
   **TYPOS:** Misspellings, search-and-replace artifacts, duplicated words
   **OVERFLOW:** Overfull hbox (LaTeX), content exceeding slide boundaries (Markdown/Quarto)
   **CONSISTENCY:** Citation format, notation, terminology
   **ACADEMIC QUALITY:** Informal language, missing words, awkward constructions

3. **Produce a detailed report** for each file listing every finding with:
   - Location (line number or slide title)
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category and severity

4. **Save each report** to `quality_reports/`:
   - For `.tex` files: `quality_reports/FILENAME_report.md`
   - For `.qmd` files: `quality_reports/FILENAME_qmd_report.md`
   - For `.md` files: `quality_reports/FILENAME_md_report.md`

5. **IMPORTANT: Do NOT edit any source files.**
   Only produce the report. Fixes are applied separately after user review.

6. **Present summary** to the user:
   - Total issues found per file
   - Breakdown by category
   - Most critical issues highlighted
