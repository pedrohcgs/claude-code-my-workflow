#!/usr/bin/env python3
"""
Issue Guard Hook (PreToolUse, Bash, scoped with `"if": "Bash(gh *)"` and, as a
second registration, `"if": "Bash(gh.exe *)"`)

Every new GitHub issue has to pass a duplicate check first. The check lives in
scripts/file-issue.py, which searches open and closed issues several ways and
creates the issue only when no candidate is left unreviewed. This guard makes
that the only route Claude takes: it denies a Bash command that would create an
issue directly and names the script instead.

Denied (each as a simple command, anywhere in a compound line, a $(...), or
after a shell control word — if/then/else, while/until/do, for, { }, !):
  - gh issue create / gh issue new        (global -R/--repo flags allowed anywhere)
  - gh api ... repos/<o>/<r>/issues       with POST (explicit -X/--method, or
                                          implied by -f/-F/--field/--raw-field/--input)
  - gh api graphql ... createIssue        in the command, or in a query file it
                                          reads (--input FILE, -F key=@FILE); a
                                          file that cannot be read, or stdin (@-),
                                          is denied because it cannot be checked

Allowed and silent: everything else, including gh issue list/view/comment/close/
reopen/edit, and python3 scripts/file-issue.py (its own `gh issue create` runs
as a child process, which hooks never see).

What this is not: a security boundary. `/path/to/gh`, `sh -c '...'` or a
script of your own can still create an issue. It stops the usual form Claude
writes, which is the one that skips the check by accident.

Cost: the `if` filter (Claude Code >= 2.1.85; compound commands >= 2.1.89)
spawns this hook only for commands that run `gh`. On an older version the
filter is ignored and the hook runs on every Bash call, still correctly. The
filter is a prefix match, so `gh.exe` — which Git Bash on Windows runs as
readily as `gh` — needs its own registration; .claude/settings.json carries
both rather than dropping the filter and spawning this on every command.

No network and no git: a guard that stalls or crashes fails OPEN, so it decides
from the command text, plus — only for `gh api graphql` — the query file the
command names, read from the local disk.

Output: deny → exit 0 + JSON {"hookSpecificOutput": {"hookEventName":
"PreToolUse", "permissionDecision": "deny", "permissionDecisionReason"}}.
Anything else → exit 0, no output. Fail-open: any error → exit 0, silent.
"""

from __future__ import annotations

import json
import os
import re
import shlex
import sys

REASON = (
    "Blocked: a new GitHub issue must pass the duplicate check first. Write the body to a "
    "file and run `python3 scripts/file-issue.py --title \"...\" --body-file <file> "
    "[--label ...] [--search \"...\"]`. It searches open and closed issues and creates the "
    "issue only when every candidate it finds has been reviewed (re-run with --checked N,M "
    "once you have judged them distinct). If the problem is already tracked, use "
    "`gh issue comment <N>` (and `gh issue reopen <N>` if it is back) instead. "
    "See .claude/skills/issues/SKILL.md."
)

# Operators that end one simple command and start the next.
SEPARATORS = {";", "&&", "||", "|", "|&", "&", "(", ")", "\n"}
# Words that run the command after them.
WRAPPERS = {"command", "builtin", "exec", "nohup", "time", "env", "sudo"}
# Shell reserved words that can stand before a command in the same segment
# (`if true; then gh issue create; fi` splits into `then gh issue create`).
RESERVED = {"if", "then", "else", "elif", "while", "until", "do", "{", "!"}
# Wrapper options that consume the next word (sudo -u USER, env -u VAR, env -C DIR).
WRAPPER_VALUE_OPTS = {"-u", "-g", "-h", "-p", "-C", "-D", "-r", "-t", "-U", "-S",
                      "--user", "--group", "--chdir", "--unset"}
# gh flags that take a value (skipped when finding the subcommand words).
GH_VALUE_FLAGS = {"-R", "--repo", "--hostname"}
API_BODY_FLAGS = {"-f", "-F", "--field", "--raw-field", "--input"}
ISSUES_ENDPOINT = re.compile(r"^/?repos/[^/\s]+/[^/\s]+/issues/?(\?.*)?$")
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
# A heredoc opener at a given position (<<EOF, <<-'EOF', <<"EOF").
HEREDOC_AT = re.compile(r"<<-?[ \t]*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")
GQL_FILE_FLAGS = {"-F", "--field"}
MAX_QUERY_FILE = 1_000_000


