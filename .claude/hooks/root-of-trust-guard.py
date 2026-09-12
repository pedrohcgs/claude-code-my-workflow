#!/usr/bin/env python3
"""
Silent-Shell-Write Tripwire for the gate-defining files (PreToolUse, Bash only)

NAMING, STATED UP FRONT. The file is called `root-of-trust-guard.py` and the
path set below is referred to as the "gate-defining files". It is NOT a root of
trust and this hook is NOT a guard in the sense that word usually carries. An
independent referee (2026-08-23) was right about this: a repo-local, mutable,
fail-open textual scan cannot be the thing everything else stands on. What it
actually is:

    a best-effort TRIPWIRE against SILENT shell writes into the files that
    decide whether any other gate runs.

Its whole value is a change of CHANNEL, not a prohibition: a modification to a
gate arrives as a reviewable Edit/Write diff instead of an invisible one-line
overwrite. It does not lock the files, and it cannot.

WHAT CAN REPLACE OR DISABLE IT ANYWAY — all four are ordinary, allowed, and
none of them trips this hook:

    1. an Edit / Write / MultiEdit on these same files (deliberately allowed —
       see below). That includes an edit removing this hook's registration
       from `.claude/settings.json`. The diff is visible AFTERWARDS; under
       `bypassPermissions` nothing authorises it BEFOREHAND.
    2. an ordinary branch transition — `git switch <branch>` / `git checkout
       <branch>` with no pathspec — onto a branch whose tree deletes
       `.claude/hooks/` or carries an older `.claude/settings.json`. There is
       no protected literal path on that command line to test.
    3. a clean merge or pull that imports changes to these files, for the same
       reason.
    4. an error in THIS file. It fails open (see "Decision protocol"), so an
       allowed edit that introduces a syntax error here silently converts the
       tripwire into a no-op.

So read every sentence below as "raises the cost of one silent path", never as
"cannot be disabled".

The template ships `permissions.defaultMode: "bypassPermissions"` with an
empty `deny` list, so the hook layer is the only thing watching the files that
decide whether any other gate runs at all:

    .claude/settings.json        — which hooks fire, and on what
    .claude/settings.local.json  — the same, per machine
    .claude/hooks/               — the gates themselves
    .githooks/                   — the pre-commit gate suite
    .claude/                     — the directory, because deleting it
                                   deletes the hooks

This hook denies SHELL writes into those paths — the silent path, where one
redirection disables the whole suite and nothing surfaces in review until much
later.

SCOPE — THIS PROJECT, not every tree on the machine. A path is protected
only when it matches the pattern above AND resolves inside the project
directory (CLAUDE_PROJECT_DIR, else the git repository the call runs in,
else the repository this file ships in). A fixture clone under /tmp, a
second checkout, and the user's own `~/.claude/settings.json` are other
trees: denying writes there protected none of the gates this repo runs,
while it DID block the qualification ledger's own gate-9 reproduction,
which seeds a mistyped hook path into a fixture clone's settings file. The
deny message names the project directory it is speaking for, so the claim
"this repository's gate-defining files" is checkable rather than asserted. If
no project directory can be resolved at all, the guard falls back to the plain
text match and says so in the message.

Denied, when the target is a protected path:

    - redirection            `> f`, `>> f`, `&> f`, `&>> f`, `>| f`, `>& f` —
                             `&>>` is bash's APPEND-both form and `>&` its
                             csh-style redirect-both, identical in effect to
                             `&> f` whenever f is not a file descriptor. Both
                             are carried by `_TOKEN` and by the `_REDIR`
                             backstop; this list omitted `&>>` until r19, so it
                             under-reported what the regexes already caught.
                             FILE-DESCRIPTOR DUPLICATION is NOT a write and
                             stays allowed: `>&2`, `1>&2`, `2>&1`, `>&-` name a
                             descriptor, not a path
    - tee                    `... | tee f`
    - copy / link            cp, install, rsync, scp, ln (DESTINATION only —
                             copying a hook out is a read)
    - move / delete          mv, rm, unlink, shred (ANY argument — moving a
                             hook away disables it as surely as deleting it)
    - in-place edit          sed -i, perl -i, truncate, dd of=
    - git working-tree write `git rm`, `git checkout [<rev>] -- <path>`,
                             `git restore <path>`, `git clean -f <path>`,
                             `git stash push -- <path>`, `git mv` — git is a
                             writer program too, and these modify or delete the
                             gate-defining files exactly as rm/cp/mv do, with the
                             protected path as a literal argument. Read-only git
                             (status, log, diff, show, ls-files, rev-parse) is
                             untouched; a protected `-C <dir>` counts only when
                             the subcommand is one of the writers above
    - find deleter           find <protected> ... -delete / -exec rm|mv|... —
                             a plain shell deleter of the same class as rm
    - tar extraction         tar -x ... -C <protected> — extraction WRITES
                             files into the destination directory
    - shell wrapper          sh/bash/zsh/dash/ksh -c '<payload>' — the -c
                             payload is UNWRAPPED and re-scanned (depth <= 2),
                             so a redirection or deleter hidden inside it is
                             caught rather than swallowed by the tokenizer. The
                             shell's OWN options are parsed (long options never
                             count as `-c`; `--rcfile`/`--init-file`/`-o` are
                             consumed WITH their values), so a value-taking
                             option cannot make the guard read the wrong word as
                             the payload and skip the real one
    - command wrapper        env / sudo / doas / nice / stdbuf / ionice /
                             timeout / nohup / time / command / exec — the
                             wrapper AND its option arguments (`env -i`,
                             `env -u FOO`, `nice -n 10`, `sudo -u root`,
                             `stdbuf -oL`, `ionice -c2`, `timeout 5`) are
                             consumed so the REAL command behind them — a shell
                             `-c` OR a bare deleter (`nice rm .claude/...`) — is
                             reached and the -c-unwrap / deny logic applies to it
    - env split-string       env -S '<payload>' / env --split-string='<payload>'
                             (the attached `-S<payload>`/`--split-string=` forms,
                             AND the bundled short-flag forms `env -vS`/`env -iS`)
                             make env SPLIT the string into words and EXECUTE
                             them, so it is a command-payload carrier exactly like
                             a shell `-c`. env is located through the SAME
                             wrapper-skip as everything else, so `nice env -S …`
                             / `timeout 5 env -S …` reach it; the payload is then
                             UNWRAPPED and re-scanned (depth <= 2), not skipped as
                             an opaque value

Denied REGARDLESS of any protected path — the cross-hook rule:

    - destructive git inside an UNWRAPPED PAYLOAD. `bash -c 'git reset --hard'`
      and `bash -c 'git clean -fdx'` used to fall between the two hooks and be
      denied by neither: this hook's rules all key off a protected LITERAL path
      and there is none, while `git-guardrails.py` treats a shell-wrapper
      payload as one opaque word. Ordinary execution forms, not evasions. So
      the payload this hook already unwraps for its own path rules (shell `-c`,
      `env -S`, behind the usual wrappers, depth <= 2) is ALSO handed to
      `git-guardrails.py`'s own `git_deny_reason()` — the SHARED destructive-git
      deny list (`reset --hard`, `clean -f`, `push --force`, `add -A`,
      `checkout -- .`, `restore .`), imported rather than copied, so the two
      hooks cannot drift into disagreeing about what is destructive. The
      unwrapped payload is what is re-scanned, so the direct (unwrapped)
      spellings are untouched here and stay `git-guardrails.py`'s to decide —
      no double denial, no second opinion.
      LIMIT, disclosed: only the DENY LIST is shared. The dirty-tree check on
      merge/rebase/pull is NOT applied to wrapped payloads, so
      `bash -c 'git merge main'` on a dirty tree is still seen by neither hook.
      The override for the shared rules stays git-guardrails' own (run it in a
      terminal yourself), not this hook's ALLOW_ROOT_OF_TRUST_WRITE.

Allowed, deliberately:

    - every READ — cat, grep, ls, head, diff, shasum, and running a hook
      (`python3 .claude/hooks/<name>.py`).
    - Edit / Write / MultiEdit on the same files. Those arrive as a diff the
      user can read; a shell one-liner does not. This guard closes the
      silent path, it does not lock the files.

When a command is ambiguous the guard ALLOWS it. A false deny that makes
the repository unusable costs more than the narrow case it would have
caught, so every rule keys off a command that can only be writing.

WHAT THIS TRIPWIRE IS — best-effort defense-in-depth, NOT a proof, and NOT a
control that can stop a change. It is a textual scan, not a sandbox. Its single
claim is about CHANNEL: a shell one-liner that would have overwritten a gate
silently gets denied, so the change has to come back through Edit/Write, where
it lands as a diff. Whether anyone READS that diff is outside this file.

Be precise about what is not here. In the shipped configuration there may be no
protective control elsewhere at all:
  - the reviewable Edit/Write diff is RETROSPECTIVE VISIBILITY, not
    authorisation. It tells you afterwards; it stops nothing.
  - `bypassPermissions` being a deliberate operator posture is a fact about how
    the repo is configured. It is not a control.
  - a machine-wide guard in `~/.claude/hooks/` is OPTIONAL and lives outside
    this repository — present on the maintainer's machine, absent in a fresh
    fork unless the forker installs one.
A real control would have to sit OUTSIDE the worktree — the ordinary permission
system with a non-empty `deny` list, or a machine-level hook — and would have
to cover Edit/Write/MultiEdit and branch transitions too. If you want one, that
is where to put it; this file cannot be it.

`git-guardrails.py` is a sibling of the same kind and carries the same
limitation. Neither hook's audit trail RECOVERS anything: the transcript records
that a loss happened, and `git reflog`/`ORIG_HEAD` recover a moved COMMIT
POINTER — neither holds the bytes of an uncommitted edit, an untracked file, or
an ignored one. `git reset --hard` and `git clean -fdx` destroy exactly those.
Call these an audit trail and a commit-history recovery aid; do not call them a
backstop.

WHAT IT CATCHES: direct writes and deletes (redirection, tee, cp/mv/rm/ln,
sed -i, dd, find -delete, tar -x, and GIT'S OWN working-tree writers —
`git rm/checkout -- /restore/clean/stash push -- /mv`) whose protected-path
target appears as a literal argument, and the two known command-payload
carriers — a shell
`sh/bash/… -c '<payload>'` and `env -S/--split-string`/`-vS` — reached after
the known command wrappers (env/sudo/nice/stdbuf/timeout/…). Both carriers are
unwrapped and re-scanned (depth <= 2). A command formatted across several lines
with BACKSLASH-NEWLINE continuations is spliced before tokenising (r12), so the
multi-line spelling of a write is read as the one command bash will run — it
used to split into two segments and go silent. A protected path spelled with a
shell GLOB or a BRACE GROUP is caught since r15 (`rm -f .claude/hook?/…`,
`.claude/*/…`, `.clau*/hooks/…`, `settings.jso?`, `hook[s]`, `{hooks,rules}`,
`.githook?/…`): the token's BRACE GROUPS are expanded into their alternatives,
and then each path SEGMENT is compared against the protected names with
`fnmatch`. That test is LEXICAL — no `glob`, no `stat`, no filesystem call
anywhere in it (r13 doc fix; `glob` is not even imported) — so the verdict never
depends on what happens to exist when the hook runs, and a pattern that would
expand to nothing here is matched all the same. Before r15 every one of those
spellings was ALLOWED while its literal twin was denied — a one-character edit
flipped the verdict. The csh-style `>&<target>` redirection joined the caught
set at r18, for the same reason and with the same measurement: it is `&>` by
another name, it truncated `.claude/settings.json` in a throwaway fixture while
`&>`/`>`/`>|` all denied, and it was missing from BOTH redirection surfaces —
the tokenizer split it into `>` plus the SEPARATOR `&`, and the backstop's
target class excludes `&`. Descriptor duplication (`>&2`, `1>&2`, `2>&1`, `>&-`)
is excluded from it and stays allowed. ORDINARY QUOTING PLACED INSIDE THE
PROTECTED NAME joined the caught set at r20 — `.clau\de/…`, `.cl'aud'e/…`,
`.cl"aud"e/…`, `.githook\s/…`, and the same split across a line continuation.
The scan half always read these correctly; what silenced them was the literal
substring test in front of it, for the third time (`_may_name_a_protected_path`
has the measurements). The trigger is now taken on the line with `\`, `'` and
`"` deleted as well as as written — those three are the whole set of QUOTING
characters that can sit inside a word without changing which file it names (a
variable or a substitution can too, and both are disclosed as residual below) —
and the
continuation splice was corrected to DELETE the backslash-newline the way the
shell does rather than substitute a space for it.

WHAT IT DOES NOT CATCH — disclosed residual, in scope for a future audit as
BOUNDARY, not as a defect:
  - a write performed by an INTERPRETER whose program text this scan cannot
    read into — `python3 -c '...open(path,"w")...'`, `perl -e`, `node -e`,
    `ruby -e`, an `awk` program. These are execution forms, not command lines
    the tokenizer can see a literal path in.
  - a protected path fed to a deleter through a PIPE — `... | xargs rm`,
    `... | xargs -0 truncate` — where the path never appears as a literal
    argument on a command line this scanner sees.
  - a protected path produced by a COMMAND SUBSTITUTION rather than written as
    a literal — `echo X > $(echo .claude/settings.json)`, and the same write
    spelled with backticks, both measured ALLOWED (silent) on 2026-08-24 in a
    throwaway project fixture while the literal spelling DENIED. The
    substitution's OUTPUT is the path, and this scan reads command TEXT, so the
    token it sees is `$(echo` — a word naming nothing protected. Neither the
    tokenizer path nor the `_REDIR` backstop has a literal to test. This is
    disclosed rather than
    half-built: recursing into a substitution would mean predicting what an
    arbitrary command prints, which is the shell simulation `git-guardrails.py`
    tore out at r8 for making the guard's own complexity the leak. The sibling
    hook already discloses the same class for its history ops.
  - a VARIABLE OR SUBSTITUTION SITTING INSIDE A PROTECTED SEGMENT'S NAME, which
    is a NARROWER residual than `in_project`'s docstring may suggest and is
    disclosed here so the two are not confused. That function says an
    unresolvable token "fails toward DENYING", and it does — for the SCOPE half,
    which is the only half it speaks for. Measured 2026-08-24 in a throwaway
    project fixture: `rm -f $UNSET/.claude/hooks/…` DENIES, exactly as that
    sentence implies, because the segment `.claude` is still there to match.
    But `rm -f .clau${NOPE}de/hooks/…` and `rm -f .clau$(echo d)e/hooks/…` are
    both ALLOWED (silent), because the PATTERN half never sees a protected name
    at all — bash expands `.clau${NOPE}de` to `.claude` (an unset variable
    expands to nothing), while this scan reads the token as written. Position,
    not presence, decides: a variable BEFORE the protected segment leaves the
    segment intact and is caught; one INSIDE it destroys the only thing the
    pattern half matches on. Closing it means expanding variables and running
    substitutions — the shell simulation this pair deliberately refuses.
  - a git write whose target is NOT a literal path operand — `git apply <patch>`
    (the paths live inside the patch), `git reset --hard`, `git merge`,
    `git checkout <branch>` with no pathspec. These rewrite the tree from
    recorded state rather than from a path on this command line, so this scan
    has no literal to test. For the DIRECT spellings `git-guardrails.py` is the
    layer that governs them; for the spellings hidden in a shell/`env -S`
    payload — which git-guardrails treats as one opaque word — the cross-hook
    rule above hands the unwrapped payload to its deny list, and that covers
    the deny list ONLY. Still governed by NEITHER hook, in any spelling: `git
    apply`, and a branch-switching `git checkout`/`git switch` with no
    pathspec — the second is one of the four ways, listed at the top, that the
    gate files get replaced without this hook seeing anything.
  - a write ROUTED THROUGH A SYMLINK whose own name is not protected. The
    pattern half is purely lexical — `_spellings()` walks the token as written
    and the token its `..` segments resolve to LEXICALLY, and neither is the
    path the kernel lands on — so a link named anything else that points at a
    gate-defining directory is invisible to it. Measured 2026-08-24 in a
    throwaway project fixture, with `linkhooks -> .claude/hooks` and
    `linkdot -> .claude`: `rm -f linkhooks/git-guardrails.py`,
    `rm -f linkdot/hooks/git-guardrails.py`, `rm -f .claude/linkin/…` (the link
    inside `.claude` itself) and `echo X > linkdot/settings.json` were all
    ALLOWED (silent), while the literal twin `rm -f .claude/hooks/…` DENIED.
    Only the SCOPE half (`in_project`) resolves anything on disk, and it decides
    which tree a path is in, never whether it is protected. Recorded here as an
    uncovered class at r19; nothing in this file closes it, and the r16 `..`
    walk deliberately does not try to (resolving in place would LOSE denials
    that stand today — see the block above `resolve_parents`).
  - a `cd` EARLIER IN THE SAME COMMAND LINE. Relative tokens resolve against
    the tool call's cwd, not against a `cd` inside the command, so
    `cd /tmp/fixture && printf '{}' > .claude/settings.json` is scored against
    the project — it is DENIED though it writes elsewhere. That is the
    conservative direction (a false deny, remedied by using the absolute path),
    and it is the same residual `git-guardrails.py` discloses for `cd`.
  - a path built from a variable this process cannot expand (`$FIXTURE/.claude/
    settings.json` with FIXTURE unset in the hook's environment). It stays
    relative, resolves against the project, and is denied — again failing
    toward the deny.
  - an UNKNOWN wrapper or execution form not in the WRAPPERS/SHELLS tables, or
    an unlisted wrapper option that takes a SEPARATE value (assumed here to
    attach its value, which skips too LITTLE — a real command word is still
    scanned — rather than too much, so it fails toward catching the write).
    A CASE-VARIED spelling of a LISTED wrapper counts as unknown here: r19
    folded the WRITER-program names and the protected path segments, not the
    scaffolding in front of them. Measured 2026-08-24 on a throwaway project
    fixture, `nice rm -f .claude/hooks/git-guardrails.py` DENIED while
    `NICE rm -f …` and `BASH -c 'rm -f …'` were ALLOWED (silent).
  - a GLOB whose expansion depends on a shell OPTION this scan does not model
    (r15, the residual left by the glob fix). A bare wildcard segment does not
    match a DOT-name because of an EXPLICIT rule in `_segment_matches` — a
    segment carrying no literal character of its own (`*`, `?`, `[a-z]*`) is
    refused against `.claude`/`.githooks` — not because of any `glob` module
    semantic, since nothing here expands anything. That rule mirrors bash
    WITHOUT `dotglob`, so with `dotglob` actually set `rm -rf *` really would
    take `.claude` with it and is allowed here; and the rule is load-bearing —
    delete it as "redundant" and every `rm -f build/*` starts being denied.
    `extglob` forms (`@(a|b)`, `!(x)`, `+(…)`) are not modelled either. What
    the fix does close is the ordinary case: a glob whose literal characters
    already name a protected segment is denied whether or not anything matching
    it exists. (Expanding for REAL — `glob.glob` against the event's cwd — was
    implemented first and DROPPED: it made the verdict depend on what happened
    to exist at hook time, could not see the not-yet-created
    `> .claude/settings.jso?` case, added filesystem work to every command
    carrying a `*`, and handed a pathological pattern like `/*/*/*/*` a way to
    stall the hook. The inline note above `_segment_matches` keeps the full
    reasoning. The cwd residual is real but belongs to PATH RESOLUTION, not to
    globbing — it is the `cd` bullet above.)
  - ANY SPELLING THAT PUTS A PROTECTED PATH SOMEWHERE THIS SCAN DOES NOT LOOK.
    The bullets above are the set known on 2026-08-24. They record where this
    scanner has been PROBED; they do not establish where it is complete, and
    reading the list as a closed enumeration is the mistake. Six consecutive
    rounds each turned up a spelling every earlier round had missed — globs
    (r15), `..` segments (r16), a shell COMMENT naming a heredoc (r17), `>&`
    (r18), the `$'…'` openers and case (r19), quoting inside the protected NAME
    itself (r20) — and every one of them
    failed toward ALLOW while its literal twin denied. Those are closed; the
    CLASS is not. Assume there are more, and that the next one also looks
    ordinary.
These are not closed, and nothing here closes them. The honest statement is that
they are UNCOVERED: the Edit/Write channel makes some of them visible after the
fact, which is not the same as covering them.

Decision protocol (modern PreToolUse): exit 0 + JSON
  {"hookSpecificOutput": {"hookEventName": "PreToolUse",
    "permissionDecision": "deny", "permissionDecisionReason": "..."}}.
Fail-open: any error — malformed event, unparseable command, an exception
in this file — exits 0 with no decision (allow). A guard that hard-fails on
its own bug takes the session down with it; failing open loses coverage for
that one call, which is the cheaper failure for a best-effort deny.

Escape hatch: set ALLOW_ROOT_OF_TRUST_WRITE=1 in the ENVIRONMENT OF THE
SESSION (`ALLOW_ROOT_OF_TRUST_WRITE=1 claude`, or export it in the shell
that launches Claude Code). Prefixing the blocked Bash command with it does
not work and is not meant to: hooks run as separate processes, so the hatch
has to be a deliberate act of the person starting the session.
"""

