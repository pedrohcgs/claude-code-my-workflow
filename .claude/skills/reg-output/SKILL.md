---
name: reg-output
description: Standardize Stata regression output format. Ensures consistent coefficient placement, standard error formatting, significance stars, and variable ordering across all regression tables.
argument-hint: "[specs or 'table name']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit"]
---

# Standardize Regression Output

Ensure all regression tables follow consistent formatting standards for publication.

## Usage

```
/reg-output table1    # Standardize Table 1
/reg-output main      # Standardize main results
/reg-output all       # Standardize all tables
```

## Output Standards

### Coefficient Format

| Element | Format | Example |
|---------|--------|---------|
| Coefficients | 3 decimals | 0.123 |
| SE in parens | (3 decimals) | (0.041) |
| Stars | * p<0.10, ** p<0.05, *** p<0.01 | 0.123*** |

### Table Structure

```latex
\begin{table}[htbp]
\caption{[Title]}
\label{tab:[label]}
\centering
\begin{tabular}{l*{N}{S}}
\toprule
               & {(1)}   & {(2)}   & ... \\
               & {DepVar} & {DepVar} & ... \\
\midrule
[key var]      & 0.123*** & 0.098** & ... \\
               & (0.041)  & (0.039) & ... \\
[control 1]    & 0.045    & 0.032   & ... \\
               & (0.031)  & (0.028) & ... \\
\midrule
Observations   & {1,234}  & {1,234} & ... \\
R-squared      & {0.456}  & {0.512} & ... \\
\bottomrule
\end{tabular}
\end{table}
```

## Checklist

Before finalizing any regression table:

- [ ] Coefficients rounded to 3 decimals
- [ ] Standard errors in parentheses, same precision
- [ ] Significance stars placed correctly
- [ ] Observations in curly braces `{1,234}`
- [ ] R-squared aligned with observations
- [ ] Fixed effects documented in notes
- [ ] Clustering documented in notes

## Common Fixes

| Issue | Fix |
|-------|-----|
| Too many decimals | Round to 3 |
| Stars on wrong side | Move to coefficients, not SE |
| Missing braces on N | Use `{N}` not `N` for siunitx |
| Inconsistent cols | Check all columns have same structure |
