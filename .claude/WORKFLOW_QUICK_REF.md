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

## Security Layer

- **Deny list** blocks 17 dangerous patterns statically (rm -rf, force push, sudo, credential reads)
- **bash-safety.sh** blocks destructive commands dynamically (curl|bash, file uploads)
- **output-scanner.sh** warns if secrets appear in tool output (AWS keys, API tokens)
- **audit-log.sh** records every tool invocation to `.claude/logs/audit.jsonl`
- **enforce-isolation.sh** keeps reviewer agents read-only
- **enforce-foreground-agents.sh** blocks background agents that can't prompt

---

## Non-Negotiables (Customize These)

<!-- Replace with YOUR project's locked-in preferences -->

- [YOUR PATH CONVENTION] (e.g., `here::here()` for R, relative paths for LaTeX)
- [YOUR SEED CONVENTION] (e.g., `set.seed()` once at top for stochastic code)
- [YOUR FIGURE STANDARDS] (e.g., white bg, 300 DPI, custom theme)
- [YOUR COLOR PALETTE] (e.g., institutional colors)
- [YOUR TOLERANCE THRESHOLDS] (e.g., 1e-6 for point estimates)

---

## Preferences

<!-- Fill in as you discover your working style -->

**Visual:** [How you want figures/plots handled]
**Reporting:** [Concise bullets? Detailed prose? Details on request?]
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** [How strict? Flag near-misses?]

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## New Capabilities

- `/oracle [question]` -- Second-opinion via ChatGPT Pro
- `/parse-paper [pdf]` -- Extract structured content from PDFs
- `/ship [description]` -- One-command commit-push-PR-merge
- `/simulation-study [name]` -- Monte Carlo scaffold
- `/mailbox` -- Structured inter-agent communication
- `/progress` -- Visual progress tracking

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
