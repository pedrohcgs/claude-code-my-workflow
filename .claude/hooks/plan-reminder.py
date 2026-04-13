#!/usr/bin/env python3
"""
Plan Persistence Reminder Hook for Claude Code

A Stop hook that checks whether a plan file exists in quality_reports/plans/
when Claude has been in plan mode. If a plan was discussed but not saved to
disk, blocks once with a reminder.

State is tracked per session ID (not project-wide) to prevent one session's
plan activity from suppressing reminders in a different session.

Usage (in .claude/settings.json):
    "Stop": [{ "hooks": [{ "type": "command",
        "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/plan-reminder.py" }] }]
"""
from __future__ import annotations

import json
import sys
import hashlib
import os
from pathlib import Path
from datetime import datetime


def get_session_dir() -> Path:
    """Return session state directory, consistent with other hooks."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    state_dir = Path.home() / ".claude" / "sessions" / project_hash
    state_dir.mkdir(parents=True, exist_ok=True)
    return state_dir


def get_hook_input():
    """Read hook input from stdin."""
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        hook_input = {}

    # If stop_hook_active, Claude is already continuing from a previous
    # Stop hook block — let it stop this time to avoid infinite loops.
    if hook_input.get("stop_hook_active", False):
        sys.exit(0)

    return hook_input


def get_state_path(state_dir: Path, session_id: str) -> Path:
    """Return a session-keyed state file path."""
    safe_id = session_id.replace("/", "_")[:64]
    return state_dir / f"plan-reminder-{safe_id}.json"


def load_state(state_path: Path) -> dict:
    """Load persisted state, or return defaults."""
    try:
        return json.loads(state_path.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return {"reminded": False, "plan_mode_entered_at": None}


def save_state(state_path: Path, state: dict):
    """Persist state to disk."""
    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps(state))


def find_plan_file_after(project_dir: str, after_ts: str | None) -> bool:
    """Check if any plan file was created/modified after the given timestamp.

    If after_ts is None, falls back to checking for any plan file modified today.
    """
    plans_dir = Path(project_dir) / "quality_reports" / "plans"
    if not plans_dir.is_dir():
        return False

    if after_ts:
        try:
            # Normalize Z suffix to +00:00 for Python < 3.11 compatibility
            normalized = after_ts.replace("Z", "+00:00") if after_ts.endswith("Z") else after_ts
            cutoff = datetime.fromisoformat(normalized).replace(tzinfo=None)
        except (ValueError, TypeError):
            cutoff = None
    else:
        cutoff = None

    for md_file in plans_dir.glob("*.md"):
        mtime = datetime.fromtimestamp(md_file.stat().st_mtime)
        if cutoff and mtime >= cutoff:
            return True
        elif not cutoff:
            # Fallback: check if modified today
            today = datetime.now().strftime("%Y-%m-%d")
            if md_file.name.startswith(today):
                return True
            if mtime.strftime("%Y-%m-%d") == today:
                return True

    return False


def conversation_mentions_plan(hook_input: dict) -> tuple[bool, str | None]:
    """Check if the conversation transcript mentions plan-related activity.

    Returns (mentions_plan, earliest_plan_timestamp).
    """
    transcript = hook_input.get("transcript", [])
    if not transcript:
        return False, None

    plan_keywords = [
        "EnterPlanMode", "ExitPlanMode", "plan mode",
        "## Plan", "## Approach", "## Steps",
        "quality_reports/plans/",
    ]

    earliest_ts = None
    found = False

    # Check last 10 messages for plan-related content
    recent = transcript[-10:] if len(transcript) >= 10 else transcript
    for msg in recent:
        content = ""
        msg_ts = None
        if isinstance(msg, dict):
            content = str(msg.get("content", ""))
            msg_ts = msg.get("timestamp")
        elif isinstance(msg, str):
            content = msg

        for keyword in plan_keywords:
            if keyword.lower() in content.lower():
                found = True
                if msg_ts and (earliest_ts is None or msg_ts < earliest_ts):
                    earliest_ts = msg_ts
                break

    return found, earliest_ts


def main():
    hook_input = get_hook_input()
    project_dir = hook_input.get("cwd", "")
    session_id = hook_input.get("session_id", "unknown")
    if not project_dir:
        sys.exit(0)

    state_dir = get_session_dir()
    state_path = get_state_path(state_dir, session_id)
    state = load_state(state_path)

    # If already reminded this session, don't block again
    if state.get("reminded", False):
        sys.exit(0)

    # Check if the conversation involved plan-related activity
    mentions_plan, plan_ts = conversation_mentions_plan(hook_input)
    if not mentions_plan:
        sys.exit(0)

    # Record when plan mode was first detected in this session
    if not state.get("plan_mode_entered_at") and plan_ts:
        state["plan_mode_entered_at"] = plan_ts
        save_state(state_path, state)

    # Check if a plan file was created/modified AFTER plan mode was entered
    after_ts = state.get("plan_mode_entered_at") or plan_ts
    if find_plan_file_after(project_dir, after_ts):
        # Plan was saved — clear state for this session
        state["reminded"] = False
        state["plan_mode_entered_at"] = None
        save_state(state_path, state)
        sys.exit(0)

    # Plan was discussed but not saved — remind once per session
    today = datetime.now().strftime("%Y-%m-%d")
    state["reminded"] = True
    save_state(state_path, state)

    output = {
        "decision": "block",
        "reason": (
            f"Plan was discussed but not saved to disk. "
            f"Write it to quality_reports/plans/{today}_description.md "
            f"before stopping."
        ),
    }
    json.dump(output, sys.stdout)
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Fail open — never block Claude due to a hook bug
        sys.exit(0)
