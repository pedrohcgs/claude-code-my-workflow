---
name: verify-claims
description: "Run Chain-of-Verification (CoVe) on a draft or a block of text with factual claims. Spawns the `claim-verifier` agent in a forked (fresh) context so it never sees the draft — then reports which claims are supported, contradicted, or unverifiable. Use when user says \"verify these citations\", \"check the claims in X\", \"did I hallucinate anything\", \"fact-check this draft\", \"run CoVe on this\", or after any text generation that asserts facts about papers, datasets, or numerical results. NOT for style/grammar review (use `$proofread`) or substance review (use `$review-paper`)."
---



# $verify-claims — Chain-of-Verification on a Draft

Fact-check a draft using the **Post-Flight Verification protocol** ([`.codex/guidance/post-flight-verification.md`](../../../.codex/guidance/post-flight-verification.md)).

**Input:** `the arguments supplied with the invocation` — path to a file containing the draft (Markdown or LaTeX) or a shorthand pointer. Optional flags:

- `--source <path-or-url>` — one or more source-material pointers (repeat for multiple). If omitted, the skill infers from context (e.g., papers referenced, cited arXiv URLs).
- `--no-fail-closed` — downgrade FAIL outcomes to warnings without regeneration. Use sparingly.

## When to pick this skill

- **`$verify-claims`** (this skill) — ad-hoc fact-checking on any draft or text block the user hands you. One-shot, user-invoked.
- **Other skills that auto-run Post-Flight internally** (`$lit-review`, `$research-ideation`, `$respond-to-referees`, `$review-paper --peer`) — no need to call this separately; they already run it.
- **`$proofread`** — grammar, typos, overflow. Different lens.
- **`$review-paper`** (default mode) — full manuscript review, not just claim verification.
- **`$validate-bib`** — checks citations *exist* and are well-formed (structural + DOI). This skill checks they *hold* (the cited paper supports the attributed claim). Complementary — run both before submission.

## How it works

