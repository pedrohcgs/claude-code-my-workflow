#!/usr/bin/env python3
"""
Context Usage Monitor Hook

Monitors approximate context usage and provides progressive, de-duplicated nudges:
- At 40%, 55%, 65%: suggest /learn for skill extraction
- At 80%: info-level note (auto-compact approaching)
- At 90%: caution-level note (finish the current task at full quality)

Hook Event: PostToolUse (on common tools). Throttled to 60-second intervals
when below the warning threshold.

Output contract (PostToolUse, exit 0): emits JSON on stdout with a `systemMessage`
(shown to the user) AND `hookSpecificOutput.additionalContext` (injected into
Claude's context). Plain stdout would reach Claude but NOT the user, and would
carry literal ANSI escape codes as noise — so we emit clean structured JSON.
See https://code.claude.com/docs/en/hooks.

Context %% is a COARSE PROXY. When the hook receives a `transcript_path`, we
estimate tokens from the transcript size against CLAUDE_CONTEXT_WINDOW_TOKENS
(default 1,000,000 — the 1M-context default on recent Opus/Sonnet tiers; see model-versions.md). Otherwise we
fall back to a tool-call counter (CLAUDE_CONTEXT_MAX_TOOL_CALLS, default 400).
Neither is exact; treat the percentage as a rough early-warning signal, not a
precise gauge.
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

# Thresholds (effective percentage, where 100% ~ auto-compact)
LEARN_THRESHOLDS = [40, 55, 65]
THRESHOLD_WARN = 80
THRESHOLD_CRITICAL = 90

# Throttle interval in seconds (skip checks if below threshold and recent check)
THROTTLE_INTERVAL = 60

# Calibration defaults (both overridable via env)
DEFAULT_CONTEXT_WINDOW_TOKENS = 1_000_000   # 1M default window on recent Opus/Sonnet tiers
DEFAULT_MAX_TOOL_CALLS = 400                 # fallback proxy when transcript size is unavailable
APPROX_BYTES_PER_TOKEN = 4.0


def _env_int(name: str, default: int) -> int:
    """Read a positive int from the environment, falling back to `default`."""
    try:
        value = int(os.environ.get(name, "") or default)
        return value if value > 0 else default
    except ValueError:
        return default


def get_session_dir() -> Path:
    """Get the session directory for storing cache files."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        return Path.home() / ".claude" / "sessions" / "default"

    import hashlib
    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    session_dir = Path.home() / ".claude" / "sessions" / project_hash
    session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


def read_cache() -> dict:
    """Read the context monitor cache."""
    cache_file = get_session_dir() / "context-monitor-cache.json"
    if not cache_file.exists():
        return {}
    try:
        return json.loads(cache_file.read_text(encoding="utf-8"))
    except (ValueError, OSError):
        return {}


def save_cache(data: dict) -> None:
    """Save the context monitor cache."""
    cache_file = get_session_dir() / "context-monitor-cache.json"
    try:
        cache_file.write_text(json.dumps(data, indent=2), encoding="utf-8")
    except IOError:
        pass


def estimate_context_percentage(hook_input: dict) -> float:
    """
    Estimate context usage as a percentage (0-100). COARSE PROXY.

    Preferred: a token estimate from the transcript file size against the model's
    context window (CLAUDE_CONTEXT_WINDOW_TOKENS). Fallback when no transcript is
    available: a tool-call counter (CLAUDE_CONTEXT_MAX_TOOL_CALLS). Neither is exact.
    """
    window = _env_int("CLAUDE_CONTEXT_WINDOW_TOKENS", DEFAULT_CONTEXT_WINDOW_TOKENS)

    transcript_path = hook_input.get("transcript_path", "")
    if transcript_path:
        try:
            size_bytes = os.path.getsize(transcript_path)
            approx_tokens = size_bytes / APPROX_BYTES_PER_TOKEN
            return min(approx_tokens / window * 100, 100)
        except OSError:
            pass

    # Fallback: tool-call counter (very rough)
    cache = read_cache()
    tool_calls = cache.get("tool_calls", 0) + 1
    cache["tool_calls"] = tool_calls
    save_cache(cache)
    max_calls = _env_int("CLAUDE_CONTEXT_MAX_TOOL_CALLS", DEFAULT_MAX_TOOL_CALLS)
    return min((tool_calls / max_calls) * 100, 100)


