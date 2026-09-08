# Repo Hygiene — scratch must not become main

Agents try things. Codex and Codex will each explore five approaches to a problem, and four of
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
| **The working tree** (`Slides/`, `scripts/`, `.codex/`, `.agents/`) | the approach you chose and would defend | yes |
| **An archive** (`master_supporting_docs/`, a dated `explorations/` subdir) | superseded work worth keeping for the record | yes, **with a README saying why** |

## What the checker rejects

- **Root clutter.** A file at the repository root that is not on the allowlist. Top-level space
  is for things a newcomer must see first; everything else lives in a directory.
- **Draft names.** `untitled`, `tmp`, `temp`, `scratch`, `foo`, `bar`, `baz`, `asdf`, `test123` —
  as the filename or its prefix (`scratch_x.py` counts; `scratchpad-notes.md` also counts,
  deliberately: rename it).
- **Superseded copies.** `analysis_old.R`, `deck_backup.tex`, `notes_copy.md`. If it is worth
  keeping, archive it with a reason; otherwise delete it — **git already has the history.**
- **Version-in-filename.** `model_v2.R`, `paper_final.tex`, `script_fixed.py`. That is what git
  is for, and `_final` is never final. *(Exempt: `explorations/` — its
  [protocol](exploration-folder-protocol.md) deliberately allows `_v1`/`_v2` iteration there.)*
- **Accidental duplicates.** `notes 2.md` **when `notes.md` also exists** (the true copy
  signature — a bare `seminar-draft.tex` is an ordinary academic filename and is not flagged),
  and `data(1).csv`.
- **Tracked build artifacts.** `.aux`, `.log`, `.synctex.gz`, `.pyc`. Regenerable output does
  not belong in version control.
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

- [`.codex/guidance/exploration-folder-protocol.md`](exploration-folder-protocol.md) — how `explorations/` is structured
- [`.codex/guidance/meta-governance.md`](meta-governance.md) — what is committed vs local
- [`progress-reports.md`](progress-reports.md) — where the record of *work* lives, so files do not have to carry it
