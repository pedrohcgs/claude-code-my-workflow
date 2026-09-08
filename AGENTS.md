# AGENTS.md -- Academic Project Development with Codex

<!-- HOW TO USE: Replace [BRACKETED PLACEHOLDERS] with your project info.
     Customize the Beamer environments and current-project table below.
     Keep this root file concise because Codex loads it every session; route
     detailed procedures to .codex/guidance/ and .codex/references/. -->

**Project:** [YOUR PROJECT NAME]  
**Institution:** [YOUR INSTITUTION]  
**Field:** [YOUR FIELD OR SUBFIELD]  
**Primary paper type:** [REDUCED-FORM / STRUCTURAL / THEORY + EMPIRICS / DESCRIPTIVE / OTHER]  
**Target journal/audience:** [TARGET OR UNDECIDED]  
**Preferred talk engine:** Beamer [OR QUARTO REVEALJS]  
**Branch:** main

This repository supports both Codex and Claude Code. Codex configuration lives in
`.codex/` and `.agents/`; preserve `.claude/` and `CLAUDE.md` as the original
Claude runtime rather than rewriting them during Codex work.

---

## Scope Discipline

**Do exactly what was asked—nothing adjacent.** Treat extra improvements as
suggestions. Before adding an unrequested README, helper, build script, ignore
rule, deployment step, or other artifact, ask the user.

Inspect before editing, preserve user changes and generated artifacts, and use
`apply_patch` for reviewable edits. Never silently mutate `AGENTS.md`,
`.agents/skills/`, `.codex/`, or `.githooks/` through shell commands.

User instructions override skill defaults. A skill does not enlarge scope or
authorize external writes, messages, commits, pushes, or deployments. Invoke
`$commit` only when the user explicitly asks to commit or push.

---

## Core Principles

- **Plan first** — for non-trivial work, state the intended outcome and checks;
  save durable plans in `quality_reports/plans/` when the task warrants one.
- **Verify after** — run the affected pipeline and inspect the resulting artifact,
  not merely the command's exit code.
- **Single source of truth** — identify the authoritative source before editing;
  analysis outputs own numbers, the approved manuscript owns narrative scope and
  notation, and talks derive from both.
- **Quality gates** — nothing ships below the applicable repository threshold.
- **Claims need evidence** — treat AI-produced facts, citations, numbers, and
  proofs as claims until checked against a named source or executable oracle.
- **Independent review** — reviewer agents are read-only, receive only the
  artifact and rubric they need, and do not see earlier verdicts unless they are
  explicitly adjudicating them.
- **Durable memory** — record decisions in `quality_reports/` and corrections as
  `[LEARN:category] wrong → right` entries in `MEMORY.md`, not only in chat.

The verification system is documented in:

- `.codex/references/verification-ladder.md` — seven verification rungs.
- `.codex/references/provenance-and-ground-truth.md` — oracle and provenance rules.
- `.codex/guidance/review-fencing.md` — clean-room reviewer independence.
- `.codex/references/release-engineering.md` — safe research-software releases.
- `.codex/references/theory-proving.md` — proof contracts and counterexamples.
- `.codex/references/research-agent-laws.md` — the 21 research-agent laws.
- `.codex/guidance/writing-with-ai.md` — external-facing writing standards.
- `.codex/guidance/progress-reports.md` and `.codex/guidance/issue-ledger.md` —
  persistent work and defect memory.

Nothing is cleared by assertion alone. Qualification evidence belongs in
`quality_reports/qualification/LEDGER.md`; use `$vaccinate` to add it.

### Research product contract

- Use an approved `$strategize` memo as the contract for confirmatory analysis;
  label exploration and record deviations before interpreting new estimates.
- Do not draft empirical Results or Conclusions as observed findings until actual
  outputs exist and the relevant numbers have been verified.
- Research talks may not introduce claims absent from the approved manuscript or
  numbers that do not trace to analysis outputs.
- Project-specific field, data, notation, venue, and recurring-objection context
  belongs in `.codex/references/project-profile.md`.

---

## Folder Structure

```text
[YOUR-PROJECT]/
├── AGENTS.md                    # Always-loaded Codex instructions
├── .agents/skills/              # Native $skill workflows
├── .codex/                      # Config, agents, hooks, rules, and guidance
├── .claude/ and CLAUDE.md       # Original Claude runtime; preserve unchanged
├── Bibliography_base.bib        # Central bibliography
├── Figures/                     # Figures and images
├── Preambles/header.tex         # Shared LaTeX definitions
├── Slides/                      # Beamer or Quarto research presentations
├── scripts/                     # Validation utilities and R/Python analysis
├── quality_reports/             # Plans, reviews, logs, and qualification evidence
├── explorations/                # Research sandbox; never silently becomes main
├── templates/                   # Reusable research and workflow templates
└── master_supporting_docs/      # Papers and source materials
```

The Codex port supports R and Python analyses, manuscripts, replication packages,
LaTeX/Beamer research talks, optional Quarto RevealJS research talks, TikZ,
literature work, and seminar preparation. Quarto support does not extend to
lecture translation, Beamer synchronization, QA/deployment workflows, or course
sites. Stata workflows, course administration, lectures, pedagogy review,
assignments, syllabi, evaluations, and deployment remain excluded.

