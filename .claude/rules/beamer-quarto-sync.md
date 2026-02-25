---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
---

# Beamer → Quarto Auto-Sync Rule (MANDATORY)

**Every edit to a Beamer `.tex` file MUST be immediately synced to the corresponding Quarto `.qmd` file — automatically, without the user asking.** This is non-negotiable.

## The Rule

When you modify a Beamer `.tex` file, you MUST also apply the equivalent change to the Quarto `.qmd` (if it exists) **in the same task**, before reporting completion. Do NOT wait to be asked. Do NOT just "flag the drift." Just do it.

## Lecture Mapping

<!-- Customize this table for your lectures -->
| Lecture | Beamer | Quarto |
|---------|--------|--------|
<!-- Add rows as you create lectures -->

## Workflow (Every Time)

1. Apply fix to Beamer `.tex`
2. **Immediately** apply equivalent fix to Quarto `.qmd`
3. Compile Beamer (3-pass xelatex)
4. Render Quarto (`./scripts/sync_to_docs.sh LectureN`)
5. Only then report task complete

## LaTeX → Quarto Translation Reference

| Beamer | Quarto Equivalent |
| ------ | ----------------- |
| `\begin{block}{Title}` | `::: {.keybox}\n**Title**` |
| `\begin{alertblock}{Title}` | `::: {.highlightbox}\n**Title**` |
| `\begin{exampleblock}{Title}` | `::: {.methodbox}\n**Title**` |
| `\textbf{text}` | `**text**` |
| `\emph{text}` | `*text*` |
| `\item text` | `- text` |
| `\bm{x}` | `$\boldsymbol{x}$` |
| `\cite{key}` | `@key` |
| `\bibentry{key}` | `@key` (full reference via CSL) |
| `$formula$` | `$formula$` (same) |

## When NOT to Sync

- Quarto file doesn't exist yet
- Change is LaTeX-only infrastructure (preamble, theme files)
- Explicitly told to skip Quarto sync

## Enforcement

Before marking any Beamer editing task as complete, check:
> "Did I also update the Quarto file?"

If the answer is no and a Quarto file exists, **you are NOT done.**

## When to Update This Table

After creating a new Quarto translation, add it to the mapping table above.
