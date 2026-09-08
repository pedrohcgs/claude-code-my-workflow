#!/usr/bin/env python3
"""Make the qualification ledger load-bearing: what runs and what is recorded must agree.

The ledger's own rule is that a checker with no row is unqualified and its green
light means nothing. Until now nothing enforced that rule — the ledger could drift
from the repo in either direction and every gate stayed green.

Both directions fail here:

  1. a check that RUNS but has no ledger row — an unmeasured green light. A row in
     the "Not yet qualified" section counts as VISIBLE DEBT and only warns: the job
     is to prevent SILENT absence, not to force instant qualification.
  2. a ledger row naming a checker that is no longer on disk — a qualification for
     a ghost, which reads as coverage the repo does not have.

Plus wiring: a mistyped path in `.claude/settings.json` costs you the GUARDING,
and no other gate in the suite notices — nothing else reads the settings file
against the disk, so a hook can be wired to nothing while every check stays green.
That is the failure this checker exists to catch. The symptom is not silence, and
it is not legible either: `python3 <missing-path>` exits 2, which a PreToolUse hook
means as BLOCK, so a typo on a guard denies every matching call with an interpreter
error nobody reads as a config error; a bare path exits 127 (126 if present but not
executable), a non-blocking error that scrolls past while the guard stops guarding.

Registered checks are derived LIVE from three sources of truth — the `run` lines in
`scripts/backtest.sh`, the hook commands in `.claude/settings.json`, and the
`.githooks/pre-commit` entry point. Never a hardcoded list: a list here would drift
exactly the way the ledger does, and this checker would be the last to notice.

Exit: 0 agreement (warnings allowed), 1 disagreement, 2 could not run.
"""
import json, os, re, shlex, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS = os.path.join(ROOT, "scripts")

LEDGER = "quality_reports/qualification/LEDGER.md"
SETTINGS = ".claude/settings.json"
CODEX_HOOKS = ".codex/hooks.json"
BACKTEST = "scripts/backtest.sh"
PRECOMMIT = ".githooks/pre-commit"

# The ledger section that records checks known to be unqualified. A name there is
# debt someone can see and schedule; a name nowhere at all is the failure.
DEBT_HEADING = "not yet qualified"

# A command whose first word is one of these runs the NEXT argument as a script,
# so the script itself needs only to exist and be readable — not to be executable.
INTERPRETERS = {"python", "python3", "bash", "sh", "zsh", "node", "Rscript", "perl", "ruby", "uv"}

# What counts as a checker name in a ledger cell. Deliberately narrow: ledger rows
# also backtick artifacts, flags, and shell fragments, and none of those are checks.
# Extension-less entry points (git's own hook names) carry no signature of their own,
# so they are admitted only by matching something that demonstrably runs.
SCRIPT_TOKEN = re.compile(r'^[\w./-]+\.(?:py|sh)$')

# Where an unqualified (directory-less) ledger name may live.
SEARCH_DIRS = ["", "scripts", ".claude/hooks", ".claude/scripts", ".codex/hooks", ".githooks"]


class CannotRun(Exception):
    """A source of truth could not be read. A check that could not run is not a passing check."""


def read(rel):
    try:
        return open(os.path.join(ROOT, rel), encoding="utf-8").read()
    except OSError as e:
        raise CannotRun(f"{rel}: cannot read ({e.strerror or e})")


def expand(tok):
    """Resolve the two path variables the harness and the gate runner inject."""
    tok = tok.replace("${CLAUDE_PROJECT_DIR}", ROOT).replace("$CLAUDE_PROJECT_DIR", ROOT)
    return tok.replace("${DIR}", SCRIPTS).replace("$DIR", SCRIPTS)


