---
name: grant-proposal
description: "Scaffold a research grant proposal (NSF, NIH, ERC, or foundation) by composing existing primitives — pulls identification strategy from an `$interview-me` spec, delegates the data-management plan to `$data-management-plan` and the facilities statement to `$capture-environment`, and emits a funder-requirements checklist. Use when user says \"draft a grant\", \"write a proposal\", \"NSF proposal\", \"NIH aims\", \"ERC application\", \"foundation grant\", \"specific aims\", or \"scaffold a grant proposal\". NOT a submission tool — produces a draft the user uploads to the sponsor's portal themselves."
---



# $grant-proposal — Research Grant Proposal Scaffolder

Compose a funder-shaped grant proposal draft from primitives you already have: an `$interview-me` research spec supplies the science, `$data-management-plan` supplies the DMP, `$capture-environment` supplies the facilities/computational statement, and `$lit-review` supplies the prior-work framing. This skill structures and stitches — it does **not** submit anywhere, and it does not invent identification strategy where a spec is absent.

**Core principle:** A proposal is a *coherence* artifact. Aims, methods, budget, timeline, and broader impacts must agree with each other and with the underlying research spec. The skill's main value-add over a blank template is the Phase 3 coherence pass (aims ↔ methods ↔ budget ↔ timeline).

## When to use

- Drafting an NSF / NIH / ERC / foundation proposal from an existing research idea.
- Turning an `$interview-me` spec (or a `$preregister` PAP) into a fundable narrative.
- Assembling the boilerplate-but-required pieces (DMP, facilities, data-sharing) so the human writes only the science.
- During resubmission, re-scaffolding aims after a reviewer "revise and resubmit" round.

## When NOT to use

