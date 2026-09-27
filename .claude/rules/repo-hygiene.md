# Repo Hygiene — scratch must not become main

Agents try things. Claude and Codex will each explore five approaches to a problem, and four of
them produce files. **Those four must not survive.** A repo where every abandoned attempt was
left in place is not a record of the work — it is noise that makes the real work unfindable,
and it is the single fastest way for a project to feel unmaintained while the code is fine.

Enforced by `scripts/check-repo-hygiene.py`, which runs inside `./scripts/backtest.sh` — and
therefore on every commit **once `./scripts/install-hooks.sh` has been run** (a fresh clone's
hook is inert until then), plus unconditionally in CI.

## The rule

> **Anything you would not defend in a code review does not get committed as a main file.**

Three destinations, and everything goes to exactly one:

| Destination | For | Committed? |
|---|---|---|
| **The scratchpad** (outside the repo, or `explorations/`) | trying something; you do not yet know if it works | `explorations/` is **tracked** but exempt from the draft-name checks — its own protocol permits versioned/dated files there; clean it up when the exploration ends |
| **The working tree** (`Slides/`, `Quarto/`, `scripts/`, `.claude/`) | the approach you chose and would defend | yes |
| **An archive** (`master_supporting_docs/`, a dated `explorations/` subdir) | superseded work worth keeping for the record | yes, **with a README saying why** |

## Where each kind of file goes

The layout follows the AEA Data Editor's replication-package advice: inputs, code and results in
separate places, and one command that rebuilds every result. A project whose `CLAUDE.md` folder
tree says otherwise wins; this is the default.

| Kind | Location | Committed? |
|---|---|---|
| Raw inputs | `data/raw/` — read-only; code never writes here | only if the licence allows; never restricted data ([`confidential-data.md`](confidential-data.md)) |
| Analysis code | `scripts/<lang>/` — numbered stages (`01_load.R`, …) plus one master script (`00_run_all.R`, `99_run_all.do`) | yes |
| Package-style functions and tests | `R/`, `tests/testthat/` ([`r-package-conventions.md`](r-package-conventions.md)) | yes |
| Generated results | top-level `output/`, never inside `scripts/`; subfolders per project (`tables/`, `figures/`, or by analysis) | tables, figures, logs, `sessionInfo*.txt`: yes — after disclosure clearance on restricted data. Regenerable intermediates (`.rds`, `.parquet`, `.dta`, …): no |
| Hooks | `.claude/hooks/` | yes, when `.claude/settings.json` calls them — a clone would break otherwise; personal hooks go in `settings.local.json` |
| Plans, session logs | `quality_reports/plans/`, `quality_reports/session_logs/` | whatever the project's `.gitignore` says; this template ignores them (owner work, not template content) — `git add -f` one a collaborator needs |
| Scratch | the session scratchpad, or `explorations/` under [its protocol](exploration-folder-protocol.md) | scratchpad: no; `explorations/`: yes, cleaned up when the exploration ends |

## What the checker rejects

- **Root clutter.** A file at the repository root that is not on the allowlist. Top-level space
  is for things a newcomer must see first; everything else lives in a directory.
- **Draft names.** `untitled`, `tmp`, `temp`, `scratch`, `foo`, `bar`, `baz`, `asdf`, `test123` —
  as the whole name or a prefix ending at a separator (`scratch_x.py`, `tmp.R`, `scratch-notes.md`
  count; `scratchpad-notes.md` and `template.md` do not — the word must be followed by a
  non-alphanumeric character).
- **Superseded copies.** `analysis_old.R`, `deck_backup.tex`, `notes_copy.md`. If it is worth
  keeping, archive it with a reason; otherwise delete it — **git already has the history.**
- **Version-in-filename.** `model_v2.R`, `paper_final.tex`, `script_fixed.py`. That is what git
  is for, and `_final` is never final. *(Exempt: `explorations/` — its
  [protocol](exploration-folder-protocol.md) deliberately allows `_v1`/`_v2` iteration there.)*
- **Accidental duplicates.** `notes 2.md` **when `notes.md` also exists** (the true copy
  signature — a bare `Lecture 2.tex` is an ordinary academic filename and is not flagged),
  and `data(1).csv`.
- **Paths that differ only by case or Unicode form.** `Notes.md` beside `notes.md`, or an accented name stored
  both composed and decomposed: two files in git, one on macOS and Windows, so a checkout there silently
  loses one.
- **Tracked build artifacts.** `.aux`, `.log`, `.synctex.gz`, `.pyc`. Regenerable output does
  not belong in version control.
- **Edited append-only records.** A commit that edits or removes a committed line of
  `quality_reports/replication-log.md` or `quality_reports/spec-ledger.md` — checked against the
  last commit at pre-commit, and against the base branch in CI. A correction is a new entry;
  a disclosure redaction is committed with `ALLOW_LOG_REWRITE=1` and the reason in the message.
- **Undocumented archives.** An archive directory with no README is indistinguishable from
  abandoned clutter. *(The checker enforces this for the named archive roots —
  `explorations/`, `master_supporting_docs/` — not for every directory in the tree.)*

*Numbered pipeline stages are exempt* — `01_explore.R`, `02_clean.R`, `03_analyze.R` are
idiomatic, not drafts.

## Archiving, not deleting

When work is superseded but the record matters — a prior specification, an approach that failed
for an interesting reason, a deck from a previous term:

1. Move it to a **dated** subdirectory: `explorations/2026-08_did-alternative-weighting/`.
2. Add a README with **three lines**: what this was, why it was superseded, and what replaced it.
3. Never edit it again. An archive that changes is not an archive.

> **A failed approach is evidence.** It tells the next person — often you — which routes are
> already closed. That is worth keeping, but only if it is labelled. An unlabelled dead end
> costs more than it saves.

## For agents specifically

- Write experiments to the session scratchpad, **not** the repo. If a scratch file must live in
  the repo to be run, put it under `explorations/` and delete it when done.
- **Never** create `foo_v2.R` beside `foo.R` to try something. Edit `foo.R`; git is the undo.
- When an approach is abandoned, **remove its files in the same commit** that lands the chosen
  approach. Do not leave both and let the reader guess which is live.
- If you are unsure whether something is scratch: it is scratch until it passes a gate.

## Cross-references

- [`.claude/rules/exploration-folder-protocol.md`](exploration-folder-protocol.md) — how `explorations/` is structured
- [`.claude/rules/meta-governance.md`](meta-governance.md) — what is committed vs local
- [`progress-reports.md`](progress-reports.md) — where the record of *work* lives, so files do not have to carry it
