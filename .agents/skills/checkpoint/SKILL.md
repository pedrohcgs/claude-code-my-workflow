---
name: checkpoint
description: Save a structured repository checkpoint for a pause or handoff, capturing the active goal, decisions, file pointers, open questions, validation evidence, and next actions. Use only when explicitly invoked with $checkpoint.
---

# Repository checkpoint

Write `quality_reports/checkpoints/YYYY-MM-DD_<topic>.md`. Use repository and conversation evidence; do not depend on private runtime memory.

Include:

- goal and success criteria;
- completed work and validation receipts;
- decisions and rejected alternatives;
- exact file pointers, preferably with line numbers;
- unresolved questions and blockers;
- the next one to three actions;
- current `git status --short` without staging or committing.

Separate verified facts from assumptions. Never copy secrets or large source excerpts. If an existing checkpoint for the topic exists, create a dated successor and link it rather than overwriting history. Optionally propose concise `[LEARN:<category>]` entries for repository `MEMORY.md`; do not add them without explicit approval.

