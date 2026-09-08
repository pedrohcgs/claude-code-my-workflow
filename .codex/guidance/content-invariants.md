---
paths: ["Slides/**/*.tex", "Slides/**/*.qmd", "Preambles/**/*.tex", "scripts/R/**", "manuscript*.tex"]
---
# Content invariants

Treat these as hard constraints:

- Beamer/TeX or Quarto/QMD source is authoritative for its research presentation; rendered PDF or HTML is derived.
- Analysis code and saved outputs are authoritative for numbers. The approved manuscript is authoritative for narrative scope and notation; talks derive from both and cannot introduce unsupported claims.
- Symbols, signs, units, sample definitions, and estimands stay consistent across manuscript, presentation, code, tables, and figures.
- Use one canonical bibliography and resolve every citation key there.
- TikZ source is authoritative; regenerate previews after source changes.
- Do not use Beamer overlays such as `\pause`, `\only`, `\visible`, or `\onslide`; keep each frame's argumentative state explicit.
- Do not use RevealJS incremental fragments for research talks; keep each audited slide state explicit.
- Never invent citations, results, values, or provenance. Unknowns remain marked.
- Do not present predictions or planned results as observed empirical findings. Empirical Results and Conclusions require actual verified outputs.
- A code or data change that can alter a reported number requires claim reconciliation and cross-artifact verification.

When an invariant conflicts with an explicit user instruction, surface the conflict and follow the user.
