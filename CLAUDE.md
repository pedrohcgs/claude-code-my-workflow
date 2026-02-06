# CLAUDE.MD — Academic Project Development with Claude Code

<!-- ============================================================
     HOW TO USE THIS TEMPLATE:
     1. Replace all [BRACKETED PLACEHOLDERS] with your project info
     2. Delete sections that don't apply to your project
     3. Add domain-specific sections as needed
     4. This file is read by Claude at the start of every session
     ============================================================ -->

**Last Updated:** [DATE]
**Project:** [YOUR PROJECT NAME] (e.g., "Econ 730 — Causal Panel Data")
**Institution:** [YOUR INSTITUTION]
**Working Branch:** main

---

## Quick Reference: Available Skills & Agents

| Command | What It Does |
|---------|-------------|
| `/compile-latex [filename]` | 3-pass XeLaTeX compilation with bibtex |
| `/deploy [LectureN]` | Render Quarto slides and sync to GitHub Pages |
| `/extract-tikz [LectureN]` | TikZ diagrams to PDF to SVG with 0-based indexing |
| `/proofread [filename]` | Grammar/typo/overflow review and report |
| `/visual-audit [filename]` | Slide layout audit for overflow and consistency |
| `/pedagogy-review [filename]` | PhD-student lens: narrative, notation, pacing review |
| `/review-r [file or LectureN]` | R code review: quality, reproducibility, correctness |
| `/qa-quarto [LectureN]` | Adversarial Quarto vs Beamer QA: critic finds issues, fixer resolves |
| `/slide-excellence [filename]` | Combined visual + pedagogical + proofreading review |
| `/translate-to-quarto [filename]` | Full Beamer to Quarto translation workflow |
| `/validate-bib` | Cross-reference citations vs bibliography file |
| `/devils-advocate` | Challenge slide design with pedagogical questions |
| `/create-lecture` | Full lecture creation workflow |

**Agents** (available for delegation): `proofreader`, `slide-auditor`, `pedagogy-reviewer`, `r-reviewer`, `tikz-reviewer`, `beamer-translator`, `quarto-critic`, `quarto-fixer`, `verifier`, `domain-reviewer`

**Rules** (auto-loaded): See `.claude/rules/` for domain-specific rules on LaTeX, Quarto, R, verification, proofreading, and quality gates.

---

## Project Overview

<!-- Describe your project in 2-3 paragraphs. What is it? Who is it for? -->

[DESCRIBE YOUR PROJECT HERE]

This repository is designed for multi-platform collaboration using:
- **GitHub** for version control and cross-computer synchronization
- **Overleaf** (optional) for LaTeX editing and compilation
- **Claude Code** for slide development, content creation, and research assistance

---

## Folder Structure

```
[YOUR-PROJECT]/
├── CLAUDE.MD                          # This file — Claude's guide
├── .claude/                           # Claude Code configuration
│   ├── settings.json                  # Project permissions + hooks
│   ├── rules/                         # Domain-specific rules (auto-loaded)
│   ├── skills/                        # Slash commands (/deploy, /proofread, etc.)
│   └── agents/                        # Specialized agents (proofreader, verifier, etc.)
├── Bibliography_base.bib              # Centralized bibliography
├── Figures/                           # Course figures and images
├── Preambles/                         # LaTeX headers and style files
│   └── header.tex
├── Slides/                            # LaTeX/Beamer lecture slides
│   ├── Lecture01_Topic.tex
│   └── ...
├── Quarto/                            # Quarto/RevealJS slides
│   ├── Lecture1_Topic.qmd
│   └── your-theme.scss               # Custom theme
├── docs/                              # GitHub Pages deployment (auto-generated)
│   ├── index.html
│   └── slides/
├── scripts/                           # Utility scripts
│   ├── sync_to_docs.sh               # Renders Quarto & syncs to docs/
│   └── R/                             # R scripts for figures and analysis
├── quality_reports/                    # Review agent reports (auto-generated)
└── master_supporting_docs/            # Supporting materials
    ├── supporting_papers/             # Academic papers (auto-split into chunks)
    └── supporting_slides/             # Existing slides to upgrade
```

---

## Working Philosophy

### Collaborative Partnership Approach

Claude serves as your **collaborative partner**, not a fully autonomous agent:

- **You drive the vision** — provide papers, concepts, and aesthetic preferences
- **Claude proposes designs** — creates slide structures and content arrangements
- **You iterate together** — refine until excellent
- **You maintain control** — final decisions always rest with you

### Communication Style

- **Devil's advocate mode** — challenge assumptions and explore alternative presentations
- **Reference validation** — every citation and claim verified for accuracy
- **Aesthetic excellence** — all slides should be visually compelling
- **Understanding > speed** — getting it right matters more than getting it fast

---

## CRITICAL: Single Source of Truth Principle

**NEVER duplicate content. Always extract from the original source.**

When content exists in multiple formats (e.g., Beamer PDF and Quarto HTML), there must be ONE authoritative source that all other versions derive from.

| Content Type | Source of Truth | Derived From |
|--------------|-----------------|--------------|
| Slide content | Beamer `.tex` file | Quarto `.qmd` derived from it |
| TikZ diagrams | Beamer `.tex` file | extract_tikz.tex, SVG, docs/ |
| Bibliography | `Bibliography_base.bib` | All `.tex` files reference it |
| Figures/images | `Figures/` directory | `docs/Figures/` via sync script |

> **Modify the original source, then regenerate all derived versions automatically.**

---

## Slide Development Workflow

### 1. Input Stage
Provide one or more of:
- Academic papers (upload to `master_supporting_docs/supporting_papers/`)
- Topic descriptions or learning objectives
- Existing slides to upgrade (`master_supporting_docs/supporting_slides/`)

