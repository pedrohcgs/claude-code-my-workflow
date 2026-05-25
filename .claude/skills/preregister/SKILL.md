---
name: preregister
description: Draft a structured preregistration document (OSF, AsPredicted, or AEA RCT Registry style) from a research spec or free-form study description. Output is a Markdown file with hypotheses, design, sampling plan, analysis plan, exclusions, and inference criteria — annotated with MUST / SHOULD / MAY clarity flags. Use when user says "preregister", "draft a preregistration", "OSF preregistration", "AsPredicted", "AEA RCT registry", "PAP", "preanalysis plan", or before launching an experiment / data collection / analysis on data the analyst has not yet seen. NOT a registry submission tool — produces a document the user uploads to OSF / AsPredicted / AEA themselves.
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[--style osf|aspredicted|aea-rct] [--input <spec-or-description>] [--no-verify]"
disable-model-invocation: true
allowed-tools: ["Read", "Write", "Task"]
---

# /preregister — Preregistration Document Generator

Produce a registry-ready preregistration document. The user uploads it to a real registry (OSF / AsPredicted / AEA RCT Registry) — this skill writes the prose and structure, it does not submit anywhere.

## Why preregister

Preregistration is a written commitment to your hypotheses, design, and analysis plan **before** you see the data (or, for observational analyses, before you analyse the realised outcome). It separates confirmatory tests from exploratory tests and protects you from p-hacking, HARKing, and forking-paths. Different fields use different registries:

