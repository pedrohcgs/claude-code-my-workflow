#!/usr/bin/env python3
"""
Numeric-Claim Reconciliation Hook (PostToolUse)

Event-driven half of the cross-artifact dependency graph: the moment an
analysis script or an `output/` artifact changes, the manuscript's
numeric claims that depend on it may be STALE. Instead of waiting for the
nightly reproducibility Routine, this hook surfaces the staleness
immediately so the author re-runs /audit-reproducibility before relying
on the affected tables.

Fires on Write/Edit to:
  - scripts/**/*.{R,do,py,jl}        (analysis code)      — vertical link
  - output/**                        (regenerated outputs) — vertical link
    (and the pre-v2.6 scripts/**/_outputs/**, kept so older forks still fire)
  - *.{tex,qmd,md,Rmd,typ,ipynb}     (display artifacts)   — horizontal link
when a passport (quality_reports/passports/*.yaml) exists. It counts the
passport claims whose `source_file`/`output_file` mentions the changed
file (their number may have moved) and the claims that declare the changed
file as a display in `location:` / `appears_in:` (their OTHER displays may
now disagree), then emits a one-line systemMessage + additionalContext.
Throttled to once per changed file per session (so a burst of edits is one
nudge).

The hook only counts declarations by path — it never reads a value. It
marks the moment two artifacts can fall out of step; the actual comparison
(vertical tolerance, horizontal coarser-precision) runs in
/audit-reproducibility. See .claude/rules/replication-protocol.md.

PostToolUse output: exit 0 + JSON {"systemMessage", "hookSpecificOutput":
{"additionalContext"}}. Fail-open: any error → exit 0, silent.

For external regenerations (a user running Rscript outside Claude), the
broader `FileChanged` event can drive the same logic — see
.claude/references/scheduled-routines.md.
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
import hashlib
import unicodedata
from pathlib import Path

# Matched against the path with `\` turned into `/` (see main): on Windows
# Claude Code sends `C:\...\scripts\analysis.R`, which a `/`-only pattern never
# matched, so every analysis-code and output/ edit was silent there.
# Case-insensitive, because on macOS and Windows `Scripts/x.R` is `scripts/x.R`.
WATCH = re.compile(r"(^|/)scripts/.*\.(R|do|py|jl)$|(^|/)output/|(^|/)scripts/.*/_outputs/",
                   re.IGNORECASE)
DISPLAY = re.compile(r"\.(tex|qmd|md|rmd|typ|ipynb)$", re.IGNORECASE)
THROTTLE_S = 300


def _fold(s: str) -> str:
    """A path spelling as a case-insensitive disk compares it: NFC, case-folded.
    macOS and Windows open `slides/Lecture1.tex` for `Slides/Lecture1.tex`, and
    a passport written by hand may use either; exact comparison missed both."""
    return unicodedata.normalize("NFC", s).casefold()


def scan_passport(text: str, changed: str):
    """Claim ids in one passport that reference `changed`, split by role.

    Returns (provenance_ids, display_ids): claims whose source_file/output_file
    is the changed path, and claims that declare it as one of SEVERAL displays
    (`location:` plus the `appears_in:` `path:` entries). A claim with a single
    declared display has no sibling to disagree with, so it is not counted —
    `location:` and its matching `appears_in` entry are one display, not two.

    Line-oriented and best-effort by design — the same posture as
    scripts/nightly-repro-check.sh, and cheap enough for a 5s hook.
    """
    blocks: list[dict] = []
    cur = None
    changed_f = _fold(changed)
    for ln in text.splitlines():
        m = re.match(r"\s*-\s*id:\s*(\S+)", ln)
        if m:
            cur = {"id": m.group(1).strip().strip("\"'"), "prov": False, "displays": set()}
            blocks.append(cur)
            continue
        if cur is None:
            continue
        if "source_file" in ln or "output_file" in ln:
            if changed_f in _fold(ln):
                cur["prov"] = True
            continue
        m = re.match(r"\s*-?\s*(?:path|location):\s*(.+)", ln)
        if m:
            # "manuscript.tex:Table 2, Col 3" and "manuscript.tex" are the same
            # display; keep the path part so the two spellings collapse (and
            # drop any trailing ` # comment`, which would split them again).
            val = re.sub(r"\s+#.*$", "", m.group(1)).strip().strip("\"'")
            cur["displays"].add(val.split(":")[0].strip())

    prov = [b["id"] for b in blocks if b["prov"]]
    # Path-EQUALITY, not substring containment: "index.md" must not match a
    # declared display of "docs/index.md", or "report.md" match "final-report.md".
    cn = _fold(os.path.normpath(changed))
    disp = [b["id"] for b in blocks
            if len(b["displays"]) > 1
            and any(_fold(os.path.normpath(d)) == cn for d in b["displays"])]
    return prov, disp


def state_dir() -> Path:
    pd = os.environ.get("CLAUDE_PROJECT_DIR", "")
    h = hashlib.md5(pd.encode()).hexdigest()[:8] if pd else "default"
    d = Path.home() / ".claude" / "sessions" / h
    d.mkdir(parents=True, exist_ok=True)
    return d


def main() -> int:
    # Bytes, decoded as UTF-8 — what Claude Code writes. sys.stdin on Windows
    # decodes a pipe with the ANSI code page, which turned an accented project
    # path into one this hook could not relate to CLAUDE_PROJECT_DIR.
    try:
        data = json.loads(sys.stdin.buffer.read().decode("utf-8", "replace"))
    except (json.JSONDecodeError, EOFError):
        return 0

    ti = data.get("tool_input", {}) or {}
    fp = ti.get("file_path", "") or ""
    fp_n = fp.replace("\\", "/")            # the filters are written with `/`
    if not fp or not (WATCH.search(fp_n) or DISPLAY.search(fp_n)):
        return 0

    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "") or data.get("cwd", "")
    if not project_dir:
        return 0
    passports = sorted((Path(project_dir) / "quality_reports" / "passports").glob("*.yaml"))
    if not passports:
        return 0  # no claims tracked → nothing to reconcile

    # Match + throttle on the project-relative PATH, not the bare basename —
    # otherwise scripts/R/results.rds and scripts/stata/results.rds throttle
    # each other, and clean.R spuriously matches data_clean.R.
    #
    # as_posix() (from PR #152): passports declare "scripts/analysis.R", and
    # str() of a Windows path is "scripts\analysis.R", so the `changed in ln`
    # test never matched and every provenance claim went unflagged there.
    # The prefix is stripped part by part under _fold rather than with
    # relative_to, which is case-sensitive on POSIX: a file_path spelled
    # .../crproj/slides/... for the project .../crproj/Slides/... is the same
    # file on macOS and fell back to the bare basename. Parts are compared,
    # not folded strings sliced, because casefold can change a length (ß → ss).
    try:
        fparts = Path(fp).resolve().parts
        pparts = Path(project_dir).resolve().parts
        if len(fparts) <= len(pparts) or any(
                _fold(a) != _fold(b) for a, b in zip(fparts, pparts)):
            raise ValueError("outside the project")
        changed = Path(*fparts[len(pparts):]).as_posix()
    except Exception:
        changed = Path(fp).name

    # Throttle: one nudge per changed file per THROTTLE_S — keyed on the folded
    # spelling, so case variants of one file share one throttle.
    key = _fold(changed)
    st_path = state_dir() / "claim-reconcile-state.json"
    try:
        st = json.loads(st_path.read_text(encoding="utf-8"))
    except Exception:
        st = {}
    now = time.time()
    if now - st.get(key, 0) < THROTTLE_S:
        return 0
    st[key] = now
    try:
        st_path.write_text(json.dumps(st), encoding="utf-8")
    except Exception:
        pass

    # Count passport claims that reference this file (best-effort text match),
    # separately for the two roles a file can play: it PRODUCED the number, or
    # it DISPLAYS it alongside other artifacts that must still agree.
    prov_where, disp_where = [], []
    prov_total = disp_total = 0
    for p in passports:
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        prov, disp = scan_passport(text, changed)
        if prov:
            prov_where.append(f"{p.name} ({len(prov)})")
            prov_total += len(prov)
        if disp:
            disp_where.append(f"{p.name} ({len(disp)})")
            disp_total += len(disp)
    if not (prov_total or disp_total):
        return 0

    lines, context = [], []
    if prov_total:
        lines.append(f"{prov_total} passport claim(s) may be STALE [{', '.join(prov_where)}]")
        context.append(
            f"A tracked analysis input ({changed}) was just modified. {prov_total} numeric "
            f"claim(s) recorded in {', '.join(prov_where)} depend on it and are now potentially "
            f"stale. Before presenting or committing those numbers, run /audit-reproducibility "
            f"to re-verify them against the regenerated outputs."
        )
    if disp_total:
        lines.append(
            f"{disp_total} claim(s) display a number here whose other displays may now "
            f"disagree [{', '.join(disp_where)}]"
        )
        context.append(
            f"({changed}) is a declared display for {disp_total} passport claim(s) in "
            f"{', '.join(disp_where)}. The same number appears in other artifacts (paper, "
            f"supplement, deck) that were NOT edited, so they may now show a different value. "
            f"Run /audit-reproducibility for the horizontal check — every declared display of a "
            f"claim must agree at the coarser of the two display precisions."
        )
    msg = f"⟳ {changed} changed — " + "; ".join(lines) + ". Run /audit-reproducibility."
    json.dump({
        "systemMessage": msg,
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": " ".join(context),
        },
    }, sys.stdout)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail open