- You need the *science itself* invented — run `$interview-me` first; this skill refuses to fabricate an identification strategy.
- The sponsor is a clinical-trial funder requiring its own protocol template (out of scope; use the sponsor's native forms).
- You want a finished, submittable PDF — this writes Markdown sections + a checklist; final assembly into the sponsor's format is yours.

## Funder profiles

Generic across sponsors via placeholder profiles. `--funder` selects the section set + naming; default is `nsf`.

| Funder | Core sections (named per sponsor) | Page/format signals |
|---|---|---|
| **`nsf`** | Project Summary (Overview/Intellectual Merit/Broader Impacts) · Project Description · Broader Impacts · Data Management & Sharing Plan · Facilities/Equipment · Budget Justification | 15-page Project Description; DMSP required |
| **`nih`** | Specific Aims (1 p.) · Research Strategy (Significance/Innovation/Approach) · Vertebrate/Human Subjects (if any) · Data Management & Sharing · Facilities & Other Resources · Budget Justification | Aims page is load-bearing |
| **`erc`** | Extended Synopsis (B1) · Scientific Proposal (B2: state-of-art, objectives, methodology) · CV + track record · Resources/Budget · Data Management | PI-centric; "high-risk/high-gain" framing |
| **`foundation`** | Project Summary · Statement of Need · Goals & Objectives · Methods/Approach · Evaluation Plan · Budget Justification · Sustainability | Mission-fit framing; lighter methods |

Economics framing is the primary lens (DiD/event-study, IV, RCT, panel; AEA Data Editor / openICPSR / DCAS data-sharing expectations), but the section scaffold is field-agnostic — a biology or CS forker fills the same slots.

## Workflow

### Phase 0 — Detect funder + spec

1. Resolve `--funder` (or infer from the request wording; default `nsf`). Echo the chosen profile back before drafting.
2. Locate the research spec: `--input <path>`, else the most recent `quality_reports/specs/research_spec_*.md` from `$interview-me`. If none exists, **stop and recommend `$interview-me`** — do not invent the science.
3. From the spec, extract: research question, hypotheses (directional), identification strategy (DiD / IV / RDD / RCT / structural), data sources, sample, expected results, contribution. Record any `paper_type:` field.
4. Scan `quality_reports/` for adjacent artifacts to reuse: a `$lit-review` synthesis (prior work), a `$preregister` PAP (analysis plan), a `passport.yaml` or `$data-analysis` outputs (preliminary results).

### Phase 1 — Scaffold sections from templates + the spec

Generate the funder's section set. Map spec content into slots:

- **Specific Aims / Project Summary** — RQ + 2–3 numbered, directional aims drawn from the spec's hypotheses.
- **Background & Significance** — motivation + prior work; pull citations from the `$lit-review` synthesis if present (do not re-search unless asked).
- **Research Design & Methods** — lift the identification strategy verbatim from the spec (estimand, treatment/control, identifying assumption, robustness and placebo strategy, clustering). Name the estimator concretely (e.g. `fixest::feols`, `AER::ivreg`, Python `reghdfe`).
- **Preliminary Results** — summarize any existing `$data-analysis` / passport outputs; otherwise mark `[PRELIMINARY RESULTS: none yet — describe planned pilot]`.
- **Timeline & Milestones** — quarter/year table aligned to the aims (every aim gets a milestone).
- **Broader Impacts / Significance** — sponsor-appropriate framing (NSF Broader Impacts vs NIH Significance vs foundation mission-fit).
- **Budget Justification skeleton** — personnel / data acquisition / compute / travel / dissemination line-item stubs, each tied to an aim.

For every MUST slot the spec did not supply, write `[CLARIFY: <specific question>]` — never fabricate. Re-use the MUST / SHOULD / MAY clarity language from [`templates/requirements-spec.md`](../../../templates/requirements-spec.md).

### Phase 2 — Compose the DMP and computational statements (delegate)

1. **Data Management (& Sharing) Plan** — invoke [`$data-management-plan`](../data-management-plan/SKILL.md) as a subagent with the funder + data sources from the spec. It returns the DMP section (repository choice — openICPSR / Dataverse / Zenodo, access/retention, FAIR/DCAS alignment). If any data source is sensitive (restricted-use admin data, PII, IRB-restricted), have it honor [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) and describe access via a secure enclave / FSRDC rather than open release. **Do not draft a sharing plan that promises to release confidential data.**
2. **Facilities / Computational-Environment statement** — invoke [`$capture-environment`](../capture-environment/SKILL.md) as a subagent to produce the compute/software/dependency statement (cluster, R/Python toolchain, `renv.lock` / `DESCRIPTION` / `requirements.txt` provenance) for the Facilities section.

If a delegate skill is unavailable, leave a `[DELEGATE: $data-management-plan]` placeholder rather than half-writing its output.

### Phase 3 — Coherence pass (aims ↔ methods ↔ budget ↔ timeline)

The differentiating step. Cross-check the assembled draft and report mismatches:

- **Aims ↔ Methods** — every aim has a named method/estimator; no orphan method serves no aim.
- **Methods ↔ Budget** — each cost line traces to an aim (e.g. an RCT aim implies a participant-incentives line; admin data implies an acquisition/enclave line; a large simulation implies a compute line).
- **Aims ↔ Timeline** — every aim has at least one milestone; no milestone is unattributed.
- **DMP ↔ Methods** — the data named in Methods matches the data described in the DMP; confidential sources are not promised as open.
- **Page/format budget** — flag sections likely to overflow the funder's page limit (NSF 15-page Project Description, NIH 1-page Aims).

### Phase 4 — Post-flight verification + output

- **Post-flight (CoVe):** if Background/Significance cites prior literature, run the Post-Flight protocol from [`.codex/guidance/post-flight-verification.md`](../../../.codex/guidance/post-flight-verification.md) — spawn `claim-verifier` as a subagent (`context: fork`) on the citations. Surface PASS / PARTIAL / FAIL. Skip on `--no-verify` or zero citations.
- **Write** sections to `--out` (default `quality_reports/grants/YYYY-MM-DD_<slug>/`), one Markdown file per section plus `checklist.md`.

## Output / Report format

A `proposal_draft.md` (concatenated sections) plus a `checklist.md`:

```markdown
# Grant Proposal Draft — [Title]
**Funder:** NSF | NIH | ERC | foundation     **Date:** YYYY-MM-DD
**Source spec:** quality_reports/specs/research_spec_<slug>.md

## Funder-Requirements Checklist
| Requirement | Status | Source |
|---|---|---|
| Project Summary / Specific Aims | DRAFTED | Phase 1 |
| Research Design & Methods | DRAFTED | spec |
| Data Management & Sharing Plan | DELEGATED | $data-management-plan |
| Facilities / Computational Env | DELEGATED | $capture-environment |
| Budget Justification | SKELETON | Phase 1 |
| Broader Impacts / Significance | DRAFTED | Phase 1 |
| [n] [CLARIFY:] items unresolved | TODO | — |

## Coherence Report
- Aims ↔ Methods: PASS / [n issues]
- Methods ↔ Budget: PASS / [n issues]
- Aims ↔ Timeline: PASS / [n issues]
- DMP ↔ Methods (confidential-data check): PASS / [n issues]
- Page-budget flags: [sections at risk of overflow]

## Post-Flight Verification
Claims extracted: N · Verified: N · Outcome: PASS / PARTIAL / FAIL
```

## Exit behavior

- **All MUST slots filled + coherence PASS:** report "DRAFT READY — review [CLARIFY:] items, then assemble in the sponsor's portal."
- **Open [CLARIFY:] / [DELEGATE:] items or coherence issues:** report "INCOMPLETE — N items unresolved" and list them. The skill never blocks like `$audit-reproducibility` (it is a drafting tool, not a gate) — it surfaces, the author resolves.
- **No research spec found:** stop in Phase 0 and recommend `$interview-me`. Nothing is written.

## Flags

- `--funder` `<nsf|nih|erc|foundation>` — Select the funder profile that shapes section structure and the requirements checklist.
- `--input` `<spec>` — Path to an existing `$interview-me` research spec to seed Aims and Methods (otherwise the skill elicits them).

## Cross-references

- [`.agents/skills/interview-me/SKILL.md`](../interview-me/SKILL.md) — produces the research spec this skill consumes; run it first if none exists.
- [`.agents/skills/data-management-plan/SKILL.md`](../data-management-plan/SKILL.md) — Phase 2 delegate for the DMP/DMSP section.
- [`.agents/skills/capture-environment/SKILL.md`](../capture-environment/SKILL.md) — Phase 2 delegate for the facilities/computational statement.
- [`.agents/skills/lit-review/SKILL.md`](../lit-review/SKILL.md) — supplies Background & Significance prior-work framing.
- [`.agents/skills/preregister/SKILL.md`](../preregister/SKILL.md) — a PAP can seed the analysis plan; preregistration is the forward commitment a funded project then executes.
- [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) — governs how sensitive data sources appear in the DMP and budget.
- [`.codex/guidance/post-flight-verification.md`](../../../.codex/guidance/post-flight-verification.md) — Phase 4 citation fact-check.

## What this skill does NOT do

- **Submit anywhere.** It writes Markdown + a checklist; you assemble and upload to Research.gov / ASSIST / the ERC portal / the foundation's system.
- **Invent the science.** No spec → no proposal. It will not fabricate an identification strategy, hypotheses, or aims.
- **Write the DMP or facilities statement itself.** Those are delegated to `$data-management-plan` and `$capture-environment`; this skill only stitches their output into the funder's section set.
- **Compute the budget.** It scaffolds line items tied to aims; actual dollar figures, indirect-cost rates, and effort percentages are the PI's and the grants office's job.
- **Guarantee page-limit compliance.** It flags likely overflow; final trimming to the sponsor's exact format is manual.