from __future__ import annotations

import fnmatch
import json
import os
import re
import sys

# --- protected paths -------------------------------------------------------

# Children of `.claude/` that are gate-defining. Everything else under
# `.claude/` (rules, skills, references, agents) is ordinary content.
PROTECTED_UNDER_CLAUDE = {"settings.json", "settings.local.json", "hooks"}

_SLASHES = re.compile(r"/{2,}")


def normalize(path: str) -> str:
    """Collapse separator noise so `.claude//hooks` and `.claude/./hooks`
    match the same rule as `.claude/hooks`.

    r19 — CASE IS FOLDED, and this docstring used to say the opposite
    ("Case-sensitive by design"), which was false the moment the repository sat
    on a case-insensitive filesystem. It does: APFS is the macOS default (HFS+
    before it), so `.CLAUDE/settings.json` and `.claude/settings.json` are ONE
    file. Measured 2026-08-24 against the shipped guard on a throwaway project
    fixture, `echo X > .CLAUDE/settings.json` was ALLOWED (silent) while its
    lowercase twin DENIED. The comparison itself lives in `_segment_matches`;
    this function only collapses separators. The fold is UNCONDITIONAL — no
    probe of the filesystem — by the same ruling the r15 glob fix made: the
    verdict must not depend on what happens to exist at hook time. Its cost is a
    false DENY on a case-SENSITIVE filesystem for a directory literally spelled
    `.CLAUDE` that is not the root of trust. That is the direction this guard
    errs in on purpose."""
    p = _SLASHES.sub("/", path)
    while "/./" in p:
        p = p.replace("/./", "/")
    while p.startswith("./"):
        p = p[2:]
    return p


