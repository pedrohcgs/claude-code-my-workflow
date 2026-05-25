---
name: interview-me
description: Interactive interview that formalizes a fuzzy research idea into a structured spec (RQ, hypotheses, identification, data needs, empirical strategy). Use when user says "interview me", "help me think through this idea", "I have a half-baked idea", "formalize this into a project", "walk me through framing a study". Multi-turn Q&A; saves spec to disk. NOT for lit review (`/lit-review`) or ideation from scratch (`/research-ideation`).
argument-hint: "[brief topic or 'start fresh'] [--no-verify]"
allowed-tools: ["Read", "Write", "Task"]
---

# Research Interview

Conduct a structured interview to help formalize a research idea into a concrete specification.

**Input:** `$ARGUMENTS` — a brief topic description or "start fresh" for an open-ended exploration.

---

## How This Works

This is a **conversational** skill. Instead of producing a report immediately, you conduct an interview by asking questions one at a time, probing deeper based on answers, and building toward a structured research specification.

**Do NOT use AskUserQuestion.** Ask questions directly in your text responses, one or two at a time. Wait for the user to respond before continuing.

---

## Interview Structure

### Phase 1: The Big Picture (1-2 questions)
- "What phenomenon or puzzle are you trying to understand?"
- "Why does this matter? Who should care about the answer?"
- After the user answers, optionally ask: "Do you have a sense of what *kind* of paper this would be — reduced-form / structural / theory+empirics / descriptive / formal-theory / survey-experiment / unsure?" (See `.claude/agents/methods-referee.md` for the type definitions and `.claude/references/discipline-cards.md` for field-default frequencies.) Record the answer in the saved spec under the `**Paper type:**` header field; "unsure" is fine and is recorded as `**Paper type:** unsure`.

### Phase 2: Theoretical Motivation (1-2 questions)
- "What's your intuition for why X happens / what drives Y?"
- "What would standard theory predict? Do you expect something different?"

### Phase 3: Data and Setting (1-2 questions)
- "What data do you have access to, or what data would you ideally want?"
- "Is there a specific context, time period, or institutional setting you're focused on?"

### Phase 4: Identification (1-2 questions)
- "Is there a natural experiment, policy change, or source of variation you can exploit?"
- "What's the biggest threat to a causal interpretation?"

### Phase 5: Expected Results (1-2 questions)
- "What would you expect to find? What would surprise you?"
- "What would the results imply for policy or theory?"

### Phase 6: Contribution (1 question)
- "How does this differ from what's already been done? What's the gap you're filling?"

---

## After the Interview

Once you have enough information (typically 5-8 exchanges), produce a **Research Specification Document**:

```markdown
# Research Specification: [Title]

**Date:** [YYYY-MM-DD]
**Researcher:** [from conversation context]
**Paper type:** [reduced-form | structural | theory+empirics | descriptive | formal-theory | survey-experiment | unsure]

## Research Question

[Clear, specific question in one sentence]

## Motivation

[2-3 paragraphs: why this matters, theoretical context, policy relevance]

## Hypothesis

[Testable prediction with expected direction]

## Empirical Strategy

- **Method:** [e.g., Difference-in-Differences with staggered adoption]
- **Treatment:** [What varies]
- **Control:** [Comparison group]
- **Key identifying assumption:** [What must hold]
- **Robustness checks:** [Pre-trends, placebo tests, etc.]

## Data

- **Primary dataset:** [Name, source, coverage]
- **Key variables:** [Treatment, outcome, controls]
- **Sample:** [Unit of observation, time period, N]

## Expected Results

[What the researcher expects to find and why]

## Contribution

[How this advances the literature — 2-3 sentences]

## Open Questions

[Issues raised during the interview that need further thought]
```

**Save to:** `quality_reports/research_spec_[sanitized_topic].md`

---

## Post-Flight Verification (mandatory, CoVe — applies when the spec cites prior work)

The research spec's **Motivation** and **Contribution** sections typically reference prior papers by author + year. Those citations are hallucination-prone. Before saving the spec, run the Post-Flight Verification protocol from [`.claude/rules/post-flight-verification.md`](../../rules/post-flight-verification.md) if the spec contains any citations.

### Steps (skip if the spec cites zero papers)

1. **Extract claims:** every paper-citation in the Motivation / Contribution sections ("Smith 2019 shows X"), any dataset-structure claims ("the CPS has field `educ_attain`"), any negative-literature assertions ("nobody has studied Y").
2. **Generate verification questions:** specific, answerable questions per claim. "Does Smith (2019, *JEL*) Section 3 report finding X? Is the venue correct?"
3. **Spawn `claim-verifier`** via `Task` with `subagent_type=claim-verifier` and `context=fork`. Hand it the claims + questions + source pointers (DOIs, arXiv links, `master_supporting_docs/` PDFs if the user provided any during the interview). Do NOT include the drafted spec.
4. **Reconcile:** PASS → attach green block to the spec. PARTIAL → mark unverifiable citations with uncertainty flags. FAIL → rewrite the affected paragraph using the verifier's evidence before saving the spec.

### Skip conditions

- Spec contains zero paper citations (pure-methodology specs with no lit references).
- `--no-verify` flag.
- The user explicitly said during the interview "I'll verify the literature myself."

---

## Decision records (when tradeoffs surface)

If during the interview the researcher explicitly chose among alternatives — identification strategy (DiD vs IV vs RDD), data source (admin vs survey), outcome measure, sample scope, etc. — also write an ADR-style **decision record** for each choice. Use [`templates/decision-record.md`](../../../templates/decision-record.md) and save to `quality_reports/decisions/YYYY-MM-DD_[short-topic].md`. Required fields: Status / Problem / Options considered / Decision + rationale / Consequences / Rejected alternatives.

Skip the ADR if the interview produced a single uncontested direction — ADRs are for *decisions with live alternatives*, not for announcing the default path.

---

## Interview Style

- **Be curious, not prescriptive.** Your job is to draw out the researcher's thinking, not impose your own ideas.
- **Probe weak spots gently.** If the identification strategy sounds fragile, ask "What would a skeptic say about...?" rather than "This won't work because..."
- **Build on answers.** Each question should follow from the previous response.
- **Know when to stop.** If the researcher has a clear vision after 4-5 exchanges, move to the specification. Don't over-interview.
