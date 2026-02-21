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
- **Data edge case:** "Outlier filtering removed 15% of data. Investigate?"
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

- **SI units throughout** -- W/m², °C, %, kWh/kWp; convert at data ingestion
- **Reproducible seeds** -- `np.random.seed(42)` or `set.seed(42)` at top of every stochastic script
- **IEC standard references** -- cite specific standard number and clause (e.g., IEC 61215:2021 clause 10.13)
- **Transparent figure backgrounds** -- all figures PNG/SVG with transparent or white bg, 300 DPI min
- **Timezone-aware timestamps** -- all solar time series data must use tz-aware datetimes

---

## Preferences

**Visual:** matplotlib for publication figures, plotly for interactive exploration
**Formatting:** Python: `black`; R: `styler`
**Testing:** `pytest` for Python validation, known reference values for regression tests
**Reporting:** Concise bullets for progress updates; detailed prose in reports
**Session logs:** Always (post-plan, incremental, end-of-session)
**Data formats:** Parquet for large datasets, CSV for small reference data

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed -- just a research value check (2 min)
- Good for: testing new pvlib features, exploring datasets, prototyping degradation models
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