# --- PARENT-DIRECTORY (`..`) SEGMENTS (r16) --------------------------------
#
# `normalize()` collapsed `//` and `/./` but NOT `/../`, and the segment walk
# below then read the segments AS WRITTEN. So an ordinary relative path that
# climbs back into a protected directory through an UNPROTECTED sibling was not
# recognised, while the shell resolved it to exactly the gate-defining file.
# Measured at 7b8848d, event cwd = the project, guard verdict vs. what the
# shell really does:
#
#     rm -f .claude/rules/../hooks/git-guardrails.py   SILENT -> file deleted
#     echo x > .claude/rules/../settings.json          SILENT -> file rewritten
#     rm -f .claude/agents/../settings.local.json      SILENT
#
# while the literal twins of all three DENIED. `..` was on NEITHER disclosed-
# residual list, and like the r15 glob class it failed toward ALLOW. Any real
# unprotected child of `.claude/` works as the pivot (rules, agents, skills,
# references, state); `.claude/../.claude/hooks/x` already denied, because
# there a second protected segment survives literally.
#
# RESOLUTION IS PURELY LEXICAL — no filesystem call, by the same choice the
# glob comment above records: the verdict must not depend on what happens to
# exist at hook time, and `> .claude/rules/../settings.jso?` names a file that
# need not exist yet. `in_project()` is the one half that touches disk, and it
# already realpaths the token, so the SCOPE half needs no change.
#
# BOTH SPELLINGS ARE TESTED, the token as written and the token `..` resolves
# it to (`_spellings`). Resolving in place would be strictly weaker: lexical
# and kernel resolution DIVERGE when a segment is a symlink (the kernel's `..`
# is the physical parent of the link TARGET), so a token that literally names
# `.claude/hooks` must keep being judged as naming it. The union can only add
# denials, never remove one that stands today.
def resolve_parents(path: str) -> str:
    """Resolve `..` segments LEXICALLY, the way the shell prints a path.

    A `..` pops the segment before it (`.claude/rules/..` -> `.claude`). Two
    edge cases decide the rest:

      * a LEADING `..`, or one that would climb above the start of a RELATIVE
        token, has nothing to pop and is KEPT (`../.claude/hooks/x` stays
        `../.claude/hooks/x`, which still names the protected directory);
        under an ABSOLUTE token it is dropped, because POSIX defines `/..`
        as `/`.
      * a TRAILING `..` is an ordinary pop (`.claude/hooks/..` -> `.claude`,
        which the walk below still recognises as the directory itself).
    """
    lead = "/" if path.startswith("/") else ""
    out: list[str] = []
    for seg in path.split("/"):
        if seg in ("", "."):
            continue
        if seg != "..":
            out.append(seg)
        elif out and out[-1] != "..":
            out.pop()
        elif not lead:
            out.append("..")     # climbs above the base: keep it as written
    return lead + "/".join(out)


def _spellings(path: str) -> list[str]:
    """The path with separator noise collapsed, plus — when they differ — the
    path its `..` segments resolve to. Both are walked; see the block above."""
    written = normalize(path)
    landed = resolve_parents(written)
    return [written] if landed == written else [written, landed]


# --- shell GLOBS and BRACE GROUPS (r15) ------------------------------------
#
# Until r15 the segment test below was a LITERAL string comparison, so one
# ordinary metacharacter took a protected path out of the guard's sight while
# the shell expanded it to exactly the protected file. Measured at 7eee6b2,
# event cwd = the project, guard verdict vs. what the shell expands to:
#
#     rm -f .claude/hook?/git-guardrails.py   ALLOW -> .claude/hooks/git-guardrails.py
#     rm -f .claude/*/git-guardrails.py       ALLOW -> .claude/hooks/git-guardrails.py
#     rm -f .clau*/hooks/git-guardrails.py    ALLOW -> .claude/hooks/git-guardrails.py
#     echo x > .claude/settings.jso?          ALLOW -> .claude/settings.json
#     rm -rf .claude/hook[s]                  ALLOW
#     rm -f .claude/{hooks,rules}/…           ALLOW -> .claude/hooks/…
#     rm -f .githook?/pre-commit              ALLOW -> .githooks/pre-commit
#
# while the literal spellings of all three targets DENIED. Globbing was on
# NEITHER disclosed-residual list, and unlike every item that is on them it
# failed toward ALLOW. Tab completion and shorthand globs are how people spell
# paths; this was ordinary usage, not an evasion.
#
# THE TEST IS TEXTUAL, not a real expansion, and that is a choice: a segment
# matches a protected NAME when `fnmatch` says the shell's expansion could
# produce it. Expanding for real (`glob.glob` against the event cwd) was tried
# first and buys nothing this does not — see the dotfile rule below — while it
# would make the verdict depend on what happens to exist at hook time, add
# filesystem work to every command carrying a `*`, and hand a pathological
# pattern (`/*/*/*/*`) a way to stall the hook. Text also covers the file that
# does not exist YET, which is exactly the `> .claude/settings.jso?` case.
#
# THE DOTFILE RULE is what keeps this from denying everything. A bare wildcard
# segment (`*`, `?`, `[a-z]*` — no literal character of its own) fnmatches
# every name, so without a rule `rm -f build/*` would be DENIED. It must not
# be: bash without `dotglob`, and Python's glob likewise, never expand a bare
# wildcard to a DOTFILE, so `*` cannot become `.claude` or `.githooks`. So a
# segment must carry a literal character to match a DOT-name, while against
# the ordinary names under `.claude/` (`hooks`, `settings.json`,
# `settings.local.json`) a bare wildcard matches — because there it really
# does expand: `rm -rf .claude/*` deletes the hooks. `dotglob` being set is
# the residual, disclosed in the docstring.
_GLOB_META = re.compile(r"[*?\[]")
_BRACE_LIMIT = 64          # bound the expansion of nested/ganged brace groups


def _brace_expand(token: str) -> list[str]:
    """Expand shell BRACE GROUPS: `.claude/{hooks,rules}/x` -> two tokens.
    Braces are not globs — the shell emits every alternative whether or not it
    exists — so each alternative is judged as its own literal token."""
    out = [token]
    for _ in range(8):                                   # bounded nesting
        nxt: list[str] = []
        changed = False
        for t in out:
            i = t.find("{")
            j = t.find("}", i + 1) if i != -1 else -1
            if i == -1 or j == -1 or "," not in t[i + 1:j]:
                nxt.append(t)
                continue
            changed = True
            head, body, tail = t[:i], t[i + 1:j], t[j + 1:]
            for alt in body.split(","):
                nxt.append(head + alt + tail)
        out = nxt[:_BRACE_LIMIT]
        if not changed:
            break
    return out


def _glob_literal(seg: str) -> str:
    """The characters of a segment that a glob CANNOT vary — metacharacters and
    whole `[...]` classes removed. `hook?` -> `hook`, `.clau*` -> `.clau`,
    `hook[s]` -> `hook`, `*` -> `` (nothing literal at all)."""
    out: list[str] = []
    i, n = 0, len(seg)
    while i < n:
        c = seg[i]
        if c == "[":
            j = seg.find("]", i + 1)
            i = n if j == -1 else j + 1
            continue
        if c in "*?":
            i += 1
            continue
        out.append(c)
        i += 1
    return "".join(out)


def _segment_matches(seg: str, name: str) -> bool:
    """Does this path SEGMENT spell a protected NAME — literally, or as a glob
    the shell could expand to it? A segment with no literal character of its
    own matches only a NON-dot name: see the dotfile rule above.

    r19 — THE COMPARISON IS CASE-INSENSITIVE, UNCONDITIONALLY. See `normalize`
    for the measurement and for why the fold is not conditioned on a filesystem
    probe. `fnmatchcase` is kept rather than `fnmatch` (which would defer to
    `os.path.normcase`, an identity function on POSIX): both sides are lowered
    here, so the fold is this file's own rule and not the platform's."""
    seg_l, name_l = seg.lower(), name.lower()
    if seg_l == name_l:
        return True
    if not _GLOB_META.search(seg):
        return False
    if name_l.startswith(".") and not _glob_literal(seg_l):
        return False
    try:
        return fnmatch.fnmatchcase(name_l, seg_l)
    except Exception:
        return False


def _matches_one(path: str) -> bool:
    for spelling in _spellings(path):
        segs = [s for s in spelling.split("/") if s not in ("", ".")]
        for i, s in enumerate(segs):
            if _segment_matches(s, ".githooks"):
                return True
            if _segment_matches(s, ".claude"):
                if i + 1 == len(segs):
                    return True  # the directory itself
                if any(_segment_matches(segs[i + 1], n) for n in PROTECTED_UNDER_CLAUDE):
                    return True
    return False


def matches_root_of_trust(token: str) -> bool:
    """PATTERN half: does this token spell a gate-defining path at all?
    Says nothing about WHICH tree it is in — see in_project()."""
    return any(_matches_one(alt) for alt in _brace_expand(normalize(token)))


# --- project scope ---------------------------------------------------------
#
# The pattern above is a TEXT match, so on its own it protects `.claude/hooks`
# in every tree on the machine: a throwaway fixture clone under /tmp, a second
# checkout, the user's own ~/.claude. That bought this repository nothing (the
# gates it defends live HERE) and cost real work — it denied the qualification
# ledger's own gate-9 reproduction, which seeds a mistyped hook path into a
# fixture clone's `.claude/settings.json`, and it contradicted the deny message,
# which asserts the path is one of this repository's gate-defining files.
#
# So a token is protected only when it RESOLVES INSIDE the project directory.
# Precedence: CLAUDE_PROJECT_DIR (what Claude Code sets for hooks) → the git
# repository the call is running in → the repository this hook file ships in.
# If none of those resolves, the scope is unknown and the guard falls back to
# the old text match, which loses no coverage it used to have.

_PROJECT: str | None = None   # resolved project root, or None = unknown
_CWD: str = ""                # the cwd relative tokens resolve against


def _real(p: str) -> str:
    try:
        return os.path.realpath(p)
    except OSError:
        return os.path.abspath(p)


def _git_root(start: str) -> str | None:
    """Nearest ancestor of `start` that contains a `.git` entry."""
    if not start:
        return None
    cur = _real(start)
    while True:
        if os.path.exists(os.path.join(cur, ".git")):
            return cur
        parent = os.path.dirname(cur)
        if parent == cur:
            return None
        cur = parent


def configure_scope(event_cwd: str = "") -> None:
    """Resolve the project root and the cwd relative tokens resolve against.
    Called once per event, before any scan."""
    global _PROJECT, _CWD
    # A cwd that does not exist tells us nothing, and trusting it would resolve
    # every relative token to a directory outside every project — i.e. silently
    # disarm the guard. Fall back to the hook process's own cwd instead.
    try:
        usable = bool(event_cwd) and os.path.isdir(event_cwd)
        _CWD = _real(event_cwd) if usable else _real(os.getcwd())
    except OSError:
        _CWD = ""
    env = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if env and os.path.isdir(env):
        _PROJECT = _real(env)
        return
    _PROJECT = (_git_root(_CWD)
                or _git_root(os.path.dirname(os.path.abspath(__file__))))


def in_project(token: str) -> bool:
    """SCOPE half: does this token resolve inside the project directory?

    Relative tokens resolve against the TOOL CALL's cwd (the event's `cwd`),
    falling back to the hook process's cwd and then the project root. `~` and
    `$VAR` are expanded, so `$HOME/.claude/settings.json` is recognised as the
    user's own config rather than read as a relative path. A token that still
    cannot be resolved to an absolute path is treated as project-relative,
    which fails toward DENYING — the safe direction for this guard.
    """
    if _PROJECT is None:
        return True  # scope unknown: keep the pre-scoping behaviour
    t = os.path.expandvars(os.path.expanduser(token.strip()))
    if not t:
        return False
    if not os.path.isabs(t):
        t = os.path.join(_CWD or _PROJECT, t)
    t = _real(t)
    return t == _PROJECT or t.startswith(_PROJECT + os.sep)


def is_protected(token: str) -> bool:
    """A path this hook defends: the gate-defining PATTERN, inside THIS
    project. Both halves must hold.

    r15: the PATTERN half now reads a glob or brace group the way the shell
    would (see `_segment_matches`). The SCOPE half is unchanged and still
    decides on the token as written, so a glob aimed at another tree stays
    allowed exactly as its literal spelling is (the r11 scope rule)."""
    return matches_root_of_trust(token) and in_project(token)


# --- command shape ---------------------------------------------------------

