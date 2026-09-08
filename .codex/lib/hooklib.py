"""Small shared helpers for fail-open Codex lifecycle hooks."""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path


def read_event() -> dict:
    try:
        value = json.load(__import__("sys").stdin)
        return value if isinstance(value, dict) else {}
    except Exception:
        return {}


def project_root(event: dict) -> Path | None:
    candidates = [event.get("cwd"), os.environ.get("CODEX_PROJECT_DIR")]
    for candidate in candidates:
        if not candidate:
            continue
        try:
            result = subprocess.run(
                ["git", "-C", str(candidate), "rev-parse", "--show-toplevel"],
                capture_output=True,
                text=True,
                timeout=3,
            )
            if result.returncode == 0:
                return Path(result.stdout.strip()).resolve()
        except Exception:
            pass
        path = Path(str(candidate))
        if path.is_dir():
            return path.resolve()
    return None


def git(root: Path, *args: str) -> str:
    try:
        result = subprocess.run(
            ["git", "-C", str(root), *args],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return result.stdout if result.returncode == 0 else ""
    except Exception:
        return ""


def state_dir(root: Path) -> Path:
    digest = hashlib.sha256(str(root).encode()).hexdigest()[:16]
    path = Path(tempfile.gettempdir()) / "codex-research-workflow" / digest
    path.mkdir(parents=True, exist_ok=True)
    return path


def emit(event_name: str, context: str, *, system_message: str | None = None) -> None:
    value: dict = {
        "hookSpecificOutput": {
            "hookEventName": event_name,
            "additionalContext": context,
        }
    }
    if system_message:
        value["systemMessage"] = system_message
    print(json.dumps(value))


def deny(reason: str) -> None:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))

