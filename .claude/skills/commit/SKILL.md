---
name: commit
description: Commit the current work — runs the quality, consistency and passport gates, branches off main if needed, stages specific files, and writes a commit whose subject states what is now true. Pushes and opens a pull request only with --pr or when the user asks; never merges — a merge happens only when the user explicitly says to merge. Use ONLY on explicit commit intent — user says "commit", "let's commit this", "open a PR", or prefixes with `/commit`. Do NOT auto-invoke on vague end-of-task phrases ("we're done", "wrap up") — those require explicit confirmation first. Never force-pushes or skips hooks.
argument-hint: "[optional: commit message] [--pr]"
allowed-tools: ["Bash", "Read", "Glob", "Agent", "Task"]
---

# Commit

Verify the gates, then commit. **A commit is not a pull request, and a pull request is not a merge.**
This skill stops after the commit. It pushes and opens a pull request only with `--pr` or when the
user asks, and it **never merges** — a merge happens only when the user explicitly says to merge
that pull request (see "Merging" below). Reviewers such as Codex and Copilot comment after a pull
request opens; merging before they report skips their review.

## Steps

### Step 0: Quality Gate (Pre-Commit)

**Run before branching.** For every changed `.qmd`, `.tex`, or `.R` file that has quality rubrics, run:

```bash
python3 scripts/quality_score.py <changed-file-paths>
```

- If any file scores below **80**, halt and report the findings. The user must either fix the issues or explicitly override with phrases like *"commit anyway"* or *"skip quality gate"*. Once `./scripts/install-hooks.sh` has been run, `.githooks/pre-commit` re-runs the same ≥80 gate on the staged `.qmd`/`.tex`/`.R` files, so carry an approved override into Step 4 as `SKIP_QUALITY_GATE=1 git commit ...` and record the override reason in the commit message. That variable skips only the quality score; the backtest still runs. Never fall back to `git commit --no-verify`.
- If all files score 80+, continue.

Spawn the **verifier** agent (via the `Agent` tool with `subagent_type=verifier`) to run compilation/render checks on the changed files. Report pass/fail before committing.

### Step 0b: Consistency Gate (Pre-Commit)

**Runs unconditionally.** The full backtest suite — all eleven gates (surface-sync count claims like `"18 agents, 61 skills, 37 rules, 11 hooks"` and marked tables, skill integrity, model currency, links, spec conformance, staleness, repo hygiene, derived counts, ledger coverage, hook battery, portability):

```bash
./scripts/backtest.sh
```

- **Exit 0:** all gates green — continue.
- **Nonzero:** at least one gate is red — print its output and halt. Fix, then re-run. Do not proceed past this gate on a red result, even with "commit anyway": a red gate is drift that the next reader inherits, and small count drift has repeatedly cost follow-up PRs.

### Step 0c: Passport Check (Pre-Commit)

If the diff touches a manuscript (`.tex`/`.qmd`) that has a passport in `quality_reports/passports/`, any `source_file` a passport lists, or any file a claim declares as a display (its `location:`, or an `appears_in` `path:`), read that passport: a load-bearing claim with `status: FAIL` or `STALE` is a **must-fix** — halt, name the claim, and point at `/audit-reproducibility` (or the stale script) before committing. A touched display triggers the check for the same reason a touched script does: editing one artifact's copy of a number desynchronizes it from that number's other displays — the supplement or deck holding the same value was not necessarily updated in the same commit. Skip silently when no passport exists.

### Step 1: Check current state

```bash
git status
git diff --stat
git log --oneline -5
```

### Step 2: Create a branch (when on main)

Never commit directly to `main`. If the current branch is `main`, create one; if you are already on
a feature branch, commit there.

```bash
git checkout -b <short-descriptive-branch-name>
```

### Step 3: Stage files

Add specific files (never use `git add -A`):

```bash
git add <file1> <file2> ...
```

Do NOT stage `.claude/settings.local.json` or any files containing secrets.

### Step 4: Commit with a descriptive message

