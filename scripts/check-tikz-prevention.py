#!/usr/bin/env python3
"""
check-tikz-prevention.py — shared multi-line-aware prevention pre-check.

Invoked by /extract-tikz and /new-diagram as their Step 1 gate.
Reports P3 and P4 violations from tikz-prevention.md.

- P3: bare `scale=X` in a tikzpicture options block without accompanying node
      scaling (`every node/.style={scale=X}` or `transform shape`).
- P4: edge label (`node {...}` attached to a `\\draw`) without a directional
      keyword (`above`, `below`, `left`, `right`, or a compound).

Unlike a line-oriented grep, this handles:
  - Multi-line tikzpicture option blocks: `\\begin{tikzpicture}[\\n scale=0.8\\n]`
  - Multi-line draw commands where `node {...}` is on a different line than `\\draw`.

Usage:
  python3 scripts/check-tikz-prevention.py FILE.tex [FILE2.tex ...]

Exit codes:
  0 = all files pass
  1 = one or more P3/P4 violations (details on stderr)
  2 = usage / input error
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


# P4: a directional keyword must appear as a STANDALONE option, not as a
# value fragment (e.g., `align=left` is not a direction; `left` or
# `above left` is). We enforce this by checking the option token after
# splitting on commas and stripping any `key=` prefix (see has_direction_option).
DIRECTIONS = frozenset(["above", "below", "left", "right"])

# Opener of a tikzpicture environment. The `[...]` options block may span
# multiple lines and can contain brace-delimited values, so we CANNOT match
# the closing `]` with a simple `[^\]]*` greedy regex (that breaks on
# `scale={0.8}`). Instead we locate the opener and then use a brace/bracket
# balancer to find the real end.
TIKZPICTURE_OPENER_RE = re.compile(r"\\begin\{tikzpicture\}\s*\[", re.DOTALL)

DRAW_STATEMENT_RE = re.compile(
    r"\\draw\b(?P<body>.*?);",
    re.DOTALL,
)

# `node {...}` or `node[...] {...}` or `node [...] {...}` inside a \draw body.
# The options group uses a balanced bracket matcher applied separately since
# Python's re can't balance brackets — we use a simple scanner in find_nodes.
NODE_START_RE = re.compile(r"\bnode\b", re.DOTALL)


def strip_comments(text: str) -> str:
    """Strip TeX line comments so a `%` in prose doesn't hide real violations."""
    out_lines = []
    for line in text.splitlines(keepends=True):
        i = 0
        while i < len(line):
            if line[i] == "%" and (i == 0 or line[i - 1] != "\\"):
                break
            i += 1
        out_lines.append(line[:i] + ("\n" if line.endswith("\n") else ""))
    return "".join(out_lines)


def line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def find_balanced_close(text: str, start: int, open_ch: str, close_ch: str) -> int:
    """
    Return the index of the matching close bracket/brace after `start` (which
    must already be past the opener). Honors nested `{...}` inside `[...]`
    (and vice versa). Returns -1 if no match found.
    """
    depth = 1
    i = start
    n = len(text)
    while i < n:
        c = text[i]
        if c == "\\" and i + 1 < n:
            # Skip TeX escape sequences like \{ or \}
            i += 2
            continue
        if c == "{":
            # A `{...}` value INSIDE an options block contributes to brace
            # depth but not bracket depth. We use a separate counter so the
            # outer `[...]` balancing isn't confused by `scale={0.8}`.
            brace_depth = 1
            j = i + 1
            while j < n and brace_depth > 0:
                if text[j] == "\\" and j + 1 < n:
                    j += 2
                    continue
                if text[j] == "{":
                    brace_depth += 1
                elif text[j] == "}":
                    brace_depth -= 1
                j += 1
            i = j
            continue
        if c == open_ch:
            depth += 1
        elif c == close_ch:
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def split_options(options_text: str) -> list[str]:
    """
    Split a TikZ options block on top-level commas, respecting `{...}` and
    `[...]` nesting so `every node/.style={scale=1.1, foo=bar}` stays one
    option. Returns stripped option tokens.
    """
    parts: list[str] = []
    buf = []
    depth_brace = 0
    depth_bracket = 0
    i = 0
    n = len(options_text)
    while i < n:
        c = options_text[i]
        if c == "\\" and i + 1 < n:
            buf.append(c)
            buf.append(options_text[i + 1])
            i += 2
            continue
        if c == "{":
            depth_brace += 1
        elif c == "}":
            depth_brace -= 1
        elif c == "[":
            depth_bracket += 1
        elif c == "]":
            depth_bracket -= 1
        if c == "," and depth_brace == 0 and depth_bracket == 0:
            parts.append("".join(buf).strip())
            buf = []
        else:
            buf.append(c)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    return [p for p in parts if p]


def parse_options(text: str, start: int) -> tuple[str | None, int]:
    """
    Given text with `[` at position `start`, return (options_content, end_pos)
    where end_pos is the index of the matching `]`. Returns (None, -1) on
    unbalanced input.
    """
    close = find_balanced_close(text, start + 1, "[", "]")
    if close < 0:
        return None, -1
    return text[start + 1 : close], close


def has_scale(options_tokens: list[str]) -> bool:
    """True if any top-level token is `scale=SOMETHING` (any literal form)."""
    for tok in options_tokens:
        # strip whitespace and leading slashes / keys like `scale=...`
        if re.match(r"\s*scale\s*=", tok):
            return True
    return False


