#!/usr/bin/env python3
"""
Check cross-document count consistency for the template's public surfaces.

Prevents the drift pattern that hit PRs #70, #76, #78 — where adding a skill
(agent, rule, hook) updates `.claude/` but leaves stale counts in README,
CLAUDE.md, the guide source, the rendered guide, or the landing page.

Run via `./scripts/check-surface-sync.sh` pre-commit, or `/commit` will
invoke it automatically.

Exit codes:
    0 — all counts consistent
    1 — drift detected (prints a diff)
    2 — internal error (missing surface file, unreadable directory)
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# Ground truth: count entries on disk.
GROUND_TRUTH = {
    "skills":       len(list((REPO / ".claude/skills").glob("*/SKILL.md"))),
    "agents":       len(list((REPO / ".claude/agents").glob("*.md"))),
    "rules":        len(list((REPO / ".claude/rules").glob("*.md"))),
    "hooks":        (
        len(list((REPO / ".claude/hooks").glob("*.py"))) +
        len(list((REPO / ".claude/hooks").glob("*.sh")))
    ),
}

# Surfaces to scan + the phrasings that count as "making a claim."
# Each phrasing is a (regex-extracting-the-count, name-of-thing-being-counted) pair.
# The regex MUST have exactly one capture group that yields an integer.
SURFACES = [
    REPO / "README.md",
    REPO / "CLAUDE.md",
    REPO / "guide/workflow-guide.qmd",
    REPO / "docs/workflow-guide.html",
    REPO / "docs/index.html",
    REPO / "templates/skill-template.md",
]

# Phrasings that assert THIS TEMPLATE's counts. We deliberately require
# compound patterns (multiple counts in the same line) or a highly specific
# scaffold ("this template's N") so we don't false-positive on unrelated
# usages like "3 parallel agents", "17 specialized agents" (clo-author's
# count, different template), or "start with 2-3 skills".
#
# Each entry is (regex, ordered list of (group_index, kind)). Group index is
# 1-based. The regex MUST match the compound assertion, not just one count.
COMPOUND_PHRASINGS: list[tuple[str, list[tuple[int, str]]]] = [
    # "13 agents, 27 skills, 21 rules, 6 hooks" (README's <summary>)
    (
        r"(\d+)\s+agents?,\s+(\d+)\s+skills?,\s+(\d+)\s+rules?,\s+(\d+)\s+hooks?",
        [(1, "agents"), (2, "skills"), (3, "rules"), (4, "hooks")],
    ),
    # "13 agents, 27 skills, and 21 rules" (guide's Bottom Line + "full system")
    (
        r"(\d+)\s+agents?,\s+(\d+)\s+skills?,?\s+and\s+(\d+)\s+rules?",
        [(1, "agents"), (2, "skills"), (3, "rules")],
    ),
    # "13 agents, 27 skills, 21 rules" (no 'and', no 'hooks')
    (
        r"(\d+)\s+agents?,\s+(\d+)\s+skills?,\s+(\d+)\s+rules?(?!\s*,)",
        [(1, "agents"), (2, "skills"), (3, "rules")],
    ),
    # og:description: "27 skills, 13 specialized agents, 21 rules"
    (
        r"(\d+)\s+skills?,\s+(\d+)\s+specialized\s+agents?,\s+(\d+)\s+rules?",
        [(1, "skills"), (2, "agents"), (3, "rules")],
    ),
    # Landing page bullet: "27 slash commands + 21 context-aware rules"
    (
        r"(\d+)\s+slash\s+commands?\s*\+\s*(\d+)\s+context-aware\s+rules?",
        [(1, "skills"), (2, "rules")],
    ),
]

# Singular phrasings. These ONLY fire when the match is clearly about this
# template (not attribution, not a generic count). Each must be a scaffold
# specific enough that false positives are unlikely.
SINGULAR_PHRASINGS: list[tuple[str, str]] = [
    # "this template's 27" (prose shortcut in Built-In Skills callout)
    (r"this template's\s+(\d+)\b",                  "skills"),
    # "(N skills for LaTeX..." (templates/skill-template.md trailing note)
    (r"\((\d+)\s+skills?\s+for\b",                  "skills"),
]


def scan_file(path: Path) -> list[tuple[int, str, int, str]]:
    """
    Return [(line_number, kind, asserted_count, raw_match)] for every
    assertion found. `kind` is one of GROUND_TRUTH.keys().
    """
    if not path.exists():
        return []
    hits: list[tuple[int, str, int, str]] = []
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        # Compound assertions: one match yields multiple (group, kind) hits.
        for pattern, group_kinds in COMPOUND_PHRASINGS:
            for m in re.finditer(pattern, line):
                for group_idx, kind in group_kinds:
                    try:
                        n = int(m.group(group_idx))
                    except (ValueError, IndexError):
                        continue
                    hits.append((lineno, kind, n, m.group(0)))
        # Singular assertions: one match, one hit.
        for pattern, kind in SINGULAR_PHRASINGS:
            for m in re.finditer(pattern, line):
                try:
                    n = int(m.group(1))
                except (ValueError, IndexError):
                    continue
                hits.append((lineno, kind, n, m.group(0)))
    return hits


def main() -> int:
    rel = lambda p: p.relative_to(REPO)
    drift: list[str] = []

    # Sanity: every surface file listed must exist.
    missing = [p for p in SURFACES if not p.exists()]
    if missing:
        for p in missing:
            print(f"ERROR: surface file missing: {rel(p)}", file=sys.stderr)
        return 2

    print("Ground truth (counted from disk):")
    for k, v in GROUND_TRUTH.items():
        print(f"  {k:<8} {v}")
    print()

    per_file: dict[Path, list[tuple[int, str, int, str]]] = {}
    for path in SURFACES:
        per_file[path] = scan_file(path)

    for path, hits in per_file.items():
        for lineno, kind, asserted, raw in hits:
            expected = GROUND_TRUTH[kind]
            if asserted != expected:
                drift.append(
                    f"  {rel(path)}:{lineno}  "
                    f"asserts {asserted} {kind} "
                    f"(actual: {expected})  "
                    f"[matched: {raw!r}]"
                )

    if drift:
        print("DRIFT DETECTED:", file=sys.stderr)
        for d in drift:
            print(d, file=sys.stderr)
        print(
            f"\nFix by updating the asserted counts, or if the assertion is "
            f"a false positive (e.g., historical CHANGELOG entry), move it "
            f"to a phrasing this script does not match.",
            file=sys.stderr,
        )
        return 1

    total_assertions = sum(len(v) for v in per_file.values())
    print(f"All {total_assertions} count assertions match ground truth across "
          f"{len(SURFACES)} surfaces.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(2)