# r18: `\d?>&` IS AN OPERATOR. It was absent from this alternation, so bash's
# csh-style `>&<word>` — which redirects stdout AND stderr to <word> exactly
# like `&><word>` whenever <word> is not a file descriptor — tokenised as `>`
# followed by `&`. `&` is a SEPARATOR, so the segment ENDED there and the write
# target became a bare word at the head of the NEXT segment, out of reach of the
# `idx + 1` lookahead in `scan_segment`. Measured at e0c4cdb, event cwd = the
# project, guard verdict vs. what bash really does:
#
#     echo CLOBBERED >& .claude/settings.json        ALLOW -> file is 'CLOBBERED'
#     echo CLOBBERED >&.claude/settings.json         ALLOW -> file is 'CLOBBERED'
#     echo CLOBBERED >& .claude/hooks/git-guardrails.py  ALLOW -> guard overwritten
#
# while `&>`, `>` and `>|` all DENIED the byte-equivalent write. Same class as
# the r15 glob defect: one character took a protected path out of the guard's
# sight while the shell wrote to exactly that file.
#
# FILE-DESCRIPTOR DUPLICATION IS NOT A WRITE. `>&2`, `1>&2`, `2>&1`, `>&-` name
# a descriptor, not a path; `_is_fd_dup_target` excludes them below so the fix
# does not start denying the most ordinary redirection in any shell script.
_TOKEN = re.compile(
    r"""(?P<op>&>>|&>|\d?>&|>\||\d?>>|\d?>|<<-?|<|\|\||\||&&|;|&|\n)
      | (?P<word>(?:"[^"]*"|'[^']*'|\\.|[^\s"'|;&<>\n])+)""",
    re.VERBOSE,
)

SEPARATORS = {"||", "|", "&&", ";", "&", "\n"}

# The word after a `>&` that means a FILE DESCRIPTOR rather than a file: a bare
# descriptor number (`>&2`, `2>&1`), the same with bash's move suffix (`2>&1-`),
# or `-` to close it. Anything else is a path bash truncates.
_FD_DUP_TARGET = re.compile(r"^(?:\d+-?|-)$")


def _is_fd_dup_target(tok: str) -> bool:
    """Does this `>&` target duplicate a descriptor instead of writing a file?"""
    return bool(_FD_DUP_TARGET.match(tok))


# Env-var prefixes (`FOO=bar cmd`) and wrappers that delegate to a real command.
_ASSIGN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
WRAPPERS = {"sudo", "doas", "env", "command", "builtin", "exec",
            "nohup", "time", "nice", "stdbuf", "xargs", "timeout", "ionice"}

# Per-wrapper short/long options that consume a SEPARATE following value
# (`nice -n 10`, `sudo -u root`, `env -u FOO`, `stdbuf -o L`). An option that
# ATTACHES its value (`-oL`, `--chdir=/x`, `-n10`) is a single token and is
# consumed as an ordinary flag; only these exact tokens also eat the next word.
# `env`'s `-S`/`--split-string` is listed here so skip_wrappers still lands on
# any trailing real command word, but its VALUE is NOT opaque: it is a command
# line env splits and executes, re-scanned separately by env_split_payload().
_WRAPPER_ARG_OPTS = {
    "env":     {"-u", "--unset", "-C", "--chdir", "-S", "--split-string", "-P"},
    "nice":    {"-n", "--adjustment"},
    "sudo":    {"-u", "--user", "-g", "--group", "-C", "--close-from",
                "-h", "--host", "-p", "--prompt", "-r", "--role", "-t", "--type",
                "-U", "--other-user", "-R", "--chroot", "-D", "--chdir"},
    "doas":    {"-u", "-C"},
    "timeout": {"-s", "--signal", "-k", "--kill-after"},
    "stdbuf":  {"-i", "--input", "-o", "--output", "-e", "--error"},
    "ionice":  {"-c", "--class", "-n", "--classdata", "-p", "--pid"},
    "xargs":   {"-n", "--max-args", "-P", "--max-procs", "-I", "-i", "--replace",
                "-s", "--max-chars", "-d", "--delimiter", "-E", "-e", "--eof",
                "-L", "--max-lines", "-a", "--arg-file"},
}

# Wrappers that take a bare POSITIONAL argument before the real command
# (`timeout 5 rm x` — DURATION is a positional, not a flag). We skip at most
# this many leading non-option positionals so the loop reaches the command.
_WRAPPER_POSITIONAL = {"timeout": 1}

# Shells whose `-c '<payload>'` argument is a command line in its own right.
# The payload is unwrapped and re-scanned so a write hidden inside it is not
# swallowed as one opaque quoted word.
SHELLS = {"sh", "bash", "zsh", "dash", "ksh"}

DEST_LAST = {"cp", "install", "rsync", "scp", "ln"}     # last non-flag arg
ANY_ARG = {"mv", "rm", "unlink", "shred", "tee", "truncate"}
INPLACE = {"sed", "gsed", "perl", "ruby"}               # only with -i

# GIT'S OWN WORKING-TREE WRITERS. git is a writer program too, and the tables
# above never named it — so `git rm .claude/hooks/x`, `git checkout HEAD~1 --
# .claude/settings.json`, `git restore .claude/settings.json`, `git clean -fd
# .claude/hooks`, `git stash push -- .claude/hooks/x` and `git mv` all
# overwrote or deleted a gate-defining file through a plain shell one-liner while
# the semantically identical `cp`/`rm` spelling was denied. These are NOT part
# of the disclosed residual below: the command word is known, the protected path
# is a LITERAL argument, and the write is direct and unambiguous — exactly the
# class this guard claims to catch.
#
# ONLY these subcommands count as writers. Read-only git — status, log, diff,
# show, ls-files, rev-parse, cat-file, blame — is deliberately untouched, so a
# session can still inspect the gate-defining files freely.
GIT_WRITE_SUBS = {"rm", "checkout", "restore", "clean", "stash", "mv"}

# git GLOBAL options that sit between `git` and the subcommand and take a
# SEPARATE value; without consuming the value, `git -C <dir> checkout` would be
# read as the subcommand `<dir>` and the writer missed.
_GIT_GLOBAL_ARG_OPTS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace",
                        "--exec-path", "--super-prefix"}

# `git stash push -m <msg>`: the value is a MESSAGE, never a pathspec, so it
# must not be read as a path operand.
_GIT_STASH_MSG_OPTS = {"-m", "--message"}

_SHORT_INPLACE = re.compile(r"^-[A-Za-z]*i")
_TARGET_DIR = re.compile(r"^--target-directory=(.+)$")


# ANSI-C QUOTING (`$'…'`) AND LOCALE TRANSLATION (`$"…"`) — r19.
#
# The unquoting walk handled `'…'`, `"…"` and backslash escapes, and nothing
# else. Bash has two more quote openers, and both put a `$` IMMEDIATELY in
# front of the quote: `$'…'` (ANSI-C, escapes decoded) and `$"…"` (locale
# translation, which with no message catalogue is the double-quoted string
# itself). The `$` fell through to the walk's ordinary-character branch, so it
# SURVIVED into the unquoted word: `$'--hard'` unquoted to `$--hard`, which is
# not `--hard`, and every whole-word comparison downstream missed. Bash
# executes the byte-identical bare spelling.
#
# Measured 2026-08-24 against the shipped hooks with synthetic PreToolUse
# events, in a throwaway fixture repository whose porcelain read ' M f.txt' and
# a throwaway project fixture holding `.claude/settings.json` and
# `.claude/hooks/`:
#
#   git reset --hard HEAD                      DENY   (control)
#   git reset $'--hard' HEAD                   ALLOW (silent)
#   git $'merge' other                         ALLOW (silent)  <- the clean-tree
#   git clean $'-fd'                           ALLOW (silent)      check too
#   git reset $"--hard" HEAD                   ALLOW (silent)
#   echo X > .claude/settings.json             DENY   (control)
#   echo X > $'.claude/settings.json'          ALLOW (silent)
#   echo X > $".claude/settings.json"          ALLOW (silent)
#   rm -f $'.claude/hooks/git-guardrails.py'   ALLOW (silent)
#
# Like the r10 quoting hole this is ORDINARY SHELL, not an evasion, and it
# silenced the deny list and the clean-tree precondition at once.
#
# THE RULE: a `$` immediately before a quote opener is QUOTING SYNTAX, not part
# of the word. `$'…'` additionally has its ANSI-C escapes decoded, because bash
# decodes them before the word ever reaches the command — `$'\x2d\x2dhard'` IS
# `--hard` to git, and a guard that compares whole words has to see the same
# word. An escape this decoder does NOT recognise keeps BOTH its characters,
# exactly as bash does for an unrecognised escape: dropping the backslash would
# invent a DIFFERENT word, and a word the guard invented is a word that matches
# nothing.
#
# Disclosed residual, stated as the possibility it is rather than as a measured
# hole: the TOKENIZERS still read `'…'` as a span ending at the next `'`, while
# inside `$'…'` a `\'` is an ESCAPED quote that does not end the span, so a
# `$'…\'…'` spelling could be split into words differently from bash. The
# unquoting below is escape-aware; the tokenizer is not. No spelling in this
# class has been shown to reach a false ALLOW — the one probed on 2026-08-24
# still DENIED — so this is a known divergence, not a demonstrated bypass.
#
# THIS BLOCK AND THE FUNCTION BELOW ARE DUPLICATED VERBATIM IN
# `git-guardrails.py` (its copy names the function `_unquote`), for the same
# reason the heredoc walker is: this hook's import of that one is best-effort
# and returns None on any failure, and a parser that silently stops running is
# exactly what this defect was.
_ANSI_C_SIMPLE = {"a": "\a", "b": "\b", "e": "\x1b", "E": "\x1b", "f": "\f",
                  "n": "\n", "r": "\r", "t": "\t", "v": "\v",
                  "\\": "\\", "'": "'", '"': '"', "?": "?"}
_ANSI_C_HEX = {"x": 2, "u": 4, "U": 8}
_HEXDIGITS = "0123456789abcdefABCDEF"


def _ansi_c(body: str) -> str:
    """Decode the ANSI-C escapes bash processes inside `$'…'`.

    An UNRECOGNISED escape keeps its backslash AND its character, which is what
    bash does with one — the failure direction matters here, because a word this
    function invents matches no rule at all."""
    out, i, n = [], 0, len(body)
    while i < n:
        c = body[i]
        if c != "\\" or i + 1 >= n:
            out.append(c); i += 1; continue
        e = body[i + 1]
        if e in _ANSI_C_SIMPLE:
            out.append(_ANSI_C_SIMPLE[e]); i += 2; continue
        if e in _ANSI_C_HEX:                        # \xHH \uHHHH \UHHHHHHHH
            j, stop = i + 2, i + 2 + _ANSI_C_HEX[e]
            while j < n and j < stop and body[j] in _HEXDIGITS:
                j += 1
            if j > i + 2:
                try:
                    out.append(chr(int(body[i + 2:j], 16))); i = j; continue
                except (ValueError, OverflowError):
                    pass
            out.append(c); out.append(e); i += 2; continue
        if e in "01234567":                         # \nnn, up to three octal
            j = i + 1
            while j < n and j < i + 4 and body[j] in "01234567":
                j += 1
            try:
                out.append(chr(int(body[i + 1:j], 8) & 0xFF)); i = j; continue
            except (ValueError, OverflowError):
                pass
        if e == "c" and i + 2 < n:                  # \cX — a control character
            x = body[i + 2]
            if x.isalpha() and x.isascii():
                out.append(chr(ord(x.upper()) ^ 0x40)); i += 3; continue
        out.append(c); out.append(e); i += 2        # unrecognised: keep both
    return "".join(out)


def unquote(w: str) -> str:
    out, i = [], 0
    while i < len(w):
        c = w[i]
        if c == "$" and i + 1 < len(w) and w[i + 1] in "\"'":
            q = w[i + 1]                    # `$'…'` / `$"…"`: `$` is SYNTAX
            if q == "'":
                j, esc = i + 2, False       # inside `$'…'` a `\'` does not close
                while j < len(w):
                    if esc:
                        esc = False
                    elif w[j] == "\\":
                        esc = True
                    elif w[j] == "'":
                        break
                    j += 1
                if j >= len(w):
                    out.append(_ansi_c(w[i + 2:])); break
                out.append(_ansi_c(w[i + 2:j])); i = j + 1
                continue
            j = w.find(q, i + 2)
            if j == -1:
                out.append(w[i + 2:]); break
            out.append(w[i + 2:j]); i = j + 1
        elif c in "\"'":
            j = w.find(c, i + 1)
            if j == -1:
                out.append(w[i + 1:]); break
            out.append(w[i + 1:j]); i = j + 1
        elif c == "\\" and i + 1 < len(w):
            out.append(w[i + 1]); i += 2
        else:
            out.append(c); i += 1
    return "".join(out)


