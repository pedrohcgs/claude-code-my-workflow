---
paths: ["paper/**/*.tex", "manuscript*.tex", "Figures/**", "scripts/R/_outputs/**", "scripts/python/_outputs/**"]
---

# Manuscript authoring and displays

Venue instructions and an approved project profile override these defaults.
The authoritative manuscript source owns prose, captions, notes, labels, and
display placement; analysis code owns generated values and graphics.

## Generated tables

- Generate numeric table bodies from analysis code and include them as fragments
  in the manuscript. Do not hand-edit a generated fragment to change a value,
  label, sample, or specification.
- Keep table title, caption, notes, source, label, and venue-specific wrappers in
  a maintained manuscript layer unless the pipeline deliberately generates and
  tests the entire display.
- Use human-readable variable and specification labels while preserving a
  documented mapping to code names.
- State units, sample, weighting, uncertainty method, fixed effects or controls,
  and significance conventions needed to interpret the display.
- Treat stars, decimal precision, notes, and column order as venue-controlled
  choices rather than universal defaults.

## Figures

- Prefer vector output for line art, statistical plots, and diagrams when the
  target format preserves it; use raster output when the underlying content
  calls for it.
- Label axes, groups, units, uncertainty, sample, and data source. Captions should
  state the finding or purpose, not merely repeat the title.
- Use encodings distinguishable under common color-vision deficiencies and in
  grayscale; never rely on color alone.
- Export at dimensions appropriate to the manuscript and separately optimize
  talk figures rather than scaling a dense paper display until it is unreadable.

## Labels, references, and provenance

- Give every equation, table, figure, appendix, and section a stable semantic
  label; resolve every cross-reference in the rendered artifact.
- Keep one canonical bibliography and verify every new key and attributed claim.
- Trace each reported number to a saved output and generating script through the
  reproducibility passport. If a generated display changes, reconcile every
  manuscript and presentation claim that consumes it.
- Compile or render from the authoritative source and inspect the output. A clean
  command exit alone does not establish correct placement, legibility, or source
  alignment.
