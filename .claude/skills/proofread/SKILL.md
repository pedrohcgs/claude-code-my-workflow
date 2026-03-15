---
name: proofread
description: Run the proofreading protocol on manuscript or other academic writing files. Checks grammar, typos, academic writing style, consistency, and number accuracy. Produces a report without editing files.
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Proofread Manuscript Files

Run the mandatory proofreading protocol on academic writing files. This produces a report of all issues found WITHOUT editing any source files.

## Steps

1. **Identify files to review:**
   - If `$ARGUMENTS` is a specific filename: review that file only
   - If `$ARGUMENTS` is `all`: review all files in `manuscript/`

2. **For each file, launch the proofreader agent** that checks for:

   **GRAMMAR:** Subject-verb agreement, articles, prepositions, tense consistency
   **TYPOS:** Misspellings, duplicated words, punctuation errors
   **ACADEMIC STYLE:** Contractions, vague hedges, overly long sentences, awkward phrasing
   **CONSISTENCY:** Variable name formatting, notation, terminology, citation format
   **NUMBERS:** Statistics in text match tables, significance levels match stars, sample sizes consistent
   **CITATIONS:** Every claim cited, references complete, no orphan citations

3. **Produce a detailed report** for each file listing every finding with:
   - Location (section / paragraph)
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category and severity

4. **Save each report** to:
   `quality_reports/[FILENAME_WITHOUT_EXT]_proofread.md`

5. **IMPORTANT: Do NOT edit any source files.**
   Only produce the report. Fixes are applied separately after user review.

6. **Present summary** to the user:
   - Total issues found per file
   - Breakdown by category
   - Most critical issues highlighted (especially number discrepancies)