# A backslash-newline is a LINE CONTINUATION in POSIX shell: it JOINS the line,
# it does not end the command. `_TOKEN` lists `\n` in its separator alternation
# while its word alternation's escape class (`\\.`) cannot match backslash +
# newline — `.` excludes newline outside DOTALL — so a trailing `\` was consumed
# as an ordinary word character and the newline behind it ENDED the segment.
# Executed against the pre-fix guard (r11): `rm -f \` + newline +
# `    .claude/hooks/git-guardrails.py` emitted no decision, and the same string
# through `bash -c` really deleted the guard file, while the byte-equivalent
# one-line spelling DENIED. Protection depended on where the author had put a
# newline — ordinary multi-line formatting, not an evasion. So the continuation
# is spliced the way the shell splices it, BEFORE anything is tokenised.
#
# The RUN of backslashes is what decides. `\\` is an ESCAPED backslash, so
# `\\` + newline is a literal backslash followed by a REAL separator, not a
# continuation. The even-run prefix is consumed first and re-emitted, so only an
# ODD trailing backslash joins; a naive `\\\n -> " "` substitution would splice
# the NEXT command onto this one and could false-deny. A newline with no
# backslash in front of it is untouched and still separates commands, and a
# backslash NOT followed by a newline (a literal `\` inside a quoted string) is
# never matched at all.
#
# r20 — THE SPLICE INSERTED A SPACE, AND THE SHELL DOES NOT. POSIX is explicit:
# "the <backslash> and <newline> shall be removed before splitting the input
# into tokens" — REMOVED, not replaced. The r11 repair substituted `" "`, which
# is indistinguishable from removal at a token BOUNDARY (its own measured case
# had whitespace on both sides) and wrong INSIDE a word: it split one word bash
# keeps whole, so the halves were scored separately and matched nothing.
# Measured 2026-08-24 at 727a66c, event cwd = the project:
#
#     rm -f .claude/hooks/git-guardrails.py    DENY   (literal control)
#     rm -f .clau\ + newline + de/hooks/…      ALLOW (silent)
#
# while `printf '%s\n'` on the same string prints ONE word,
# `.claude/hooks/git-guardrails.py`. Same class as the fast-path defect above —
# a backslash inside the protected directory name — and the same failure
# direction, so it is closed with it rather than disclosed. The substitution
# now emits the even-backslash prefix and NOTHING else.
_LINE_CONT = re.compile(r"(?<!\\)((?:\\\\)*)\\\n")


def join_continuations(cmd: str) -> str:
    """Splice POSIX line continuations, so a command formatted across several
    lines is tokenised as the ONE command bash will actually run.

    The backslash-newline is DELETED, which is what the shell does with it; a
    continuation inside a word therefore joins the word rather than splitting
    it. Whitespace that was already there is untouched, so the token-boundary
    spelling this function was written for (r11: `rm -f \\` + newline +
    `    <path>`) still tokenises exactly as before — the leading spaces of the
    continued line are what separate the words, and always were."""
    return _LINE_CONT.sub(r"\1", cmd)


# THE OPENER SCAN IS QUOTE-AWARE AND HERESTRING-AWARE (r16). It used to be one
# quote-blind regex — `<<-?\s*(['"]?)([A-Za-z_][A-Za-z0-9_]*)\1` — run over RAW
# line text with `finditer`. Two ordinary spellings therefore opened a heredoc
# that bash never opens, and every line after them (to the end of the command,
# or to a line spelling the invented terminator) was DELETED before anything was
# tokenised:
#
#   * a HERESTRING. To that regex `tr a-z A-Z <<< hello` is `<<` + `\s*` +
#     `hello`, so `hello` became the terminator.
#   * a `<<WORD` inside a QUOTED STRING. `echo '<<EOF'` and
#     `echo "docs: use <<EOF"` are prose bash merely prints; both opened one.
#
# Measured at 7b8848d against throwaway fixture trees, line 2 of a two-line
# command carrying the real op: after `tr a-z A-Z <<< hello` this guard went
# SILENT on `rm -f .claude/hooks/git-guardrails.py` and on
# `echo x > .claude/settings.json`, and the sibling hook went SILENT on
# `git reset --hard HEAD~1`, `git clean -fd`, `git push --force origin main`,
# `git add -A` and a dirty-tree `git merge` — every one of which DENIES when
# line 1 is `echo hi`, and bash runs line 2 in all of them. Dropping REAL
# command text is a missed deny, the one direction a guard must not fail in,
# and this took the whole deny spine of both hooks with it.
#
# So the line is WALKED, not pattern-matched: quote state is tracked (and
# carried ACROSS lines, because a shell string may span them), `<<<` is consumed
# whole so it can never be read as a `<<`, and a delimiter is taken only from an
# opener found OUTSIDE quotes. An UNBALANCED quote leaves the rest of the
# command in quote state, so no opener is found and NO text is dropped — that
# fails toward scanning more, which is the safe direction here.
#
# r17 — THE WALK IS ALSO COMMENT-AWARE, and the r16 fix above is what made that
# necessary: it modelled quoting and herestrings but gave the scan NO notion of
# a shell COMMENT, while `strip_heredocs` runs BEFORE the comment-aware
# segmenting the sibling hook performs on the same text. So an ORDINARY `#`
# comment that merely NAMES a heredoc opened one, and every following line was
# DELETED before anything was tokenised. This class was INTRODUCED by r16: its
# disclosed residual named exactly one surviving opener misread (the arithmetic
# shift below), and this was a second one, one character away from the quoted
# spelling r16 had just closed.
#
# Measured 2026-08-23 against throwaway fixtures (a project fixture holding
# `.claude/hooks/` and `.claude/settings.json`; a git fixture with one modified
# tracked file), line 2 carrying the real op. With line 1 =
# `# heredoc <<EOF` this guard went SILENT on
# `rm -f .claude/hooks/git-guardrails.py` and on a redirect into
# `.claude/settings.json`, and the sibling hook went SILENT on
# `git reset --hard HEAD~1`, a destructive `clean -fdx`, a force push,
# `git add -A` and a dirty-tree `git merge main`. With line 1 = an ordinary
# comment carrying no `<<`, every one of them DENIED. Executed, not simulated:
# `bash -c` on the two-line form left the guard file absent, so bash runs line 2
# while the hook writes nothing — and a hook that writes nothing is what an
# allow looks like.
#
# THE RULE: an unquoted `#` that BEGINS a word — start of line, or preceded by
# whitespace or one of `;&|()` — ends the line for opener purposes. That is the
# same test the sibling's `_segments` applies to raw words, so the two parsers
# stop disagreeing about what a comment is; the separator set here is
# deliberately a SUPERSET of that tokenizer's, because erring toward "this is a
# comment" makes the scan stop EARLIER, find FEWER openers and drop LESS text —
# the safe direction, the same one the quote handling already fails toward. A
# `#` inside quotes is untouched (`echo '#'` still opens nothing), a `#` in
# mid-word is not a comment (`git log --format=%h#%s <<EOF` still opens one),
# and an unbalanced quote still drops NOTHING.
#
# Disclosed residual, unchanged by either fix: a `<<` in an arithmetic left-shift
# whose right operand is an identifier (`$(( x << n ))`) still reads as an
# opener and still drops the lines after it. Requiring the `<<` to sit in
# redirection position would close it and would also stop recognising the
# equally ordinary `cat<<EOF`, so it is disclosed rather than guessed at.
#
# THIS BLOCK IS DUPLICATED VERBATIM IN `git-guardrails.py` (its copy names the
# function `_strip_heredocs`). Duplicated, not imported: this hook's import of
# the sibling is best-effort and returns None on any failure, and a parser that
# silently stops running is exactly what this defect was.
_HEREDOC_DELIM = re.compile(
    r"""-?[ \t]*(?: (?P<q>['"])(?P<qword>[A-Za-z_][A-Za-z0-9_]*)(?P=q)
                  | \\?(?P<word>[A-Za-z_][A-Za-z0-9_]*) )""",
    re.VERBOSE,
)


def _heredoc_opener(line: str, quote: str = "") -> "tuple[str | None, str]":
    """The delimiter of the LAST heredoc this line OPENS (None if it opens
    none), and the quote state the line ends in — fed back in for the next
    line, so a string spanning lines stays quoted.

    An unquoted `#` that BEGINS a word ENDS the line: everything after it is a
    shell COMMENT and can open nothing. See the r17 paragraph above."""
    delim = None
    i, n = 0, len(line)
    while i < n:
        c = line[i]
        if quote:
            if c == "\\" and quote == '"' and i + 1 < n:
                i += 2                      # only `"` honours a backslash
                continue
            if c == quote:
                quote = ""
            i += 1
            continue
        if c == "\\" and i + 1 < n:
            i += 2                          # an escaped char, `\<` included
            continue
        if c in "'\"":
            quote = c
            i += 1
            continue
        if c == "#" and (i == 0 or line[i - 1] in " \t;&|()"):
            break                           # a COMMENT: no shell text follows
        if line.startswith("<<<", i):
            i += 3                          # HERESTRING: never an opener
            continue
        if line.startswith("<<", i):
            m = _HEREDOC_DELIM.match(line, i + 2)
            if m:
                delim = m.group("qword") or m.group("word")
                i = m.end()
                continue
            i += 2
            continue
        i += 1
    return delim, quote


def strip_heredocs(cmd: str) -> str:
    """Drop heredoc BODIES. `cat <<'EOF' > .claude/settings.json` still denies —
    the redirection is on the command line — but a body that merely *documents*
    `rm .claude/hooks/x` is prose, not a command, and must not trip a rule."""
    if "<<" not in cmd:
        return cmd
    out, pending, quote = [], None, ""
    for line in cmd.split("\n"):
        if pending is not None:
            if line.strip() == pending:
                pending = None
            continue                        # a BODY line: not shell text
        out.append(line)
        delim, quote = _heredoc_opener(line, quote)
        if delim:
            pending = delim
    return "\n".join(out)


def segments(cmd: str) -> list[list[tuple[str, str]]]:
    """Split into per-command segments of (kind, text) tokens; kind is
    'op' or 'word'. Best-effort — quoting oddities degrade to allow."""
    segs: list[list[tuple[str, str]]] = [[]]
    for m in _TOKEN.finditer(cmd):
        if m.group("op") is not None:
            tok = m.group("op")
            if tok in SEPARATORS:
                segs.append([])
            else:
                segs[-1].append(("op", tok))
        else:
            segs[-1].append(("word", unquote(m.group("word"))))
    return segs


def is_inplace(flag: str) -> bool:
    return (flag == "--in-place" or flag.startswith("--in-place=")
            or (not flag.startswith("--") and bool(_SHORT_INPLACE.match(flag))))


def skip_wrappers(words: list[str], stop_at: set[str] | None = None) -> int:
    """Advance past `FOO=bar` env-assignments and command wrappers — INCLUDING
    each wrapper's own option flags and the value some options take — to the
    index of the REAL command word. Returns len(words) if the whole segment is
    wrapper scaffolding.

    `stop_at` names wrappers to STOP ON rather than skip: with
    `stop_at={"env"}` the scan skips any leading `nice`/`timeout`/… but halts
    ON `env` itself, so a caller (env_split_payload) can then inspect env's own
    `-S` option instead of having it consumed as a skipped wrapper. Without it,
    every wrapper — env included — is skipped.

    The earlier version stopped at the first flag, so `env -i bash -c ...`,
    `nice -n 10 rm ...`, `sudo -u root ...`, `stdbuf -oL ...` and `timeout 5 rm`
    all halted on the flag and never reached the shell/deleter — defeating both
    the `-c` unwrap and direct deleter detection. Conservative-but-not-silent:
    where a flag's arity is unknown we treat it as attached-value (skip only the
    flag token), which risks skipping too LITTLE (a following real command is
    still scanned) rather than too much (which would blind the scan)."""
    i, n = 0, len(words)
    while i < n:
        if _ASSIGN.match(words[i]):          # FOO=bar prefix
            i += 1
            continue
        base = os.path.basename(words[i])
        if base not in WRAPPERS:
            break
        if stop_at and base in stop_at:      # halt ON this wrapper, don't skip it
            break
        i += 1                               # consume the wrapper name
        arg_opts = _WRAPPER_ARG_OPTS.get(base, set())
        while i < n:                         # consume this wrapper's options
            t = words[i]
            if _ASSIGN.match(t):             # `env VAR=val` after its flags
                i += 1
                continue
            if t == "--":                    # explicit end-of-options
                i += 1
                break
            if t.startswith("-") and t != "-":
                i += 1
                if t in arg_opts and i < n:  # separate-value option: eat its arg
                    i += 1
                continue
            break                            # first non-option word
        pos = _WRAPPER_POSITIONAL.get(base, 0)   # e.g. `timeout DURATION`
        while pos > 0 and i < n and not words[i].startswith("-"):
            i += 1
            pos -= 1
        # loop: words[i] may itself be another wrapper (`env sudo nice cmd`).
    return i


