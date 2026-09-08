---
name: visual-audit
description: Perform a read-only rendered-layout audit of a Beamer or Quarto RevealJS research presentation, checking overflow, legibility, consistency, spacing, and alignment. Use for slide-layout review, not prose or substantive review.
---

# Visual audit

Resolve the authoritative source and render it with the matching engine. For
Beamer, compile the source and convert every PDF page to an image. For Quarto
RevealJS, run `quarto render`, open the generated HTML at a fixed 1600×900
viewport, and capture every slide. Inspect every rendered slide, not only source,
the build log, or a subset of pages. If rendering or capture is unavailable,
report the audit as NOT RUN rather than inferring layout from source.

Report findings by slide with severity and evidence for overflow, clipped
content, unreadable text, inconsistent typography or color, excessive boxes,
weak alignment, crowded whitespace, and ambiguous figure labels. For HTML,
also check viewport-dependent wrapping, scrollbars, missing assets, and content
that appears only through an unaudited fragment state. Prefer fixes in this
order: simplify content, improve structure and spacing, resize figures, then
adjust typography; avoid shrinking body text below a legible presentation size.

This skill is read-only. Pair with `$proofread` for language and `$slide-excellence` for combined research-presentation review.
