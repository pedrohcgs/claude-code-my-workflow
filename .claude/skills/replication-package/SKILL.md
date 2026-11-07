---
name: replication-package
description: Assemble a submission-ready replication package to the AEA Data and Code Availability Standard (DCAS) / openICPSR / Social Science Reproduction Platform expectations — standard replication README, dataset manifest, computational-requirements capture, a Table/Figure → script:line map, and a confidential-data deposit plan. Use when user says "build the replication package", "prepare the openICPSR deposit", "make the AEA data and code package", "DCAS compliance", "assemble the deposit for the journal", or after a paper is accepted and the journal's data editor needs the package. NOT a numeric verifier — it calls /audit-reproducibility to confirm claims reproduce before packaging.
argument-hint: "[manuscript path] [outputs-dir] (outputs-dir defaults to output/)"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Agent", "Task"]
effort: high
---

# Replication Package

Produce the deposit an economist hands a journal at acceptance: a directory tree (`data/`, `code/`, `output/`, `README`) plus a DCAS compliance checklist, built to the [AEA Data and Code Availability Standard](https://datacodestandard.org/), openICPSR deposit expectations, and the [Social Science Reproduction Platform](https://www.socialsciencereproduction.org/) reproduction protocol. This skill **moves the repo from auditing reproducibility to producing the deposit** — `/audit-reproducibility` proves the numbers; this skill packages everything a third party needs to regenerate them from scratch.

**Core principle:** the package is reproducible by a stranger with the data and the README — no tacit knowledge, no "ask the author" steps. Every table and figure maps to the exact script and line that produces it.

## When to use

- **At acceptance.** The journal's data editor (AEA, REStud, JPE, EJ, ...) requests a DCAS-compliant deposit before the paper is typeset.
- **Before an openICPSR / Zenodo / Dataverse upload.** Build the tree and README once, locally, before the web upload.
- **Pre-submission dry run.** Catch the "I never wrote down where Table 3 comes from" gap while it is cheap to fix.
- **Confidential-data papers.** Produce the access-restricted-data note and a runnable-on-restricted-data package even when the data itself cannot be deposited.

## Inputs

- `$0` — path to the manuscript (`.tex`, `.qmd`, `.md`, `.pdf`). Required (the source of the Table/Figure inventory).
- `$1` — outputs directory. Defaults to `output/`, where every language's pipeline writes. Recognised alternative: `_targets/objects/`. If `output/` does not exist but a pre-v2.6 `scripts/<lang>/_outputs/` does, use that and say so.

## Workflow

### Phase 0: Pre-flight — detect language(s) and outputs

1. Detect the analysis language(s) by scanning for `scripts/R/*.R` (+ `renv.lock` / `DESCRIPTION`), `scripts/stata/*.do`, `scripts/python/*.py` (+ `requirements.txt` / `environment.yml` / `pyproject.toml`). A project may be **polyglot** — record all detected languages.
2. Locate the outputs directory (`$1`) and the one-command entry point (`00_run_all.R`, `99_run_all.do`, `run.py`, `Makefile`). If none exists, flag it — DCAS requires a single master script.
3. If `quality_reports/passports/<paper-slug>.yaml` exists, load it; its `claims:` entries are the authoritative Table/Figure → `source_file:source_line` map for Phase 1.

### Phase 1: Generate the standard replication README

Write `replication_package/README.md` (the AEA template, fields below). Leave a `[FILL]` marker on any field you cannot infer — never fabricate a data source or license.

- **Overview / paper citation** — title, authors, abstract one-liner.
- **Data Availability Statement** — for each dataset: public / restricted / proprietary, and whether it is redistributed in the package. This is the single most-rejected DCAS field; be explicit.
- **Dataset manifest** — a table, one row per file: `filename | description | source (URL/citation) | access (public / DUA / purchase) | license | provided in package? (Y/N)`. Start it from `python3 scripts/data-inventory.py data/raw --format md` (add `--header` once you have checked that each CSV's first row is a header), which lists each file's size, SHA-256, rows, column names, and the columns whose *names* suggest personal data, and never a value. Everything in it is still derived from the data. On restricted data the author runs it on the permitted machine, and the **whole** manifest (file names, sizes, row counts, column names) goes through the agreement's disclosure review (`/disclosure-check`) before it leaves that machine or reaches a model. `--no-counts` drops the row counts.
- **Computational requirements** — OS, software + versions (R / Stata / Python), key packages, approximate runtime, RAM, any HPC/cluster need.
- **AI-generated analytical outputs** (only if the analysis used a model to *produce data*, such as variables coded by an LLM, classified text, or extracted fields) — for each output: the exact model ID or snapshot and the date it ran, the prompts verbatim, the parameters, where the raw model output is kept, the post-processing applied, and who checked a sample and how. AI help with *writing code* is not an analytical output; it is disclosed under the journal's AI policy (`/submission-disclosures`). The distinction follows the World Bank's reproducibility guidance (`worldbank/wb-reproducible-research-repository`).
- **Step-by-step run instructions** — the single master-script invocation, then the expected outputs.
- **Table/Figure → script:line map** — one row per exhibit: `Exhibit | Program | Line | Output file`. Read from the passport if present; otherwise grep the manuscript for `\input{}` / `\includegraphics{}` and trace each to the producing script. This map is what a reproducer follows; it is the heart of the package.

### Phase 2: Capture the computational environment

Generate the dependency lockfile(s) and an environment snapshot for each detected language. Prefer [`/capture-environment`](../capture-environment/SKILL.md) if available; otherwise produce them directly:

- **R** — `renv::snapshot()` → `renv.lock`; `sessionInfo()` → `output/sessionInfo.txt`.
- **Python** — `pip freeze` → `requirements.txt` (or export the conda `environment.yml`); record `python --version`.
- **Stata** — `creturn list` / `about` / the `which` list → `output/sessionInfo_stata.txt`, the environment record the Stata convention requires; confirm every `.do` pins `version NN` (per [`stata-code-conventions.md`](../../rules/stata-code-conventions.md)).
- **Container (recommended by DCAS for non-trivial setups)** — scaffold a `Dockerfile` pinning the base image + language version.

### Phase 3: Confirm claims reproduce before packaging

Run [`/audit-reproducibility`](../audit-reproducibility/SKILL.md) `$0 $1` (passport-aware if the YAML exists).

- **Any FAIL** (out of tolerance, no named alternative) → **block**: do not assemble a package around numbers that do not reproduce. Surface the failing claims and stop.
- **EXPLAINED** (out of tolerance with a recorded named alternative) → allowed; carry the note into the README's known-discrepancies section.
- **All PASS / PASS + EXPLAINED** → proceed to Phase 4.

### Phase 4: Assemble the tree + DCAS checklist

Create the deposit skeleton (copy/symlink real files where they exist; leave `[FILL]` placeholders otherwise):

```
replication_package/
├── README.md                # Phase 1
├── data/
│   ├── raw/                 # as-obtained (or a pointer + DUA note if restricted)
│   └── analysis/            # constructed analysis files
├── code/                    # numbered scripts + master script (00_run_all.* / 99_run_all.do)
└── output/                  # tables/, figures/, logs/, sessionInfo.txt (R) / sessionInfo_stata.txt (Stata), renv.lock / requirements.txt
```

Then emit the **DCAS compliance checklist** (`replication_package/DCAS_checklist.md`): Data Availability Statement present · every dataset has source + access + license · master script present and one-command · computational requirements stated · every Table/Figure mapped to program:line · no absolute/machine-specific paths in code · seeds set for any stochastic step · license file (a code license such as BSD/MIT + a data-usage statement). Mark each PASS / FAIL / `[FILL]`.

### Phase 5: Confidential-data handling

Per [`.claude/rules/confidential-data.md`](../../rules/confidential-data.md), scan the manifest for restricted, proprietary, or PII-bearing inputs (administrative records, IRS/Census RDC, proprietary panels, linked health data).

- **Never copy restricted data into `replication_package/data/`.** Replace it with a pointer: the provider, the application/DUA process, the access cost, and the expected wait time.
- Generate `replication_package/data/access-restricted-data.md` — the access-restricted-data note a reproducer follows to obtain the same inputs.
- Confirm the **code still ships** (DCAS requires runnable-on-restricted-data code even when the data cannot be deposited), and that any committed extracts pass disclosure-avoidance (cell suppression / rounding) before they enter `output/`.

## Output / Report format

Write `quality_reports/replication_package_[paper-slug].md`:

```markdown
# Replication Package: [Paper Title]
**Date:** [YYYY-MM-DD]  **Languages:** [R / Stata / Python]  **Deposit target:** [openICPSR / Zenodo / Dataverse]

## DCAS checklist
| Item | Status |
|---|---|
| Data Availability Statement | PASS / FAIL / [FILL] |
| Dataset manifest (source · access · license) | ... |
| One-command master script | ... |
| Computational requirements | ... |
| Table/Figure → program:line map | ... |
| No machine-specific paths · seeds set | ... |
| Reproducibility audit (Phase 3) | PASS / EXPLAINED-only / FAIL (blocker) |
| Confidential-data note (if applicable) | ... |

## Skeleton built at
replication_package/  (tree + README + checklist)

## Open [FILL] items
[one line per unresolved field]
```

## Exit behavior

- **All checklist items PASS (or PASS + `[FILL]`) and audit PASS/EXPLAINED-only:** exit 0; print the tree location and any `[FILL]` items for the author to complete.
- **Any audit FAIL (Phase 3):** exit 1; package assembly halts. Numbers that do not reproduce do not get deposited.
- **Restricted data detected but no access note generated:** exit 1 with the confidential-data blocker — packaging cannot proceed until Phase 5 runs.

## Cross-references

- [`.claude/rules/replication-protocol.md`](../../rules/replication-protocol.md) — tolerance contract + passport schema (the upstream verification this skill packages).
- [`.claude/skills/audit-reproducibility/SKILL.md`](../audit-reproducibility/SKILL.md) — the Phase 3 gate; proves claims reproduce.
- [`.claude/rules/confidential-data.md`](../../rules/confidential-data.md) — restricted-data deposit rules driving Phase 5.
- [`templates/passport-template.yaml`](../../../templates/passport-template.yaml) — source of the Table/Figure → program:line map when present.
- [`.claude/skills/data-analysis/SKILL.md`](../data-analysis/SKILL.md) · [`.claude/skills/stata-replication/SKILL.md`](../stata-replication/SKILL.md) — the R / Stata pipelines whose outputs this skill packages.
- [`.claude/skills/simulation-study/SKILL.md`](../simulation-study/SKILL.md) — seeded Monte Carlo outputs are packaged the same way (seeds + per-rep raw results belong in `output/`).
- [`.claude/skills/preregister/SKILL.md`](../preregister/SKILL.md) — for RCTs, the PAP belongs in the deposit alongside the analysis.

## What this skill does NOT do

- **Verify the numbers.** That is `/audit-reproducibility` (called in Phase 3). This skill packages a *verified* result; it blocks rather than re-derives on FAIL.
- **Upload to the repository.** It builds the local tree and README; the author performs the openICPSR / Zenodo / Dataverse upload and gets the DOI. Web deposit is deliberately out of scope.
- **Judge the research.** Whether the identification strategy (DiD / event-study, IV, RCT, panel FE) is sound is a `/review-paper` question. A reproducible package can still house a flawed design.
- **De-identify your data.** It flags restricted inputs and refuses to deposit them; it does not run disclosure-avoidance algorithms on raw microdata — that is the author's (and the RDC's) responsibility.