def has_node_scaling(options_tokens: list[str]) -> bool:
    """True if the options block includes a node-scaling sibling."""
    for tok in options_tokens:
        tok_stripped = tok.strip()
        # every node/.style={... scale=... ...}
        if re.match(r"every\s+node\s*/\s*\.style\s*=\s*\{", tok_stripped):
            if re.search(r"\bscale\s*=", tok_stripped):
                return True
        # transform shape
        if re.match(r"^transform\s+shape\b", tok_stripped):
            return True
    return False


def find_node_in_draw(body: str) -> list[tuple[int, str | None, int]]:
    """
    Find every `node {...}` or `node[OPTS] {...}` occurrence in a draw body.
    Returns list of (node_start, options_text_or_None, brace_start).
    brace_start is the index of the `{` of the node label.
    """
    found: list[tuple[int, str | None, int]] = []
    for m in NODE_START_RE.finditer(body):
        pos = m.end()
        # Optional whitespace, then optional `[...]` options, then `{`
        i = pos
        while i < len(body) and body[i] in " \t\n":
            i += 1
        options_text: str | None = None
        if i < len(body) and body[i] == "[":
            opts, close = parse_options(body, i)
            if opts is None:
                # Unbalanced — treat as malformed; skip but don't crash
                continue
            options_text = opts
            i = close + 1
            while i < len(body) and body[i] in " \t\n":
                i += 1
        if i < len(body) and body[i] == "{":
            found.append((m.start(), options_text, i))
    return found


def has_direction_option(options_text: str | None) -> bool:
    """
    True iff the options block contains a directional keyword as an OPTION
    NAME (not as a value fragment).

    Legitimate direction tokens in TikZ:
      - `above`, `below`, `left`, `right` as bare options
      - Compounds: `above left`, `below right`, etc.
      - With distance/relative: `below=0.55cm`, `above=of A`, `right=2mm`
      - Combined with position-along-path: `midway, above`, `near start, left`

    NOT directions (false-positive guard):
      - `align=left` — text alignment, a different key entirely
      - `text align=right` — same
      - Any `key=value` where the KEY is not itself a direction word
    """
    if not options_text:
        return False
    tokens = split_options(options_text)
    for tok in tokens:
        tok = tok.strip()
        # Handle `key=value` — a direction if the key IS a direction word.
        if "=" in tok:
            key = tok.split("=", 1)[0].strip()
            # Compound keys like `above of` or `below left` also count.
            key_words = key.split()
            if key_words and key_words[0] in DIRECTIONS:
                return True
            # Otherwise skip (this handles align=left, text-align=left, etc.)
            continue
        # Bare option — any word in it is a direction?
        for word in tok.split():
            if word in DIRECTIONS:
                return True
    return False


def check_p3(stripped: str) -> list[tuple[int, str]]:
    violations: list[tuple[int, str]] = []
    for m in TIKZPICTURE_OPENER_RE.finditer(stripped):
        bracket_pos = m.end() - 1  # position of `[`
        opts, _ = parse_options(stripped, bracket_pos)
        if opts is None:
            # Unbalanced options block — surface as a parse error, not silent.
            raise ValueError(
                f"Unbalanced `[` in \\begin{{tikzpicture}} at line "
                f"{line_of(stripped, m.start())}"
            )
        tokens = split_options(opts)
        if has_scale(tokens) and not has_node_scaling(tokens):
            ln = line_of(stripped, m.start())
            snippet = re.sub(r"\s+", " ", opts).strip()
            violations.append((ln, f"\\begin{{tikzpicture}}[{snippet}]"))
    return violations


def check_p4(stripped: str) -> list[tuple[int, str]]:
    violations: list[tuple[int, str]] = []
    for m in DRAW_STATEMENT_RE.finditer(stripped):
        body = m.group("body")
        for node_start, options_text, brace_start in find_node_in_draw(body):
            if not has_direction_option(options_text):
                node_offset = m.start() + node_start
                ln = line_of(stripped, node_offset)
                snippet_raw = body[node_start : min(brace_start + 40, len(body))]
                snippet = re.sub(r"\s+", " ", snippet_raw).strip()
                violations.append((ln, f"\\draw ... {snippet}"))
    return violations


def check_file(path: Path) -> int:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        # Return 2 (input error), not 1 (violation) — read failure is "couldn't do
        # the job" not "did the job and found problems". main() uses max(rc, ...)
        # so 2 correctly dominates any prior 1.
        print(f"ERROR: cannot read {path}: {e}", file=sys.stderr)
        return 2

    stripped = strip_comments(text)
    p3 = check_p3(stripped)
    p4 = check_p4(stripped)

    if not p3 and not p4:
        return 0

    print(f"\n{path} — prevention violations", file=sys.stderr)
    for ln, snippet in p3:
        print(f"  P3 @ line {ln}: bare scale= without node scaling", file=sys.stderr)
        print(f"      {snippet}", file=sys.stderr)
    for ln, snippet in p4:
        print(f"  P4 @ line {ln}: edge label without directional keyword", file=sys.stderr)
        print(f"      {snippet}", file=sys.stderr)
    return 1


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2

    rc = 0
    for arg in sys.argv[1:]:
        p = Path(arg)
        if not p.exists():
            print(f"ERROR: not found: {arg}", file=sys.stderr)
            rc = 2
            continue
        rc = max(rc, check_file(p))

    if rc == 0:
        print(f"OK: {len(sys.argv) - 1} file(s) pass P3+P4 prevention checks.")
    return rc


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        # Fail VISIBLY on parse errors so adversarial input doesn't silently
        # pass. Exit 2 (usage/parse error) makes skills halt instead of
        # continuing as if the check succeeded.
        print(f"check-tikz-prevention.py parse error: {e}", file=sys.stderr)
        sys.exit(2)
