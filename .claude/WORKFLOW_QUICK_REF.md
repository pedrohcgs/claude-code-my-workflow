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

- **Path convention:** Stata tasks use relative paths within task directories; symlinks connect tasks
- **Seed convention:** `set seed YYYYMMDD` at top of master .do files for stochastic operations
- **Figure standards:** White background, 300 DPI PNG export from Stata; `graph export` with explicit dimensions
- **Color palette:** UChicago Maroon (#800000), Dark Gray (#767676), Phoenix Yellow (#FFA319)
- **Tolerance thresholds:** 1e-6 for point estimates, 1e-4 for standard errors
- **Data vintage:** Always document BEA/NIPA vintage date; CMS claims data year range; BLS reference quarter

---

## Preferences

**Visual:** Publication-quality figures; consistent maroon/gray palette; Beamer-compatible dimensions
**Reporting:** Detailed by default (thorough explanations with reasoning)
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** Strict -- flag near-misses with tolerance note

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed -- just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
