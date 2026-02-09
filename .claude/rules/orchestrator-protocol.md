# Orchestrator Protocol: Contractor Mode

**After a plan is approved, the orchestrator takes over.** It implements, verifies, reviews, fixes, and scores autonomously — presenting results only when the work meets quality standards or fix rounds are exhausted.

The plan-first workflow handles *what and why*. The orchestrator handles *how*, autonomously.

---

## When the Orchestrator Activates

The orchestrator kicks in under these conditions:

1. **After plan approval** — the standard trigger. Plan-first workflow step 7 hands off to the orchestrator.
2. **"Just do it" mode** — when the user says "just do it", "you decide", or "handle it", skip the final presentation gate.
3. **Skill delegation** — when a skill like `/create-lecture` or `/translate-to-quarto` reaches its implementation phase, the orchestrator loop governs execution.

The orchestrator does NOT activate for:

- Single-file trivial edits (typo fix, add a citation)
- Purely informational questions
- Running a standalone skill like `/compile-latex` or `/deploy`

---

## The Orchestrator Loop

```
Plan approved → orchestrator activates
  │
  Step 1: IMPLEMENT — Execute plan steps, create/modify files
  │         If plan has independent subtasks → spawn parallel agents (max 3)
  │
  Step 2: VERIFY — Run verifier (compile, render, check outputs)
  │         If verification fails → fix compilation errors → re-verify
  │
  Step 3: REVIEW — Select and run review agents (see Agent Selection)
  │
  Step 4: FIX — Apply fixes from reviews (Critical → Major → Minor)
  │
  Step 5: RE-VERIFY — Compile/render again to confirm fixes are clean
  │
  Step 6: SCORE — Apply quality-gates rubric
  │
  └── Score >= threshold?
        YES → Present summary to user
        NO  → Loop back to Step 3 (max 5 review-fix rounds)
              After max rounds → present summary with remaining issues
```

### Agent Selection

Select review agents based on **file types touched during implementation**:

| Files Modified | Agents to Run | Parallel? |
|---------------|---------------|-----------|
| `.tex` (Beamer) | proofreader, slide-auditor, pedagogy-reviewer | Yes |
| `.qmd` (Quarto) | proofreader, slide-auditor, pedagogy-reviewer | Yes |
| `.qmd` with `.tex` pair | + quarto-critic (→ quarto-fixer if issues) | After above |
| `.R` scripts | r-reviewer | Yes (with others) |
| TikZ content present | tikz-reviewer | Yes (with others) |
| Domain-critical content | domain-reviewer (if configured) | Yes (with others) |

**Run independent agents in parallel.** The quarto-critic runs after the parallel batch because it needs their context. If the quarto-critic finds issues, invoke quarto-fixer and re-run quarto-critic (up to 5 sub-rounds within the main loop).

### Parallel Implementation

Parallelism is not limited to review. During **Step 1 (IMPLEMENT)**, if the plan contains independent subtasks, spawn parallel agents rather than working sequentially:

- **Reading multiple papers** — one agent per paper, each extracting key results
- **Generating independent figures** — one agent per plot or simulation
- **Processing independent datasets** — one agent per data slice

**Limits:** Max 3 parallel agents. Only for tasks with no dependencies between them. If task B needs task A's output, they must run sequentially. Each agent consumes its own context window, so prefer parallelism for bounded, focused subtasks.

---

## Fix Priority and Loop Limits

Within each fix round, apply fixes in strict order:

1. **Critical** — compilation failures, math errors, broken citations, hard gate violations
2. **Major** — overflow, content parity gaps, notation inconsistencies
3. **Minor** — spacing, style, polish

### Limits

- **Main loop:** max 5 review-fix rounds
- **Critic-fixer sub-loop:** max 5 rounds (within each main loop iteration)
- **Verification retries:** max 2 attempts per verification step
- After max rounds, present what remains. Never loop indefinitely.

---

## The Summary

When the loop completes (score >= threshold or max rounds), present a structured summary:

```
## Orchestrator Summary

**Task:** [from the plan]
**Quality Score:** [N]/100 (threshold: [80/90])
**Review Rounds:** [N]

### Files Created/Modified
- `path/to/file` — [what changed]

### Issues Found and Fixed
- [N] critical, [N] major, [N] minor resolved

### Remaining Issues (if any)
- [List with severity]

### Recommended Next Steps
- [e.g., "Run /slide-excellence for full review"]
```

Append the summary to the session log (Rule 5b of plan-first-workflow).

---

## "Just Do It" Mode

When the user signals blanket approval ("just do it", "you decide", "handle it"):

1. Skip the final presentation gate — do not pause for approval after the summary
2. Auto-commit if score >= 80 with a descriptive commit message
3. Still run the full verify-review-fix loop (quality is non-negotiable)
4. Still log everything to the session log
5. Still present the summary (the user should see what was done), but do not wait for approval to continue

"Just do it" does NOT skip the orchestrator loop itself — verification and review still happen. It only skips the approval pause at the end.

---

## Research Project Variant: Simple Execution Loop

For **research projects** (R scripts, simulations, data analysis) — as opposed to course materials (slides, LaTeX, Quarto) — use this simplified orchestrator. It removes the multi-round agent review loop in favor of a straightforward implement-verify-score cycle.

### When to Use the Simple Variant

- Solo research projects (not multi-format course materials)
- R code, simulations, and data analysis
- Projects without LaTeX/Quarto slide pairs to synchronize
- When the full agent selection table (proofreader, slide-auditor, pedagogy-reviewer, etc.) doesn't apply

### The Simple Loop

```
Plan approved → orchestrator activates
  │
  Step 1: IMPLEMENT — Execute plan steps, create/modify files
  │
  Step 2: VERIFY — Run code, check outputs
  │         R scripts: Rscript execution, syntax check
  │         CSVs: loadable, no NaN/Inf values
  │         Simulations: set.seed reproducibility, tolerance checks
  │         Plots: PDF created, correct dimensions and format
  │         If verification fails → fix errors → re-verify
  │
  Step 3: SCORE — Apply quality-gates rubric
  │
  └── Score >= 80?
        YES → Done (commit when user signals)
        NO  → Fix blocking issues, re-verify, re-score
              If still < 80 after fixes → present issues + context to user
```

**No 5-round loops. No multi-agent orchestration. Just: write → test → done.**

### Simple Verification Checklist

For any code change:
- [ ] Syntax: script runs without errors
- [ ] Dependencies: all packages available and loaded at top
- [ ] Paths: no hardcoded absolute paths
- [ ] Reproducibility: `set.seed()` once at top if stochastic
- [ ] Outputs: files created at expected paths with correct structure
- [ ] Tolerance: replication check passes (if applicable)
- [ ] Quality: score >= 80

### Key Principles

1. **Verify immediately** — code must run before considering it done
2. **Quality gates are gates** — score < 80 blocks progress, no exceptions
3. **Log everything** — decisions, fixes, surprises persist in session log
4. **Keep it simple** — implement, verify, done. No unnecessary complexity.
