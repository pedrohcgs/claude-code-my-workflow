---
name: prompt-only
description: Reformat an informal or dictated request into a structured prompt (Role / Task / Context / Constraints / Output format / Bookend) and emit it as a reusable artifact — does NOT execute. Companion to `/prompt`. Use when user says "format this prompt", "give me a clean version of this ask", "save this prompt for later", "I want a reusable prompt", or wants a prompt to use elsewhere (different model, different conversation, recurring task).
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[informal-text-or-pointer-to-text] [depth:light|standard|deep] [--save path]"
allowed-tools: ["Read", "Write", "Glob"]
---

<!-- Pattern adapted with attribution from Chris Blattman's claudeblattman v2.1
     (github.com/chrisblattman/claudeblattman, skills/prompt-only.md).
     Blattman-specific elements omitted; see
     .claude/references/prompt-formatting-core.md "What we don't ship". -->

# `/prompt-only` — format input into a structured prompt without executing

Same six-section skeleton as [`/prompt`](../prompt/SKILL.md), but **does not execute**. Returns the formatted prompt as a reusable artifact.

## When to use

- You want a prompt you'll run later — in a different conversation, against a different model, or as the basis for a recurring task.
- You're drafting a prompt template (e.g., for a future skill, a co-author, a teaching exercise).
- The execution itself should happen elsewhere (a long batch, a different tool, an offline workflow).

## When NOT to use

- You want the formatted prompt run immediately. Use [`/prompt`](../prompt/SKILL.md).
- You want a research project formalised. Use [`/interview-me`](../interview-me/SKILL.md).

## How it works

### Step 1: Read the input

`$ARGUMENTS` is the informal text or a pointer to a file. Strip a trailing `depth:` token and `--save` if present.

### Step 2: Calibrate depth

Same heuristic as `/prompt` (see [`.claude/references/prompt-formatting-core.md`](../../references/prompt-formatting-core.md)):

- Light: < 40 words, no domain jargon, "quick" / "small".
- Standard: 40–200 words, or 1+ domain-specific terms.
- Deep: > 200 words, or specific paper/dataset/submission mentioned, or "thorough" / "for submission".

User override honoured via `depth:light|standard|deep`.

### Step 3: Emit the formatted prompt

Use the six-section skeleton from [`.claude/references/prompt-formatting-core.md`](../../references/prompt-formatting-core.md):

- Light → Role + Task + Output format + Bookend.
- Standard → All six + Assumptions block.
- Deep → All six + Assumptions + Investigation pre-step.

Output the formatted prompt **in a fenced code block** so the user can copy it cleanly.

### Step 4 (optional): Save

If `--save <path>` was supplied, write the formatted prompt to that path. If the path is a directory, default the filename to `quality_reports/prompts/YYYY-MM-DD_<slug>.md`. The slug is derived from the first ~8 words of the Task section.

### Step 5: Return

Standard output:

- The formatted prompt in a code block.
- If saved: a one-line "saved to <path>" confirmation.

**No execution.** That's the whole point.

## Boundary

`/prompt-only` is for **reusable prompt artifacts**. It does not produce the output of the prompt — that's `/prompt`'s job (single-run) or your job (when you run the saved prompt elsewhere).

## Anti-pattern

Do not use `/prompt-only` when you want immediate execution. The friction of "format then run separately" is wasteful in interactive contexts. Reach for `/prompt` instead.

## Output

- The formatted prompt (fenced code block).
- Optionally: "saved to <path>" confirmation.
- No execution result.
