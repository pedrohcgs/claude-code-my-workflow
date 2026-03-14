# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)

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

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Code ambiguity:** "Spec unclear on X. Assume Y?"
- **Replication edge case:** "Just missed tolerance. Investigate?"
- **Scope question:** "Also refactor Y while here, or focus on X?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (tolerance checks, tests, compilation)
- Documentation (logs, commits)
- Plotting (per established standards)
- Deployment (after you approve, I ship automatically)

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables

- **Path convention:** All paths via `$root` global defined in `do/master.do`. No absolute paths anywhere in do-files.
- **Seed convention:** `set seed XXXXX` once at the top of `do/master.do`; inherited by all sub-do-files (never re-set in sub-files).
- **Figure standards:** White background, publication-ready, consistent font; use `scheme s2color` or project custom scheme. Export as `.pdf` or `.png` at ≥300 DPI.
- **Tolerance thresholds:** 1e-4 for point estimate replication checks. Flag near-misses (within 1e-3), investigate before accepting.
- **Data:** Never overwrite raw HILDA files. All analysis on copies. Raw data lives in `data/raw/` (gitignored).

---

## Preferences

**Reporting:** Concise bullets; details on request.
**Session logs:** Always (post-plan, incremental, end-of-session).
**Replication:** Flag near-misses (within 1e-3), investigate before accepting. Exact match expected at 1e-4.
**Stata output:** Always use `esttab`/`estout` with consistent formatting; never deliver raw `.log` as a result.

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
