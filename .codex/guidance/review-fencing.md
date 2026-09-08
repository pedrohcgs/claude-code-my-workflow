---
paths:
  # DISPATCH-TIME. Fencing is decided when a reviewer is pointed at an
  # artifact, not when a skill is written, so the rule is scoped to the
  # artifacts and answer keys a fenced run touches — the session that runs
  # `$review-paper --peer` on a manuscript is the one that must read this.
  - "*.tex"
  - "*.md"
  - "master_supporting_docs/**"
  - "quality_reports/qualification/**"
  - "quality_reports/passports/**"
  - "quality_reports/audits/**"
  - "quality_reports/oracle_audits/**"
  # AUTHORING-TIME, one file: the input contract that already implements the
  # fence. A skill that grows a real fencing step joins this list AND the
  # RULE_KEYWORDS registry in scripts/check-skill-integrity.py, so the
  # rule-vs-implementation gate can see it.
  - ".codex/agents/claim-verifier.md"
---

# Review Fencing — independence is a property of the environment

**A reviewer is only as blind as its working directory.**
[`verification-ladder.md`](../references/verification-ladder.md) rung 3 gives three ways to make
a reviewer independent — critic/fixer role tension, cross-artifact traversal, and the CoVe
fresh-context fork — and all three operate on the **context**. None of them touches the
filesystem the reviewer is standing on. A forked referee with a spotless context still holds the
repository checkout, and that checkout contains the earlier round's referee reports, the judge's
verdict, the passport recording every number the paper claims, and the stamp recording what the
current render was built from.

Prompting an agent to "review this independently" while it can `grep` for the answer is not
independence. It is an honour system with a search tool.

> **The rule:** before dispatching an independence-critical reviewer, ask what its *environment*
> would reveal if it looked — then remove that, rather than instructing it not to look.

**Where this rule loads.** Fencing is a *dispatch-time* obligation, so the `paths:` above name
the manuscripts, qualification ledger, passports and audit reports a fenced run is pointed at —
the session that dispatches referees at `manuscript.tex` is the one that has to make the call.
It deliberately does **not** claim every `SKILL.md`: a rule that binds every skill, none of which
implements it, is an unenforced obligation, and `scripts/check-skill-integrity.py` (check 5) now
fails on exactly that shape. When a skill grows a real fencing step, add it to `paths:` **and**
to that script's `RULE_KEYWORDS`, so the claim and the implementation are checked against each
other rather than asserted.

## The neutral copy

An independence-critical reviewer receives the artifact as a **copy placed outside the repository
checkout** — the session scratchpad, or any directory outside the working tree — under a
**neutral filename**, with no repo access.

Neutral means the name carries no verdict: not `paper_round3_after_referee_fixes.tex`, not
`protocol_final_v2.md` — `artifact-a.tex` is enough. A filename announcing which round it is has
already told the reviewer what was found last time.

Fencing is warranted whenever the reviewer's output is about to be **compared** against
something:

| Fence the environment | In-repo review is fine |
|---|---|
| Calibration and fresh-read passes — *what does a reader seeing this cold conclude?* | The artifact's own working review loop, where repo context **is** the point |
| A second-opinion reviewer meant to corroborate a first | Cross-artifact traversal — paper → table → output → script **requires** the tree |
| Any reviewer scored against another's findings, or against a planted-defect set | Deterministic gates — a script has no impression to bias |
| An external-model consult (already a copy — keep the name neutral too) | A fixer applying findings a critic has already confirmed |

The distinction is not important-versus-unimportant review. It is whether a comparison is coming.
**Two reviewers that both read the first one's report are one reviewer**, and averaging them
reports agreement that was manufactured rather than found.

## What the fence does not buy

**Fencing makes the evidence independent. It does not make the errors independent.** Two fenced
reviewers running the same model on the same artifact share a prior — the same blind spots, the
same misreadings, the same confident wrong answer — and separate sessions do not separate that.
So their agreement is weaker evidence than two independent readers agreeing, and the fence is
precisely what makes it *look* stronger.

Three consequences worth holding onto:

- **Vary what actually varies the error.** A different model, a different lens or role, or a
  human reader buys independence; a second session of the identical configuration mostly buys a
  second sample of the same distribution. N identical fenced runs measure the reviewer's
  variance, not the artifact's correctness.
- **Read concordance as stability, disagreement as signal.** Same-model agreement says the
  reading is reproducible. It does not say it is right, and the disagreement is the informative
  half.
- **Never report a same-model concurrence as corroboration.**
  [`../references/external-oracle-process.md`](../references/external-oracle-process.md) states
  this for the oracle — *agreement is not confirmation; two models correlate on the same wrong
  answer* — and the caution does not weaken inside the fence. A mechanical check outranks any
  number of concurring reviewers.

