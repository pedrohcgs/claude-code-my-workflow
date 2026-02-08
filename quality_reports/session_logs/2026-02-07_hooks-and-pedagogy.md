# Session Log: Hooks, MEMORY.md, and Pedagogy Refinement

**Date:** 2026-02-07
**Goal:** Implement hooks from external resource analysis, then reevaluate landing page and guide for appeal/pedagogy.

## Completed

- Added `scripts/log-reminder.py` Stop hook (session log enforcement)
- Added Beamer-Quarto sync PostToolUse hook in `settings.json`
- Created `MEMORY.md` bootstrap for `[LEARN:tag]` persistence
- Added plan step 1.5 (check institutional memory)
- Consolidated landing page from 11 to 8 features, reordered for impact
- Smoothed hooks transition in guide, added appendix hooks table
- Updated README with hook documentation
- PR #7 merged to main

## Key Decisions

- Adopted 4 ideas from external resources (log hook, MEMORY.md, sync hook, plan step 1.5), skipped 9 (compound-docs, file todos, 29 agents, git-worktree, etc.)
- PostToolUse matcher is regex on tool name only; file path filtering done in prompt via `$ARGUMENTS`
- Landing page reorder: concrete deliverables (Beamer-to-Quarto) moved up, infrastructure details merged into parent features

## Bug Fix: Log Reminder Infinite Loop

The "no session log" case blocked every response indefinitely. Fixed by adding `no_log_reminded` flag — reminds once, then lets Claude work so it can actually create the log.

## Hook Audit: Simplification

Audited all hooks for latency, loops, and bad UX. Changes:

1. **Removed PostToolUse hook** — fired on every Edit/Write to check for .tex files. Cost: prompt evaluation on every file edit. Beamer-Quarto sync already enforced via auto-loaded rule.
2. **Removed prompt-based verification Stop hook** — fired an LLM call on every response. Cost: ~30s latency per response. Verification already enforced via rules + orchestrator step 2.
3. **Raised log-reminder threshold** from 8 to 15 — less nagging for new users.
4. **Added crash protection** — try/except in main() fails open, never blocks due to hook bugs.
5. **Added hook design principle to guide** — command hooks for mechanical checks, rules for nuanced judgment, avoid prompt hooks on hot paths.

Net result: from 2 Stop hooks + 1 PostToolUse hook → 1 Stop hook (command-based, fast).

## Open Questions

- None. Session work complete.
