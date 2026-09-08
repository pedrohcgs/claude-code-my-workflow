#!/usr/bin/env python3
"""Require reviewable apply_patch edits for Codex control surfaces."""

from __future__ import annotations

import re
import shlex
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hooklib import deny, project_root, read_event

PROTECTED = re.compile(
    r"^(?:\./)?(?:AGENTS\.md(?:/|$)|\.agents/skills(?:/|$)|\.codex(?:/|$)|\.githooks(?:/|$))",
    re.IGNORECASE,
)
SEPARATORS = {";", "&&", "||", "|", "&", "(", ")"}


def tokenized(command: str) -> list[str]:
    try:
        lexer = shlex.shlex(command, posix=True, punctuation_chars=";&|()<>")
        lexer.whitespace_split = True
        lexer.commenters = ""
        return list(lexer)
    except ValueError:
        return command.split()


def protected(value: str, root: Path | None, cwd: Path) -> bool:
    value = value.strip().replace("\\", "/")
    if "$" in value and re.search(r"(?:^|/)(?:AGENTS\.md|\.agents/skills|\.codex|\.githooks)(?:/|$)", value, re.I):
        return True
    try:
        path = Path(value).expanduser()
        resolved = (path if path.is_absolute() else cwd / path).resolve(strict=False)
        if root:
            relative = resolved.relative_to(root)
            return bool(PROTECTED.search(relative.as_posix()))
    except (OSError, ValueError):
        pass
    return bool(PROTECTED.search(value))


def segments(tokens: list[str]):
    current = []
    for token in tokens:
        if token in SEPARATORS:
            if current:
                yield current
                current = []
        else:
            current.append(token)
    if current:
        yield current


def mutates_protected(command: str, root: Path | None, cwd: Path, depth: int = 0) -> bool:
    tokens = tokenized(command)
    # Redirection decisions follow the destination, not a protected source read.
    for index, token in enumerate(tokens[:-1]):
        if token in (">", ">>") and protected(tokens[index + 1], root, cwd):
            return True
    for part in segments(tokens):
        if not part:
            continue
        # Inspect ordinary shell -c payloads once; interpreters remain outside
        # this tripwire's threat model.
        if depth < 2 and Path(part[0]).name in {"sh", "bash", "zsh"} and "-c" in part:
            index = part.index("-c")
            if index + 1 < len(part) and mutates_protected(part[index + 1], root, cwd, depth + 1):
                return True
        index = 0
        while index < len(part) and ("=" in part[index] or Path(part[index]).name in {"env", "sudo", "command", "nice", "nohup"}):
            index += 1
        if index >= len(part):
            continue
        program = Path(part[index]).name.lower()
        args = part[index + 1:]
        operands = [arg for arg in args if not arg.startswith("-")]
        if program in {"rm", "touch", "truncate"} and any(protected(arg, root, cwd) for arg in operands):
            return True
        if program in {"chmod", "chown"} and any(protected(arg, root, cwd) for arg in operands[1:]):
            return True
        if program in {"cp", "mv", "install", "ln", "rsync"} and len(operands) >= 2 and protected(operands[-1], root, cwd):
            return True
        if program == "tee" and any(protected(arg, root, cwd) for arg in operands):
            return True
        if program in {"sed", "perl"} and any("i" in arg for arg in args if arg.startswith("-")) \
                and any(protected(arg, root, cwd) for arg in operands):
            return True
        if program == "git":
            sub = next((arg for arg in args if not arg.startswith("-") and arg != "."), "")
            if sub in {"checkout", "restore", "clean", "rm", "mv"} and any(protected(arg, root, cwd) for arg in args):
                return True
    return False


def main() -> int:
    event = read_event()
    if event.get("tool_name") not in (None, "Bash"):
        return 0
    command = str((event.get("tool_input") or {}).get("command") or "")
    root = project_root(event)
    cwd = Path(str(event.get("cwd") or root or Path.cwd())).resolve()
    if mutates_protected(command, root, cwd):
        deny(
            "Blocked shell mutation of a workflow control surface. "
            "Inspect the file and edit it through apply_patch so the change is reviewable."
        )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception:
        raise SystemExit(0)