### 2. Design Stage
Claude will:
- Analyze the material thoroughly
- Validate all references and claims
- Propose slide structure
- Play devil's advocate on structure
- Await your feedback

### 3. Iteration Stage
Collaborate to:
- Refine content organization
- Enhance visual aesthetics
- Improve pedagogical flow
- Validate technical accuracy

### 4. Output Stage
Final deliverables:
- **Beamer slides** (`.tex`) with polished design
- **Quarto slides** (`.qmd`) for web deployment (optional)
- Supporting R scripts and figures

---

## Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** A Stop hook enforces this automatically.

See `.claude/rules/verification-protocol.md` for the full checklist.

**Quick summary:**
- **Quarto:** Run `./scripts/sync_to_docs.sh LectureN`, verify HTML renders
- **LaTeX:** Compile with xelatex (3 passes), check for overfull hbox
- **TikZ to SVG:** Use `pdf2svg` with **0-based indexing**
- **Always** use `sync_to_docs.sh` instead of manual copying

---

## Quality Gates

| Threshold | When | What It Means |
|-----------|------|--------------|
| **80/100** | Commit | Good enough to save progress |
| **90/100** | PR | High quality, ready for deployment |
| **95/100** | Excellence | Aspirational target |

See `.claude/rules/quality-gates.md` for full scoring rubric.

---

## Design Principles

### Visual Excellence
- Clean, uncluttered layouts
- Strategic use of whitespace
- Consistent color schemes
- High-quality figures and diagrams
- Professional typography

### Pedagogical Clarity
- One key idea per slide
- Progressive revelation of complex concepts
- Visual metaphors and intuitive diagrams
- Smooth narrative flow between slides

### Technical Rigor
- All references validated and accurate
- Mathematical notation consistent and precise
- Code examples tested and functional
- Citations properly formatted in BibTeX

---

<!-- ============================================================
     CUSTOMIZE: Add your Beamer environments and CSS classes below
     ============================================================ -->

## Beamer Custom Environments

<!-- List your custom LaTeX environments here. Example: -->

| Environment | Effect | Use Case |
|-------------|--------|----------|
| `keybox` | Gold background box | Key points |
| `highlightbox` | Gold left-accent box | Highlights |
| `methodbox` | Blue left-accent box | Technical methods |
| `definitionbox[Title]` | Blue-bordered titled box | Formal definitions |

<!-- Add more as you build your theme -->

## Quarto CSS Classes

<!-- List your custom CSS classes here. Example: -->

| Class | Effect | Use Case |
|-------|--------|----------|
| `.smaller` | 85% font | Dense content slides |
| `.positive` | Green bold | Good annotations |
| `.negative` | Red bold | Problematic annotations |

---

## Technical Notes

### LaTeX Compilation

**Always compile with XeLaTeX, not pdflatex:**

```bash
cd Slides
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode filename.tex
BIBINPUTS=..:$BIBINPUTS bibtex filename
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode filename.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode filename.tex
```

### Deploying Quarto Slides

```bash
./scripts/sync_to_docs.sh              # All lectures
./scripts/sync_to_docs.sh Lecture2     # Specific lecture
```

### Git Workflow

- Main branch: `main`
- Commit regularly with descriptive messages
- Use PRs for significant changes
- Run proofreading before every PR

---

## Session Startup Ritual

Start each session with:

```
Claude, please:
1. Read CLAUDE.MD to understand our workflow
2. Check recent git commits to see what changed
3. Look at the lecture/slides we're working on
4. State what you understand our goals to be
```

### Session End Protocol

Before ending a session:
1. Commit significant changes with descriptive messages
2. Update CLAUDE.MD if workflow changed
3. Note any unresolved questions

---

## Current Project State

<!-- Update this table as you develop your project -->

| Lecture | Beamer | Quarto | Key Content |
|---------|--------|--------|-------------|
| 1: [Topic] | `Lecture01_Topic.tex` | `Lecture1_Topic.qmd` | [Brief description] |
| 2: [Topic] | `Lecture02_Topic.tex` | — | [Brief description] |

---

## Proofreading Protocol (MANDATORY)

**Every lecture file MUST be reviewed before any commit or PR.** Use `/proofread` to run the proofreading agent.

**Key rule:** The agent must NEVER apply changes directly. It proposes changes via a report in `quality_reports/`, then waits for your approval.

---

## Devil's Advocate Protocol

When designing slides, Claude will proactively:

1. **Challenge presentation choices** — "Could this be clearer if we showed X before Y?"
2. **Question pedagogical flow** — "Will students have the background for this notation?"
3. **Probe for gaps** — "Should we include an intuitive example before the formal proof?"
4. **Explore alternatives** — "Here are three ways to visualize this concept..."

---

## PDF Management

Long PDFs can challenge Claude's processing. Upload full PDFs to `master_supporting_docs/supporting_papers/` — Claude will automatically split them into 5-page chunks for safe processing.

See `.claude/rules/pdf-processing.md` for details.

---

## Reference Validation Protocol

For every slide deck, Claude will:

1. **Verify citations** — confirm paper exists, authors correct, year accurate
2. **Check claims** — validate assertions match source material
3. **Cross-reference** — ensure consistency across materials
4. **Document sources** — maintain bibliography with complete entries

---

## Quick Reference Commands

```bash
# Compile LaTeX (3-pass)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex file.tex

# Deploy Quarto to GitHub Pages
./scripts/sync_to_docs.sh LectureN

# Run quality score
python scripts/quality_score.py Quarto/file.qmd

# Add a paper (Claude auto-splits)
cp paper.pdf master_supporting_docs/supporting_papers/
```

---

**Ready to begin? Start by customizing this CLAUDE.md for your project, then upload your materials!**
