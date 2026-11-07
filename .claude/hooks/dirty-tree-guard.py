#!/usr/bin/env python3
"""
Dirty-Tree Guard (PreToolUse, Bash; registered three times, with
`"if": "Bash(git merge *)"`, `"if": "Bash(git pull *)"` and
`"if": "Bash(git rebase *)"`)

Refuses a merge, pull or rebase while TRACKED files have uncommitted changes,
so uncommitted work is not mixed into the result of a history operation.

Cost: Claude Code starts this hook only when a subcommand matches one of those
patterns, including after `&&` and inside `$()`, so it does not run on other
commands. One exception, from the hooks docs: a pattern that names more than
the program also starts the hook on ANY command containing `$()`, backticks or
`$VAR`. So the hook first confirms that the command really runs `git merge`,
`git pull` or `git rebase`, and allows everything else without reading the tree.

What it checks: `git status --porcelain --untracked-files=no` in the event's
`cwd`, with git's repository-scoping variables (GIT_DIR, GIT_INDEX_FILE, ...)
removed, so a parent git process cannot redirect the reading to another
repository. Untracked files are ignored: git itself refuses a merge that would
overwrite one. `--abort`, `--continue`, `--skip`, `--quit` and `--edit-todo`
are allowed, because they run mid-conflict, when the tree is dirty by
definition.

Escape: ALLOW_DIRTY_MERGE=1 in the session environment.

Fails open, by design. If the directory is not a repository, git is missing,
the reading times out, the event is malformed or this file has a bug, there is
no decision and the command runs. It is registered WITHOUT
`"onFailure": "block"`, so a missing `python3` lets the command run too. One
case does refuse: if THIS FILE is missing while `python3` is present, Python
exits 2 ("can't open file"), and Claude Code treats exit 2 from a PreToolUse
hook as a refusal. Then `git merge`, `git pull` and `git rebase` are refused
until the file is restored (`git checkout -- .claude/hooks`); nothing else is
affected, because the hook is started only for those three. It is a speed
bump against the ordinary accident, not a boundary.

What it does not see:
  - a repository reached by `cd elsewhere && git pull` or `git -C other merge`
    (it reads the session's directory, so it may also refuse there when only
    THIS repository is dirty; ALLOW_DIRTY_MERGE=1 covers that case);
  - `bash -c '...'`, an alias, a script, or a Makefile target;
  - anything the `if` filter misses, which Claude Code calls best-effort.

Replaces the clean-tree rule of git-guardrails.py, removed in v2.9.1. That
file parsed the whole command line itself; its history is in git (tag v2.9.0).
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys

# `git`, then any global options, then the operation as a whole word.
# `merge-base` and `merge-file` are other commands, hence the lookahead.
OP = re.compile(r"\bgit(?:\s+(?:-[Cc]\s+\S+|--?[\w-]+(?:=\S+)?))*\s+(merge|pull|rebase)(?=\s|$|[;&|)`])")
# The arguments of that operation run to the next shell separator.
ARGS = re.compile(r"[^;&|)`\n]*")
RESUME = re.compile(r"(?:^|\s)--(?:abort|continue|skip|quit|edit-todo)(?=\s|$)")
STATUS = ("git", "status", "--porcelain", "--untracked-files=no")
TIMEOUT = 5          # strictly below the registered timeout (10 s) in settings.json

REASON = ("Blocked by dirty-tree-guard: tracked files have uncommitted changes, so "
          "this git {op} would mix them into its result. Commit them, or stash them "
          "(`git stash push -m \"<what this is>\"`), then run the {op} as its own "
          "command. Changed: {files}. (Override: ALLOW_DIRTY_MERGE=1 in the session "
          "environment.)")


def deny(reason: str) -> None:
    json.dump({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}, sys.stdout)


def history_op(command: str) -> str | None:
    """The first merge/pull/rebase in the command that is not a resume step, or None."""
    for m in OP.finditer(command):
        args = ARGS.match(command, m.end()).group(0)
        if not RESUME.search(args):
            return m.group(1)
    return None


def dirty_files(cwd: str) -> list[str]:
    """Tracked files with uncommitted changes; empty when clean or when git cannot answer."""
    env = {k: v for k, v in os.environ.items()
           if not k.startswith("GIT_") or k == "GIT_EXEC_PATH"}
    try:
        r = subprocess.run(STATUS, cwd=cwd, env=env, capture_output=True, timeout=TIMEOUT)
    except (OSError, subprocess.SubprocessError):
        return []
    if r.returncode != 0:
        return []
    return [line[3:] for line in r.stdout.decode("utf-8", "replace").splitlines() if line.strip()]


def main() -> int:
    if os.environ.get("ALLOW_DIRTY_MERGE", "") == "1":
        return 0
    try:
        data = json.loads(sys.stdin.buffer.read().decode("utf-8", "replace"))
    except ValueError:
        return 0
    if not isinstance(data, dict) or data.get("tool_name") != "Bash":
        return 0
    command = ((data.get("tool_input") or {}).get("command") or "").replace("\r", "")
    op = history_op(command)
    if not op:
        return 0
    files = dirty_files(str(data.get("cwd") or os.getcwd()))
    if files:
        shown = ", ".join(files[:5]) + (f" and {len(files) - 5} more" if len(files) > 5 else "")
        deny(REASON.format(op=op, files=shown))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail open
