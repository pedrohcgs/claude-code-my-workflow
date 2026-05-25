---
name: prompt
description: Reformat an informal or dictated request into a structured prompt (Role / Task / Context / Constraints / Output format / Bookend) at Light / Standard / Deep depth, then execute it immediately. Use when user has a conversational ask that would benefit from being made specific before Claude runs it, or says "prompt", "structure this", "format this ask", "reshape this request", "make this rigorous". Single-shot input shaping — distinct from `/interview-me` (multi-turn project specification).
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[informal-text-or-pointer-to-text] [depth:light|standard|deep]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Task", "WebSearch", "WebFetch"]
---

<!-- Pattern adapted with attribution from Chris Blattman's claudeblattman v2.1
     (github.com/chrisblattman/claudeblattman, skills/prompt.md). Blattman-
     specific elements (tool-routing to ChatGPT / Perplexity / Gemini, the
     `council` token) are deliberately omitted; see
     .claude/references/prompt-formatting-core.md "What we don't ship". -->

# `/prompt` — format informal input into a structured prompt, then execute

Take an informal or dictated request, reformat it into a structured six-section prompt (Role / Task / Context / Constraints / Output format / Bookend) at the appropriate depth, **show the formatted prompt to the user**, and execute it.

## When to use

- The user dictates a long, meandering ask and wants a clean run.
- The request mentions specific domain terminology and would benefit from explicit Constraints + Output-format sections before execution.
- The user has tried an unformatted run and got a generic answer; reformatting before re-running is cheaper than iterating in dialogue.

## When NOT to use

- The request is already a clean, specific ask. Skip the formatter; run the request directly.
- The request is for a multi-turn project specification (hypotheses, identification strategy, data needs). Use [`/interview-me`](../interview-me/SKILL.md) instead.
- The request is for ad-hoc fact-checking. Use [`/verify-claims`](../verify-claims/SKILL.md).
- The request is a side question that shouldn't enter conversation history. Use the built-in `/btw` instead.

## How it works

### Step 1: Read the input

`$ARGUMENTS` is either the informal text itself or a pointer to a file containing it (`.md`, `.txt`, `.qmd`). If it's a file, read it. Strip a trailing `depth:light|standard|deep` token if present and record the override.

### Step 2: Calibrate depth

Default heuristic (from [`.claude/references/prompt-formatting-core.md`](../../references/prompt-formatting-core.md)):

- **Light** — input < 40 words, no domain-specific terminology, or explicit "quick" / "small".
- **Standard** — input 40–200 words, OR contains 1+ domain-specific terms (econometrics / political science / methods jargon).
- **Deep** — input > 200 words, OR mentions a specific paper / dataset / submission target, OR says "thorough" / "detailed" / "for submission".

User override (`depth:light|standard|deep`) is honoured.

### Step 3: Emit the formatted prompt

Use the structured-prompt skeleton from [`.claude/references/prompt-formatting-core.md`](../../references/prompt-formatting-core.md):

- **Light:** Role + Task + Output format + Bookend.
- **Standard:** All six sections + Assumptions/Rationale block (2–4 bullets).
- **Deep:** All six sections + Assumptions + Investigation pre-step (one sentence describing what Claude should research/read/verify before producing the output).

**Always show the formatted prompt to the user before executing.** Use a fenced code block. The user sees what you reshaped their ask into and can correct an inferred assumption with one message.

### Step 4: Execute the formatted prompt

Immediately after emitting the formatted prompt, **execute it** — run the request as if the user had typed the formatted version. Use the appropriate tools (Read, Grep, WebFetch, etc.) per the formatted prompt's Constraints.

If the formatted Bookend asked a clarifying question and the answer would change the output, surface that question first and wait for the answer.

### Step 5: Return the output

Standard prose, table, or code output per the formatted prompt's Output-format section.

## Boundary with `/interview-me`

`/prompt` is **input shaping** (single-shot). `/interview-me` is **project specification** (multi-turn Socratic). They don't compete — use `/prompt` when you want a well-formed ask; use `/interview-me` when you want a well-formed research project.

## Companion: `/prompt-only`

[`/prompt-only`](../prompt-only/SKILL.md) is the same skill **without** Step 4 — it emits the formatted prompt as a reusable artifact and stops. Use it when you want a prompt you'll run later (e.g., in a different conversation, against a different model, or as the basis for a recurring task).

## Anti-pattern

Do not run `/prompt` on a request that is already specific. If the user has already typed a six-section prompt manually, reformatting it via `/prompt` adds friction without value.

## Output

- The formatted prompt (visible in the conversation).
- The execution result (the answer to the formatted prompt's Task).
- Optionally: a one-sentence note if an Assumptions item turned out to be wrong during execution, so the user can correct for the next run.
