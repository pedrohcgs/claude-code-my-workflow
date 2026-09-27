#!/usr/bin/env python3
"""
Pre-Compact State Capture Hook

Fires before context compaction to:
1. Capture current state (active plan, current task, recent decisions)
   so post-compact-restore.py can surface it afterwards.
2. OPTIONALLY block compaction once when an active plan is still DRAFT,
   to avoid losing mid-plan context before approval. **Opt-in** via
   CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT=1 (default OFF — the v2.0 default-ON
   flip was reverted: blocking the harness's *automatic* compaction can
   strand a user at the context ceiling, and post-compact-restore.py
   re-injects the plan afterward anyway). Blocks at most once per DRAFT
   plan, fail-open.

The blocking protocol follows modern Claude Code semantics:
  exit 0 + JSON {"decision": "block", "reason": "..."} on stdout.
Block fires at most once per DRAFT plan — the plan path is recorded in
state, and a subsequent compaction for the same plan proceeds normally.
Fail-open on any internal error.

Hook Event: PreCompact
Returns: exit 0 in all cases; stdout is block JSON or empty.
"""

from __future__ import annotations

import json
import os
import sys
import re
from pathlib import Path
from datetime import datetime
import hashlib

# Colors for terminal output
CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
NC = "\033[0m"  # No color


