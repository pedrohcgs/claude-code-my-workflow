---
paths:
  - ".claude/agents/**/*.md"
  - ".claude/skills/**/SKILL.md"
---

# Per-Agent Model Routing (architect/editor split)

**Match model tier to the cognitive demand of the work.** Reserve Opus for high-judgment work; route mechanical work to Haiku; default review/critique to Sonnet. Anthropic's [Apr 8 2026 "Decoupling brain from hands"](https://www.anthropic.com/engineering) endorses this pattern; Aider's architect/editor split is the canonical community shape.

## The 70/20/10 routing pattern

| Share | Tier | Use for |
|---:|---|---|
| ~70% | **the Haiku tier** | Mechanical work — file renames, citation-format conversion, TikZ extraction, bib validation, proofread-fix application, simple grep / file lookups |
| ~20% | **the Sonnet tier** | Review and critique — `r-reviewer`, `slide-auditor`, `proofreader`, `quarto-fixer`, `humanize-auditor` |
| ~10% | **the Opus tier** | High-judgment work — `editor`, `methods-referee`, `domain-referee`, `claim-verifier`, `quarto-critic`, `tikz-reviewer`, `domain-reviewer`, `verifier` for non-trivial gates |

Set per-agent via `model:` in the agent's YAML frontmatter:

```yaml
---
name: quarto-fixer
model: sonnet      # was: inherit
---
```

Set per-skill via the same field in `SKILL.md` frontmatter. Inheritance is fine for skills whose work spans tiers (e.g., `/review-paper --peer` dispatches a mix).

## The effort axis (the first cost lever)

Model tier is the second cost lever; **effort is the first.** Every current model tier supports effort (`low / medium / high / xhigh / max` on all four) — and lowering effort is cheaper than dropping a tier: reach for it first.

Default effort differs by tier — the current defaults live in [`model-versions.md`](../references/model-versions.md) (at its 2026-11-04 verification: Opus and Haiku tiers **`medium`**, Sonnet and Fable tiers `high`). Two facts about the current Opus shape every pin, and both belong to that verification — re-read them when the SSoT changes:

