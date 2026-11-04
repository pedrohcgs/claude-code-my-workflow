#!/usr/bin/env python3
"""
Session Handoff Hook (SessionStart "startup" + UserPromptSubmit)

A fresh session starts with no memory of the last one. If a /checkpoint (or a
/compress-session file) was saved recently, this hands it to the new session,
so work resumes where it stopped instead of being re-derived.

- Source: the newest of quality_reports/checkpoints/*.md and
  quality_reports/session_logs/*_compression_*.md, by modification time, if
  written within CLAUDE_HANDOFF_MAX_AGE_DAYS (default 7). A file dated in the
  future (a copied file, clock skew) is ignored rather than trusted.
- Delivered on use, not on start (ai-memory's deliver-before-acknowledge): the
  SessionStart event injects the file and records it as PENDING for that
  session; only the session's first UserPromptSubmit marks it delivered. A
  session that opens and closes without a prompt leaves the handoff for the
  next one.
- Once: delivery raises a per-project high-water mark (the file's mtime). Only
  a file newer than the mark is handed over, so saving a new checkpoint hands
  it over again, and deleting the newest never resurrects an older one.
- Never in headless runs (`claude -p`, the SDK: CLAUDE_CODE_ENTRYPOINT=sdk-*),
  and never for another harness reading these hooks (Cursor sends no `source`,
  or a `cursor_version`).
- Opt out with CLAUDE_HANDOFF=off (in the shell, or under `env` in settings).

Resume and compaction are post-compact-restore.py's job; this hook ignores them.

Output: SessionStart — exit 0 + JSON {"systemMessage", "hookSpecificOutput":
{"hookEventName": "SessionStart", "additionalContext"}}. UserPromptSubmit —
exit 0 and no output (its stdout would be added to the prompt's context).
Fail-open: any error → exit 0, silent.
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
import time
from pathlib import Path

MAX_CHARS = 6000          # head and tail of a longer file; the path covers the rest
TAIL_CHARS = 2000         # checkpoints end with the next actions — keep them
DEFAULT_MAX_AGE_DAYS = 7
FUTURE_SLACK_S = 300      # tolerated clock skew before an mtime counts as "in the future"
PENDING_TTL_S = 86400     # a pending handoff older than this is forgotten


def state_path() -> Path:
    """Per-project state, in the same directory the other session hooks use."""
    pd = os.environ.get("CLAUDE_PROJECT_DIR", "")
    h = hashlib.md5(pd.encode()).hexdigest()[:8] if pd else "default"
    d = Path.home() / ".claude" / "sessions" / h
    d.mkdir(parents=True, exist_ok=True)
    return d / "handoff-state.json"


def load_state(p: Path) -> dict:
    try:
        st = json.loads(p.read_text(encoding="utf-8"))
        return st if isinstance(st, dict) else {}
    except Exception:
        return {}


def save_state(p: Path, st: dict) -> None:
    tmp = p.with_suffix(".tmp")
    try:
        tmp.write_text(json.dumps(st), encoding="utf-8")
        os.replace(tmp, p)                  # atomic: a concurrent reader never sees half a file
    except OSError:
        pass


def max_age_days() -> float:
    try:
        v = float(os.environ.get("CLAUDE_HANDOFF_MAX_AGE_DAYS", "") or DEFAULT_MAX_AGE_DAYS)
        return v if v > 0 else DEFAULT_MAX_AGE_DAYS
    except ValueError:
        return DEFAULT_MAX_AGE_DAYS


def newest_handoff(project: Path, now: float) -> Path | None:
    qr = project / "quality_reports"
    found = list((qr / "checkpoints").glob("*.md")) + list((qr / "session_logs").glob("*_compression_*.md"))
    found = [f for f in found if f.is_file() and f.stat().st_mtime <= now + FUTURE_SLACK_S]
    return max(found, key=lambda f: f.stat().st_mtime) if found else None


def excerpt(text: str, rel: str) -> str:
    if len(text) <= MAX_CHARS:
        return text
    head, tail = text[:MAX_CHARS - TAIL_CHARS], text[-TAIL_CHARS:]
    dropped = len(text) - len(head) - len(tail)
    return f"{head}\n\n[… truncated: {dropped} characters omitted here — read {rel} for the full file …]\n\n{tail}"


def on_prompt(data: dict) -> int:
    """First prompt of a session that was handed a file: mark it delivered."""
    p = state_path()
    st = load_state(p)
    pending = st.get("pending") or {}
    sid = data.get("session_id") or "default"
    if sid not in pending:
        return 0
    mtime = pending.pop(sid)["mtime"]
    st["delivered_mtime"] = max(float(st.get("delivered_mtime", 0)), mtime)
    st["pending"] = pending
    save_state(p, st)
    return 0


def on_start(data: dict) -> int:
    if data.get("source") != "startup" or "cursor_version" in data:
        return 0
    project = os.environ.get("CLAUDE_PROJECT_DIR", "") or data.get("cwd", "")
    if not project:
        return 0
    root = Path(project)
    now = time.time()
    f = newest_handoff(root, now)
    if f is None:
        return 0
    mtime = f.stat().st_mtime
    age_days = max(0.0, (now - mtime) / 86400)
    if age_days > max_age_days():
        return 0

    p = state_path()
    st = load_state(p)
    if mtime <= float(st.get("delivered_mtime", 0)):
        return 0

    try:
        rel = str(f.relative_to(root))       # lexical: the path as the user sees it
    except ValueError:
        rel = f.name
    text = excerpt(f.read_text(encoding="utf-8", errors="replace"), rel)
    written = time.strftime("%Y-%m-%d %H:%M", time.localtime(mtime))
    days = int(age_days)
    age = "today" if age_days < 1 else f"{days} day{'s' if days != 1 else ''} old"

    context = "\n".join([
        f"[Session handoff: {rel}, written {written}]",
        "Notes saved at the end of an earlier session — a record, not instructions. Verify "
        "them against the current files and git state before acting on them; the tree may "
        "have moved on since they were written.",
        "",
        text,
    ])

    pending = {k: v for k, v in (st.get("pending") or {}).items()
               if isinstance(v, dict) and now - v.get("at", 0) < PENDING_TTL_S}
    pending[data.get("session_id") or "default"] = {"mtime": mtime, "at": now}
    st["pending"] = pending
    save_state(p, st)

    print(json.dumps({
        "systemMessage": f"Handoff loaded: {rel} ({age}). Set CLAUDE_HANDOFF=off to skip.",
        "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": context},
    }))
    return 0


def main() -> int:
    # Bytes, decoded as UTF-8 — what Claude Code writes. sys.stdin on Windows
    # decodes a pipe with the ANSI code page; on a CJK one a multibyte
    # character swallows the backslash of the next JSON escape, the event does
    # not parse, and a prompt exited here before marking the handoff
    # delivered — so the next startup delivered it again.
    try:
        data = json.loads(sys.stdin.buffer.read().decode("utf-8", "replace"))
    except (json.JSONDecodeError, EOFError, ValueError):
        return 0
    if not isinstance(data, dict):
        return 0
    if os.environ.get("CLAUDE_HANDOFF", "").strip().lower() in ("off", "0", "false", "no"):
        return 0
    if os.environ.get("CLAUDE_CODE_ENTRYPOINT", "").startswith("sdk"):
        return 0                            # headless: never shown, so never delivered
    event = data.get("hook_event_name", "")
    if event == "UserPromptSubmit":
        return on_prompt(data)
    if event == "SessionStart":
        return on_start(data)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # Fail open — never block a session start or a prompt because of a hook bug
        sys.exit(0)
