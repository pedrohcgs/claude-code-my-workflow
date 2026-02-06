---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "quality_reports/**"
---

# Proofreading Agent Protocol (MANDATORY)

**Every lecture file MUST be reviewed by the proofreading agent before any commit or PR.**

The proofreading agent checks for:
- **Grammar errors** -- subject-verb agreement, missing articles, wrong prepositions
- **Typos** -- misspellings, search-and-replace corruption
- **Overflow issues** -- overfull hbox in Beamer, content exceeding slide boundaries in Quarto
- **Consistency** -- notation, citation style (`\citet` vs `\citep`, `[@key]` brackets), terminology
- **Academic writing quality** -- informal abbreviations, missing words, awkward phrasing

## Two-Phase Workflow: PROPOSE FIRST, THEN DEPLOY

**The agent must NEVER apply changes directly. It must first propose all changes for review.**

### Phase 1: Review & Propose (NO EDITS)

Launch parallel review agents for all modified lecture files. Each agent:

1. Reads the entire file carefully
2. Identifies all grammar, typo, overflow, and consistency issues
3. Produces a **detailed report** listing every proposed change with:
   - Line number or slide context
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category (grammar / typo / overflow / consistency)
4. Saves the report to `quality_reports/` (e.g., `quality_reports/LectureN_Topic_report.md`)
5. **Does NOT modify any source files**

**Example report entry:**
```
### Issue 7: Wrong preposition
- **File:** Slides/LectureN_Topic.tex
- **Location:** Slide "Example Title", line ~247
- **Current:** "eligible to the program"
- **Proposed:** "eligible for the program"
- **Category:** Grammar
```

### Phase 2: Review & Approve

The user (or Claude, if instructed) reviews the proposed changes:
- Accepts all changes, or
- Accepts selectively, or
- Requests modifications

**Only after explicit approval** does the agent proceed to apply fixes.

### Phase 3: Apply Fixes

Launch parallel fix agents to apply only the approved changes:
- Each agent reads the report and applies edits using the Edit tool
- Uses `replace_all: true` for issues with multiple instances
- Verifies each edit succeeded
- Reports completion summary

## Agent Prompt Template

```
You are an expert proofreading agent for academic lecture slides. Review the file
[FILENAME] thoroughly for:

1. GRAMMAR: Subject-verb agreement, articles (a/an/the), prepositions, tense consistency
2. TYPOS: Misspellings, search-and-replace artifacts, duplicated words
3. OVERFLOW: Overfull hbox warnings (LaTeX), content exceeding slide boundaries (Quarto)
4. CONSISTENCY: Citation format, notation, terminology across slides
5. ACADEMIC QUALITY: Informal language, missing words, awkward constructions

IMPORTANT: Do NOT edit any files. Only produce a report listing all findings with:
- Location (line number or slide title)
- Current text
- Proposed fix
- Category

Save the report to quality_reports/[FILENAME_WITHOUT_EXT]_report.md
```

## Integration Points

Run proofreading at these points:
1. **Before any commit** -- on all modified lecture files
2. **Before any PR** -- full sweep of all lecture files
3. **After creating new lecture content** -- immediately after development
4. **After bulk edits** -- any search-and-replace or refactoring

## Quality Reports

Reports saved to `quality_reports/` with naming convention:
```
quality_reports/
├── Lecture1_Topic_report.md
├── Lecture2_Topic_report.md
├── Lecture3_Topic_report.md
└── ...
```

These are **auto-generated** and serve as an audit trail of quality checks.