If `$ARGUMENTS` is provided, use it as the commit message. Otherwise, analyze the staged changes and write a message that explains *why*, not just *what*.

**The subject line states what is TRUE AFTER the commit** — a plain sentence about behavior that a reader could go and test. *"Fixed review feedback"* and *"Updated the checker"* narrate your afternoon and tell a reader nothing; *"The parity gate refuses a fixture whose hash is unregistered"* is a claim they can check against the code. Process narration — which review round it came from, who asked, how many attempts it took — belongs in the body if it belongs anywhere. The body still carries the *why*; the subject carries the claim.

```bash
git commit -m "$(cat <<'EOF'
<commit message here>
EOF
)"
```

### Step 5: Push and open a pull request — only with `--pr` or when the user asks

Without `--pr`, and without the user asking for a pull request, skip this step: the commit stays
local and the report says so.

```bash
git push -u origin <branch-name>
gh pr create --title "<short title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points>

## Changed defaults
<"None", or each default a forker will notice changing: a setting, a threshold, a hook that now fires, a path that moved>

## Test plan
<checklist>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 6: Report

Report the commit (hash and subject), the branch, and — if a pull request was opened — its URL.
Say plainly that nothing was merged.

## Merging — only when the user says so

A merge is never a step of this skill. Merge only when the user explicitly asks to merge a specific
pull request ("merge #155"); "ship it", "done" or "commit" are not a merge instruction. Before
merging, check that the pull request's CI is green and that its reviews (human, Codex, Copilot)
have been read and answered.

```bash
gh pr merge <pr-number> --merge --delete-branch
git checkout main
git status --porcelain          # must print nothing before the next line runs
git pull
```

**Expect the tree to be dirty here — that is what Step 3 is for.** Staging specific files means
everything the session touched but did not stage, plus every untracked artifact, is still in the
tree when you arrive at this step. The `git-guardrails` hook this template ships **denies**
`git pull` (and `merge`, and `rebase`) whenever `git status --porcelain` is non-empty, because a
pull that resolves on top of uncommitted work cannot be reviewed afterwards — you can no longer
tell which hunk came from the remote. Chaining a stash into the same command line does not help:
the hook reads the tree, it does not predict what the line will do to it.

Clear the tree deliberately, then pull:

```bash
git stash push -u -m "post-merge: unstaged leftovers"   # -u, or untracked files stay behind
git pull
git stash pop
```

`git pull --autostash` is the one-command alternative, but only on a tree whose dirt is entirely
**tracked**. `git stash` does not stash untracked files, so an autostash over a `??` entry starts
the pull on the same dirty tree the check exists to refuse — the hook therefore reads porcelain
and **denies** `--autostash` whenever any `??` entry is present. At this step that is the usual
state, so the explicit `-u` stash above is the default route and `--autostash` is the shortcut for
the case where `git status --porcelain` shows no `??` lines at all. Git agrees independently: if
the incoming commits add a file at a path you are holding untracked, it aborts the merge
(*"untracked working tree files would be overwritten"*) after the autostash has already been
taken. Either route must be its **own** command — chaining the stash and the pull onto one line is
denied outright, because an identified history op reaches the tree reading only as a standalone
simple command.

`ALLOW_DIRTY_MERGE=1` is the hatch for a dirty state you have looked at and can justify out loud.
It is not the routine remedy, and reaching for it because the block is inconvenient is the
behavior the check exists to prevent.

## Important

- **Never skip Step 0.** Quality gates catch broken compilation, bad citations, and hardcoded paths before they reach `main`. If the user insists on skipping, record their override reason in the commit message.
- Never commit directly to `main`; branch off it first.
- Never push, open a pull request, or merge unless asked — see Step 5 and "Merging".
- Exclude `settings.local.json` and sensitive files from staging.
- When the user does ask to merge, use `--merge` (not `--squash` or `--rebase`) unless they say otherwise.
- If the commit message from `$ARGUMENTS` is provided, use it exactly.

## Flags

| Flag | Effect |
|---|---|
| `--pr` | After the commit, push the branch and open a pull request (Step 5). Never merges. |
