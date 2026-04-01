---
name: deep-audit
description: |
  Deep consistency audit of the entire repository infrastructure.
  Launches parallel specialist agents to find code bugs, stale references,
  cross-document inconsistencies, and data quality issues. Then fixes all issues
  and loops until clean.
  Use when: after making broad changes, before releases, or when user says
  "audit", "find inconsistencies", "check everything".
---

# /deep-audit -- Repository Infrastructure Audit

Run a comprehensive consistency audit across the entire repository, fix all issues found, and loop until clean.

## When to Use

- After broad changes (new skills, rules, hooks, config edits)
- Before releases or major commits
- When the user asks to "find inconsistencies", "audit", or "check everything"

## Workflow

### PHASE 1: Launch 3 Parallel Audit Agents

Launch these 3 agents simultaneously using `Task` with `subagent_type=general-purpose`:

#### Agent 1: Config Consistency
Focus: `CLAUDE.md`, `.claude/settings.json`, `.claude/WORKFLOW_QUICK_REF.md`
- Skills table in CLAUDE.md matches actual skill directories 1:1
- No stale references to removed tools (Beamer, Quarto, LaTeX, R)
- Settings.json permissions match the tools actually used
- All file paths mentioned actually exist on disk

#### Agent 2: Rules and Skills Quality
Focus: `.claude/skills/*/SKILL.md` and `.claude/rules/*.md`
- Valid YAML frontmatter in all files
- Rule `paths:` reference existing directories
- No contradictions between rules
- No stale `allowed-tools` attributes in skill files
- All templates referenced in rules exist in `templates/`

#### Agent 3: Hook Code Quality
Focus: `.claude/hooks/*.py` and `.claude/hooks/*.sh`
- Proper error handling (fail-open pattern)
- JSON input/output correctness
- Exit code correctness
- No hardcoded paths

### PHASE 2: Triage Findings

Categorize each finding:
- **Genuine bug**: Fix immediately
- **False alarm**: Discard (document WHY)

### PHASE 3: Fix All Issues

Apply fixes in parallel where possible. For each fix:
1. Read the file first
2. Apply the fix
3. Verify the fix

### PHASE 4: Loop or Declare Clean

After fixing, launch fresh agents to verify.
- If new issues found -> fix and loop again
- If zero genuine issues -> declare clean and report summary

**Max loops: 5** (to prevent infinite cycling)

## Output Format

After each round, report:

```
## Round N Audit Results

### Issues Found: X genuine, Y false alarms

| # | Severity | File | Issue | Status |
|---|----------|------|-------|--------|
| 1 | Critical | file.py:42 | Description | Fixed |

### Verification
- [ ] No stale references (grep confirms)
- [ ] All hooks have fail-open pattern
- [ ] CLAUDE.md skills table matches disk

### Result: [CLEAN | N issues remaining]
```
