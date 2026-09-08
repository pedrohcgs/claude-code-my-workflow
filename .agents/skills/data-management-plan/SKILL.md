---
name: data-management-plan
description: "Draft a funder-compliant Data Management Plan (NSF DMP, NIH DMS Policy 2023, ERC, Horizon Europe) by composing the confidential-data and environment-capture primitives. Sections cover data description, formats/metadata, storage/backup, access/sharing, preservation/archiving, and roles. Use when user says \"data management plan\", \"DMP\", \"DMSP\", \"NIH data sharing plan\", \"write the data plan for my grant\", or when a grant proposal needs a data-management section. NOT a submission tool — produces a draft the user pastes into the funder portal (DMPTool, NIH ASSIST, Horizon Europe portal)."
---



# `$data-management-plan` — Funder-Compliant DMP Generator

Produce a Data Management Plan ready to paste into a funder portal. This skill writes the prose and structure; it does **not** submit anywhere. It is a **composition** skill — it folds the disclosure-avoidance / IRB rules from [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) and the environment + replication-package plan from `$capture-environment` and `$replication-package` into a single funder-shaped document.

## When to use

- **Writing a grant proposal.** Every NSF, NIH, ERC, and Horizon Europe proposal needs a DMP (NSF), DMS Plan (NIH 2023 policy), or Data Management Plan (ERC/Horizon). `$grant-proposal` calls this skill for that section.
- **Before data collection on a funded project.** The plan is a commitment you make at award time and report against at renewal.
- **When restricted or human-subjects data is involved.** The access/sharing and preservation sections change materially — see Phase 2.

## When NOT to use

- For a clinical-trial data-sharing statement governed by ICMJE / ClinicalTrials.gov — use the trial sponsor's template.
- As a substitute for IRB protocol text — the DMP *references* IRB constraints; it is not the protocol itself.

## Inputs

- `the first argument` `--funder nsf|nih|erc|horizon` — target funder profile. If omitted, Phase 0 detects it from `--input` or asks once.
- `--input <path>` — a research spec (`$interview-me` output under `quality_reports/specs/`), a grant draft, or a `passport`-adjacent description. The skill extracts data types, sample, and identification strategy from it.
- `--no-verify` — skip the Phase 4 citation/standard post-flight (inherited from `$preregister`).

## Workflow

### Phase 0 — Detect funder + data sensitivity

1. Resolve the funder (`--funder`, else infer from `--input`, else ask once). Load its section schema:

   | Funder | Plan name | Required sections (abridged) |
   |---|---|---|
   | **NSF** | Data Management Plan (2 pp max) | data types · standards · access/sharing · re-use/redistribution · archiving |
   | **NIH** | DMS Plan (2023 policy) | data type · tools/software · standards · preservation/access/timelines · access/distribution + reuse · oversight |
   | **ERC** | DMP (Horizon Europe Annex) | FAIR per dataset · data summary · making data FAIR · resource allocation · security · ethics |
   | **Horizon Europe** | DMP (DMP template) | same FAIR-first structure as ERC; open by default, "as open as possible, as closed as necessary" |

2. Classify the data on three axes (drives Phases 2–3):
   - **Public** (open survey, scraped public records, simulated) — minimal restrictions.
   - **Restricted** (admin/tax/Census, proprietary, licensed under DUA) — access procedures dominate.
   - **Human-subjects** (PII, biospecimen-linked, survey with identifiers) — IRB + disclosure avoidance dominate.

   If the data is restricted *or* human-subjects, set `sensitive = true` and run Phase 2. If it is purely public, Phase 2 is a short paragraph.

### Phase 1 — Scaffold sections from the funder profile

Generate the six house sections, mapped onto the funder's required headings:

1. **Data description & types** — what data, source, volume, formats produced. Be specific: panel/admin microdata, RCT outcomes, event-study event files, replication intermediate `.rds`/`.dta`/`.parquet`.
2. **Formats & metadata standards** — open/non-proprietary formats where possible (`.csv`/`.parquet` over `.dta`; codebooks; DDI / Dublin Core / domain schema). Name the standard, don't say "appropriate metadata".
3. **Storage & backup** — during the project: encrypted institutional storage, 3-2-1 backup, version control for code (not raw restricted data in git).
4. **Access & sharing** — who can access, when, under what terms. For restricted data this is the **restricted-data access procedure** (see Phase 2).
5. **Preservation & archiving** — a named repository with a persistent identifier (see Phase 3).
6. **Roles & responsibilities** — PI as data steward, data manager, institutional support, succession plan.

For any required field the input does not supply, write `[CLARIFY: <specific question>]` rather than fabricating — same convention as `$preregister`.

### Phase 2 — Fold in disclosure-avoidance + IRB constraints (only if `sensitive = true`)

Pull the relevant rules from [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) and weave them into the **access & sharing** and **preservation** sections:

