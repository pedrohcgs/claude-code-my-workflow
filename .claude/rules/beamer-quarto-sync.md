---
paths:
  - "Slides/**/*.tex"
---

# Beamer → Quarto Sync Rule

> **PROJECT NOTE (mh_layoff):** Quarto/RevealJS is NOT used in this project.
> The mandatory sync rule below is **INACTIVE** — there are no `.qmd` counterparts.
> This file is kept for future-proofing (if Quarto is added later, populate the
> lecture mapping table and re-activate the rule).

---

## The Rule (Inactive — No Quarto in This Project)

When a project uses both Beamer and Quarto, every edit to a Beamer `.tex` file
MUST be immediately synced to the corresponding Quarto `.qmd` file, in the same
task, before reporting completion.

## Lecture Mapping

<!-- No Quarto files in this project. Add entries here if Quarto is introduced. -->
| Lecture | Beamer | Quarto |
|---------|--------|--------|
| *(none yet)* | -- | -- (not used) |

## Workflow (When Quarto IS Used)

1. Apply fix to Beamer `.tex`
2. **Immediately** apply equivalent fix to Quarto `.qmd`
3. Compile Beamer (3-pass xelatex)
4. Render Quarto (`./scripts/sync_to_docs.sh LectureN`)
5. Only then report task complete

## When NOT to Sync

- Quarto file doesn't exist yet (current state of this project)
- Change is LaTeX-only infrastructure (preamble, theme files)
- Explicitly told to skip Quarto sync
- **This entire project** — Quarto not used; skip sync entirely

## LaTeX → Quarto Translation Reference

*(Kept for reference if Quarto is added later)*

| Beamer | Quarto Equivalent |
| ------ | ----------------- |
| `\muted{text}` | `[text]{style="color: #525252;"}` |
| `\key{text}` | `[**text**]{.key}` |
| `\item text` | `- text` |
| `$formula$` | `$formula$` (same) |
