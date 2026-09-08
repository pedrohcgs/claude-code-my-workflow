---
name: coauthor-brief
description: "Generate a co-author / collaborator handoff brief for a multi-author, multi-machine project — summarizing what changed since the last brief (git delta), the current state of each artifact (manuscript, analysis, slides), open questions, how to reproduce locally, and any restricted-data access steps. Use when user says \"coauthor brief\", \"handoff brief\", \"bring my coauthor up to speed\", \"what changed since last week\", \"onboard a collaborator\", \"write a handoff for [name]\", or before sending a co-author the repo. NOT a commit or a checkpoint — it is the cross-machine, cross-person summary `meta-governance.md` only partially covers."
---



# $coauthor-brief — Collaborator Handoff Brief

Produce a single Markdown brief a co-author (or your future self on another machine) can read in a few minutes to know **what changed, where each artifact stands, what's blocked, and how to run the pipeline locally** — including restricted-data access steps a new collaborator needs. [`meta-governance.md`](../../../.codex/guidance/meta-governance.md) covers the *memory* side of cross-machine work (what syncs via git, what stays in gitignored native auto memory); this skill covers the *human* side: the per-person, per-session handoff.

**Core principle:** `$checkpoint` is for *you* resuming; `$coauthor-brief` is for *someone else* starting. The first answers "where am I?"; the second answers "what do I need to know to take over a piece of this?"

## When to use

- **Before sending a co-author the repo** (or a PR / branch) and you want them oriented, not archaeologizing the git log.
- **Onboarding a new RA / collaborator** who needs the reproduce-locally and restricted-data steps in one place.
- **Periodic sync** on a long multi-author project — "here's the delta since the last brief."
- **Cross-machine handoff** — finishing on the office desktop, picking up on the laptop, or handing the analysis half to a co-author who runs Python while you run R.

## When NOT to use

- For *your own* resume-point — use [`$checkpoint`](../checkpoint/SKILL.md).
- For distilling a noisy session before auto-compact — use [`$compress-session`](../compress-session/SKILL.md).
- For the commit message itself — that goes through [`$commit`](../commit/SKILL.md).

## Phases

### Phase 0 — Determine the "since" point

Resolve the delta window, in this priority order:

1. `--since <arg>` if given — a git tag, an ISO date, or `Ndays` (e.g. `--since v1.2`, `--since 2026-05-01`, `--since 14days`).
2. Else, the **last brief** — `ls -t quality_reports/handoffs/*.md | head -1`; use the date in its filename as the floor.
3. Else, fall back to **14 days** and say so in the brief (an unbounded `git log` is noise, not signal).

Echo the resolved window back before gathering ("Brief covers changes since `<tag/date>` …").

### Phase 1 — Gather the delta + project state

Read-only collection. Skip any source that doesn't apply (R-only, Python-only, no slides) rather than fabricating.

1. **Git delta** — `git log --oneline --since=<point>` (or `<tag>..HEAD`), `git diff --stat <point>..HEAD`, `git branch --show-current`, and `git log --all --oneline -15` to see co-authors' parallel branches. Group commits by area (manuscript / analysis / slides / infra).
2. **Reproducibility status** — if a passport exists at `quality_reports/passports/<slug>.yaml`, read the PASS / FAIL / EXPLAINED / STALE / UNVERIFIED roll-up ([`audit-reproducibility`](../audit-reproducibility/SKILL.md), [`replication-protocol.md`](../../../.codex/guidance/replication-protocol.md)). Note whether the analysis is replication-ready or has open FAILs.
3. **Open plan items** — most recent `quality_reports/plans/*.md` (status + any "Open questions" / "Next" lines) and the latest `quality_reports/session_logs/*.md` blockers.
4. **Environment / lockfiles** — locate the env capture a collaborator needs: `renv.lock` (R), `requirements.txt` / `environment.yml` / `uv.lock` (Python), Python interpreter and dependency-lock information, or whatever [`$capture-environment`](../capture-environment/SKILL.md) wrote. Record the exact restore command.
5. **Restricted-data steps** *(skip if `--no-data-section`)* — if the repo touches confidential/restricted data, read [`confidential-data.md`](../../../.codex/guidance/confidential-data.md) and summarize the access path a new collaborator needs (DUA / IRB approval, secure-enclave or openICPSR-restricted credentials, where the data lives, what is git-ignored vs committed). **Never copy actual restricted values, paths to live extracts, or credentials into the brief** — describe the *process to obtain access*, not the data.

### Phase 2 — Write the brief

Use the template below. Keep it tight (~1–2 screens). Concrete `path:line` pointers beat prose.

**Label every status statement `measured` or `inferred`.** *Measured* means a command was run and what you are reporting is its output — **name the command**. *Inferred* means you believe it from reading the code, the diff, or a run from some earlier day. Both belong in a brief; mixing them silently does not, because the reader cannot tell which claims they can build on without re-checking. Write `replication-ready (measured: Rscript scripts/R/00_run_all.R — 0 FAIL)`, not `replication-ready`.

**Disposition delegated work item by item.** Anything handed to a co-author, an RA, or an agent gets its own line and its own state — done (with the evidence) / in progress / blocked (on what) / not started. *"Mostly done"* is not a disposition: it hands the reader the job of finding the missing piece, which is precisely the job the brief exists to do.

