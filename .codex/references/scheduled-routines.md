# Scheduled & Background Routines

The loop-first half of the workflow: recurring scholarly chores that should run *on a schedule* and surface only when they find something — not when you remember to run them. These are **Routines** (cron-scheduled remote agents managed by `$schedule`), not committed cron files, so they survive a closed laptop and run on web infrastructure.

> **Use Routines, not `CronCreate`,** for any away-from-keyboard work — Routines run on managed infra and persist; a local cron dies with the REPL. Each routine below is a *prompt + interval*; set them up once with `$schedule`.

## The four standing routines

| Routine | Interval | What it does | Push when |
|---|---|---|---|
| **Reproducibility drift** | nightly | Re-run `$audit-reproducibility` against the passport; diff stale claims | any FAIL (not EXPLAINED) |
| **Literature delta** | weekly | `$lit-review` sweep on your saved topics; diff against last week | new directly-relevant work |
| **Memory promotion** | monthly | `$promote-memory` — the five-critic council reviews `[LEARN]` candidates | items graduate to MEMORY.md |
| **Inbox triage** | daily / weekdays | `$triage-inbox` — referee requests, R&R deadlines, co-author asks | action proposed (always human-gated) |

**Push-on-failure, silence-on-success.** A nightly job that emails "all good" every day trains you to ignore it. These notify only on a real finding; a quiet run leaves no trace but a log line.

## Event-driven, not just scheduled

The nightly reproducibility job is the *backstop*. The *immediate* signal is the [`claim-reconcile`](../hooks/claim-reconcile.py) PostToolUse hook: the moment Codex edits an analysis script or display artifact, it flags manuscript claims as potentially stale and points you at `$audit-reproducibility` — so you catch drift during analysis, not the next morning. Regeneration outside Codex does not emit that tool event, so run the audit explicitly after external analysis runs.

## Setting one up

Create the scheduled task from a **natural-language description**:

```text
Nightly at 6am, run $audit-reproducibility against the current passport.
If any claim FAILs (not EXPLAINED), summarize which tables are affected and notify me;
otherwise exit quietly.
```

Configure the recurrence in Codex's scheduled-task controls after creating the task. Prefer one batched reproducibility task over many small checks. A remote task can see only the repository state available in its configured environment; local-only or uncommitted material must be checked locally.

`scripts/nightly-repro-check.sh` is the **local** runner for the nightly reproducibility check — required, not a preference, whenever the data is local or uncommitted (a cloud routine gets a fresh clone and cannot reach your data directory; see the mechanism table below). Schedule it via Desktop scheduled tasks or a machine cron. `$schedule` (cloud) fits only fully committed repos.

## Guardrails for unattended runs

- **Never point an unattended loop at a submission portal, shared/restricted data, or a co-author's inbox without a human gate.** Routines *propose*; a human *sends*. (`$triage-inbox` never auto-sends; the [`git-guardrails`](../hooks/git-guardrails.py) hook still blocks destructive git even in a routine.)
- **Bound the cost.** A nightly full-manuscript re-audit is fine; a nightly 7× `$seven-pass-review` is not — cost-pilot first.
- **Connectors are INCLUDED by default — least-privilege them.** Cloud Routines run with **all of your claude.ai connectors attached, write access included, and no approval prompts**. An unattended routine that only needs to read your repo should have Gmail/Calendar/Slack *removed from that routine's connector list* before it ever fires — the risk is not a missing connector but a fully-armed one acting without you. (Locally-authenticated MCP servers in your *terminal* sessions are a separate thing and may still be absent in other headless contexts — degrade gracefully either way.)

## Choosing a scheduling mechanism (verified 2026-08-21)

Codex offers **three** ways to schedule work. The distinction that matters for research
is **local file access** — a cloud routine runs against a *fresh clone* and cannot see local
or restricted data.

| | Cloud routines | Desktop scheduled tasks | `$loop` |
|---|---|---|---|
| Runs on | Anthropic-managed cloud | your machine | your machine |
| Requires machine on | No | **Yes** | Yes |
| Requires open session | No | **No** | **Yes** |
| Persistent across restarts | Yes | Yes | restored on `--resume` if unexpired |
| **Access to local files** | **No (fresh clone)** | **Yes** | Yes |
| Permission prompts | none (autonomous) | configurable per task | inherits from session |
| Minimum interval | **1 hour** | 1 minute | 1 minute |

### What this means for research workflows

- **Nightly reproducibility check on local data** → **Desktop scheduled tasks**. A cloud
  routine gets a fresh clone and cannot reach your data directory. This is the correct home
  for `scripts/nightly-repro-check.sh`.
- **Restricted-use microdata** → **Desktop only**, never cloud. A cloud routine would need the
  data in the repo, which the confidential-data rule forbids.
- **Watching a PR, a CI run, or a long build** → cloud routines (no machine required) or
  `$loop` if you are already in the session.
- **Polling inside an active session** → `$loop`. It dies with the session; that is fine for
  polling and wrong for anything that must survive a restart.

> Session-scoped scheduling remains session-scoped: *"Tasks are session-scoped: they live in
> the current conversation and stop when you start a new one."* Re-verified 2026-08-21 — the
> long-standing guidance to use durable scheduling for anything that must outlive a session
> still holds.

### Least privilege still applies

Cloud routines include **all connectors with write access by default**. Grant per task, not
per account.

## Push on failure, silence on success

**A nightly job that reports "all good" every day trains you to ignore it.** By the time it
reports something real, it has been noise for a month and you skim past it.

Scheduled checks notify **only when a human is needed**:

- **Failure** → push a notification with the failing gate, the artifact path, and the command
  to reproduce.
- **Success** → write the log, say nothing.
- **Did not run** → this is a **failure**, not silence. A check that could not run is not a
  passing check, and a scheduler that dies quietly is indistinguishable from one reporting
  clean. Alert on a missing heartbeat as loudly as on a red gate.

The same principle as monitor filters covering every terminal state: a filter matching only the
success line is silent through a crash, and **silence looks identical to "still running."**

## Cross-references

- `$schedule` — create/list/run routines.
- [`.codex/hooks/claim-reconcile.py`](../hooks/claim-reconcile.py) — the event-driven reconciliation hook.
- [`.codex/guidance/replication-protocol.md`](../guidance/replication-protocol.md) — what the reproducibility routine checks.
- [`.codex/guidance/confidential-data.md`](../guidance/confidential-data.md) — why unattended runs stay human-gated near restricted data.