- **Political science**, **psychology**, broad social science → **OSF** (osf.io/registries) is the default. AsPredicted (aspredicted.org) is a popular short form for experiments.
- **Economics field experiments** → **AEA RCT Registry** (socialscienceregistry.org) is mandatory for AEA journal submission since 2018.
- **Public health / clinical trials** → ClinicalTrials.gov or ISRCTN (NOT covered by this skill — use the trial-registry's own template).

## When to use

- Before launching an experiment (lab, field, or survey).
- Before collecting observational data on a target population for a specific RQ.
- Before analysing data you have access to but haven't yet examined for the focal hypothesis.
- During R&R when a referee asks for a written preanalysis plan.

## When NOT to use

- After you've seen the realised outcomes and want to "preregister retrospectively" — that is not preregistration. The skill will refuse if the input description includes results.
- For exploratory analyses — those don't need preregistration; they need transparent labelling.
- For meta-analyses — use PROSPERO directly, not this template.

## Workflow

### PHASE 1 — Read inputs

Two input modes:

1. **`--input <path>`** — a research spec produced by `/interview-me` (saved under `quality_reports/specs/`) or any structured Markdown file. Read the spec and extract: research question, hypotheses (directional!), data source, design, sample, analysis approach. If the spec already has a `paper_type:` field (e.g., `survey-experiment`), use it to bias the style choice.
2. **No `--input`** — prompt the user for a 1–3 paragraph description of the study, then proceed. If the description omits a directional hypothesis, ask once. Do not fabricate.

Refusal conditions (must be checked before any drafting):

- Description contains realised results ("we found", "the estimate is", "p =") → refuse with: "Preregistration is forward-looking; this description includes results. Did you mean `/respond-to-referees` or to write a methods section?"
- Description has no testable hypothesis at all (pure exploratory framing) → flag and ask whether the user wants the *exploratory analysis* version of the OSF template (still useful, but not a registered confirmatory test).

### PHASE 2 — Pick the style

Default per field (used when `--style` is not given):

| Field signal | Default style |
|---|---|
| `paper_type: survey-experiment` or political-science / psychology context | `osf` |
| Field experiment in econ / labelled "RCT" / IRB-approved randomised intervention | `aea-rct` |
| 9-question quick-form ask, lab psych experiment, time-pressure | `aspredicted` |
| Anything else | `osf` |

User can override with `--style osf|aspredicted|aea-rct`.

### PHASE 3 — Generate the document

Read `templates/preregistration-template.md`. The template has three style sections; **only use the section matching the chosen style** (don't merge — registries differ).

Common to all styles, the document MUST include:

- Title and authors.
- Date and version.
- Pointer back to the source spec (if `--input` was given) so traceability survives.

Style-specific sections:

- **`osf`** — Hypotheses (directional, numbered) · Design · Sampling Plan · Variables · Analysis Plan · Inference Criteria · Data Exclusions · Missing Data Handling · Exploratory Analyses (clearly labelled as such) · Other.
- **`aspredicted`** — 9 numbered fields per the AsPredicted form: (1) data collection status, (2) hypothesis, (3) key dependent variable, (4) conditions, (5) analyses, (6) outliers/exclusions, (7) sample size + stopping rule, (8) anything else, (9) name (study not paper).
- **`aea-rct`** — Intervention · Outcomes (primary, secondary) · Primary hypotheses · Sample (target N, eligibility, randomization unit, randomization method) · IRB approval · Trial dates · Power calc · Pre-analysis plan attachment · Status (not yet on the air / ongoing / completed).

Annotate each section with one of:

- **MUST** — registry requires this; the document cannot be submitted without it.
- **SHOULD** — strongly recommended; reviewers expect it.
- **MAY** — optional; include if relevant.

Re-use the MUST/SHOULD/MAY framework from `templates/requirements-spec.md`. For each MUST that the input did not supply, write `[CLARIFY: <specific question>]` rather than fabricating content.

### PHASE 4 — Cross-checks (before writing to disk)

Refuse to mark the document "ready" if any of these fails:

- **Hypothesis directionality.** Each hypothesis must contain a direction ("higher than", "increases", "negatively predicts", "no effect" is acceptable as a directional claim under equivalence-testing). Reject "is associated with" without a sign.
- **Estimator named.** Analysis plan names a specific estimator (OLS, logit, fixest::feols, lme4::lmer, ATT difference-in-means …) and a primary outcome variable. "Regression" alone is insufficient.
- **Sample plan numeric.** Target N, stopping rule, or power-calc target appear. "As many as possible" is not a sample plan.
- **Exclusions ex ante.** Outlier and exclusion rules are stated *before* the data is seen ("we will exclude observations with completion time < 1 minute"). Vague "we'll deal with outliers" fails.
- **Internal consistency.** If the design is randomised, the unit of randomisation matches the unit of analysis OR the analysis plan addresses clustering. If observational, identification strategy is stated.

For each failure, the document gets a `[CLARIFY: …]` placeholder; the document is written to disk but flagged in the output summary as "INCOMPLETE — N MUST items unresolved".

### PHASE 5 — Post-flight verification

If the document cites prior literature in the rationale section (e.g., "Building on Hainmueller et al. 2014, we expect …"), invoke `/verify-claims` via `Task` to fact-check those citations. Pass the draft path and a list of explicit citations. The `claim-verifier` agent (forked context, never sees the draft) returns PASS / PARTIAL / FAIL per citation. Surface any FAIL/PARTIAL in the output summary.

Skip post-flight if:

- No prior-literature citations in the document.
- User passes `--no-verify` (flag inherited from `/lit-review` and `/research-ideation` post-flight).

### PHASE 6 — Output

Write to `quality_reports/preregistrations/YYYY-MM-DD_<slug>.md` (gitignored — preregistration is meant to be timestamped and uploaded externally, not committed alongside code).

Print to chat:

```
✓ Preregistration draft saved: quality_reports/preregistrations/<file>.md
  Style: <osf|aspredicted|aea-rct>
  Sections: <count> total — <complete> complete, <clarify> with [CLARIFY:] placeholders
  Citations verified: <PASS>/<PARTIAL>/<FAIL>  (or "no citations to verify")
  Next: review the [CLARIFY:] placeholders, fill in, then upload to <registry-url>
```

Include the registry URL: OSF → `osf.io/registries`, AsPredicted → `aspredicted.org`, AEA RCT → `socialscienceregistry.org`.

## Cross-references

- `templates/preregistration-template.md` — the three style templates this skill consumes.
- `templates/requirements-spec.md` — MUST/SHOULD/MAY annotation language re-used here.
- `.claude/skills/interview-me/SKILL.md` — produces the spec this skill consumes via `--input`.
- `.claude/skills/verify-claims/SKILL.md` — Phase 5 invokes this for citation post-flight.
- `.claude/references/discipline-cards.md` — field defaults that drive `--style` selection.
- `.claude/rules/replication-protocol.md` — preregistration is the *forward* commitment; replication-protocol is the *backward* contract.

## Examples

### Example 1 — Poli-sci survey experiment from a spec
**User says:** "Preregister this study" (with `--input quality_reports/specs/2026-04-15_priming-effects.md`)
**Actions:**
1. Read spec; `paper_type: survey-experiment` → default style `osf`.
2. Extract 2 directional hypotheses, MTurk N=1,200, OLS with treatment dummies.
3. Generate OSF document, all MUST sections filled, 1 MAY left blank.
4. No prior-lit citations beyond the spec — skip post-flight.
**Result:** Saved to `quality_reports/preregistrations/2026-04-15_priming-effects.md`. User uploads to OSF.

### Example 2 — Econ field experiment, AEA RCT Registry
**User says:** "Draft an AEA RCT preregistration for the cash-transfer pilot" (with `--style aea-rct --input quality_reports/specs/2026-03-10_ct-pilot.md`)
**Actions:**
1. Read spec; randomization unit = village, primary outcome = consumption.
2. Generate AEA RCT fields. IRB number missing in spec → `[CLARIFY: IRB approval number]`.
3. Cross-check: estimator (cluster-robust OLS), primary outcome stated, exclusion rule (intent-to-treat) stated. Pass.
4. No prior-lit cites — skip post-flight.
**Result:** Document written. Output summary flags 1 [CLARIFY:] item to fill before AEA submission.

### Example 3 — Free-form description, AsPredicted short form
**User says:** "Preregister my next priming experiment, AsPredicted style" (no `--input`)
**Actions:**
1. Prompt for the 1–3 paragraph description.
2. User supplies a paragraph; hypothesis lacks direction → ask once: "Direction?"
3. User clarifies; populate the 9 AsPredicted fields.
4. Sample-size stopping rule omitted → `[CLARIFY: target N or stopping rule]`.
**Result:** Short form written; one MUST [CLARIFY:] flagged; user told to fill before pasting into AsPredicted.

## Troubleshooting

**"Description contains results"** — by design. Move results into a methods + results write-up; preregistration is forward-looking.

**Citation post-flight fails with FAIL** — `claim-verifier` could not find a cited paper in WebSearch / corpus. Either the citation is real but the verifier missed it (common with very recent / paywalled work — cite explicitly with URL), or the citation is hallucinated. Inspect manually before upload.

**Different registries asking for different things** — use the registry's own template if this skill's mapping is too coarse. The three styles cover ~90% of social-science preregistrations; edge cases (PROSPERO, ClinicalTrials.gov, ISRCTN) need the registry's native form.

**Output dir doesn't exist** — `quality_reports/preregistrations/.gitkeep` should exist on a fresh fork; if missing, the skill will create the directory before writing.