- **Restricted data → describe the access path, not the data.** State the data provider, the DUA/restricted-use agreement, and how a replicator obtains access (e.g., FSRDC application, openICPSR restricted-access tier, provider application). The data itself is *not* deposited; the *path to it* is.
- **Human-subjects → IRB + minimization.** Reference the IRB protocol number (or `[CLARIFY:]`), the consent terms governing sharing, and the de-identification plan. Shared outputs are de-identified per the consent.
- **Disclosure avoidance for any released microdata or tables.** Name the technique: suppression of small cells (n < threshold), rounding, top-coding, noise infusion, or aggregation. For tabular output, state the minimum cell-count rule. Defer the actual pre-release scan to `$disclosure-check`, and say so in the plan ("released outputs pass `$disclosure-check` before deposit").

### Phase 3 — Fold in the computational-environment + replication-package plan

The DMP should commit to *reproducibility*, not just data deposit:

- **Environment capture.** State that the computational environment will be captured (R `sessionInfo()` / `renv.lock`, Python version plus `requirements.txt` / lockfile / container). Point to `$capture-environment` as the mechanism. AEA Data Editor / DCAS standards expect this.
- **Replication package.** Commit to depositing a replication package (code + non-restricted data + a master run script + README) in a trusted repository. Point to `$replication-package` as the builder.
- **Repository choice** — match the data class:
  - Economics / social science → **openICPSR** (AEA's home; DCAS-compliant) or **Harvard Dataverse**.
  - Restricted data → openICPSR *restricted-access* tier or the provider's enclave (FSRDC); deposit code + metadata, not the microdata.
  - Domain repos → field-specific (e.g., ICPSR proper, GenBank, Zenodo for code) where the funder or community expects them.
- State the **persistent identifier** (DOI) and the **timeline** (e.g., "at publication" or "within 12 months of project end" — NIH expects no later than publication or award end).

### Phase 4 — Post-flight (skip with `--no-verify`)

If the draft cites a funder policy or standard by name/number (e.g., "per NIH NOT-OD-21-013", "DCAS v1"), invoke `$verify-claims` as a subagent to confirm the policy citation resolves. Forked `claim-verifier` never sees the draft. Surface any FAIL/PARTIAL.

### Phase 5 — Output

Write the draft to `quality_reports/dmp/YYYY-MM-DD_<funder>_<slug>.md` and a funder checklist alongside it.

```
✓ DMP draft saved: quality_reports/dmp/<file>.md
  Funder: <nsf|nih|erc|horizon>   Data class: <public|restricted|human-subjects>
  Sections: <count> total — <complete> complete, <clarify> with [CLARIFY:] placeholders
  Disclosure/IRB folded in: <yes (Phase 2) | n/a — public data>
  Repository: <openICPSR | Dataverse | domain repo>   PID: <DOI planned | [CLARIFY:]>
  Policy citations verified: <PASS>/<PARTIAL>/<FAIL>  (or "none to verify")
  Next: resolve [CLARIFY:] items, then paste into <DMPTool | NIH ASSIST | Horizon portal>
```

The **funder checklist** is a table: each required section → present? → complete / `[CLARIFY:]`, so the user sees at a glance whether the plan will pass the funder's compliance check.

## Exit behavior

- **All required sections present, zero `[CLARIFY:]`** → "DMP READY", checklist all green.
- **Any required section unresolved** → "INCOMPLETE — N MUST items unresolved", listed in the checklist. The draft is still written (so the user can fill it in), but not marked ready.
- This skill **does not block** anything — it produces a document. The gate is the funder's, not ours.

## Cross-references

- [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) — restricted-data / IRB / disclosure-avoidance rules folded in at Phase 2.
- `.agents/skills/disclosure-check/SKILL.md` — pre-release disclosure scan the plan commits released outputs to.
- `.agents/skills/capture-environment/SKILL.md` — the environment-capture mechanism Phase 3 references.
- `.agents/skills/replication-package/SKILL.md` — the replication-package builder Phase 3 commits to.
- `.agents/skills/grant-proposal/SKILL.md` — calls this skill for the proposal's data-management section.
- [`.agents/skills/preregister/SKILL.md`](../preregister/SKILL.md) — sibling document-generator; shares the MUST/`[CLARIFY:]` + post-flight conventions.
- [`.codex/guidance/replication-protocol.md`](../../../.codex/guidance/replication-protocol.md) — the reproducibility contract the deposited package must satisfy.

## What this skill does NOT do

- **Submit the plan.** It writes a Markdown draft; the user pastes it into DMPTool / NIH ASSIST / the Horizon portal.
- **Run the disclosure scan or build the package.** It *commits* the project to `$disclosure-check`, `$capture-environment`, and `$replication-package`, and references them — it does not execute them.
- **Write the IRB protocol.** It references the protocol number and consent terms; the protocol is authored separately.
- **Choose a repository for you when the funder mandates one.** If NIH names a domain repository for your data type, that mandate wins over the defaults in Phase 3 — the skill flags it as `[CLARIFY:]` rather than guessing.

