# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** Surfacing Data Value — What Makes Data Valuable to Hybrid Organizations under the
Economies of Worth Lens (A Q Methodology Study)
**Institution:** [YOUR INSTITUTION]
**Branch:** main

---

## Scope Discipline

**Do exactly what was asked — nothing adjacent.** Do not add README files, build scripts,
`.gitignore` edits, helper utilities, or extra tooling that was not requested. If an addition
looks valuable, **list it as a suggestion at the end** and let the user decide.

A request for a codebook is a request for a codebook. Delivering a codebook plus a README plus
build scripts plus gitignore edits means the user now has to review four things to accept one,
and the usual outcome is that all four get thrown away.

**Before adding anything not named in the request, ask.** One line is cheaper than a revert.

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- confirm rendered output and citation integrity at the end of every task
- **Single source of truth** -- `Manuscript/paper.md` is the authoritative text; `Manuscript/original_draft/` holds the superseded `.docx` for reference only, never edited
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md)

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, and session logs are in [quality_reports/](quality_reports/).

**How we verify** — the references and rules that carry the verification discipline:

- [`verification-ladder.md`](.claude/references/verification-ladder.md) — the seven rungs, from *qualify the checker* to the external oracle, and how the review loop converges.
- [`external-oracle-process.md`](.claude/references/external-oracle-process.md) — running an independent frontier-model referee (Claude Code → GPT-5.6 Sol Pro) and adjudicating what it returns.
- [`provenance-and-ground-truth.md`](.claude/references/provenance-and-ground-truth.md) — naming and pinning your oracles, classifying divergence, and the clean-room boundary.
- [`review-fencing.md`](.claude/rules/review-fencing.md) — reviewer independence is a property of the environment, not an instruction: a neutral copy outside the checkout, prior verdicts withheld, and the answer keys the repo already commits fenced off.
- [`release-engineering.md`](.claude/references/release-engineering.md) — shipping research software: message and silent-resolution censuses, frozen feature matrices for ports, hash-claimed inherited tests, and downstream consumers pinned by commit SHA.

**How we write** — [`writing-with-ai.md`](.claude/rules/writing-with-ai.md): internal vs external-facing documents, why a model cannot make its own output stop reading as model output, and the human-readable standard for anything with your name on it.

**Theory work** — [`theory-proving.md`](.claude/references/theory-proving.md): proof contracts, portfolio search with isolated explorers, counterexample-hunting your own lemmas, adversarial audits, and the rule that an AI-generated proof is a claim, not a theorem.

**The laws** — [`research-agent-laws.md`](.claude/references/research-agent-laws.md): 21 laws for running agents on research infrastructure, each paid for by a real incident.

**How we remember** — the record lives in the repo, not the transcript:

- [`progress-reports.md`](.claude/rules/progress-reports.md) — GitHub issues as defect memory, `quality_reports/` as work memory, `MEMORY.md` as lesson memory.
- [`issue-ledger.md`](.claude/rules/issue-ledger.md) — the evidence standard an issue must meet, and the seven-section closure comment.
- [`repo-hygiene.md`](.claude/rules/repo-hygiene.md) — **scratch must not become main.** Enforced by `check-repo-hygiene.py` on every commit.

Nothing clears work until it has a row in [`quality_reports/qualification/LEDGER.md`](quality_reports/qualification/LEDGER.md) — run [`/vaccinate`](.claude/skills/vaccinate/SKILL.md) to put one there.

**A note on method scope (see [`meta-governance.md`](.claude/rules/meta-governance.md)):** the
owner's veto on unvetted prescriptive guidance is scoped to **causal identification methods**
(difference-in-differences, regression discontinuity, synthetic control, instrumental
variables, event studies, matching-as-identification). **Q methodology is not in that scope** —
it is a technique for surfacing structured subjectivity (viewpoints on value), not for causal
identification — so the domain reviewer and skills in this repo give real, current
methodological guidance on Q-methodology design rather than declining to judge it.

---

## Folder Structure