# Shell options that take a SEPARATE value, which must be consumed rather than
# mistaken for the -c payload. `--rcfile <file>` / `--init-file <file>` (bash)
# and `-o <option>` / `+o <option>` (every POSIX shell) are the ones that carry
# a value the shell reads but does not execute.
_SHELL_LONG_ARG_OPTS = {"--rcfile", "--init-file"}


def shell_c_payload(seg: list[tuple[str, str]]) -> str | None:
    """If this segment invokes a shell with `-c <payload>`, return the payload
    (already unquoted by the tokenizer) so scan() can recurse into it.

    The shell's OWN options are parsed properly rather than sniffed for the
    letter c. The earlier `w.startswith("-") and "c" in w` test set the -c flag
    on ANY option containing a c — so `bash --rcfile <file> -c '<payload>'`
    returned <file> as the payload, the real payload was never re-scanned, and a
    write into a gate-defining file hidden inside it passed silently. That failed
    toward MISSING the write, which is the direction this guard must never fail
    in. A `-c` is now only: the exact token `-c`, or a `c` inside a SINGLE-DASH
    short-flag group (`-lc`, `-ic`, `-ci`) — every letter of such a group is one
    short flag, so a `c` there really is `-c` and the command string really does
    follow it. That is a deliberate superset of the strict last-letter rule,
    because bash accepts `-ci '<payload>'` as readily as `-ic '<payload>'`. LONG
    options never set it, whatever letters they contain — `--rcfile` is exactly
    the bug — and the value-taking options above are consumed with their values.

    Where the parse is uncertain it errs toward SCANNING MORE (an unrecognised
    long option does not stop the walk; a stray operand does not end it), because
    an extra re-scan can only cost a false deny on text that literally contains a
    protected-path write, whereas stopping early costs the catch."""
    words = [t for k, t in seg if k == "word"]
    i = skip_wrappers(words)
    n = len(words)
    if i >= n or os.path.basename(words[i]) not in SHELLS:
        return None
    seen_c = False
    j = i + 1
    while j < n:
        w = words[j]
        if seen_c and not w.startswith("-"):
            return w                          # the command string
        if w == "--":                         # end of shell options
            j += 1
            continue
        if w.startswith("--"):                # long option: NEVER the -c flag
            if w in _SHELL_LONG_ARG_OPTS and j + 1 < n:
                j += 2                        # `--rcfile <file>` — eat its value
                continue
            j += 1                            # incl. attached `--rcfile=<file>`
            continue
        if w.startswith(("-", "+")) and len(w) > 1:
            group = w[1:]                     # short-flag group: one letter = one flag
            if "c" in group:                  # -c, -lc, -ic, -ci → payload follows
                seen_c = True
            if group.endswith("o") and j + 1 < n:
                j += 2                        # `-o pipefail` / `+o nounset` / `-co pipefail`
                continue
            j += 1
            continue
        j += 1                                # a bare operand; keep walking
    return None


# `env`'s -S/--split-string carries a COMMAND LINE that env splits into words
# and executes — a command-payload carrier exactly like a shell `-c`, not an
# opaque value. It appears as a separate value (`env -S '<payload>'`), attached
# (`-S<payload>`, `--split-string=<payload>`), OR bundled inside a short-flag
# group (`env -vS '<payload>'`, `env -iS '<payload>'`), all of which env
# executes.
_ENV_ARG_OPTS = {"-u", "--unset", "-C", "--chdir", "-P"}  # env opts taking a separate value


def env_split_payload(seg: list[tuple[str, str]]) -> str | None:
    """If this segment is `env` carrying -S/--split-string — reached through any
    number of command wrappers (`nice env -S …`, `timeout 5 env -S …`) — return
    the split string (a command line env will execute) so scan() can recurse
    into it, rather than letting its write/delete of a protected path pass
    unscanned. Locating env through the SAME skip_wrappers the rest of the guard
    uses (stopping ON env) is what closes the `<wrapper> env -S` bypass; matching
    -S inside a bundled short-flag group is what closes the `env -vS`/`-iS`
    bypass."""
    words = [t for k, t in seg if k == "word"]
    i = skip_wrappers(words, stop_at={"env"})   # skip nice/timeout/… , halt ON env
    if i >= len(words) or os.path.basename(words[i]) != "env":
        return None
    i += 1
    while i < len(words):
        w = words[i]
        if w == "--":                       # end of options; no split string
            return None
        if w in ("-S", "--split-string"):   # separate-value form: next word is it
            return words[i + 1] if i + 1 < len(words) else None
        if w.startswith("--split-string="):  # attached long form
            return w[len("--split-string="):]
        if w.startswith("-S"):              # attached short form `-S<payload>`
            return w[2:]
        # A bundled short-flag group that CONTAINS S (`-vS`, `-iS`, `-vS<payload>`):
        # env still splits+executes what follows the S. Chars after S in the same
        # token are the attached payload; if S is terminal, the next word is it.
        if w.startswith("-") and not w.startswith("--") and "S" in w:
            attached = w[w.index("S") + 1:]
            if attached:
                return attached
            return words[i + 1] if i + 1 < len(words) else None
        if _ASSIGN.match(w):                # NAME=VALUE → the command follows, no -S
            return None
        if w.startswith("-") and w != "-":  # some other env option
            if w in _ENV_ARG_OPTS and i + 1 < len(words):
                i += 2                      # separate-value option: skip its value too
            else:
                i += 1
            continue
        return None                         # a bare word = the command; no split string
    return None


def _compose_dash_c(parts: list[str]) -> str | None:
    """Fold every `-C <path>` on a git invocation the way git folds them.

    r15, found by auditing the sibling fix: this function kept only the LAST
    `-C`, so `git -C .claude -C hooks clean -fd` was SILENT while the
    byte-equivalent `git -C .claude/hooks clean -fd` DENIED (a22) — measured.
    git(1) composes them left to right: an ABSOLUTE value replaces what came
    before, a relative one is appended, an empty one is a no-op. The composed
    token is what the writer's working directory will actually be, and it is
    what `is_protected` is asked about; a relative result still resolves
    against the event cwd there, exactly as a single relative `-C` did."""
    cur: str | None = None
    for raw in parts:
        if not raw:                            # `-C ""` leaves the cwd alone
            continue
        expanded = os.path.expandvars(os.path.expanduser(raw))
        if cur is None or os.path.isabs(expanded):
            cur = raw
            continue
        # Compose with a FORWARD slash, not os.sep: is_protected() matches on
        # "/"-separated segments, so an os.path.join on Windows produced
        # ".claude\hooks" and the fold silently stopped being protected
        # (a54 fails exactly this way under Git Bash).
        cur = os.path.join(cur, raw).replace(os.sep, "/")
    return cur


def git_write_target(args: list[str]) -> tuple[str, str] | None:
    """For a segment whose command word is `git`, return (protected path, how)
    when a WORKING-TREE-WRITING subcommand names a protected path, else None.
    `args` is everything after the `git` word.

    Precise by construction, in three steps: (1) walk git's GLOBAL options —
    consuming the value of the ones that take a separate value — to find the
    real subcommand; (2) return None unless that subcommand is in
    GIT_WRITE_SUBS, so every read-only git invocation is left alone; (3) apply
    the guard's existing is_protected() test to the subcommand's PATH OPERANDS,
    respecting `--` (everything after it is a pathspec) and skipping option
    flags and a stash `-m <message>` value. A rev/branch operand — `HEAD~1`,
    `main` — never satisfies is_protected(), so scanning operands ahead of `--`
    costs nothing and catches the `--`-less spellings (`git restore <path>`,
    `git rm <path>`).

    A `-C <dir>` that is itself protected is also a write when the subcommand
    writes: `git -C .claude/hooks clean -fd` deletes hooks without ever naming
    one as an operand. MULTIPLE `-C` options are composed (r15) — see
    `_compose_dash_c`; keeping only the last one let the same deletion through
    spelled as `git -C .claude -C hooks clean -fd`."""
    i, dash_c_parts = 0, []
    while i < len(args):                       # 1. global options → subcommand
        w = args[i]
        if not w.startswith("-"):
            break
        if w in _GIT_GLOBAL_ARG_OPTS and i + 1 < len(args):
            if w == "-C":
                dash_c_parts.append(args[i + 1])
            i += 2
            continue
        if w.startswith("-C") and len(w) > 2:  # attached `-Cdir`
            dash_c_parts.append(w[2:])
        i += 1
    dash_c = _compose_dash_c(dash_c_parts)
    if i >= len(args):
        return None
    sub = args[i]
    if sub not in GIT_WRITE_SUBS:              # 2. read-only git → not a writer
        return None
    if dash_c is not None and is_protected(dash_c):
        return dash_c, f"`git {sub}` in a protected working directory"

    rest = args[i + 1:]                        # 3. the subcommand's operands
    operands: list[str] = []
    after_ddash = False
    k = 0
    while k < len(rest):
        w = rest[k]
        if after_ddash:                        # everything past `--` is a path
            operands.append(w)
            k += 1
            continue
        if w == "--":
            after_ddash = True
            k += 1
            continue
        if sub == "stash" and w in _GIT_STASH_MSG_OPTS and k + 1 < len(rest):
            k += 2                             # `-m <msg>` — a message, not a path
            continue
        if w.startswith("-") and w != "-":
            if w in ("-n", "--dry-run"):
                return None            # r21: writes nothing — see below
            k += 1
            continue
        operands.append(w)
        k += 1
    for a in operands:
        if is_protected(a):
            return a, f"`git {sub}`"
    return None
# r21 — THE DRY RUN IS A READ, AND REFUSING IT CONTRADICTED THIS GUARD'S OWN
# DENY MESSAGE. `git clean -n`, `git clean --dry-run`, `git rm -n` and
# `git rm --dry-run` list what WOULD happen and change nothing, and git spells
# the flag the same way for clean, rm and mv. Measured at 0d16939 on a project
# fixture: all four DENIED while the message printed to the user said reads are
# untouched — and the sibling guard's own deny text RECOMMENDS a dry run as the
# safe way to look before acting, so the pair told the user to run a command
# this one refused. The exemption is narrow on purpose: only the exact tokens
# `-n` / `--dry-run`, never a bundled short group (`-nf` still writes), so
# `git clean -fd` and every real writer are untouched. This was PRE-EXISTING,
# not introduced by a recent wave — the pre-r20 hooks refuse it identically.