def script_of(command, where):
    """The script a shell command actually runs, and the interpreter it runs under."""
    # Project-local Codex hook commands resolve the root at runtime with
    # ``$(git rev-parse --show-toplevel)``. shlex correctly splits the shell
    # words but cannot evaluate the substitution; extract the stable suffix.
    dynamic = re.search(r'(?:^|["\s])(?:[^"\s]*/)?(\.codex/hooks/[\w.-]+\.(?:py|sh))', command)
    if dynamic:
        toks0 = shlex.split(command)
        interp0 = os.path.basename(toks0[0]) if toks0 and os.path.basename(toks0[0]) in INTERPRETERS else None
        return os.path.join(ROOT, dynamic.group(1)), interp0
    try:
        toks = shlex.split(command)
    except ValueError as e:
        raise CannotRun(f"{where}: cannot tokenize command ({e})")
    if not toks:
        raise CannotRun(f"{where}: empty command")
    interp, i = None, 0
    if os.path.basename(toks[0]) in INTERPRETERS:
        interp, i = os.path.basename(toks[0]), 1
        while i < len(toks) and toks[i].startswith("-"):
            i += 1
    if i >= len(toks):
        raise CannotRun(f"{where}: no script path in command: {command}")
    p = expand(toks[i])
    return os.path.normpath(p if os.path.isabs(p) else os.path.join(ROOT, p)), interp


def registered():
    """Every check that actually runs, derived live. Returns (source, path, interpreter, where)."""
    out = []

    gates = re.findall(r'^run\s+"([^"]+)"\s+(.+?)\s*$', read(BACKTEST), re.M)
    if not gates:
        raise CannotRun(f'{BACKTEST}: no `run "label" ...` gate lines found — the gate-line '
                        "format changed and this checker is now blind to every gate")
    for label, cmd in gates:
        path, interp = script_of(cmd, f"{BACKTEST} gate '{label}'")
        out.append(("backtest gate", path, interp, label))

    try:
        cfg = json.loads(read(SETTINGS))
    except json.JSONDecodeError as e:
        raise CannotRun(f"{SETTINGS}: invalid JSON ({e})")
    hooks = cfg.get("hooks")
    if not isinstance(hooks, dict) or not hooks:
        raise CannotRun(f"{SETTINGS}: no `hooks` object — the session hooks are registered there, "
                        "and an empty one means either a broken file or silently no hooks at all")
    for event in sorted(hooks):
        for group in hooks[event] or []:
            for h in group.get("hooks") or []:
                if h.get("type") != "command":
                    continue
                path, interp = script_of(h.get("command", ""), f"{SETTINGS} {event}")
                out.append(("settings hook", path, interp, event))

    # The native Codex port has an independent lifecycle registry. It becomes
    # mandatory when the port manifest exists, and every command hook joins the
    # same qualification/wiring accounting as the Claude registry.
    codex_manifest = os.path.join(ROOT, ".codex", "port-manifest.toml")
    codex_hooks_path = os.path.join(ROOT, CODEX_HOOKS)
    if os.path.exists(codex_manifest) or os.path.exists(codex_hooks_path):
        try:
            codex_cfg = json.loads(read(CODEX_HOOKS))
        except json.JSONDecodeError as e:
            raise CannotRun(f"{CODEX_HOOKS}: invalid JSON ({e})")
        codex_hooks = codex_cfg.get("hooks")
        if not isinstance(codex_hooks, dict) or not codex_hooks:
            raise CannotRun(f"{CODEX_HOOKS}: no `hooks` object")
        for event in sorted(codex_hooks):
            for group in codex_hooks[event] or []:
                for h in group.get("hooks") or []:
                    if h.get("type") != "command":
                        continue
                    path, interp = script_of(h.get("command", ""), f"{CODEX_HOOKS} {event}")
                    out.append(("codex hook", path, interp, event))

    out.append(("entry point", os.path.join(ROOT, PRECOMMIT), None, "pre-commit"))
    return out


