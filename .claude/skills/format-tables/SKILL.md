---
name: format-tables
description: Verify that Stata-generated output tables in output/tables/ are publication-ready for top accounting journals. Checks booktabs formatting, significance stars, SE presentation, and number formatting.
argument-hint: "[table filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write"]
---

# Format Tables

Verify that Stata-generated tables are publication-ready for top accounting journals (JAR, TAR, CAR, RAS).

**Input:** `$ARGUMENTS` — specific table filename or `all` to check all files in `output/tables/`

---

## Steps

1. **Identify tables to check:**
   - If specific filename: check that file only
   - If `all`: check all `.tex`, `.xlsx`, and `.rtf` files in `output/tables/`

2. **For each `.tex` table, check:**

   **Booktabs formatting:**
   - [ ] Uses `\toprule`, `\midrule`, `\bottomrule` (no `\hline`)
   - [ ] No vertical lines (`|` in column spec)
   - [ ] Column spec uses `l`, `c`, or `r` only

   **Significance stars:**
   - [ ] Stars defined as: `* p<0.10, ** p<0.05, *** p<0.01`
   - [ ] Table note states the star convention explicitly
   - [ ] Stars use `\sym{}` or superscript notation (not literal `*`)

   **Standard errors:**
   - [ ] SEs appear in parentheses directly below coefficients
   - [ ] SE format: 3 decimal places (consistent with coefficient format)

   **Number formatting:**
   - [ ] Coefficients: 3 decimal places
   - [ ] N (observations): integer with comma separator (e.g., `10,432`)
   - [ ] R² / Pseudo-R²: 3 decimal places
   - [ ] No stray `.` representing missing values in published cells
   - [ ] Percentages consistent with text

   **Structure:**
   - [ ] Column headers present and descriptive
   - [ ] Row labels match variable labels (not raw Stata variable names)
   - [ ] Fixed effects rows present (e.g., "Industry FE: Yes/No")
   - [ ] Clustering note present (e.g., "Standard errors clustered at firm level")
   - [ ] Sample description in table note

3. **For each `.xlsx` table** (summary statistics, etc.):
   - Check that numeric formatting is consistent
   - Check that variable names/labels are human-readable
   - Check that units are stated

4. **Report:**

   ```markdown
   ## Table Format Report: [filename]
   **Standard:** JAR/TAR/CAR/RAS publication ready

   ### Issues Found: N

   #### Issue 1: [Brief title]
   - **Location:** [line or section]
   - **Severity:** [CRITICAL / MAJOR / MINOR]
   - **Problem:** [what's wrong]
   - **Fix:** [specific correction]

   ### Verdict: PUBLICATION READY / NEEDS FIXES
   ```

5. **Save report** to `quality_reports/[filename]_table_format.md`

6. **Present summary:** total issues across all tables, most critical issues highlighted.

---

## Publication-Ready Checklist Summary

```
[ ] Booktabs (no hlines, no vertical rules)
[ ] Stars: * p<0.10 ** p<0.05 *** p<0.01
[ ] SEs in parentheses, 3 decimal places
[ ] N as integer with comma
[ ] R² to 3 decimal places
[ ] No raw Stata variable names as row labels
[ ] FE and clustering documented
[ ] Table note explains all symbols
```
