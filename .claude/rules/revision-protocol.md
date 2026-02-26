# Revision Protocol — R&R Cycle (Rule 18)

**When referee reports arrive, `/respond-to-referee` classifies each comment and routes it to the right agent.**

## Comment Classification

| Classification | What It Means | Routed To |
|---------------|---------------|-----------|
| **NEW ANALYSIS** | Requires new estimation or data work | Coder → Debugger |
| **CLARIFICATION** | Text revision sufficient | Writer → Proofreader |
| **DISAGREE** | Diplomatic pushback needed | Flagged for User review |
| **MINOR** | Typos, formatting | Writer |

## The R&R Flow

```
Referee reports arrive (real, not simulated)
        │
        ▼
   /respond-to-referee classifies each comment
        │
        ├── NEW ANALYSIS → Coder → Debugger → Writer updates
        ├── CLARIFICATION → Writer → Proofreader
        ├── DISAGREE → User decides → diplomatic response drafted
        └── MINOR → Writer
        │
        ▼
   Revised paper → Proofreader → Editor re-checks
        │
        ▼
   Response letter produced
```

## Rules

- This uses the same agents but in a targeted way — not a full pipeline restart
- Each comment gets its own routing — a single referee report may trigger multiple agent pairs
- The response letter maps each referee comment to the specific change made
- DISAGREE items are always flagged for user review — Claude never autonomously pushes back on referees
- The Orchestrator tracks which comments are resolved and which are pending
