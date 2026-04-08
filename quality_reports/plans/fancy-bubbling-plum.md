# Plan: Major Infrastructure Upgrade (P0-P3)

**Status:** DRAFT
**Date:** 2026-04-07
**Scope:** Security foundation + new tools + workflow patterns + documentation

---

## Context

This repo is the public benchmark template for Claude Code academic workflows. We're upgrading it with security, new tools, and patterns from Econ730, StatsClaw, Oracle, LiteParse, Karpathy's autoresearch, and Anthropic best practices. Everything must be generic (not domain-specific) and production-quality.

## Summary of Changes

| Category | Before | After | Delta |
|----------|--------|-------|-------|
| Hooks | 7 | 13 | +6 |
| Skills | 22 | 28 | +6 |
| Rules | 18 | 20 | +2 |
| Templates | 7 | 8 | +1 |

---

## Phase 1: Security Foundation

### 1A. Create 6 new hooks (all parallelizable)

| File | Source | Generalization |
|------|--------|---------------|
| `.claude/hooks/bash-safety.sh` | Econ730 | Remove "Econ 730" comment |
| `.claude/hooks/output-scanner.sh` | Econ730 | None needed (already generic) |
| `.claude/hooks/audit-log.sh` | Econ730 | Remove "Econ 730" comment |
| `.claude/hooks/enforce-isolation.sh` | Econ730 | Replace `econometric-reviewer` → `domain-reviewer` |
| `.claude/hooks/enforce-foreground-agents.sh` | Econ730 | None needed |
| `.claude/hooks/plan-reminder.py` | Econ730 | Fix state dir to `~/.claude/sessions/<hash>/`, fix hash to [:8] |

All scripts must be `chmod +x`.

### 1B. Update settings.json

**Add deny list** (17 patterns):
```
rm -rf, rm -r /*, sudo, chmod 777, chmod u+s,
git push --force/--f, git reset --hard, git clean -f,
git checkout ., git restore ., git branch -D,
Read(.env), Read(.env.*), Read(**/*.pem), Read(**/*.key)
```

**Add `showThinkingSummaries: true`** (from Twitter finding about effort regression)

**Add new hook configs:**
- PreToolUse[Bash] → bash-safety.sh
- PreToolUse[Edit|Write] → enforce-isolation.sh (add to existing)
- PreToolUse[Agent] → enforce-foreground-agents.sh
- PostToolUse[] → output-scanner.sh, audit-log.sh (add to existing)
- Stop → plan-reminder.py (add to existing)

**Note:** settings.json is in protect-files.sh PROTECTED_PATTERNS. Must handle this.

### 1C. Update .gitignore
- Add `.claude/logs/` (audit log is machine-specific)

---

## Phase 2: New Tool Skills (6 new skills)

### 2A. Create from scratch
| Skill | Description |
|-------|------------|
| `oracle/SKILL.md` | Cross-validate with ChatGPT Pro via Oracle CLI. Generic examples, not domain-specific. |
| `parse-paper/SKILL.md` | LiteParse wrapper for PDF preprocessing. Text + screenshots for AI context. |

### 2B. Port from Econ730 (generalized)
| Skill | Generalization Needed |
|-------|----------------------|
| `mailbox/SKILL.md` | None (already generic) |
| `progress/SKILL.md` | None (already generic) |
| `ship/SKILL.md` | Remove Econ730/DRDID examples, generic examples |
| `simulation-study/SKILL.md` | Remove Emory theme, #f2a900, LectureNN; use generic conventions |

---

## Phase 3: Workflow Patterns

### 3A. Create 2 new rules
| Rule | Type | Source |
|------|------|--------|
| `pipeline-isolation.md` | Always-on | Econ730 (generalize econometric-reviewer → domain-reviewer) |
| `inter-agent-communication.md` | Always-on | Econ730 (already generic) |

### 3B. Create 1 new template
| Template | Source |
|----------|--------|
| `templates/research-program.md` | Karpathy autoresearch pattern (new) |

### 3C. Modify 4 existing skills (add frontmatter)
| Skill | Change |
|-------|--------|
| `lit-review/SKILL.md` | Add `context: fork` |
| `research-ideation/SKILL.md` | Add `context: fork` |
| `review-paper/SKILL.md` | Add `context: fork` |
| `data-analysis/SKILL.md` | Add `effort: max` |

### 3D. Modify 2 existing rules
| Rule | Addition |
|------|---------|
| `quality-gates.md` | Add "Tolerance Integrity" section (never relax tolerances) |
| `plan-first-workflow.md` | Add "Deep Comprehension Protocol" (understand before specifying) |

---

## Phase 4: Documentation Updates

### 4A. CLAUDE.md
- Add 6 new skills to Skills Quick Reference table
- Add compaction directives section
- Add "Research the codebase before editing. Never change code you haven't read." to Core Principles

### 4B. README.md
- Update all counts (13 hooks, 28 skills, 20 rules, 8 templates)
- Add new skills/hooks/rules/templates to "What's Included"
- Add security layer description
- Add Oracle/LiteParse to ecosystem references

### 4C. guide/workflow-guide.qmd
- Update hooks table with 6 new entries
- Update skills table with 6 new entries
- Add Pattern 16: Oracle for Research
- Add Pattern 17: PDF Preprocessing Pipeline
- Add Pattern 18: Autonomous Research Loops (autoresearch)
- Add Pattern 19: Pipeline Isolation
- Update all count references

### 4D. MEMORY.md
- Add security pattern learnings
- Add inter-agent pattern learnings
- Add effort/thinking budget finding

### 4E. WORKFLOW_QUICK_REF.md
- Add Security Layer section
- Add New Capabilities section

---

## Execution Order (Parallelization)

```
WAVE 1 (all independent, maximum parallelism):
  15 file CREATES: 6 hooks + 6 skills + 2 rules + 1 template

WAVE 2 (parallel with Wave 1, no dependencies):
  8 file MODIFIES: settings.json, .gitignore, 4 skills, 2 rules

WAVE 3 (after Waves 1+2):
  5 file MODIFIES: CLAUDE.md, README.md, guide, MEMORY.md, QUICK_REF

WAVE 4 (after all):
  Verification: JSON validation, chmod check, count audit, grep for Econ730 references
```

---

## Verification Checklist

1. `python3 -m json.tool .claude/settings.json` → valid JSON
2. All new hooks executable (`chmod +x`)
3. All new skills have valid YAML frontmatter
4. README counts: 10 agents, 28 skills, 20 rules, 13 hooks, 8 templates
5. Guide counts match README
6. Zero Econ730/Emory-specific references: `grep -r "Econ 730\|Emory\|econometric-reviewer\|#f2a900\|DRDID\|pedrohcgs" .claude/ templates/`
7. `.claude/logs/` in .gitignore
8. `git diff --stat` → ~28 files changed
