#!/usr/bin/env python3
"""
Git & Path Guardrails Hook (PreToolUse)

Blocks the small set of operations that are destructive or that the
template's own conventions forbid — before they run, not after. Adapted
from the `git-guardrails` pattern in mattpocock/skills, scoped so the
normal workflow (`/commit` stages specific files, and pushes only with
`--pr`) still works.

Two checks, by tool:

  Bash — deny destructive / convention-violating git:
    - git reset --hard            (silently discards work)
    - git clean -f / -fd / -fdx   (deletes UNTRACKED files — incl. data)
    - git push --force / -f       (clobbers remote history; --force-with-lease is allowed)
    - git add -A / --all / git add .   (the commit skill forbids blanket staging)
    - git checkout -- . / git restore .   (mass discard of working changes)

      HOW THE DENY LIST DECIDES, since r10: over the SAME tokenised, unquoted
      segments the clean-tree check reads, not over the raw command string. The
      command line is split into segments, each segment's leading shell syntax
      is dropped, a word whose basename is `git` is found, git's GLOBAL options
      are walked, and the rule for that SUBCOMMAND is applied to the remaining
      ARGUMENT TOKENS — `--hard`, `--force`, `-A`, `.` — compared as whole
      words. Until r10 these were regexes over the raw string, so quoting one
      token defeated them: `git reset "--hard" HEAD~1`, `git 'reset' --hard
      HEAD~1`, `git add '-A'`, `git add "--all"` and `git checkout -- '.'` were
      all SILENT while the byte-equivalent bare spellings DENIED. Sharing the
      tokenizer also means the two checks can no longer disagree about what a
      command says, and it fixed a false deny in the other direction: a fully
      QUOTED mention (`echo "never run git reset --hard here"`) writes nothing
      and is now silent. An UNQUOTED mention still denies — see THE COST OF
      FAILING TOWARD DENY below; that applies to both checks.

    - git merge / rebase / pull unless the invocation is a STANDALONE SIMPLE
      COMMAND whose repository reads clean RIGHT NOW   (a resolution that also
      swallows uncommitted work is unreviewable afterwards). Stated that way on
      purpose: the reading is taken at PreToolUse, so the only honest guarantee
      is over a command that cannot itself dirty the tree before git starts —
      see rule 0. Hatch: ALLOW_DIRTY_MERGE=1.

      WHAT THE RULE IS, SAID WITHOUT OVERCLAIM (r13). This heading used to read
      "THE RULE IS A CLOSED ALLOWLIST OVER THE WHOLE COMMAND", while the same
      file admitted forty lines below that `bash -c 'git merge main'` is not
      inspected. An external referee (2026-08-23) called that what it is: a
      best-effort RECOGNIZER wrapped around a closed decision, not a closed
      allowlist over the whole command. The truthful statement is:

        For a history operation THIS PARSER IDENTIFIES, the allow paths are
        limited to a fixed set of escape tokens, an `--autostash` on a tree
        with no untracked files, and a clean live `git status` reading — and
        the op must be a STANDALONE SIMPLE COMMAND. An invocation the parser
        does NOT identify passes outside this rule entirely: it is not allowed
        by the rule, it is INVISIBLE to it, and it runs.

      Rules 0-3 below are what happens to an op that IS identified.

        0. STANDALONE OR NOTHING (r13 — the TOCTOU repair). This hook decides at
           PreToolUse, BEFORE bash runs the command, so a tree reading taken now
           says nothing about the tree the op will actually start from. The
           referee's case, on a CLEAN repository:

               printf '\n# local work\n' >> analysis.R && git merge main

           reads clean at hook time and is dirty when git executes. Rounds 4-12
           read that asymmetry backwards: a chain that CLEANED the tree
           (`git stash push -m x && git merge`) was DENIED, while a chain that
           DIRTIED it was ALLOWED. The whole false-deny cost was being paid for
           none of the safety.

           So an identified history op reaches the tree reading ONLY as a
           STANDALONE SIMPLE COMMAND. If the command line carries anything else
           — a second shell segment, a pipeline, a redirection, a command or
           process substitution, a grouping, a `cd`, a variable assignment — the
           op is DENIED, without reading the tree. Over the text the parser
           sees, this IS a closed grammar rather than a best-effort search:
           there is no ordering of write-then-op that survives it, because the
           only accepted shape has nowhere to put a write. The rule-2 escapes
           keep working — on a standalone op; `git merge --abort && echo done`
           is denied like any other chain.

           THE COST, restated honestly. The accepted cost was already "run the
           cleaning step as a SEPARATE command"; r13 does not add to that, it
           makes it apply in both directions. What r13 DOES newly deny is an op
           with an ordinary trailing convenience — `git pull | tail -5`,
           `git pull > log 2>&1`, `git merge x && npm install`, `git merge
           $(cat branchfile)`. Each costs one extra tool call. And that IS a
           tool call, a hook cycle and an agent round trip — not "one extra
           keystroke", as this docstring used to claim.
        1. FIND the history ops this command line invokes, by parsing the
           command TEXT. The line is split into segments; each segment's
           leading shell syntax is dropped — variable assignments, the reserved
           words (`if then elif else fi for while until do done case esac in
           select function time`), a `!` negation, the grouping tokens
           `( ) { }`, a leading redirection — and the segment is then searched
           for a word whose basename is `git`, followed (after git's GLOBAL
           options) by `merge` / `rebase` / `pull`. If no segment yields one,
           this check is SILENT. A `git pull` that survives quoting as a single
           WORD — inside an `echo "…"`, a heredoc body, a `python3 -c '…'`
           payload — is text, not an invocation, and is not found.
           This step is a best-effort parse, and it is the ONLY thing standing
           between an op and the tree reading. What it cannot identify, it does
           not check: see WHAT IT DOES NOT SEE.
        2. ESCAPE / SELF-MANAGING FLAGS, as ACTUAL ARGUMENT TOKENS. A word that
           IS `--abort`, `--continue`, `--skip`, `--quit` or `--edit-todo`
           ALLOWS without reading the tree: those five are how you get OUT of a
           dirty in-progress operation. The test is EXACT TOKEN EQUALITY over
           the words after the subcommand, stopping at a `--` end-of-options
           marker and skipping the VALUES of value-taking options (`-m`, `-F`,
           `--exec`, `-X`, `-s`, …). So an exempt word that is really part of a
           VALUE does not qualify — `git merge -m "wip --autostash later"` is
           an ordinary merge and faces rule 3 — and `--skip-smudge` (a
           different flag that merely starts with an exempt one) does not
           qualify either.

           `--autostash` IS NO LONGER UNCONDITIONALLY EXEMPT (r13). It used to
           be, on the stated ground that "git ESTABLISHES the precondition this
           check exists to enforce". That was FALSE for untracked files, and
           the external referee reproduced it: in a repository holding an
           untracked `note.txt`, `git merge --autostash main` completed and
           `git status --porcelain` still reported `?? note.txt` afterwards —
           because `git stash` does not stash untracked files at all, which is
           the very semantic that justified deleting the shell predictor in r8.
           The exemption therefore reintroduced the hole it was written beside.
           CHOICE MADE, of the referee's two options: `--autostash` now READS
           the tree and is allowed only when `git status --porcelain` reports
           NO `??` entry. Tracked and staged changes may be git-managed; an
           untracked file may not. `--no-autostash` still does not qualify for
           anything and faces rule 3.
        3. Otherwise READ THE TREE, live: `git status --porcelain` in the
           working directory the invocation itself names (the event cwd, or the
           `-C <path>` options carried by the history-op segment — a quoted
           `-C` path is honoured, so quoting cannot bypass it, and a RELATIVE
           `-C` path is resolved against the event cwd, not against whatever
           directory the hook process happens to have been spawned in).
           CLEAN → allow. DIRTY → DENY.

           THE QUESTION IS PINNED AGAINST CONFIGURATION (r15). `git status
           --porcelain` honours settings that can make a dirty tree report
           EMPTY, so the flags are part of the question:
           `--untracked-files=normal` (else `status.showUntrackedFiles=no` —
           the documented remedy for a slow status — hides every `??` entry,
           which is precisely the dirt rule 2b exists for) and
           `--ignore-submodules=none` (else `diff.ignoreSubmodules=all` /
           `submodule.<name>.ignore` hides a submodule holding modified work).
           Both measured on git 2.50.1; see `_GIT_STATUS_CMD`. A reading the
           guarded repository can reconfigure is not a reading.

           EVERY `-C` IS COMPOSED, NOT JUST THE LAST (r15). git folds multiple
           `-C` options left to right — each subsequent non-absolute one is
           relative to the preceding one — so keeping only the last and
           resolving it against the event cwd read a DIFFERENT repository than
           git would use: `git -C <dirty> -C . merge feature`, fired from a
           clean checkout, was ALLOWED. `_resolve_dash_c` now folds them git's
           way (absolute replaces, relative appends, empty is a no-op).

           AN UNREADABLE STATUS DENIES (r15). `read_status` used to return the
           same None for "this is not a repository" and for "git could not
           answer" (timeout, non-zero exit, exception), and the no-`-C` caller
           read that as the former and ALLOWED. A slow `git status` was
           therefore a silent allow on a dirty tree — the same unanswered
           question the `-C` branch was fixed for at r13. Only the benign cause
           (no `.git` at or above the directory, decided from the FILESYSTEM so
           a broken git cannot fake it) allows now; everything else denies, and
           the timeout bound is configurable via CLAUDE_GIT_STATUS_TIMEOUT
           (default 10s) so a genuinely slow worktree can be worked in.

           THE BUDGET MUST FIT INSIDE THE REGISTRATION (r16). That 10s bound
           shipped against a 5s `"timeout"` in .claude/settings.json, so on the
           very worktree it was raised for the harness killed this hook before
           it could write the deny — and a killed hook emits nothing, which is
           what an ALLOW looks like. The registration is 20s now, the internal
           bound is derived from it (`_HOOK_REGISTERED_TIMEOUT` minus margin),
           and CLAUDE_GIT_STATUS_TIMEOUT is CLAMPED rather than honoured.

           AN UNRESOLVED REPOSITORY SELECTOR NOW DENIES (r13). If the invocation
           names a `-C <path>` that cannot be read as a repository — it does not
           exist, it holds an unexpanded `$var`, git cannot answer — the check
           used to fall back to reading the EVENT cwd, and allow if THAT was
           clean. The referee named this correctly: reading a different
           repository and allowing because it is clean IS allowing on the
           unanswered question. `REPO=/tmp/B` + `git -C "$REPO" merge main` was
           judged against `/tmp/A`. It now DENIES, and says to rerun from that
           repository or spell the path literally.

      OTHER REPOSITORY SELECTORS ARE DENIED, BY NAME (r13). `-C` is not the only
      way to select a repository, and the docstring's old "the event cwd, or a
      `-C`" was simply wrong about git. The referee reproduced both native
      forms: `git --git-dir=/tmp/B/.git --work-tree=/tmp/B merge feature`
      launched from a clean `/tmp/A` fast-forwarded B and left B's untracked
      file in place, and `GIT_DIR=… GIT_WORK_TREE=… git merge feature` does the
      same with no option at all. CHOICE MADE, of the referee's two options:
      rather than bind these into the status query, a history op carrying any of
      `--git-dir`, `--work-tree`, `--namespace`, `--bare`, or ANY variable
      assignment on its command line (which covers `GIT_DIR=`, `GIT_WORK_TREE=`,
      `GIT_INDEX_FILE=`, `GIT_COMMON_DIR=`, `GIT_OBJECT_DIRECTORY=`,
      `GIT_NAMESPACE=` and every future sibling, because the ban is on the SHAPE
      `NAME=VALUE`, not on a list of names) is DENIED outright. Run the op from
      the repository it belongs to. This is named as a mechanism, not left to
      the "assume there are more" bullet at the bottom of this file.

      WHY IT NO LONGER SIMULATES THE SHELL. Eight audit rounds tried to
      PREDICT, from command text, whether the tree would still be clean by the
      time the op ran: stash flags, then stash subcommands, then the segments
      in between, then per-repository clean marks, then output redirection —
      and every round found one more dimension the enumeration had missed. The
      last round found three at once: a command substitution inside an
      "inert" segment (`echo $(touch f)` writes and was classified inert), a
      `cd` into another checkout, and the plain semantic fact that `git stash`
      does not stash UNTRACKED files at all — so even a "provable full
      cleaner" can leave the tree dirty. Simulating shell semantics by
      enumeration does not converge. So the machinery that existed only to
      model intervening segments — the stash-effect classifier, the
      inert-segment allowlist, the per-repository cleaned map — IS DELETED.
      The check reads the tree as it actually is at decision time. Command
      substitution, `cd`, untracked-after-stash and every shell form not yet
      invented cannot make a live `git status --porcelain` report a dirty tree
      as CLEAN — the verdict is not derived from the command text at all.

      WHAT THAT SENTENCE DOES NOT COVER, and round 9 proved it: a form can
      still keep the op out of the PARSER's sight, so no reading is ever taken.
      That is a different failure and it is a real one — round 9 executed three
      instances (`if true; then git merge x; fi`, `git -P reset --hard` /
      `git --no-optional-locks pull`, and `git merge -m "… --autostash …"`).
      Those three are closed. The class is NOT closed, so what remains is
      disclosed below as residual rather than claimed away.

      THE ACCEPTED COST, stated plainly and corrected at r13: `git stash push -m
      x && git merge` is DENIED, even though it would sometimes have worked —
      and the old text's example was itself overstated, because on a tree whose
      only dirt is UNTRACKED files that chain would NOT have worked: plain
      `git stash push -m x` leaves `??` entries exactly where they were, and the
      merge would have started dirty. (`git stash push -u -m x` is the spelling
      that includes them.) The remedy is unchanged: run the cleaning step and
      the history op as SEPARATE commands — the guard re-reads the real tree
      state on the second one — or commit/stash first, or set
      ALLOW_DIRTY_MERGE=1. Split is also clearer: you see whether the stash
      actually cleaned the tree before you merge, instead of asking a hook to
      guess. The cost is one extra TOOL CALL, with its own hook cycle and agent
      round trip; earlier revisions of this file called it "one extra
      keystroke", which understated it.

  Write/Edit/MultiEdit — warn on hardcoded machine paths in code:
    - absolute home paths (/Users/<u>, /home/<u>, C:\\Users\\<u> with either
      slash, single or doubled, any case) written into .R / .qmd / .do / .py /
      .Rmd files (extension in any case) break replication packages. Warn by
      default; set CLAUDE_STRICT_PATHS=1 to hard-deny.

LINE CONTINUATIONS ARE SPLICED (r12), for BOTH checks, before the command line
is split into segments. A backslash-newline JOINS the line in POSIX shell; this
tokenizer used to read it as a separator, so a `git clean` whose `-xfd` sat on a
continued line — ordinary multi-line formatting, not an evasion — was two
segments and went SILENT while the one-line spelling DENIED. An ESCAPED
backslash (two of them) before a newline is not a continuation and still
separates commands.

WHAT THE CLEAN-TREE CHECK IS — a LIVE reading of `git status --porcelain`,
reached through a best-effort TEXTUAL scan of the Bash command line. The scan
answers one narrow question — does this command line invoke a history op, and
in which directory — and nothing else is inferred from the text. It is not a
proof and not a sandbox.

WHAT IT GUARANTEES — this much, and no more. For a history op this parser
IDENTIFIES (rule 1), the op must first be a STANDALONE SIMPLE COMMAND (rule 0)
or it is denied outright; then, if it carries no rule-2 escape token, the
verdict is a LIVE `git status --porcelain` reading taken at hook time in the
directory the invocation names — resolved since r18 the way git's own `chdir()`
resolves it, through the kernel, so a `-C` whose `..` follows a SYMLINK is read
in the repository git will land in rather than the one the text spells out. No
feature of the command text substitutes for that reading: there is no model of
the shell left to fool, so the ALLOW side
cannot be talked into existing by clever text — it can only be reached by a
tree that is actually clean, or by the op never being identified in the first
place.

WHY RULE 0 IS WHAT MAKES THE READING MEAN ANYTHING. The reading is taken BEFORE
bash runs the command. Until r13 the guarantee was therefore only "the
parser-selected repository was clean when the Bash tool call was authorized" —
materially narrower than "history operations start from a clean tree", which
this file's summary and the doctrine's law 20 both asserted. Rule 0 closes the
gap the only way a PreToolUse hook can: by refusing every command shape that
could act between the reading and the op. What remains is the ordinary external
race — another process writing to the tree in the milliseconds between the
`git status` and git starting — which is disclosed, not claimed away, and is
categorically smaller than predicting an arbitrary shell prefix.

WHAT IT EXPLICITLY DOES NOT CLAIM: that it identifies every shell form. It does
not, it cannot, and nine rounds of trying to enumerate forms is the reason that
sentence is written this way. Where the parse is ambiguous the code is written
to fall toward FINDING an op (an unknown git global option is consumed rather
than mistaken for the subcommand; a `git` word later in a segment is still
searched for; a `-C` directory that cannot be read as a repository DENIES since
r13, rather than falling back to the event cwd) — but "falls toward deny where
the parse permits" is not "denies everything it should". A form the parser
does not identify is not
denied; it is INVISIBLE, and the op runs. That residual is listed next.

THE COST OF FAILING TOWARD DENY, stated as a cost: because a `git` word is
searched for past an unrecognised leading word, an UNQUOTED mention of a
history op in an ordinary command — `echo run git pull later`, `man git merge`
— is denied on a dirty tree. Quoting it (`echo "run git pull later"`) makes it
one word again and it is silent. This is the same trade as the r8 accepted
cost: a small, visible over-deny bought a whole class of wrapper bypasses.
Since r10 the deny list shares that parser, so it carries the same cost:
`echo run git push --force later` denies, `man git reset` does not (no
`--hard`), and the quoted spellings of both are silent.

WHAT IT DOES NOT SEE — disclosed residual, BOUNDARY not defect. Since r10 this
block covers BOTH checks, because both reach their subject through the SAME
parser: what the parser cannot identify, neither check sees. (Before r10 it was
scoped to the clean-tree check alone, while the deny list ran on raw text and
had no boundary statement anywhere — which is how the quoting hole above went
undisclosed as well as unclosed.)
  - a history op carried by an INTERPRETER whose program text is not a command
    line — `python3 -c '...subprocess.run(["git","merge"])...'`, `perl -e`, an
    R `system()` call. The op never appears as a `git` segment here.
  - a history op inside a SHELL-WRAPPER payload — `bash -c 'git merge main'`,
    `env -S 'git pull'`, `sh -c '...'`. Unlike root-of-trust-guard, this check
    does NOT unwrap `-c` payloads, so such a form is not inspected. (A payload
    that is a single QUOTED word is one word to the tokenizer; the same is true
    of any op that survives quoting intact.)
  - a history op run by an alias, a script file, a Makefile target, or a git
    hook — anything whose text is on disk rather than on this command line.
  - any dirtying by ANOTHER PROCESS between the hook's decision and git
    starting. The `git status` answer is a point-in-time reading; rule 0 closes
    the case where the SAME command line does the dirtying, but it cannot close
    a concurrent writer. Ordinary accidents, not concurrency, are the threat
    model here.
CLOSED at r13, therefore no longer residual: `cd <other repo> && git merge`
(disclosed since r8 as judged against the session's repository rather than the
one the merge runs in) — a `cd` on a history op's command line now DENIES under
rule 0, as does every other multi-segment form. So does an unresolved `-C`, and
so do the `--git-dir` / `--work-tree` / `GIT_DIR=` / `GIT_WORK_TREE=` selectors,
which the pre-r13 text wrongly implied did not exist.
CLOSED at #172 (2026-09-27), therefore no longer residual: an op inside a
subshell or a substitution — `(git reset --hard)`, `$(git merge main)`, the
backtick spelling. The tokenizer read `(git` and `--hard)` as single words, so
no `git` segment was ever identified; it now separates on `(`, `)` and
backticks, so the deny list sees the destructive op and rule 0 denies the merge.
  - ANY SHELL FORM THAT PUTS THE OP SOMEWHERE THIS PARSER DOES NOT LOOK. The
    list above is the set known on 2026-08-23; it is a report of where the
    parser has been probed, not a proof of where it is complete. Round 9 found
    five such forms that eight earlier rounds had not (compound-command
    keywords, an exempt token inside an option value, the same inside a trailing
    comment, unenumerated git global options, a relative `-C`). All five are
    closed; the CLASS is not. Assume there are more.
CLOSED at r9, therefore no longer residual: the bare COMMAND WRAPPER
(`timeout 300 git pull`, `nice git merge`, `nohup`, `command`, `env`), disclosed
at r8 because the segment's first word is not `git`. A `git` word is now
searched for along the segment — at the over-deny cost stated above.
None of the forms above is closed, and these checks are DEFENCE IN DEPTH over a
deliberate bypass posture, not a sandbox: permissions ship in bypass mode here,
so a determined caller was never the threat model. What actually backstops it
is the same layering root-of-trust-guard relies on — the operation stays
visible in the transcript, changes arrive through reviewable Edit/Write diffs
rather than invisibly, and the deliberate hatch (ALLOW_DIRTY_MERGE=1 in the
session environment) exists so the honest way past this check is to SAY SO
rather than to route around it.
DO NOT list reflog or ORIG_HEAD among those backstops, however tempting: they
recover COMMITS. The work this check exists to protect is precisely the work
that is NOT committed — uncommitted edits and untracked files — and no reflog
entry brings those back. An external referee caught that claim standing in the
docs; it was removed there and must not creep back here. What this hook buys is that the ordinary accident — an
agent one-liner that merges over uncommitted work — costs a denial instead of
an unreviewable commit.

Decision protocol (modern PreToolUse): exit 0 + JSON
  {"hookSpecificOutput": {"hookEventName": "PreToolUse",
    "permissionDecision": "deny", "permissionDecisionReason": "..."}}.
Fail-open: any error → exit 0 with no decision (allow).
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path

# ── git's GLOBAL options: ONE table, ONE consumer ──────────────────────────
#
# Options can sit between `git` and the subcommand (`git -C <dir> reset --hard`,
# `git -c x=y clean -fd`). Both the deny list and the clean-tree check must walk
# past them to reach the real subcommand — and until r9 each had its OWN
# enumeration of which options exist. Both enumerated seven. git documents far
# more, so ONE innocuous unlisted option defeated BOTH at once: `git -P`
# (git's own short spelling of `--no-pager`, whose LONG spelling was listed),
# `git --no-optional-locks`, `--literal-pathspecs`, `--icase-pathspecs`,
# `--no-replace-objects`, `--exec-path=…`, `--bare`. With any of them inserted,
# `reset --hard` / `clean -fd` / `push --force` / `add -A` / `checkout -- .`
# all went SILENT, and so did the dirty-tree check on merge/rebase/pull.
#
# So stop enumerating which options EXIST. Enumerate only the ones that take a
# SEPARATE value token (the one thing a walker cannot guess), and treat every
# other leading `-…` word as a one-token global option. That fails toward
# FINDING the subcommand — i.e. toward DENY — instead of toward missing it.
#
# r10: there is no longer a regex COPY of this table. `_GO`, the regex-prefix
# spelling that the deny patterns carried, is DELETED along with the raw-string
# deny regexes themselves — the deny list now walks the same `_walk_git_globals`
# the clean-tree check walks, so the "two consumers that disagreed" shape that
# produced the r9 defect cannot recur here at all.
_GIT_GLOBAL_VALUE_OPTS = ("-C", "-c", "--git-dir", "--work-tree", "--namespace",
                          "--exec-path", "--super-prefix", "--attr-source",
                          "--config-env")


# ── the destructive-git deny list, decided over TOKENS ─────────────────────
#
# r10: these five rules used to be REGEXES over the RAW command string, and
# ordinary shell quoting of a SINGLE token defeated every one of them. Executed
# against the shipped guard on a fixture repo: `git reset --hard HEAD~1` DENIED,
# while `git reset "--hard" HEAD~1`, `git 'reset' --hard HEAD~1`, `git add '-A'`,
# `git add "--all"` and `git checkout -- '.'` were all SILENT. The clean-tree
# check had already been rebuilt to tokenise (`_segments` → `_unquote` →
# `_git_segment`); the deny list had not, so the two halves of ONE guard
# disagreed about what a command even says, and the half with no boundary
# statement was the one with the hole.
#
# They now share ONE representation. A rule is
# (subcommand, predicate over the ARGUMENT TOKENS, reason, safe alternative);
# the predicate sees every word after the subcommand, already unquoted, with a
# trailing shell comment already dropped by `_segments`. A quoted flag is
# therefore matched exactly like a bare one, because by the time the predicate
# runs there is no difference between them.
#
# WHAT THE PORT CHANGED, both directions, stated rather than claimed away:
#   * quoting no longer evades — the six spellings above now DENY (battery
#     cases b5-b12 pin them).
#   * a MENTION that survives quoting is now correctly SILENT: in
#     `echo "never run git reset --hard here"` the quoted span is ONE word whose
#     basename is not `git`, so no invocation is found. The old raw regex DENIED
#     that string, which wrote nothing — a false deny, now gone (case b13).
#   * an UNQUOTED mention — `echo run git reset --hard later` — still denies,
#     because `_git_segment` searches for a `git` word ALONG the segment. That is
#     the SAME accepted over-deny the clean-tree check already carries and it is
#     what closes the bare-wrapper class (`timeout 300 git push --force`,
#     `nice git clean -fd`), which the raw regex caught only by the accident of
#     matching anywhere in the string.
#
# The predicates deliberately do NOT stop at a `--` end-of-options marker. For
# `add`/`checkout`/`restore` the dangerous operand is a PATHSPEC that
# legitimately follows `--` (`git add -- .`), and for the flag rules a `--hard`
# or `--force` sitting after `--` would be a pathspec by that name, which does
# not exist. Biased toward DENY, like the rest of this file.

def _has_token(args, *names):
    """True when an ACTUAL argument token IS one of `names` (exact equality —
    `--force-with-lease` is not `--force`)."""
    return any(a in names for a in args)


def _short_flag(args, letter):
    """True when a single-dash SHORT-OPTION GROUP carries `letter`: `-f`, `-fd`,
    `-uA`. A long option is never a short group, which is what keeps
    `--force-with-lease` and `--force-if-includes` allowed."""
    return any(len(a) > 1 and a[0] == "-" and not a.startswith("--") and letter in a[1:]
               for a in args)


def _mass_discard(args):
    """`git checkout -- .` / `git restore .` — a whole-tree discard.

    `--staged`/`-S` alone is NOT a working-tree discard (it unstages, and the
    work stays in the tree), so it does not qualify unless `--worktree`/`-W` is
    also present. The old regex could not express this: it only looked at the
    token immediately after the subcommand, so it neither caught
    `git restore --source=HEAD .` nor spared `git restore --staged .`."""
    if not _has_token(args, "."):
        return False
    staged = _has_token(args, "--staged") or _short_flag(args, "S")
    worktree = _has_token(args, "--worktree") or _short_flag(args, "W")
    return worktree or not staged


# (subcommand, predicate over argument tokens, human reason, safe alternative)
GIT_DENY = [
    ("reset", lambda a: _has_token(a, "--hard"),
     "git reset --hard discards uncommitted work irrecoverably.",
     "Use `git stash` (recoverable) or reset specific paths."),
    ("clean", lambda a: _has_token(a, "--force") or _short_flag(a, "f"),
     "git clean -f/--force deletes UNTRACKED files — including data not yet committed.",
     "Inspect with `git clean -n` first; delete specific paths by hand."),
    ("push", lambda a: _has_token(a, "--force") or _short_flag(a, "f"),
     "git push --force clobbers remote history.",
     "Use `git push --force-with-lease` if you truly must rewrite a branch."),
    ("add", lambda a: _has_token(a, "-A", "--all", ".", ":/") or _short_flag(a, "A"),
     "Blanket staging (git add -A / . / -- . / :/) can stage data, secrets, or settings.local.json. "
     "The /commit skill forbids it.",
     "Stage specific files: `git add path/to/file ...`."),
    ("checkout", _mass_discard,
     "Mass discard of working-tree changes is irreversible.",
     "Discard specific files, or `git stash` to keep them recoverable."),
    ("restore", _mass_discard,
     "Mass discard of working-tree changes is irreversible.",
     "Discard specific files, or `git stash` to keep them recoverable."),
]

# A merge, rebase, or pull started on a dirty tree resolves *two* sets of
# changes at once and records only one of them as a decision — afterwards
# nothing distinguishes "I chose this" from "this was in my tree".
#
# The check operates on COMMAND SEGMENTS for ONE reason only: to tell a real
# `git merge` from a `git merge` merely mentioned in an echo, inside a quoted
# string, or in a heredoc body. It does NOT reason about what the other
# segments do — that was the simulator, and it is gone (see the docstring).
#
# `--autostash` is exempt for the OPPOSITE reason to `--abort`/`--continue`: it
# is git's own stash-operate-restore. git stashes the dirty tree, runs the
# merge/rebase/pull, and reapplies the stash afterwards, so the uncommitted work
# is never folded into the resolution — the precondition this check enforces is
# ESTABLISHED BY GIT ITSELF. It is supported on merge, rebase and pull and is
# switched on implicitly by `rebase.autoStash` / `pull.autoStash`, so denying it
# rejected the git-native spelling of the very remedy the deny message
# recommends. Only the affirmative form is exempt: `--no-autostash` does not
# qualify, so explicitly turning autostash OFF still faces the live check.
#
# r9: the exemption is decided from ARGUMENT TOKENS, not from a substring
# search over the joined segment. It used to be the latter, and rule 2 is the
# ONLY path that skips the live `git status` read — so any option VALUE
# containing the literal text of an exempt flag switched the whole check off.
# Executed on a dirty fixture: `git merge -m "wip --autostash later" feature`
# was ALLOWED, as were `git pull -m "after the --abort we retry" origin main`,
# a trailing `# finish the --continue later` comment, a branch called
# `feature--continue`, and `git rebase --skip-smudge main` (the old `\b` was
# satisfied by the following hyphen). None of those is an escape form; each is
# an ordinary history op on a dirty tree, which is precisely what rule 3 exists
# to refuse.
#
# r13: `--autostash` IS SPLIT OUT of this set. The paragraph above was wrong
# about untracked files and an external referee reproduced it — `git merge
# --autostash main` in a repo holding `?? note.txt` merged and left the
# untracked file exactly where it was, because `git stash` does not stash
# untracked files. So the affirmative `--autostash` no longer skips the tree
# read; it now takes a NARROWER allow (`_GIT_OP_AUTOSTASH`, applied in
# `dirty_tree_reason`): allowed only when `git status --porcelain` reports no
# `??` entry. The five ESCAPE flags below keep the unconditional allow, because
# they are how you get out of an in-progress operation and reading the tree
# cannot inform that.
GIT_OP_EXEMPT_TOKENS = frozenset(
    ("--abort", "--continue", "--skip", "--quit", "--edit-todo"))
_GIT_OP_AUTOSTASH = frozenset(("--autostash",))

# Options on a history op that take a SEPARATE value token. Their value must be
# SKIPPED before the exempt test, or the value gets read as a flag. Biased
# toward over-skipping on purpose: skipping one word too many can only cost a
# DENY (rule 3 runs), while skipping one too few is a false ALLOW.
_GIT_OP_VALUE_OPTS = frozenset((
    "-m", "--message", "-F", "--file", "--exec", "-x", "-s", "--strategy",
    "-X", "--strategy-option", "-S", "--gpg-sign", "--into-name", "--onto",
    "--log", "--depth", "--deepen", "--shallow-since", "--shallow-exclude",
    "--refmap", "--upload-pack", "--recurse-submodules", "-j", "--jobs",
))

GIT_HISTORY_OPS = {"merge", "rebase", "pull"}
_ASSIGN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")


def _prog(word: str) -> str:
    """The program a command word names, as Windows and a case-insensitive disk
    run it: the basename on EITHER separator, lower-cased, a trailing `.exe`
    dropped. `git.exe`, `GIT` and 'C:\\...\\cmd\\git.exe' are all `git` (r21)."""
    b = re.split(r"[\\/]", word)[-1].lower()
    return b[:-4] if b.endswith(".exe") else b


def _op_is_exempt(words: list[str], start: int, tokens=GIT_OP_EXEMPT_TOKENS) -> bool:
    """True only when an ACTUAL argument token of this invocation IS one of
    `tokens`. `start` is the index of the subcommand. The token set is a
    PARAMETER since r13, because the escape flags and `--autostash` no longer
    buy the same thing — see GIT_OP_EXEMPT_TOKENS."""
    i = start + 1
    while i < len(words):
        w = words[i]
        if w == "--":                       # end of options: refs only after
            return False
        if w in tokens:
            return True
        if w in _GIT_OP_VALUE_OPTS and i + 1 < len(words):
            i += 2                          # `-m <message>`: the value is DATA
            continue
        i += 1
    return False

# Tokenizer: split a Bash command into per-command segments on shell
# separators, keeping quoted spans intact so a separator inside quotes does not
# split a segment. `(`, `)` and backticks separate too (#172): without them
# `(git reset --hard)` read as the words `(git` … `--hard)`, was not recognised
# as git at all, and a subshell or `$(…)` / backtick substitution carried a
# destructive op past the deny list on a dirty tree.
_SEG_TOKEN = re.compile(
    r"""(?P<sep>\|\||&&|;|&|\||\n|\(|\)|`)
      | (?P<word>(?:"[^"]*"|'[^']*'|\\.|[^\s"'|;&\n()`])+)""",
    re.VERBOSE,
)
# r21: the Windows branch used to need `C:\\Users\\` with DOUBLED backslashes —
# the escaped spelling inside an R string — so Stata's native `cd "C:\Users\me"`,
# a Python raw string `r"C:\Users\me\x.csv"` and lower-case `c:/users/me` were
# never flagged; `C:/Users/me` was, but only by luck, through the `/Users/`
# branch. Measured 2026-09-27 on ae72617 with CLAUDE_STRICT_PATHS=1: the first
# three ALLOWED. One or more of either separator counts now, and `users` in any
# case — a SCOPED `(?i:...)`, because a global `(?i)` also flags
# `https://api.github.com/users/<name>` in ordinary .py code. The extension is
# compared lower-cased for the same reason: `a.rmd` and `MASTER.DO` skipped the
# check entirely while `a.Rmd` and `master.do` denied.
# The drive letter must not follow a letter or digit. Without that the scheme's
# last letter reads as a drive: `gs://users/data.csv`, `https://users/x` and
# `{"key:/users/me": 1}` matched as `s:`, `s:` and `y:` (measured on 9d90fc3, a
# deny under CLAUDE_STRICT_PATHS=1). A real drive follows a quote, a space, `(`,
# `=`, `\\?\` or `file:///`, none of which the lookbehind refuses.
HARDCODED_PATH = re.compile(r"(/Users/[^/\s'\")]+|/home/[^/\s'\")]+"
                            r"|(?<![A-Za-z0-9])[A-Za-z]:[\\/]+(?i:users)[\\/]+[^\\/\s'\")]+)")
CODE_EXT = {".r", ".qmd", ".do", ".py", ".rmd"}      # compared lower-cased


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
# `root-of-trust-guard.py` (its copy names the function `unquote`), for the same
# reason the heredoc walker is: that hook's import of this one is best-effort
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


def _unquote(w: str) -> str:
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
# Measured at 7b8848d against a throwaway fixture repo whose porcelain was
# ' M s.txt', line 2 of a two-line command carrying the real op: after
# `tr a-z A-Z <<< hello` this hook went SILENT on `git reset --hard HEAD~1`,
# `git clean -fd`, `git push --force origin main`, `git add -A` and a
# dirty-tree `git merge main`, and the sibling guard went SILENT on
# `rm -f .claude/hooks/git-guardrails.py` — every one of which DENIES when
# line 1 is `echo hi`, and bash runs line 2 in all of them. `_strip_heredocs`
# runs FIRST in both `git_deny_reason` and `dirty_tree_reason`, so this silenced
# the unconditional deny list AND the clean-tree precondition at once. Dropping
# REAL command text is a missed deny, the one direction a guard must not fail
# in.
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
# a shell COMMENT, while `_strip_heredocs` runs BEFORE the comment-aware
# `_segments` (`git_deny_reason` and `dirty_tree_reason` both call
# `_segments(_join_continuations(_strip_heredocs(cmd)))`). So an ORDINARY `#`
# comment that merely NAMES a heredoc opened one, and every following line was
# DELETED before anything was tokenised. This class was INTRODUCED by r16: its
# disclosed residual named exactly one surviving opener misread (the arithmetic
# shift below), and this was a second one, one character away from the quoted
# spelling r16 had just closed.
#
# Measured 2026-08-23 against throwaway fixtures (a project fixture holding
# `.claude/hooks/` and `.claude/settings.json`; a git fixture with one modified
# tracked file), line 2 carrying the real op. With line 1 =
# `# heredoc <<EOF` this hook went SILENT on `git reset --hard HEAD~1`, on a
# destructive `clean -fdx`, on a force push, on `git add -A` and on a
# dirty-tree `git merge main`, and the sibling guard went SILENT on
# `rm -f .claude/hooks/git-guardrails.py` and on a redirect into
# `.claude/settings.json`. With line 1 = an ordinary comment carrying no `<<`,
# every one of them DENIED. Executed, not simulated: `bash -c` on the two-line
# form left the guard file absent, so bash runs line 2 while the hook writes
# nothing — and a hook that writes nothing is what an allow looks like.
#
# THE RULE: an unquoted `#` that BEGINS a word — start of line, or preceded by
# whitespace or one of `;&|()` — ends the line for opener purposes. That is the
# same test `_segments` applies to raw words, so the two parsers stop
# disagreeing about what a comment is; the separator set here is deliberately a
# SUPERSET of `_SEG_TOKEN`'s, because erring toward "this is a comment" makes
# the scan stop EARLIER, find FEWER openers and drop LESS text — the safe
# direction, the same one the quote handling already fails toward. A `#` inside
# quotes is untouched (`echo '#'` still opens nothing), a `#` in mid-word is not
# a comment (`git log --format=%h#%s <<EOF` still opens one), and an unbalanced
# quote still drops NOTHING.
#
# Disclosed residual, unchanged by either fix: a `<<` in an arithmetic left-shift
# whose right operand is an identifier (`$(( x << n ))`) still reads as an
# opener and still drops the lines after it. Requiring the `<<` to sit in
# redirection position would close it and would also stop recognising the
# equally ordinary `cat<<EOF`, so it is disclosed rather than guessed at.
#
# THIS BLOCK IS DUPLICATED VERBATIM IN `root-of-trust-guard.py` (its copy names
# the function `strip_heredocs`). Duplicated, not imported: that hook's import
# of this one is best-effort and returns None on any failure, and a parser that
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


def _strip_heredocs(cmd: str) -> str:
    """Drop heredoc BODIES so a `git pull` that merely appears inside one is
    prose, not a command — the same posture as root-of-trust-guard."""
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


# A backslash-newline is a LINE CONTINUATION in POSIX shell: it JOINS the line,
# it does not end the command. `_SEG_TOKEN` lists `\n` in its `sep` alternation
# while its `word` alternation's escape class (`\\.`) cannot match backslash +
# newline — `.` excludes newline outside DOTALL — so a trailing `\` was consumed
# as an ordinary word character and the newline behind it ENDED the segment.
# Executed against the pre-fix guard on a dirty fixture (r11): `git clean \` +
# newline + `    -xfd` emitted no decision and, run through `bash -c`, deleted
# the untracked file; so did `git push \`+NL+`--force origin main`, `git reset \`
# +NL+`--hard HEAD~1`, `git add \`+NL+`-A`, `git checkout \`+NL+`-- .`, and
# `git \`+NL+`merge feature`. Every one-line spelling DENIED, so the verdict
# turned on where the author had put a newline. The continuation is now spliced
# the way the shell splices it, BEFORE anything is tokenised.
#
# The RUN of backslashes decides. `\\` is an ESCAPED backslash, so `\\` + newline
# is a literal backslash followed by a REAL separator, not a continuation: the
# even-run prefix is consumed and re-emitted, and only an ODD trailing backslash
# joins. A newline with no backslash before it still separates commands, and a
# literal `\` inside a quoted string (not followed by a newline) never matches.
_LINE_CONT = re.compile(r"(?<!\\)((?:\\\\)*)\\\n")


def _join_continuations(cmd: str) -> str:
    """Splice POSIX line continuations, so a command formatted across several
    lines is tokenised as the ONE command bash will actually run.

    THE REPLACEMENT IS EMPTY, NOT A SPACE (r20 fix), and the difference is a
    bypass. POSIX REMOVES a backslash-newline; it does not turn it into a word
    separator. Substituting a space is invisible where the continuation sits at
    a token boundary — which is every example r12 was written against, and why
    this stood — and DECISIVE where it sits inside a word, because a space there
    splits one word into two and the split halves match no rule.

    Measured at 727a66c on a dirty fixture repository, guard verdict then what
    bash makes of the same string: a continuation inside the SUBCOMMAND
    (`git re\\<newline>set --hard`) ALLOW(silent), inside the FLAG
    (`--ha\\<newline>rd`) ALLOW(silent), inside a force push
    (`--for\\<newline>ce`) ALLOW(silent), and inside the program word itself
    (`gi\\<newline>t`) ALLOW(silent) — while every literal twin DENIED, and
    `printf '%s' re\\<newline>set` prints the single word `reset`. So the guard
    read two words where bash reads one, and every destructive verb was
    spellable straight through the deny list.

    Found by the SIBLING hook's r20 audit: the identical substitution was fixed
    there first, and the same defect was sitting in this file. Two copies of one
    rule drifted apart in the direction neither author checked — which is the
    argument for the shared-helper routing this pair already uses for the deny
    list itself."""
    return _LINE_CONT.sub(r"\1", cmd)


def _drop_cr(cmd: str) -> str:
    """Remove every carriage return, as the MSYS bash of Git for Windows does
    before it splits words (r21).

    `_SEG_TOKEN` counts `\\r` as whitespace, so `git re<CR>set --hard` was
    three words here and matched no rule, while Git Bash — the shell Claude
    Code's Bash tool runs through on Windows — drops the CR and runs
    `git reset --hard`. The same held for a CR inside the program word and
    for a `\\<CR><LF>` continuation, which the continuation splice never saw.
    Unconditional: POSIX bash keeps a CR as an ordinary WORD character, never
    a separator, so dropping it can only join text the shell also treats as
    one word — a false deny at worst, on a command git would reject anyway."""
    return cmd.replace("\r", "")


def _segments(cmd: str) -> list[list[str]]:
    """Per-command segments as lists of unquoted words.

    A word whose RAW text begins with `#` starts a shell COMMENT: it and the
    words after it are not arguments, so they are dropped. The test is on the
    raw word, before `_unquote`, so a quoted `"#123 fix"` message stays an
    argument. r9: without this, `git pull origin main  # finish the --continue
    later` put an exempt TOKEN on the invocation and skipped the tree read."""
    segs: list[list[str]] = [[]]
    comment = False
    for m in _SEG_TOKEN.finditer(cmd):
        if m.group("sep") is not None:
            segs.append([])
            comment = False
            continue
        raw = m.group("word")
        if raw.startswith("#"):
            comment = True
        if not comment:
            segs[-1].append(_unquote(raw))
    return [s for s in segs if s]


# Shell RESERVED WORDS and grouping tokens that can stand in front of a command
# inside one segment. Until r9 a segment was tested for git by its FIRST word
# only, so every one of these hid the op completely: `if true; then git merge x;
# fi`, `( git merge x )`, `{ git merge x; }`, `for d in .; do git -C $d pull;
# done`, `while …; do git pull; …; done`, `else git rebase main`,
# `! git merge x`, `>/dev/null git merge x` — all executed SILENT on a dirty
# fixture while the byte-identical bare spelling DENIED.
_SHELL_HEAD_WORDS = frozenset((
    "if", "then", "elif", "else", "fi", "for", "while", "until", "do", "done",
    "case", "esac", "in", "select", "function", "time", "coproc",
    "!", "(", ")", "{", "}", "[[", "]]",
))
# `>f` `2>f` `>>f` `<f` `>&2` `<>f` … as a leading word, attached or bare.
_REDIR_HEAD = re.compile(r"^\d*(?:>>|>&|>\||<>|<&|>|<)")


def _strip_shell_head(words: list[str]) -> tuple[list[str], int]:
    """Drop leading shell SYNTAX so the command word itself can be seen.
    Returns the (possibly rewritten) word list and the index of the first word
    that is not shell syntax."""
    words = list(words)
    i = 0
    while i < len(words):
        w = words[i]
        if _ASSIGN.match(w) or w in _SHELL_HEAD_WORDS:
            i += 1
            continue
        bare = w.lstrip("({!")                 # `(git`, `{git`, `!git`
        if bare != w:
            if bare:
                words[i] = bare
                continue                       # re-test the rewritten word
            i += 1
            continue
        m = _REDIR_HEAD.match(w)
        if m:
            # a BARE operator carries its target in the next word (`> /dev/null`)
            i += 2 if m.end() == len(w) else 1
            continue
        if w.endswith(")") and "/" not in w:   # `*)` case label, `f()` definition
            i += 1
            continue
        break
    return words, i


# r13 — git's OTHER repository selectors. `-C` changes the working DIRECTORY;
# these change which REPOSITORY git operates on, with no `cd` and no `-C`. The
# referee reproduced native git honouring them: `git --git-dir=/tmp/B/.git
# --work-tree=/tmp/B merge feature`, launched from a clean /tmp/A, fast-forwarded
# B and left B's untracked file in place. The pre-r13 docstring claimed
# repository identity was "the event cwd, or a -C" — flatly wrong. They are not
# bound into the status query; a history op carrying one is DENIED (see
# `_standalone_violation`), which is the option the referee allowed for and the
# only one that cannot be wrong about a repository it never read.
_REPO_SELECTOR_GLOBALS = frozenset(
    ("--git-dir", "--work-tree", "--namespace", "--bare"))


def _walk_git_globals(words: list[str], i: int) -> tuple[int, list[str], list[str]]:
    """Consume git's GLOBAL options starting just after the `git` word. Returns
    (index of the subcommand — or len(words) if there is none, EVERY `-C` path
    in the order given, the REPOSITORY-SELECTOR globals seen).

    Only the value-taking names in `_GIT_GLOBAL_VALUE_OPTS` consume a second
    token; ANY other leading `-…` word is consumed as a one-token global. See
    that table for why enumerating which options exist was the defect.

    r15: this used to keep only the LAST `-C` and throw the rest away. git does
    not — git(1): "If multiple -C options are given, each subsequent
    non-absolute -C <path> is interpreted relative to the preceding -C <path>."
    Measured on git 2.50.1: from a clean checkout, `git -C <dirty> -C . rev-parse
    --show-toplevel` prints <dirty>, and so does `-C <dirty> -C sub`. Keeping
    the last one and resolving it against the EVENT cwd therefore read a
    DIFFERENT repository from the one git would operate on — and allowed when
    that one was clean. Every value is carried out now and folded by
    `_resolve_dash_c` the way git folds them."""
    dash_c: list[str] = []
    selectors: list[str] = []
    while i < len(words):
        w = words[i]
        if not w.startswith("-") or w == "--":
            break
        name = w.split("=", 1)[0]
        if name in _REPO_SELECTOR_GLOBALS and name not in selectors:
            selectors.append(name)
        if w == "-C" and i + 1 < len(words):
            dash_c.append(words[i + 1]); i += 2; continue
        if w.startswith("-C") and len(w) > 2 and "=" not in w:   # -Cdir
            dash_c.append(w[2:]); i += 1; continue
        if "=" in w:                                             # --opt=value
            i += 1; continue
        if w in _GIT_GLOBAL_VALUE_OPTS and i + 1 < len(words):
            i += 2; continue
        i += 1                                                   # any other global
    return i, dash_c, selectors


def _git_segment(words: list[str]) -> tuple[str | None, list[str], int, list[str], list[str]]:
    """If a segment invokes git, return (subcommand, EVERY `-C` path in order,
    subcommand index, the words the index refers to, repository-selector
    globals); else (None, [], -1, words, []).

    The word list is returned because `_strip_shell_head` REWRITES leading words
    (`(git` → `git`), so the index is meaningful only against the list this
    function actually walked. Both callers — the deny list and the clean-tree
    check — slice arguments with it, and neither may guess.

    Leading shell syntax is dropped first, then a `git` word is searched for
    ALONG the segment rather than tested at position 0 only. Searching forward
    also closes the r8-disclosed bare-COMMAND-WRAPPER residual (`timeout 300 git
    pull`, `nice git merge`, `nohup`, `command`, `env`) — at the stated cost
    that an UNQUOTED mention of a history op or a destructive op in another
    command now denies. A mention that survives quoting is a single WORD and is
    still silent, which is what the rule-1 control (c17) and the deny-list
    control (b13) pin.

    r19 — THE COMMAND WORD IS MATCHED CASE-INSENSITIVELY, UNCONDITIONALLY. This
    test was `== "git"`, and on a case-insensitive filesystem — APFS, the macOS
    default, and HFS+ before it — the uppercase spelling really runs git:
    `command -v GIT` resolves to /usr/bin/GIT here. Measured 2026-08-24 against
    a throwaway fixture repository whose porcelain read ' M f.txt',
    `GIT reset --hard HEAD` and `Git merge other` were ALLOWED (silent) while
    their lowercase twins DENIED. The fold is UNCONDITIONAL rather than probed
    from the filesystem, by the same ruling the r15 glob fix made: the verdict
    must not depend on what happens to exist at hook time. The cost is a false
    DENY on a case-SENSITIVE filesystem for a program genuinely named `GIT` that
    is not git — err toward denying, which is this file's standing direction.

    The SUBCOMMAND is deliberately NOT folded. git itself rejects a
    case-varied subcommand: measured on git 2.50.1 (Apple Git-155),
    `git STATUS --porcelain` and `git Status --porcelain` both exit 128
    ("fatal: cannot handle STATUS as a builtin") while `git status` exits 0. A
    spelling git refuses to run cannot reach the tree, so folding it would buy
    no coverage and would only add false denies.

    r21 — `.exe` AND A BACKSLASH PATH NAME THE SAME PROGRAM. On Windows, Git
    Bash starts `cmd\\git.exe` for `git.exe` exactly as for `git`, and a quoted
    'C:\\Program Files\\Git\\cmd\\git.exe' is one word posixpath never splits.
    Measured 2026-09-27 against ae72617: `git.exe reset --hard`, `GIT.EXE
    clean -fdx` and that quoted path + `reset --hard` were ALLOWED (silent)
    while `git reset --hard` DENIED. `_prog` reads the program either way, on
    every OS, by the same ruling as the case fold above."""
    words, i = _strip_shell_head(words)
    while i < len(words):
        if _prog(words[i]) == "git":
            j, dash_c, selectors = _walk_git_globals(words, i + 1)
            if j < len(words):
                return words[j], dash_c, j, words, selectors
            return None, [], -1, words, []
        i += 1
    return None, [], -1, words, []


def git_deny_reason(cmd: str) -> str | None:
    """The destructive-git deny list, decided over the SAME tokenised, unquoted
    segments the clean-tree check reads. Returns the deny message, or None."""
    # Heredoc bodies are dropped FIRST (they are line-oriented: joining a body
    # line that ends in `\` could hide the terminator), then continuations are
    # spliced, so a multi-line command is tokenised as the one command bash runs.
    # Carriage returns go before either, as Git Bash drops them (r21).
    for seg in _segments(_join_continuations(_strip_heredocs(_drop_cr(cmd)))):
        sub, _dash_c, at, words, _sel = _git_segment(seg)
        if sub is None:
            continue
        args = words[at + 1:]
        for name, predicate, reason, alt in GIT_DENY:
            if sub == name and predicate(args):
                return (f"{reason} {alt} "
                        f"(override: run it in a terminal yourself, outside Claude Code.)")
    return None


# ────────────────────────────────────────────────────────────────────────────
# DELETED IN r8, DELIBERATELY: `_STASH_VALUE_FLAGS`, `_STASH_REDIRTY`,
# `_STASH_NEUTRAL`, `_STASH_CLEANERS`, `_STASH_CLEAN_FLAGS`, `_stash_effect`,
# `_INERT_GIT_SUBS`, `_INERT_COMMANDS`, `_REDIRECTORS`,
# `_segment_writes_via_redirection`, `_segment_is_inert`, `_REPO_KEY_CACHE`,
# `_repo_key`, `_resolve_repo_key`, and the per-repository `cleaned` map.
#
# All of it existed for ONE purpose: to decide whether an earlier segment in
# the same command line had left the tree clean enough to license a later
# history op — i.e. to SIMULATE the shell. Rounds 4 through 8 each found one
# more dimension the simulation had not modelled (stash flags, stash
# subcommands, intervening segments, repository identity, output redirection,
# command substitution, `cd`, and untracked-after-stash). The leak lived in the
# complexity itself, so the complexity is gone: the guard now reads the tree
# live and refuses a dirty-tree history op unconditionally. Nothing here may be
# reintroduced without re-opening that hole.
# ────────────────────────────────────────────────────────────────────────────

def deny(reason: str) -> None:
    json.dump({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}, sys.stdout)


def _repo_neutral_env() -> dict:
    """The process environment with git's REPOSITORY-SCOPING variables removed.

    Found by /blast-radius (2026-08-23): this read passed `cwd=` and no `env=`.
    git EXPORTS its repository into every hook it runs — GIT_DIR,
    GIT_INDEX_FILE, GIT_WORK_TREE, GIT_COMMON_DIR, GIT_OBJECT_DIRECTORY,
    GIT_PREFIX, GIT_NAMESPACE and siblings — ABSOLUTE when the command came
    from a linked worktree. GIT_DIR overrides repository DISCOVERY, so `cwd=`
    was advisory: the guard answered about whatever repository the environment
    named rather than the directory it was ASKED about. That is a correctness
    hole in both directions — a dirty tree could read clean, and a clean tree
    could read dirty — and it silently invalidated the battery cases that
    exercise this function, which were satisfied by reading the session's own
    repository instead of their fixture (re-qualified after this fix; battery
    c27/c28 pin both directions).

    The strip is by PREFIX, not a fixed list, so a git version that adds one
    more repository-scoping variable cannot quietly re-open it. GIT_EXEC_PATH
    is kept: it locates git's own helper programs, not a repository.
    """
    return {k: v for k, v in os.environ.items()
            if not k.startswith("GIT_") or k == "GIT_EXEC_PATH"}


class _NotARepo:
    """Sentinel: git could not answer, and the directory is not a repository at
    all — the ONE benign cause of an unanswered status. Distinct from None,
    which now means the question was asked and went UNANSWERED (see r15)."""
    __slots__ = ()

    def __repr__(self) -> str:            # pragma: no cover - diagnostics only
        return "<not-a-repository>"


NOT_A_REPO = _NotARepo()

# ── r15: THE STATUS QUERY IS PINNED AGAINST CONFIGURATION ──────────────────
#
# `git status --porcelain` is not a fixed question: it honours repository and
# user CONFIGURATION, and two settings can make it report a dirty tree as
# empty. An external referee (2026-08-23) reproduced the first on git 2.50.1:
#
#   status.showUntrackedFiles=no   — the documented remedy for a slow status on
#     a large worktree. In a repo carrying an untracked `note.txt`:
#         git status --porcelain                      -> ''
#         git status --porcelain --untracked-files=normal -> '?? note.txt'
#     The guard read '' and ALLOWED both a plain `git merge` and a `--autostash`
#     one — reproducing verbatim the hole r13 narrowed `--autostash` to close,
#     since untracked files are the whole reason that narrowing exists.
#
#   diff.ignoreSubmodules=all (and submodule.<name>.ignore) — measured on the
#     same git: a host repo whose submodule holds modified work reports
#     ' M sub' by default, '' with the setting, and ' M sub' again with
#     `--ignore-submodules=none`. Same class, same direction, found by auditing
#     this call rather than by a referee.
#
# So the flags below are part of the QUESTION, not decoration: the reading a
# guard makes must not be reconfigurable by the thing it is guarding. Nothing
# else in either hook shells out to git — `root-of-trust-guard.py` is a purely
# textual scan — so this call is the whole of the exposure, and the GIT_*
# environment (`GIT_CONFIG_GLOBAL`, `GIT_CONFIG_COUNT`, `GIT_DIR`, …) is
# already stripped by `_repo_neutral_env()`.
#
# `--untracked-files=normal`, not `=all`: rule 2b asks whether ANY `??` entry
# exists, and `normal` already answers that (it collapses an untracked
# directory into one entry instead of listing its files, which is cheaper on a
# large tree and cannot change the emptiness of the answer).
_GIT_STATUS_CMD = ("git", "status", "--porcelain",
                   "--untracked-files=normal", "--ignore-submodules=none")

# THE INVARIANT (r16), and it is not a style preference:
#
#     the internal budget must be STRICTLY LESS than this hook's REGISTERED
#     timeout in .claude/settings.json, with margin for the rest of the hook's
#     work — BECAUSE A KILLED HOOK IS INDISTINGUISHABLE FROM AN ALLOW.
#
# A PreToolUse hook says "deny" by writing a decision to stdout. The harness
# kills it at its registered bound; a killed hook has written nothing, and
# nothing is what an allow looks like. So a deny branch that cannot RETURN
# inside the registration does not exist.
#
# That is what r15 shipped. `_STATUS_TIMEOUT_DEFAULT` was raised to 10 s so a
# slow worktree would not wedge a session, while the registration stayed at the
# 5 s it had been since before the branch. Measured at 7b8848d against a dirty
# fixture repo with a `git` shim that sleeps 30: run with no harness bound the
# hook took 10 s, exited 0, and emitted `"permissionDecision": "deny"`; run as
# the harness runs it, `timeout -s KILL 5`, it took 5 s, exited 137, and wrote
# ZERO BYTES. So on the exact case the r15 fix names — a large worktree on a
# cold cache, a network filesystem — the history op was ALLOWED over
# uncommitted work, and the deny message's own remedy (raise
# CLAUDE_GIT_STATUS_TIMEOUT) moved the user FURTHER from a deny.
#
# Both numbers now derive from `_HOOK_REGISTERED_TIMEOUT`, which states what
# .claude/settings.json registers, and `_status_timeout()` CLAMPS rather than
# honours: a caller who asks for 600 s gets the ceiling, not a killed hook.
# Battery case c54 fires this hook under the registered bound with a slow git
# and requires the deny to still come out; c55 pins the two numbers against
# settings.json itself, so raising one without the other goes red.
#
# At most ONE status is read per invocation — rule 0 refuses a history op that
# is not a standalone simple command BEFORE the tree is read — so the worst
# case really is one budget, not one per segment.
_HOOK_REGISTERED_TIMEOUT = 20.0   # MUST equal .claude/settings.json's "timeout"
_STATUS_TIMEOUT_MARGIN = 5.0      # json parse, tokenise, write the decision
_STATUS_TIMEOUT_CEILING = _HOOK_REGISTERED_TIMEOUT - _STATUS_TIMEOUT_MARGIN
_STATUS_TIMEOUT_DEFAULT = 10.0
_STATUS_TIMEOUT_ENV = "CLAUDE_GIT_STATUS_TIMEOUT"


def _status_timeout() -> float:
    """Seconds to wait for `git status`. Configurable because r15 made an
    UNREADABLE status a DENY: on a genuinely slow worktree the bound is the
    difference between a working guard and a blocked session, and 3 s (the old
    hardcoded value) is reachable on a cold cache over a network filesystem.

    r16: CLAMPED to `_STATUS_TIMEOUT_CEILING`. A bound at or above the
    registered timeout cannot produce a deny — the hook is killed first — so
    honouring one would turn the escape hatch into a silent allow."""
    v = _STATUS_TIMEOUT_DEFAULT
    try:
        env = float(os.environ.get(_STATUS_TIMEOUT_ENV, ""))
        if env > 0:
            v = env
    except (TypeError, ValueError):
        pass
    return min(v, _STATUS_TIMEOUT_CEILING)


def _within_git_repo(cwd: str | None) -> bool:
    """Is there a `.git` entry at `cwd` or above it? Answered from the
    FILESYSTEM, deliberately not by asking git again: the case this exists to
    classify is precisely the one where git could not answer, so a second git
    invocation would inherit the same failure and could be shimmed, broken or
    slow in the same way. A `.git` FILE (a linked worktree) counts, like a
    directory."""
    try:
        cur = os.path.realpath(cwd or os.getcwd())
    except OSError:
        return False
    try:
        while True:
            if os.path.exists(os.path.join(cur, ".git")):
                return True
            parent = os.path.dirname(cur)
            if parent == cur:
                return False
            cur = parent
    except OSError:
        return False


def read_status(cwd: str | None) -> "str | _NotARepo | None":
    """The RAW porcelain status text, or one of two DIFFERENT non-answers:

        str          — git answered; this is the tree state
        NOT_A_REPO   — git could not answer AND there is no repository here:
                       the one benign cause, which the caller may skip
        None         — the question went UNANSWERED (timeout, a non-zero exit
                       inside a real repository, git missing, any exception).
                       The caller must DENY on this; see r15 below.

    r13: this used to be `tree_is_dirty()`, returning a bool. The porcelain TEXT
    is needed now, because `--autostash` is allowed only when there is no `??`
    entry — a distinction a boolean cannot carry. Callers derive both answers
    from the one reading, so a single subprocess still answers the whole rule.

    r15: it used to return None for all three cases alike, and the caller
    treated that as "not a repository at all → git's problem" and CONTINUED —
    i.e. allowed. A `git status` that merely ran slowly was therefore a silent
    ALLOW on a dirty tree, which is the same "allowing on an unanswered
    question" the `-C` path was fixed for at r13 and this path was not. The two
    causes are now distinguished, and only the benign one allows."""
    try:
        # UTF-8, not the locale: on Windows the default is the ANSI code page,
        # which cannot decode every name git prints with core.quotePath=off,
        # and a decode error here is an unanswered question — a false deny.
        r = subprocess.run(list(_GIT_STATUS_CMD), cwd=cwd or None,
                           env=_repo_neutral_env(),
                           capture_output=True, text=True,
                           encoding="utf-8", errors="replace",
                           timeout=_status_timeout())
    except Exception:
        return None if _within_git_repo(cwd) else NOT_A_REPO
    if r.returncode != 0:
        return None if _within_git_repo(cwd) else NOT_A_REPO
    return r.stdout


def _untracked(status: str) -> list[str]:
    """The `??` lines of a porcelain status — the entries `git stash` (and
    therefore `--autostash`) leaves exactly where they are."""
    return [ln for ln in status.splitlines() if ln.startswith("??")]


DIRTY_TREE_REMEDY = (
    "Run the cleaning step and the history op as SEPARATE commands — this guard "
    "re-reads the real tree state on the second one, so `git stash push -u -m "
    "\"<what this is>\"` (or a commit) and THEN `git {op} ...` is allowed. "
    "Note the `-u`: a plain `git stash push` does NOT stash untracked files, so "
    "it can leave the tree dirty. Chaining the two in ONE command is refused on "
    "purpose: this guard reads the tree BEFORE the command runs, so a chain "
    "could dirty it again before git starts. "
    "(Override: ALLOW_DIRTY_MERGE=1 in the session environment.)"
)

STANDALONE_REMEDY = (
    "A history op is accepted only as a STANDALONE SIMPLE COMMAND, because this "
    "guard reads `git status` at PreToolUse — BEFORE bash runs anything — so a "
    "command line that can act before git starts (a chain, a pipeline, a "
    "redirection, a substitution, a `cd`, an assignment) makes that reading "
    "meaningless. Run `git {op} ...` on its own line, and whatever else the "
    "command was doing as a separate call. "
    "(Override: ALLOW_DIRTY_MERGE=1 in the session environment.)"
)

# ── rule 0: is this command line a STANDALONE SIMPLE COMMAND? ──────────────
#
# The shell syntax that disqualifies it, found OUTSIDE quotes. This is the ONE
# place in this file that reads raw command TEXT for structure rather than for
# words, and it is deliberately over-inclusive: every character below can put a
# write, a directory change, or another command between the reading and the op.
#
# Quote-awareness is the whole difficulty. `'...'` suppresses everything;
# `"..."` still expands `$(...)` and backticks but not `|`, `&`, `;`, `<`, `>`.
# A `#` at a word boundary starts a COMMENT, which `_segments` already drops, so
# the scan stops there rather than scoring the prose after it.
_CD_WORDS = frozenset(("cd", "chdir", "pushd", "popd"))


def _unquoted_shell_syntax(cmd: str) -> list[str]:
    """Shell syntax found outside quoting, in order of first appearance."""
    found: list[str] = []

    def add(tok: str) -> None:
        if tok not in found:
            found.append(tok)

    i, n, prev_ws = 0, len(cmd), True
    while i < n:
        c = cmd[i]
        if c == "\\":
            i += 2
            prev_ws = False
            continue
        if c == "'":                                   # single quotes: inert
            j = cmd.find("'", i + 1)
            i = n if j == -1 else j + 1
            prev_ws = False
            continue
        if c == '"':                                   # double quotes: $( ` live
            j = i + 1
            while j < n and cmd[j] != '"':
                if cmd[j] == "\\":
                    j += 2
                    continue
                if cmd[j] == "`":
                    add("`")
                elif cmd[j] == "$" and j + 1 < n and cmd[j + 1] == "(":
                    add("$(")
                j += 1
            i = n if j >= n else j + 1
            prev_ws = False
            continue
        if c == "#" and prev_ws:                       # a comment: stop scanning
            break
        if c == "$" and i + 1 < n and cmd[i + 1] == "(":
            add("$(")
            i += 2
            prev_ws = False
            continue
        if c in "<>" and i + 1 < n and cmd[i + 1] == "(":   # process substitution
            add(c + "(")
            i += 2
            prev_ws = False
            continue
        if c in "|&;<>()`":
            add(c)
            i += 1
            prev_ws = False
            continue
        prev_ws = c.isspace()
        i += 1
    return found


def _standalone_violation(spliced: str, n_segments: int,
                          words: list[str], at: int,
                          selectors: list[str]) -> str | None:
    """Why this command line is NOT a standalone simple history op, or None.

    `words`/`at` are the history-op segment's words and its subcommand index, as
    `_git_segment` returned them; `selectors` are its repository-selector git
    globals. The checks before the subcommand are where a wrapper, an assignment
    or a `cd` would sit; after it, a word is an argument (a branch may legally be
    called `cd`)."""
    if n_segments != 1:
        return ("the command line has more than one shell segment — a chain, a "
                "pipeline or a grouping runs before git does")
    syntax = _unquoted_shell_syntax(spliced)
    if syntax:
        return ("the command line carries unquoted shell syntax ("
                + " ".join(syntax) + ") — a redirection, a substitution or "
                "another command can write to the tree before git starts")
    for w in words[:max(at, 0)]:
        if w in _CD_WORDS:
            return (f"the command line contains `{w}`, which changes which "
                    "repository the op runs in — a directory this guard never read")
        m = _ASSIGN.match(w)
        if m:
            name = w.split("=", 1)[0]
            if name.startswith("GIT_"):
                return (f"the command line sets `{name}`, which selects a "
                        "DIFFERENT repository from the one this guard read "
                        "(git honours GIT_DIR / GIT_WORK_TREE with no -C and no cd)")
            return (f"the command line carries a variable assignment (`{name}=`), "
                    "which can change which repository git operates on and how")
    if selectors:
        return ("the invocation carries " + " ".join(f"`{s}`" for s in selectors)
                + ", which selects a DIFFERENT repository from the one this "
                "guard would read — git honours it with no -C and no cd")
    return None


_MSYS_DRIVE = re.compile(r"^/([A-Za-z])(?=/|$)")


def _resolve_dash_c(dash_c: list[str], default_cwd: str | None) -> str | None:
    """Fold EVERY `-C <path>` on the invocation, in order, the way git folds
    them — starting from the INVOCATION's directory.

    r9: the raw string was handed to `subprocess.run(cwd=…)`, which resolves a
    relative path against the HOOK PROCESS's cwd — not the event cwd the same
    function already treats as authoritative. With the two differing (the Bash
    tool's cwd drifts; hooks are spawned by the CLI process), `git -C . pull` in
    a dirty repo A was judged against whatever repo B the hook happened to sit
    in, and went SILENT — using the exact spelling the docstring recommends as
    the remedy for the `cd` residual.

    r15: the same defect one dimension over. Only the LAST `-C` reached here,
    and it was resolved against the event cwd — so a TRAILING RELATIVE `-C`
    discarded a leading absolute one, and `git -C <dirty> -C . merge feature`
    fired from a clean checkout read the CLEAN one and allowed, while git
    merged in the dirty one. git's own rule, quoted in `_walk_git_globals` and
    measured on 2.50.1, is a left-to-right fold: an ABSOLUTE value replaces the
    accumulator, a RELATIVE one is appended to it, and an EMPTY one is a no-op
    ("If <path> is present but empty … the current working directory is left
    unchanged").

    r18: THE FOLD IS KERNEL-FAITHFUL, NOT LEXICAL. The left-to-right rule above
    was right and the resolution under it was wrong: each step went through
    `os.path.normpath`, which pops a `..` off the path as WRITTEN, while git
    folds `-C` by `chdir()` and the kernel pops a `..` off the path RESOLVED —
    the physical parent of a symlink's TARGET, not of the link. The two diverge
    the moment a `..` follows a symlinked component, and this docstring's own
    claim ("the directory git will chdir into") was false there. Measured at
    e0c4cdb: from a CLEAN repo C holding a tracked symlink `link` -> D/sub,
    where D is a second repository whose porcelain reads ' M sub/f.txt',
    `git -C link/.. merge feature` resolved to C lexically and to D through the
    kernel. The guard read C, said nothing, and real bash then fast-forwarded D
    — leaving the uncommitted work sitting on top of merged history, which is
    exactly what the clean-tree rule exists to refuse. `-C ./link/..`,
    `-C link/../`, `-C link/../.` and the composed `-C . -C link/..` all reached
    the same false ALLOW, while the byte-equivalent `-C <D>` DENIED. So the
    verdict turned on whether the path was spelled through the symlink.

    CORRECTED at r19: this enumeration also listed the ATTACHED `-Clink/..`, and
    it could never have reached that false ALLOW, because git does not accept an
    attached `-C<path>` at all. Measured on the same git this file's other
    numbers come from (2.50.1, Apple Git-155): `git -C . status --porcelain`
    exits 0, `git -C. status --porcelain` exits 129 with "unknown option: -C.".
    Counting it inflated the demonstrated recall class by one spelling.
    `_walk_git_globals` still parses the attached form and battery case c60 still
    pins that it is denied — as a DEFENSIVE CONTROL over a spelling git itself
    rejects, not as a reproduction of the defect.

    WHY RESOLVING ON DISK IS ACCEPTABLE HERE, and what it costs. The sibling
    hook (`root-of-trust-guard.py`) deliberately resolves paths LEXICALLY: it
    judges paths that need not exist yet, so its verdict must not depend on what
    happens to be on disk at hook time. Its `_spellings()` walks TWO spellings
    and takes the union of denials — but they are the token AS WRITTEN and the
    token its `..` segments resolve to LEXICALLY. The KERNEL-resolved spelling,
    which is what this divergence is about, is in NEITHER (r19 correction: this
    paragraph used to claim the sibling "handles this same divergence", and it
    does not — it models `..`, not a symlinked component, and only its project-
    SCOPE half, `in_project`, touches the filesystem). Even the union it does
    take is not available here — this guard must pick ONE directory and read the
    tree in it, and a union of two readings is not a tree state. But the objection does not
    apply either: rule 3's whole verdict is already a live `git status` run IN
    this directory, so this branch depends on the filesystem at hook time by
    construction, and a `-C` naming a directory that does not exist cannot be a
    merge git will perform. The cost is the ordinary TOCTOU one the module
    docstring already discloses for concurrent writers: if the symlink is
    repointed between the hook and the exec, the reading was of the old target.
    `os.path.realpath` also falls back to a lexical fold for components that do
    not exist — there the resolved directory is not a repository, and the
    unresolvable-`-C` branch in `dirty_tree_reason` DENIES rather than allowing.

    r21: A GIT BASH DRIVE PATH IS READ AS GIT.EXE RECEIVES IT. MSYS converts
    `/c/Users/me/proj` to `C:/Users/me/proj` before it starts a native git.exe,
    but Windows Python reads `/c/...` as a path on the CURRENT drive (or, on
    3.13+, as relative to the event cwd) — `C:\\c\\Users\\...`, which does not
    exist. Measured 2026-09-27 under the ntpath simulation: `git -C /c/<repo>
    merge feature` on a CLEAN repo was DENIED as "names a repository this
    guard cannot resolve" while `-C C:/<repo>` allowed. A false deny, not a
    hole, but it refused ordinary Git Bash usage. Only on Windows: on POSIX
    `/c/...` is a real path. Other MSYS roots (`/tmp`, `/usr`) still fail
    closed; mapping those needs `cygpath`.

    Returns None when the fold cannot be anchored or cannot be computed; the
    caller must treat that as an unanswered question, never as the event cwd."""
    cur = default_cwd
    for raw in dash_c:
        if not raw:                          # `-C ""` — git leaves cwd alone
            continue
        p = os.path.expanduser(raw)
        if os.name == "nt":
            m = _MSYS_DRIVE.match(p)         # `/c/x` → `C:/x`, as MSYS hands it on
            if m:
                p = f"{m.group(1).upper()}:{p[m.end():] or '/'}"
        try:
            if os.path.isabs(p):
                cur = os.path.realpath(p)    # absolute: replaces what came before
                continue
            if not cur:
                return None                  # unanchored → caller DENIES
            cur = os.path.realpath(os.path.join(cur, p))
        except OSError:
            return None                      # unresolvable → caller DENIES
    return cur


def dirty_tree_reason(cmd: str, event: dict) -> str | None:
    if os.environ.get("ALLOW_DIRTY_MERGE", "") == "1":
        return None
    default_cwd = (event.get("cwd")
                   or os.environ.get("CLAUDE_PROJECT_DIR") or None)
    # One live reading per working directory this command line names. There is
    # NO state carried between segments — no clean marks, no stash effects, no
    # inertness. A segment is looked at for exactly one thing: is it a git
    # history op, and does it carry its own `-C`.
    seen: dict[str, "str | _NotARepo | None"] = {}

    def read(cwd: str | None) -> "str | _NotARepo | None":
        key = cwd or ""
        if key not in seen:
            seen[key] = read_status(cwd)
        return seen[key]

    # Heredoc bodies are dropped FIRST (they are line-oriented: joining a body
    # line that ends in `\` could hide the terminator), then continuations are
    # spliced, so a multi-line command is tokenised as the one command bash runs.
    # Carriage returns go before either, as Git Bash drops them (r21).
    spliced = _join_continuations(_strip_heredocs(_drop_cr(cmd)))
    segs = _segments(spliced)
    for seg in segs:
        sub, dash_c, at, words, selectors = _git_segment(seg)
        if sub not in GIT_HISTORY_OPS:
            continue                         # rule 1: not a history op → silent
        # Rule 0 (r13): STANDALONE OR NOTHING. Decided BEFORE the tree is read,
        # because on a non-standalone line the reading proves nothing — the
        # referee's `printf … >> analysis.R && git merge main` is clean here and
        # dirty when git runs. This also subsumes the `cd` residual and both
        # non-`-C` repository selectors.
        shape = _standalone_violation(spliced, len(segs), words, at, selectors)
        if shape:
            return (f"git {sub} is refused here: {shape}. "
                    + STANDALONE_REMEDY.format(op=sub))
        # Rule 2a: the ESCAPE forms need no tree at all — decided from actual
        # argument TOKENS, never from text anywhere in the segment.
        if _op_is_exempt(words, at):
            continue
        # Rule 3: read the tree, live, in the directory THIS invocation names.
        cwd = _resolve_dash_c(dash_c, default_cwd)
        # r18: an invocation that CARRIES a `-C` the fold could not anchor or
        # resolve must not fall through to `read(None)` — that reads the HOOK
        # PROCESS's own directory, which is the r9 defect one dimension over.
        # No reading is taken; the unresolvable-selector deny below is the answer.
        status = None if (dash_c and cwd is None) else read(cwd)
        if dash_c and not isinstance(status, str):
            # r13 (referee finding 2): an explicit selector that cannot be
            # resolved used to fall back to the EVENT cwd and allow if THAT was
            # clean — which is allowing on the unanswered question. It denies.
            spelling = " ".join(f"-C {p}" for p in dash_c)
            return (f"git {sub} names a repository this guard cannot resolve "
                    f"(`{spelling}`): the path does not exist, holds an "
                    f"unexpanded variable, or is not a git repository. Rerun the "
                    f"{sub} from that repository, or spell the path literally. "
                    f"Reading a DIFFERENT repository and allowing because it is "
                    f"clean would be allowing on an unanswered question. "
                    f"(Override: ALLOW_DIRTY_MERGE=1 in the session environment.)")
        if status is NOT_A_REPO:
            continue                         # not a repository at all → git's problem
        if status is None:
            # r15: THE UNANSWERED QUESTION, ON THE PATH WITH NO `-C`. This used
            # to fall into the `continue` above on the stated ground that the
            # only cause was "not a repository at all". It was not: `read_status`
            # returned None for a TIMEOUT and a non-zero exit as well, so a
            # `git status` that merely ran slowly — a large worktree on a cold
            # cache, a network filesystem — was a silent ALLOW of a history op
            # over uncommitted work. That is the same defect the `-C` branch
            # above was fixed for at r13 and this branch was not. The two causes
            # are separated in `read_status` now, and this one denies.
            return (f"git {sub} is refused here: this guard could not determine "
                    f"the tree state — `git status` did not answer in "
                    f"{_status_timeout():g}s, exited non-zero, or could not be "
                    f"run, in a directory that IS a git repository. An "
                    f"unanswered question is not an allow. Check `git status` "
                    f"yourself, or raise the bound with "
                    f"{_STATUS_TIMEOUT_ENV}=<seconds> in the session "
                    f"environment — capped at {_STATUS_TIMEOUT_CEILING:g}s, "
                    f"because this hook is registered with a "
                    f"{_HOOK_REGISTERED_TIMEOUT:g}s timeout and a hook killed "
                    f"before it answers is read as an ALLOW. "
                    f"(Override: ALLOW_DIRTY_MERGE=1 in the session environment.)")
        # Rule 2b (r13): `--autostash` is git's own stash-operate-restore, but
        # `git stash` does not stash UNTRACKED files — the referee reproduced a
        # `--autostash` merge leaving `?? note.txt` untouched. So it is allowed
        # only over tracked/staged dirt.
        if _op_is_exempt(words, at, _GIT_OP_AUTOSTASH):
            untracked = _untracked(status)
            if not untracked:
                continue
            return (f"git {sub} --autostash does NOT establish a clean tree here: "
                    f"`git status --porcelain` reports {len(untracked)} untracked "
                    f"entr{'y' if len(untracked) == 1 else 'ies'} "
                    f"({', '.join(u[3:] for u in untracked[:3])}"
                    f"{', …' if len(untracked) > 3 else ''}), and git's autostash "
                    f"does not stash untracked files — they stay in the tree "
                    f"through the {sub}. " + DIRTY_TREE_REMEDY.format(op=sub))
        if not status.strip():
            continue                         # clean → allow
        return (f"git {sub} must start from a clean tree — `git status --porcelain` is "
                f"non-empty, so this {sub} would resolve your uncommitted work together "
                f"with the incoming changes and leave no way to tell them apart. "
                + DIRTY_TREE_REMEDY.format(op=sub))
    return None


def main() -> int:
    # The event is read as BYTES and decoded as UTF-8, which is what Claude Code
    # writes. `json.load(sys.stdin)` decoded it with the Windows ANSI code page:
    # an accented project path came out as mojibake, the event cwd named a
    # directory that does not exist, and a merge over a dirty tree read as
    # "not a repository" and was allowed (r21).
    try:
        data = json.loads(sys.stdin.buffer.read().decode("utf-8", "replace"))
    except (json.JSONDecodeError, EOFError):
        return 0

    tool = data.get("tool_name", "")
    ti = data.get("tool_input", {}) or {}

    if tool == "Bash":
        cmd = ti.get("command", "") or ""
        denied = git_deny_reason(cmd)
        if denied:
            deny(f"Blocked by git-guardrails: {denied}")
            return 0
        dirty = dirty_tree_reason(cmd, data)
        if dirty:
            deny(f"Blocked by git-guardrails: {dirty}")
        return 0

    if tool in ("Write", "Edit", "MultiEdit"):
        fp = ti.get("file_path", "") or ""
        if Path(fp).suffix.lower() not in CODE_EXT:
            return 0
        # Collect every string that becomes file content: Write.content,
        # Edit.new_string, and EACH MultiEdit edit's new_string (a list).
        candidates = []
        for k in ("content", "new_string"):
            v = ti.get(k)
            if isinstance(v, str):
                candidates.append(v)
        for e in ti.get("edits", []) or []:
            v = (e or {}).get("new_string")
            if isinstance(v, str):
                candidates.append(v)
        for content in candidates:
            m = HARDCODED_PATH.search(content)
            if m:
                msg = (f"Hardcoded machine path '{m.group(0)}' in {Path(fp).name} "
                       f"breaks replication packages. Use here::here(), relative paths, "
                       f"or a config variable.")
                if os.environ.get("CLAUDE_STRICT_PATHS", "") == "1":
                    deny(f"Blocked (CLAUDE_STRICT_PATHS=1): {msg}")
                else:
                    sys.stderr.write(f"[git-guardrails] WARNING: {msg}\n")
                break  # one finding per call is enough
        return 0

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail open
