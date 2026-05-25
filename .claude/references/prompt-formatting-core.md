# Prompt-Formatting Core (shared reference)

Used by `/prompt` and `/prompt-only`. Defines the **structured-prompt skeleton** and the **depth-calibration heuristic** that both skills emit.

> Pattern adapted with attribution from Chris Blattman's [`claudeblattman` v2.1](https://github.com/chrisblattman/claudeblattman) (`skills/prompt-references/formatting-core.md`). Blattman-specific elements (tool-routing to ChatGPT / Perplexity / Gemini, the `council` token that dispatches to his `/council` skill) are deliberately omitted — see this file's "What we don't ship" section.

---

## The structured-prompt skeleton

Every formatted prompt has six sections, in order. Some are optional at Light depth; all are present at Standard and Deep.

### 1. Role

One sentence naming the role Claude should adopt. Specific over generic.

- Generic (bad): "You are a helpful assistant."
- Specific (good): "You are a senior economics referee for *Journal of Public Economics*, calibrated to its identification-credibility bar."

The role anchors the rest of the prompt; everything that follows is interpreted relative to it.

### 2. Task

One imperative sentence describing what to produce. Verb-first.

- Bad: "I'd like you to maybe think about whether we could possibly..."
- Good: "Identify the three weakest steps in this paper's identification strategy."

### 3. Context

Brief grounding: what the user is working on, what's already known, what the agent should assume vs. ask about. Bulleted; ~5–8 items max at Standard depth.

For academic contexts, useful items:

- The paper's main contribution (one sentence).
- The methodological tradition (reduced-form / structural / formal-theory / etc.).
- The target audience for the output (referee / co-author / student).
- Anything the user has already verified or ruled out.

### 4. Constraints

What the output MUST and MUST NOT do. Numbered if more than three. Bias toward MUST NOT — the absences are usually more informative than the presences.

- "MUST NOT recommend instrumental variables — the user has already considered and ruled out IV."
- "MUST return findings as a numbered list with severity tags (CRITICAL / IMPORTANT / MINOR)."

### 5. Output format

Concrete shape of the output. The more specific, the better.

- Bad: "Give me a thorough analysis."
- Good: "Return a Markdown table with columns: Finding, Severity, Why-it-matters, Suggested-fix. One row per finding, max 10 rows."

### 6. Bookend

The closing instruction. Almost always: "If anything in the above is ambiguous, ask one clarifying question before proceeding."

The bookend is what catches the cases where the prompt was almost-but-not-quite specific enough. Without it, Claude guesses; with it, you get one focused question that improves the rest of the run.

---

## Depth calibration

`/prompt` accepts a `depth:` override (`light` / `standard` / `deep`). The depth heuristic picks a default when the user doesn't specify.

### Light (default)

- Heuristic: input is conversational (< 40 words) and contains no domain-specific terminology, OR explicitly says "quick", "just", "small".
- What you emit: Role + Task + Output Format (+ Bookend). Skip Context and Constraints.
- Use case: "Reword this paragraph for clarity." / "What's a good R package for X?"

### Standard

- Heuristic: input is 40–200 words OR contains 1+ domain-specific terms (econometrics / political science / methods jargon).
- What you emit: All six sections. Add an **Assumptions/Rationale** block at the end — "Here's what I inferred from the context; correct me if any of this is wrong." Two to four bullet points.
- Use case: "Help me think through the identification strategy for this RD paper."

### Deep

- Heuristic: input is > 200 words, OR mentions a specific paper / dataset / submission target, OR explicitly says "thorough", "detailed", "for submission".
- What you emit: All six sections + Assumptions block + an **Investigation pre-step** before the main task. The pre-step is one sentence describing what Claude should research / read / verify before producing the output. Example: "Pre-step: read the Methods section of [paper] and identify the assumption set actually invoked before assessing whether the paper's main claim follows."
- Use case: "Draft a referee response to the three concerns in this R&R."

### When to override

If the user types `depth:light` / `depth:standard` / `depth:deep`, honor it. The heuristic is a sensible default, not a contract.

---

## Worked example

**Input (conversational, dictated):**

