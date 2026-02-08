# Session Log: Lit Trilogy Installation

**Date:** 2026-02-07
**Goal:** Install lit-search, lit-synthesis, and lit-writeup skills from `test-for-useful/` into `.claude/skills/`, adapted for policing research.

---

## Plan Summary

Install three interconnected literature review skills ("The Lit Trilogy"), adapt them from sociology to multidisciplinary policing research (criminology, economics, political science, policy studies), connect them to the existing `lit-review-assistant` skill, register them in CLAUDE.md, and clean up the source directory.

## Key Decisions

- **Discipline adaptation:** Replaced sociology-specific references (Bourdieu/Goffman/Foucault) with policing-relevant theorists (Tyler/Becker/Nagin/Ostrom/Wilson). Changed "sociology" to "policing and criminal justice research" throughout.
- **What was preserved:** Core API code, phase workflows (7-phase search, 6-phase synthesis, 5 contribution clusters), calibration norms, Zotero MCP integration, turn formula, sentence toolbox. Sociology benchmarks in calibration norms kept as valid cross-discipline starting points with an added caveat.
- **Exemplar quotes retained:** Some "sociologists" references in teaching examples (citation pattern demonstrations) were intentionally preserved for pedagogical value.
- **YAML frontmatter:** Added `disable-model-invocation: true` and `argument-hint` to all three SKILL.md files per project conventions.

## OpenAlex Concept ID Corrections

The original plan contained 5 incorrect concept IDs. During implementation, all IDs were verified against the live OpenAlex API and corrected in `lit-search/api/openalex-reference.md`:
- Criminology, Law enforcement, Police, Criminal justice
- Political science, Economics, Public policy, Sociology

## Files Created (34 new files)

**`.claude/skills/lit-search/`** (9 files):
- `SKILL.md`, 7 phase files (`phases/phase0-scope.md` through `phase6-synthesis.md`), `api/openalex-reference.md`

**`.claude/skills/lit-synthesis/`** (8 files):
- `SKILL.md`, 6 phase files (`phases/phase0-corpus-audit.md` through `phase5-field-synthesis.md`), `mcp/zotero-setup.md`

**`.claude/skills/lit-writeup/`** (17 files):
- `SKILL.md`, 6 phase files, 5 cluster profiles (`clusters/`), 5 technique guides (`techniques/`)

## Files Modified (2)

- **`.claude/skills/lit-review-assistant/SKILL.md`** (+12 lines) — Added "Proactive Tools: The Lit Trilogy" section positioning the trilogy as the depth engine behind the lightweight lit-review-assistant.
- **`CLAUDE.md`** (+3 lines) — Added `/lit-search`, `/lit-synthesis`, `/lit-writeup` to the Research Lifecycle table.

## Files Deleted

- **`test-for-useful/`** — entire directory (39 files) removed after successful installation.

## Verification Results

- All 3 SKILL.md files passed YAML validation (`python -c "import yaml; yaml.safe_load(...)"`)
- Required fields confirmed: `name`, `description`, `disable-model-invocation`, `argument-hint`
- No stray sociology-specific language in generic sections
- All 34 files in correct directory structure
- OpenAlex concept IDs verified against live API

## Remaining Issues

- Stray `nul` file at repo root (Windows artifact from a bad redirect; untracked, harmless)
- All changes are uncommitted — ready for commit

## Open Questions for Next Session

- None. Installation complete and verified.

---

## Later Activity (same day)

- **Chrome MCP test:** User asked to test Chrome browser automation. Connection was already active (no need to run `/chrome`). Created a tab group successfully — confirmed MCP bridge is working. Single empty "New Tab" visible in the group.