```markdown
---
date: YYYY-MM-DD
for: [collaborator name or "all coauthors"]
since: [tag | date | Ndays]
branch: [current branch]
---

# Co-Author Brief — [project / paper short name]

## What changed since [since-point]
[3–8 bullets, grouped by area. Each: what changed + why it matters to a reader, not raw commit subjects.]
- **Analysis:** re-ran the main specification on the de-duplicated sample (533 fanned-out rows dropped); headline estimate now −1.19 — see `scripts/R/03_analyze.R:147`.
- **Manuscript:** Table 2 + §4.2 rewritten to match; Figure 3 regenerated.
- **Slides:** untouched.

## Current state of each artifact
| Artifact | Path | State | Evidence (measured / inferred) |
|---|---|---|---|
| Manuscript | `manuscript.tex` | drafting §5 | inferred — §5 read, not compiled since the Table 2 rewrite |
| Analysis | `scripts/R/` | replication-ready | measured: `Rscript scripts/R/00_run_all.R`, passport 11 PASS / 1 EXPLAINED / 0 FAIL |
| Slides | `Slides/` | current | measured: `git log --since=<point> -- Slides/` returns nothing |

## Delegated work — one line per item
[Everything handed to a co-author, an RA, or an agent, dispositioned individually. No roll-ups.]
| Item | Owner | State | Evidence / blocker |
|---|---|---|---|
| Re-run Table 3 with the new sample filter | [name] | done | measured: output diff vs `_outputs/tab3_prev.csv`, 2 cells moved |
| Appendix B proof of Lemma 2 | [name] | blocked | waiting on the boundedness condition in Q1 below |

## Open questions / decisions needed
[Things the co-author should weigh in on. Mark Q1, Q2…; flag which block progress.]

## Reproduce locally
1. Clone + branch: `git checkout <branch>`
2. Restore environment: `Rscript -e 'renv::restore()'` (or `pip install -r requirements.txt` or `uv sync`).
3. Run the pipeline: `Rscript scripts/R/00_run_all.R` (or `python scripts/python/run.py` or `make all`).
4. Verify: `$audit-reproducibility manuscript.tex` should report 0 FAIL.

## Restricted-data access (if applicable)
[Process to obtain access — DUA/IRB/enclave/openICPSR-restricted steps. NO actual data, paths to live extracts, or credentials. See confidential-data.md.]

## Recommended git topology for this project
- One **feature branch per author** (`feat/<author>-<topic>`); rebase on `main`, open a PR, merge via `$commit`.
- `MEMORY.md` is **committed** — generic learnings sync to everyone.
- Native auto memory (`~/.codex/projects/<project>/memory/`) and `quality_reports/session_logs/` stay **local** — never expect a co-author to have yours (see meta-governance.md).
- Pull before you brief; brief before you hand off.
```

### Phase 3 — Save and summarize

1. Write to `quality_reports/handoffs/YYYY-MM-DD_coauthor-brief.md` (create `quality_reports/handoffs/` if missing). If `--for` is set, suffix the slug (`…_coauthor-brief_<name>.md`).
2. Print to chat: saved path, the resolved since-window, counts (commits summarized / open questions / artifacts), and whether the data section was included or skipped.

## Output / report format

A single Markdown handoff doc at `quality_reports/handoffs/YYYY-MM-DD_coauthor-brief.md` matching the Phase 2 template, plus a one-line chat summary. No edits to any other file.

## Exit behavior

- **Brief written:** exit 0 with the saved path and summary line.
- **No "since" resolvable and no git history in window:** still write the brief with an explicit "no changes in window" note rather than failing — a co-author starting fresh still needs the state + reproduce + data sections.
- **Restricted-data repo detected but `confidential-data.md` missing:** write the brief, leave the data section with a `TODO: complete per your DUA` placeholder, and warn — do **not** guess the access process.

## Flags

- `--since` `<tag|date|Ndays>` — Baseline to diff against — a git tag, an ISO date, or `Ndays` (e.g. `14days`). Default: the previous brief in `quality_reports/handoffs/`, else the last tag.
- `--for` `<name>` — Tailor the brief to a specific collaborator (e.g. surface the restricted-data access steps they still need).

## Cross-references

- [`.codex/guidance/meta-governance.md`](../../../.codex/guidance/meta-governance.md) — the cross-machine memory model (what syncs, what stays local) this brief operationalizes for *people*.
- [`.agents/skills/capture-environment/SKILL.md`](../capture-environment/SKILL.md) — produces the lockfiles the "Reproduce locally" section points at.
- [`.agents/skills/checkpoint/SKILL.md`](../checkpoint/SKILL.md) — the *self*-resume companion (this skill is the *other-person* handoff).
- [`.agents/skills/compress-session/SKILL.md`](../compress-session/SKILL.md) — distil a noisy session before compaction (orthogonal; run before briefing if context is fat).
- [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) — restricted-data handling; the data section summarizes its access steps without exposing data.

## What this skill does NOT do

- **Push, PR, or merge.** It writes a doc. Branch/PR/merge is [`$commit`](../commit/SKILL.md)'s job.
- **Run the pipeline or audit numbers.** It *reports* passport status if one exists; it does not re-run analysis or re-verify claims — that's [`$audit-reproducibility`](../audit-reproducibility/SKILL.md).
- **Capture the environment.** It locates and links existing lockfiles; generating them is [`$capture-environment`](../capture-environment/SKILL.md).
- **Expose restricted data.** It describes the *access process* only — never copies confidential values, live data paths, or credentials into a brief that may be emailed or committed.