> "ok so this referee says my identification doesn't work because of measurement error in the treatment variable. i think they're wrong because the measurement error is classical and would just attenuate the coefficient toward zero, but i want to write a clean response that doesn't pick a fight. help me draft it."

**Depth inference:** Standard (input is ~50 words, mentions specific econometrics concept "classical measurement error", and asks for a response document, not a quick reword).

**Formatted prompt (Standard, all six sections + Assumptions):**

```
Role
----
You are an applied econometrician drafting a response to a referee's
methods concern. The tone is firm but respectful — you neither concede
unnecessarily nor escalate.

Task
----
Draft a 1-paragraph response to the referee's claim that classical
measurement error in the treatment variable undermines identification.

Context
-------
- The treatment variable is mismeasured but the error is plausibly
  classical (mean-zero, independent of the true treatment and outcome).
- Standard econometrics: classical measurement error in the
  right-hand-side variable attenuates the OLS coefficient toward zero.
- The author's existing estimates are statistically significant; they
  argue the attenuated estimate represents a lower bound on the true
  effect.
- The R&R policy is one revision; we cannot afford to escalate.

Constraints
-----------
1. MUST cite the attenuation result with a textbook reference (e.g.,
   Wooldridge 2010, Cameron & Trivedi 2005).
2. MUST NOT concede the identification critique unconditionally.
3. MUST acknowledge the referee's concern as legitimate before
   responding to it.
4. SHOULD propose one robustness check (e.g., IV using a plausibly
   exogenous instrument for treatment intensity) as a "we agree this
   is worth showing" gesture.

Output format
-------------
A single paragraph of 5-8 sentences in this structure:
1. Acknowledge the concern.
2. State the classical-ME framework.
3. Cite the attenuation result.
4. Reframe the existing estimates as a lower bound.
5. Optionally: propose the IV robustness check.

Bookend
-------
If anything above is ambiguous, ask one clarifying question before
drafting.

Assumptions
-----------
- Measurement error is in the treatment, not the outcome.
- The referee is a methods skeptic, not a structural-modeling
  fundamentalist (no need to refute structural alternatives).
- Wooldridge 2010 is the preferred textbook citation; substitute if
  the author cites a different one elsewhere.
- The paper's contribution is reduced-form; we're not switching to a
  structural model in revision.
```

Notice the assumptions block. If any of those four assumptions are wrong, the user corrects them in one message and we re-emit — much cheaper than running the unformatted prompt and discovering the misalignment downstream.

---

## What we don't ship (intentionally)

Blattman's original `/prompt` includes:

- A **tool-routing table** that suggests dispatching to ChatGPT / Perplexity Deep Research / Gemini when those tools serve the task better. This bakes in a multi-vendor workflow not every academic forker maintains. If a user wants tool routing, they add their own table to this file.
- A **`council` token** that dispatches the formatted prompt to Blattman's `/council` skill (his five-critic multi-model deliberation). This template doesn't ship `/council` — we have `/seven-pass-review` and `/devils-advocate` instead, which serve adjacent purposes but with different shapes. If you want the council pattern, see Pass 3 item H (`/promote-memory` five-critic council) — that's a closer fit for the template.

If you fork this template and add your own multi-vendor or multi-model fan-out, extend this file with your routing rules. Keep them in this reference, not in the SKILL.md, so `/prompt` and `/prompt-only` stay aligned.

---

## Boundary with `/interview-me`

`/prompt` is **single-shot input shaping** — one informal request becomes one formatted prompt. The output is the prompt (`/prompt-only`) or the prompt + its first execution (`/prompt`). There is no multi-turn elaboration.

`/interview-me` is **multi-turn project specification** — a fuzzy research idea becomes a structured research spec (RQ, hypotheses, identification strategy, data needs, empirical strategy) via Socratic Q&A. The output is a spec file used by `/preregister`, `/research-ideation`, `/data-analysis`, etc.

They don't compete. Use `/prompt` when you want a well-formed ask. Use `/interview-me` when you want a well-formed research project. The former takes 30 seconds; the latter takes 10–20 minutes.
