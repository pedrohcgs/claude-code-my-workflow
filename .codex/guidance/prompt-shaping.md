# Prompt Shaping (a standing habit, not a skill)

**When a request arrives informal, dictated, or ambiguous, shape it before you act on it — silently, in your head, every time.** This used to be a `$prompt` skill you had to invoke. In a loop-first workflow that ceremony is backwards: you should *always* be resolving a fuzzy ask into a clear one, not only when asked to. So it is a habit now, not a surface.

## The shape

Before executing a non-trivial informal request, resolve these five things (the sixth, the bookend, is for the *output*):

1. **Role** — whose expertise answers this? (econometrician, referee, researcher, data engineer)
2. **Task** — the single concrete deliverable, stated as a verb + object.
3. **Context** — which files, datasets, prior decisions, and constraints bear on it.
4. **Constraints** — what must hold (journal style, tolerance, reproducibility, no hardcoded paths).
5. **Output format** — exactly what to return (a report? a diff? a table? a plan?).
6. **Bookend** — restate the goal at the end and confirm it was met.

Full elaboration and examples: [`.codex/references/prompt-formatting-core.md`](../references/prompt-formatting-core.md).

## How to apply it

- **Mostly silent.** Resolve the shape and proceed; do not narrate a six-section preamble back to the user. The point is a better answer, not a visible form.
- **Surface only the genuine ambiguity.** If a *decision* is the user's to make (which journal? which estimator? overwrite or append?), ask it — briefly, via `AskUserQuestion` — instead of guessing. Everything else, infer and state your assumption in one line.
- **For multi-turn project specification** (a fuzzy research idea → a full spec), that is still a real skill: use [`$interview-me`](../../.agents/skills/interview-me/SKILL.md). Prompt-shaping is the single-shot habit; `$interview-me` is the conversation.

## Why this replaced `$prompt` and `$prompt-only` (v2.0)

The `$prompt` skills reformatted an informal ask into a six-section prompt — useful in 2023 when prompt-craft was the lever. In a goal-first, verification-gated workflow the lever is the *goal and the gates*, not the wording. Shaping is now ambient (this rule), and the reusable-artifact use case (`$prompt-only`) is served by saving a spec via `$interview-me` or a plan in `quality_reports/plans/`.

## Cross-references

- [`.codex/references/prompt-formatting-core.md`](../references/prompt-formatting-core.md) — the six-section elaboration.
- [`.agents/skills/interview-me/SKILL.md`](../../.agents/skills/interview-me/SKILL.md) — multi-turn specification (the surviving, heavier sibling).
- [`.codex/guidance/plan-first-workflow.md`](plan-first-workflow.md) — for non-trivial tasks, shaping feeds the plan.