def scan_segment(seg: list[tuple[str, str]]) -> tuple[str, str] | None:
    """Return (protected_path, how) for the first write found, else None.

    r19 — THE WRITER-PROGRAM BASENAME IS MATCHED CASE-INSENSITIVELY. This
    function tested `os.path.basename(...)` against ANY_ARG / DEST_LAST /
    INPLACE and against `git`/`dd`/`find`/`tar` with `==` and `in`, and on a
    case-insensitive filesystem — APFS, the macOS default — the uppercase
    spelling really runs the program. Measured 2026-08-24 on a throwaway project
    fixture, `RM -f .claude/hooks/git-guardrails.py` was ALLOWED (silent) while
    `rm -f` on the same path DENIED. `key` is the folded name used for every
    table lookup; `name` stays AS WRITTEN so the deny message quotes the
    spelling the caller actually used. Unconditional, and erring toward denying,
    for the reasons in `normalize`.

    Residual, disclosed rather than half-closed: the WRAPPERS and SHELLS tables
    (`skip_wrappers`, `shell_c_payload`) are still matched case-sensitively, so
    a case-varied WRAPPER hides the writer behind it. Measured 2026-08-24 on a
    throwaway project fixture: `nice rm -f .claude/hooks/git-guardrails.py`
    DENIED, while `NICE rm -f .claude/hooks/git-guardrails.py` and
    `BASH -c 'rm -f .claude/hooks/git-guardrails.py'` were ALLOWED (silent).
    That class predates r19 and is unchanged by it — r19 folded the WRITER
    name, not the scaffolding in front of it. It is listed in the module
    docstring's residual enumeration."""
    words = [t for k, t in seg if k == "word"]

    # 1. Output redirection — the target is the token right after the operator.
    #    `>&` (r18) is included: it is `&>` spelled the csh way, and it writes
    #    the FILE named after it unless that word is a descriptor.
    for idx, (kind, tok) in enumerate(seg):
        if kind != "op" or idx + 1 >= len(seg):
            continue
        if tok.endswith(">&"):
            k2, t2 = seg[idx + 1]
            if k2 == "word" and not _is_fd_dup_target(t2) and is_protected(t2):
                return t2, "output redirection (`>&` redirects both streams to the FILE)"
            continue
        if tok.endswith(">") or tok == ">|":
            k2, t2 = seg[idx + 1]
            if k2 == "word" and is_protected(t2):
                return t2, "output redirection"

    if not words:
        return None

    # 2. The command itself, past env assignments and wrappers (with their
    #    option arguments — see skip_wrappers).
    i = skip_wrappers(words)
    if i >= len(words):
        return None
    name = os.path.basename(words[i])
    key = name.lower()                       # r19: see the docstring above
    args = words[i + 1:]
    plain = [a for a in args if a != "--" and not a.startswith("-")]
    flags = [a for a in args if a.startswith("-")]

    if key == "git":
        hit = git_write_target(args)
        if hit:
            return hit

    if key in ANY_ARG:
        for a in plain:
            if is_protected(a):
                return a, f"`{name}`"

    if key in DEST_LAST:
        for f in flags:
            m = _TARGET_DIR.match(f)
            if m and is_protected(m.group(1)):
                return m.group(1), f"`{name}` target directory"
        if "-t" in flags and plain and is_protected(plain[0]):
            return plain[0], f"`{name}` target directory"
        # r21: a DESTINATION needs something to be the destination OF. With a
        # single operand there is no destination on the command line, and for
        # `ln`/`rsync` that operand is the SOURCE — `ln -s .claude/hooks/x`
        # creates `./x` POINTING AT the hook, and `rsync .claude/hooks/` lists
        # it. Both are reads. Measured at 0d16939: one-argument `ln -s`, `ln`
        # and `rsync` on a protected path all DENIED, falsifying this branch's
        # own "DESTINATION only" contract and the guard's "every READ is
        # allowed" guarantee. Pre-existing, not a recent regression. The
        # two-operand forms are untouched, which is every real write.
        if len(plain) > 1 and is_protected(plain[-1]):
            return plain[-1], f"`{name}` destination"

    if key in INPLACE and any(is_inplace(f) for f in flags):
        for a in plain:
            if is_protected(a):
                return a, f"in-place `{name} -i`"

    if key == "dd":
        for a in args:
            if a.startswith("of=") and is_protected(a[3:]):
                return a[3:], "`dd of=`"

    if key == "find":
        # A find that deletes: `-delete`, or `-exec/-execdir <deleter> ...`.
        deleters = {"rm", "mv", "truncate", "shred", "unlink"}
        destructive = False
        for k, a in enumerate(args):
            if a == "-delete":
                destructive = True
                break
            if a in ("-exec", "-execdir") and k + 1 < len(args) \
                    and os.path.basename(args[k + 1]).lower() in deleters:
                destructive = True
                break
        if destructive:
            # Path operands are the plain args before the first predicate flag.
            for a in args:
                if a.startswith("-"):
                    break
                if is_protected(a):
                    return a, "`find ... -delete/-exec`"

    if key == "tar":
        # Extraction WRITES files into the -C/--directory destination; creating
        # an archive only reads it, so gate on an extract mode being present.
        extracting = any(
            a in ("-x", "--extract") or a.startswith("--extract")
            or (a.startswith("-") and not a.startswith("--") and "x" in a)
            for a in args)
        if extracting:
            for idx, a in enumerate(args):
                if a in ("-C", "--directory") and idx + 1 < len(args) \
                        and is_protected(args[idx + 1]):
                    return args[idx + 1], "`tar` extraction destination"
                if a.startswith("--directory=") and is_protected(a[len("--directory="):]):
                    return a[len("--directory="):], "`tar` extraction destination"

    return None


# Quote-naive backstop: catches a BARE redirection the tokenizer mis-segments.
# It runs on a QUOTE-STRIPPED copy of the command (single- and double-quoted
# spans blanked to spaces of equal length), so a redirection that appears only
# *inside* quotes — an echo or a runbook line that documents `> .claude/...` —
# is prose, not a command-line redirect, and is not matched. A real bare
# redirect still is; and a redirect hidden in `bash -c '<payload>'` is handled
# by the shell-`-c` UNWRAP path below, which re-scans the (unquoted) payload, so
# the backstop no longer needs to see inside quotes at all.
# r18: `\d?>&` is listed here too — and BEFORE the bare `>` alternative, or the
# `>` would match first and the `&` would defeat the target class, which
# excludes `&`. The tokenizer path above is the primary fix; this is the
# backstop for a segmentation it mis-reads, and both must know the spelling.
_REDIR = re.compile(r"(?:&>>|&>|\d?>&|>\||>>|>)\s*([^\s;|&<>()]+)")
_QUOTED_SPAN = re.compile(r"'[^']*'|\"[^\"]*\"")


def strip_quoted(cmd: str) -> str:
    """Blank single- and double-quoted spans to equal-length runs of spaces, so
    the quote-naive backstop scans only the UNQUOTED command line."""
    return _QUOTED_SPAN.sub(lambda m: " " * len(m.group(0)), cmd)


def scan(raw: str, depth: int = 0) -> tuple[str, str] | None:
    # Heredoc bodies are dropped FIRST (they are line-oriented: joining a body
    # line that ends in `\` could hide the terminator and swallow the rest of
    # the command), and only then are line continuations spliced.
    cmd = join_continuations(strip_heredocs(raw))
    for seg in segments(cmd):
        hit = scan_segment(seg)
        if hit:
            return hit
        # A shell `-c '<payload>'` is a command line of its own; unwrap and
        # re-scan it (depth-limited, so pathological nesting cannot loop).
        if depth < 2:
            payload = shell_c_payload(seg)
            if payload is not None:
                hit = scan(payload, depth + 1)
                if hit:
                    return hit
            # `env -S '<payload>'` splits and executes its string, so it is a
            # command line of its own — unwrap and re-scan it, same depth guard.
            split = env_split_payload(seg)
            if split is not None:
                hit = scan(split, depth + 1)
                if hit:
                    return hit
    for m in _REDIR.finditer(strip_quoted(cmd)):
        target = m.group(1)
        if _is_fd_dup_target(target):
            continue                    # `>&2` / `2>&1` — a descriptor, not a path
        if is_protected(target):
            return target, "output redirection"
    return None


# --- cross-hook: destructive git inside an unwrapped payload ---------------
#
# THE GAP THIS CLOSES. The two hooks divided the work by what each could see,
# and the division left a hole neither owned:
#
#   * this hook unwraps a shell `-c` / `env -S` payload, but every rule it then
#     applies keys off a PROTECTED LITERAL PATH. `git reset --hard` names none,
#     so the unwrapped payload was re-scanned and found nothing;
#   * `git-guardrails.py` owns the destructive-git deny list, but it does not
#     unwrap payload carriers — to it, `bash -c '<payload>'` is one word whose
#     basename is `bash`, so no `git` invocation is found at all.
#
# Result: `bash -c 'git reset --hard'` and `bash -c 'git clean -fdx'` were
# denied by NEITHER, while their bare spellings were denied by git-guardrails.
# The second deletes untracked and ignored files, which is research data that no
# reflog holds. These are ordinary execution forms — a wrapper is how a script,
# a `Makefile`, or a generated command line spells things — not evasion attempts,
# so "a determined caller was never the threat model" does not excuse it.
#
# The fix is the one the referee asked for and the one that cannot drift: the
# payload-unwrapping layer CALLS the shared rules rather than reimplementing
# them. `git_deny_reason()` is IMPORTED from the sibling hook, so there is one
# definition of "destructive git" in the repository. A copy here would be a
# second consumer of an unwritten table, which is exactly the shape that
# produced git-guardrails' own r9/r10 defects.
#
# SCOPE, deliberately narrow:
#   * only the DENY LIST is shared, not the dirty-tree check. That check needs
#     the event dict, a resolved repository, and a live `git status`; wiring it
#     through a second hook would duplicate repository-identity logic — the
#     precise thing that keeps going wrong. Disclosed in the docstring instead.
#   * only UNWRAPPED payloads are tested. A direct `git reset --hard` reaches
#     this hook too, but git-guardrails already denies it; testing it here as
#     well would produce two denials for one command and make each hook's
#     battery depend on the other's behaviour.
#   * fail-open on anything the sibling RAISES — including a `SystemExit`. The
#     sibling is exec'd IN THIS PROCESS, so a `sys.exit()` reached while its
#     module body runs is not the sibling's problem, it is this hook's death:
#     the process ends with status 0 and an EMPTY stdout, and an empty stdout is
#     exactly what an ALLOW looks like. Both foreign-code entry points
#     (`exec_module`, and the `git_deny_reason` call) therefore catch
#     `BaseException`, not `Exception`. What is NOT survivable is named in
#     `_git_guardrails`'s docstring; the honest boundary is "raises", not "any
#     failure".

_GG_MODULE = None          # the imported sibling, or None
_GG_TRIED = False          # import attempted (once per process)


def _git_guardrails():
    """Import the sibling `git-guardrails.py` as a module, once per process.

    Loaded BY PATH because the filename is not an identifier (a hyphen), and
    from THIS file's directory so a hook directory selected for a fixture run
    pairs with its own sibling rather than the repository's. The module is
    import-safe as shipped: it does all its work under `if __name__ ==
    "__main__"`.

    SURVIVABLE — returns None, the caller gets no cross-hook opinion, and this
    hook's own path rules run exactly as they did before the sibling existed:
    the file missing, unreadable, or not loadable as a module; and ANYTHING the
    sibling's module body RAISES. That last word is the r20 correction. The
    sentence here used to read "Returns None on any failure", and the block
    above promised "fail-open on anything", while the code caught `Exception` —
    which is not `BaseException`. Because the sibling is exec'd IN THIS PROCESS,
    a `SystemExit` raised at its import time terminated root-of-trust-guard.py
    itself with status 0 and an EMPTY stdout, and empty stdout is
    indistinguishable from an allow. Measured 2026-08-24 at 727a66c: with
    `.claude/hooks/git-guardrails.py` replaced by `import sys; sys.exit(0)`, a
    write into `.claude/hooks/` returned rc=0 and said nothing — a SILENT ALLOW
    of a gate-file write. Not hypothetical either: an audit agent hit it by
    accident while building a stub and read the spurious result as a finding.
    `BaseException` is caught now, so `SystemExit`, `KeyboardInterrupt` and
    every ordinary exception all land in the same place.

    NOT SURVIVABLE, and no `except` clause can make it so: anything that ends
    the PROCESS without raising in this thread — `os._exit()`, a fatal signal, a
    crash inside a C extension the sibling imports — or a sibling whose module
    body never returns, since the harness then kills the hook on its registered
    timeout. In every one of those this file dies with nothing on stdout, which
    the harness reads as an allow. The mitigation is not here: it is that the
    sibling is a shipped, gated file, and a fixture run that replaces it points
    HOOK_DIR at a copy."""
    global _GG_MODULE, _GG_TRIED
    if _GG_TRIED:
        return _GG_MODULE
    _GG_TRIED = True
    try:
        import importlib.util
        path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "git-guardrails.py")
        spec = importlib.util.spec_from_file_location("_git_guardrails_shared",
                                                      path)
        if spec is None or spec.loader is None:
            return None
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)      # FOREIGN CODE, IN THIS PROCESS
        if callable(getattr(mod, "git_deny_reason", None)):
            _GG_MODULE = mod
    except BaseException:                 # r20: SystemExit is not an Exception
        _GG_MODULE = None
    return _GG_MODULE