---

## Commands

```bash
# Beamer/LaTeX: three XeLaTeX passes; BibTeX after pass 1 when cited
cd Slides
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
if grep -q '\\citation' file.aux; then
  BIBINPUTS=..:$BIBINPUTS bibtex file
fi
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Optional Quarto RevealJS research talk
cd ..
quarto render Slides/file.qmd

# Validate the native installation or both runtimes
./scripts/validate-setup.sh --platform codex
./scripts/validate-setup.sh --platform all

# Full repository gate suite; run after every change
./scripts/backtest.sh
```

For analysis work, run the affected numbered R/Python pipeline and reconcile every
reported number with `$audit-reproducibility`. For Beamer presentations, use
`$compile-latex` and inspect the rendered PDF. For Quarto research talks, render
the `.qmd` and inspect every slide in the generated HTML at a fixed viewport.

---

## Quality Thresholds (Advisory)

| Score | Checkpoint | Meaning |
| ---: | --- | --- |
| 80 | Commit | Good enough to save |
| 90 | PR | Ready to share |
| 95 | Excellence | Aspirational |

After `./scripts/install-hooks.sh`, `.githooks/pre-commit` runs the backtest and
the quality threshold. Never bypass hooks or force-push by default, and never use
destructive Git commands or blanket staging.

---

## Skills Quick Reference

Invoke native workflows as `$skill-name`; use `/status`, `/statusline`, `/hooks`,
and `/skills` for Codex runtime controls.

- **Papers and writing:** `$draft-paper`, `$academic-writing`, `$review-paper`,
  `$seven-pass-review`, `$respond-to-referees`, `$verify-claims`, `$proofread`,
  `$humanize`, `$submission-disclosures`
- **Data and reproducibility:** `$data-analysis`, `$simulation-study`,
  `$audit-reproducibility`, `$diagnose`, `$replication-package`,
  `$capture-environment`, `$power-analysis`, `$disclosure-check`, `$review-r`
- **Research design:** `$strategize`, `$interview-me`, `$lit-review`, `$research-ideation`,
  `$preregister`, `$grant-proposal`, `$data-management-plan`
- **Research presentations:** `$create-talk`, `$present-paper`, `$compile-latex`,
  `$slide-excellence`, `$visual-audit`, `$extract-tikz`, `$new-diagram`,
  `$validate-bib`
- **Verification and rigor:** `$vaccinate`, `$challenge`, `$oracle-review`,
  `$adjudicate-review`, `$differential-audit`, `$blast-radius`,
  `$verify-artifact`, `$credible-claims`, `$deep-audit`
- **Workflow:** `$commit`, `$learn`, `$new-skill`, `$checkpoint`,
  `$compress-session`, `$promote-memory`, `$coauthor-brief`, `$triage-inbox`,
  `$permission-check`

See `README.md` and `.codex/WORKFLOW_QUICK_REF.md` for the complete inventory.

---

## Beamer Custom Environments

| Environment | Effect | Use case |
| --- | --- | --- |
| `[your-env]` | [Description] | [When to use] |
| `keybox` | Gold background box | Key points *(example—delete)* |
| `definitionbox[Title]` | Blue-bordered titled box | Definitions *(example—delete)* |

---

## Current Project State

| Artifact | Authoritative source | Derived output | Status |
| --- | --- | --- | --- |
| Paper | `[paper source]` | `[paper PDF]` | [Status] |
| Analysis | `[entry script]` | `[output directory]` | [Status] |
| Research talk | `[Slides/deck.tex or .qmd]` | `[Slides/deck.pdf or .html]` | [Status] |
| Replication package | `[package directory]` | `[archive/release]` | [Status] |

---

## Task-Specific Routing

Read only the guidance relevant to the task:

- Research integrity: `.codex/guidance/replication-protocol.md`
- Research lifecycle: `.codex/guidance/research-lifecycle.md`
- Paper review: `.codex/guidance/review-fencing.md`
- Manuscript drafting and displays: `.codex/guidance/manuscript-authoring.md`
- R/Python and simulation: `.codex/guidance/r-code-conventions.md`,
  `.codex/guidance/agent-authored-code.md`, `.codex/guidance/simulation-conventions.md`
- LaTeX, Beamer, and TikZ: `.codex/guidance/no-pause-beamer.md`,
  `.codex/guidance/tikz-prevention.md`, `.codex/guidance/tikz-visual-quality.md`
- Quarto research talks: `$create-talk`, then `$visual-audit` on the rendered HTML
- Plans and repository memory: `.codex/guidance/progress-reports.md`,
  `.codex/guidance/issue-ledger.md`, `.codex/guidance/repo-hygiene.md`
- Complete source-to-target inventory: `.codex/port-manifest.toml`

## Verification

Run the narrowest checks while developing, then finish with the Codex setup
validator and the full backtest. Report what ran, what passed, and anything that
could not be verified. Preserve numeric provenance from source data and code
through outputs and every paper, appendix, or presentation display.
