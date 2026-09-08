#!/usr/bin/env python3
"""Surface potentially stale numeric claims after reviewable file edits."""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hooklib import emit, project_root, read_event

RELEVANT = re.compile(r"\.(?:R|r|py|jl|tex|md|rmd|typ|ipynb)$", re.IGNORECASE)
PATCH_PATH = re.compile(r"^\*\*\* (?:Add|Update|Delete) File:\s*(.+)$", re.MULTILINE)


def main() -> int:
    event = read_event()
    command = str((event.get("tool_input") or {}).get("command") or "")
    changed = [p.strip() for p in PATCH_PATH.findall(command) if RELEVANT.search(p.strip())]
    if not changed:
        return 0
    root = project_root(event)
    if not root:
        return 0
    passports = sorted((root / "quality_reports" / "passports").glob("*.yaml"))
    if not passports:
        return 0
    hits: set[str] = set()
    for passport in passports:
        try:
            text = passport.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if any(path in text for path in changed):
            hits.add(passport.name)
    detail = f" Referenced passports: {', '.join(sorted(hits))}." if hits else ""
    message = (
        "Research code or a display artifact changed; numeric claims may now be stale. "
        f"Changed: {', '.join(changed[:8])}.{detail} "
        "Run $audit-reproducibility before relying on affected values."
    )
    emit("PostToolUse", message, system_message="Numeric-claim reconciliation required")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception:
        raise SystemExit(0)