def ledger_names(known):
    """Checker names the ledger claims, split into qualified rows and visible debt.

    `known` is the set of registered basenames, which is what lets an extension-less
    entry point be recognised without hardcoding git's hook names here.

    Name-extraction is SCOPED BY SECTION, not applied to every table row: a token
    is read as a qualification claim only inside the debt section (`## Not yet
    qualified`) or a section whose heading records qualification (`qualif` in it,
    including the top-level `# Qualification Ledger`). A stray backticked hook path
    in an unrelated table — a future change-log or reproduction table pasted in —
    is therefore NOT silently read as a qualified checker. And a missing debt
    heading is treated as format drift (CannotRun), the same as the other two
    format dependencies, so a reworded debt section cannot silently promote every
    unmeasured checker to qualified.
    """
    qualified, debt = {}, {}
    section_qual = section_debt = seen_debt = False
    for line in read(LEDGER).split("\n"):
        head = re.match(r'^#+\s+(.*)', line)
        if head:
            h = head.group(1).strip().lower()
            section_debt = DEBT_HEADING in h
            section_qual = (not section_debt) and ("qualif" in h)
            if section_debt:
                seen_debt = True
            continue
        if not line.lstrip().startswith("|"):
            continue
        if not (section_qual or section_debt):
            continue
        bucket = debt if section_debt else qualified
        for tok in (t.strip() for t in re.findall(r'`([^`]+)`', line)):
            # r21: a checker NAME is one path and never contains whitespace. A row
            # may legitimately backtick a COMMAND that happens to end in a known
            # checker's basename — the r20 rows quote `rm -f .clau\de/hooks/…` and
            # `rm -f .githook\s/pre-commit` as the measured bypass spellings — and
            # before this guard both were read as qualification claims naming a file
            # that does not exist, failing the gate on prose rather than on coverage.
            # Splitting on whitespace is the whole fix: it cannot hide a real claim,
            # because a real one has no space to split on.
            if re.search(r'\s', tok):
                continue
            if SCRIPT_TOKEN.match(tok) or os.path.basename(tok) in known:
                bucket.setdefault(os.path.basename(tok), set()).add(tok)
    if not seen_debt:
        raise CannotRun(f"{LEDGER}: no '{DEBT_HEADING}' section heading found — the debt-section "
                        "heading changed or was removed, so every unqualified checker would "
                        "silently read as qualified; refusing to report agreement")
    if not qualified and not debt:
        raise CannotRun(f"{LEDGER}: no checker name found in any qualification or debt table row — "
                        "the ledger format changed and this checker is now blind to every row")
    return qualified, debt


def named_by(path, names, require_qualified_path=False):
    """Does `names` name this path?

    Codex hooks deliberately require a directory-qualified token because four
    filenames overlap the Claude registry. A bare ``git-guardrails.py`` row
    proves one implementation, not both platform-specific event adapters.
    """
    rel = os.path.relpath(path, ROOT)
    return any((not require_qualified_path and "/" not in tok) or rel.endswith(tok)
               for tok in names.get(os.path.basename(path), ()))


def resolve(tok):
    """Where a ledger name lives on disk, or None."""
    cands = [os.path.join(ROOT, tok)] if "/" in tok else \
            [os.path.join(ROOT, d, tok) for d in SEARCH_DIRS]
    return next((os.path.normpath(c) for c in cands if os.path.isfile(c)), None)


def tracked_files():
    r = subprocess.run(["git", "-C", ROOT, "ls-files"], capture_output=True, text=True)
    files = {f for f in r.stdout.split("\n") if f}
    if not files:
        raise CannotRun("git ls-files returned nothing (not a git repo?) — cannot verify that "
                        "the registered checks survive a fresh clone")
    return files