def strip_heredocs(command: str) -> str:
    """Drop heredoc bodies: they are a command's input, not commands.

    Without this, writing a file that merely CONTAINS the text `gh issue create`
    (a test, a doc, this hook's own battery) was denied. Only an opener the shell
    would honour counts — one outside quotes and comments — because a `<<EOF` in
    a comment or a string does not start a heredoc, and treating it as one hid
    the real command on the next line (PR #163 review). A heredoc fed to a shell
    (`bash <<EOF ... EOF`) is not inspected; like `sh -c`, that is outside what
    this guard claims to stop.
    """
    out: list[str] = []
    pending: list[str] = []
    i, n = 0, len(command)
    in_s = in_d = in_comment = False
    while i < n:
        c = command[i]
        if c == "\n":
            out.append(c)
            i += 1
            in_comment = False
            if pending and not in_s and not in_d:
                for delim in pending:       # skip each body up to its delimiter line
                    while i < n:
                        j = command.find("\n", i)
                        line = command[i:] if j < 0 else command[i:j]
                        i = n if j < 0 else j + 1
                        if line.strip() == delim:
                            break
                pending = []
            continue
        if in_comment:
            i += 1
            continue
        if c == "\\" and not in_s:
            out.append(command[i:i + 2])
            i += 2
            continue
        if c == "'" and not in_d:
            in_s = not in_s
        elif c == '"' and not in_s:
            in_d = not in_d
        elif not in_s and not in_d:
            if c == "#" and (i == 0 or command[i - 1] in " \t\n;&|()"):
                in_comment = True
                i += 1
                continue
            if command.startswith("<<", i) and not command.startswith("<<<", i) \
                    and (i == 0 or command[i - 1] != "<"):
                m = HEREDOC_AT.match(command, i)
                if m:
                    pending.append(m.group(2))
                    out.append(m.group(0))
                    i = m.end()
                    continue
        out.append(c)
        i += 1
    return "".join(out)


def graphql_files_create(args: list[str], cwd: str) -> bool:
    """True when a query file the command reads holds createIssue — or cannot be read.

    `--input FILE` and `-F key=@FILE` load the request from disk, so the command
    text alone cannot show a mutation (PR #163 review). Stdin (`-`) and a file
    that does not exist yet (written earlier in the same line) cannot be checked,
    so they are denied rather than assumed harmless.
    """
    paths = []
    for i, a in enumerate(args):
        if a == "--input" and i + 1 < len(args):
            paths.append(args[i + 1])
        elif a.startswith("--input="):
            paths.append(a.split("=", 1)[1])
        elif a in GQL_FILE_FLAGS and i + 1 < len(args) and "=@" in args[i + 1]:
            paths.append(args[i + 1].split("=@", 1)[1])
        elif a.startswith("-F") and not a.startswith("--") and "=@" in a[2:]:
            paths.append(a[2:].split("=@", 1)[1])     # attached form: -Fquery=@FILE
        elif a.startswith("--field=") and "=@" in a[len("--field="):]:
            paths.append(a[len("--field="):].split("=@", 1)[1])
    for p in paths:
        if p == "-":
            return True
        full = os.path.join(cwd, os.path.expanduser(p))
        try:
            with open(full, encoding="utf-8", errors="replace") as f:
                if "createIssue" in f.read(MAX_QUERY_FILE):
                    return True
        except OSError:
            return True
    return False


def deny(reason: str) -> None:
    json.dump({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}, sys.stdout)


def simple_commands(command: str) -> list[list[str]]:
    """Split a shell line into the word lists of its simple commands.

    $( and backticks open a nested command, so they are turned into separators:
    `echo $(gh issue create ...)` yields the gh command as its own segment.
    """
    text = command.replace("$(", " ( ").replace("`", " ; ")
    lex = shlex.shlex(text, posix=True, punctuation_chars=";&|()\n")
    lex.whitespace = " \t\r"
    lex.whitespace_split = True
    segments, cur = [], []
    for tok in lex:
        if tok in SEPARATORS or set(tok) <= set(";&|()\n"):
            if cur:
                segments.append(cur)
            cur = []
        else:
            cur.append(tok)
    if cur:
        segments.append(cur)
    return segments


