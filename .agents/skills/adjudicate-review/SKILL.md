---
name: adjudicate-review
description: "Turn an incoming set of findings — from an AI reviewer, a referee report, a code review, a linter, or a second model — into verified fixes, without letting a confident misread damage correct work. Every finding is a CANDIDATE until checked against the actual source. Use whenever you receive review comments, audit findings, or a critique you did not write yourself, especially when the reviewer is a model or when the volume is too large to check by feel."
---




# Adjudicate the review; do not ingest it

A fluent, specific, line-numbered finding is not a verdict. It is a hypothesis about your work. Modern reviewers — especially models — produce objections that are **confidently wrong at a meaningful rate**, and some proposed fixes will *introduce* defects if applied. Your job is to convert findings into evidence-backed decisions.

**Rule: never change correct work to satisfy a reviewer you have not checked.**

## 0. First, was the reviewed artifact intact?

Before adjudicating anything, confirm the reviewer saw what you meant to send (see `verify-artifact`). Findings about missing references, truncated sections, or numbering that does not match your copy are usually artifacts of a bad upload/excerpt, not defects. Adjudicating those as real is how correct material gets broken.

## 1. Triage before verifying

Classify each finding:
- **Type**: false statement | proof/logic gap | overclaim (headline exceeds what is established) | scope-or-consistency | exposition | artifact.
- **Severity**: fatal | major | minor.
- **Which question it concerns** — and do not let one clear another: reproducibility ≠ implementation fidelity ≠ statistical performance ≠ measurement validity ≠ identification/interpretation.
- **Held items**: anything that re-litigates a decision the owner already made. Record, do not act.

## 2. Mechanical checks beat opinion

If a finding is computable, compute it: run the identity on a small adversarial case, grep for the symbol, resolve the cross-reference, execute the consuming code, count the occurrences. A two-minute check outranks any amount of reviewer confidence — in either direction. Several findings that *look* like taste turn out to be real, and several that look devastating evaporate.

## 3. Verify each finding against the actual source

Open the cited location. Ask:
- Is the alleged text actually there, verbatim?
- Is the missing hypothesis genuinely absent, or is it stated elsewhere — earlier in the paragraph, in the enclosing environment, imported via "the hypotheses of X", or in a governing standing assumption?
- Does the failing case the reviewer describes actually arise under the stated conditions?

Return one of: **CONFIRMED** / **REFUTED** / **PARTIAL**, each with line-level evidence. A refutation must cite the text that refutes it, not your recollection.

## 4. Beware correlated errors and poisoned fixes

- **Agreement is not confirmation.** Two reviewers flagging the same thing is weak evidence — models share failure modes and will converge on the same wrong answer. Independent *computation* is confirmation; concurring prose is not.
- **Agreement on absence is not evidence of absence.** Multiple reviewers missing a defect says little; targeted verification finds what broad review does not.
- **Check the proposed fix, not just the finding.** A reviewer can be right that a passage is confusing and wrong about why — applying its patch can introduce a real error. Common cases: removing a step that looks redundant but is load-bearing; conceding a restriction the work does not actually make; "correcting" a cross-reference that was right.

## 5. Fix in one batch, then rebuild and re-verify

Apply all confirmed fixes together, rebuild, and re-run the mechanical checks. Do not drip one fix per round. Keep edits **surgical** — a qualifier, a scope word, a corrected formula — unless the defect genuinely requires structural work.

## 6. Refuted ≠ safe: treat misreads as documentation signals

If a careful reviewer stumbled, a careful human may stumble the same way. For each refutation, ask: *can I make the correct mechanism unmissable at the point where they stumbled?* Add a short signpost — prose only, no change to claims.

The dominant cause of confident-but-wrong findings is **remoteness**: the claim is correct, but what licenses it sits elsewhere (a standing hypothesis a few sentences up, a factor established two paragraphs above, a premise imported by reference, a delimitation in a distant note). Where that is the cause, bring the qualifier local — a short parenthetical or an inline naming of the governing regime. This is also the single best defense against AI-assisted review generally.

Symbols carrying two meanings (centered/uncentered, raw/normalized, restricted/unrestricted) are the highest-risk case: disambiguate at the *use* site, not only at the definition.

## 7. Report a claim record, never "review passed"

Return: what was fixed (location + evidence), what was refuted and why (with the refuting text), what remains unresolved, and which decisions belong to the owner (estimand changes, scope concessions, reporting language, positioning). Escalate those rather than deciding them.

## Convergence

Stop when a confirmation pass returns no new confirmed defect — only held items and taste. Track the yield: when a round produces mostly refutations, artifacts, and exposition, further rounds cost more to adjudicate than they return. **The number of findings is not a measure of rigor.**

## Cross-references

- [`external-oracle-process.md`](../../../.codex/references/external-oracle-process.md) §5 — adjudicate, never ingest
- [`orchestration-schemas.md`](../../../.codex/references/orchestration-schemas.md) §7 — the validated FINDING contract