def main():
    try:
        checks = registered()
        qualified, debt = ledger_names({os.path.basename(p) for _, p, _, _ in checks})
        tracked = tracked_files()
    except CannotRun as e:
        print(f"check-ledger-coverage: CANNOT RUN — {e}", file=sys.stderr)
        print("  A check that could not run is not a passing check.", file=sys.stderr)
        return 2

    rel = lambda p: os.path.relpath(p, ROOT)
    errs, warns = [], []
    n = lambda src: sum(1 for s, _, _, _ in checks if s == src)
    art = lambda src: ("an " if src[0] in "aeiou" else "a ") + src

    print("check-ledger-coverage: the qualification ledger vs. what actually runs")
    print(f"  derived live from source: {n('backtest gate')} backtest gate(s), "
          f"{n('settings hook')} Claude hook(s), {n('codex hook')} Codex hook(s), "
          f"{n('entry point')} entry point(s)")

    print("\n  DIRECTION 1 — every registered check needs a ledger row")
    for source, path, _, where in checks:
        qualified_path = source == "codex hook"
        # Debt wins over a qualified mention: an explicit 'not yet qualified' row
        # is a stronger statement than any incidental backticked reference.
        if named_by(path, debt, qualified_path):
            status = "visible debt — 'Not yet qualified'"
            warns.append(f"{rel(path)}: relied upon as {art(source)} ('{where}') and never measured")
        elif named_by(path, qualified, qualified_path):
            status = "ledger row"
        else:
            status = "NO LEDGER ROW"
            errs.append(f"{rel(path)}: runs as {art(source)} ('{where}') but the ledger does not "
                        "name it — qualify it, or list it under 'Not yet qualified' as visible debt")
        print(f"    {source:<14} {rel(path):<42} {status}")

    print("\n  DIRECTION 2 — every checker the ledger names must still exist")
    for kind, names in (("row", qualified), ("debt row", debt)):
        for base in sorted(names):
            for tok in sorted(names[base]):
                found = resolve(tok)
                print(f"    {kind:<14} {tok:<42} {'-> ' + rel(found) if found else 'NOT ON DISK'}")
                if not found:
                    errs.append(f"{tok}: named by a ledger {kind} but no such file exists — the "
                                "qualification is recorded for a checker that is gone")

    print("\n  WIRING — a mistyped path here leaves a check wired to nothing")
    for source, path, interp, where in checks:
        if source == "backtest gate":
            continue                      # a dead gate path is loud: backtest.sh fails on it
        r = rel(path)
        if not os.path.isfile(path):
            print(f"    {where:<14} {r:<42} MISSING — never runs")
            errs.append(f"{r}: registered as {art(source)} ('{where}') but no such file exists — "
                        "it is wired to nothing, and the invocation fails in a way nobody reads "
                        "as a config error (interpreted: exit 2, which PreToolUse means as BLOCK; "
                        "bare path: exit 127, non-blocking, guard gone)")
            continue
        notes = []
        if interp:
            if os.access(path, os.R_OK):
                notes.append(f"readable, run by {interp}")
            else:
                notes.append(f"NOT READABLE by {interp}")
                errs.append(f"{r}: invoked via {interp} but is not readable — the invocation exits 2, "
                            "which PreToolUse means as BLOCK, so every matching call is denied by a "
                            "permission error that is really a config typo")
        elif os.access(path, os.X_OK):
            notes.append("executable")
        else:
            notes.append("NOT EXECUTABLE")
            errs.append(f"{r}: invoked directly but is not executable — the invocation exits 126 with "
                        f"a shell error, which does not block anything, so the hook stops guarding "
                        f"while the session looks normal (fix: chmod +x {r})")
        if r in tracked:
            notes.append("tracked")
        else:
            notes.append("UNTRACKED")
            errs.append(f"{r}: not tracked by git — it does not survive a fresh clone, so the check "
                        "is present here and absent for everyone else")
        print(f"    {where:<14} {r:<42} {', '.join(notes)}")

    if warns:
        print(f"\n{len(warns)} VISIBLE DEBT — listed in the ledger, not yet measured:")
        for w in warns:
            print(f"  {w}")
    if errs:
        print(f"\n{len(errs)} COVERAGE FAILURE(S):")
        for e in errs:
            print(f"  {e}")
        print("\nThe ledger and the running checks disagree. An unqualified check's green light "
              "means nothing — see verification-ladder rung 0.")
        return 1

    print(f"\nLedger and running checks agree: {len(checks)} registered check(s) accounted for, "
          "every named checker on disk, every wiring live.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
