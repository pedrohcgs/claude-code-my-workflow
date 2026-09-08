#!/usr/bin/env python3
"""Save a compact repository checkpoint before Codex compacts context."""

from __future__ import annotations

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hooklib import git, project_root, read_event, state_dir


def active_plan(root):
    plans = root / "quality_reports" / "plans"
    for path in sorted(plans.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True)[:5]:
        text = path.read_text(encoding="utf-8", errors="replace")
        plain = "\n".join(line.replace("*", "") for line in text.splitlines())
        match = re.search(
            r"^\s*status\s*:\s*(draft|approved|completed|implemented|in[ -]?progress)",
            plain, re.I | re.M,
        )
        status = (match.group(1).lower() if match else "in-progress").replace(" ", "-")
        if status in ("completed", "implemented"):
            continue
        task = next((line.replace("- [ ]", "", 1).strip() for line in text.splitlines() if "- [ ]" in line), None)
        return {"path": str(path.relative_to(root)), "status": status, "next_task": task}
    return None


def main() -> int:
    event = read_event()
    root = project_root(event)
    if not root:
        return 0
    plan = active_plan(root)
    payload = {
        "saved_at": datetime.now().isoformat(timespec="seconds"),
        "trigger": event.get("trigger", "auto"),
        "plan": plan,
        "git_status": git(root, "status", "--short").splitlines()[:60],
        "recent_commits": git(root, "log", "-3", "--oneline").splitlines(),
    }
    directory = state_dir(root)
    (directory / "pre-compact-state.json").write_text(json.dumps(payload, indent=2))
    if os.environ.get("CODEX_PRECOMPACT_BLOCK_ON_DRAFT") == "1" and plan and plan["status"] == "draft":
        sentinel = directory / "draft-blocked.json"
        try:
            prior = json.loads(sentinel.read_text()).get("path")
        except Exception:
            prior = None
        if prior != plan["path"]:
            sentinel.write_text(json.dumps({"path": plan["path"]}))
            print(json.dumps({
                "continue": False,
                "stopReason": f"Compaction paused once because {plan['path']} is still DRAFT. Approve it or retry compaction.",
            }))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception:
        raise SystemExit(0)
