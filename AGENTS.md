# AGENTS.md — working in this repository with an agent other than Claude Code

This repository was built for Claude Code. [`CLAUDE.md`](CLAUDE.md) and
[`.claude/rules/`](.claude/rules/) hold its instructions, and they apply to you as well. Read
`CLAUDE.md` before your first change. This file adds what Claude Code would otherwise enforce
for you. It is written for Codex, Google Antigravity, and any other agent that reads
`AGENTS.md` or the skills in `.agents/skills/`.

## What Claude Code enforces that you must do by hand

Claude Code runs guard hooks before its shell commands and file edits. You do not, so follow
them yourself:

1. **No destructive git.** Never run `git reset --hard`, `git clean -f`, `git push --force`, or
   `git add -A` / `git add .`; stage files by name. Never discard uncommitted work. Do not merge,
   rebase or pull over a dirty tree: commit first, or stash under a label that says what it is.
2. **Leave the gate files alone.** Do not change `.claude/settings*.json`, `.claude/hooks/` or
   `.githooks/` unless the user asks. If they ask, make the change an ordinary diff and say so
   in the pull request.
3. **Issues go through the duplicate check.** Never run `gh issue create` or post to the issues
   API directly. Use `python3 scripts/file-issue.py --title "..." --body-file <file>`. It
   searches open and closed issues first, and pins the repository to your `origin`.
4. **Pull requests go to your own repository.** Read `git remote get-url origin` and pass it to
   `gh pr create --repo HOST/OWNER/NAME`. In a fork, a bare `gh pr create` targets the parent
   repository. The template itself, `github.com/pedrohcgs/claude-code-my-workflow`, accepts
   pull requests from its collaborators only.

## Before every commit

- Work on a branch. Never commit to `main`, and never merge: the user merges.
- Run `./scripts/backtest.sh`. It must pass. Once `./scripts/install-hooks.sh` has been run, the
  git pre-commit hook runs it on every commit, whichever agent commits. Ask the user before you
  run the installer, because it changes the clone's git configuration.
- For a changed `.qmd`, `.tex` or `.R` file, render or compile it and run
  `python3 scripts/quality_score.py <file>`. Nothing below 80 is committed.
- Write commit and pull-request messages that say what is now true, and list every changed
  default a forker would notice.

## Facts

The gates check that the repository agrees with itself. They cannot check that it is true. A
pull request written by another agent passed every backtest gate with three wrong names of real
people, a cited source that did not exist, and guessed version numbers.

- Every name, affiliation, version number, price, date, count and URL you write must come from
  a source you read in this session. Give the source in the pull request.
- If you cannot check it, leave it out or mark it unverified. Do not infer a person's name from
  a handle, or a version number from a pattern.
- Current Claude model versions live only in
  [`.claude/references/model-versions.md`](.claude/references/model-versions.md). Everywhere else
  refers to tiers ("the current Opus").
- Report what you ran and what it printed. Do not report a check you did not run.

## Scope and placement

Do exactly what was asked (the *Scope Discipline* section of `CLAUDE.md`). Files go where
[`.claude/rules/repo-hygiene.md`](.claude/rules/repo-hygiene.md) puts them: nothing new at the
repository root, and no scratch files committed. Before touching data, read
[`.claude/rules/confidential-data.md`](.claude/rules/confidential-data.md): restricted data
never leaves the machine.

## Skills

[`.agents/skills/`](.agents/skills/) holds generated wrappers for the skills in
`.claude/skills/` that one agent can run end to end. Each wrapper points to the real
instructions. In Codex, mention one with `$name` or list them with `/skills`; in Antigravity,
type `/name`. Where a skill hands a step to a Claude Code agent, do the step where it appears
and let it gate what follows. Where that step needs a context that has not seen your work (a
claim verifier that must not see the draft), use a separate session that has not seen it. If you
cannot, mark its results *not independently verified* and say so. Skills built on several independent reviewers (such as `/review-paper --peer`),
and skills that manage Claude Code itself, are not bridged. The list and the reason for each
are in [`scripts/sync-agent-skills.py`](scripts/sync-agent-skills.py). To change a skill, edit
`.claude/skills/<name>/SKILL.md` and run `python3 scripts/sync-agent-skills.py`. The backtest
fails while a wrapper is out of date.
