#!/usr/bin/env python3
"""Block destructive Git and blanket staging before Bash runs."""

from __future__ import annotations

import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hooklib import deny, project_root, read_event


def words(command: str) -> list[str]:
    try:
        lexer = shlex.shlex(command, posix=True, punctuation_chars=";&|()<>")
        lexer.whitespace_split = True
        lexer.commenters = ""
        return list(lexer)
    except ValueError:
        return command.split()


def git_calls(tokens: list[str]) -> list[list[str]]:
    calls: list[list[str]] = []
    boundaries = {";", "&&", "||", "|", "&", "(", ")", "<", ">", ">>"}
    for index, token in enumerate(tokens):
        if os.path.basename(token).lower() != "git":
            continue
        call: list[str] = []
        for arg in tokens[index + 1:]:
            if arg in boundaries:
                break
            call.append(arg)
        calls.append(call)
    return calls


def subcommand(call: list[str]) -> tuple[str, list[str]]:
    index = 0
    while index < len(call):
        token = call[index]
        if token == "-C" and index + 1 < len(call):
            index += 2
        elif token.startswith("-"):
            index += 1
        else:
            return token, call[index + 1:]
    return "", []


def command_variants(command: str, depth: int = 0):
    """Yield a command and ordinary shell -c payloads it directly executes."""
    yield command
    if depth >= 2:
        return
    tokens = words(command)
    for index, token in enumerate(tokens[:-2]):
        if Path(token).name.lower() in {"sh", "bash", "zsh"} and tokens[index + 1] == "-c":
            yield from command_variants(tokens[index + 2], depth + 1)


def selected_root(event: dict, call: list[str]) -> Path | None:
    root = project_root(event)
    current = Path(str(event.get("cwd") or root or Path.cwd())).resolve()
    index = 0
    while index < len(call):
        token = call[index]
        if token == "-C":
            if index + 1 >= len(call) or "$" in call[index + 1]:
                return None
            target = Path(call[index + 1]).expanduser()
            current = (target if target.is_absolute() else current / target).resolve()
            index += 2
            continue
        if not token.startswith("-"):
            break
        index += 1
    return current


def status(root: Path) -> str | None:
    try:
        result = subprocess.run(
            ["git", "-C", str(root), "status", "--porcelain",
             "--untracked-files=normal", "--ignore-submodules=none"],
            capture_output=True,
            text=True,
            timeout=8,
        )
        return result.stdout if result.returncode == 0 else None
    except Exception:
        return None


def main() -> int:
    event = read_event()
    if event.get("tool_name") not in (None, "Bash"):
        return 0
    original = str((event.get("tool_input") or {}).get("command") or "")
    for command in command_variants(original):
        tokens = words(command)
        calls = git_calls(tokens)
        for call in calls:
            cmd, args = subcommand(call)
            if cmd == "reset" and "--hard" in args:
                deny("Blocked git reset --hard: it can silently discard research work.")
                return 0
            if cmd == "clean" and any(re.fullmatch(r"-[a-zA-Z]*f[a-zA-Z]*", a) for a in args):
                deny("Blocked git clean with force: untracked data and artifacts may be deleted.")
                return 0
            if cmd == "push" and any(a == "-f" or a.startswith("--force") for a in args):
                deny("Blocked force push, including --force-with-lease. Use a normal push.")
                return 0
            if cmd == "add" and any(a in ("-A", "--all", ".") for a in args):
                deny("Blocked blanket staging. Stage reviewed paths explicitly.")
                return 0
            if cmd in ("checkout", "restore") and "." in args:
                deny("Blocked mass restore/checkout: it can discard unrelated work.")
                return 0
            if cmd in ("merge", "rebase", "pull"):
                if any(a in ("--abort", "--continue", "--skip", "--quit", "--edit-todo") for a in args):
                    continue
                if any(a == "--bare" or a.startswith(("--git-dir", "--work-tree", "--namespace")) for a in call):
                    deny(f"Blocked git {cmd} with an alternate repository selector.")
                    return 0
                # Only a standalone history operation can rely on the pre-run tree reading.
                if len(calls) != 1 or any(t in {";", "&&", "||", "|", "&", "<", ">", ">>"} for t in tokens):
                    deny(f"Blocked chained git {cmd}. Run the history operation as a standalone command.")
                    return 0
                root = selected_root(event, call)
                tree = status(root) if root else None
                if "--autostash" in args and tree is not None \
                        and not any(line.startswith("??") for line in tree.splitlines()):
                    continue
                if tree is None or tree.strip():
                    deny(f"Blocked git {cmd}: the working tree is dirty or could not be verified clean.")
                    return 0
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception:
        raise SystemExit(0)
