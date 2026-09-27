#!/usr/bin/env python3
"""Audit every skill against the Agent Skills spec (agentskills.io/specification).

Checks: name format + directory match, description length, SKILL.md body size,
fields that no consumer reads, and portability of the frontmatter.

Exit: 0 clean (advisories allowed), 1 spec violation, 2 internal error.
"""
import re, os, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPEC_FIELDS = {"name","description","license","compatibility","metadata","allowed-tools"}
# Fields Claude Code documents beyond the portable spec (verified 2026-08-21).
CC_ONLY = {"when_to_use","argument-hint","arguments","disable-model-invocation","user-invocable",
           "disallowed-tools","model","effort","context","agent","background","hooks","paths","shell"}
NAME_RE = re.compile(r'[a-z0-9]+(-[a-z0-9]+)*')

def main():
    errs, warns = [], []
    # glob.escape: a clone at "Paper [2026]" read its own path as a character class
    # and found "no skills" (#171).
    skills = sorted(glob.glob(os.path.join(glob.escape(ROOT), ".claude/skills/*/SKILL.md")))
    if not skills:
        print("check-spec-conformance: no skills found", file=sys.stderr); return 2
    for f in skills:
        d = os.path.basename(os.path.dirname(f))
        rel = os.path.relpath(f, ROOT)
        # utf-8-sig drops a leading BOM (PowerShell 5.1 writes one), which otherwise
        # hid intact frontmatter behind "no YAML frontmatter" — Claude Code's own
        # skill loader strips it.
        s = open(f, encoding="utf-8-sig", errors="ignore").read()
        m = re.match(r'^---\n(.*?)\n---\n(.*)$', s, re.S)
        if not m:
            errs.append(f"{rel}: no YAML frontmatter"); continue
        fm, body = m.group(1), m.group(2)
        def field(k):
            # Value = rest of THIS line plus indented continuation lines only.
            # The old \s* skipped a blank value across the newline and returned
            # the NEXT key's line, so an empty description: passed (v2.5 audit).
            mm = re.search(rf'^{re.escape(k)}:[ \t]*(.*(?:\n[ \t]+\S.*)*)', fm, re.M)
            return mm.group(1).strip() if mm else None
        name = (field("name") or "").strip().strip('"\'')
        desc = field("description") or ""
        if not name:                       errs.append(f"{rel}: missing required 'name'")
        elif not NAME_RE.fullmatch(name):  errs.append(f"{rel}: name '{name}' violates spec format")
        elif name != d:                    errs.append(f"{rel}: name '{name}' != directory '{d}'")
        if not desc:                       errs.append(f"{rel}: missing required 'description'")
        elif len(desc) > 1024:             errs.append(f"{rel}: description {len(desc)} chars > 1024 spec max")
        n = body.count("\n")
        if n > 500:                        errs.append(f"{rel}: body {n} lines > 500 (spec guidance: split into references/)")
        keys = set(re.findall(r'^([a-zA-Z_-]+):', fm, re.M))
        unknown = keys - SPEC_FIELDS - CC_ONLY
        if unknown:
            errs.append(f"{rel}: field(s) {sorted(unknown)} read by neither the spec nor Claude Code "
                        f"— move under 'metadata:'")
        nonportable = keys & CC_ONLY
        if nonportable:
            warns.append(f"{rel}: {sorted(nonportable)} are Claude Code-only "
                         f"(blocks claude.ai upload / Skills API / Cowork / Routines)")
    print(f"check-spec-conformance: {len(skills)} skills audited")
    if errs:
        print(f"\n{len(errs)} SPEC VIOLATION(S):")
        for e in errs: print(f"  {e}")
    if warns:
        print(f"\n{len(warns)} portability advisory(ies) — not failures, a deliberate ceiling:")
        for w in warns[:3]: print(f"  {w}")
        if len(warns) > 3: print(f"  … and {len(warns)-3} more")
    if not errs: print("\nAll skills conform to the Agent Skills spec.")
    return 1 if errs else 0

if __name__ == "__main__":
    # The advisory header prints an em dash on every run. A pipe on Japanese or
    # Korean Windows (cp932, cp949) cannot encode one, and the print crashed the
    # gate (#171): replace what the code page lacks rather than die.
    try:
        sys.stdout.reconfigure(errors="replace")
    except (AttributeError, ValueError):
        pass
    sys.exit(main())