- **Its `medium` matches or beats the prior Opus generation at `high`** on coding and knowledge work (Anthropic's own evaluations), and **at a given level it thinks more per turn** than that generation did. So pin above the default only where the extra thinking is the point.
- **Thinking is always on**; effort is the only depth control. To get less thinking, lower effort — do not add "think less" prose. To get more, raise effort — do not add "think harder" prose.

How the template pins effort:

- **Mechanical work** → the Haiku tier at `low` effort (`promote-memory-council` pins `effort: low`, one notch below the Haiku default of `medium`).
- **Review and judgment on the Sonnet tier** → `high` (its default).
- **Opus-tier gates where a false PASS is expensive** — `editor`, `domain-referee`, `methods-referee`, `claim-verifier` → `high`, deliberately one level above the default. These are the do-not-demote agents below; the extra thinking is what you are paying for.
- **Other Opus-tier agents** (`verifier`, `quarto-critic`, `tikz-reviewer`, `sim-reviewer`, `domain-reviewer`) → `medium`. Raise one only after `medium` measurably missed issues on your material.
- **Skills** pin `high` only for verification gates and correctness-critical computation (`/audit-reproducibility`, `/disclosure-check`, `/replication-package`, `/seven-pass-review`, `/r-package-check`, `/simulation-study`, `/diagnose`, `/power-analysis`). Writing and synthesis skills carry no pin and inherit the session. A handful of lightweight skills pin `medium` as a cost cap (`/syllabus`, `/scaffold-exercises`, `/coauthor-brief`, `/submission-disclosures`, `/data-management-plan`, `/triage-inbox`, `/capture-environment`, `/new-skill`). A skill's `effort:` *overrides* the session, so those `medium` pins also lower effort on tiers that default to `high` — intended for a cost cap, worth knowing if you run them on Sonnet or Fable.
- **The hardest runs** (deep refactors, the toughest `/review-paper --peer`) → `xhigh`; `ultracode` (xhigh + dynamic workflows) for repo-scale autonomous tasks. Reserve `max` for the rare case where you've verified `xhigh` was insufficient. `maxEffortLevel` in settings caps every surface — a useful ceiling on a fixed grant budget.

Set per skill/agent with the `effort:` frontmatter field. Match effort to the cognitive demand the same way you match model tier — and tune effort before you swap models.

## Where the Fable tier fits — and where it does not

The Fable tier is the most capable model in Claude Code, and this rule deliberately does **not** route any of the template's fleet to it. The reason is cost, and Anthropic's own routing advice agrees:

- **Cost discipline.** The Fable tier costs a multiple of the Opus per-token price (current figures in [`model-versions.md`](../references/model-versions.md)) on exactly the judgment tier the 70/20/10 split exists to guard. The referee/editor/verifier agents are bounded, single-sitting reviews; Fable is priced for *long-horizon, larger-than-one-sitting* autonomous work, which the fleet is not.
- **Anthropic's guidance** is to start with the current Opus for most workloads and move to Fable when evals at a higher Opus effort still fall short. For a fleet lens, raise that agent's effort first; move it to Fable only with a measured gap.

**Where the Fable tier *is* the right call:** your own interactive sessions on the hardest long-horizon work — a multi-day refactor, a deep research synthesis you'll steer by hand, a proof you are auditing line by line — where the task actually exploits the model's horizon. Select it per-session (`/model fable`); leave the fleet's `model:` pins alone.

**Cost reality check (grad-student budgets):** a full `/review-paper --peer` runs a meaningful fraction of a dollar-denominated token budget at Opus prices; moving the judgment tier to Fable multiplies that line item with no quality evidence yet. When cost-constrained, drop *effort* first (the first lever, above), then tier — never the reverse.

## Why this matters

Cost reduction on routed skills is typically **50–80%** with no quality loss on the mechanical tier. The cache-TTL change (5-min default in 2026; Claude subscriptions get 1-hour automatically, API keys opt in) made multi-turn pipelines on API keys materially more expensive; per-agent routing recovers that lost ground without sacrificing the high-judgment lens where it matters.

## Routing recipe per task type

### Mechanical (Haiku tier)

- **TikZ → SVG extraction** — if you delegate `/extract-tikz`'s compile-and-convert steps to an agent (the skill runs them inline today; its only agent, `tikz-reviewer`, is Opus-tier).
- **Bib formatting / citation rewrites** — if you add a fix path (`/validate-bib` is report-only and does not auto-fix).
- **Memory-promotion voting** (`promote-memory-council`).
- **Proofread fix application** (when the fix is "replace X with Y" mechanically).
- **File rename / search-and-replace operations.**

### Review / critique (Sonnet tier)

- **R code review** (`r-reviewer`).
- **Slide layout audit** (`slide-auditor`).
- **Proofread inspection** (`proofreader`).
- **Quarto fix application** when the fix is a `quarto-critic`-driven edit.
- **AI-voice audit** (`humanize-auditor`).
- **Beamer ↔ Quarto translation** (`beamer-translator`) — translation is bounded enough to live here unless the source TeX has unusual TikZ.

### High-judgment (Opus tier)

- **Editor for `/review-paper --peer`** (`editor`).
- **Both referee agents** (`domain-referee`, `methods-referee`).
- **Claim verifier in fresh-context mode** (`claim-verifier`).
- **Quarto critic** (`quarto-critic`) — adversarial parity QA needs the high-judgment lens to catch subtle visual drift.
- **TikZ reviewer** (`tikz-reviewer`) — measurement-rule enforcement requires precise spatial reasoning.
- **Domain reviewer** (`domain-reviewer`).
- **Verifier** (`verifier`) when gating non-trivial commits.

## When inheritance still makes sense

- A new agent you haven't profiled yet — start with `model: inherit`, run once, then route.
- An agent whose work spans tiers in the same invocation (rare; usually a sign the agent should be split).
- One-shot test agents you'll discard.

## Anti-pattern: pushing Opus down a tier

Do **not** demote `claim-verifier`, `methods-referee`, `domain-referee`, or `editor` to Sonnet to save cost. These are the agents that protect the paper from hallucinated citations / weak identification / desk-reject mistakes. The cost of one false-positive PASS from a too-cheap verifier is materially higher than the cost of running Opus on every paper.

## Anti-pattern: self-as-architect-and-editor pairing

Aider's pattern uses one model as both planner and executor. We deliberately do not — same-model self-pairings produce correlated errors. Our split runs **different tier** on architect (Opus) vs. editor (Haiku/Sonnet); the diversity is part of the cost story.

### Corollary: challenger ≠ auditor tier (guardrail, not a build)

If a future contributor ever adds an explicit *challenger → auditor* step (e.g., an "audit-then-score" / "ground truth is a process" verifier where one agent argues against a claim and a second adjudicates), the challenger **must** run on a different tier than the auditor — two same-tier LLMs share blind spots, so a same-tier challenger launders correlated errors as independent confirmation. This costs nothing to honor today; it exists so the diversity property isn't quietly lost when the split is built. **This is a constraint on a hypothetical future step, not a green light to build it** — the current verification path uses the cheaper EXPLAINED-with-named-alternative mechanism (see `replication-protocol.md` and `verify-claims`), which adds no second agent and no cost multiplier.

## How `/commit` uses this rule

`/commit` spawns the `verifier` agent, pinned to the Opus tier at `medium` effort: its checks are exit codes, counts, and file existence, which `medium` handles. Routing it to the Sonnet tier (Opus reserved for a `--strict` mode) is a reasonable next step once measured on your commits.

## Cross-references

- [`.claude/rules/cross-artifact-review.md`](cross-artifact-review.md) — paper ↔ code dependency graph (orthogonal to routing but invoked at similar moments).
- [`.claude/rules/post-flight-verification.md`](post-flight-verification.md) — CoVe / fresh-context verifier (claim-verifier should stay on Opus per "anti-pattern: pushing Opus down" above).
- Guide section "Cost-Conscious Composition" — user-facing cost guidance that points at this rule.

> **Tiers, not point versions.** This rule names tiers (`Haiku` / `Sonnet` / `Opus` / `Fable`) on purpose. Current point versions and provider-dependent alias resolution live in the single source of truth: [`model-versions.md`](../references/model-versions.md). Do not hard-code a point version here.
