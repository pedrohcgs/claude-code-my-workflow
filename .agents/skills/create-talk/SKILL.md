---
name: create-talk
description: Create a finished research presentation from a manuscript and verified outputs, calibrated to the audience and time limit, using Beamer by default or Quarto RevealJS when explicitly selected. Use for job-market, seminar, conference, defense, or lightning talks; not lectures or deployment.
---

# Create a research talk

Build a finished, rendered deck whose claims remain traceable to the manuscript
and analysis. `$present-paper` produces a plan only; use this skill when the user
wants presentation source and a verified artifact.

## Resolve the brief and sources

Determine the paper path, audience, venue, time limit, talk type, and engine. If
the engine is omitted, use Beamer. Use Quarto RevealJS only when the user chooses
Quarto or an existing research-talk source is `.qmd`. Do not infer permission to
translate lectures, synchronize Beamer and Quarto, deploy a site, or publish.

Read the manuscript, its cited displays, the approved strategy or model summary,
and the saved outputs behind every proposed quantitative claim. Also read the
customized project profile and existing presentation theme when present. Treat
the approved manuscript as authoritative for narrative scope and notation and
the analysis outputs as authoritative for numbers. Flag discrepancies instead
of choosing whichever version makes the cleaner slide.

## Design the arc

Classify the paper and read the relevant section of
[narrative-arcs.md](references/narrative-arcs.md). Use
[format-planning.md](references/format-planning.md) to build a timed outline and
[slide-design.md](references/slide-design.md) while authoring.

The opening should establish the question, contribution, and reason to care
before technical detail. Every main-deck slide needs one defensible message and
a source location. Prefer figures and annotated estimates over paper-sized
tables. Keep derivations, secondary robustness, and anticipated objections in
backup unless they are essential to the audience's evaluation.

Do not force a predetermined slide count. Allocate minutes to argumentative
beats, reserve interruption or Q&A time appropriate to the venue, and test the
timing from the rendered deck. If repeated revisions cannot produce a coherent
question–evidence–takeaway arc, report a likely manuscript-framing problem to the
user; do not silently rewrite the paper.

## Author the source

Write into `Slides/` unless the project declares another authoritative talk
directory. Inspect before overwriting an existing deck.

- **Beamer:** preserve the project's preamble/theme when present; otherwise
  adapt [beamer-scaffold.tex](assets/beamer-scaffold.tex). Keep each frame's
  argumentative state explicit—no `\pause`, `\only`, `\visible`, or `\onslide`.
- **Quarto:** adapt [quarto-scaffold.qmd](assets/quarto-scaffold.qmd) and
  [talk-theme.scss](assets/talk-theme.scss). Keep RevealJS transitions and
  incremental reveals off so the source and audited slide states agree. When
  the talk cites sources, add a `bibliography` path to the project's canonical
  bibliography after copying the scaffold into the talk directory.

Add speaker notes with the point, timing, and likely questions for each main
slide. Preserve citation keys from the canonical bibliography. Never invent a
result, reference, figure, or unverified package option; visible placeholders
are preferable to unsupported content.

## Render and verify

For Beamer, run `$compile-latex` and inspect the rendered PDF. For Quarto, first
confirm that `quarto` is available, then run:

```bash
quarto render Slides/<deck>.qmd
```

Open the rendered RevealJS HTML at a fixed 1600×900 viewport and capture each
slide for inspection. Check all source and asset paths, citations, equations,
speaker notes, overflow, clipping, contrast, font size, and figure labels. If
browser capture is unavailable, report that rendered visual QA remains
unverified rather than inferring success from HTML source.

Run `$slide-excellence` on the rendered artifact and source. Re-render after
authorized fixes and inspect every changed slide plus the full-deck transitions.
Return the source path, artifact path, timing assessment, claim-source gaps, and
checks run. Do not commit, deploy, or publish without separate authorization.
