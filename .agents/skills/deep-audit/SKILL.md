---
name: deep-audit
description: "Comprehensive adversarial audit of a theory, proof, math/econ paper, codebase, or set of claims — decompose into components, fan out independent skeptics that must return CONCRETE defects, adjudicate every finding with a separate judge, fix all confirmed defects, then re-verify. Use when correctness must be bulletproof and single-pass or round-by-round review is too slow and too shallow. Invoke for \"audit this rigorously\", \"find ALL the bugs/gaps\", \"make this rock solid\", \"converge faster on correctness\"."
---



# Deep adversarial audit

A convergent alternative to slow round-by-round review. Instead of one reviewer finding one or two issues per pass, fan out many independent skeptics over the *whole* artifact at once, adjudicate what they find, fix everything confirmed, and re-verify. Modeled on the multi-agent methodology behind hard formal-proof efforts (diverse independent portfolio, adversarial throughout, concrete evidence only, synthesize-challenge-repeat).

## When to reach for this
- The artifact is dense enough that a single review keeps surfacing *new* issues each pass (the tell that round-by-round is the wrong tool).
- Correctness is the priority and the cost of a missed defect is high (a paper going to a top venue, a proof, a security-sensitive change, a migration).
- The user asked to "fix ALL of it", "be deeper", "converge faster", "100% rock solid".

Requires the user to have opted into multi-agent orchestration (they asked for a workflow / deep audit / to fan out agents, or ultracode is on). If they haven't, propose it and its rough cost first.

## The method

**1. Decompose (diverse portfolio).** Break the artifact into components by *idea*, not by section: each independent claim, lemma, estimator, subsystem, invariant. Add cross-cutting *failure-mode lenses* (see below). Aim for coverage such that every load-bearing claim is attacked by at least one agent that is looking straight at it. Don't tell the agents your favored reading — preserve independence so they don't all converge on the same attractive-but-wrong conclusion.

