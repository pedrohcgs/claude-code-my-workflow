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

- **Path convention:** `here::here()` for all R scripts (no hardcoded paths)
- **Seed convention:** `set.seed(42)` at top of every R script with stochastic elements
- **Figure standards:** 300 DPI, white background (`bg = "white"`), `ggplot2::theme_minimal()`
- **Color palette:** Colorblind-safe — viridis (`scale_color_viridis_d()`) or ColorBrewer palettes
- **Tolerance thresholds:** 4 decimal places for energy intensities and elasticities (e.g., `round(ei, 4)`)

---

## Preferences

**Visual:** White background figures at 300 DPI; viridis/ColorBrewer for all categorical color scales
**Reporting:** Structured bullets by default; detailed prose on request
**Session logs:** Always (post-plan, incremental, end-of-session)
**Proofreading:** Rigorous mode — flag all near-misses, not just clear errors

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