```
data-value-paper/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography (pandoc/BibTeX citekeys)
├── Manuscript/
│   ├── paper.md                 # SINGLE SOURCE OF TRUTH — the manuscript
│   └── original_draft/          # Superseded .docx, kept for reference (never edited)
├── Figures/                     # Figures (e.g., Q-sort factor loadings, once produced)
├── scripts/R/                   # Dormant — reserved for the eventual by-person factor
│                                 #   analysis on Q-sort data (not econometrics)
├── quality_reports/             # Plans, session logs, reviews, decision records
├── explorations/                # Research sandbox (see rules) — e.g., draft Q-set statements
├── templates/                   # Session log, plan, requirements-spec templates
└── master_supporting_docs/      # Source PDFs of literature cited/reviewed
    └── supporting_papers/
```

---

## Commands

```bash
# Quality gate suite (repo hygiene, surface-sync, staleness, ledger coverage, hook battery, etc.)
# Run this after ANY change. Also runs in pre-commit once ./scripts/install-hooks.sh has been run.
./scripts/backtest.sh
```

There is currently no compile/render step — the manuscript is plain Markdown, and no
manuscript-specific entry in `quality_score.py` exists yet (see "Proposed further
customizations" in `quality_reports/plans/2026-09-02_workflow-setup-and-abstract-conversion.md`
for why that's deferred rather than guessed at). Once Q-sort data collection begins,
`scripts/R/` will hold the by-person factor-analysis pipeline and its own run commands will be
documented here.

---

## Quality Thresholds (advisory)

| Score | Checkpoint | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

Enforced by `/commit` (halts + asks for override) **and** — once you run `./scripts/install-hooks.sh` — by a real git pre-commit hook (`.githooks/pre-commit`) that runs the full backtest gate suite plus the quality (≥80) gate on every commit. Bypass sparingly with `SKIP_QUALITY_GATE=1` or `--no-verify`.

---

## Skills Quick Reference

The full table of all skills lives in [README.md](README.md#skills-claudeskills). Most-used, by workflow, for a single-manuscript paper project:

- **Writing / ideation:** `/interview-me` `/research-ideation` `/lit-review`
- **Review:** `/review-paper` (`--peer`, `--adversarial`) `/seven-pass-review` `/respond-to-referees` `/verify-claims` `/proofread` `/humanize`
- **Submission prep:** `/submission-disclosures` `/preregister` `/data-management-plan` `/coauthor-brief`
- **Verification / rigor:** `/vaccinate` `/challenge` `/oracle-review` `/adjudicate-review` `/credible-claims` `/deep-audit`
- **Meta / workflow:** `/commit` `/learn` `/new-skill` `/checkpoint` `/context-status` `/triage-inbox`

Other skills (slide/LaTeX/Quarto workflow, R/Stata replication, simulation studies) remain on
disk and available but aren't relevant to this project's current phase — see the "Proposed
further customizations" note in the setup plan if you want them pruned.

---

## Key Terminology & Notation Conventions

The paper leans on precise technical vocabulary from two literatures. Keep usage consistent —
this table replaces the slide-template's Beamer/Quarto formatting tables with the drift-prone
terms that actually matter here.

| Term | Meaning | Convention |
| --- | --- | --- |
| Order of worth | One of Boltanski & Thévenot's shared, mutually irreducible value systems (market, industrial, civic, domestic, inspired, fame, green, project) | Lowercase in running prose: "the market order," "the civic order" |
| Investments of form | Durable, standardized proof devices (prices, statistics, certifications) that make a worth claim defensible (Thévenot, 1984) | Always "investments of form" — do not shorten to "form" alone |
| Compromise vs. prioritization | Two distinct ways EoW disputes resolve: compromise treats an object as satisfying several orders at once; prioritization ranks one order above the others | Keep the two terms distinct — do not use "compromise" loosely |
| Concourse | The full universe of statements/viewpoints on data value, from which the Q-set is sampled | Q-methodology term of art |
| Q-set | The ~40 statements sampled from the concourse for sorting | |
| P-set | The ~30 participants who complete the Q-sort | |
| Q-sort | One participant's forced ranking of the Q-set against the fixed-distribution grid | |
| Value creation / value capture | Bowman & Ambrosini's (2000) dyad: enlarging total value available vs. determining who gets what share of it | Keep hyphenated, lowercase |

---

## Current Project State

| Artifact | File | Status | Content |
| --- | --- | --- | --- |
| The paper | `Manuscript/paper.md` | Draft — §3a "The Data Value Literature" is WIP and needs a substantive rewrite | Introduction, Research Gap, Conceptual Background (Data Value Literature / Economies of Worth / Value Creation & Capture), Methodology (Q methodology design), Expected Results, Future Research |
