# Attacking theory problems — proof contracts, portfolio search, adversarial audit

For econometric theory: identification arguments, asymptotic results, proofs in a paper's
appendix, counterexample hunting, and "is this conjecture even true?" work. Adapted for this
template from the open-problem workflow that resolved several open Erdős problems in July 2026
(Shouqiao Wang's method, generalized in `meleantonio/open-problem-prover`, both MIT) — the
techniques transfer to statistics and econometrics almost unchanged, because the failure modes
are the same: plausible-looking arguments that do not survive a hostile reading.

> **An AI-generated proof is a claim, not a theorem.** The entire design goal of this workflow
> is making it hard for wrong proofs to survive. Expect a substantial fraction of well-chosen
> attempts to fail — that is the method working, not failing.

## 1. The proof contract — before any proving

Write a document that defines *exactly what counts as a solution*, before the first attempt:

- **Precise restatement** in this template's notation, with every assumption explicit.
- **Affirmative AND negative resolution criteria** — what proves it, and what disproves it.
  Keep both directions alive; a counterexample is as publishable as a proof.
- **Known background and what it does NOT imply.** The most common failure in econometric
  theory is silently importing a conclusion the cited result does not deliver (pointwise
  where uniform is needed; iid where the design has clustering; compactness nobody assumed).
- **A firewall of insufficient near-misses.** List the arguments that LOOK like proofs but are
  not: interchanging limits without justification, "by standard arguments", treating a
  plug-in estimator's error as second-order without the rate, assuming away boundary cases
  (unbounded weights, atoms in the propensity score, degenerate variance).
- **Problem-specific traps.** For semiparametrics: the tangent-space calculation that quietly
  assumes more smoothness than stated; for bootstrap claims: the centering that changes under
  the null nobody restated.
- **Exit criteria.** What ends the attempt — a proof, a counterexample, or a named blocked
  route with the exact missing lemma. *A blocked route is a scientific outcome.*

## 2. Portfolio search — independent routes, a route ledger

Explore genuinely different proof strategies **independently** — separate forked agents that
do not see each other's notes or the favored route (shared context produces convergence by
imitation, not correctness; the same herding measured in empirical work applies to proofs).

Track every route in a **route ledger**: route, status (live / blocked-at / merged), the exact
theorem-strength gap where it blocks, and artifacts. **Artifacts required; status reports
rejected** — "making progress on the empirical-process route" is not an entry.

## 3. Computation as evidence — counterexample-hunt your own lemmas first

Before investing in proving a lemma, **try to break it numerically**. For econometrics this is
cheap and brutal: small adversarial designs — two periods, three units, an atom in the
propensity score, weights at the trimming boundary, variance at zero. A lemma that survives a
designed grid has earned a proof attempt; one that fails has saved you a week.

- **Exact arithmetic for anything reported** (rationals, symbolic algebra) — floats prove
  nothing at boundaries, and boundaries are where econometric lemmas die.
- Finite subproblems (combinatorial identification arguments, bounds over small designs) can
  often be closed completely by exhaustive checking — a **finite certificate**, not a simulation.
- The standing rule: **computation is evidence unless converted into rigorous proof or a
  finite certificate.** A simulation supporting a conjecture goes in the ledger as evidence,
  never in the paper as proof.

## 4. Adversarial audit — a fresh hostile referee per draft

Every draft is audited by a **fresh-context agent that sees only the contract and the draft** —
never the exploration history (it would inherit the same blind spots). The auditor:

- walks the firewall and trap lists **item by item**;
- **expands every "clearly", "standard", and "it is easy to see"** — these are where proofs
  die;
- recomputes load-bearing steps independently, on adversarial instances where computable;
- returns findings under this template's contract: location + defect + **failing case**
  (the concrete configuration that breaks the step, or the exact missing hypothesis).

Loop: *attempt → failure → diagnosis → new route → draft → audit → repair* — under the
standard convergence rules ([`verification-ladder.md`](verification-ladder.md): batch fixes,
one confirmation round, two-strikes escalates to the human).

## 5. Verification and disclosure

- Paper with **explicit lemma dependencies** — a dependency graph, so a broken lemma's blast
  radius is knowable ([`$blast-radius`](../../.agents/skills/blast-radius/SKILL.md) applies to proofs too).
- A **companion verifier script** for every computational claim, stating what it does **not**
  check.
- **Lean formalization where feasible** — heavy, but it exists and it is the only gate that
  cannot be argued with. For most econometric theory, the realistic target is formalizing the
  combinatorial or finite-dimensional core, not the whole asymptotic argument.
- **A human gate before any public claim.** The external oracle
  ([`external-oracle-process.md`](external-oracle-process.md)) is the natural confirmation
  referee for a finished draft — after in-house audit, never instead of it.

## How this composes with what is already here

| This workflow's piece | Existing machinery |
|---|---|
| Proof contract | pre-committed interpretation ([`verification-ladder.md`](verification-ladder.md) rung 5) |
| Route ledger | the specification-search ledger, applied to proof routes |
| Isolated explorers | the independence rung — fresh-context forks |
| Adversarial audit | [`$deep-audit`](../../.agents/skills/deep-audit/SKILL.md)'s refute-biased verifier + the FINDING contract |
| "Computation is evidence" | the five credibility questions — evidence for one never clears another |
| External referee at the end | [`$oracle-review`](../../.agents/skills/oracle-review/SKILL.md) — confirmation, not discovery |

**Not installed as a plugin, deliberately.** The method is what transfers; the tooling above
already implements most of it. If you want the upstream's slash commands, it ships an
`install.sh` and a marketplace — evaluate it against [`provenance-and-ground-truth.md`](provenance-and-ground-truth.md)
§7 (both repos are MIT, so reuse with attribution is clean).
