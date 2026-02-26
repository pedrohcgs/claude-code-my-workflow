# Standalone Access (Rule 17)

**Any skill can be invoked directly, bypassing the pipeline.**

## Two Modes

### Mode 1: Orchestrated (within the pipeline)

The Orchestrator dispatches agents through the dependency graph. The user says:

> "I want to study the effect of minimum wage on employment using CPS data."

The Orchestrator activates Discovery → Strategy → Execution → Peer Review automatically.

### Mode 2: Standalone (direct access)

The user invokes a skill directly:

> `/econometrics-check Paper/main.tex`

This runs the Econometrician agent alone, right now, no phase dependencies.

## Why Both Modes

- **Pipeline mode** is for full projects where the Orchestrator manages the flow
- **Standalone mode** is for targeted tasks: "just check this one thing"
- Most users start with standalone skills and graduate to the pipeline

## Standalone Skills

All skills marked "Standalone: Yes" in the skills reference work without pipeline context. They dispatch their agent(s) directly and return results.

## Constraint

`/new-project` is the only skill that is always orchestrated — it exists to launch the full pipeline. Everything else can run standalone.
