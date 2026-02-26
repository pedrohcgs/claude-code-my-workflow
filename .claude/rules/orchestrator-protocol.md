# Orchestrator Protocol: Contractor Mode

**After a plan is approved, the orchestrator takes over autonomously.**

## The Dependency-Driven Loop

```
Plan approved → orchestrator activates
  │
  Step 1: IDENTIFY — Check dependency graph, determine which phases can activate
  │
  Step 2: DISPATCH — Launch worker agents (parallel when independent)
  │         Each worker paired with its critic (see adversarial-pairing.md)
  │
  Step 3: REVIEW — Critic evaluates worker output, produces score
  │         If score < 80 → worker fixes → critic re-reviews (max 3 rounds)
  │         If 3 rounds fail → ESCALATE (see three-strikes.md)
  │
  Step 4: VERIFY — Compile, render, run code, check outputs
  │         If verification fails → fix → re-verify (max 2 attempts)
  │
  Step 5: SCORE — Aggregate scores across components (see scoring-protocol.md)
  │
  └── Score >= threshold?
        YES → Present summary to user
        NO  → Identify blocking components, loop back to Step 2
              After max 5 overall rounds → present with remaining issues
```

## Agent Dispatch Rules

The Orchestrator selects agents based on what the task requires:

| Task Involves | Agents Dispatched |
|--------------|-------------------|
| Literature/references | Librarian + Editor |
| Data sourcing | Explorer + Surveyor |
| Identification strategy | Strategist + Econometrician |
| R/Stata/Python scripts | Coder + Debugger |
| Paper manuscript | Writer + Proofreader |
| Peer review | Editor → Referee 1 + Referee 2 |
| Beamer talks | Storyteller + Discussant |
| Replication package | Verifier (submission mode) |
| Compilation only | Verifier (standard mode) |

## Parallel Dispatch

Independent phases run concurrently:
- Literature and Data discovery run in parallel
- Code and Paper execution run in parallel (after Strategy)
- Presentation can run parallel with Peer Review

## Limits

- **Worker-critic pairs:** max 3 rounds (then escalate)
- **Overall loop:** max 5 rounds
- **Verification retries:** max 2 attempts
- Never loop indefinitely

## Simplified Mode (R Scripts / Explorations)

For standalone R scripts, simulations, and explorations — use the simplified loop:

```
Plan approved → implement → run code → check outputs → score → done
```

No multi-agent reviews. Just: write, test, verify quality >= 80.

### Verification Checklist (Simplified)

- [ ] Script runs without errors
- [ ] All packages loaded at top
- [ ] No hardcoded absolute paths
- [ ] `set.seed()` once at top if stochastic
- [ ] Output files created at expected paths
- [ ] Quality score >= 80

## "Just Do It" Mode

When user says "just do it" / "handle it":
- Skip final approval pause
- Auto-commit if score >= 80
- Still run the full verify-review-fix loop
- Still present the summary
