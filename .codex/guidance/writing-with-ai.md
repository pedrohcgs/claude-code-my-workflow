---
paths:
  - "**/*.tex"
  - "**/*.md"
  - "**/*.md"
  - "**/*.Rmd"
---

# Writing with AI — what actually makes prose human-readable

Two different problems get confused, and conflating them wastes effort on the wrong one.

| Problem | What it is | What fixes it |
|---|---|---|
| **Readability** | the prose is hard to follow, hedged, padded, or generic | editing — and it is worth doing regardless of who wrote it |
| **Provenance** | the prose reads as *machine-generated* to a detector or a suspicious reader | **only genuine human rewriting**, plus disclosure |

`$humanize` addresses the first. **It cannot solve the second**, and this file exists so nobody
believes otherwise.

---

## The measured finding that shapes this rule

An article was polished through several rounds of surface-level de-AI-ing — em-dashes reduced,
"delve" removed, transitions varied, sentence lengths mixed. Submitted to **Pangram**, a neural
AI-text detector, it came back **100 % AI-written.**

**Why.** Detectors like Pangram are not looking for em-dashes or a cliché lexicon. They are
neural classifiers trained on the **token-level statistics of LLM generation itself** — the
word-choice probability patterns that persist through *any* transformation the model applies,
because **every transformation is still LLM-generated text.**

The consequence is uncomfortable and worth stating plainly:

> **A model cannot make its own output stop reading as model output.** Asking Codex to
> "make this sound more human" produces text that is differently-LLM, not less-LLM. The only
> thing that changes the underlying statistics is a **human writing the sentences.**

This is the same structural problem as a reviewer grading its own work, one layer down.

---

## What to do instead

### 1. Decide what the document is

- **Internal** — notes, session logs, plans, analysis scaffolding. AI-drafted is fine. Optimise
  for accuracy and speed; nobody is reading it for voice.
- **External-facing** — a paper, a referee report, a grant, a public guide, an
  email to a coauthor or editor. **Held to the human-readable standard below.**

Everything in `docs/`, `guide/`, a manuscript, or anything with your name on it going to
another person is external-facing.

### 2. For anything external-facing, the author writes the load-bearing prose

Use the model for structure, for a first pass on mechanical sections, for catching what you
left out — then **write the sentences that carry the argument yourself.** The abstract, the
introduction, the contribution paragraph, and the interpretation of results are where a reader
decides whether to trust you. They are also the cheapest places to write in your own voice,
because you already know what you mean.

### 3. Measure with a real detector; you are the oracle

If provenance matters — a journal with an AI-use policy, a public artifact, anything where
being flagged would cost you — **run the actual detector and iterate against the score.**

- The detector is a **tool you run**, not something an agent can simulate. Codex cannot
  estimate a Pangram score, and a guess is worse than no measurement because it feels like one.
- Iterate **page by page against measurements**, not against a model's impression of what
  sounds human.
- Report the score, the tool, and the version — a measurement without its instrument is an
  anecdote.

> **Do not use this to evade disclosure.** The point is prose a reader trusts and a voice that
> is yours, not defeating a classifier. If a venue requires an AI-use statement, make it —
> see [`$submission-disclosures`](../../.agents/skills/submission-disclosures/SKILL.md).

### 4. Surface tells are necessary, not sufficient

[`$humanize`](../../.agents/skills/humanize/SKILL.md) catches boilerplate transitions, the AI-cliché
lexicon, hedging stacks, symmetric paragraph shapes, and tricolon abuse. Fixing those genuinely
improves readability — a paragraph is better without *"It is important to note that"* whoever
wrote it.

But a clean `$humanize` report says the prose reads **well**. It does not say it reads
**human**. Those are different claims, and the second one requires a measurement.

**Detect-only, by design.** `$humanize` has no `--rewrite` mode: auto-rewriting degrades
quality and introduces new tells, and — per the finding above — cannot change what a neural
detector sees. The author edits. That manual step is the price of a voice.

---

## The human-readable standard for external documents

1. **A reader can state your contribution after one paragraph.** If not, the opening is doing
   ceremony rather than work.
2. **Sentences carry information, not throat-clearing.** Cut any sentence that survives being
   deleted.
3. **Hedges are load-bearing or absent.** *"May potentially suggest"* is one hedge too many;
   pick the one you mean.
4. **Claims match evidence in strength.** Pointwise is not uniform; illustrated is not
   validated; imposed is not derived. This is the same discipline as
   [`credible-claims`](../../.agents/skills/credible-claims/SKILL.md), applied to prose.
5. **The results section prints what goes against you** with the same prominence as the wins.
6. **Someone who is not you can read it aloud without stumbling.** Read it aloud yourself; the
   sentences you cannot say are the ones to rewrite.

---

## Cross-references

- [`$humanize`](../../.agents/skills/humanize/SKILL.md) — surface-tell detection (necessary, not sufficient)
- [`$proofread`](../../.agents/skills/proofread/SKILL.md) — grammar, typos, consistency
- [`$submission-disclosures`](../../.agents/skills/submission-disclosures/SKILL.md) — the AI-use statement for your venue
- [`credible-claims`](../../.agents/skills/credible-claims/SKILL.md) — never upgrade language beyond evidence
