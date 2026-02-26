# Adversarial Pairing (Rule 1)

**Every worker agent has a paired critic. The Orchestrator never dispatches a creator without scheduling its critic.**

## Worker-Critic Pairs

| Worker (Creator) | Critic (Reviewer) | What's Reviewed |
|-----------------|-------------------|-----------------|
| Librarian | Editor | Literature coverage, gaps, recency |
| Explorer | Surveyor | Data feasibility, quality, identification fit |
| Strategist | Econometrician | Identification validity, assumptions, robustness |
| Coder | Debugger | Code quality, reproducibility, code-strategy alignment |
| Writer | Proofreader | Manuscript polish, LaTeX quality, hedging |
| Storyteller | Discussant | Talk structure, audience calibration, visual quality |

## Peer Review (Special Case)

Peer Review uses a different structure — the Editor dispatches two independent Referees:

1. Editor assigns the paper to Referee 1 and Referee 2 (blind, independent)
2. Both Referees produce scored reports
3. Editor synthesizes a decision: Accept / Minor Revisions / Major Revisions / Reject

## Enforcement

- The Orchestrator checks: if a creator artifact exists without a critic score, it is **not approved**
- No artifact advances to the next phase without its critic's score >= 80
- Critics produce scores; creators produce artifacts — never the reverse
