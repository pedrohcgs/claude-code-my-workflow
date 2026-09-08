---
name: draft-paper
description: Draft one or more research-paper sections from an existing evidence bundle, with paper-type-aware architecture, notation and citation discipline, verified numerical provenance, and staged approval for full manuscripts. Use for substantive manuscript production; use academic-writing for a small prose edit.
---

# Draft the research paper

Produce manuscript prose from the project's actual evidence. This workflow is
for building sections or a full draft; use `$academic-writing` for a bounded
paragraph-level revision and `$respond-to-referees` for an R&R response.

## Resolve the evidence bundle

Identify the authoritative manuscript source before editing. Then inspect, when
available:

- the research specification and approved strategy memo;
- the current manuscript and its include/import structure;
- analysis scripts and saved outputs behind reported results;
- table fragments, figures, appendices, and the reproducibility passport;
- `Bibliography_base.bib` or the project's declared canonical bibliography;
- `.codex/references/project-profile.md`, journal profile, and established
  notation; and
- a `$voice-profile` artifact when the user has one.

Report missing evidence and its consequence. A voice profile is optional. It may
guide style but never override evidence, notation, venue, or integrity rules.
Do not replace an existing manuscript architecture merely because a scaffold is
available.

## Choose the manuscript architecture

Classify the paper as reduced-form, structural, theory plus empirics,
descriptive/measurement, survey experiment, formal theory, or another stated
type. Read the matching section of
[section-architecture.md](references/section-architecture.md), then adapt it to
the target venue and current draft. Use
[paragraph-moves.md](references/paragraph-moves.md) while drafting and follow
[manuscript-authoring.md](../../../.codex/guidance/manuscript-authoring.md) for
displays and generated fragments.

Before a full-manuscript draft, present a compact section plan, contribution
claim, evidence map, and unresolved inputs. Ask for approval when the plan would
set or materially change the paper's framing, contribution, or section order.
For a single requested section, preserve the approved framing already present.

## Draft from evidence

- Lead each paragraph with its job and keep one main claim per paragraph.
- Preserve defined notation and the manuscript's citation commands.
- Calibrate causal, structural, descriptive, and theoretical language to the
  design actually supported.
- Give quantitative claims magnitude, units, uncertainty where relevant, and a
  traceable table, figure, equation, saved output, or citation.
- Position the paper against checked sources; never invent a citation key or
  bibliographic fact.
- Use visible markers such as `[SOURCE NEEDED]`, `[NUMBER NEEDED]`, or
  `[AUTHOR DECISION]` rather than smoothing over missing support.

Predictions, hypothesized signs, simulated examples, and proposed robustness
checks are not empirical findings. Do not draft an empirical Results section—or
a Conclusion that states empirical findings as observed—until actual outputs
exist and the relevant numbers have passed `$audit-reproducibility`. Lead result
paragraphs with the finding, magnitude, units, and uncertainty, not with table
navigation.

## Stage and verify

For a full draft, use the checkpoints in
[drafting-checkpoints.md](references/drafting-checkpoints.md). Write only to the
authoritative manuscript source or its established section files. Never
hand-edit generated table fragments or figures.

After drafting:

1. reconcile every numerical claim against the reproducibility record;
2. verify every new citation key against the canonical bibliography and use
   `$verify-claims` when factual support needs independent checking;
3. compile or render the authoritative manuscript and inspect the artifact;
4. run `$proofread`; and
5. use `$humanize` or `$review-paper` when the user requests those broader
   audits or the publication stakes warrant them.

Do not submit, contact journals, commit, or rewrite analysis code unless the user
separately authorizes that work.
