# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)

---

## The Loop

```
Your instruction
    |
[PLAN] (if multi-file or unclear) -> Show plan -> Your approval
    |
[EXECUTE] Implement, verify, done
    |
[REPORT] Summary + what's ready
    |
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Data ambiguity:** "Partner name format unclear. Assume Y?"
- **Threshold decisions:** "Match rate is X% at this cutoff. Lower threshold or accept?"
- **Scope question:** "Also clean Y while here, or focus on X?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (script runs, data outputs exist, match rates reported)
- Documentation (logs, commits)
- Plotting (per established standards)

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables

- **Paths:** `pathlib.Path` in Python, `global root` in Stata -- always relative, never absolute
- **Merge diagnostics:** Log row counts and match rates at every merge/join
- **Raw data protection:** Never modify files in `data/raw/` -- all processing creates new files
- **Thresholds documented:** Every matching cutoff has a stated justification
- **Validation before output:** Manual review sample before finalizing any match dataset

---

## Preferences

**Visual:** Publication-ready, polished, consistent color palette, 300 DPI
**Reporting:** Concise bullets with key metrics; details on request
**Session logs:** Always (post-plan, incremental, end-of-session)
**Matching rigor:** High -- flag uncertain matches for review rather than auto-accepting

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed -- just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task -> I plan (if needed) -> Your approval -> Execute -> Done.