def get_session_dir() -> Path:
    """Get the session directory for storing state files."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        return Path.home() / ".claude" / "sessions" / "default"

    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    session_dir = Path.home() / ".claude" / "sessions" / project_hash
    session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


def find_active_plan(project_dir: str) -> dict | None:
    """Find the most recent non-completed plan."""
    plans_dir = Path(project_dir) / "quality_reports" / "plans"
    if not plans_dir.exists():
        return None

    plan_files = sorted(plans_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)

    for plan_file in plan_files[:3]:  # Check last 3 plans
        # UTF-8, explicitly: with no encoding Windows reads the ANSI code page,
        # a plan holding a curly quote raised before anything was saved, and a
        # decodable one saved "stage 2 â†’ 3" and lost every "→" decision.
        content = plan_file.read_text(encoding="utf-8", errors="replace")

        # Parse the plan's Status FIELD (e.g. "**Status:** DRAFT"), not a
        # whole-file substring — a DRAFT plan whose body merely mentions
        # "APPROVED" or "COMPLETED" (a checklist item, or the legend
        # "Status (DRAFT/APPROVED/COMPLETED)") must not be mis-classified.
        m = re.search(r"^\s*\**\s*status\s*\**\s*:\s*\**\s*"
                      r"(draft|approved|completed|implemented|in[ -]?progress)",
                      content, re.IGNORECASE | re.MULTILINE)
        v = m.group(1).lower() if m else "in_progress"
        if v.startswith(("completed", "implemented")):
            continue  # skip finished plans
        status = "approved" if v.startswith("approved") else (
                 "draft" if v.startswith("draft") else "in_progress")

        # Find current task (first unchecked item)
        current_task = None
        for line in content.split("\n"):
            if "- [ ]" in line:
                current_task = line.replace("- [ ]", "").strip()
                break

        return {
            "plan_path": str(plan_file),
            "plan_name": plan_file.name,
            "status": status,
            "current_task": current_task
        }

    return None


def extract_recent_decisions(project_dir: str, limit: int = 3) -> list[str]:
    """Extract recent decisions from the session log."""
    logs_dir = Path(project_dir) / "quality_reports" / "session_logs"
    if not logs_dir.exists():
        return []

    log_files = sorted(logs_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not log_files:
        return []

    content = log_files[0].read_text(encoding="utf-8", errors="replace")
    decisions = []

    # Look for decision markers
    patterns = [
        r"Decision:\s*(.+)",
        r"Decided:\s*(.+)",
        r"Chose:\s*(.+)",
        r"→\s*(.+)",
        r"•\s*(.+)"
    ]

    for line in content.split("\n")[-50:]:  # Last 50 lines
        for pattern in patterns:
            match = re.search(pattern, line.strip())
            if match and len(match.group(1)) > 10:
                decisions.append(match.group(1)[:100])
                if len(decisions) >= limit:
                    return decisions

    return decisions


def save_state(state: dict) -> None:
    """Save state to the session directory."""
    state_file = get_session_dir() / "pre-compact-state.json"
    state["timestamp"] = datetime.now().isoformat()

    try:
        state_file.write_text(json.dumps(state, indent=2), encoding="utf-8")
    except IOError as e:
        print(f"Warning: Could not save pre-compact state: {e}", file=sys.stderr)


def should_block_draft(plan_info: dict | None) -> tuple[bool, str]:
    """Return (should_block, reason). Opt-in via env var. Blocks at most
    once per DRAFT plan so the user can't get stuck in a loop.

    Failure modes (all fail-open — return (False, "")):
    - env var not set to "1"
    - no DRAFT plan active
    - sentinel file unreadable (corrupt JSON, OSError)
    - sentinel write fails (readonly filesystem, etc.)
    Rationale: a user who can't dismiss a block is worse off than one
    who loses a single compaction-blocking opportunity.

    The sentinel lives in its own file (`precompact-block-sentinel.json`)
    which is NOT touched by `post-compact-restore.py`. This is
    deliberate — `pre-compact-state.json` is wiped after each restore,
    which would make this guard fire again on every subsequent
    compaction of the same DRAFT plan.
    """
    if os.environ.get("CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT", "0") != "1":
        return False, ""
    if not plan_info or plan_info.get("status") != "draft":
        return False, ""

    plan_path = plan_info.get("plan_path")
    if not plan_path:
        return False, ""

    sentinel_file = get_session_dir() / "precompact-block-sentinel.json"

    # Fail-open on read errors: if we can't tell whether this plan was
    # already blocked, don't block again. The guard's purpose is to warn
    # once, not to guarantee blocking under adverse conditions.
    try:
        if sentinel_file.exists():
            existing = json.loads(sentinel_file.read_text(encoding="utf-8"))
            if existing.get("last_blocked_plan") == plan_path:
                return False, ""
    except (OSError, json.JSONDecodeError):
        return False, ""

    # Only block if we successfully persist the sentinel. If the write
    # fails, fall through — blocking without a persisted sentinel would
    # cause repeat blocks on every subsequent compaction.
    try:
        sentinel_file.write_text(
            json.dumps({"last_blocked_plan": plan_path, "when": datetime.now().isoformat()}),
            encoding="utf-8",
        )
    except OSError as e:
        print(f"Warning: could not persist block sentinel; not blocking: {e}",
              file=sys.stderr)
        return False, ""

    reason = (
        f"Compaction blocked once: active plan "
        f"{plan_info.get('plan_name', '?')} is still DRAFT. "
        f"Either approve the plan (change its status line to APPROVED) "
        f"or, if you want to proceed without approval, re-run compaction "
        f"— this hook blocks at most once per DRAFT plan. To disable the "
        f"guard entirely, unset CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT (or set "
        f"it to 0)."
    )
    return True, reason


def append_to_session_log(project_dir: str, trigger: str) -> None:
    """Append compaction note to session log."""
    logs_dir = Path(project_dir) / "quality_reports" / "session_logs"
    if not logs_dir.exists():
        return

    log_files = sorted(logs_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not log_files:
        return

    try:
        with open(log_files[0], "a", encoding="utf-8") as f:
            f.write(f"\n\n---\n")
            f.write(f"**Context compaction ({trigger}) at {datetime.now().strftime('%H:%M')}**\n")
            f.write(f"Check git log and quality_reports/plans/ for current state.\n")
    except IOError:
        pass


def format_compaction_message(plan_info: dict | None, decisions: list[str]) -> str:
    """Format the pre-compaction message."""
    lines = []
    lines.append(f"\n{YELLOW}⚡ Context compaction starting{NC}")
    lines.append("")

    if plan_info:
        lines.append(f"{GREEN}Current state saved:{NC}")
        lines.append(f"  Plan: {plan_info['plan_name']} ({plan_info['status']})")
        if plan_info.get("current_task"):
            lines.append(f"  Next task: {plan_info['current_task']}")

    if decisions:
        lines.append("")
        lines.append(f"{GREEN}Recent decisions captured:{NC}")
        for d in decisions:
            lines.append(f"  • {d[:80]}...")

    lines.append("")
    lines.append(f"{CYAN}State will be restored after compaction.{NC}")
    lines.append("")

    return "\n".join(lines)


def main() -> int:
    """Main hook entry point."""
    # Read hook input — bytes, decoded as UTF-8, which is what Claude Code
    # writes; sys.stdin on Windows decodes a pipe with the ANSI code page.
    try:
        hook_input = json.loads(sys.stdin.buffer.read().decode("utf-8", "replace"))
    except (ValueError, OSError):
        hook_input = {}

    trigger = hook_input.get("trigger", "auto")
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")

    if not project_dir:
        return 0

    # Gather state
    plan_info = find_active_plan(project_dir)
    decisions = extract_recent_decisions(project_dir)

    # Build state object
    state = {
        "trigger": trigger,
        "plan_path": plan_info["plan_path"] if plan_info else None,
        "plan_status": plan_info["status"] if plan_info else None,
        "current_task": plan_info.get("current_task") if plan_info else None,
        "decisions": decisions
    }

    # DRAFT-plan guard: opt-in block to avoid losing mid-plan context
    # before the user has approved. Fires at most once per plan.
    block, reason = should_block_draft(plan_info)
    if block:
        # PreCompact accepts the modern block protocol: exit 0 with JSON
        # {"decision":"block","reason":"..."} on stdout. stderr is visible.
        print(f"\n{YELLOW}⚡ Compaction blocked{NC} (DRAFT plan detected)",
              file=sys.stderr)
        print(f"   {reason}\n", file=sys.stderr)
        json.dump({"decision": "block", "reason": reason}, sys.stdout)
        return 0

    # Save state for restoration
    save_state(state)

    # Append note to session log
    append_to_session_log(project_dir, trigger)

    # Print to stderr (PreCompact normally ignores stdout; stderr is
    # shown to user)
    print(format_compaction_message(plan_info, decisions), file=sys.stderr)

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # Fail open — never block Claude due to a hook bug
        sys.exit(0)
