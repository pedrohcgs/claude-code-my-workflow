# CLAUDE.MD -- China Innovation Tax Benefits Study

**Project:** China Innovation Tax Benefits Study
**Institution:** University of Southern California
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- run code end-to-end and confirm output at the end of every task
- **Single source of truth** -- Word `.docx` is the authoritative manuscript; tables feed from Stata output; figures feed from Stata/Python
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
china-innovation-tax/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── data/
│   ├── raw/                     # Original CSMAR/CNRDS downloads (gitignored)
│   ├── processed/               # Cleaned intermediate files
│   └── final/                   # Analysis-ready datasets (.dta)
├── code/
│   ├── python/                  # Data collection and cleaning scripts
│   └── stata/                   # Analysis do-files
├── output/
│   ├── tables/                  # Stata-generated tables (.tex, .xlsx, .rtf)
│   └── figures/                 # Stata/Python-generated figures
├── manuscript/                  # Word documents (.docx)
├── slides/                      # PowerPoint presentations (.pptx)
├── literature/                  # Key papers (gitignored if large)
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and reference materials
```

---

## Commands

```bash
# Python (data collection / cleaning) — via conda
conda run -n usc2024 python code/python/script_name.py
# Or with environment activated:
python code/python/script_name.py

# Stata (Windows — StataNow 19)
stata-mp -b do code/stata/dofile.do
# Or batch mode:
"C:/Program Files/StataNow19/StataMP-64.exe" /e do code/stata/dofile.do

# Check Python script
python -m py_compile code/python/script_name.py

# Quality score
python scripts/quality_score.py code/python/script_name.py
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for submission/sharing |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/run-stata [dofile]` | Execute Stata do-file, check errors, verify outputs |
| `/proofread [file]` | Grammar/style/consistency review (manuscript context) |
| `/format-tables` | Verify Stata output tables are publication-ready |
| `/review-code [file]` | Python or Stata code quality review |
| `/data-analysis [dataset]` | End-to-end Python+Stata analysis workflow |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |

---

## Current Paper Components

| Component | File(s) | Status | Notes |
|-----------|---------|--------|-------|
| Data cleaning | `code/python/01_clean_csmar.py` | -- | CSMAR firm data |
| Main regressions | `code/stata/02_main_regressions.do` | -- | Probit/Logit |
| Robustness checks | `code/stata/03_robustness.do` | -- | Alt specs |
| Summary statistics | `output/tables/tab01_summary.tex` | -- | Table 1 |
| Main results | `output/tables/tab02_main.tex` | -- | Table 2 |
| Manuscript | `manuscript/china_innovation_tax.docx` | -- | Main paper |
