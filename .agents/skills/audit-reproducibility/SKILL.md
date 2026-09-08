---
name: audit-reproducibility
description: Cross-check numeric claims in a manuscript and its other declared displays against actual R or Python outputs, using documented tolerances and source provenance. Use before submission or releasing a replication package.
---

# Audit reproducibility

Read `.codex/guidance/replication-protocol.md` when present. Require a manuscript, a nonempty output location, and enough provenance to connect claims to generated results. If outputs are stale or missing, stop and identify the pipeline command that must be rerun.

Extract reported estimates, uncertainty, p-values, counts, percentages, and table or figure values. Match each claim to its R or Python output using stable identifiers, labels, source maps, or direct generated includes—not numeric proximity alone. Also compare every declared display of the same claim across manuscript, supplement, and research presentation.

For each claim report its location, source, reported value, generated value, absolute and relative difference, tolerance, and disposition: PASS, FAIL, EXPLAINED, or UNRESOLVED. A defensible alternative must be concrete and recorded; never widen a tolerance after seeing a mismatch.

Save machine-readable claim records and a human report under `quality_reports/` when the user requests artifacts. Rebuild and recheck after confirmed fixes. Do not call the project reproducible when unmatched or gating claims remain.

