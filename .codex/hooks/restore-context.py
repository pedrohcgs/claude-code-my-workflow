#!/usr/bin/env python3
"""Restore saved plan and repository state after compaction or resume."""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hooklib import emit, project_root, read_event, state_dir


def main() -> int:
    event = read_event()
    if event.get("source") not in ("compact", "resume"):
        return 0
    root = project_root(event)
    if not root:
        return 0
    target = state_dir(root) / "pre-compact-state.json"
    try:
        saved = json.loads(target.read_text())
        target.unlink()
    except Exception:
        return 0
    lines = ["Repository context restored after compaction/resume."]
    plan = saved.get("plan") or {}
    if plan:
        lines.append(f"Active plan: {plan.get('path')} ({plan.get('status')}).")
        if plan.get("next_task"):
            lines.append(f"Next unchecked task: {plan['next_task']}")
    status = saved.get("git_status") or []
    if status:
        lines.append("Saved working-tree state: " + "; ".join(status[:20]))
    commits = saved.get("recent_commits") or []
    if commits:
        lines.append("Recent commits: " + "; ".join(commits))
    lines.append("Read the active plan and current git diff before continuing; do not redo completed work.")
    emit("SessionStart", "\n".join(lines))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception:
        raise SystemExit(0)
