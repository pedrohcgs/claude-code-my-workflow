---
name: verify
description: Run this repository's gates on the work about to be committed — the backtest suite, and the quality score for every staged `.qmd`, `.tex` or `.R` file — and stop the commit if one fails. Claude Code tells Claude to run a project skill named `verify` right before committing (not for docs-only or tests-only commits); also use it when the user says "verify", "run the gates", "check before I commit", or "is this ready to commit?". It checks and reports; it never commits, pushes or fixes anything itself.
allowed-tools: ["Bash", "Read"]
effort: low
---

# /verify — the gates, before a commit

Since Claude Code 2.1.286, Claude is *told* to run a project skill named `verify` right before it commits, except for docs-only and tests-only commits. This one runs the same gates `/commit` runs. It is a reminder, not enforcement: Claude can skip it, and an exempt commit never triggers it, even one that changes a `.qmd` or `.tex` file. The enforcing gates are the git pre-commit hook (`./scripts/install-hooks.sh`) and `/commit`. It **does not** commit, push, stage, or edit anything.

## Steps

1. **Is the git hook already doing this?** Only when all three checks from `/commit` Step 0b hold: `git config --get core.hooksPath` prints `.githooks`; `test -x "$(git rev-parse --show-toplevel)/.githooks/pre-commit" && echo executable` prints `executable` (git skips a hook file that is missing or not executable, and still commits); and `git status --porcelain -- ':/.githooks'` prints nothing (an edited hook is itself what needs testing, and it could exit 0 without running anything). Then the pre-commit hook will run the backtest and the quality gate on this commit anyway. Say so in one line and stop, because running everything twice wastes a minute and adds nothing. Otherwise go on to step 2.
2. **Run the backtest:** `./scripts/backtest.sh`. Capture the exit code and the last lines. A non-zero exit fails `/verify`; report the failing gate's own message, not a summary of it.
3. **Score staged prose and code:** for each staged file ending in `.qmd`, `.tex` or `.R` (`git diff --cached --name-only --diff-filter=ACMR`), run `python3 scripts/quality_score.py <file>`. A score below 80 fails `/verify`.
4. **Report.** One line per check (`PASS` / `FAIL`, with the score or the gate's message), then the verdict.
   - **FAIL:** do not commit. Say what failed and what fixes it.
   - **PASS:** say the commit can go ahead.

   If the user has explicitly said "commit anyway" or "skip quality gate", pass that on: `/commit` records such an override as `SKIP_QUALITY_GATE=1`, which skips only the quality score. Never suggest `git commit --no-verify`.

## Not this skill's job

Fixing what failed (do that, then run `/verify` again), writing the commit message (`/commit`), and deciding whether a change is wanted (the user). A gate that cannot run, such as a missing interpreter or a script error, is a FAIL, not a pass.