def is_throttled(percentage: float) -> bool:
    """Check if we should skip this check due to throttling."""
    cache = read_cache()
    last_check = cache.get("last_check_time", 0)
    now = time.time()

    # If below warning threshold and checked recently, skip
    if percentage < THRESHOLD_WARN and (now - last_check) < THROTTLE_INTERVAL:
        return True

    # Update last check time
    cache["last_check_time"] = now
    save_cache(cache)
    return False


def get_shown_thresholds() -> dict:
    """Get which thresholds have already been shown in this session."""
    cache = read_cache()
    return {
        "learn": cache.get("shown_learn", []),
        "warn_80": cache.get("shown_warn_80", False),
        "warn_90": cache.get("shown_warn_90", False)
    }


def mark_threshold_shown(threshold_type: str, value: int | bool = True) -> None:
    """Mark a threshold as shown."""
    cache = read_cache()
    if threshold_type == "learn":
        shown = cache.get("shown_learn", [])
        if value not in shown:
            shown.append(value)
        cache["shown_learn"] = shown
    else:
        cache[f"shown_{threshold_type}"] = value
    save_cache(cache)


def emit(system_message: str, claude_context: str) -> None:
    """Surface a note to BOTH the user and Claude via the PostToolUse JSON contract."""
    print(json.dumps({
        "systemMessage": system_message,
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": claude_context,
        },
    }))


def run_context_monitor() -> int:
    """Main monitoring logic."""
    # Read hook input — bytes, decoded as UTF-8, which is what Claude Code
    # writes. sys.stdin on Windows decodes a pipe with the ANSI code page: a
    # transcript under C:\Users\José\ came out as mojibake, getsize() failed,
    # and the estimate fell back to the tool-call counter (a full transcript
    # read as 0%).
    try:
        hook_input = json.loads(sys.stdin.buffer.read().decode("utf-8", "replace"))
    except (ValueError, OSError):
        hook_input = {}

    # Estimate current context usage (coarse proxy)
    percentage = estimate_context_percentage(hook_input)

    # Persist the latest estimate so the status line can surface it (best-effort).
    try:
        (get_session_dir() / "context-pct.txt").write_text(f"{percentage:.0f}", encoding="utf-8")
    except Exception:
        pass

    # Check throttling
    if is_throttled(percentage):
        return 0

    shown = get_shown_thresholds()

    # Check /learn thresholds (40%, 55%, 65%)
    for threshold in LEARN_THRESHOLDS:
        if percentage >= threshold and threshold not in shown["learn"]:
            emit(
                f"💡 Context ~{percentage:.0f}% (approx) — if a reusable discovery emerged, consider /learn before auto-compaction.",
                f"Context usage is approximately {percentage:.0f}% (coarse proxy). If a non-obvious discovery or reusable workflow emerged this session, suggest that the user run /learn to persist it as a skill before auto-compaction (/learn is user-invoked; you cannot run it yourself).",
            )
            mark_threshold_shown("learn", threshold)
            return 0  # Only show one message at a time

    # Check 90% threshold (critical)
    if percentage >= THRESHOLD_CRITICAL and not shown["warn_90"]:
        emit(
            f"⚠️ Context ~{percentage:.0f}% (approx) — auto-compact approaching. Finish the current task at full quality.",
            f"Context ~{percentage:.0f}% (coarse proxy); auto-compaction is approaching. Complete the current task without cutting corners or skipping verification, and make sure the session log and active plan are saved to disk — no context is lost, but summarize key decisions now.",
        )
        mark_threshold_shown("warn_90", True)
        return 0  # Non-blocking note (exit 2 would feed stderr to Claude)

    # Check 80% threshold (info)
    if percentage >= THRESHOLD_WARN and not shown["warn_80"]:
        emit(
            f"💡 Context ~{percentage:.0f}% (approx) — auto-compact approaching; no rush.",
            f"Context ~{percentage:.0f}% (coarse proxy); auto-compaction will trigger soon. Ensure the session log and active plan are current on disk.",
        )
        mark_threshold_shown("warn_80", True)
        return 0

    return 0


def main() -> int:
    """Main entry point."""
    return run_context_monitor()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # Fail open — never block Claude due to a hook bug
        sys.exit(0)
