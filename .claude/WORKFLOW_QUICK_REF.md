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

- Stata globals (`$dir`, `$data`, `$output`) for all paths; no hardcoded absolute paths
- `set seed YYYYMMDD` after `clear all` for any stochastic code
- `scheme(plotplain)` for figures, export PNG at default resolution
- Output chain: `build/code/` reads from `build/input/`, writes to `build/output/`; `function/code/` reads from `build/output/`, writes to `function/output/`
- All .do files must have `clear all` at top and `log using`/`log close` pair
- Existing .do files use hardcoded `C:\Users\Emilia\Dropbox\...` paths---must modernize before running locally

---

## Preferences

**Visual:** Stata `scheme(plotplain)`, histogram PNGs for distributions
**Reporting:** Concise bullets; details on request
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** Strict---existing pipeline must reproduce before extending

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed --- just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