**2. Fan out adversarial finders (one per component).** Each finder is prompted to *refute*, defaulting to "there is a bug," and must ground every claim in the actual text/code (read it, don't paraphrase from memory). Hard rules, borrowed from what works:
   - **Concrete findings only.** Every finding = exact location (file:line / label + quoted text) + one-sentence defect + a **failing case** (specific inputs/configuration → wrong output, or the exact missing hypothesis). 
   - **Reject** status reports, "looks fine", "this is standard/routine", vague optimism, and "the global step is straightforward."
   - **A fix that re-imposes the same difficulty elsewhere, or assumes its own conclusion, is not a fix** — flag it.
   - If, after genuinely attacking, nothing is found, the agent must state the *specific* attacks it ran and why each closed — not just "clean."

**3. Adjudicate every finding (independent judge).** A separate judge re-opens each cited location and decides CONFIRMED / REFUTED / DOWNGRADED, skeptical of *both* the artifact and the finding. This kills false positives (misreads, hypotheses that are actually present elsewhere, failing cases that don't arise under the stated conditions) — the step that keeps the fix list honest.

**4. Synthesize.** Dedup by location, rank fatal > major > minor, and hand back one clean defect list. Nothing is accepted as an issue until it survives this.

**5. Fix all confirmed, then re-verify.** Apply every confirmed fix (you, in the main loop — fixing needs care and judgment). Then re-audit the touched spots and check that no fix created a new defect. Repeat waves until an audit pass comes back empty. Don't stop after the first wave.

## Failure-mode lenses (adapt to domain)
Beyond per-component attacks, sweep these cross-cutting modes explicitly — they are where real defects hide:
- **Overclaim:** the headline/abstract claims more than the theorems/tests actually deliver.
- **Scope creep in a proof:** a *pointwise* result used where a *uniform* one is needed; a *both-correct* property stated unqualified; a special-case argument invoked generally.
- **Silent hypotheses:** a differentiability/density/continuity/boundedness/positivity condition used but never stated (in math), or an un-checked precondition/invariant (in code).
- **Edge cases:** atoms/ties, endpoints/unbounded support, empty/degenerate inputs, boundary of the parameter space.
- **Circularity:** an assumption that assumes its own conclusion; a result that cites itself; a citation that gives less than claimed (read the cited source).
- **Internal contradiction:** a definition/notation used two ways; a table cell contradicting a proposition; main text vs appendix disagreement; a dangling/wrong cross-reference.

## The fresh-eyes pass (final gate)
Every targeted wave inherits the blind spots of whoever wrote its prompts: focus hints, fix history, and expected failure modes all prime the auditors toward known territory. **After all targeted waves and fixes are done, run one cold audit with little to no context**: independent auditors given ONLY the artifact and a minimal instruction ("find concrete defects: location + failing case"), with no cluster assignments, no history, no special-focus lists. Diversify only the *entry point* (main-text-first as a journal referee would; appendix-first; tables/claims-first; a single deep dive of the auditor's own choosing). Adjudicate as usual. Clean fresh-eyes pass + clean targeted coverage + green mechanical battery is the closure standard; a fresh-eyes finding that targeted waves missed is also a diagnosis of the prompt set — add the missed failure mode to the lenses.

## Full inventory — never sample
For a paper/proof artifact: **enumerate every formal statement first** (grep `\begin{theorem|proposition|lemma|corollary}` + labels) and assign each proof to a verifier — coverage must be 100% of load-bearing statements, not "a few proofs of the reviewer's choice." Sampling converges linearly and stochastically; inventories converge in one wave. Group tightly-coupled small lemmas into clusters; big proofs get their own verifier. Each verifier returns, besides findings, a **steps-verified list** and a **hypotheses ledger** (used-vs-stated; used-but-unstated is a finding).

## The mechanical battery (the highest-yield check)
Written arguments can read soundly while the object they define is wrong. For **every estimating equation, influence-function identity, identification claim, and population moment**, write an executable check that *computes the population object* on adversarial toy designs — truncation (censoring endpoint below the outcome endpoint), interior atoms, misspecified nuisances, boundary/overlap failure — and asserts the claimed centering/identity numerically (analytic or fine-grid/large-N with fixed seed). Keep the scripts as a permanent test directory in the repo with a README; rerun after any change to the corresponding formula. A 5-line population computation catches classes of defects (tail-renormalized roots, sign flips, mass-deficit weighting) that neither careful reading nor model consensus reliably finds.

## Fix hygiene
- **New math introduced by fixes is un-audited math**: every fix wave is followed by a verification wave over exactly the fixed spots before anything is declared closed.
- **In workflow synthesis, match findings to verdicts by INDEX** (require the judge to return verdicts in the findings' order), never by location string — judges paraphrase locations and silent drops follow. Verify the synthesized summary against the journal before acting on it.

## Blocked routes are outcomes
If a component cannot be fixed under the stated assumptions, that is a *finding*, not a failure of the audit: report the exact remaining gap (the precise missing hypothesis or broken step) and the honest options (weaken the claim, add the hypothesis, restrict scope). Do not search for a favorable reading, and do not let an agent paper over a theorem-strength gap as "routine."

## Orchestration
- Use a **Workflow** for the fan-out: `pipeline(components, finder, judge)` so each component's findings are judged the moment its finder returns (no barrier), then synthesize. Return the confirmed list; do the fixing yourself afterward.
- **Model division:** finders = the strong *execution/analysis* model (find and attack); judges = the strong *adjudication* model. Match to the local convention (here: capable finders and independent judges). Keep judges to one-per-component (adjudicating all that component's findings at once) to conserve the scarcer judging model.
- Set finder `effort` high; give each the exact labels/locations to read and its specific attack list.
- **Persist.** Don't return "best effort" or a list of why it's hard. Return the confirmed defects (and, once fixed, a clean re-audit) — or the single strongest remaining gap stated exactly.

## Prompt skeletons
Finder: *"You are a HOSTILE referee auditing ONE component. Read the ACTUAL text at {locations}. Attack: {failure modes}. Return CONCRETE findings only (location + defect + failing case); no 'looks fine'/'routine'/vague. A fix that re-imposes the difficulty isn't a fix. If clean, list the specific attacks you ran and why each closed."*

Judge: *"An adversarial referee returned these findings on component X. For each, open the cited location, verify against what the text ACTUALLY says and its proof, mark CONFIRMED/REFUTED/DOWNGRADED. Skeptical of both the artifact and the finding."*

## Shared doctrine lives in one place

Three things this audit depends on are **not** restated here, because they are the same rules
every other verification surface uses and a third copy would drift:

- **Seeded-fault calibration** — a check that has not caught a planted defect licenses nothing.
  → [`$vaccinate`](../vaccinate/SKILL.md), and [`verification-ladder.md`](../../../.codex/references/verification-ladder.md) rung 0.
- **Independence and correlated errors** — agreement between models is not confirmation; they
  fail the same way. → [`verification-ladder.md`](../../../.codex/references/verification-ladder.md) rung 3.
- **The five credibility questions** — evidence for one never clears another.
  → [`verification-ladder.md`](../../../.codex/references/verification-ladder.md) §6 and [`external-oracle-process.md`](../../../.codex/references/external-oracle-process.md) §6.

## Auditing this repository itself

For the repo-infrastructure application — surface-sync, skill/agent/rule integrity, hook and
script review, doc-vs-reality drift — see
[`references/repo-infrastructure-audit.md`](references/repo-infrastructure-audit.md).
Start with `./scripts/backtest.sh`: the mechanical battery is already written, and an agent
should never hand-check what a script decides.

