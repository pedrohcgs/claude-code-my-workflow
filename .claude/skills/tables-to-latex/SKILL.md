---
name: tables-to-latex
description: Convert Stata regression output or descriptive statistics to publication-ready LaTeX tables. Applies booktabs styling, proper alignment, and significance stars.
argument-hint: "[table name or 'new' or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit"]
---

# Convert Stata Output to LaTeX Tables

Generate publication-ready LaTeX tables from Stata output.

## Usage

```
/tables-to-latex table1    # Create/update Table 1
/tables-to-latex new       # Create new table from scratch
/tables-to-latex all       # Convert all Stata output files
```

## Standard Output Format

Every table must follow these standards:

### Preamble (include in .tex or header)

```latex
\usepackage{booktabs}
\usepackage{siunitx}
\sisetup{
    input-symbols = (),
    table-space-text-post = ***,
    table-format = -1.3
}
```

### Regression Table Template

```latex
\begin{table}[htbp]
\caption{Main Results}
\label{tab:main}
\centering
\begin{tabular}{l*{3}{S}}
\toprule
               & {(1)}   & {(2)}   & {(3)}   \\
               & {Dep Var} & {Dep Var} & {Dep Var} \\
\midrule
Variable       & 0.123*** & 0.098**  & 0.075   \\
               & (0.041)  & (0.039)  & (0.052) \\
\midrule
Observations   & {1,234}  & {1,234}  & {1,234} \\
R-squared      & {0.456}  & {0.512}  & {0.534} \\
\bottomrule
\end{tabular}
\end{table}
```

### Significance Stars

| p-value | Symbol |
|---------|--------|
| p < 0.10 | * |
| p < 0.05 | ** |
| p < 0.01 | *** |

## Common Conversions

1. **esttab output** — Direct export from Stata
2. **Manual matrix** — Convert matrix to tabular
3. **Summary stats** — Means, SDs to formatted table

## Steps

1. Locate the Stata output file or relevant .do file
2. Identify the data to display
3. Generate LaTeX using appropriate template
4. Save to `Tables/` directory
5. Verify compilation with XeLaTeX
