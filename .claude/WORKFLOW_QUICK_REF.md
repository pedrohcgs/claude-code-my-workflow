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

- **Paths:** All code uses relative paths from repo root (`data/raw/`, `data/processed/`, `Figures/`)
- **Seeds:** Python scripts set `random.seed(20260101)` + `np.random.seed(20260101)`; Stata do-files set `set seed 20260101` — once at top
- **Figures:** White background, 300 DPI minimum, exported to `Figures/` as `.pdf` + `.png`; matplotlib or ggplot2 only (no default Stata graphs in paper)
- **MRIO algebra:** All matrix operations in Python (numpy/scipy); Stata is for econometrics and descriptive tables only
- **seg score:** Always the IPD-based formula from Bailey-Strezhnev-Voeten ideal points (St. Louis Fed 2025 formulation); UNGA-DM is robustness only
- **Weight normalization:** Assert `abs(weights.sum() - 1.0) < 1e-6` before computing any Exposure index
- **Standard errors:** Always `vce(cluster countrycode)` in Stata panel regressions — no exceptions
- **Matrix verification:** Always verify ICIO row/col ordering against ReadMe annex before matrix operations

---

## Preferences

**Visual:** Economist-style — minimal gridlines, labeled axes, no chart junk, readable at 2-column journal width
**Reporting:** Concise bullets; detailed prose only on request
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** Flag near-misses; tolerance 1e-6 for matrix algebra, 1e-4 for exposure indices

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
