---
paths: ["quality_reports/**", "scripts/**", "*.tex", "Slides/**"]
---

# Research lifecycle and handoff contracts

This is a map, not an autonomous pipeline. Enter at any stage whose inputs
already exist, return upstream when evidence changes, and invoke only the work
the user requested.

```text
question/discovery
        ↓ approved research specification
empirical strategy or model
        ↓ approved estimand, assumptions, and analysis contract
analysis
        ↓ verified saved outputs and displays
manuscript
        ↓ rendered, reconciled draft
independent review and revision
        ↓ resolved findings and verified artifact
submission or presentation
```

## Handoffs

### Discovery → strategy

Required: a clear question, candidate population/outcome/treatment or theoretical
object, relevant checked literature, and an honest account of available data.
Use `$strategize` to record the estimand, identifying variation, assumptions,
specification, inference, robustness, falsification, and rejected alternatives.

### Strategy → analysis

Confirmatory analysis uses the user-approved strategy memo as its contract.
Exploration remains allowed when labeled as exploration. Record deviations from
the approved estimand, sample, variables, estimator, inference, or planned tests
before interpreting the resulting estimates as confirmatory.

### Analysis → manuscript

Required: saved outputs with provenance, human-readable tables or figures, the
generating code, and reconciled units/sample/specification labels. `$draft-paper`
may draft a results plan before this handoff, but empirical findings and
conclusions wait for actual verified outputs.

### Manuscript → review

Required: an authoritative source, successful render, canonical bibliography,
and declared links to analysis artifacts. Reviewer agents receive only the
artifact and evidence required for their independent lens. Findings remain
candidates until adjudicated against source or an executable oracle.

### Review → submission or talk

Required: resolved blocking findings, current disclosures and venue requirements,
and a verified outbound artifact. `$create-talk` derives its narrative and
notation from the approved manuscript and its numbers from verified analysis
outputs; submission workflows do not inherit permission to upload or contact a
venue.

## Re-entry and change control

An upstream change invalidates only the downstream artifacts in its blast
radius, but all such consumers must be rerun. A changed dataset or specification
can invalidate outputs, claims, manuscript prose, and slides. A reframed
manuscript may require a new strategy decision even when numbers do not change.
Preserve the prior record and state what supersedes it.

Do not automatically chain stages, commit intermediate work, or convert an
exploration into the main analysis. The user chooses stage transitions and
external actions.