def wrapped_git_deny(raw: str, depth: int = 0) -> str | None:
    """Run the SHARED destructive-git deny list over every command payload this
    hook can unwrap. Returns git-guardrails' own deny reason, or None.

    Walks the same segments, uses the same two carriers (`shell_c_payload`,
    `env_split_payload`) and the same depth <= 2 bound as scan(), so a payload
    this hook is willing to re-scan for path writes is exactly the set it also
    tests for destructive git. Nesting recurses: `bash -c "sh -c 'git clean
    -fd'"` is reached at depth 1.

    The TOP-LEVEL command is deliberately NOT passed to the deny list — only
    payloads. git-guardrails already decides the unwrapped spelling."""
    mod = _git_guardrails()
    if mod is None:
        return None
    cmd = join_continuations(strip_heredocs(raw))
    for seg in segments(cmd):
        for payload in (shell_c_payload(seg), env_split_payload(seg)):
            if payload is None:
                continue
            try:
                reason = mod.git_deny_reason(payload)   # FOREIGN CODE, IN-PROCESS
            except BaseException:   # r20: the same reason as the loader above —
                reason = None       # a sys.exit() here would end THIS hook silently
            if reason:
                return reason
            if depth < 2:
                deeper = wrapped_git_deny(payload, depth + 1)
                if deeper:
                    return deeper
    return None


# --- hook ------------------------------------------------------------------
#
# THE SAME INVARIANT AS `git-guardrails.py` (r16): every branch that can DENY
# must be able to RETURN inside this hook's registered timeout, because a hook
# the harness kills has written nothing to stdout, and nothing is exactly what
# an allow looks like. There is no way to distinguish the two from outside.
#
# This guard has no internal budget to fit, because it makes no subprocess call
# and does not walk the tree: the pattern half is pure text (`fnmatch`, a brace
# expansion bounded at `_BRACE_LIMIT`, a recursion bounded at depth 2), and the
# only filesystem work is the metadata calls in `in_project()` / `_git_root()`
# — `realpath`, `isdir`, `exists`. Those are microseconds on a local disk and
# are the one thing here that a stalled network mount can hang, which is the
# same class of slowness that produced the sibling's defect. So the
# registration carries the headroom instead of an internal timeout, and it is
# pinned to a stated number rather than left to drift.
_HOOK_REGISTERED_TIMEOUT = 20.0   # MUST equal .claude/settings.json's "timeout"


def deny(reason: str) -> None:
    json.dump({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}, sys.stdout)


# Bash's THREE quoting characters, and they are the complete set: the escape
# `\`, the single quote, and the double quote. Every other quoting form bash
# has is one of these with a `$` glued to the front (`$'…'`, `$"…"`), and that
# `$` is tested for separately below. No other QUOTING construct can sit INSIDE
# a word without changing which file the word names — a variable or a command
# substitution can, and both are disclosed as residual in the module docstring
# rather than claimed closed here.
_QUOTING_NOISE = str.maketrans("", "", "'\"\\")


def _denoise(cmd: str) -> str:
    """The command line with every quoting character DELETED.

    `.clau\\de` -> `.claude`, `.cl'aud'e` -> `.claude`, `.cl"aud"e` ->
    `.claude`, and — because deletion does not care how deeply the quotes are
    nested — `bash -c 'rm .clau\\de/hooks/x'` -> `bash -c rm .claude/hooks/x`.
    This is a TRIGGER-ONLY transform: it can only glue text together, so it can
    only make the test below say True more often, and the verdict itself is
    still decided by the scan on properly tokenised, properly unquoted words."""
    return cmd.translate(_QUOTING_NOISE)


def _may_name_a_protected_path(cmd: str) -> bool:
    """The fast path: can this command line name a gate-defining path at all?

    r15 — THE SAME LITERAL-COMPARISON DEFECT, ONE LEVEL UP. This used to be
    `".claude" not in cmd and ".githooks" not in cmd → return 0`, which is a
    LITERAL substring test standing in front of the whole scan. Fixing
    `matches_root_of_trust` to read globs was therefore not enough on its own:
    `rm -f .clau*/hooks/git-guardrails.py` and `rm -f .githook?/pre-commit`
    still returned before anything looked at them, because the metacharacter
    sits inside the protected DIRECTORY name and neither literal appears.
    Measured: both went SILENT with the pattern half already fixed.

    So the trigger is widened to "or the line carries a glob/brace
    metacharacter", which fails toward SCANNING. The cost is that a command
    containing a `*` is now tokenised and scored; that is pure string work
    (the pattern half touches no filesystem, and `in_project` runs only once a
    pattern has matched), and it is the same work the scan already did for
    every command mentioning `.claude`.

    r19 — THE SAME DEFECT AGAIN, TWICE, AND FOR THE SAME REASON: this literal
    test stands in front of the whole scan, so a fix below it is dead code for
    any command line the test rejects.

      * CASE. The substring test was case-SENSITIVE while the filesystem this
        repository lives on is not (APFS). With `_segment_matches` already
        folded, `echo X > .CLAUDE/settings.json` STILL returned here before
        anything looked at it — measured 2026-08-24 on a throwaway project
        fixture, ALLOW (silent), while the lowercase twin DENIED. The line is
        folded before the test now.
      * ANSI-C QUOTING. `$'\\x2eclaude/settings.json'` names the protected file
        to bash and carries none of its literal characters, so neither substring
        appears. A line carrying a `$'` or `$"` opener therefore always goes
        through to the scan, where `unquote` decodes it.

    r20 — THE THIRD DEFECT FROM THIS ONE FAST PATH, AND THE LAST ONE THAT WILL
    BE PATCHED AS AN INSTANCE. Ordinary shell quoting placed INSIDE the
    protected directory NAME carries neither literal, no glob metacharacter and
    no `$` opener, so the line was rejected here and the scan — which unquotes
    every word at every nesting depth, and would have denied all six — never
    ran. Measured 2026-08-24 at 727a66c on a throwaway project fixture, guard
    verdict then what bash actually did:

        rm -f .claude/hooks/git-guardrails.py      DENY   (literal control)
        rm -f .clau\\de/hooks/git-guardrails.py     ALLOW (silent) -> file DELETED
        echo X > .clau\\de/settings.json            ALLOW (silent)
        rm -f .githook\\s/pre-commit                ALLOW (silent)
        rm -f .cl'aud'e/hooks/git-guardrails.py   ALLOW (silent) -> file DELETED
        rm -f .cl"aud"e/hooks/git-guardrails.py   ALLOW (silent)

    WHY THIS CLOSES THE CLASS RATHER THAN THREE MORE INSTANCES. The trigger is
    now computed on `_denoise(cmd)` as WELL as on the raw line: a copy with
    bash's quote characters deleted. `\\`, `'` and `"` are the COMPLETE set of
    characters that can sit inside a word without changing which file the word
    names — every remaining quoting form is one of them with a `$` in front,
    and that `$` has its own test here since r19. Deleting all three therefore
    collapses EVERY arrangement of them, in any quantity, in any order, at any
    nesting depth, back to the literal the shell will use; there is no fourth
    spelling to enumerate later because there is no fourth character. That is
    the difference between this and the r15/r19 repairs, which each taught the
    trigger one more thing to look for.

    THE FOURTH MEMBER OF THE SAME CLASS, found by probing this repair rather
    than reported: a LINE CONTINUATION inside the name (`.clau\\` + newline +
    `de/hooks/…`). The backslash is quoting noise like any other, but the
    newline behind it is not, so deletion alone leaves `.clau\\nde`. It is the
    SPLICE that has to be right, and it was not — see the r20 note above
    `join_continuations`, which used to substitute a space where the shell
    deletes. With the splicer corrected the trigger simply runs on the spliced
    line, and the scan (which splices too) agrees with it.

    Each widening fails toward SCANNING, and that direction is what makes them
    safe: this function decides only whether to LOOK. A false trigger costs one
    tokenisation of a string that the scan will then clear (`echo ".clau"`
    denoises to `echo .clau`, matches nothing, allowed); it cannot produce a
    false deny, because the deny is the scan's verdict on the real words."""
    # r21: SPLICE FIRST, THEN TEST EVERY TRIGGER ON THE SPLICED TEXT. The r20
    # fix taught only the FIRST branch to read the spliced line and left the
    # other two reading the raw one, which composed the two widenings in one
    # direction only. A `$` separated from its quote by a backslash-newline
    # therefore carried no `$'` substring for branch two, and its ANSI-C escape
    # (`\x2e`) hid the dot from branch one, so the scan was never entered.
    # Measured at 0d16939 on a throwaway project fixture: an `rm -f` whose
    # argument was `$` + backslash-newline + `'\x2eclaude/hooks/…'` was
    # ALLOW(silent) and really deleted the guard file, while both the literal
    # spelling and the UNSPLIT `$'…'` spelling DENIED. One shared `spliced` is
    # the whole fix; the asymmetry was the defect.
    spliced = join_continuations(cmd)
    for text in (cmd, spliced, _denoise(spliced)):
        low = text.lower()
        if ".claude" in low or ".githooks" in low:
            return True
    if "$'" in spliced or '$"' in spliced:   # ANSI-C / locale quoting: see above
        return True
    return any(ch in spliced for ch in "*?[{")


def main() -> int:
    if os.environ.get("ALLOW_ROOT_OF_TRUST_WRITE", "") == "1":
        return 0

    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        return 0

    if data.get("tool_name", "") != "Bash":
        return 0

    cmd = (data.get("tool_input", {}) or {}).get("command", "") or ""

    # Cross-hook rule FIRST, because it is the one case with no protected path
    # in it — it has to run BEFORE the `.claude`/`.githooks` fast path below,
    # which exists only for the path rules and would return 0 on
    # `bash -c 'git reset --hard'` before anything looked at it.
    wrapped = wrapped_git_deny(cmd)
    if wrapped:
        deny(
            f"Blocked by root-of-trust-guard (destructive git inside a shell "
            f"payload): {wrapped} This hook unwraps `sh/bash/… -c` and `env -S` "
            f"payloads, so it applies git-guardrails' own deny list to what is "
            f"inside them — the wrapped spelling is not a way past the rule. "
            f"Neither the transcript nor `git reflog` can return uncommitted, "
            f"untracked, or ignored files, so this one is refused before it runs."
        )
        return 0

    if not _may_name_a_protected_path(cmd):
        return 0

    configure_scope(str(data.get("cwd", "") or ""))

    hit = scan(cmd)
    if not hit:
        return 0
    path, how = hit
    if _PROJECT:
        scope = (f"That path is one of this repository's gate-defining files "
                 f"({_PROJECT}) — the files that ")
    else:
        # No project directory could be resolved, so the hook cannot say which
        # tree this is; it refuses conservatively and says so rather than
        # asserting the path belongs to this repository.
        scope = ("This run could not resolve a project directory, so the path is "
                 "refused on the path PATTERN alone — the files that ")
    deny(
        f"Blocked by root-of-trust-guard: shell write to '{path}' via {how}. "
        f"{scope}"
        f"define every gate (.claude/settings.json, .claude/settings.local.json, "
        f".claude/hooks/, .githooks/). Permissions run in bypass mode here, so a "
        f"shell one-liner can disable the whole gate suite without leaving anything "
        f"a reviewer would see. Reads are untouched; edit the file with the "
        f"Edit/Write tool instead, which lands as a reviewable diff. "
        f"(Override: start the session with ALLOW_ROOT_OF_TRUST_WRITE=1 in its "
        f"environment.)"
    )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail open
