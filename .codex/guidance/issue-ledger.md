---
paths:
  - ".github/**"
  - "**/ISSUE_TEMPLATE/**"
---

# The Issue Ledger — evidence standard for authenticated defects

Use the issue tracker as the **durable ledger for authenticated defects**. The purpose is not
to maximise issue count. It is to ensure that a defect, its evidence, its repair, and **the
limits of that repair** cannot disappear into a branch, a chat window, or a commit message.

A defect that lives only in a conversation is a defect you will rediscover.

## When to open one

Open **one issue per root cause** when a bounded check authenticates behaviour that violates a
documented contract, a statistical law, an invariant, a reproducibility requirement, or a
user-facing promise. Search open *and* closed issues first; link related symptoms rather than
duplicating them.

The initial report must carry:

- the exact **source revision**, branch, and worktree;
- **observed vs expected** behaviour;
- a **minimal reproducer** or a retained evidence artifact;
- the **measurement denominator**, unresolved cases, and a **live positive or negative
  control** — "430 of 962 values moved", not "some values moved";
- the **scientific consequence** — what claim this threatens;
- **affected scope and explicit non-scope**;
- **measurable acceptance criteria**.

> **Do not quietly fix an authenticated defect.** A silent repair destroys the record of what
> was wrong and why, and the next person cannot tell a deliberate change from a regression.

> **Do not file speculation as established fact.** Label the uncertainty in the body and state
> the bounded test that will adjudicate it.

## Triage

**Reproduce at the named revision before changing code.** If later evidence changes the
diagnosis, correct it in the issue — and **preserve the old diagnosis** as part of the audit
trail. A refuted hypothesis is evidence about how the system misleads.

Keep the issue open while the repair, its tests, and any required audits are incomplete.

**Do not use auto-closing keywords** (`Closes`, `Fixes`, `Resolves`) in commits or PRs.
Automatic closure races ahead of the latest scientific disposition — the merge is a code event,
the closure is a *judgement*. The final state transition is manual.

For changes to a load-bearing numeric surface, run the focused tests, the fail-closed audit
harness, the invariant fingerprint comparison, and the full suite. **Never re-bless a changed
fingerprint merely to obtain a green gate; attribute every movement first**
([`provenance-and-ground-truth.md`](../references/provenance-and-ground-truth.md)).

## The closure comment — seven required sections

Before closing as completed, post one final comment containing:

1. **Corrected diagnosis and root cause.** What was actually wrong, and which earlier
   hypothesis measurement refuted.
2. **Repair identity.** Exact commits; the material files or functions changed.
3. **Before → after.** Original and repaired measurements *with denominators*, missing cases,
   thresholds, and retained artifact paths or hashes.
4. **Controls.** The positive, negative, mutation, or regression controls proving the gate
   **can still fail for the intended reason** — a repair that also disables the detector is not
   a repair.
5. **Verification.** Focused tests plus full-suite file / pass / fail / error / warning / skip
   counts. For numeric surfaces, the audit verdict and fingerprint, or why they do not apply.
6. **Performance.** For a performance issue: comparable before/after timings, hardware and
   runtime context, watchdog status.
7. **Limits and follow-ups.** Untested routes, deferred decisions, linked issues.

**Post the comment first. Re-read it against the acceptance criteria. Then close manually.**

## Other dispositions

- **Duplicate** — name the canonical issue and explain why the root causes coincide.
- **Not planned / refuted** — post the adjudicating evidence and explain why no repair is
  warranted. **A failed hypothesis is useful evidence and stays visible.**
- **Split scope** — keep the original open until its acceptance criteria pass, or amend them
  explicitly with a reason. **Never use a follow-up to hide an unmet original criterion.**
- **Regression** — reopen the existing issue when the *same root cause* returns; open a new one
  when the symptom has a distinct root cause.

## Audit rule

At every coherent checkpoint, triage new review threads against current source. **A fetch
failure is not an empty inbox.** Review tooling must never auto-reply or auto-resolve.

Before any handoff, verify that every defect found in the round is either represented by an
open issue or has a completed issue whose final comment meets the seven sections above. Record
exceptions in the handoff rather than silently changing issue state.

## Cross-references

- [`verification-ladder.md`](../references/verification-ladder.md) — rung 5; the ledger as the arbiter
- [`provenance-and-ground-truth.md`](../references/provenance-and-ground-truth.md) — §8 evidence contracts
- [`.agents/skills/adjudicate-review/SKILL.md`](../../.agents/skills/adjudicate-review/SKILL.md) — findings from others
- [`agent-authored-code.md`](agent-authored-code.md) — the same revision-stamping standard, stated for every claim about code state, not only the ones that become issues