None of this is a reason to skip fencing. An unfenced reviewer's errors are correlated *and* it
has read the answer key; the fence removes one of the two.

## Prior verdicts stay out

Earlier referee reports, judge verdicts, adjudication tables, and prior-round quality reports do
**not** enter a reviewer's session unless the protocol deliberately feeds them — and a protocol
that does feed them says so, in writing, before the run.

The sanctioned exception is the R&R continuation. [`$review-paper`](../../.agents/skills/review-paper/SKILL.md)
in `--peer --r2` / `--r3` mode reloads the prior round's reports and reuses the same referees and
dispositions on purpose, because the question has changed from *"is this sound?"* to *"was each
prior concern resolved?"* — a task that cannot be done without the history. Everything that is
not that task stays fenced.

**Deliberate means declared.** A protocol that merely leaves the reports where a reviewer will
find them has not fed them deliberately; it has leaked them.

## Own reading first

A reviewer forms and **records** its own reading before it is shown the plan, the revision note,
the author response, or the change log. Have it decide what *should* be there before it learns
what was promised, or it grades conformance instead of adequacy
([`verification-ladder.md`](../references/verification-ladder.md) rung 3).

The ordering is the entire mechanism. The same two documents in the other order produce a
reviewer that ticks boxes.

## Fence the positive controls

**A committed expected value is an answer key.** Before asking an agent to reproduce a pinned
number — which is the whole point of a positive control — confirm the pinned value is not
readable from where the agent stands. An agent that reports the pinned number after finding it in
a tracked file has demonstrated `grep`, not reproduction, and the control that was supposed to
qualify the check now reads green for the wrong reason. Verify by **re-deriving, not re-asking**
([`research-agent-laws.md`](../references/research-agent-laws.md) law 1).

This template commits three answer keys of its own:

| Answer key | What it pins |
|---|---|
| `quality_reports/passports/<paper-slug>.yaml` | the expected value of every verified numeric claim ([`replication-protocol.md`](replication-protocol.md)) |
| `.render-stamp` | the source and output fingerprints a current render must match |
| `quality_reports/qualification/LEDGER.md` | which defects a qualification run planted, and what the checker scored against them |

Add whatever else your project pins: baseline manifests, tolerance registries, expected-output
fixtures, golden files. Then either hand the agent a checkout without them or give the
reproduction its own scratch directory. **An unfenced positive control is an unqualified check**
([`verification-ladder.md`](../references/verification-ladder.md) rung 0).

**Record the fence in the row's `Artifact` cell.**
[`LEDGER.md`](../../quality_reports/qualification/LEDGER.md) has no separate fence field, and
this rule does not invent one: `Artifact` is the column that already says what the run was
handed — *"a fixture clone outside the repo"*, *"a copied hook directory selected with
`HOOK_DIR`"*, *"synthetic events, no repo access"*. Write the fence there, in those terms, and
the row states its own independence. A row whose `Artifact` cell names only the file under test
has not declared a fence, and a reader cannot tell whether one was used.

**A forked context is not a fence.** [`$vaccinate`](../../.agents/skills/vaccinate/SKILL.md) runs the
checker blind in a fresh `Agent` fork and grades a *copy* of the artifact — that empties the
reviewer's context, not its working directory. When the expected value is committed anywhere in
the tree, the copy has to sit **outside the checkout** as well, or the fork can still read the
answer.

## What is already fenced

The template already fences one input correctly, and this rule generalizes that rather than
introducing a new idea. [`claim-verifier`](../agents/claim-verifier.toml) receives **claims plus
source-material pointers and nothing else** — never the draft, never the reasoning trace that
produced it — and is instructed to ignore the draft even if a caller leaks it into context
([`post-flight-verification.md`](post-flight-verification.md)). That is an environment fence
expressed as an input contract: the verifier cannot rubber-stamp the draft's reasoning because it
does not hold it. Extend the same discipline outward — what that contract does for the draft, the
neutral copy does for the checkout.

## Cross-references

- [`../references/verification-ladder.md`](../references/verification-ladder.md) — rung 0 (qualify the checker), rung 3 (the three context-level mechanisms this rule extends)
- [`post-flight-verification.md`](post-flight-verification.md) — the CoVe protocol and the forked verifier
- [`../agents/claim-verifier.toml`](../agents/claim-verifier.toml) — the input contract this rule generalizes
- [`../references/external-oracle-process.md`](../references/external-oracle-process.md) — external consults: blind the judge, verify the transport
- [`../../.agents/skills/vaccinate/SKILL.md`](../../.agents/skills/vaccinate/SKILL.md) — seeded-defect qualification, where an unfenced answer key is fatal
- [`../references/research-agent-laws.md`](../references/research-agent-laws.md) — law 1 (re-derive, do not re-ask), law 13 (blind the judge)
