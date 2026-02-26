# Three Strikes Escalation (Rule 7)

**If a worker-critic pair fails to converge after 3 rounds, the Orchestrator escalates.**

## The Protocol

```
Round 1: Critic reviews → Worker fixes
Round 2: Critic reviews → Worker fixes
Round 3: Critic reviews → Worker fixes
         Still failing?
              ↓
         ESCALATION
```

## Escalation Routing

| Pair | Escalation Target | What Happens |
|------|-------------------|--------------|
| Coder + Debugger | Econometrician | Re-evaluates whether the strategy memo is implementable |
| Writer + Proofreader | Editor | Structural rewrite, not just polish |
| Strategist + Econometrician | User | Fundamental design question — needs human judgment |
| Librarian + Editor | User | Scope disagreement — user decides breadth vs depth |
| Explorer + Surveyor | User | Data feasibility deadlock — user decides resource trade-offs |
| Storyteller + Discussant | User | Talk scope/format disagreement |

## Rules

- **Max 3 rounds per pair per invocation** — no infinite loops
- **Escalation is logged** in the research journal with strike count
- **User escalation requires a clear question** — not "they disagree," but "Econometrician requires X, which contradicts Y. Which takes priority?"
- **Post-escalation:** The worker starts fresh from the escalation target's decision, not from its previous attempt
