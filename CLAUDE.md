# CLAUDE.MD -- IPO Returns in the US and Europe

**Project:** IPO Returns in the United States and Europe (incl. the UK)
**Institution:** Humboldt-Universität zu Berlin — School of Business and Economics
**Author:** Joachim Gassen (solo)
**Branch:** main

Empirical study of initial-public-offering returns for issuers in the U.S. and
Europe/UK, using **WRDS** data plus Jay Ritter's public IPO data. Deliverables:
(1) a **Quarto `.qmd` → Beamer PDF** slide deck of key findings, and
(2) a **short descriptive note/paper** documenting data sources, situating the
work in the literature, and reporting the findings.

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- render to PDF and confirm output at the end of every task
- **Single source of truth** -- the Quarto `.qmd` is authoritative; the Beamer PDF derives from it (`quarto render --to beamer`). See [`.claude/rules/single-source-of-truth.md`](.claude/rules/single-source-of-truth.md)
- **Licensed data stays out of git** -- WRDS extracts are never committed; commit code + derived aggregates only. See [`.claude/rules/confidential-data.md`](.claude/rules/confidential-data.md)
- **Quality gates** -- nothing ships below 90/100 (stricter than template default)
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md)

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

```
claude_code_pground/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography (IPO literature)
├── Figures/                     # Figures (PDF, for Beamer)
├── Preambles/header.tex         # Beamer preamble = single styling source (xelatex)
├── Quarto/                      # .qmd deck source → renders to Beamer PDF
├── paper/                       # Descriptive note (.qmd → PDF)
├── scripts/                     # Utility scripts + R code (WRDS pipeline)
├── data/                        # Local data (raw WRDS pulls gitignored)
├── quality_reports/             # Plans, session logs, merge reports, decision records
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Reference papers
```

`Slides/` and `docs/` (GitHub Pages) are unused in this project — the deck is a
`.qmd` rendered to PDF, not a hand-authored `.tex` or a hosted HTML site.

---

## Commands

```bash
# Render the deck: Quarto .qmd → Beamer PDF (uses Preambles/header.tex, xelatex)
quarto render Quarto/<deck>.qmd --to beamer
quarto render paper/<note>.qmd            # descriptive note → PDF

# Reproducible analysis pipeline (WRDS + Ritter data)
Rscript scripts/R/00_run_all.R

# Quality score
python scripts/quality_score.py Quarto/<deck>.qmd

# Surface-count sync (README ↔ CLAUDE.md ↔ guide ↔ landing page)
./scripts/check-surface-sync.sh
```

Deck YAML frontmatter must set `format: beamer` with `pdf-engine: xelatex` and
`include-in-header: ../Preambles/header.tex`.

---

## Quality Thresholds

| Score | Checkpoint | Meaning |
|-------|------|---------|
| 90 | Commit | Good enough to save |
| 95 | PR | Ready for deployment |
| 98 | Excellence | Aspirational |

Enforced by `/commit` (halts + asks for override) **and** — once you run `./scripts/install-hooks.sh` — by a real git pre-commit hook (`.githooks/pre-commit`) that runs the surface-sync + quality (≥90) gates on every commit. Bypass sparingly with `SKIP_QUALITY_GATE=1` or `--no-verify`.

---

## Skills Quick Reference

The full table of all skills lives in [README.md](README.md#skills-claudeskills). Most-used here, by workflow:

- **Slides / paper:** `/create-lecture` `/slide-excellence` `/visual-audit` `/pedagogy-review` `/teach-from-paper`
- **Papers / review:** `/review-paper` (`--peer`) `/seven-pass-review` `/verify-claims` `/proofread` `/humanize` `/submission-disclosures` `/lit-review`
- **Data / reproducibility:** `/data-analysis` `/audit-reproducibility` `/diagnose` `/replication-package` `/capture-environment` `/disclosure-check` `/validate-bib`
- **Research / writing:** `/interview-me` `/research-ideation` `/preregister` `/data-management-plan`
- **Meta / workflow:** `/commit` `/learn` `/checkpoint` `/context-status` `/deep-audit`

### Inactive / repurposed surfaces (this project)

These skills/agents assume the upstream Beamer-`.tex`-authoritative → RevealJS-HTML
bridge, which this project does not use. Files remain on disk (template dual-nature)
but are **not part of the active workflow**: `/translate-to-quarto`, `/qa-quarto`,
`/compile-latex`, `/extract-tikz`, `/deploy` (GitHub-Pages sync); agents
`beamer-translator`, `quarto-critic`, `quarto-fixer`. `check-palette-sync.sh` is
advisory only (SCSS styles a non-existent HTML target). If an HTML target is ever
restored, revert the build-direction changes recorded in MEMORY.md.

---

## Beamer Custom Environments

Custom Beamer boxes are defined in `Preambles/header.tex`. Document them here as the
deck adds them.

| Environment | Effect | Use Case |
| --- | --- | --- |
| _(none yet)_ | — | Add rows as boxes are defined in `header.tex` |

## Quarto CSS Classes

Not applicable — this project targets Beamer PDF, not RevealJS HTML. `theme-template.scss` is vestigial.

---

## Current Project State

| Artifact | Source | Renders to | Key Content |
| --- | --- | --- | --- |
| HelloWorld *(smoke test — delete when real deck exists)* | `Quarto/HelloWorld.qmd` | Beamer PDF | Verifies the QMD→Beamer build path |
| Findings deck | `Quarto/<deck>.qmd` *(TBD)* | Beamer PDF | Key IPO-return findings, US vs. EU/UK |
| Descriptive note | `paper/<note>.qmd` *(TBD)* | PDF | Data sources, literature, results |
| Analysis pipeline | `scripts/R/*.R` *(TBD)* | `_outputs/` | WRDS + Ritter data → returns |
