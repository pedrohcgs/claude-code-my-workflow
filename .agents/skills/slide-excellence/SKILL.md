---
name: slide-excellence
description: Coordinate a comprehensive review of a Beamer or Quarto RevealJS research presentation across rendered layout, proofreading, substantive accuracy, and format-specific graphics. Use for seminar or conference deck readiness.
---

# Research-presentation excellence

Resolve the source deck, engine, rendered artifact, audience, venue, time limit,
and requested review depth before dispatching work. Require a successful Beamer
PDF build or Quarto HTML render before calling the deck visually ready. Run
independent lenses in parallel when available:

- `$visual-audit` for rendered layout;
- `$proofread` for language and notation consistency;
- a domain reviewer for claims, framing, and omitted assumptions;
- a TikZ reviewer when Beamer/TikZ diagrams changed.

Require every finding to cite a slide or source location. Deduplicate findings, adjudicate contradictions, and rank them as blocking, major, or polish. Do not equate reviewer agreement with truth; verify factual and mathematical objections against sources.

For Quarto, give the visual lens screenshots of every slide captured at 1600×900
and the source `.qmd`; do not substitute source inspection for rendered HTML.
Return one prioritized revision list and a readiness verdict. In fast mode, run
visual and proofreading lenses only and label the omitted checks.
