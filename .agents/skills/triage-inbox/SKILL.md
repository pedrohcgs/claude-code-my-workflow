---
name: triage-inbox
description: "Triage academic email and calendar (Gmail / Google Calendar via the session's MCP) into a prioritized digest plus a referee-obligations tracker — classifying referee requests, R&R and editor correspondence, co-author threads, seminar and conference invites, and grant/admin deadlines, and proposing a human-gated action for each (draft reply, calendar hold, scaffold a project, snooze). Use when user says \"triage my inbox\", \"check my academic email\", \"what needs my attention this week\", \"go through my mail\", or when run as a scheduled routine. NEVER auto-sends or auto-accepts anything."
---



# $triage-inbox — Academic Inbox + Calendar Triage

Turn a noisy academic inbox into a short, decision-ready digest. Fetch recent mail and calendar context through the session's MCP servers (Gmail / Google Calendar), classify each thread into the categories an academic actually acts on, and propose **one** action per thread — always human-gated. The companion artifact is a running **referee-obligations tracker** so you never silently overcommit to reviews.

**Core principle:** this skill *reads, classifies, and proposes*. It drafts; it never sends, accepts, declines, or books anything without you. That boundary is what makes it safe to run unattended as a scheduled tasks (#cross-references) routine.

## When to use

- **Weekly / daily sweep** — "what landed that needs a decision?" without reading every thread yourself.
- **As a scheduled routine** — wired to scheduled tasks to run each morning and leave a digest waiting.
- **Referee-load management** — keep an honest count of outstanding reviews against a standing cap before you say yes to one more.
- **R&R / editor deadline capture** — turn "minor revision due in 6 weeks" buried in an email into a calendar hold proposal.

## When NOT to use

- To actually send a reply, accept an invite, or book an event — this skill stops at *proposals*. You confirm and execute.
- To handoff a project to a co-author — that's [`$coauthor-brief`](../coauthor-brief/SKILL.md).
- To draft the R&R response document itself — that's [`$respond-to-referees`](../respond-to-referees/SKILL.md).

## Phases

### Phase 0 — Pre-flight (MCP check, window, referee cap)

1. **Confirm MCP access.** This skill reaches mail/calendar **only** through the session's MCP tools (`Gmail` search/read, `Google Calendar` list/suggest). They are session-scoped — in a headless `claude -p` or cron run they may be **absent**. Probe once (e.g. list labels / list calendars). If unavailable, **degrade gracefully**: emit a tracker-only digest from the on-disk tracker (Phase 3) plus a one-line "MCP servers not reachable in this run — skipped fetch" note, and exit cleanly. Never fail the routine over a missing server.
2. **Resolve the lookback window** — `--since` (an ISO date or `Ndays`), else the timestamp of the last digest in `quality_reports/inbox/`, else default **7 days**. Echo it back.
3. **Set the referee-load cap** — `--cap` if given, else read the standing cap from the tracker header, else default **3** concurrent reviews. This cap gates the recommendation in Phase 2, not your inbox.
4. **Echo a one-line pre-flight** before fetching: window, cap, calendar on/off (`--no-calendar`), dry-run on/off.

### Phase 1 — Fetch + classify

1. **Fetch** recent threads via the MCP Gmail search tool over the window; if calendar is on, pull existing events/free-busy for the deadline-conflict check.
2. **Classify** each thread into exactly one bucket:

   | Bucket | Signals |
   |---|---|
   | **Referee request** | "invite you to review", journal/editor sender, manuscript ID, "would you be willing" |
   | **R&R / editor correspondence** | "revise and resubmit", "minor/major revision", decision letter, due-date language |
   | **Co-author thread** | known collaborator, shared-paper subject, "can you", "your section", attachment churn |
   | **Seminar / conference invite** | "invited talk", "submit by", CFP, "seminar series", scheduling polls |
   | **Grant / admin deadline** | funder name, "submission deadline", reporting/compliance, IRB/DUA renewals |
   | **Noise** | newsletters, receipts, auto-notifications — counted, not itemized |

3. Capture per thread: sender, subject, a one-line gist, any **explicit deadline**, and the bucket.

### Phase 2 — Propose one action per thread (NEVER auto-send)

For each non-noise thread, propose exactly one of:

- **Draft reply** — write a courteous draft *for review*. Do not send. If the Gmail MCP exposes a create-draft tool, you MAY stage a Gmail draft (which still requires the user to hit send) — otherwise inline the text in the digest.
- **Calendar hold** — for an R&R / grant / talk deadline, propose a hold (title, date, lead-time reminder). Surface conflicts against existing events. **Propose only** — booking is the user's click.
- **Scaffold a referee project** — for an *accepted* (or leaning-yes) referee request under the cap, offer to scaffold a referee project (dated folder + manuscript + notes template). Over the cap → recommend a polite decline draft instead, and say why ("4 reviews already open vs. cap of 3").
- **Summarize + offer a brief** — for a co-author thread, distill the asks and offer to generate a [`$coauthor-brief`](../coauthor-brief/SKILL.md).
- **Snooze** — defer with a re-surface date; nothing else happens.

**Hard gate:** every outbound action (send, accept, decline, book, scaffold) waits for explicit user confirmation. Drafts and holds are *proposals*. Honor `--dry-run` by proposing without staging even drafts.

### Phase 3 — Emit digest + update the obligations tracker

1. **Digest** → `quality_reports/inbox/YYYY-MM-DD_triage.md` (create the dir). Buckets ordered by urgency; each item is a one-liner + its proposed action. Noise is a count, not a list.
2. **Referee-obligations tracker** → `quality_reports/inbox/referee-obligations.md` (a persistent ledger, not dated). Append/refresh rows for any review accepted, declined, or completed this run; recompute open count vs. cap; flag overdue rows.

## Output / report format

```markdown
# Inbox Triage — YYYY-MM-DD   (window: last N days · referee cap: K)

## Needs a decision (M)
- **[R&R]** *J. of X* — minor revision, **due 2026-07-15**. → Propose calendar hold (−14d reminder); conflicts: none.
- **[Referee]** *Econometrica* — review request, manuscript 12-345. Open reviews 2/3 → under cap. → Offer to scaffold a referee project.
- **[Co-author]** A. Smith — "can you redo Table 3 with not-yet-treated controls?" → Summarized; offer `$coauthor-brief`.

## FYI / snoozed (P)
- **[Seminar]** Dept. brown-bag poll — snoozed to 2026-06-16.

## Noise: 24 threads (newsletters, receipts) — not itemized.

## Referee load: 2 open / cap 3  (see referee-obligations.md)
```

Plus the one-line chat summary: digest path, counts per bucket, open-reviews-vs-cap, and whether the MCP fetch ran or was skipped.

## Exit behavior

- **Normal run:** write the digest, refresh the tracker, print the summary line. No mail sent, no event booked, no project scaffolded — those await your confirmation.
- **MCP unavailable (headless/cron):** tracker-only digest + "fetch skipped" note; exit 0. The routine must not error just because a session server is absent.
- **Over the referee cap:** still surface the request, but the proposed action is a decline draft with the count as rationale — never a silent scaffold.
- **`--dry-run`:** propose everything, stage nothing (not even a draft).

## Flags

- `--since` `<Ndays|date>` — Lookback window. Default: the last digest's timestamp, else 7 days.
- `--cap` `<N>` — Standing concurrent-review cap that gates referee scaffolding. Default: the tracker header value, else 3.
- `--no-calendar` — Skip the Calendar MCP entirely; classify mail only, no holds proposed.
- `--dry-run` — Propose actions without staging anything (no Gmail drafts created).

## Cross-references

- [`.agents/skills/coauthor-brief/SKILL.md`](../coauthor-brief/SKILL.md) — the handoff brief offered for co-author threads.
- [`.agents/skills/respond-to-referees/SKILL.md`](../respond-to-referees/SKILL.md) — drafts the R&R response document once a revision deadline surfaces here.
- scheduled tasks — wire this skill into a cron routine; the human-gated design is what makes unattended runs safe.
- [`.codex/guidance/orchestrator-protocol.md`](../../../.codex/guidance/orchestrator-protocol.md) — the "no daemon, user/skill-initiated, human-in-the-loop" contract this skill honors for outbound actions.
- [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) — never copy attachment contents, restricted data, or credentials into a digest that may be committed.

## What this skill does NOT do

- **Send, reply, accept, decline, or book.** It drafts and proposes; you execute. No exceptions, including in scheduled runs.
- **Auto-scaffold a referee project.** It *offers* the scaffold; creating it waits for your yes and respects the cap.
- **Run unattended with side effects.** Outbound actions are always human-gated — the only thing a cron run writes is the digest and the tracker.
- **Read or store message bodies wholesale.** It extracts gists, deadlines, and senders; it does not archive email contents or attachment data into the repo.
- **Reach mail/calendar without MCP.** No direct IMAP/API credentials — everything goes through the session's MCP servers, and their absence degrades gracefully.