def substitutions(text: str) -> list[str]:
    """Bodies of $(...) and `...` the shell would run — including inside double quotes.

    shlex keeps "…$(cmd)…" as one quoted word, so a create hidden in a quoted
    substitution needs this separate pass. Single-quoted text is literal and skipped;
    $(( )) is arithmetic and skipped.
    """
    out: list[str] = []
    i, n, in_s, in_d = 0, len(text), False, False
    while i < n:
        c = text[i]
        if c == "\\" and not in_s:
            i += 2
            continue
        if c == "'" and not in_d:
            in_s = not in_s
        elif c == '"' and not in_s:
            in_d = not in_d
        elif not in_s and text.startswith("$((", i):
            i += 3
            continue
        elif not in_s and text.startswith("$(", i):
            depth, j = 1, i + 2
            while j < n and depth:
                depth += {"(": 1, ")": -1}.get(text[j], 0)
                j += 1
            body = text[i + 2:j - 1]
            out += [body, *substitutions(body)]
            i = j
            continue
        elif not in_s and c == "`":
            j = text.find("`", i + 1)
            if j < 0:
                break
            out.append(text[i + 1:j])
            i = j + 1
            continue
        i += 1
    return out


def strip_prefix(words: list[str]) -> list[str]:
    """Drop leading reserved words, VAR=value assignments and wrappers (env, ...)."""
    i = 0
    while i < len(words):
        w = words[i]
        if w in RESERVED or ASSIGNMENT.match(w):
            i += 1
        elif w == "function":
            i += 2                          # function NAME { ... }
        elif w in WRAPPERS:
            i += 1
            while i < len(words) and words[i].startswith("-"):
                i += 2 if words[i] in WRAPPER_VALUE_OPTS else 1   # sudo -u USER, env -i
        else:
            break
    return words[i:]


def gh_positionals(args: list[str]) -> list[str]:
    """gh's non-flag words, skipping the values of flags that take one."""
    out, i = [], 0
    while i < len(args):
        a = args[i]
        if a in GH_VALUE_FLAGS:
            i += 2
            continue
        if a.startswith("-"):
            i += 1
            continue
        out.append(a)
        i += 1
    return out


def prog(word: str) -> str:
    """The program a command word names: the basename on either separator,
    lower-cased, a trailing `.exe` dropped. On Windows `gh.exe issue create`
    runs the same gh as `gh issue create`, and was allowed until this read it."""
    b = re.split(r"[\\/]", word)[-1].lower()
    return b[:-4] if b.endswith(".exe") else b


def creates_issue(words: list[str], cwd: str) -> bool:
    words = strip_prefix(words)
    if not words or prog(words[0]) != "gh":
        return False
    args = words[1:]
    pos = gh_positionals(args)
    if len(pos) >= 2 and pos[0] == "issue" and pos[1] in ("create", "new"):
        return True
    if pos and pos[0] == "api":
        joined = " ".join(args)
        if len(pos) >= 2 and pos[1] == "graphql":
            return "createIssue" in joined or graphql_files_create(args, cwd)
        method = None
        for i, a in enumerate(args):
            if a in ("-X", "--method") and i + 1 < len(args):
                method = args[i + 1].upper()
            elif a.startswith("--method="):
                method = a.split("=", 1)[1].upper()
            elif a.startswith("-X") and len(a) > 2:
                method = a[2:].upper()
        has_body = any(a in API_BODY_FLAGS or any(a.startswith(f + "=") for f in API_BODY_FLAGS
                                                   if f.startswith("--"))
                       for a in args)
        is_post = method == "POST" or (method is None and has_body)
        return is_post and any(ISSUES_ENDPOINT.match(p) for p in pos[1:])
    return False


def main() -> int:
    # Bytes, decoded as UTF-8 — what Claude Code writes. sys.stdin on Windows
    # decodes a pipe with the ANSI code page instead.
    try:
        data = json.loads(sys.stdin.buffer.read().decode("utf-8", "replace"))
    except (json.JSONDecodeError, EOFError, ValueError):
        return 0
    if not isinstance(data, dict) or data.get("tool_name") != "Bash":
        return 0
    # Git Bash drops every carriage return before it splits words, so
    # `gh issue cr<CR>eate` runs `gh issue create`; shlex would split it in two.
    command = ((data.get("tool_input") or {}).get("command") or "").replace("\r", "")
    if "gh" not in command.lower():         # `GH.exe` runs gh on Windows and macOS
        return 0
    try:
        text = strip_heredocs(command)
        segments = [seg for t in [text, *substitutions(text)] for seg in simple_commands(t)]
    except ValueError:
        # Unbalanced quotes: shlex cannot split it, and neither can the shell.
        return 0
    cwd = data.get("cwd") or os.getcwd()
    if any(creates_issue(seg, cwd) for seg in segments):
        deny(REASON)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # Fail open — a guard bug must not block unrelated work
        sys.exit(0)
