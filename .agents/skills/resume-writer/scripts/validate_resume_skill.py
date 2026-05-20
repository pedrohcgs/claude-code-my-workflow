#!/usr/bin/env python3
"""Static validation for the resume-writer skill package."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def require(path: Path) -> str:
    if not path.exists():
        fail(f"missing required file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def validate_skill_md() -> None:
    text = require(ROOT / "SKILL.md")
    if not text.startswith("---\n"):
        fail("SKILL.md must start with YAML frontmatter")
    match = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not match:
        fail("SKILL.md frontmatter is not closed")
    frontmatter = match.group(1)
    if "name: resume-writer" not in frontmatter:
        fail("SKILL.md frontmatter must include name: resume-writer")
    desc = re.search(r"^description:\s*(.+)$", frontmatter, re.M)
    if not desc or len(desc.group(1)) < 120:
        fail("description should be explicit enough to trigger reliably")

    required_refs = [
        "references/writing-guidelines.md",
        "references/intake-checklist.md",
        "assets/template_cn.tex",
        "assets/template_en.tex",
        "evals/evals.json",
        "scripts/validate_resume_skill.py",
    ]
    for ref in required_refs:
        if ref not in text:
            fail(f"SKILL.md does not reference {ref}")


def validate_templates() -> None:
    for name in ("template_cn.tex", "template_en.tex"):
        text = require(ROOT / "assets" / name)
        for needle in (
            r"\documentclass",
            r"\usepackage[hidelinks]{hyperref}",
            r"\newcommand{\workentry}",
            r"\begin{document}",
            r"\end{document}",
        ):
            if needle not in text:
                fail(f"{name} missing {needle}")
        if text.count(r"\begin{itemize}") != text.count(r"\end{itemize}"):
            fail(f"{name} has unbalanced itemize environments")
        if text.count("<<") != text.count(">>"):
            fail(f"{name} has unbalanced placeholder markers")
        if re.search(r"<<[^>\n]*<<", text):
            fail(f"{name} has nested placeholder markers")


def validate_guidelines() -> None:
    text = require(ROOT / "references" / "writing-guidelines.md")
    required_terms = [
        "Bold Prefix",
        "Capability Over Brands",
        "Independence Gradient",
        "Technical Depth",
        "Quantification",
    ]
    for term in required_terms:
        if term not in text:
            fail(f"writing-guidelines.md missing section signal: {term}")


def validate_evals() -> None:
    data = json.loads(require(ROOT / "evals" / "evals.json"))
    if data.get("skill_name") != "resume-writer":
        fail("evals/evals.json skill_name must be resume-writer")
    evals = data.get("evals")
    if not isinstance(evals, list) or len(evals) < 3:
        fail("evals/evals.json should contain at least 3 eval prompts")
    for item in evals:
        for key in ("id", "prompt", "expected_output", "files"):
            if key not in item:
                fail(f"eval item missing {key}: {item}")


def main() -> None:
    validate_skill_md()
    validate_templates()
    validate_guidelines()
    validate_evals()
    print("resume-writer skill validation passed")


if __name__ == "__main__":
    main()
