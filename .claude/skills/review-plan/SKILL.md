---
name: review-plan
description: >
  Stress-test a plan with structured expert critique, best-practice research,
  and subagent review. Use when reviewing, critiquing, or pressure-testing any
  plan, strategy, proposal, or project outline. Also use when the user asks to
  find gaps, blind spots, or weaknesses in a plan. Covers research plans,
  project proposals, implementation plans, grant applications, and strategic
  roadmaps.
disable-model-invocation: true
argument-hint: "[file] [--role X] [--focus dimension] [--depth quick|standard|deep] [--interactive]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task", "WebSearch"]
---

# Plan review

Produce a rigorous, multi-dimensional critique of a plan---the kind of
stress-test a skeptical expert panel would deliver.

---

## Flags

Parse `$ARGUMENTS` for these flags (all optional):

| Flag | Default | Purpose |
|------|---------|---------|
| (positional) | most recent plan in `quality_reports/plans/` | File path to the plan |
| `--role` | inferred from domain | Override the expert reviewer persona |
| `--focus` | all dimensions | Restrict review to one dimension |
| `--depth quick` | `standard` | Quick = top issues only; deep = subagent + web research |
| `--interactive` | off | Conversation mode instead of report |

---

## Steps

### 1. Locate and read the plan

Check in order:
- Direct path from arguments
- `quality_reports/plans/[argument]`
- Most recent `.md` in `quality_reports/plans/`

### 2. Infer the expert reviewer role

From the plan's domain, adopt a specific expert persona (e.g., "senior
development economist" for a research plan on poverty interventions, "staff
engineer" for a systems migration plan, "grant committee reviewer" for a
funding proposal). If `--role` is provided, use that instead. State the
adopted role at the top of the review.

### 3. Research best practices (unless `--depth quick`)

Use `WebSearch` to find current best practices, common pitfalls, and standard
frameworks for the plan's domain. Feed findings into the best-practice
alignment dimension.

### 4. Launch subagent for the critique (preferred)

To avoid bias from having helped write the plan, **prefer launching a Task
agent** (subagent_type `general-purpose`) to perform the six-dimension
evaluation. Pass the subagent:
- The full plan text
- The inferred role
- The six evaluation dimensions (below)
- Any web research results
- The focus dimension if `--focus` was set

If subagent launch is impractical (e.g., plan is short, `--depth quick`), do
the critique directly.

### 5. Synthesize and produce report

Combine subagent output (or direct analysis) into the output format below.
Save to `quality_reports/plan_review_[sanitized_name].md`.

### 6. Iteration gate

End the review by asking the user:

> Ready to proceed? Options:
> 1. Apply the recommended revisions to the plan
> 2. Dive deeper into a specific dimension
> 3. Re-review after manual edits
> 4. Accept the plan as-is

Do not proceed without an explicit choice.

---

## Interactive mode (`--interactive`)

1. Read the plan and infer role.
2. Identify the 2--3 weakest dimensions.
3. Ask 1--2 probing questions about the first weakness. Wait for a response.
4. Probe deeper or move to the next weakness based on the answer.
5. After covering all major issues, summarize findings and offer to write the
   full structured report.

---

## Six evaluation dimensions

### 1. Pre-mortem

Imagine the plan failed completely 3 months from now. Identify the top 3 most
likely causes of failure. For each cause: why it's plausible, what early
warning signs to watch for, and what would prevent it.

### 2. Completeness

What's missing that a domain expert would expect? Check for: unstated
assumptions, missing stakeholders, unaddressed edge cases, gaps in the
timeline, and absent success/failure criteria.

### 3. Feasibility

Which steps depend on unconfirmed resources, approvals, or external factors?
Flag anything that requires: permissions not yet granted, tools not yet
available, skills the team may lack, or timelines that assume no friction.

### 4. Best-practice alignment

How does the plan compare to current best practices found in the web search
step? Are there standard frameworks, methodologies, or checklists the plan
should reference? Does the plan deviate from norms in ways that are deliberate
or accidental?

### 5. Sequencing

Are there hidden blockers or dependencies between steps? Would reordering
reduce risk or surface problems earlier? Identify any steps that should be
parallelized, any that gate everything downstream, and any that are ordered
by habit rather than necessity.

### 6. Specificity

Could someone unfamiliar with the project execute each step without guessing?
Flag vague verbs ("coordinate with," "ensure that," "look into"), missing
quantities, undefined deliverables, and steps that require tacit knowledge
not captured in the plan.

---

## Output format (structured report)

```markdown
# Plan review: [Plan title]

**Date:** [YYYY-MM-DD]
**Reviewer role:** [Inferred or overridden role]
**Plan type:** [Research / Proposal / Implementation / Strategy / Hybrid]
**File:** [path]
**Depth:** [Quick / Standard / Deep]

## Summary verdict

**Overall assessment:** [Strong / Solid / Needs work / Significant concerns]

[2--3 paragraph summary: what the plan does well, where it's vulnerable, and
the single most important thing to fix.]

## Strengths

1. [Strength with specific reference]
2. [Strength with specific reference]
3. [Strength with specific reference]

## Pre-mortem: top 3 failure scenarios

### F1: [Failure scenario]
- **Likelihood:** [High / Medium / Low]
- **Early warning:** [What to watch for]
- **Prevention:** [Concrete action]

### F2: [Failure scenario]
[Same structure]

### F3: [Failure scenario]
[Same structure]

## Issues by dimension (ranked by severity)

### [CRITICAL] [Title] --- [Dimension]
- **Problem:** [Specific description]
- **Why it matters:** [Consequence if unaddressed]
- **Recommendation:** [Concrete fix]
- **Location:** [Section/step if applicable]

### [HIGH] [Title] --- [Dimension]
[Same structure]

### [MEDIUM] [Title] --- [Dimension]
[Same structure]

[Continue for all issues]

## Best-practice alignment

[Summary of web research: how does the plan compare to standard approaches?
Common pitfalls in this domain that the plan does/doesn't address.]

## Dimension scores

| Dimension | Score (1--5) | Key issue |
|-----------|-------------|-----------|
| Pre-mortem preparedness | [N] | [One-liner] |
| Completeness | [N] | [One-liner] |
| Feasibility | [N] | [One-liner] |
| Best-practice alignment | [N] | [One-liner] |
| Sequencing | [N] | [One-liner] |
| Specificity | [N] | [One-liner] |
| **Overall** | **[N]** | |

## Recommended revisions

1. [Most important fix --- which dimension it addresses]
2. [Second priority]
3. [Third priority]
```

**Iteration gate:** After presenting the report, ask the user whether to
apply revisions, dive deeper, re-review, or accept.

---

## Depth levels

| Level | Web search | Subagent | Scope |
|-------|-----------|----------|-------|
| `quick` | No | No | Top 3 issues + pre-mortem only |
| `standard` | Yes | Yes (preferred) | All 6 dimensions |
| `deep` | Yes | Yes (required) | All 6 dimensions + dedicated subagents per dimension |

---

## Principles

- **Be adversarial, not hostile.** The goal is to make the plan stronger.
- **Prefer subagent critique** to avoid anchoring on your own prior work.
- **Rank issues by severity.** Separate fatal flaws from polish items.
- **Be specific.** Reference exact sections, steps, and assumptions.
- **Offer fixes, not just complaints.** Every issue gets a recommendation.
- **State your role.** The expert persona grounds the critique in
  domain-appropriate expectations.
- **Do NOT fabricate evidence.** If web research is inconclusive, say so.
