# GitHub as Memory — issues, progress reports, and the durable record

**Context windows end. Repositories do not.** Anything that matters and lives only in a chat
transcript is already lost — you just have not noticed yet. This rule is about deliberately
moving the record out of the conversation and into the repository, where a future session, a
coauthor, or a replicator can actually find it.

Three durable stores, each for a different kind of thing:

| Store | Holds | Survives |
|---|---|---|
| **GitHub issues** | authenticated defects and open questions, with evidence | forever, searchable, linkable |
| **Progress reports** (`quality_reports/`) | what was done, why, what remains | forever, in-repo |
| **`MEMORY.md`** | generalisable lessons worth carrying to the *next* project | forever, committed |

Everything else — the reasoning, the false starts, the dialogue — is disposable, and should be.

## 1. Issues are the defect memory

An issue is not a to-do list entry. It is **the durable record of a defect, its evidence, its
repair, and the limits of that repair**, written so that none of it can disappear into a
branch, a chat, or a commit message. Full evidence standard and the seven-section closure
comment: [`issue-ledger.md`](issue-ledger.md).

**Open one when** a bounded check authenticates a violation of a documented contract, a
statistical law, an invariant, a reproducibility requirement, or a user-facing promise.

**Why issues rather than a TODO file:** they are searchable across years, they carry threaded
evidence, they link to the commits that fixed them, they survive every context reset, and a
closed one with a proper final comment answers *"did we already look at this?"* — which is the
question that otherwise costs a day.

**Do not quietly fix an authenticated defect.** A silent repair destroys the record, and the
next person cannot distinguish a deliberate change from a regression.

## 2. Progress reports are the work memory

At the end of any substantial working session, write what happened to
`quality_reports/session_logs/YYYY-MM-DD_description.md`. The Stop hook drafts one
automatically; the point is that it lands **on disk**, not that you typed it.

A useful report is short and answers four questions:

1. **What changed** — files, and the one-line reason for each.
2. **What was decided, and why** — especially decisions that closed off alternatives. This is
   the part that is expensive to reconstruct and cheap to write down.
3. **What was tried and abandoned** — *and why it failed.* The most valuable section, and the
   one always omitted. It stops the next session from re-walking a dead end.
4. **What remains** — open questions, blocked items, the obvious next step.

Longer-lived records go beside it: `quality_reports/plans/` for approach before work,
`quality_reports/specs/` for requirements, `quality_reports/qualification/LEDGER.md` for what
has been proven to detect anything, `quality_reports/merges/` for release-time reports.

> **Write it before you need it.** A report written while the reasoning is live takes five
> minutes. Reconstructed from a diff a month later, it takes an hour and is wrong.

## 3. `MEMORY.md` is the lesson memory

Issues remember *this* defect. Progress reports remember *this* session. `MEMORY.md` remembers
what you would want to know **on a different project**.

Promotion is deliberate, not automatic: native auto memory accumulates machine-local
observations, and [`$promote-memory`](../../.agents/skills/promote-memory/SKILL.md) runs a five-critic
council over candidates before anything is committed. The test is the same every time:

> *Would a researcher in a different field, forking this template, be better off knowing this?*

If yes, it is a lesson. If it is about this machine, this dataset, or this week, it stays local.

## 4. Correcting the record

When a previously reported claim turns out to be wrong, **the correction leads** — first
sentence of the next report, not a footnote in a later one. A record that quietly stops
mentioning a retracted finding is worse than one that never mentioned it, because it reads as
consistent.

When results are re-run at higher fidelity, the new artifact **supersedes** the old
*explicitly*, and predecessors are preserved unchanged as the record.

## 5. The pushed repo is the status report

Commit and push each stage as it lands — **including failures, plainly labelled**. Then a
coauthor, a second machine, or you-in-three-weeks needs only `git pull` to know where things
stand. No status email, no summary to write, no memory to trust.

## Cross-references

- [`issue-ledger.md`](issue-ledger.md) — the evidence standard for an issue
- [`session-logging.md`](session-logging.md) — the three logging triggers
- [`repo-hygiene.md`](repo-hygiene.md) — the record lives in reports, so files do not have to carry it in their names
- [`../references/verification-ladder.md`](../references/verification-ladder.md) — rung 5, the ledger
