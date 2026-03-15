# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)
**Project:** China Innovation Tax Benefits Study | USC | StataNow 19 + Python 3.13

---

## The Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (probit) vs. Option B (logit + LPM). Which?"
- **Data ambiguity:** "CSMAR has two versions of this variable. Which?"
- **Replication edge case:** "Just missed tolerance. Investigate?"
- **Scope question:** "Also run robustness while here, or focus on main spec?"

---

## I Just Execute When

- Code fix is obvious (bug, path error, missing option)
- Verification (log checks, output existence, tolerance checks)
- Documentation (logs, commits)
- Table formatting (per booktabs standard)
- Export (after you approve, I run and verify automatically)

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables

- **Relative paths only** — no `C:\` or absolute paths in any script
- **`set seed YYYYMMDD`** — all stochastic Stata commands must set seed in this format
- **`version 19`** — all Stata do-files declare version
- **Booktabs tables** — `\toprule / \midrule / \bottomrule`, no `\hline`, no vertical rules
- **Stars: `* p<0.10 ** p<0.05 *** p<0.01`** — consistent across all tables
- **300 DPI minimum** for all figures
- **Never modify `data/raw/`** — read only

---

## Preferences

**Reporting:** Concise bullets; details on request
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** Strict — flag near-misses; investigate before proceeding
**Stata batch:** Run via `"C:/Program Files/StataNow19/StataMP-64.exe" /e do [file]`

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Key File Locations

| What | Where |
|------|-------|
| Analysis-ready data | `data/final/*.dta` |
| Python cleaning scripts | `code/python/` |
| Stata do-files | `code/stata/` |
| Tables | `output/tables/` |
| Figures | `output/figures/` |
| Stata logs | `output/logs/` |
| Manuscript | `manuscript/` |
| Plans | `quality_reports/plans/` |

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