Implements the 4-step CoVe loop from Dhuliawala et al. 2023 ([arXiv:2309.11495](https://arxiv.org/abs/2309.11495)), with architectural enforcement of the fresh-context independence trick.

### Phase 0 — Pre-Flight

Confirm:
- Draft file exists and is readable
- At least one source pointer available (either `--source` or auto-detected from draft)
- `claim-verifier` agent file exists at `.codex/agents/claim-verifier.toml`

If any fail → surface the failure, do NOT proceed.

### Phase 1 — Extract claims

Read the draft. Identify factual assertions of these types:

| Type | Example |
|------|---------|
| Citation | "Smith (2019, *JEL*) shows X" |
| Numerical fact | "N = 10,000", "ATT = 0.42" |
| Negative literature | "No prior work studies X" |
| Named entity | researcher, paper title, venue, package, estimator name |
| Dataset claim | "The CPS contains field `educ_attain`" |

Skip: opinions, forward-looking suggestions, definitions the draft introduces.

**For citation-type claims, extract the claim↔citation PAIR — not just the citation.** Capture *what* the draft attributes to *which* work, so the verifier checks **appropriateness** (does Smith 2019 actually *show* X?), not merely existence. "Smith (2019) shows a positive wage effect" becomes `{cite: Smith2019, attributed: "positive wage effect"}`. This is the layer `$validate-bib` explicitly defers here: validate-bib confirms the citation *exists and is well-formed*; this skill confirms it *holds*. A mis-citation (the paper exists but says something else, or the opposite) is exactly a numeric/directional contradiction → HIGH-WARN unless a concrete `author_alternative` is recorded (then EXPLAINED).

Output a claims table:

```markdown
| ID | Claim | Source hint |
|----|-------|-------------|
| C1 | ... | ... |
```

### Phase 2 — Generate verification questions

One question per claim. Make it specific and answerable from the source alone.

### Phase 3 — Spawn `claim-verifier` (forked, fresh context)

```
Agent: subagent_type=claim-verifier, context=fork
Prompt: hand over claims table + verification questions + source material pointers.
        Do NOT include the draft text.
```

The forked agent runs the CoVe independent-answer step. It has never seen the draft and cannot confirm-bias. It returns a structured verification report.

### Phase 4 — Reconcile

The verifier returns a per-claim verdict in one of these severity tiers:

- **HIGH-WARN** — fabricated reference (the cited paper doesn't exist at the named venue/year), draft claim directly contradicted by the source, or `not_found` retrieval that the verifier interprets as a hallucinated citation. **Gate-refuse** — these block `$commit` for any file `$verify-claims` was just run against, unless the user explicitly overrides with `--no-fail-closed` or sets `verifyClaims.allowHighWarn: true` in `.codex/config.toml`.
- **MED-WARN** — transient infrastructure / retrieval failure (paywall the verifier can normally bypass via cached metadata; DOI resolver timeout; partial PDF read). Surface for the author; do not gate-refuse.
- **LOW-WARN** — source genuinely inaccessible (paywalled and not in cache; private dataset; pre-print server transient). Surface with `cannot-verify` flag; do not gate-refuse.
- **EXPLAINED** (v2.0) — a numeric/directional contradiction the author has *pre-justified* with a concrete named alternative (different defensible edition, specification, sample, or rounding convention), passed to the verifier via the claim's `author_alternative` field. Surfaced with the evidence and the recorded reason; **non-gating**. The hard floor holds: a *fabricated* citation is never EXPLAINED, and a blank/vague alternative stays HIGH-WARN. This mirrors `audit-reproducibility`'s EXPLAINED disposition for numeric claims — a mismatch is not always a failure when a defensible alternative is named.

Verdict aggregation by tier across all extracted claims (EXPLAINED counts as non-gating, like LOW):

| Tier counts | Outcome | `$commit` behaviour |
|---|---|---|
| 0 HIGH, 0 MED, ≥ 0 LOW/EXPLAINED | **PASS** (green block) | proceeds |
| 0 HIGH, ≥ 1 MED, any LOW/EXPLAINED | **PARTIAL** (yellow block) | proceeds with warning |
| ≥ 1 HIGH | **FAIL** (red block) | **halts** unless override |

`--no-fail-closed` opts out of the gate-refuse behaviour on HIGH-WARN. Use sparingly — it's there for offline / hallucination-sensitive contexts where the user accepts the risk in writing.

If the draft is writeable and the user asked for auto-correction, regenerate the affected sections using the verifier's evidence. Otherwise return the report and let the user decide.

## Example

```
$verify-claims quality_reports$lit-review_measurement-error.md --source master_supporting_docs/author_2021_method.pdf --source master_supporting_docs/coauthor_2020_survey.pdf
```

Expected output (abridged):

```markdown
## Post-Flight Verification — lit-review_measurement-error.md

**Claims extracted:** 14
**Verified independently:** 14 (forked claim-verifier)
**Outcome:** PARTIAL — 12 verified, 1 discrepancy, 1 unverifiable

### Discrepancies

- **C7** — draft claims "Coauthor (2020) *proposes* a bias-corrected estimator." Source Section 4 shows they propose a weighting estimator, not a bias-corrected one. Recommend correction.

### Unverifiable

- **C12** — draft cites "Third Author et al. 2024 (working paper)". No canonical URL in provided sources. Recommend user supply DOI or arXiv link.

### Verified

| ID | Claim | Evidence |
|----|-------|----------|
| C1 | "Author 2021 defines the calibration constant as a ratio of moments" | p. 5, eq. (3) |
| ... | ... | ... |
```

## Fail modes and recovery

**Verifier times out:** surface a warning block, return draft as provisional. Do not silently ship.

**Source material inaccessible** (paywall, 404): report the specific claims that hinge on it, flag as `cannot-verify`, recommend user supply an alternative source.

**Draft contains only opinions / forward-looking text:** report "no verifiable factual claims extracted — nothing to check" and return.

## Cross-references

- [`.codex/agents/claim-verifier.toml`](../../../.codex/agents/claim-verifier.toml) — the fresh-context verifier.
- [`.codex/guidance/post-flight-verification.md`](../../../.codex/guidance/post-flight-verification.md) — the protocol.
- MEMORY.md `[LEARN:pattern]` on Chain-of-Verification vs critic-fixer vs cross-artifact review.
