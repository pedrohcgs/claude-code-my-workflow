# Workflow Quick Reference

**Project:** AIGC and Stock Price Synchronicity
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
- **Identification choice:** "Two valid IV approaches. Which fits your theory?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (tolerance checks, compilation)
- Documentation (logs, commits)
- Plotting (per established figure standards)
- Adding robustness checks from the standard list

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables

- **Relative paths** — no hardcoded absolute paths in any script
- **Reproducibility** — `random_state=42` in Python; `set.seed(YYYYMMDD)` once at top in R
- **Figure standards** — white background, 300 DPI, tight layout, no decorative fonts
- **Color palette** — neutral/publication-appropriate (no institutional colors); default: black, gray, `#2166ac` (blue), `#d6604d` (red)
- **Tolerance thresholds** — point estimates ±1e-4; SEs ±1e-3; see knowledge base for full table
- **Synchronicity** — always log-odds transform (ψ), never raw R²
- **Panel SEs** — cluster at firm level minimum; two-way (firm + year) preferred

---

## Preferences

**Visual:** Publication-quality figures — white bg, 300 DPI, concise axis labels, no chart junk
**Reporting:** Concise bullets first; details on request
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** Strict — flag any deviation from spec, including near-misses

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
