# CLAUDE.MD --- Data Analysis with Claude Code

**Project:** Fertilizer Quality in Kenya
**Institution:** Macquarie University
**Branch:** main

---

## Core principles

- **Plan first** --- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** --- compile/run and confirm output at the end of every task
- **Quality gates** --- nothing ships below 80/100
- **[LEARN] tags** --- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Project setup checklist (first session)

1. ~~Drop your existing project folder contents into `project/`~~ Done (synced from Dropbox)
2. ~~Describe the folder structure in the "File structure map" section below~~ Done
3. ~~Configure Dropbox sync paths if applicable~~ Done
4. N/A (no Beamer theme for this project)
5. N/A (no LaTeX compilation for this project)

---

## Folder structure

```
repo/
├── CLAUDE.md                    # This file
├── MEMORY.md                    # Persistent learnings
├── README.md                    # Minimal: what, how, prerequisites
├── bibliography.bib             # Shared bibliography
├── .syncignore                  # Excluded from Dropbox sync
├── .claude/                     # All infrastructure
│   ├── settings.json            # Permissions + hook wiring
│   ├── agents/                  # Review agents
│   ├── rules/                   # Workflow rules
│   ├── skills/                  # Slash commands
│   ├── hooks/                   # Automation hooks
│   └── WORKFLOW_QUICK_REF.md    # One-page cheat sheet
├── preambles/header.tex         # Shared Beamer preamble (Metropolis)
├── slides/                      # New Beamer slides
├── figures/                     # Static images for slides
├── scripts/
│   ├── quality_score.py         # Quality scoring (Beamer/Python/Stata)
│   ├── python/                  # Shared Python utilities
│   └── stata/
│       └── logs/                # Stata log files
├── templates/                   # Session log, quality report, sync scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox
├── master_supporting_docs/      # Papers (PDF processing rule)
└── project/                     # YOUR EXISTING PROJECT FILES HERE
    └── README.md                # Explains convention + Dropbox sync
```

Infrastructure at root never touches Dropbox. Only `project/` syncs bidirectionally.

---

## File structure map

```
project/                              # Synced from Dropbox PEDL/ folder
├── admin/                            # Admin docs (budget, proposals)
├── Alison/                           # Early scripts (Alison's versions)
├── data/
│   ├── build/
│   │   ├── code/                     # Main build pipeline
│   │   │   ├── ff_master.do          # Orchestrates cleaning pipeline
│   │   │   └── archive/              # Deprecated build scripts
│   │   ├── input/                    # Raw data (PROTECTED, never overwrite)
│   │   ├── output/                   # Cleaned datasets
│   │   └── temp/                     # Intermediate files
│   ├── function/
│   │   ├── code/                     # Analysis functions
│   │   │   ├── ff_stores_distance.do # Store proximity (geodist)
│   │   │   └── ff_summary_stats.do   # Summary stats + histograms
│   │   └── output/                   # Tables (.tex), figures
│   ├── media/                        # Survey media (PROTECTED)
│   └── round 2/                      # Round 2 data + scripts
├── directory/                        # Agro-dealer directory data
├── Photos, round 2/                  # Field photos
├── Survey/
│   ├── Expenses/                     # Field expense records
│   └── Stata/                        # Survey cleaning scripts
│       └── media/                    # Survey media files
└── Testing/                          # Lab testing data (PROTECTED)
```

---

## Commands

```bash
# Stata --- project build pipeline
stata-mp -b do project/data/build/code/ff_master.do

# Stata --- analysis pipeline
stata-mp -b do project/analysis/master.do

# Stata --- individual scripts (legacy, in project/)
stata-mp -b do project/data/function/code/ff_summary_stats.do
stata-mp -b do project/data/function/code/ff_stores_distance.do

# Quality score
python scripts/quality_score.py project/data/build/code/ff_master.do
python scripts/quality_score.py project/data/function/code/ff_summary_stats.do

# Dropbox sync (pull collaborator changes)
bash sync-from-dropbox.sh
```

---

## Quality thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

---

## Skills quick reference

| Command | What it does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/extract-tikz [LectureN]` | TikZ → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-python [file]` | Python code quality review |
| `/review-stata [file]` | Stata .do file quality review |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end Python analysis |

---

## Beamer custom environments

| Environment | Effect | Use case |
|-------------|--------|----------|
| `keybox` | Gold background box | Key takeaways |
| `highlightbox` | Teal left-accent box | Highlights |
| `definitionbox[Title]` | Navy titled box | Formal definitions |

---

## Sync

```
[REPO_PATH]:    C:/git/fake-fertilizer
[DROPBOX_PATH]: C:/Users/maand/Dropbox (Personal)/Fake fertilizer/PEDL
```

Only the `PEDL/` subfolder syncs---root-level admin docs in Dropbox are excluded.

See `templates/sync-from-dropbox.sh`.
Note: rsync unavailable on this Windows machine; sync scripts use Python fallback.

---

## Current project state

| Pipeline stage | Script | Status | Description |
|----------------|--------|--------|-------------|
| Build: master | `data/build/code/ff_master.do` | Existing | Orchestrates cleaning pipeline |
| Build: archive | `data/build/code/archive/*.do` | Archived | Older cleaning scripts |
| Function: distance | `data/function/code/ff_stores_distance.do` | Existing | Store proximity (geodist) |
| Function: stats | `data/function/code/ff_summary_stats.do` | Existing | Summary stats + histograms |
| Survey cleaning | `Survey/Stata/*.do` | Existing | Input survey + mystery shopping |
| Round 2 | `data/round 2/From Hilda 20180329/*.do` | Existing | Second round data processing |

All existing code uses hardcoded paths (`C:\Users\Emilia\Dropbox\...`) that need updating.
