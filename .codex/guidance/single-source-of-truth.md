---
paths: ["Slides/**/*.tex", "Slides/**/*.qmd", "Figures/**/*.tex", "scripts/R/**", "manuscript*.tex"]
---
# Single source of truth

```
analysis code + inputs -> saved results -> tables/figures -> manuscript numbers
approved strategy/model -> analysis contract and interpretation limits
approved manuscript -> narrative scope and notation -> research talk
TikZ source -> rendered diagram
TeX source -> rendered PDF
QMD source + local assets -> rendered RevealJS HTML
canonical bibliography -> all citations
```

These authorities are layered, not interchangeable: the manuscript cannot
override generated numbers, while analysis output does not silently settle
narrative framing or notation. A talk derives claims from the approved manuscript
and values from verified outputs; discrepancies must be reconciled upstream.

Never hand-edit generated output to change substantive content. Fix upstream and
regenerate. Compare rendered TikZ with current source; trace cited numbers to
saved results and generating code; and register every display of a shared claim
in the reproducibility passport. Committed generated artifacts need discoverable
provenance and regeneration commands.
