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
It reads the command the way the shell splits it (quotes, comments, `;`, `&&`,
`|`, `>`, and the contents of `$(...)` and backticks), so a quoted mention is not
a command and a `--abort` inside a comment or a `-m` message is not a resume.

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
`"onFailure": "block"`, so a missing `python3` lets the command run too, and
through a one-line launcher, `sh -c '[ -f "$1" ] || exit 0; exec python3 "$1"'`,
that exits 0 when THIS FILE is missing. Without the launcher, Python's exit 2
for a missing script would read as a refusal of every command the filter
starts the hook for, which includes any command containing `$VAR` or `$(...)`.
It is a speed bump against the ordinary accident, not a boundary.

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
import shlex
import subprocess
import sys

OPS = {"merge", "pull", "rebase"}
RESUME = {"--abort", "--continue", "--skip", "--quit", "--edit-todo"}
# Programs that run their arguments as a command; Claude Code strips the same ones
# before matching a permission rule.
WRAPPERS = {"timeout", "time", "nice", "nohup", "stdbuf", "command", "builtin", "env",
            "xargs", "noglob"}
# `$(...)` and backticks run their contents as a command even inside double quotes,
# where the tokenizer below sees one quoted word, so their contents are read again.
# Inside single quotes they are literal text, so single-quoted spans are blanked
# before the search.
SUBST = re.compile(r"\$\(([^()]*)\)|`([^`]*)`")
SINGLE_QUOTED = re.compile(r"'[^']*'")
# A heredoc opener (`<<EOF`, `<<-'EOF'`, `<< "EOF"`), not a here-string (`<<<`).
HEREDOC = re.compile(r"(?<!<)<<(?!<)-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")
BREAKS = set(";&|()")
ASSIGNMENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*=.*")
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


def strip_heredocs(command: str) -> str:
    """The command with every heredoc body removed: a body is data fed to a program
    (a commit message, a script), not commands this shell runs."""
    out, until = [], None
    for line in command.split("\n"):
        if until is not None:
            if line.strip() == until:
                until = None
            continue
        out.append(line)
        m = HEREDOC.search(line)
        if m:
            until = m.group(2)
    return "\n".join(out)


def simple_commands(text: str):
    """The word lists of the simple commands in one shell line, quotes removed.

    Quoted text stays one word, so `grep 'git pull origin' notes.md` names grep,
    not git. A `#` comment is dropped. `;`, `&`, `|`, `(` and `)` end a command.
    `<` and `>` are split off as words of their own but do not end the command,
    because the shell keeps passing the words after a redirection to the program:
    `git pull>log` is a pull, and `git rebase > log --continue` is a resume step.
    Raises ValueError on unbalanced quotes, which the shell cannot run either."""
    lex = shlex.shlex(text.replace("\n", " ; "), posix=True, punctuation_chars=True)
    lex.whitespace_split = True
    words: list[str] = []
    for tok in lex:
        if tok and set(tok) <= BREAKS:
            if words:
                yield words
            words = []
        else:
            words.append(tok)
    if words:
        yield words


def git_op(words: list[str]) -> str | None:
    """`merge`, `pull` or `rebase` when this simple command runs one that is not a
    resume step (`--abort`, `--continue`, ...), else None."""
    i = 0
    while i < len(words) and ASSIGNMENT.fullmatch(words[i]):
        i += 1
    while i < len(words) and re.split(r"[\\/]", words[i])[-1] in WRAPPERS:
        i += 1                     # the wrapper, then its options, a duration, VAR=value
        while i < len(words) and (words[i].startswith("-") or ASSIGNMENT.fullmatch(words[i])
                                  or re.fullmatch(r"[\d.]+[smhd]?", words[i])):
            i += 1
    if i >= len(words) or re.split(r"[\\/]", words[i])[-1].lower() not in ("git", "git.exe"):
        return None
    i += 1
    while i < len(words) and words[i].startswith("-"):     # git's global options
        i += 2 if words[i] in ("-C", "-c") else 1
    if i >= len(words) or words[i] not in OPS or RESUME & set(words[i + 1:]):
        return None
    return words[i]


def history_op(command: str) -> str | None:
    """The first merge/pull/rebase the command runs that is not a resume step, or None."""
    command = strip_heredocs(command)
    unquoted = SINGLE_QUOTED.sub("''", command)
    for text in [command, *(a or b for a, b in SUBST.findall(unquoted))]:
        try:
            for words in simple_commands(text):
                op = git_op(words)
                if op:
                    return op
        except ValueError:
            continue
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
