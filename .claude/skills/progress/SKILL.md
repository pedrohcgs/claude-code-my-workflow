---
name: progress
description: Visual progress tracking during long orchestrator runs. Shows current phase, step, and elapsed time.
allowed-tools:
  - Read
  - Write
  - Bash
---

# Progress Tracking

Track and display progress during multi-step workflows (translation pipelines, deep audits, quality reviews, etc.).

## Usage

```
/progress          # Show current progress
```

## State File

Progress is tracked in `.claude/state/progress.json`:

```json
{
  "task": "Translate Lecture 7 to Quarto",
  "phase": "3/9",
  "phase_name": "Slide-by-slide translation",
  "step": "Frame 45/94",
  "started": "2026-04-07T14:00:00Z",
  "elapsed_min": 12,
  "status": "running",
  "signal": null,
  "last_update": "2026-04-07T14:12:00Z"
}
```

## Orchestrator Integration

The orchestrator updates progress at each phase transition:

| Phase | Label |
|-------|-------|
| Step 1 (IMPLEMENT) | "Implementing plan steps" |
| Step 2 (VERIFY) | "Compiling/rendering" |
| Step 3 (REVIEW) | "Running review agents" |
| Step 4 (FIX) | "Applying fixes" |
| Step 5 (RE-VERIFY) | "Re-compiling after fixes" |
| Step 6 (SCORE) | "Computing quality score" |

## Signals

| Signal | Meaning | Set By |
|--------|---------|--------|
| `null` | Normal operation | -- |
| `HOLD` | Paused, awaiting user input | Reviewer, quality gate |
| `BLOCK` | Hard failure, cannot proceed | Hook, compilation |
| `STOP` | User requested halt | User |

## How to Update (for skill/agent authors)

Write progress updates to `.claude/state/progress.json` using the Write tool. The state directory is gitignored.
