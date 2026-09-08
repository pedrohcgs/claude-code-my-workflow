#!/usr/bin/env python3
"""Append one structured session-log entry per changed working-tree state."""

from __future__ import annotations

import hashlib
import json
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hooklib import git, project_root, read_event, state_dir


def main() -> int:
    event = read_event()
    if event.get("stop_hook_active"):
        print("{}")
        return 0
    root = project_root(event)
    if not root:
        print("{}")
        return 0
    status = "\n".join(
        line for line in git(root, "status", "--porcelain").splitlines()
        if "_codex_auto.md" not in line
    )
    if not status.strip():
        print("{}")
        return 0
    digest = hashlib.sha256(status.encode()).hexdigest()
    marker = state_dir(root) / "session-log-state.json"
    try:
        if json.loads(marker.read_text()).get("last_hash") == digest:
            print("{}")
            return 0
    except Exception:
        pass
    now = datetime.now()
    logs = root / "quality_reports" / "session_logs"
    logs.mkdir(parents=True, exist_ok=True)
    target = logs / f"{now:%Y-%m-%d}_codex_auto.md"
    new = not target.exists()
    changed = [line.strip() for line in status.splitlines() if line.strip()][:40]
    with target.open("a", encoding="utf-8") as handle:
        if new:
            handle.write(f"# Codex session log — {now:%Y-%m-%d}\n\n")
            handle.write("_Automatically records meaningful working-tree states._\n")
        handle.write(f"\n## {now:%H:%M} — {len(changed)} changed path(s)\n\n")
        handle.write("\n".join(f"- `{line}`" for line in changed) + "\n")
    try:
        marker.write_text(json.dumps({"last_hash": digest}))
    except OSError:
        pass
    print("{}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception:
        print("{}")
        raise SystemExit(0)
