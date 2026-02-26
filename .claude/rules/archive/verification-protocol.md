---
paths:
  - "Paper/**/*.tex"
  - "Talks/**/*.tex"
  - "scripts/**/*.R"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For Paper LaTeX (Paper/main.tex):
1. Compile with 3-pass xelatex + bibtex, check for errors
2. Verify all `\ref{}` and `\cite{}` resolve (no undefined references)
3. Check for overfull hbox warnings above 1pt
4. Verify tables compile and display correctly
5. Verify figures exist at referenced paths (`Figures/`, `Tables/`)
6. Report verification results

## For Talk Beamer (Talks/*.tex):
1. Compile with xelatex, check for errors
2. Verify figures/tables match paper versions
3. Check for overfull hbox warnings
4. Verify slide count is appropriate for format

## For R Scripts:
1. Run `Rscript scripts/R/filename.R`
2. Verify output files (PDF, RDS, .tex tables) were created with non-zero size
3. Spot-check estimates for reasonable magnitude
4. Verify `set.seed()` is present for stochastic analyses

## Common Pitfalls:
- **Assuming success**: Always verify output files exist AND contain correct content
- **Stale figures**: R script output may be older than paper revision — check timestamps
- **Hardcoded paths**: Paths must be relative to project root
- **Missing packages**: Check `library()` calls match documented dependencies

## Verification Checklist:
```
[ ] Output file created successfully
[ ] No compilation/render errors
[ ] Figures/tables display correctly
[ ] All references and citations resolve
[ ] Reported results to user
```
