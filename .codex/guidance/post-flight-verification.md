---
paths:
  - ".agents/skills/lit-review/SKILL.md"
  - ".agents/skills/research-ideation/SKILL.md"
  - ".agents/skills/respond-to-referees/SKILL.md"
  - ".agents/skills/review-paper/SKILL.md"
  - ".agents/skills/interview-me/SKILL.md"
alwaysApply: false
---

# Post-Flight Verification (anti-hallucination)

Symmetric partner to **Pre-Flight Reports** (`.codex/guidance/content-invariants.md` + skill-level `## Phase 0`). Where Pre-Flight proves inputs were read *before* work, Post-Flight proves the output's factual claims hold *after* drafting — before the skill returns to the user.

**Adapted from:** Dhuliawala et al. 2023, "Chain-of-Verification Reduces Hallucination in Large Language Models" ([arXiv:2309.11495](https://arxiv.org/abs/2309.11495)). The **independence trick** — answer verification questions in a context that does not contain the original draft — is architecturally enforced here by running `claim-verifier` via the `Agent` tool with `context: fork`. The forked agent literally cannot self-confirm; it has never seen the draft.

## When this rule applies

Any skill whose output contains **factual claims that can be independently verified** against a source:

| Skill | High-risk claim types |
|-------|----------------------|
| `$lit-review` | Citations (paper exists, authors, year, venue); paraphrased claims ("Smith 2019 finds X") |
| `$research-ideation` | "Has anyone tested this?" negative-literature claims; dataset structure claims; estimator feasibility claims |
| `$respond-to-referees` | "We added X on page Y" assertions about actual revisions |
| `$review-paper` (`--peer` mode) | Novelty-probe claims from WebSearch ("this paper's contribution is novel" / "similar to Jones 2020") |
| `$interview-me` | Papers referenced in the research spec (if any cited) |

Does **not** apply to mechanical skills (`$compile-latex`, `$deploy`, `$extract-tikz`, `$commit`) — they produce compiled output verified by external processes (the compiler), not factual text.

## The 4-step CoVe protocol

### Step 1 — Draft (the skill's normal output generation)

Produce the response as usual. Do not short-circuit the Post-Flight check even for "obviously correct" drafts.

### Step 2 — Extract claims

From the draft, identify every assertion of the form:

- **Citation claims:** "Author (Year) shows X."
- **Existence claims:** "A dataset called X contains Y fields."
- **Numerical facts:** "N = 10,000" / "coefficient = 0.42" / "p < 0.01"
- **Named entities:** researcher names, paper titles, venues, package names
- **Negative literature claims:** "No prior work studies X."

Skip:
- **Opinions** ("this is a promising direction") — not verifiable
- **Suggestions** ("the user could try a log specification") — forward-looking
- **Definitions Codex introduces itself** ("let τ denote the treatment effect")

### Step 3 — Generate verification questions

For each extracted claim, write one specific, answerable question whose answer can confirm or refute the claim from the source material alone. Good questions name the source explicitly. Bad questions are open-ended.

| Bad question | Good question |
|-------------|--------------|
| "Is Author (2021) about calibration?" | "In Author (2021), what is the exact estimator name given in Section 4?" |
| "Does the estimator need a regularity condition?" | "Does Author (2021) Section 4 Assumption 2 require a monotone response, or merely a continuous one?" |

### Step 4 — Answer in fresh context, then reconcile

Spawn `claim-verifier` via the `Agent` tool with `subagent_type=claim-verifier` and `context=fork`. Hand it: claims, verification questions, source material pointers. **Do not include the draft** — forking removes the draft from the verifier's context automatically, but don't explicitly pass it either.

Receive back a verification report. Three outcomes:

- **PASS** (all claims match): return the draft to the user as-is.
- **PARTIAL** (some `cannot-verify`, no hard discrepancies): return the draft with explicit uncertainty flags on the unverified claims, so the user knows to double-check them.
- **FAIL** (at least one claim contradicts the source): **regenerate the affected section** using the verifier's evidence. If regeneration still fails after 2 attempts, return the best draft with discrepancies surfaced as a warning block — do not silently ship a known-wrong claim.

## Output contract

Every skill that applies this rule must include a structured Post-Flight block in its response (can be collapsed by the user; visible on demand):

```markdown
## Post-Flight Verification

**Claims extracted:** N
**Verified independently:** N (forked `claim-verifier` agent)
**Outcome:** PASS | PARTIAL | FAIL → regenerated

### Verified

| ID | Claim | Evidence |
|----|-------|----------|
| C1 | [claim] | [source + loc] |

### Unverifiable (user review recommended)

- **C4** — [reason, e.g., paywalled source]

### Discrepancies (regenerated)

- **C3** — original draft: "N = 10,000"; source shows: "N = 1,000". Corrected in final response.
```

## Fail-closed semantics

- If the verifier agent errors out, returns malformed output, or times out, **do not silently ship the draft.** Surface a block like:
  > "Post-Flight verification failed (verifier error: …). Draft has not been independently checked. Treat the output as provisional."
- This mirrors Pre-Flight's fail-closed contract. Hallucination discipline is most valuable precisely when things are going sideways — that's when silent failures are most expensive.

## Opt-out

`--no-verify` flag skips Post-Flight. Useful for speed-critical iterations or when the user is actively reading the source material themselves. Document the opt-out in each skill's argument hints.

## Cross-references

- `.codex/agents/claim-verifier.md` — the forked verifier.
- `.codex/guidance/review-fencing.md` — the environment side of the same discipline: a forked context does not fence the checkout the reviewer stands in.
- `.agents/skills/verify-claims/SKILL.md` — user-facing wrapper for ad-hoc verification of any text.
- `.codex/guidance/content-invariants.md` — Pre-Flight (input side).
- `.codex/guidance/cross-artifact-review.md` — pattern-based; Post-Flight is draft-based.
- `.codex/guidance/summary-parity.md` — rule against enumerative summaries drifting from their bodies; Post-Flight is the factual equivalent for draft content.
