# Dependency Graph (Rule 16)

**Phases activate by dependency, not sequence. Research is not a waterfall.**

## Phase Dependencies

| Phase | Requires | Can Re-enter? |
|-------|----------|---------------|
| Discovery | Research idea | Always — Librarian is persistent |
| Strategy | At least one of: literature review OR data assessment | Yes — new data or literature can trigger re-strategy |
| Execution (Code) | Approved strategy (Econometrician >= 80) | Yes — strategy revision triggers re-coding |
| Execution (Write) | Approved code (Debugger >= 80) | Yes — new results trigger rewriting |
| Peer Review | Approved paper (Proofreader >= 80) + approved code | Yes — major revisions loop back |
| Submission | Editor accepts + Verifier PASS + overall >= 95 | No — terminal |
| Presentation | Approved paper (can run parallel with Peer Review) | Yes — paper revisions trigger talk updates |

## How It Works

The Orchestrator checks the dependency graph before dispatching any agent. If a phase's inputs are satisfied, it can activate — regardless of whether earlier phases are "complete."

**Example — entering mid-pipeline:**
You already have data and a draft paper. You can enter at Strategy (skip Discovery) or even at Peer Review (skip Execution). The Orchestrator checks dependencies, not phase numbers.

**Example — targeted re-entry:**
Referee says "control for X." The Orchestrator routes back to Coder (not through the full pipeline), Debugger reviews, Writer updates, Proofreader reviews the update, then back to Referee.

## Parallel Activation

Independent phases run concurrently:
- Literature (Librarian + Editor) and Data (Explorer + Surveyor) run in parallel
- Code (Coder + Debugger) and Paper (Writer + Proofreader) run in parallel after Strategy
- Presentation can run parallel with Peer Review
