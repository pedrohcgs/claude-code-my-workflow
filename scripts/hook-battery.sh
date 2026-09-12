#!/usr/bin/env bash
# hook-battery.sh — prove the ACTIVE guard hooks still fire.
#
# A hook is the one gate nobody watches. It runs in a subprocess, its output is
# a decision the harness consumes, and when it stops working it stops working
# SILENTLY: no error, no red gate, just a session that behaves as though the
# hook had nothing to say. `check-ledger-coverage.py` proves each hook is WIRED
# to a file that exists. This battery proves the file still DOES something —
# it re-seeds each guard's target failure on every run and checks that the
# guard goes red on it, and stays quiet on a clean control.
#
# Covered (the three guards that make a DECISION; the passive convenience hooks
# are listed as visible debt in quality_reports/qualification/LEDGER.md):
#
#   root-of-trust-guard.py   shell write into the repo's root of trust
#   git-guardrails.py        destructive git + the clean-tree precondition
#   claim-reconcile.py       numeric claims that a just-edited file can stale
#
# Every fixture is built under a mktemp directory that is removed on exit; the
# real .claude/ tree is never written to, and the throwaway git repository is
# created inside the temp directory, never the repo under test.
#
# ISOLATION IS NOT `git -C`. This battery runs inside `.githooks/pre-commit`,
# and git EXPORTS its repository into a hook's environment: GIT_DIR,
# GIT_INDEX_FILE, GIT_WORK_TREE, GIT_COMMON_DIR, GIT_OBJECT_DIRECTORY,
# GIT_PREFIX, GIT_NAMESPACE and siblings. GIT_DIR overrides repository
# DISCOVERY; `-C` only changes the working directory. From a LINKED WORKTREE
# those variables are ABSOLUTE, so the fixture's `init`/`add`/`commit` operated
# on the USER'S repository — writing a junk `seed` commit onto their branch,
# leaving a phantom deletion in their tree, and aborting the commit that
# triggered the hook. (Found by /blast-radius, 2026-08-23; reproduced end to
# end from a linked worktree of a fresh clone.) The whole GIT_* namespace is
# therefore stripped below before any fixture is built, and cases e1-e3 pin it.
#
# HOOK_DIR overrides which hook directory is exercised. That is how the battery
# itself is qualified: point it at a stub guard that always allows and it must
# go red, because a battery that cannot fail is decoration.
#
# Exit 0 = every case passed. Exit 1 = at least one case failed (named on
# stdout). Exit 2 = the battery could not run, which is a failure, not a pass.
set -uo pipefail

# ── strip the inherited git environment (see header) ───────────────────────
# Prefix-based, not a fixed list: a git version that adds one more
# repository-scoping variable must not silently re-open the hole. Only
# GIT_EXEC_PATH is kept — it locates git's own helper programs, not a
# repository. Names are listed here for grep-ability, but the loop is what
# enforces it: GIT_DIR GIT_INDEX_FILE GIT_WORK_TREE GIT_COMMON_DIR
# GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_PREFIX
# GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM
# GIT_GRAFT_FILE GIT_ATTR_SOURCE GIT_CONFIG_* GIT_INDEX_VERSION.
for _gv in ${!GIT_@}; do
    [ "$_gv" = "GIT_EXEC_PATH" ] && continue
    unset "$_gv"
done
unset _gv
# The same names, spelled for `env -u` in fire()/fire_in() below. The strip
# above already covers every child, so this is the second, explicit layer: it
# survives someone re-exporting one of these mid-script.
UNSET_GIT_ENV=(-u GIT_DIR -u GIT_INDEX_FILE -u GIT_WORK_TREE -u GIT_COMMON_DIR
               -u GIT_OBJECT_DIRECTORY -u GIT_ALTERNATE_OBJECT_DIRECTORIES
               -u GIT_PREFIX -u GIT_NAMESPACE -u GIT_CEILING_DIRECTORIES
               -u GIT_DISCOVERY_ACROSS_FILESYSTEM -u GIT_GRAFT_FILE
               -u GIT_ATTR_SOURCE -u GIT_INDEX_VERSION)

DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ -z "${DIR:-}" ] || [ ! -d "$DIR" ]; then
    echo "hook-battery: cannot resolve script directory" >&2; exit 2
fi
ROOT="$(cd "$DIR/.." && pwd)"
HOOKS="${HOOK_DIR:-$ROOT/.claude/hooks}"
SELF_PATH="$DIR/$(basename "$0")"   # absolute; cases e1-e3 re-enter this script

for h in root-of-trust-guard.py git-guardrails.py claim-reconcile.py; do
    if [ ! -f "$HOOKS/$h" ]; then
        echo "hook-battery: CANNOT RUN — $HOOKS/$h does not exist" >&2
        echo "  A battery that could not run is not a passing battery." >&2
        exit 2
    fi
done
if ! command -v git >/dev/null 2>&1; then
    echo "hook-battery: CANNOT RUN — git is not on PATH (cases c1-c3 need a throwaway repo)" >&2
    exit 2
fi
if ! command -v python3 >/dev/null 2>&1; then
    echo "hook-battery: CANNOT RUN — python3 is not on PATH (every case invokes it)" >&2
    echo "  A battery that could not run is not a passing battery." >&2
    exit 2
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/hook-battery.XXXXXX")" || exit 2
trap 'rm -rf "$TMP"' EXIT INT TERM

# ── Windows: the harness sends NATIVE paths in the event JSON ──────────────
# Under Git Bash the fixtures are built at POSIX paths (/tmp/..., /c/...), but
# the hooks run under a NATIVE python3, for which "/tmp/hook-battery.X/repo" is
# not a directory at all. A guard asked about a path it cannot resolve fails
# OPEN, so every fixture reads as clean and the battery reports the guards
# silent when the shipped guards are in fact firing correctly — measured on
# Windows 11 / Git Bash, where 30 of 234 cases failed this way while the same
# events with native paths denied exactly as specified.
#
# Real Claude Code always sends the native spelling (C:/Users/...), so
# rewriting the event's paths is what makes the battery measure the behaviour
# that actually ships. cygpath -m yields forward slashes, which need no JSON
# escaping. On POSIX cygpath is absent and _ev is an exact no-op.
if command -v cygpath >/dev/null 2>&1; then
    _TMP_NATIVE="$(cygpath -m "$TMP")"
    _ROOT_NATIVE="$(cygpath -m "$ROOT")"
    _ev() {
        sed -e "s|$TMP|$_TMP_NATIVE|g" -e "s|$ROOT|$_ROOT_NATIVE|g" "$1" > "$1.native"
        printf '%s' "$1.native"
    }
else
    _ev() { printf '%s' "$1"; }
fi

# ── --fixture-selftest: the child half of cases e1-e3 ──────────────────────
# Cases e1-e3 re-enter THIS script with git's hook environment deliberately
# exported at a decoy repository, and check that the fixture build lands in the
# fixture. It has to be a re-entry rather than an inline subshell: the defect
# was that the strip above did not exist, so the only honest way to exercise it
# is to run the real top-of-script path in a contaminated environment. Builds
# one fixture repo, commits in it, prints its HEAD, exits.
if [ "${1:-}" = "--fixture-selftest" ]; then
    SELF="$TMP/selftest-repo"
    mkdir -p "$SELF" || exit 2
    git -C "$SELF" init -q >/dev/null 2>&1
    : > "$SELF/untracked.txt"
    git -C "$SELF" add untracked.txt >/dev/null 2>&1
    git -C "$SELF" -c commit.gpgsign=false -c tag.gpgsign=false \
        -c user.email=battery@example.invalid -c user.name=hook-battery \
        commit -q -m "seed" >/dev/null 2>&1
    if [ -n "$(git -C "$SELF" status --porcelain 2>/dev/null)" ]; then
        echo "selftest-fixture-not-clean"; exit 1
    fi
    git -C "$SELF" rev-parse HEAD 2>/dev/null || { echo "selftest-no-head"; exit 1; }
    exit 0
fi

PASS=0; FAIL=0; FAILED=()
ok() { PASS=$((PASS + 1)); printf '  PASS  %s\n' "$1"; }
no() { FAIL=$((FAIL + 1)); FAILED+=("$1"); printf '  FAIL  %s\n        %s\n' "$1" "$2"; }

OUT=""; RC=0
fire() {  # fire <hook-file> <event-json> [VAR=VAL ...]  -> sets OUT, RC
    # The GIT_* strip is repeated here (it is already done process-wide) because
    # a CASE may deliberately re-export one — c27/c28 do, to prove the guard
    # reads the directory it was ASKED about. `env` applies -u first and the
    # trailing VAR=VAL assignments second, so a case that wants one back gets it.
    local hook="$1" ev="$2"; shift 2
    OUT="$(env -u ALLOW_ROOT_OF_TRUST_WRITE -u ALLOW_DIRTY_MERGE -u CLAUDE_STRICT_PATHS \
           "${UNSET_GIT_ENV[@]}" "$@" python3 "$HOOKS/$hook" < "$(_ev "$ev")" 2>/dev/null)"
    RC=$?
}
fire_in() {  # fire_in <hook-process-cwd> <hook-file> <event-json> -> sets OUT, RC
    # The hook PROCESS's working directory is not the event's `cwd`: hooks are
    # spawned by the CLI process while the Bash tool's directory drifts. Case
    # c25 needs the two to DIFFER, so it runs the guard from somewhere else.
    local dir="$1" hook="$2" ev="$3"
    OUT="$(cd "$dir" && env -u ALLOW_ROOT_OF_TRUST_WRITE -u ALLOW_DIRTY_MERGE \
           -u CLAUDE_STRICT_PATHS "${UNSET_GIT_ENV[@]}" \
           python3 "$HOOKS/$hook" < "$(_ev "$ev")" 2>/dev/null)"
    RC=$?
}

fire_from() {  # fire_from <hook-dir> <hook-file> <event-json> -> sets OUT, RC
    # Like fire(), but the hook DIRECTORY is given per call instead of taken
    # from $HOOKS. Cases a103-a107 need a guard whose SIBLING is a stub, and the
    # sibling is located from the guard file's OWN directory — so the only way to
    # pair one with the other is to run a copy of the guard out of a directory
    # built for the case. The copy is always taken from $HOOKS, so a seeded
    # HOOK_DIR still reaches these cases.
    local dir="$1" hook="$2" ev="$3"
    OUT="$(env -u ALLOW_ROOT_OF_TRUST_WRITE -u ALLOW_DIRTY_MERGE -u CLAUDE_STRICT_PATHS \
           "${UNSET_GIT_ENV[@]}" python3 "$dir/$hook" < "$(_ev "$ev")" 2>/dev/null)"
    RC=$?
}

verdict() {  # verdict <text> — hand a LOCALLY computed result to the expect_
             # helpers, so a case that does not fire a hook (section (e), which
             # tests the battery's own isolation) is still counted and reported
             # through the same three helpers as every other case.
    OUT="$1"; RC=0
}

expect_deny() {     # the guard must refuse
    if [ "$RC" -ne 0 ]; then no "$1" "hook exited $RC (a PreToolUse guard must exit 0)"; return; fi
    case "$OUT" in
        *'"permissionDecision": "deny"'*) ok "$1" ;;
        *) no "$1" "no deny decision emitted — stdout was: ${OUT:-<empty>}" ;;
    esac
}
expect_silent() {   # the clean control: allowed, and nothing said
    if [ "$RC" -ne 0 ]; then no "$1" "hook exited $RC (expected 0 — hooks fail open)"; return; fi
    if [ -n "$OUT" ]; then no "$1" "expected silence, got: $OUT"; else ok "$1"; fi
}
expect_contains() { # expect_contains <name> <substring>
    if [ "$RC" -ne 0 ]; then no "$1" "hook exited $RC (expected 0)"; return; fi
    case "$OUT" in
        *"$2"*) ok "$1" ;;
        *) no "$1" "expected substring '$2' — stdout was: ${OUT:-<empty>}" ;;
    esac
}

echo "hook-battery: do the active guard hooks still fire?"
echo "  hooks under test: $HOOKS"

# ── (a) root-of-trust-guard ────────────────────────────────────────────────
# The guard's whole job is the SILENT path: a shell one-liner that rewrites the
# files deciding whether any other gate runs. Seed one; then three controls.
echo ""
echo "  (a) root-of-trust-guard.py"

cat > "$TMP/a1.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"printf disabled | tee .claude//settings.json"}}
EOF
cat > "$TMP/a2.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"cat .claude/settings.json | head -20"}}
EOF
printf '%s\n' 'this is not json at all {' > "$TMP/a3.json"

fire root-of-trust-guard.py "$TMP/a1.json"
expect_deny   "a1 shell write into the root of trust is denied"
fire root-of-trust-guard.py "$TMP/a2.json"
expect_silent "a2 clean control: reading the same file is allowed"
fire root-of-trust-guard.py "$TMP/a3.json"
expect_silent "a3 malformed event fails OPEN (exit 0, no decision)"
fire root-of-trust-guard.py "$TMP/a1.json" ALLOW_ROOT_OF_TRUST_WRITE=1
expect_silent "a4 documented escape hatch actually disarms the guard"

# a5/a6: a redirection wrapped in `bash -c '...'` (the -c payload is unwrapped
# and re-scanned) and a `find ... -delete` of a hook dir — both were bypasses
# before this fix, so they are pinned as regression cases here.
cat > "$TMP/a5.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -c 'printf disabled > .claude/settings.json'"}}
EOF
cat > "$TMP/a6.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"find .claude/hooks -name '*.py' -delete"}}
EOF
fire root-of-trust-guard.py "$TMP/a5.json"
expect_deny   "a5 redirection wrapped in bash -c is unwrapped and denied"
fire root-of-trust-guard.py "$TMP/a6.json"
expect_deny   "a6 find -delete of a hook directory is denied"

# a7: a pure echo that merely DOCUMENTS a redirection into a protected path,
# inside a quoted string, writes nothing and must be ALLOWED. The backstop scans
# a quote-stripped copy, so the redirect-mention inside quotes is prose, not a
# command-line redirect. (Regression: the round-1 fix over-matched this.)
cat > "$TMP/a7.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"echo \"to reset a wedged hook: printf '{}' > .claude/settings.json\""}}
EOF
fire root-of-trust-guard.py "$TMP/a7.json"
expect_silent "a7 quoted echo documenting a protected redirection is allowed"

# a8: a command WRAPPER carrying its own option flag (`env -i`, `nice -n N`,
# `sudo -u X`) must be skipped ALONG WITH its options so the real shell/deleter
# behind it is reached. Before this fix the loop halted on the first flag, so
# `env -i bash -c '<redirect>'` and `nice rm <protected>` both bypassed the
# guard entirely. Pinned as a regression case so the gap cannot silently regrow.
cat > "$TMP/a8.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"env -i bash -c 'printf disabled > .claude/settings.json'"}}
EOF
cat > "$TMP/a9.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"nice rm .claude/hooks/git-guardrails.py"}}
EOF
fire root-of-trust-guard.py "$TMP/a8.json"
expect_deny   "a8 flag-carrying wrapper (env -i bash -c) is unwrapped past its flags and denied"
fire root-of-trust-guard.py "$TMP/a9.json"
expect_deny   "a9 bare wrapper deleter (nice rm) reaches the real command and is denied"

# a10: `env -S '<payload>'` / `env --split-string='<payload>'` makes env SPLIT
# the string into words and EXECUTE them — a command-payload carrier exactly
# like a shell `-c`, not an opaque value. Before this fix -S sat in env's
# arg-opts and its value was skipped whole, letting a redirect/deleter of a
# protected path through. Pinned so the split-string bypass cannot regrow.
cat > "$TMP/a10.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"env -S 'printf disabled > .claude/settings.json'"}}
EOF
fire root-of-trust-guard.py "$TMP/a10.json"
expect_deny   "a10 env -S split-string carrying a redirect is unwrapped and denied"

# a11/a12: env -S reached THROUGH a command wrapper (`nice env -S …`) and the
# bundled short-flag form (`env -vS …`). Before this fix env_split_payload located
# `env` with its own assignment-only scanner, so a wrapper in front of env hid it
# and the `^-S`-anchored match missed a bundled `-vS` — both silently ALLOWED a
# protected-path write inside the split string. env is now located through the
# same skip_wrappers the rest of the guard uses, and any short-flag group ending
# in S is treated as the split-string carrier. Pinned so neither bypass regrows.
cat > "$TMP/a11.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"nice -n 10 env -S 'printf disabled > .claude/settings.json' true"}}
EOF
cat > "$TMP/a12.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"env -vS 'printf disabled > .claude/settings.json' true"}}
EOF
fire root-of-trust-guard.py "$TMP/a11.json"
expect_deny   "a11 wrapper-chained env -S (nice env -S <redirect>) is located past the wrapper and denied"
fire root-of-trust-guard.py "$TMP/a12.json"
expect_deny   "a12 bundled short-flag env -vS <redirect> is recognized as a split-string carrier and denied"

# a13/a14: the shell's OWN options. shell_c_payload used to spot `-c` with the
# loose test `w.startswith("-") and "c" in w`, so a VALUE-TAKING long option that
# merely contains the letter c — `bash --rcfile <file> -c '<payload>'` — set the
# -c flag on `--rcfile` and returned <file> as the payload; the real payload was
# never re-scanned and its deleter passed SILENTLY. That failed toward MISSING
# the write, the one direction this guard must never fail in. Options are now
# parsed: long options never count as -c, `--rcfile`/`--init-file`/`-o` are
# consumed WITH their values, and only a `c` inside a single-dash short group is
# the real flag. a14 pins the bundled form, which must keep working.
cat > "$TMP/a13.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash --rcfile /tmp/x -c 'rm .claude/hooks/git-guardrails.py'"}}
EOF
cat > "$TMP/a14.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -ic 'rm .claude/hooks/git-guardrails.py'"}}
EOF
fire root-of-trust-guard.py "$TMP/a13.json"
expect_deny   "a13 value-taking shell option (bash --rcfile <f> -c <deleter>) no longer hides the real -c payload"
fire root-of-trust-guard.py "$TMP/a14.json"
expect_deny   "a14 bundled short-flag shell (bash -ic <deleter>) is still recognised as a -c carrier"

# a15: the control for that parser. Consuming `--rcfile`'s value must not start
# DENYING the ordinary case — a shell option parser that over-matches would make
# every `bash --rcfile <f> -c '<harmless>'` unusable, which is the failure mode
# the guard's own "when a command is ambiguous, ALLOW it" rule forbids.
cat > "$TMP/a15.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash --rcfile /tmp/x -c 'ls -la'"}}
EOF
fire root-of-trust-guard.py "$TMP/a15.json"
expect_silent "a15 clean control: the same shell options carrying a HARMLESS payload stay allowed"

# a16-a22: GIT'S OWN working-tree writers. The writer tables named cp/mv/rm/ln/
# sed -i/dd/find/tar but never git, so `git checkout HEAD~1 -- .claude/settings.json`
# restored the root of trust from an arbitrary revision — wiping every hook
# registration — through a plain shell one-liner with the protected path sitting
# there as a literal argument, while the semantically identical `cp`/`rm`
# spelling was DENIED. That is not the disclosed residual (interpreters,
# pipe-fed deleters, unknown wrappers): the command is known, the path literal,
# the write direct. Each writer is pinned here, including the `-C <protected>`
# form where the subcommand writes INSIDE the protected directory without ever
# naming a file in it.
cat > "$TMP/a16.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git checkout HEAD~1 -- .claude/settings.json"}}
EOF
cat > "$TMP/a17.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git restore .claude/hooks/git-guardrails.py"}}
EOF
cat > "$TMP/a18.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git rm .claude/hooks/git-guardrails.py"}}
EOF
cat > "$TMP/a19.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git clean -fd .claude/hooks"}}
EOF
cat > "$TMP/a20.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git stash push -m wip -- .claude/hooks/git-guardrails.py"}}
EOF
cat > "$TMP/a21.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git mv .claude/hooks/git-guardrails.py /tmp/parked.py"}}
EOF
cat > "$TMP/a22.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git -C .claude/hooks clean -fd"}}
EOF
fire root-of-trust-guard.py "$TMP/a16.json"
expect_deny   "a16 git checkout <rev> -- <protected> is a working-tree write and is denied"
fire root-of-trust-guard.py "$TMP/a17.json"
expect_deny   "a17 git restore <protected> is a working-tree write and is denied"
fire root-of-trust-guard.py "$TMP/a18.json"
expect_deny   "a18 git rm <protected> is denied (git deletes as surely as rm)"
fire root-of-trust-guard.py "$TMP/a19.json"
expect_deny   "a19 git clean -fd <protected dir> is denied (it deletes the hooks)"
fire root-of-trust-guard.py "$TMP/a20.json"
expect_deny   "a20 git stash push -- <protected> is denied (stashing a hook away disables it); the -m message value is not misread as a path"
fire root-of-trust-guard.py "$TMP/a21.json"
expect_deny   "a21 git mv <protected> <elsewhere> is denied (moving a hook away disables it)"
fire root-of-trust-guard.py "$TMP/a22.json"
expect_deny   "a22 git -C <protected dir> clean -fd is denied (the writer's working directory IS the protected path)"

# a23/a24: the controls for that table. Adding git as a writer must NOT start
# denying READ-ONLY git against the same paths — inspecting the root of trust is
# explicitly allowed ("every READ"), and a guard that blocks `git log` on its own
# hooks would violate the "when a command is ambiguous, ALLOW it" rule the same
# way an over-matching parser would.
cat > "$TMP/a23.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git log --oneline -- .claude/settings.json"}}
EOF
cat > "$TMP/a24.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git status --porcelain .claude/hooks"}}
EOF
fire root-of-trust-guard.py "$TMP/a23.json"
expect_silent "a23 clean control: read-only git (git log -- <protected>) stays allowed"
fire root-of-trust-guard.py "$TMP/a24.json"
expect_silent "a24 clean control: read-only git (git status <protected>) stays allowed"

# a25/a26: SCOPE — THIS project, not the pattern wherever it appears on the
# machine. `is_protected()` matched path TEXT with no repository anchoring, so
# the guard denied writes into ANY tree containing `.claude/hooks` or
# `.githooks`: a throwaway fixture clone, a second checkout, the user's own
# ~/.claude — while its deny message asserted the path was "part of THIS
# repository's root of trust". It bought no protection (this repo's gates are
# not in those trees) and it BLOCKED the qualification ledger's own gate-9
# reproduction, whose seeded defect is a mistyped hook path written into a
# fixture clone's settings.json. A path now counts only when it resolves inside
# the project (CLAUDE_PROJECT_DIR → the repo the call runs in → the repo this
# hook ships in); if none resolves, the guard falls back to the text match and
# says so. a25 pins that the real project path is still denied when the event
# carries an explicit cwd; a26 pins that the fixture-clone write is allowed.
mkdir -p "$TMP/rot-clone/.claude/hooks" "$TMP/rot-clone/.githooks"
printf '{}\n' > "$TMP/rot-clone/.claude/settings.json"
cat > "$TMP/a25.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf disabled > .claude/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a26.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"sed -i '' 's/notify.sh/notifyy.sh/' $TMP/rot-clone/.claude/settings.json"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a25.json"
expect_deny   "a25 a write into THIS project's root of trust is denied when the event names its cwd"
fire root-of-trust-guard.py "$TMP/a26.json"
expect_silent "a26 the same write into a fixture clone OUTSIDE the project is allowed (the ledger's gate-9 reproduction)"

# a27-a30 (r12): BACKSLASH-NEWLINE LINE CONTINUATION. `_TOKEN` listed `\n` as a
# separator while its word class could not consume backslash+newline, so an
# ordinary multi-line command was read as TWO segments and the half carrying the
# protected path was never scored. Executed against the pre-fix guard: a `rm -f`
# whose operand sat on the continued line emitted NO decision, and the same
# string through `bash -c` really deleted `.claude/hooks/git-guardrails.py`;
# continued `cp`/`mv`/redirection into `settings.json` were silent too, while
# every one-line spelling DENIED — the guarantee turned on where the author had
# put a newline. Continuations are now spliced before tokenising. The two
# controls are the other direction, and neither is padding:
#   a29 — a REAL newline with no backslash must still SEPARATE commands, so a
#         later READ is not folded into an earlier deleter's argument list.
#   a30 — an ESCAPED backslash (a literal `\` argument) before a real newline is
#         NOT a continuation. A naive `\\\n -> " "` join splices here and turns
#         a29's shape into a false DENY; the fix consumes even backslash runs
#         first, so only an odd trailing backslash joins.
#
# The JSON spellings these four turn on, defined once because the escaping is
# where such a fixture goes quietly wrong: a JSON string carries a backslash as
# `\\` and a newline as `\n`.
JCONT='\\\n'      # `\` + newline  — a POSIX LINE CONTINUATION (joins the line)
JNL='\n'          # a bare newline — an ordinary command SEPARATOR
JBSNL='\\\\\n'    # `\\` + newline — a literal backslash, then a separator
cat > "$TMP/a27.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f ${JCONT}    .claude/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a28.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf disabled > ${JCONT}    .claude/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a29.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f /tmp/hook-battery-no-such-file${JNL}cat .claude/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a30.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f /tmp/hook-battery-no-such-file${JBSNL}cat .claude/settings.json"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a27.json"
expect_deny   "a27 r12: a DELETE of a protected path written across a LINE CONTINUATION is denied (this exact spelling went silent and really removed the guard file)"
fire root-of-trust-guard.py "$TMP/a28.json"
expect_deny   "a28 r12: a REDIRECTION into settings.json across a line continuation is denied (the quote-stripped backstop sees the joined line too)"
fire root-of-trust-guard.py "$TMP/a29.json"
expect_silent "a29 r12 control: a GENUINE newline still separates commands — a following read is not folded into the preceding rm's arguments"
fire root-of-trust-guard.py "$TMP/a30.json"
expect_silent "a30 r12 control: an ESCAPED backslash before a real newline is a literal backslash, not a continuation — the newline still separates (a naive backslash-newline join would false-deny here)"

# a31-a42 (r14): THE CROSS-HOOK PATH — this is why a git op appears in the
# ROOT-OF-TRUST section, which otherwise has nothing to say about git history.
# Two guards split the work between them, and each was correct about its own
# half: root-of-trust-guard.py UNWRAPS command payloads (`bash -c '...'`,
# `env -S '...'`) and judges PATH writes; git-guardrails.py judges DESTRUCTIVE
# GIT but treats a `-c` payload as opaque and does not unwrap it. A payload
# carrying a destructive git verb and NO protected path therefore fell BETWEEN
# them: this hook unwrapped it, found no protected path, and returned 0; the
# sibling never saw the verb at all. `bash -c 'git reset --hard'` and
# `bash -c 'git clean -fdx'` RAN — the second removing untracked and ignored
# files, which is research data no reflog holds. A shell wrapper is how a
# script, a Makefile, or a generated command line ordinarily spells things, so
# "a determined caller was never the threat model" did not excuse it.
# (Found by the EXTERNAL REFEREE — GPT-5.6 Sol Pro, 2026-08-23 oracle pass,
# finding 5; a31 and a32 are the referee's own two named cases.)
#
# The fix ROUTES: every payload this hook is willing to unwrap is now passed to
# git-guardrails' `git_deny_reason()`, IMPORTED rather than copied, so there is
# one definition of "destructive git" and the two hooks cannot drift apart.
# These cases therefore pin the ROUTING, not the deny list — the reason text
# they emit is the sibling's own. a33 uses a THIRD deny-list rule for exactly
# that reason: it proves the whole shared list is reachable, not two special
# cases welded in.
cat > "$TMP/a31.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -c 'git reset --hard'"}}
EOF
cat > "$TMP/a32.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -c 'git clean -fdx'"}}
EOF
cat > "$TMP/a33.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"sh -c 'git push --force'"}}
EOF
cat > "$TMP/a34.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"env -S 'git clean -fdx'"}}
EOF
cat > "$TMP/a35.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"nice bash -c 'git reset --hard'"}}
EOF
cat > "$TMP/a36.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"timeout 5 bash -c 'git clean -fdx'"}}
EOF
cat > "$TMP/a37.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash --rcfile /dev/null -c 'git reset --hard'"}}
EOF
cat > "$TMP/a38.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -c \"sh -c 'git clean -fdx'\""}}
EOF
fire root-of-trust-guard.py "$TMP/a31.json"
expect_deny   "a31 r14 CROSS-HOOK (the referee's first named case): bash -c '<git reset --hard>' is denied — the unwrapped payload is judged by the SHARED destructive-git rules, not by this hook's path rules"
fire root-of-trust-guard.py "$TMP/a32.json"
expect_deny   "a32 r14 CROSS-HOOK (the referee's second named case): bash -c '<git clean -fdx>' is denied — it deletes untracked and ignored research data that no reflog holds"
fire root-of-trust-guard.py "$TMP/a33.json"
expect_deny   "a33 r14 CROSS-HOOK: sh -c '<git push --force>' is denied — a THIRD deny-list rule through the same carrier, so the WHOLE shared list is reachable, not two hardcoded cases"
fire root-of-trust-guard.py "$TMP/a34.json"
expect_deny   "a34 r14 CROSS-HOOK: env -S '<git clean -fdx>' is denied — the other payload carrier this hook unwraps routes to the deny list too"
fire root-of-trust-guard.py "$TMP/a35.json"
expect_deny   "a35 r14 CROSS-HOOK: nice bash -c '<git reset --hard>' is denied — reached through the shared skip_wrappers, so a command wrapper does not hide the payload"
fire root-of-trust-guard.py "$TMP/a36.json"
expect_deny   "a36 r14 CROSS-HOOK: timeout 5 bash -c '<git clean -fdx>' is denied — a wrapper carrying its own positional argument still reaches the payload"
fire root-of-trust-guard.py "$TMP/a37.json"
expect_deny   "a37 r14 CROSS-HOOK: bash --rcfile <f> -c '<git reset --hard>' is denied — the r6 shell-option parse must not lose the payload on this path either"
fire root-of-trust-guard.py "$TMP/a38.json"
expect_deny   "a38 r14 CROSS-HOOK: a NESTED payload, bash -c \"sh -c '<git clean -fdx>'\", is denied — the routing recurses to the same depth <= 2 bound as the path scan"

# a39-a42: the CONTROLS, and they are the point. A blunt "deny any unwrapped
# payload that mentions git" would pass every deny case above and fail all four
# of these — so without them the new recall would be indistinguishable from a
# false-deny rule. a42 additionally pins the SCOPE: only UNWRAPPED payloads are
# routed here. The direct spelling is git-guardrails' own to judge; denying it
# here as well would emit two denials for one command and make each hook's
# battery depend on the other's behaviour.
cat > "$TMP/a39.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -c 'git status --porcelain'"}}
EOF
cat > "$TMP/a40.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -c 'git clean -n'"}}
EOF
cat > "$TMP/a41.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"bash -c 'echo hello world'"}}
EOF
cat > "$TMP/a42.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git reset --hard"}}
EOF
fire root-of-trust-guard.py "$TMP/a39.json"
expect_silent "a39 r14 control: a READ inside the same carrier — bash -c '<git status --porcelain>' — stays allowed, so the routing did not buy its recall by denying git in a payload"
fire root-of-trust-guard.py "$TMP/a40.json"
expect_silent "a40 r14 control: bash -c '<git clean -n>' — the DRY RUN the deny message itself recommends — stays allowed"
fire root-of-trust-guard.py "$TMP/a41.json"
expect_silent "a41 r14 control: a payload with no git in it at all — bash -c '<echo hello world>' — stays allowed (the ordinary unwrap path is undisturbed)"
fire root-of-trust-guard.py "$TMP/a42.json"
expect_silent "a42 r14 control + SCOPE: the UNWRAPPED spelling of the same op is silent HERE — only payloads are routed, so one command never draws two denials (git-guardrails denies this one; case b1)"

# a43-a53 (r15): SHELL GLOBS AND BRACE GROUPS. `matches_root_of_trust` compared
# path segments LITERALLY against `.claude`, `.githooks`, `settings.json`,
# `settings.local.json` and `hooks`, so ONE metacharacter took a protected path
# out of the guard's sight while the shell expanded it to exactly the protected
# file. Measured at 7eee6b2 with the event cwd at this repository — guard
# verdict, then what the shell expands the token to:
#     rm -f .claude/hook?/git-guardrails.py   ALLOW -> .claude/hooks/git-guardrails.py
#     rm -f .claude/*/git-guardrails.py       ALLOW -> .claude/hooks/git-guardrails.py
#     rm -f .clau*/hooks/git-guardrails.py    ALLOW -> .claude/hooks/git-guardrails.py
#     echo x > .claude/settings.jso?          ALLOW -> .claude/settings.json
#     rm -rf .claude/hook[s]                  ALLOW
#     rm -f .claude/{hooks,rules}/…           ALLOW -> .claude/hooks/…
#     rm -f .githook?/pre-commit              ALLOW -> .githooks/pre-commit
# while the literal spellings of all three targets DENIED — a one-character
# edit flipped every denied spelling to allowed. Globbing was on NEITHER
# disclosed-residual list, and unlike everything that IS on them it failed
# toward ALLOW.
#
# a45 and a49 are not repetition: they put the metacharacter inside the
# protected DIRECTORY name, which also defeated the LITERAL `.claude`/
# `.githooks` fast path in main() — a second copy of the same defect one level
# up, and one that stayed silent after the pattern half was fixed. Measured.
#
# The four controls are what stop this from being "deny anything with a `*`":
#   a50 — a glob under `.claude/` that names an UNPROTECTED child (`rule?`)
#   a51 — a BARE wildcard elsewhere (`rm -f docs/*`). This is the sharp one: a
#         bare `*` fnmatches every protected name, so the naive fix denies the
#         most ordinary command in the repo. It must stay silent, and it can,
#         because bash without `dotglob` never expands `*` to a DOTFILE.
#   a52 — a READ through a glob stays allowed ("every READ is untouched")
#   a53 — SCOPE: the same glob aimed at a clone OUTSIDE the project stays
#         allowed, so the r11 scoping still holds through the glob path
cat > "$TMP/a43.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .claude/hook?/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a44.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .claude/*/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a45.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .clau*/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a46.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf disabled > .claude/settings.jso?"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a47.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -rf .claude/hook[s]"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a48.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .claude/{hooks,rules}/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a49.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .githook?/pre-commit"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a50.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .claude/rule?/deleted-note.md"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a51.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f docs/*"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a52.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cat .claude/hook?/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a53.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f $TMP/rot-clone/.claude/hook?/git-guardrails.py"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a43.json"
expect_deny   "a43 r15: a '?' glob in the hooks DIRECTORY name is denied — the shell expands it to .claude/hooks/git-guardrails.py, and this spelling was ALLOWED while the literal one denied"
fire root-of-trust-guard.py "$TMP/a44.json"
expect_deny   "a44 r15: a bare '*' as the child of .claude/ is denied — .claude/*/git-guardrails.py really does expand to the guard file (an ordinary name, not a dotfile)"
fire root-of-trust-guard.py "$TMP/a45.json"
expect_deny   "a45 r15: the metacharacter INSIDE the protected directory name (.clau*/hooks/…) is denied — this one also had to defeat the literal '.claude' fast path in main(), which returned before the scan ran"
fire root-of-trust-guard.py "$TMP/a46.json"
expect_deny   "a46 r15: a REDIRECTION whose target is globbed (> .claude/settings.jso?) is denied — the file that decides which hooks fire"
fire root-of-trust-guard.py "$TMP/a47.json"
expect_deny   "a47 r15: a character CLASS (.claude/hook[s]) is denied"
fire root-of-trust-guard.py "$TMP/a48.json"
expect_deny   "a48 r15: a BRACE GROUP (.claude/{hooks,rules}/…) is denied — braces are not globs, the shell emits every alternative whether or not it exists"
fire root-of-trust-guard.py "$TMP/a49.json"
expect_deny   "a49 r15: the same glob in the .githooks directory name (.githook?/pre-commit) is denied — the other half of the fast-path defect"
fire root-of-trust-guard.py "$TMP/a50.json"
expect_silent "a50 r15 control: a glob naming an UNPROTECTED child of .claude/ (rule?) stays allowed — the glob rule did not become 'anything under .claude'"
fire root-of-trust-guard.py "$TMP/a51.json"
expect_silent "a51 r15 control, the sharp one: a BARE wildcard elsewhere (rm -f docs/*) stays allowed. A bare '*' fnmatches every protected name, so a naive glob fix denies the most ordinary command in the repo; it is allowed here because bash without dotglob never expands '*' to a DOTFILE"
fire root-of-trust-guard.py "$TMP/a52.json"
expect_silent "a52 r15 control: a READ through the same glob (cat .claude/hook?/…) stays allowed — 'every READ is untouched' survives the fix"
fire root-of-trust-guard.py "$TMP/a53.json"
expect_silent "a53 r15 control + SCOPE: the same glob aimed at a clone OUTSIDE the project stays allowed, so r11's project scoping still holds on the glob path"

# a54/a55 (r15): MULTIPLE -C, the sibling of the git-guardrails defect, found by
# auditing this hook after fixing that one. git composes -C options left to
# right; git_write_target kept only the LAST, so the writer's working directory
# was read as 'hooks' — protected by nothing — and the deletion went SILENT,
# while the byte-equivalent single -C spelling DENIED (a22). Measured at
# 7eee6b2. a55 is the control: composing is not the same as denying any -C chain
# that mentions .claude, and a chain that composes its way back OUT stays
# allowed.
cat > "$TMP/a54.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C .claude -C hooks clean -fd"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a55.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C .claude -C ../docs clean -fd"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a54.json"
expect_deny   "a54 r15: multiple -C COMPOSE — git -C .claude -C hooks clean -fd deletes the hooks and is denied; keeping only the last -C read the working directory as an unprotected 'hooks' and went silent, while the single -C spelling of the same deletion denied (a22)"
fire root-of-trust-guard.py "$TMP/a55.json"
expect_silent "a55 r15 control: a -C chain that composes its way back OUT of the protected tree (.claude then ../docs) stays allowed — the fold follows git rather than denying any -C chain that mentions .claude"

# a56-a60 (r16): PARENT-DIRECTORY (`..`) SEGMENTS. normalize() collapsed `//`
# and `/./` but not `/../`, and the segment walk then read the segments AS
# WRITTEN — so a path that pivots through an UNPROTECTED real child of
# `.claude/` and climbs back into a protected one was not recognised, while the
# shell resolved it to exactly the gate-defining file. Measured at 7b8848d
# against a throwaway fixture tree: `rm -f .claude/rules/../hooks/git-guardrails.py`
# went SILENT and really deleted the guard; `echo x > .claude/rules/../settings.json`
# went SILENT and really rewrote settings.json; both literal twins DENIED.
# a59/a60 are the controls the fix must not buy its recall by breaking: an
# ordinary `..` outside the root of trust, and a READ through the very spelling
# a56 denies.
cat > "$TMP/a56.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .claude/rules/../hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a57.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo disabled > .claude/rules/../settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a58.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .claude/agents/../settings.local.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a59.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f scripts/../docs/index.html"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a60.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cat .claude/rules/../settings.json | head -20"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a56.json"
expect_deny   "a56 r16: a path that pivots through an unprotected sibling and climbs back in (.claude/rules/../hooks/git-guardrails.py) is denied — the shell deletes the guard, and the raw segment walk saw 'rules' after '.claude' and went silent"
fire root-of-trust-guard.py "$TMP/a57.json"
expect_deny   "a57 r16: the same shape reaching settings.json (.claude/rules/../settings.json) is denied"
fire root-of-trust-guard.py "$TMP/a58.json"
expect_deny   "a58 r16: any real unprotected child works as the pivot (.claude/agents/../settings.local.json) — the class is the spelling, not the one directory"
fire root-of-trust-guard.py "$TMP/a59.json"
expect_silent 'a59 r16 control: an ORDINARY `..` outside the root of trust (scripts/../docs/index.html) stays allowed — resolving `..` did not become denying every path that carries one'
fire root-of-trust-guard.py "$TMP/a60.json"
expect_silent "a60 r16 control: a READ through the very spelling a57 denies stays allowed — 'every READ is untouched' survives the fix"

# a61-a63 (r16): THE HEREDOC OPENER SCAN. `_HEREDOC` was a quote-blind regex run
# over raw line text, so `<<` + a bareword matched a HERESTRING (`cmd <<< word`)
# and a `<<WORD` sitting inside a QUOTED STRING. Either one made the scanner
# treat every following line as a heredoc BODY and delete it before tokenising —
# so the real command bash runs on line 2 was never seen. Measured at 7b8848d:
# with line 1 = `tr a-z A-Z <<< hello` or `echo '<<EOF'`, the deleter and the
# redirect on line 2 both went SILENT; with line 1 = `echo hi` both DENIED, and
# bash runs line 2 in every case. a63 is the control in the other direction: a
# REAL heredoc body is still prose and must still be dropped.
A61_CMD='tr a-z A-Z <<< hello\nrm -f .claude/hooks/git-guardrails.py'
A62_CMD='echo \"docs: use <<EOF\"\nprintf disabled > .claude/settings.json'
A63_CMD='cat <<'"'"'EOF'"'"' > notes.md\nrm -f .claude/hooks/git-guardrails.py\nEOF'
cat > "$TMP/a61.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$A61_CMD"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a62.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$A62_CMD"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a63.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$A63_CMD"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a61.json"
expect_deny   "a61 r16: a HERESTRING on line 1 (tr a-z A-Z <<< hello) no longer swallows line 2 — the deletion of a hook is seen and denied"
fire root-of-trust-guard.py "$TMP/a62.json"
expect_deny   "a62 r16: a <<WORD inside a QUOTED string on line 1 no longer opens a heredoc — the redirect into settings.json on line 2 is seen and denied"
fire root-of-trust-guard.py "$TMP/a63.json"
expect_silent 'a63 r16 control: a REAL heredoc body is still dropped — a body that merely documents `rm .claude/hooks/x` is prose, not a command, and quote-awareness did not buy its recall by keeping every body'

# a64 (r16): the hook's REGISTERED timeout. A PreToolUse guard says 'deny' by
# writing a decision; the harness kills it at the timeout in .claude/settings.json
# and a killed hook has written NOTHING, which is exactly what an allow looks
# like. So the registration is pinned against the number the hook itself states.
A64=""
if ROT_DECL="$(grep -o '^_HOOK_REGISTERED_TIMEOUT = [0-9.]*' "$HOOKS/root-of-trust-guard.py" | head -1 | awk '{print $3}')" \
   && [ -n "$ROT_DECL" ]; then
    ROT_REG="$(python3 -c '
import json,sys
d=json.load(open(sys.argv[1]))
for gs in d["hooks"].get("PreToolUse",[]):
    for h in gs["hooks"]:
        if "root-of-trust-guard.py" in h.get("command",""):
            print(h.get("timeout")); break
' "$ROOT/.claude/settings.json" 2>/dev/null)"
    if [ -z "$ROT_REG" ]; then
        A64="ROOT-OF-TRUST-NOT-REGISTERED: no PreToolUse entry names the hook"
    elif [ "$(python3 -c "print(float('$ROT_REG') == float('$ROT_DECL'))" 2>/dev/null)" = "True" ]; then
        A64="registration-matches-the-declared-bound"
    else
        A64="REGISTRATION-DRIFT: settings.json registers ${ROT_REG}s, the hook declares ${ROT_DECL}s"
    fi
else
    A64="NO-DECLARED-BOUND: root-of-trust-guard.py states no _HOOK_REGISTERED_TIMEOUT"
fi
verdict "$A64"
expect_contains "a64 r16: root-of-trust-guard.py's registered timeout in .claude/settings.json equals the bound the hook itself declares — a deny branch that cannot RETURN inside the registration does not exist, because a killed hook emits nothing and nothing is what an ALLOW looks like" \
                "registration-matches-the-declared-bound"

# a65-a67 (r17): THE COMMENT BLINDNESS THE r16 FIX INTRODUCED. r16 taught the
# opener walk about quotes and herestrings but gave it no notion of a shell
# COMMENT, and `strip_heredocs` runs BEFORE any comment-aware tokenising — so an
# ORDINARY `#` comment that merely NAMES a heredoc opened one and DELETED every
# following line. Measured 2026-08-23 at c285699: with line 1 =
# `# heredoc <<EOF` this guard went SILENT on the deletion of a hook file and on
# a redirect into settings.json; with line 1 = `# just a comment` both DENIED,
# and `bash -c` on the two-line form really did remove the guard file. a67 is
# the control in the other direction, and it is the interaction that matters: a
# REAL opener followed by a TRAILING comment must still open, so the body is
# still dropped as prose — comment-awareness must not have bought its recall by
# keeping every heredoc body.
A65_CMD='# regenerate the config with a heredoc <<EOF\nrm -f .claude/hooks/git-guardrails.py'
A66_CMD='echo hi   # uses <<EOF here\nprintf disabled > .claude/settings.json'
A67_CMD='cat <<'"'"'EOF'"'"' > notes.md  # write the notes\nrm -f .claude/hooks/git-guardrails.py\nEOF'
cat > "$TMP/a65.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$A65_CMD"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a66.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$A66_CMD"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a67.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$A67_CMD"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a65.json"
expect_deny   "a65 r17: a FULL-LINE comment naming a heredoc (# … <<EOF) no longer suppresses line 2 — the deletion of a hook is seen and denied"
fire root-of-trust-guard.py "$TMP/a66.json"
expect_deny   "a66 r17: a TRAILING comment naming a heredoc (echo hi # uses <<EOF here) no longer suppresses line 2 — the redirect into settings.json is seen and denied"
fire root-of-trust-guard.py "$TMP/a67.json"
expect_silent 'a67 r17 control: a REAL heredoc opener with a trailing comment after it still OPENS, so its body documenting `rm .claude/hooks/x` is still dropped as prose — comment-awareness did not buy its recall by keeping every body'

# a68-a76 (r18): `>&` — THE REDIRECTION SPELLING THAT WAS IN NO SURFACE AT ALL.
# bash's csh-style `>&<word>` redirects stdout AND stderr to <word> whenever
# <word> is not a file descriptor: it is `&><word>` by another name, and `&>`
# was handled. `>&` was not — `_TOKEN` split it into the op `>` plus `&`, `&` is
# a SEPARATOR so the segment ENDED and the target became a bare word in the NEXT
# segment (out of reach of the `idx + 1` lookahead), and the quote-naive
# backstop could not recover it either because `_REDIR`'s target class excludes
# `&`. Measured at e0c4cdb against a throwaway fixture holding a real
# settings.json: `bash -c 'echo CLOBBERED >& .claude/settings.json'` exited 0
# with empty stderr and left the file containing exactly 'CLOBBERED', while the
# guard fired on the same string said NOTHING — against `&>`, `>` and `>|`
# spellings of the identical write, all three of which DENIED.
#
# a72-a74 are the controls a naive fix breaks, and they are the sharp ones:
# FILE-DESCRIPTOR DUPLICATION (`>&2`, `1>&2`, `2>&1`) is not a file write at
# all, and denying it would refuse the single most ordinary redirection in any
# shell script. a75/a76 keep the other two directions honest: a `>&` aimed
# somewhere unprotected, and a `>&` that only appears INSIDE quotes as prose.
cat > "$TMP/a68.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo CLOBBERED >& .claude/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a69.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo CLOBBERED >&.claude/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a70.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo CLOBBERED >& .claude/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a71.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"bash -c 'echo CLOBBERED >& .claude/settings.json'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a72.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo diagnostic >&2"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a73.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo diagnostic 1>&2"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a74.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"ls .claude/hooks 2>&1 | head -3"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a75.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo building >& docs/build.log"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a76.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo \"to wedge a hook you would run: printf x >& .claude/settings.json\""},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a68.json"
expect_deny   "a68 r18: the csh-style redirect-both (echo CLOBBERED >& .claude/settings.json) is denied — it truncates the file that registers every gate, and it was in NEITHER redirection surface while &>, > and >| all denied the identical write"
fire root-of-trust-guard.py "$TMP/a69.json"
expect_deny   "a69 r18: the ATTACHED spelling (>&.claude/settings.json) is denied too — no space is needed to reach the file"
fire root-of-trust-guard.py "$TMP/a70.json"
expect_deny   "a70 r18: the same operator aimed at a HOOK FILE (>& .claude/hooks/git-guardrails.py) is denied — a guard overwritten by its own blind spot"
fire root-of-trust-guard.py "$TMP/a71.json"
expect_deny   "a71 r18: the >& write wrapped in bash -c is unwrapped and denied — the payload carrier and the new operator compose"
fire root-of-trust-guard.py "$TMP/a72.json"
expect_silent "a72 r18 CONTROL, the sharp one: FILE-DESCRIPTOR DUPLICATION (echo diagnostic >&2) writes to a descriptor, not a path, and stays allowed — a fix that reads every >& as a file write refuses the most ordinary redirection in any shell script"
fire root-of-trust-guard.py "$TMP/a73.json"
expect_silent "a73 r18 CONTROL: the explicit-fd form (1>&2) is a duplication as well and stays allowed"
fire root-of-trust-guard.py "$TMP/a74.json"
expect_silent "a74 r18 CONTROL: 2>&1 on a READ of the protected directory stays allowed — the backstop skips fd targets too, not only the tokenizer path"
fire root-of-trust-guard.py "$TMP/a75.json"
expect_silent "a75 r18 CONTROL: a >& aimed at an UNPROTECTED path in the same project (docs/build.log) stays allowed — the operator was added, not a blanket deny"
fire root-of-trust-guard.py "$TMP/a76.json"
expect_silent "a76 r18 CONTROL: a >& into a protected path that appears only INSIDE QUOTES writes nothing and stays allowed — the a7 prose rule survives the new operator"

# a77-a91 (r19): TWO SPELLINGS OF A PROTECTED PATH THE GUARD COULD NOT SEE.
#
# (1) ANSI-C QUOTING AND LOCALE TRANSLATION. `unquote()` knew `'…'`, `"…"` and
# backslash escapes and nothing else. Bash has two more quote openers and both
# put a `$` immediately in front of the quote — `$'…'` (ANSI-C, escapes
# decoded) and `$"…"` (locale translation). The `$` survived into the unquoted
# word, so `$'.claude/settings.json'` became `$.claude/settings.json`, which
# matches no protected segment. Measured 2026-08-24 against the shipped guard,
# event cwd = the project:
#
#     echo X > .claude/settings.json             DENY   (control)
#     echo X > $'.claude/settings.json'          ALLOW (silent)
#     echo X > $".claude/settings.json"          ALLOW (silent)
#     rm -f $'.claude/hooks/git-guardrails.py'   ALLOW (silent)
#
# a80 is the sharper one: `$'\x2eclaude/…'` carries NONE of the literal
# characters of `.claude`, so it also had to get past `_may_name_a_protected_
# path`, the literal substring fast path that stands in front of the whole scan
# — the r15 defect one level up, and the same shape as it. What bash really
# decodes these to was measured with `printf '%s'` on bash 5.3.9, not assumed:
# `$'\x2eclaude/hooks/x'` -> `.claude/hooks/x`.
#
# (2) CASE. This repository lives on APFS, which is case-INSENSITIVE by default,
# so `.CLAUDE/settings.json` and `.claude/settings.json` are ONE file and `RM`
# really runs rm (`command -v RM` resolves). The segment comparison, the
# writer-program basename lookups and the fast path were all case-sensitive:
#
#     echo X > .CLAUDE/settings.json             ALLOW (silent)
#     RM -f .claude/hooks/git-guardrails.py      ALLOW (silent)
#
# while both lowercase twins DENIED. The fold is UNCONDITIONAL — no filesystem
# probe — by the same ruling the r15 glob fix made, so its cost is a false DENY
# on a case-SENSITIVE filesystem for a directory literally spelled `.CLAUDE`
# that is not the root of trust.
#
# THE CONTROLS ARE WHAT MAKE THE NEW RECALL MEAN ANYTHING, and each is aimed at
# a specific way the fix could have been over-broad:
#   a81/a90 — every READ is still allowed, through BOTH new spellings.
#   a82/a91 — the r11 project SCOPE survives both: the same spelling aimed at a
#             tree outside the project stays silent.
#   a83     — a `$'…'` that is genuinely just TEXT does not become a deny.
#   a88/a89 — an ordinary unprotected path is untouched, lowercase and upper.
# The literal-twin denies these are measured against are a25 (redirection) and
# a5/a20 (deleters), which stay green unchanged.
cat > "$TMP/a77.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf disabled > \$'.claude/settings.json'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a78.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf disabled > \$\".claude/settings.json\""},"cwd":"$ROOT"}
EOF
cat > "$TMP/a79.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f \$'.claude/hooks/git-guardrails.py'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a80.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f \$'\\\\x2eclaude/hooks/git-guardrails.py'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a81.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cat \$'.claude/settings.json'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a82.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f \$'$TMP/rot-clone/.claude/settings.json'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a83.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo \$'first line\\\\nsecond line'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a84.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf disabled > .CLAUDE/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a85.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"RM -f .claude/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a86.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .Claude/HOOKS/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a87.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -rf .GITHOOKS/pre-commit"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a88.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f docs/tmp.txt"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a89.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"RM -f docs/tmp.txt"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a90.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cat .CLAUDE/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a91.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f $TMP/rot-clone/.CLAUDE/settings.json"},"cwd":"$ROOT"}
EOF

fire root-of-trust-guard.py "$TMP/a77.json"
expect_deny   "a77 r19: an ANSI-C quoted redirection target (> \$'.claude/settings.json') is denied — the \$ was surviving into the unquoted word, so the guard compared \$.claude against .claude and missed, while bash writes the byte-identical file"
fire root-of-trust-guard.py "$TMP/a78.json"
expect_deny   "a78 r19: the LOCALE-translation spelling (> \$\".claude/settings.json\") is denied — the second opener bash puts a \$ in front of, missed for the same reason"
fire root-of-trust-guard.py "$TMP/a79.json"
expect_deny   "a79 r19: a DELETE of a hook through the ANSI-C spelling (rm -f \$'.claude/hooks/…') is denied — the guard file itself was reachable this way"
fire root-of-trust-guard.py "$TMP/a80.json"
expect_deny   "a80 r19 THE SHARP ONE: an ANSI-C ESCAPE-ENCODED protected path (\$'\\x2eclaude/hooks/…') is denied. It carries none of the literal characters of '.claude', so it also had to get past the literal-substring fast path standing in front of the whole scan — the r15 defect one level up. Bash decodes it to .claude/hooks/… (measured with printf on bash 5.3.9)"
fire root-of-trust-guard.py "$TMP/a81.json"
expect_silent "a81 r19 CONTROL: a READ through the new ANSI-C spelling (cat \$'.claude/settings.json') stays allowed — 'every READ is untouched' survives the fix"
fire root-of-trust-guard.py "$TMP/a82.json"
expect_silent "a82 r19 CONTROL, and it fires in BOTH directions: the same ANSI-C spelling aimed at a fixture clone OUTSIDE the project stays allowed, so the r11 project scoping is not weakened by teaching the unquoter a new opener. Seeding the fix back out turns this case RED as well — with the \$ left in the word the ABSOLUTE path became the relative token '\$/…', which in_project() resolves against the project and denies. The quoting hole cost a false DENY here at the same time as it cost the false ALLOWs above"
fire root-of-trust-guard.py "$TMP/a83.json"
expect_silent "a83 r19 CONTROL: a \$'…' string that is genuinely just TEXT (echo \$'first line\\nsecond line') is not a write and stays silent — recognising the opener did not become denying every command that carries one"
fire root-of-trust-guard.py "$TMP/a84.json"
expect_deny   "a84 r19: a CASE-VARIED protected directory (> .CLAUDE/settings.json) is denied — APFS is case-insensitive by default, so this is the same file the lowercase twin names, and the twin DENIED while this went silent"
fire root-of-trust-guard.py "$TMP/a85.json"
expect_deny   "a85 r19: a CASE-VARIED writer program (RM -f .claude/hooks/…) is denied — 'command -v RM' resolves on this filesystem, so the uppercase spelling really runs rm"
fire root-of-trust-guard.py "$TMP/a86.json"
expect_deny   "a86 r19: case variance in BOTH the protected directory and the protected child (.Claude/HOOKS/…) is denied — the fold is per SEGMENT, not a special case for the top-level name"
fire root-of-trust-guard.py "$TMP/a87.json"
expect_deny   "a87 r19: the case-varied .githooks tree (.GITHOOKS/pre-commit) is denied — the second protected root folds the same way"
fire root-of-trust-guard.py "$TMP/a88.json"
expect_silent "a88 r19 CONTROL: an ordinary unprotected path with no case variance and no \$-quoting (rm -f docs/tmp.txt) behaves exactly as before"
fire root-of-trust-guard.py "$TMP/a89.json"
expect_silent "a89 r19 CONTROL: the UPPERCASE deleter aimed at an unprotected path (RM -f docs/tmp.txt) stays allowed — folding the program name added a spelling of rm, it did not make rm itself denied"
fire root-of-trust-guard.py "$TMP/a90.json"
expect_silent "a90 r19 CONTROL: a READ through the case-varied spelling (cat .CLAUDE/settings.json) stays allowed"
fire root-of-trust-guard.py "$TMP/a91.json"
expect_silent "a91 r19 CONTROL: the case-varied spelling aimed at a clone OUTSIDE the project stays allowed — the r11 scoping survives the case fold too"

# a92-a102 — r20, THE THIRD DEFECT FROM THE SAME FAST PATH: ORDINARY QUOTING
# PLACED INSIDE THE PROTECTED DIRECTORY NAME. `_may_name_a_protected_path` is a
# case-folded LITERAL substring test standing in front of the entire scan, and a
# quote or a backslash sprinkled through `.claude`/`.githooks` carries neither
# literal, no glob metacharacter and no `$` opener — so the line was rejected
# there and the scan, which unquotes every word at every nesting depth and would
# have denied all of these, never ran. Measured 2026-08-24 at 727a66c, event cwd
# = the project, guard verdict then what bash actually does:
#
#     rm -f .claude/hooks/git-guardrails.py     DENY   (literal control)
#     rm -f .clau\de/hooks/git-guardrails.py    ALLOW (silent) -> file DELETED
#     echo X > .clau\de/settings.json           ALLOW (silent)
#     rm -f .githook\s/pre-commit               ALLOW (silent)
#     rm -f .cl'aud'e/hooks/git-guardrails.py   ALLOW (silent) -> file DELETED
#     rm -f .cl"aud"e/hooks/git-guardrails.py   ALLOW (silent)
#
# THIS IS THE THIRD TIME THIS ONE TEST HAS PRODUCED A FALSE ALLOW (r15 globs,
# r19 case and `$'…'`), so the repair is the CLASS and not three more spellings:
# the trigger is now also computed on a copy of the line with `\`, `'` and `"`
# DELETED. Those three are the complete set of characters that can sit inside a
# word without changing which file the word names — every other quoting form
# bash has is one of them with a `$` in front, which r19 already tests for — so
# deletion collapses every arrangement of them, at any depth, back to the
# literal the shell will use. a97 is the depth case; there is no fourth
# character to enumerate later.
#
# THE CONTROLS ARE WHAT KEEP THE WIDENING HONEST. a98/a99 pin that the same
# quoting in an UNPROTECTED path is untouched; a100 that every READ is still
# allowed through the new spelling; a101 that the r11 project scoping still
# holds (the same spelling aimed at a clone outside the project stays silent);
# and a102 is the sharp one — a target whose denoised form LOOKS protected while
# bash resolves it to a different file entirely, proving the denoise is a
# TRIGGER and not a verdict. What bash really does with both spellings was
# measured with printf on bash 5.3.9, not assumed: `.clau\de/hooks/x` ->
# `.claude/hooks/x` (the guard file), `$'.clau\de/hooks/x'` -> `.clau\de/hooks/x`
# (an unrecognised ANSI-C escape keeps BOTH characters, so this is a different
# name). a83 already pins the plain-text `$'…'` control and stays green.
cat > "$TMP/a92.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .clau\\\\de/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a93.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf disabled > .clau\\\\de/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a94.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .githook\\\\s/pre-commit"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a95.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .cl'aud'e/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a96.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .cl\"aud\"e/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a97.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"bash -c 'rm -f .clau\\\\de/hooks/git-guardrails.py'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a98.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f do\\\\cs/note.txt"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a99.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f 'docs'/note.txt"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a100.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cat .clau\\\\de/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a101.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f $TMP/rot-clone/.clau\\\\de/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a102.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f \$'.clau\\\\de/hooks/git-guardrails.py'"},"cwd":"$ROOT"}
EOF

fire root-of-trust-guard.py "$TMP/a92.json"
expect_deny   "a92 r20 THE MEASURED CASE: a BACKSLASH inside the protected directory name (rm -f .clau\\de/hooks/…) is denied — bash resolves it to the guard file and really deleted it, while the literal twin (a5/a20) denied"
fire root-of-trust-guard.py "$TMP/a93.json"
expect_deny   "a93 r20: the same noise in front of a REDIRECTION target (> .clau\\de/settings.json) is denied — the file that decides which hooks fire"
fire root-of-trust-guard.py "$TMP/a94.json"
expect_deny   "a94 r20: the backslash inside the OTHER protected root (.githook\\s/pre-commit) is denied — the fast path rejected this one on both literals at once"
fire root-of-trust-guard.py "$TMP/a95.json"
expect_deny   "a95 r20: SINGLE QUOTES splitting the name (.cl'aud'e/hooks/…) are denied — quoting is not a spelling of the path, and this one deleted the guard file too"
fire root-of-trust-guard.py "$TMP/a96.json"
expect_deny   "a96 r20: DOUBLE QUOTES splitting the name (.cl\"aud\"e/hooks/…) are denied — the third and last quoting character"
fire root-of-trust-guard.py "$TMP/a97.json"
expect_deny   "a97 r20 THE DEPTH CASE: the same backslash spelling NESTED in a bash -c payload is denied — deleting the quoting characters does not care how deeply they are nested, which is why this closes a class and not three spellings"
fire root-of-trust-guard.py "$TMP/a98.json"
expect_silent "a98 r20 CONTROL: a backslash in an UNPROTECTED path (rm -f do\\cs/note.txt) is untouched — the widened trigger scans more, it does not deny more"
fire root-of-trust-guard.py "$TMP/a99.json"
expect_silent "a99 r20 CONTROL: quotes in an UNPROTECTED path (rm -f 'docs'/note.txt) are untouched — the most ordinary quoting there is"
fire root-of-trust-guard.py "$TMP/a100.json"
expect_silent "a100 r20 CONTROL: a READ through the newly-recognised spelling (cat .clau\\de/settings.json) stays allowed — 'every READ is untouched' survives the fix"
fire root-of-trust-guard.py "$TMP/a101.json"
expect_silent "a101 r20 CONTROL + SCOPE: the same newly-recognised spelling aimed at a clone OUTSIDE the project stays allowed, so the r11 project scoping is not weakened by widening the trigger"
fire root-of-trust-guard.py "$TMP/a102.json"
expect_silent "a102 r20 CONTROL, THE SHARP ONE: rm -f \$'.clau\\de/hooks/…' stays allowed. Its denoised form LOOKS protected and the trigger duly fires, but bash keeps BOTH characters of an unrecognised ANSI-C escape (measured with printf on bash 5.3.9), so the word really names .clau\\de/hooks/… and not the guard. The verdict is still the scan's, on the real word — a widened trigger cannot manufacture a deny"

# a103-a107 — r20, THE SIBLING LOADER'S DOCUMENTED FAIL-OPEN DID NOT HOLD.
# `_git_guardrails()` execs git-guardrails.py IN THIS PROCESS to borrow the
# shared destructive-git deny list, and wrapped that exec in `except Exception`
# while promising "fail-open on anything" and "Returns None on any failure".
# `SystemExit` is not an `Exception`. So a `sys.exit()` reached while the
# sibling's module body ran terminated root-of-trust-guard.py ITSELF with status
# 0 and an EMPTY stdout — and empty stdout is exactly what an ALLOW looks like,
# with no way to tell the two apart from outside. Measured 2026-08-24 at
# 727a66c: with git-guardrails.py replaced by `import sys; sys.exit(0)`, a write
# into `.claude/hooks/` returned rc=0 and said nothing. A SILENT ALLOW of a
# gate-file write, caused by the loader for a rule that had not even run yet.
# Not hypothetical: an audit agent hit it by accident while building a stub and
# read the spurious result as a finding.
#
# Each case runs a COPY of the guard out of a directory built beside a stub
# sibling, because the sibling is located from the guard file's own directory.
# a104 is the behaviour that must NOT regress — an ordinary Exception at the
# sibling's import time is genuinely survivable and always was — and a105/a106
# are what stop the repair from becoming "deny whenever the sibling is broken":
# a read stays silent, and the real sibling still supplies the cross-hook deny.
ROT_SE="$TMP/rot-sib-sysexit"; ROT_EX="$TMP/rot-sib-exception"
mkdir -p "$ROT_SE" "$ROT_EX"
cp "$HOOKS/root-of-trust-guard.py" "$ROT_SE/" 2>/dev/null
cp "$HOOKS/root-of-trust-guard.py" "$ROT_EX/" 2>/dev/null
printf 'import sys\nsys.exit(0)\n'                > "$ROT_SE/git-guardrails.py"
printf "raise RuntimeError('stub blows up')\n"    > "$ROT_EX/git-guardrails.py"

cat > "$TMP/a103.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rm -f .claude/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a105.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cat .claude/settings.json"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a106.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"bash -c 'git reset --hard'"},"cwd":"$ROOT"}
EOF

fire_from "$ROT_SE" root-of-trust-guard.py "$TMP/a103.json"
expect_deny   "a103 r20 THE MEASURED CASE: with a sibling that calls sys.exit() at IMPORT time, a write into .claude/hooks/ is still DENIED. Before the fix the SystemExit propagated out of exec_module past 'except Exception' and ended this hook with rc=0 and empty stdout — a silent ALLOW of a gate-file write"
fire_from "$ROT_EX" root-of-trust-guard.py "$TMP/a103.json"
expect_deny   "a104 r20 CONTROL, the behaviour that must not regress: a sibling raising an ORDINARY Exception at import STILL fails open — the loader returns None and the hook's own path rules run, so the same write is denied. This case was green before the fix and must stay green"
fire_from "$ROT_SE" root-of-trust-guard.py "$TMP/a105.json"
expect_silent "a105 r20 CONTROL: with the same sys.exit() sibling, a READ stays silent — catching BaseException did not turn a broken sibling into a blanket deny"
fire_from "$HOOKS" root-of-trust-guard.py "$TMP/a106.json"
expect_deny   "a106 r20 CONTROL: with the REAL sibling, the cross-hook rule still fires (bash -c '<git reset --hard>' is denied) — widening the except did not break the import that makes a31-a38 work"
fire_from "$ROT_SE" root-of-trust-guard.py "$TMP/a106.json"
expect_silent "a107 r20 CONTROL, the honest half: with a sibling that cannot be loaded, the cross-hook rule has no deny list to consult and the wrapped git op is ALLOWED. That is the documented fail-open, stated as a fact rather than left to be discovered — a guard that invented a verdict without the shared rules would be worse"

# a108/a109 — the SECOND foreign-code entry point, and the reason the r20 repair
# is stated as a class. `_git_guardrails()` is not the only place this hook runs
# the sibling's code in its own process: `wrapped_git_deny` CALLS
# `mod.git_deny_reason(payload)`, and that call carried the same `except
# Exception`. A sibling that imports cleanly and then exits from inside the deny
# list kills this hook at exactly the same cost — rc=0, empty stdout, a silent
# allow — so both call sites catch BaseException now. a109 is the control: with
# the same sibling, a harmless payload must still be silent.
ROT_CE="$TMP/rot-sib-callexit"
mkdir -p "$ROT_CE"
cp "$HOOKS/root-of-trust-guard.py" "$ROT_CE/" 2>/dev/null
printf 'import sys\n\n\ndef git_deny_reason(cmd):\n    sys.exit(0)\n' > "$ROT_CE/git-guardrails.py"

cat > "$TMP/a108.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"bash -c 'rm -f .claude/hooks/git-guardrails.py'"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a109.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"bash -c 'ls -la docs'"},"cwd":"$ROOT"}
EOF

fire_from "$ROT_CE" root-of-trust-guard.py "$TMP/a108.json"
expect_deny   "a108 r20: a sibling that imports CLEANLY and then calls sys.exit() from INSIDE git_deny_reason no longer kills this hook — the wrapped deletion of a hook file falls through to the path rules and is denied. The loader was the measured case; this is the other in-process entry point, closed with it"
fire_from "$ROT_CE" root-of-trust-guard.py "$TMP/a109.json"
expect_silent "a109 r20 CONTROL: with that same sibling, a HARMLESS wrapped payload (bash -c 'ls -la docs') stays silent — swallowing the sibling's exit did not become denying whatever the deny list failed to answer for"

# a110-a112 — r20, THE FOURTH MEMBER OF THE QUOTING CLASS, found by probing the
# a92-a102 repair instead of being reported: a LINE CONTINUATION inside the
# protected directory name. Two things had to be wrong at once for it to reach a
# false ALLOW, and only the second is about the fast path:
#
#   * `join_continuations` substituted a SPACE for the backslash-newline. POSIX
#     says the pair is REMOVED ("the <backslash> and <newline> shall be removed
#     before splitting the input into tokens"), and the difference is invisible
#     at a token BOUNDARY — which is where r11's own measured case sat — and
#     decisive INSIDE a word: the splice split one word bash keeps whole.
#   * the fast path then never saw `.claude` in either the raw line or the
#     denoised one, because deleting the backslash still leaves the newline.
#
# Measured 2026-08-24 at 727a66c, event cwd = the project: `rm -f .clau\` +
# newline + `de/hooks/git-guardrails.py` was ALLOWED (silent) while the literal
# twin DENIED, and `printf '%s\n'` on the same string prints ONE word,
# `.claude/hooks/git-guardrails.py`. a111 is the r11 spelling this splicer was
# written for and must keep working; a112 is the control that a naive
# "delete the backslash-newline and glue everything" repair fails — a
# continuation followed by INDENTATION is still two words to bash, and
# `.clau` + `   de/hooks/…` names nothing protected.
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"rm -f .clau\\' > "$TMP/a110.json"
printf '\\nde/hooks/git-guardrails.py"},"cwd":"%s"}\n' "$ROOT" >> "$TMP/a110.json"
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"rm -f \\' > "$TMP/a111.json"
printf '\\n    .claude/hooks/git-guardrails.py"},"cwd":"%s"}\n' "$ROOT" >> "$TMP/a111.json"
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"rm -f .clau\\' > "$TMP/a112.json"
printf '\\n   de/hooks/git-guardrails.py"},"cwd":"%s"}\n' "$ROOT" >> "$TMP/a112.json"

fire root-of-trust-guard.py "$TMP/a110.json"
expect_deny   "a110 r20 THE PROBE'S CASE: a LINE CONTINUATION inside the protected directory name (rm -f .clau\\<newline>de/hooks/…) is denied. bash removes the backslash-newline and runs the deletion on the guard file; this guard substituted a SPACE for it and scored two words that name nothing"
fire root-of-trust-guard.py "$TMP/a111.json"
expect_deny   "a111 r20 CONTROL, the r11 spelling this splicer exists for: a continuation at a TOKEN BOUNDARY (rm -f \\<newline>    .claude/hooks/…) is still denied — the leading whitespace of the continued line is what separates the words, so removing the space the splice used to invent changed nothing here"
fire root-of-trust-guard.py "$TMP/a112.json"
expect_silent "a112 r20 CONTROL, the sharp one: a continuation followed by INDENTATION (rm -f .clau\\<newline>   de/hooks/…) stays allowed — bash removes only the backslash-newline, so this is still the two words '.clau' and 'de/hooks/…' and names nothing protected. A repair that glued the halves unconditionally would false-deny here"

# a113-a122 (r21): THREE FIXES, and the first is a false ALLOW the r20 wave
# introduced by composing its own two widenings in ONE DIRECTION ONLY. r20
# taught the fast path's literal branch to read the SPLICED line and left the
# `$'` branch and the glob branch reading the RAW one, so a `$` separated from
# its quote by a backslash-newline carried no `$'` substring while its ANSI-C
# escape hid the dot from the literal branch. Measured at 0d16939: ALLOW
# (silent), and bash really deleted the guard file. The other two are
# OVER-DENIALS, both PRE-EXISTING rather than new: a read-only dry run and a
# one-operand `ln`/`rsync` whose operand is the SOURCE were refused, each
# falsifying this guard's own "every READ is allowed" guarantee.
A113Q="'"
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"rm -f $\\' > "$TMP/a113.json"
printf '\\n%s\\\\x2eclaude/hooks/git-guardrails.py%s"},"cwd":"%s"}\n' "$A113Q" "$A113Q" "$ROOT" >> "$TMP/a113.json"
cat > "$TMP/a114.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git clean -n .claude/hooks"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a115.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git clean --dry-run .claude/hooks"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a116.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git rm --dry-run .claude/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a117.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git clean -fd .claude/hooks"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a118.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git clean -nf .claude/hooks"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a119.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"ln -s .claude/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a120.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"rsync .claude/hooks/"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a121.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"ln -s /tmp/x .claude/hooks/git-guardrails.py"},"cwd":"$ROOT"}
EOF
cat > "$TMP/a122.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cp /tmp/x .claude/settings.json"},"cwd":"$ROOT"}
EOF
fire root-of-trust-guard.py "$TMP/a113.json"
expect_deny   "a113 r21 THE COMPOSED-IN-ONE-DIRECTION CASE: an ANSI-C opener SPLIT from its quote by a continuation (rm -f \$<continuation>'\\x2eclaude/hooks/...') is denied — r20 spliced only the literal branch, so the \$' branch saw no opener and the escaped dot hid the literal; every trigger now reads the same spliced text"
fire root-of-trust-guard.py "$TMP/a114.json"
expect_silent "a114 r21 CONTROL: git clean -n on a protected path stays SILENT — a dry run writes nothing, and denying it contradicted this guard's own message that reads are untouched"
fire root-of-trust-guard.py "$TMP/a115.json"
expect_silent "a115 r21 CONTROL: the long spelling (git clean --dry-run) stays silent too"
fire root-of-trust-guard.py "$TMP/a116.json"
expect_silent "a116 r21 CONTROL: git rm --dry-run stays silent — git spells the flag the same way for clean, rm and mv"
fire root-of-trust-guard.py "$TMP/a117.json"
expect_deny   "a117 r21 CONTROL, the sharp one: the REAL writer (git clean -fd) still DENIES — the dry-run exemption did not disarm the rule it sits inside"
fire root-of-trust-guard.py "$TMP/a118.json"
expect_deny   "a118 r21 CONTROL: a BUNDLED short group containing n (git clean -nf) still DENIES — the exemption matches the exact tokens -n and --dry-run only, because -nf still writes"
fire root-of-trust-guard.py "$TMP/a119.json"
expect_silent "a119 r21 CONTROL: one-argument ln -s on a protected path stays SILENT — it creates ./git-guardrails.py POINTING AT the hook, so the protected path is the SOURCE and this is a read"
fire root-of-trust-guard.py "$TMP/a120.json"
expect_silent "a120 r21 CONTROL: one-argument rsync of a protected directory stays silent — with a single operand there is no destination on the command line"
fire root-of-trust-guard.py "$TMP/a121.json"
expect_deny   "a121 r21 CONTROL, the sharp one: the TWO-operand form writing INTO a protected path (ln -s /tmp/x .claude/hooks/...) still DENIES — requiring a second operand did not disarm the destination rule"
fire root-of-trust-guard.py "$TMP/a122.json"
expect_deny   "a122 r21 CONTROL: an ordinary two-operand cp INTO the root of trust still DENIES — the DEST_LAST branch is intact for every real write"

# ── (b) git-guardrails: the deny list ──────────────────────────────────────
echo ""
echo "  (b) git-guardrails.py — destructive git"

cat > "$TMP/b1.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git reset --hard HEAD~1"}}
EOF
cat > "$TMP/b2.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git push --force-with-lease origin main"}}
EOF

fire git-guardrails.py "$TMP/b1.json"
expect_deny   "b1 git reset --hard is denied"
fire git-guardrails.py "$TMP/b2.json"
expect_silent "b2 clean control: --force-with-lease is allowed"

# b3/b4 (r9): git's GLOBAL options were ENUMERATED — seven of them — in the
# prefix every deny regex carries. git documents many more, so ONE innocuous
# unlisted option defeated the ENTIRE deny list: with `-P` (git's own short
# spelling of `--no-pager`, whose LONG spelling WAS listed) or
# `--no-optional-locks` inserted, reset --hard / clean -fd / push --force /
# add -A / checkout -- . all went SILENT. The table now enumerates only the
# options that take a SEPARATE VALUE and consumes any other dash-word as a
# one-token global, so an unknown option fails toward FINDING the subcommand.
cat > "$TMP/b3.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git -P reset --hard HEAD~1"}}
EOF
cat > "$TMP/b4.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git --no-optional-locks clean -fd"}}
EOF
fire git-guardrails.py "$TMP/b3.json"
expect_deny   "b3 r9: an UNENUMERATED git global option (git -P reset --hard) no longer bypasses the deny list"
fire git-guardrails.py "$TMP/b4.json"
expect_deny   "b4 r9: the same for a long unenumerated global (git --no-optional-locks clean -fd)"

# b5-b14 (r10): SHELL QUOTING defeated the whole deny list. The rules were
# regexes over the RAW command string while the clean-tree check next door had
# already been rebuilt to tokenise, so quoting ONE token made a destructive op
# invisible — executed against the shipped guard: `git reset --hard HEAD~1`
# DENIED, `git reset "--hard" HEAD~1` SILENT; `git add -A` DENIED, `git add
# '-A'` SILENT. The deny list now runs over the same unquoted TOKENS as the
# clean-tree check. One quoted spelling per GIT_DENY verb is pinned here —
# reset, clean, push, add, checkout, restore — plus the quoted SUBCOMMAND form,
# because quoting `git 'reset'` broke it just as thoroughly as quoting the flag.
cat > "$TMP/b5.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git reset \"--hard\" HEAD~1"}}
EOF
cat > "$TMP/b6.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git 'reset' --hard HEAD~1"}}
EOF
cat > "$TMP/b7.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git clean \"-fd\""}}
EOF
cat > "$TMP/b8.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git push \"--force\" origin main"}}
EOF
cat > "$TMP/b9.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git add '-A'"}}
EOF
cat > "$TMP/b10.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git add \"--all\""}}
EOF
cat > "$TMP/b11.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git checkout -- '.'"}}
EOF
cat > "$TMP/b12.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git restore \".\""}}
EOF
# b13/b14: the two controls for the port, one per direction.
#   b13 — a FULLY QUOTED mention writes nothing and must be SILENT. The old raw
#         regex DENIED this string; the tokenizer sees one word whose basename
#         is not `git`, so no invocation is found. (The UNQUOTED mention still
#         denies — the documented over-deny the clean-tree check already pays.)
#   b14 — quoting the SAFE flag must not start denying it either: the port must
#         not have bought its recall by matching substrings again.
cat > "$TMP/b13.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"echo \"never run git reset --hard here\""}}
EOF
cat > "$TMP/b14.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"git push \"--force-with-lease\" origin main"}}
EOF
fire git-guardrails.py "$TMP/b5.json"
expect_deny   "b5 r10: a QUOTED flag no longer evades the deny list (git reset \"--hard\" HEAD~1)"
fire git-guardrails.py "$TMP/b6.json"
expect_deny   "b6 r10: a QUOTED subcommand no longer evades it either (git 'reset' --hard HEAD~1)"
fire git-guardrails.py "$TMP/b7.json"
expect_deny   "b7 r10: quoted destructive clean (git clean \"-fd\") is denied"
fire git-guardrails.py "$TMP/b8.json"
expect_deny   "b8 r10: quoted force push (git push \"--force\" origin main) is denied"
fire git-guardrails.py "$TMP/b9.json"
expect_deny   "b9 r10: quoted blanket staging (git add '-A') is denied"
fire git-guardrails.py "$TMP/b10.json"
expect_deny   "b10 r10: the long quoted spelling (git add \"--all\") is denied"
fire git-guardrails.py "$TMP/b11.json"
expect_deny   "b11 r10: quoted mass discard (git checkout -- '.') is denied"
fire git-guardrails.py "$TMP/b12.json"
expect_deny   "b12 r10: the restore spelling of the same (git restore \".\") is denied"
fire git-guardrails.py "$TMP/b13.json"
expect_silent "b13 r10 control: a FULLY QUOTED mention writes nothing and is silent (the raw regex used to deny this string)"
fire git-guardrails.py "$TMP/b14.json"
expect_silent "b14 r10 control: quoting the SAFE flag keeps it allowed (git push \"--force-with-lease\") — the port did not buy recall with substring matching"

# b15-b17 (r12): the SAME backslash-newline defect as a27-a30, one hook over —
# `_SEG_TOKEN` listed `\n` as a separator and its word class could not consume
# backslash+newline, so a destructive flag that landed on the continued line was
# invisible. Executed against the pre-fix guard on a dirty fixture, all SILENT:
# `git clean \`+NL+`-xfd` (and run through bash it deleted the untracked file),
# `git push \`+NL+`--force origin main`, `git reset \`+NL+`--hard HEAD~1`,
# `git add \`+NL+`-A`, `git checkout \`+NL+`-- .`, `git restore \`+NL+`.`. Every
# one-line spelling denied. b17 is the control in the other direction: the join
# must not start denying the SAFE flag just because it was continued.
cat > "$TMP/b15.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git clean ${JCONT}    -xfd"}}
EOF
cat > "$TMP/b16.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git push ${JCONT}--force origin main"}}
EOF
cat > "$TMP/b17.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git push ${JCONT}--force-with-lease origin main"}}
EOF
fire git-guardrails.py "$TMP/b15.json"
expect_deny   "b15 r12: a destructive clean whose -xfd sits on a CONTINUED line is denied (this spelling was silent and deleted untracked files)"
fire git-guardrails.py "$TMP/b16.json"
expect_deny   "b16 r12: the same for a continued force push (git push \\<newline>--force origin main)"
fire git-guardrails.py "$TMP/b17.json"
expect_silent "b17 r12 control: the continued SAFE spelling (git push \\<newline>--force-with-lease) stays allowed — splicing continuations did not buy recall by denying every multi-line push"

# b18-b20 (r16): THE HEREDOC OPENER SCAN, the sibling of a61-a63. This hook
# carried the SAME quote-blind `_HEREDOC` regex, and `_strip_heredocs` runs
# FIRST in both `git_deny_reason` and `dirty_tree_reason` — so a herestring or a
# quoted `<<WORD` on an earlier line deleted the rest of the command and
# silenced the UNCONDITIONAL deny list as well as the clean-tree rule. Measured
# at 7b8848d: with line 1 = `tr a-z A-Z <<< hello` or `echo '<<EOF'`, `git reset
# --hard HEAD~1`, `git clean -fd`, `git push --force origin main` and `git add
# -A` all went SILENT; every one of them DENIES when line 1 is `echo hi`, and
# bash runs line 2 in each. b20 is the control: a REAL heredoc body carrying the
# same text is prose and must stay allowed.
B18_CMD='tr a-z A-Z <<< hello\ngit reset --hard HEAD~1'
B19_CMD='echo '"'"'<<EOF'"'"'\ngit clean -fd'
B20_CMD='cat <<'"'"'EOF'"'"' > runbook.md\ngit push --force origin main\nEOF'
cat > "$TMP/b18.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$B18_CMD"}}
EOF
cat > "$TMP/b19.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$B19_CMD"}}
EOF
cat > "$TMP/b20.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$B20_CMD"}}
EOF
fire git-guardrails.py "$TMP/b18.json"
expect_deny   "b18 r16: a HERESTRING on line 1 (tr a-z A-Z <<< hello) no longer swallows line 2 — git reset --hard is seen and denied"
fire git-guardrails.py "$TMP/b19.json"
expect_deny   "b19 r16: a <<WORD inside a QUOTED string on line 1 no longer opens a heredoc — git clean -fd on line 2 is seen and denied"
fire git-guardrails.py "$TMP/b20.json"
expect_silent 'b20 r16 control: a REAL heredoc body carrying `git push --force` is still dropped as prose — quote-awareness did not buy its recall by keeping every body'

# b21-b23 (r17): the sibling of a65-a67 — the SAME comment blindness, in this
# hook's byte-identical copy of `_heredoc_opener`, reaching the UNCONDITIONAL
# deny list. Measured 2026-08-23 at c285699: with line 1 = `# heredoc <<EOF`
# this hook went SILENT on `git reset --hard HEAD~1`, on a destructive clean, on
# a force push, on `git add -A` and on a dirty-tree merge; with line 1 =
# `# just a comment` every one of them DENIED, and bash runs line 2 in all of
# them. b23 is the control: a REAL opener with a trailing comment still opens,
# so its body stays prose.
B21_CMD='# regenerate the runbook with a heredoc <<EOF\ngit reset --hard HEAD~1'
B22_CMD='echo hi   # uses <<EOF here\ngit clean -fdx'
B23_CMD='cat <<'"'"'EOF'"'"' > runbook.md  # write the runbook\ngit push --force origin main\nEOF'
cat > "$TMP/b21.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$B21_CMD"}}
EOF
cat > "$TMP/b22.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$B22_CMD"}}
EOF
cat > "$TMP/b23.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$B23_CMD"}}
EOF
fire git-guardrails.py "$TMP/b21.json"
expect_deny   "b21 r17: a FULL-LINE comment naming a heredoc (# … <<EOF) no longer suppresses line 2 — git reset --hard is seen and denied"
fire git-guardrails.py "$TMP/b22.json"
expect_deny   "b22 r17: a TRAILING comment naming a heredoc (echo hi # uses <<EOF here) no longer suppresses line 2 — the destructive clean is seen and denied"
fire git-guardrails.py "$TMP/b23.json"
expect_silent 'b23 r17 control: a REAL heredoc opener with a trailing comment after it still OPENS, so its body carrying `git push --force` is still dropped as prose'

# b24-b33 (r19): THE r10 QUOTING HOLE HAD TWO SPELLINGS LEFT, AND A THIRD
# DIMENSION NOBODY HAD LOOKED AT.
#
# r10 ported this deny list off raw-string regexes onto tokens precisely so that
# quoting one word could not defeat it. It closed `"…"` and `'…'`. Bash has two
# more openers — `$'…'` (ANSI-C) and `$"…"` (locale translation) — and the `$`
# in front of the quote was falling through `_unquote` into the word, so
# `$'--hard'` became `$--hard` and the whole-word comparison missed. Separately,
# the command word itself was compared with `== "git"` while this filesystem is
# case-insensitive (`command -v GIT` resolves to /usr/bin/GIT). Measured
# 2026-08-24 against the shipped hook on a fixture repository:
#
#     git reset --hard HEAD        DENY   (control)
#     git reset $'--hard' HEAD     ALLOW (silent)
#     git $'merge' other           ALLOW (silent)
#     git clean $'-fd'             ALLOW (silent)
#     git reset $"--hard" HEAD     ALLOW (silent)
#     GIT reset --hard HEAD        ALLOW (silent)
#     Git merge other              ALLOW (silent)
#
# b27 is the one that needs the DECODER rather than just the opener: bash
# expands `$'\x2dA'` to `-A`, so a guard that stripped the quotes but left the
# escape would still compare `\x2dA` against `-A` and miss. What bash really
# produces was measured with `printf '%s'` on bash 5.3.9.
#
# The SUBCOMMAND is deliberately not folded, and b32 is why that costs nothing:
# git itself refuses a case-varied subcommand (`git STATUS` exits 128, "cannot
# handle STATUS as a builtin", measured on git 2.50.1), so folding it would add
# only false denies. The controls b30-b33 pin the other direction — the fix
# recognises two more openers and one more spelling of the program name, it does
# not deny every command carrying a `$'` or every word beginning with GIT.
cat > "$TMP/b24.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git reset \$'--hard' HEAD~1"}}
EOF
cat > "$TMP/b25.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git \$'reset' --hard HEAD~1"}}
EOF
cat > "$TMP/b26.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git clean \$'-fd'"}}
EOF
cat > "$TMP/b27.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git add \$'\\\\x2dA'"}}
EOF
cat > "$TMP/b28.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git reset \$\"--hard\" HEAD~1"}}
EOF
cat > "$TMP/b29.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"GIT reset --hard HEAD~1"}}
EOF
cat > "$TMP/b30.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"Git push --force origin main"}}
EOF
cat > "$TMP/b31.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git push \$'--force-with-lease' origin main"}}
EOF
cat > "$TMP/b32.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo \$'never run git reset --hard here'"}}
EOF
cat > "$TMP/b33.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"GIT status --porcelain"}}
EOF

fire git-guardrails.py "$TMP/b24.json"
expect_deny   "b24 r19: an ANSI-C quoted FLAG (git reset \$'--hard') is denied — r10 closed '…' and \"…\" and left bash's other two openers open, and the \$ was surviving into the unquoted word"
fire git-guardrails.py "$TMP/b25.json"
expect_deny   "b25 r19: an ANSI-C quoted SUBCOMMAND (git \$'reset' --hard) is denied — the same hole on the other half of the invocation"
fire git-guardrails.py "$TMP/b26.json"
expect_deny   "b26 r19: git clean \$'-fd' is denied — the destructive-clean rule was reachable through the same spelling, and it deletes untracked data no reflog holds"
fire git-guardrails.py "$TMP/b27.json"
expect_deny   "b27 r19 THE DECODER CASE: git add \$'\\x2dA' is denied. Stripping the quotes is not enough — bash DECODES the ANSI-C escape, so the word git receives is -A (measured with printf on bash 5.3.9), and a guard comparing the undecoded text would still miss"
fire git-guardrails.py "$TMP/b28.json"
expect_deny   "b28 r19: the LOCALE-translation spelling (git reset \$\"--hard\") is denied — bash's fourth quote opener, missed for the same reason as the third"
fire git-guardrails.py "$TMP/b29.json"
expect_deny   "b29 r19: a CASE-VARIED program word (GIT reset --hard) is denied — 'command -v GIT' resolves to /usr/bin/GIT on this case-insensitive filesystem, so the uppercase spelling really runs git"
fire git-guardrails.py "$TMP/b30.json"
expect_deny   "b30 r19: the title-case spelling (Git push --force) is denied too — the fold is on the whole basename, not on one alternative capitalisation"
fire git-guardrails.py "$TMP/b31.json"
expect_silent "b31 r19 CONTROL: an ALLOWED flag in the new spelling (git push \$'--force-with-lease') stays allowed — the unquoter learned an opener, it did not start denying every quoted flag"
fire git-guardrails.py "$TMP/b32.json"
expect_silent "b32 r19 CONTROL: a \$'…' that is a quoted MENTION (echo \$'never run git reset --hard here') is one word whose basename is not git, and stays silent — the b13 false-deny rule survives the new opener"
fire git-guardrails.py "$TMP/b33.json"
expect_silent "b33 r19 CONTROL: GIT status --porcelain stays silent — folding the program word did not make every uppercase git invocation destructive, and the SUBCOMMAND is deliberately not folded because git itself rejects a case-varied one (git STATUS exits 128 on 2.50.1)"

# b34-b38 (r20): THE LINE-CONTINUATION SPLICE, the sibling's defect sitting in
# this file too. POSIX REMOVES a backslash-newline; `_join_continuations`
# substituted a SPACE. That is invisible where the continuation sits at a token
# boundary -- every spelling r12 was written against, which is why it stood --
# and decisive INSIDE a word, where the invented space splits one word into two
# that match no rule. Measured at 727a66c on a dirty fixture: a continuation
# inside the subcommand, the flag, a force push, and the program word itself all
# went SILENT while every literal twin DENIED, and `printf '%s' re\<newline>set`
# prints the single word `reset`. Found by the r20 audit of the SIBLING hook,
# which carried the identical substitution -- two copies of one rule drifting
# apart in the direction neither author checked.
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git re\\' > "$TMP/b34.json"
printf '\\nset --hard HEAD"}}\n' >> "$TMP/b34.json"
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git reset --ha\\' > "$TMP/b35.json"
printf '\\nrd HEAD"}}\n' >> "$TMP/b35.json"
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git push --for\\' > "$TMP/b36.json"
printf '\\nce origin main"}}\n' >> "$TMP/b36.json"
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"gi\\' > "$TMP/b37.json"
printf '\\nt reset --hard HEAD"}}\n' >> "$TMP/b37.json"
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"echo re\\' > "$TMP/b38.json"
printf '\\nset is a word here"}}\n' >> "$TMP/b38.json"
fire git-guardrails.py "$TMP/b34.json"
expect_deny   "b34 r20: a LINE CONTINUATION inside the SUBCOMMAND (git re\\<newline>set --hard) is denied — bash removes the backslash-newline and runs reset --hard; this guard substituted a space and scored two words that name no rule"
fire git-guardrails.py "$TMP/b35.json"
expect_deny   "b35 r20: the same split inside the FLAG (--ha\\<newline>rd) is denied — the class is the splice, not one position in the command"
fire git-guardrails.py "$TMP/b36.json"
expect_deny   "b36 r20: a force push split across a continuation (--for\\<newline>ce) is denied — a third deny-list rule, proving the whole list was reachable this way and not two spellings"
fire git-guardrails.py "$TMP/b37.json"
expect_deny   "b37 r20 THE SHARP ONE: the split inside the PROGRAM WORD (gi\\<newline>t reset --hard) is denied — with the word broken the segment carried no basename 'git' at all, so neither the deny list NOR the clean-tree precondition ever ran"
fire git-guardrails.py "$TMP/b38.json"
expect_silent "b38 r20 CONTROL: a continuation inside a word of an ORDINARY command (echo re\\<newline>set is a word here) stays silent — joining the halves did not make every spliced word a destructive verb, and the basename is echo"

# ── (c) git-guardrails: the clean-tree precondition ────────────────────────
# Needs a real repository to answer `git status --porcelain`, so build a
# throwaway one inside the temp directory. Dirty first, then clean.
echo ""
echo "  (c) git-guardrails.py — merge must start from a clean tree"

REPO="$TMP/repo"
mkdir -p "$REPO"
git -C "$REPO" init -q >/dev/null 2>&1
: > "$REPO/untracked.txt"          # one untracked file == a dirty tree

# A SECOND, CLEAN checkout — the fixture case c17 needs. A `git -C <other> stash`
# must not vouch for the tree the merge actually runs in (a common worktree /
# second-clone setup), so the clean mark has to be keyed per repository.
OTHER_REPO="$TMP/other-repo"
mkdir -p "$OTHER_REPO"
git -C "$OTHER_REPO" init -q >/dev/null 2>&1   # no files == a clean tree

# A THIRD checkout, dirty in a way `git stash` can actually handle: ONE TRACKED
# file modified, and no `??` entry anywhere. r13 needs this because `--autostash`
# stopped being unconditionally exempt — it is now allowed only when porcelain
# status reports no untracked entry — so the ALLOW direction of that rule cannot
# be tested in $REPO, whose entire dirt IS an untracked file. Cases c19, c30 and
# c42 run here; c9 is the same op in $REPO and must now DENY.
TRACKED_REPO="$TMP/tracked-repo"
mkdir -p "$TRACKED_REPO"
git -C "$TRACKED_REPO" init -q >/dev/null 2>&1
printf 'v1\n' > "$TRACKED_REPO/tracked.txt"
git -C "$TRACKED_REPO" add tracked.txt >/dev/null 2>&1
git -C "$TRACKED_REPO" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1
printf 'v2\n' > "$TRACKED_REPO/tracked.txt"   # ` M tracked.txt`, no `??`

# ── r8, AS AMENDED AT r13: the rule this block pins ────────────────────────
# The clean-tree check STOPPED SIMULATING THE SHELL at r8, and r13 corrected two
# things r8 got wrong. What it pins NOW, rule by rule:
#   (0) an identified history op must be a STANDALONE SIMPLE COMMAND, or it is
#       DENIED without reading the tree (r13). The reading is taken at
#       PreToolUse, so a chain, pipeline, redirection, substitution, `cd` or
#       assignment could act between the reading and git.
#   (1) no history op as an actual command → silent.
#   (2) an ESCAPE op (`--abort`/`--continue`/`--skip`/`--quit`/`--edit-todo`)
#       → ALLOW without reading the tree. `--autostash` was in this list until
#       r13 and is NOT any more: it reads the tree and is allowed only when
#       there is no `??` entry, because git's autostash does not stash
#       untracked files (c9 flipped to DENY; c42 is its control).
#   (3) otherwise read `git status --porcelain` LIVE in the directory the
#       invocation itself names and DENY if it is non-empty. An UNRESOLVED
#       repository selector denies too, rather than falling back (r13).
# r8's own heading called this "a closed whole-command allowlist". It was not —
# an unidentified invocation (`bash -c '...'`) passes outside the rule entirely.
# Corrected wording lives in the guard's docstring; see the r13 block below.
#
# DELETED IN r8, because each of these tested ONLY the simulator that is gone:
#   old c7  `git stash push && git pull` ALLOW   — the stash-effect "clean" verdict
#   old c8  push && pop && merge DENY            — the redirty state machine
#   old c9  `-m pop` message-not-subcommand ALLOW— the stash subcommand parser
#   old c10 pathspec-limited push DENY           — the "partial" classification
#   old c11 `--keep-index` DENY                  — the stash FLAG allowlist
#   old c12 bare `-p` DENY                       — the stash FLAG allowlist
#   old c13 invented stash flag DENY             — the stash FLAG allowlist
#   old c14 `stash branch` DENY                  — the stash SUBCOMMAND allowlist
#   old c15 invented stash subcommand DENY       — the stash SUBCOMMAND allowlist
#   old c20 `git log > f` between DENY           — the inert-segment allowlist
#   old c21 `echo >> f` between DENY             — the inert-segment allowlist
#   old c22 inert `echo` preserves the mark ALLOW— the inert-segment allowlist
# Every one of them now resolves to the same trivial answer ("the tree is dirty,
# so DENY") and none of them can distinguish a working guard from a broken one.
# Old c4/c7/c9/c22 flipped ALLOW→DENY: that flip is the ACCEPTED COST, and c4
# below pins it so nobody "fixes" it back.
# Retained from earlier rounds: old c1→c1, c2→c2, c3→c3, c4→c4 (flipped),
# c5→c5, c6→c6, c16→c7, c17→c8, c18→c9, c19→c10.
cat > "$TMP/c1.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c2.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge --abort"},"cwd":"$REPO"}
EOF
# c4: THE ACCEPTED COST, pinned. `git stash push -m x && git merge` used to be
# ALLOWED (the remedy the old deny message recommended). It is DENIED — since
# r13 by RULE 0, before the tree is read at all, because a history op is
# accepted only as a standalone simple command. Eight rounds of trying to
# SIMULATE what the first half of such a chain would do leaked eight times,
# including `git stash` not stashing UNTRACKED files at all, so this very chain
# could leave the tree dirty and still be allowed. Note what r13 added: the
# mirror image, `<a write> && git merge`, was ALLOWED on a clean tree the whole
# time (c31) — the cost below was being paid in one direction only.
# The cost is one extra TOOL CALL (run the two commands separately, which the
# guard re-checks), not one keystroke. DO NOT "fix" this back.
cat > "$TMP/c4.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git stash push -m wip && git merge feature-x"},"cwd":"$REPO"}
EOF
# c5: a quoted -C path must not let a dirty merge through (the path is honoured,
# not stripped as a quoted span).
cat > "$TMP/c5.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C \"$REPO\" merge feature-x"}}
EOF
# c6: a `git commit` earlier in the chain licenses nothing either.
cat > "$TMP/c6.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git commit -m wip && git merge feature-x"},"cwd":"$REPO"}
EOF
# c7/c8/c10 (old c16/c17/c19): the historic bypass SHAPES, kept because they are
# the real command lines that leaked in rounds 6 and 7 — a dirtying command
# between the stash and the merge, a stash in a DIFFERENT checkout, and a
# redirection inside an "inert" echo. Under the new rule they deny for one
# reason, not three: the tree is dirty at decision time.
cat > "$TMP/c7.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git stash push -m wip && touch new.R && git merge feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c8.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C $OTHER_REPO stash && git merge feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c9.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge --autostash feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c10.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git stash push -m wip && echo note > b.txt && git merge feature-x"},"cwd":"$REPO"}
EOF
# c11-c13: the three r8 findings that broke the simulator, pinned against the
# rule that makes them harmless.
#   c11 — `cd <other repo> && git merge`. Repository identity is read from -C or
#         the event cwd only, so this is judged against the SESSION's repo,
#         which is dirty → DENY. (`cd` is disclosed as unseen in the docstring;
#         what matters is that it cannot make a dirty tree look clean.)
#   c12 — `echo $(touch f)`: a command substitution inside an allowlisted "inert"
#         command word. It used to preserve the clean mark and false-ALLOW.
#   c13 — the backtick spelling of the same thing.
cat > "$TMP/c11.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"cd $OTHER_REPO && git merge feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c12.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git stash push -m wip && echo \$(touch new1.R) && git merge feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c13.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git stash push -m wip && echo \`touch new2.R\` && git merge feature-x"},"cwd":"$REPO"}
EOF
# c14-c17: the rest of the rule.
#   c14 — rule 2 on a DIFFERENT op and a DIFFERENT escape flag (`rebase --continue`).
#   c15 — `--no-autostash` does NOT qualify for rule 2: switching git's own
#         stash-operate-restore OFF must face the live check.
#   c16 — rule 3 on `git pull`, the third history op, with no chain at all.
#   c17 — rule 1: a `git merge` merely MENTIONED in an echo is not a history op,
#         so the check must stay silent. This is the control that stops the new
#         rule from buying its recall by denying everything.
cat > "$TMP/c14.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git rebase --continue"},"cwd":"$REPO"}
EOF
cat > "$TMP/c15.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git pull --no-autostash"},"cwd":"$REPO"}
EOF
cat > "$TMP/c16.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git pull"},"cwd":"$REPO"}
EOF
cat > "$TMP/c17.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"echo 'remember to git merge feature-x after the review'"},"cwd":"$REPO"}
EOF
# ── r9: the parse holes that survived r8's deletion of the simulator ────────
# r8 removed every PREDICTION about what the shell would do, and that held —
# round 9 found no way to make a dirty tree read as clean. What it found
# instead is that the small amount of PARSING still required (which segment is
# a git invocation, which words are git's globals, whether the op is exempt)
# had holes, and each one skipped the tree reading entirely.
#
#   c18 — rule 2 was a SUBSTRING search over the joined, already-unquoted
#         segment, so an exempt token appearing inside an option VALUE switched
#         the whole check off. Executed on a dirty fixture, `git merge -m "wip
#         --autostash later" feature` was ALLOWED. The exemption is now exact
#         TOKEN equality with value-taking options' values skipped.
#   c19 — the control for that fix: a REAL `--autostash` must still be exempt
#         even when a -m value also names an exempt flag, so recall was not
#         bought with a false deny.
#   c20 — a segment was tested for git by its FIRST WORD only, so any shell
#         compound keyword in front of the op hid it. `if true; then git merge
#         x; fi` was SILENT while bare `git merge x` DENIED, and the merge ran
#         over uncommitted work in the fixture.
#   c21 — the grouping form of the same hole, attached-paren spelling.
#   c22 — the loop form, plus an UNRESOLVABLE `-C $d`: an unreadable named
#         directory used to be treated as clean and ALLOWED; it now degrades to
#         reading the event cwd.
#   c23 — the clean-tree half of the b3/b4 global-option hole.
#   c24 — the r8-DISCLOSED bare command wrapper, now closed: a `git` word is
#         searched for ALONG the segment, not only at its head.
#   c25 — a RELATIVE `-C` was resolved against the HOOK PROCESS's cwd instead
#         of the event's, so `git -C . pull` in a dirty repo A was judged
#         against whatever repo B the hook sat in. Fired deliberately from the
#         OTHER checkout so the two directories differ.
#   c26 — a trailing shell COMMENT put an exempt token on the invocation.
cat > "$TMP/c18.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge -m \"wip --autostash later\" feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c19.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge --autostash -m \"keep --skip in the message\" feature-x"},"cwd":"$TRACKED_REPO"}
EOF
cat > "$TMP/c20.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"if true; then git merge feature-x; fi"},"cwd":"$REPO"}
EOF
cat > "$TMP/c21.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git status && (git merge feature-x)"},"cwd":"$REPO"}
EOF
cat > "$TMP/c22.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"for d in .; do git -C \$d pull; done"},"cwd":"$REPO"}
EOF
cat > "$TMP/c23.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git --no-optional-locks pull"},"cwd":"$REPO"}
EOF
cat > "$TMP/c24.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"timeout 300 git pull"},"cwd":"$REPO"}
EOF
cat > "$TMP/c25.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C . merge feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c26.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git pull origin main  # finish the --continue later"},"cwd":"$REPO"}
EOF
# ── the INHERITED GIT ENVIRONMENT (found by /blast-radius, 2026-08-23) ──────
# `tree_is_dirty()` shells out to `git status --porcelain` with a cwd and,
# until this fix, no `env=`. git EXPORTS GIT_DIR / GIT_INDEX_FILE into every
# hook it runs, ABSOLUTE when the commit came from a linked worktree — and
# GIT_DIR overrides repository DISCOVERY, so `cwd=` was decoration: the guard
# answered about whatever repository the environment named. Cases c1-c26 were
# green in that environment FOR THE WRONG REASON — satisfied by reading the
# session's own dirty repository rather than the fixture. Both directions are
# pinned, because a fix that simply denied more would also have "passed" c27:
#   c27 — event cwd DIRTY, environment pointing at a CLEAN repo  -> DENY
#   c28 — event cwd CLEAN, environment pointing at the DIRTY one -> SILENT
# c28 is the one that cannot be satisfied by over-denying.
#
# Both cases export GIT_WORK_TREE as well as GIT_DIR/GIT_INDEX_FILE, and that
# is not padding: with GIT_DIR alone git still takes the WORKING TREE from the
# process cwd, so the answer coincides with the right one and BOTH cases pass
# against the unfixed guard — measured. Only when the environment names the
# other repository COMPLETELY do the two readings disagree, which is what makes
# these cases able to fail.
cat > "$TMP/c28.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$OTHER_REPO"}
EOF
# c29/c30 (r12): the clean-tree half of the line-continuation defect. With the
# subcommand on the continued line the segment holding `git` had no subcommand
# at all, so rule 1 answered "not a history op" and the tree was never read —
# `git \`+NL+`merge feature-x` and `git \`+NL+`pull origin main` were SILENT on
# the dirty fixture. c30 is the control the auditor asked for and it discriminates
# in BOTH directions: with the continuation unspliced the exempt `--autostash`
# lands in a SEPARATE segment, so the merge segment looks unexempt and DENIES —
# a false deny of git's own stash-operate-restore. Splicing restores both.
cat > "$TMP/c29.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git ${JCONT}merge feature-x"},"cwd":"$REPO"}
EOF
cat > "$TMP/c30.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge ${JCONT}--autostash feature-x"},"cwd":"$TRACKED_REPO"}
EOF

if [ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]; then
    fire git-guardrails.py "$TMP/c1.json"
    expect_deny   "c1 merge on a DIRTY tree is denied"
    fire git-guardrails.py "$TMP/c2.json"
    expect_silent "c2 --abort stays allowed (it is how you get OUT of a dirty merge)"
    fire git-guardrails.py "$TMP/c4.json"
    expect_deny   "c4 ACCEPTED COST: git stash push && git merge in ONE command is DENIED — at r13 by RULE 0 (a history op is accepted only as a STANDALONE simple command), before the tree is even read. Run the two as separate commands. Pinned so it is not 'fixed' back"
    fire git-guardrails.py "$TMP/c5.json"
    expect_deny   "c5 quoted git -C <path> merge on a DIRTY tree is still denied"
    fire git-guardrails.py "$TMP/c6.json"
    expect_deny   "c6 git commit && git merge on a DIRTY tree is denied (no segment licenses a later op)"
    fire git-guardrails.py "$TMP/c7.json"
    expect_deny   "c7 git stash push && touch <file> && git merge on a DIRTY tree is denied (r6 bypass shape)"
    fire git-guardrails.py "$TMP/c8.json"
    expect_deny   "c8 git -C <other clean repo> stash && git merge on a DIRTY tree is denied (r6 bypass shape — the op's OWN cwd is what is read)"
    fire git-guardrails.py "$TMP/c9.json"
    expect_deny   "c9 r13 (referee finding 1): git merge --autostash on a tree whose dirt is an UNTRACKED file is now DENIED — git's autostash does not stash untracked files, so it does NOT establish the precondition this check enforces. This case was expect_silent until r13, on a claim the referee reproduced as false"
    fire git-guardrails.py "$TMP/c10.json"
    expect_deny   "c10 git stash push && echo note > <tracked file> && git merge is denied (r7 bypass shape)"
    fire git-guardrails.py "$TMP/c11.json"
    expect_deny   "c11 r8/r13: cd <other repo> && git merge is denied — r8 because a cd cannot make the tree the guard reads look clean, r13 because a `cd` on a history op's command line now violates RULE 0 outright"
    fire git-guardrails.py "$TMP/c12.json"
    expect_deny   "c12 r8: git stash push && echo \$(touch f) && git merge is denied (a command substitution inside an 'inert' word used to preserve the clean mark)"
    fire git-guardrails.py "$TMP/c13.json"
    expect_deny   "c13 r8: the backtick spelling of the same substitution is denied"
    fire git-guardrails.py "$TMP/c14.json"
    expect_silent "c14 git rebase --continue on a DIRTY tree is allowed (rule 2 escape form, on a different op)"
    fire git-guardrails.py "$TMP/c15.json"
    expect_deny   "c15 git pull --no-autostash on a DIRTY tree is denied (turning git's own autostash OFF does not qualify for the rule-2 exemption)"
    fire git-guardrails.py "$TMP/c16.json"
    expect_deny   "c16 bare git pull on a DIRTY tree is denied (rule 3 on the third history op)"
    fire git-guardrails.py "$TMP/c17.json"
    expect_silent "c17 clean control: a git merge merely MENTIONED in an echo is not a history op — the check stays silent (rule 1)"
    fire git-guardrails.py "$TMP/c18.json"
    expect_deny   "c18 r9: an exempt token inside an option VALUE (git merge -m \"wip --autostash later\") no longer satisfies rule 2 — the exemption is exact-token, not substring"
    fire git-guardrails.py "$TMP/c19.json"
    expect_silent "c19 r9 control, MOVED to the tracked-dirt fixture at r13: a REAL --autostash is still allowed even when a -m value also names an exempt flag — over TRACKED dirt, which is what git's autostash actually handles"
    fire git-guardrails.py "$TMP/c20.json"
    expect_deny   "c20 r9: a compound-command keyword in front of the op (if true; then git merge x; fi) no longer hides it from the check"
    fire git-guardrails.py "$TMP/c21.json"
    expect_deny   "c21 r9: the grouping form of the same hole (git status && (git merge x)) is denied"
    fire git-guardrails.py "$TMP/c22.json"
    expect_deny   "c22 r9: the loop form with an UNRESOLVABLE -C (for d in .; do git -C \$d pull; done) is denied — an unreadable named directory degrades to the event cwd instead of allowing"
    fire git-guardrails.py "$TMP/c23.json"
    expect_deny   "c23 r9: an unenumerated git global option on a history op (git --no-optional-locks pull) is denied"
    fire git-guardrails.py "$TMP/c24.json"
    expect_deny   "c24 r9: the r8-disclosed bare command wrapper (timeout 300 git pull) is now SEEN and denied"
    fire_in "$OTHER_REPO" git-guardrails.py "$TMP/c25.json"
    expect_deny   "c25 r9: a RELATIVE -C is resolved against the EVENT cwd, not the hook process's — fired from the other checkout, git -C . merge on the dirty event repo is denied"
    fire git-guardrails.py "$TMP/c26.json"
    expect_deny   "c26 r9: an exempt token inside a trailing shell COMMENT does not exempt the op"
    fire git-guardrails.py "$TMP/c1.json" GIT_WORK_TREE="$OTHER_REPO" \
         GIT_DIR="$OTHER_REPO/.git" GIT_INDEX_FILE="$OTHER_REPO/.git/index"
    expect_deny   "c27 the INHERITED git environment does not answer for the event cwd: GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE pointing at a CLEAN repo, merge in the DIRTY event repo is still denied"
    fire git-guardrails.py "$TMP/c28.json" GIT_WORK_TREE="$REPO" \
         GIT_DIR="$REPO/.git" GIT_INDEX_FILE="$REPO/.git/index"
    expect_silent "c28 the control for c27, which over-denying cannot satisfy: GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE pointing at the DIRTY repo, merge in a CLEAN event repo stays allowed"
    fire git-guardrails.py "$TMP/c29.json"
    expect_deny   "c29 r12: a history op whose SUBCOMMAND sits on a CONTINUED line (git \\<newline>merge feature-x) on a DIRTY tree is denied — the continuation used to split it into two segments and the tree was never read"
    fire git-guardrails.py "$TMP/c30.json"
    expect_silent "c30 r12 control, MOVED to the tracked-dirt fixture at r13: a continued --autostash (git merge \\<newline>--autostash feature-x) over TRACKED dirt is still allowed — unspliced, the exempt token lands in a SEPARATE segment, which now fails RULE 0 as well as the exemption test"
else
    no "c1 merge on a DIRTY tree is denied" "fixture repo did not come up dirty"
    no "c2 --abort stays allowed" "fixture repo did not come up dirty"
    no "c4 ACCEPTED COST: stash-then-merge in ONE command is denied" "fixture repo did not come up dirty"
    no "c5 quoted git -C merge on a DIRTY tree is denied" "fixture repo did not come up dirty"
    no "c6 git commit && git merge on a DIRTY tree is denied" "fixture repo did not come up dirty"
    no "c7 git stash push && touch <file> && git merge on a DIRTY tree is denied" "fixture repo did not come up dirty"
    no "c8 git -C <other clean repo> stash && git merge on a DIRTY tree is denied" "fixture repo did not come up dirty"
    no "c9 git merge --autostash on a DIRTY tree is allowed" "fixture repo did not come up dirty"
    no "c10 git stash push && echo note > <file> && git merge is denied" "fixture repo did not come up dirty"
    no "c11 cd <other repo> && git merge on a DIRTY session tree is denied" "fixture repo did not come up dirty"
    no "c12 command substitution inside an inert word && git merge is denied" "fixture repo did not come up dirty"
    no "c13 backtick substitution && git merge is denied" "fixture repo did not come up dirty"
    no "c14 git rebase --continue on a DIRTY tree is allowed" "fixture repo did not come up dirty"
    no "c15 git pull --no-autostash on a DIRTY tree is denied" "fixture repo did not come up dirty"
    no "c16 bare git pull on a DIRTY tree is denied" "fixture repo did not come up dirty"
    no "c17 clean control: a mentioned git merge stays silent" "fixture repo did not come up dirty"
    no "c18 an exempt token inside an option VALUE does not exempt the op" "fixture repo did not come up dirty"
    no "c19 control: a REAL --autostash is still exempt" "fixture repo did not come up dirty"
    no "c20 a compound-command keyword does not hide the op" "fixture repo did not come up dirty"
    no "c21 the grouping form is denied" "fixture repo did not come up dirty"
    no "c22 the loop form with an unresolvable -C is denied" "fixture repo did not come up dirty"
    no "c23 an unenumerated git global option on a history op is denied" "fixture repo did not come up dirty"
    no "c24 a bare command wrapper (timeout 300 git pull) is denied" "fixture repo did not come up dirty"
    no "c25 a relative -C is resolved against the EVENT cwd" "fixture repo did not come up dirty"
    no "c26 an exempt token inside a trailing comment does not exempt the op" "fixture repo did not come up dirty"
    no "c27 an inherited GIT_DIR does not answer for the event cwd (deny direction)" "fixture repo did not come up dirty"
    no "c28 an inherited GIT_DIR does not answer for the event cwd (allow direction)" "fixture repo did not come up dirty"
    no "c29 a history op with its subcommand on a CONTINUED line is denied on a dirty tree" "fixture repo did not come up dirty"
    no "c30 control: a continued --autostash is still exempt" "fixture repo did not come up dirty"
fi

git -C "$REPO" add untracked.txt >/dev/null 2>&1
# commit.gpgsign=true / tag.gpgsign=true in a global config would make this
# commit fail on a machine that signs by default (no usable key in the hook's
# non-interactive environment); pin them off, the same defensive posture as the
# identity flags, so the fixture reaches a clean tree for case c3.
git -C "$REPO" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1
if [ -z "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]; then
    fire git-guardrails.py "$TMP/c1.json"
    expect_silent "c3 clean control: the same merge on a CLEAN tree is allowed"
else
    no "c3 clean control: the same merge on a CLEAN tree is allowed" \
       "fixture repo would not go clean"
fi


# ── (c) continued — r13: ENFORCEMENT AT EXECUTION TIME, NOT AT HOOK TIME ----
# An independent frontier-model referee (2026-08-23) found the defect eleven
# in-house rounds missed, because every one of them tested chains in ONE
# direction. This hook decides at PreToolUse -- BEFORE bash runs the command --
# so the referee's case, on a CLEAN repository:
#
#     printf '\n# local work\n' >> analysis.R && git merge main
#
# reads clean at hook time and is dirty when git executes. Rounds 4-12 DENIED the
# chain that CLEANED the tree (c4) and ALLOWED the chain that DIRTIED it: the
# whole false-deny cost, none of the safety, while the docstring's summary and
# law 20 both claimed the stronger guarantee. A history op is therefore accepted
# only as a STANDALONE SIMPLE COMMAND (rule 0) -- a genuinely closed grammar over
# the text the parser sees, rather than a best-effort search for cleaners.
#
# These cases run on the CLEAN fixtures on purpose. On a dirty tree every one of
# them would deny for the ordinary reason and the block could not discriminate at
# all; on a clean tree, a deny can ONLY come from the rule under test. c32, c36,
# c39 and c42 are the controls, and they are what stops rule 0 from being
# satisfied by a guard that denies everything.
cat > "$TMP/c31.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"printf 'x' >> analysis.R && git merge feature-x"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c32.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c33.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git pull | tail -5"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c34.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge \$(cat /tmp/hook-battery-branch-name)"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c35.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge --abort && echo done"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c36.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge -m \"wip && later\" feature-x"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c37.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C \"\$TARGET_REPO\" merge feature-x"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c38.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C /tmp/hook-battery-no-such-repo merge feature-x"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c39.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C $OTHER_REPO merge feature-x"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c40.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git --git-dir=$REPO/.git --work-tree=$REPO merge feature-x"},"cwd":"$OTHER_REPO"}
EOF
cat > "$TMP/c41.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"GIT_DIR=$REPO/.git GIT_WORK_TREE=$REPO git merge feature-x"},"cwd":"$OTHER_REPO"}
EOF

if [ -z "$(git -C "$OTHER_REPO" status --porcelain 2>/dev/null)" ]; then
    fire git-guardrails.py "$TMP/c31.json"
    expect_deny   "c31 r13 THE REFEREE'S FAILING CASE: a write (printf >> analysis.R) chained before a history op is DENIED even though the tree is CLEAN right now -- the tree it reads is not the tree git will see. Allowed before r13"
    fire git-guardrails.py "$TMP/c32.json"
    expect_silent "c32 r13 CONTROL: the same op as a STANDALONE simple command on the same CLEAN tree is allowed -- rule 0 did not buy its recall by denying every history op"
    fire git-guardrails.py "$TMP/c33.json"
    expect_deny   "c33 r13: a PIPELINE carrying a history op is denied on a clean tree (another command runs in the same job)"
    fire git-guardrails.py "$TMP/c34.json"
    expect_deny   "c34 r13: a COMMAND SUBSTITUTION in the op's arguments is denied on a clean tree -- it executes before git does, and r8 already measured \$(touch f) writing to the tree"
    fire git-guardrails.py "$TMP/c35.json"
    expect_deny   "c35 r13: an ESCAPE flag does not license a CHAIN -- git merge --abort && echo done is denied, while the standalone spelling (c2) stays allowed"
    fire git-guardrails.py "$TMP/c36.json"
    expect_silent "c36 r13 CONTROL: shell metacharacters INSIDE a quoted option value are text, not syntax -- git merge -m \"wip && later\" is still allowed on a clean tree, so the rule-0 scan is quote-aware and did not regress to substring matching"
    fire git-guardrails.py "$TMP/c37.json"
    expect_contains "c37 r13 (referee finding 2): an UNRESOLVED -C target denies instead of falling back to the event cwd -- git -C \"\$TARGET_REPO\" with the variable unexpanded, fired from a CLEAN event repo, was SILENT before r13 because the guard read the wrong repository and liked what it saw" \
                    "from that repository, or spell the path literally"
    fire git-guardrails.py "$TMP/c38.json"
    expect_deny   "c38 r13: the same for a -C naming a directory that simply does not exist -- an unanswered question is not an allow"
    fire git-guardrails.py "$TMP/c39.json"
    expect_silent "c39 r13 CONTROL: a -C that DOES resolve, at a clean repository, is still allowed -- denying unresolved selectors did not become denying every -C"
    fire git-guardrails.py "$TMP/c40.json"
    expect_deny   "c40 r13 (referee finding 3): --git-dir/--work-tree select a DIFFERENT repository with no -C and no cd (the referee reproduced native git doing it), so a history op carrying them is denied. Both repositories are CLEAN here, so nothing but the selector rule can produce this deny"
    fire git-guardrails.py "$TMP/c41.json"
    expect_deny   "c41 r13 (referee finding 3, environment form): GIT_DIR=/GIT_WORK_TREE= on the command line select another repository just as directly; every NAME=VALUE assignment on a history op's line is refused, so a future GIT_* variable cannot re-open this"
else
    no "c31 the referee's write-then-op chain is denied on a clean tree" "the OTHER_REPO fixture did not come up clean"
    no "c32 control: a standalone op on a clean tree is allowed" "the OTHER_REPO fixture did not come up clean"
    no "c33 a pipeline carrying a history op is denied" "the OTHER_REPO fixture did not come up clean"
    no "c34 a command substitution in the op's arguments is denied" "the OTHER_REPO fixture did not come up clean"
    no "c35 an escape flag does not license a chain" "the OTHER_REPO fixture did not come up clean"
    no "c36 control: quoted metacharacters are text, not syntax" "the OTHER_REPO fixture did not come up clean"
    no "c37 an unresolved -C target denies" "the OTHER_REPO fixture did not come up clean"
    no "c38 a -C naming a missing directory denies" "the OTHER_REPO fixture did not come up clean"
    no "c39 control: a resolvable -C at a clean repo is allowed" "the OTHER_REPO fixture did not come up clean"
    no "c40 --git-dir/--work-tree on a history op is denied" "the OTHER_REPO fixture did not come up clean"
    no "c41 GIT_DIR=/GIT_WORK_TREE= on a history op is denied" "the OTHER_REPO fixture did not come up clean"
fi

# c42: the ALLOW direction of the r13 --autostash rule, which c9 alone cannot
# show. c9 proves --autostash is refused over UNTRACKED dirt; c42 proves it is
# still accepted over TRACKED dirt, which is exactly what git's stash handles.
# Without this case the referee's fix could have been "delete the exemption",
# and the battery could not tell the two choices apart.
cat > "$TMP/c42.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge --autostash feature-x"},"cwd":"$TRACKED_REPO"}
EOF
TRACKED_STATUS="$(git -C "$TRACKED_REPO" status --porcelain 2>/dev/null)"
if [ -n "$TRACKED_STATUS" ] && ! printf '%s\n' "$TRACKED_STATUS" | grep -q '^??'; then
    fire git-guardrails.py "$TMP/c42.json"
    expect_silent "c42 r13 CONTROL for c9: git merge --autostash over dirt that is ONE MODIFIED TRACKED FILE and no ?? entry is still allowed -- the referee's correction narrowed the exemption to what git's autostash really handles, it did not delete it"
else
    no "c42 control: --autostash over tracked-only dirt is still allowed" \
       "the TRACKED_REPO fixture is not modified-tracked-only (status: ${TRACKED_STATUS:-<empty>})"
fi

# ── (c) continued — r15: THE READING ITSELF WAS THE HOLE ───────────────────
# r13 fixed WHEN the tree is read and WHICH repository is named. r15 is about
# the reading: the question git was asked could be reconfigured, the directory
# it was asked about could be mis-composed, and a question that came back
# UNANSWERED was scored as a pass.
#
#   c43-c46 — `git status --porcelain` HONOURS CONFIGURATION. With
#     `status.showUntrackedFiles=no` (the documented remedy for a slow status
#     on a large worktree) porcelain reports NO `??` lines at all: measured on
#     git 2.50.1, a repo holding one untracked file answers '' to the guard's
#     query and '?? note.txt' to `--untracked-files=normal`. The guard read ''
#     and ALLOWED both a plain merge and an `--autostash` one — reproducing
#     the exact hole r13 narrowed `--autostash` to close, since untracked
#     files are the whole reason that narrowing exists, and satisfying both
#     directions of the c9/c42 control because neither sets the config.
#     c46 is the same class found by auditing the call rather than by a
#     referee: `diff.ignoreSubmodules=all` hides a submodule holding modified
#     work from porcelain (measured: ' M sub' by default, '' with the setting,
#     ' M sub' again with `--ignore-submodules=none`). Both flags are now part
#     of the query, so the repository being guarded cannot reconfigure the
#     reading. c45 is the control: the SAME config on a genuinely clean repo
#     must stay silent, which over-denying cannot satisfy.
#
#   c47-c50 — MULTIPLE `-C` COMPOSE. git(1): "If multiple -C options are
#     given, each subsequent non-absolute -C <path> is interpreted relative to
#     the preceding -C <path>." The guard kept only the LAST one and resolved
#     it against the EVENT cwd, so a trailing relative `-C` discarded a
#     leading absolute one and the guard read a DIFFERENT repository from the
#     one git operates in. Measured: from a clean checkout, real git resolves
#     `-C <dirty> -C .` to <dirty> and the guard ALLOWED the merge. c48 and
#     c50 are the controls that over-denying cannot satisfy — denying every
#     multi-`-C` invocation would pass c47/c49 and fail both.
#
#   c51-c53 — AN UNREADABLE STATUS IS NOT AN ALLOW. `read_status` returned the
#     same None for a timeout, a non-zero exit and "not a repository", and the
#     caller with no `-C` read that as "not a repository → git's problem" and
#     CONTINUED. So a `git status` that merely ran slowly (a large worktree, a
#     cold cache, a network filesystem — and note that the r15 config defect
#     above is the documented remedy for exactly that slowness) was a silent
#     ALLOW on a dirty tree, one line below the `-C` branch that r13 fixed for
#     being the same mistake. c51/c52 shim a `git` on PATH that cannot answer;
#     c53 is the control that keeps the one BENIGN cause allowed.
UNO_REPO="$TMP/uno-repo"
mkdir -p "$UNO_REPO"
git -C "$UNO_REPO" init -q >/dev/null 2>&1
git -C "$UNO_REPO" config status.showUntrackedFiles no >/dev/null 2>&1
: > "$UNO_REPO/note.txt"                       # dirt the config makes invisible

UNO_CLEAN="$TMP/uno-clean"
mkdir -p "$UNO_CLEAN"
git -C "$UNO_CLEAN" init -q >/dev/null 2>&1
git -C "$UNO_CLEAN" config status.showUntrackedFiles no >/dev/null 2>&1
: > "$UNO_CLEAN/kept.txt"
git -C "$UNO_CLEAN" add kept.txt >/dev/null 2>&1
git -C "$UNO_CLEAN" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1

# The submodule fixture for c46. `protocol.file.allow=always` is required by
# git >= 2.38 to add a submodule over a local path; older git ignores the
# unknown config. INNER is committed clean, added to HOST, and only THEN
# modified, so HOST's only dirt is the submodule.
SUB_INNER="$TMP/sub-inner"
mkdir -p "$SUB_INNER"
git -C "$SUB_INNER" init -q >/dev/null 2>&1
printf 'v1\n' > "$SUB_INNER/inner.R"
git -C "$SUB_INNER" add inner.R >/dev/null 2>&1
git -C "$SUB_INNER" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1
SUB_HOST="$TMP/sub-host"
mkdir -p "$SUB_HOST"
git -C "$SUB_HOST" init -q >/dev/null 2>&1
git -C "$SUB_HOST" config diff.ignoreSubmodules all >/dev/null 2>&1
git -C "$SUB_HOST" -c protocol.file.allow=always -c commit.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    submodule add -q "$SUB_INNER" sub >/dev/null 2>&1
git -C "$SUB_HOST" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "add sub" >/dev/null 2>&1
printf 'v2\n' > "$SUB_HOST/sub/inner.R"        # dirt the config makes invisible

# The multi-`-C` fixtures: a DIRTY repo carrying a committed subdirectory (so a
# relative second `-C sub` has somewhere to land), and a CLEAN one.
MC_DIRTY="$TMP/mc-dirty"
mkdir -p "$MC_DIRTY/sub"
git -C "$MC_DIRTY" init -q >/dev/null 2>&1
printf 'v1\n' > "$MC_DIRTY/tracked.R"
printf 'k\n' > "$MC_DIRTY/sub/keep.txt"
git -C "$MC_DIRTY" add tracked.R sub/keep.txt >/dev/null 2>&1
git -C "$MC_DIRTY" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1
printf 'v2\n' > "$MC_DIRTY/tracked.R"          # ' M tracked.R'
MC_CLEAN="$TMP/mc-clean"
mkdir -p "$MC_CLEAN/sub"
git -C "$MC_CLEAN" init -q >/dev/null 2>&1
: > "$MC_CLEAN/kept.txt"
# A `sub/` in BOTH fixtures, and this is what makes c49 able to fail: with the
# pre-r15 last-`-C`-wins reading, `-C sub` resolves against the EVENT cwd and
# lands in mc-clean/sub — a real directory in a CLEAN repository, so the guard
# reads clean and ALLOWS. Without this directory the seeded revert would deny
# c49 anyway, for the unrelated reason that the path does not exist.
: > "$MC_CLEAN/sub/keep.txt"
git -C "$MC_CLEAN" add kept.txt sub/keep.txt >/dev/null 2>&1
git -C "$MC_CLEAN" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1

# The shims for c51/c52: a 'git' on PATH that cannot answer. The battery keeps
# the timeout bound short through CLAUDE_GIT_STATUS_TIMEOUT so the slow case
# costs a second rather than the 10s default.
SHIM_SLOW="$TMP/shim-slow"; mkdir -p "$SHIM_SLOW"
printf '#!/bin/sh\nsleep 3\nexit 0\n' > "$SHIM_SLOW/git"; chmod +x "$SHIM_SLOW/git"
SHIM_FAIL="$TMP/shim-fail"; mkdir -p "$SHIM_FAIL"
printf '#!/bin/sh\necho "fatal: unable to read the index" >&2\nexit 128\n' > "$SHIM_FAIL/git"
chmod +x "$SHIM_FAIL/git"
NOT_A_REPO_DIR="$TMP/not-a-repo"; mkdir -p "$NOT_A_REPO_DIR"

cat > "$TMP/c43.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge --autostash feature-x"},"cwd":"$UNO_REPO"}
EOF
cat > "$TMP/c44.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$UNO_REPO"}
EOF
cat > "$TMP/c45.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$UNO_CLEAN"}
EOF
cat > "$TMP/c46.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$SUB_HOST"}
EOF
cat > "$TMP/c47.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C $MC_DIRTY -C . merge feature-x"},"cwd":"$MC_CLEAN"}
EOF
cat > "$TMP/c48.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C $MC_CLEAN -C . merge feature-x"},"cwd":"$MC_DIRTY"}
EOF
cat > "$TMP/c49.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C $MC_DIRTY -C sub merge feature-x"},"cwd":"$MC_CLEAN"}
EOF
cat > "$TMP/c50.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C $MC_DIRTY -C $MC_CLEAN merge feature-x"},"cwd":"$MC_DIRTY"}
EOF
cat > "$TMP/c51.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$MC_DIRTY"}
EOF
cat > "$TMP/c52.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$MC_DIRTY"}
EOF
cat > "$TMP/c53.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$NOT_A_REPO_DIR"}
EOF

# Every fixture states the precondition that makes its cases able to fail, and
# a fixture that did not reach it is a FAILURE, not a skip.
UNO_HIDDEN="$(git -C "$UNO_REPO" status --porcelain 2>/dev/null)"
UNO_REAL="$(git -C "$UNO_REPO" status --porcelain --untracked-files=normal 2>/dev/null)"
if [ -z "$UNO_HIDDEN" ] && [ -n "$UNO_REAL" ]; then
    fire git-guardrails.py "$TMP/c43.json"
    expect_deny   "c43 r15 (the referee's case): git merge --autostash on a repo configured status.showUntrackedFiles=no, holding an untracked file, is DENIED. Plain porcelain answers '' here, so the guard used to read this tree as CLEAN and allow the very op r13 narrowed --autostash to refuse"
    fire git-guardrails.py "$TMP/c44.json"
    expect_deny   "c44 r15: a PLAIN merge on the same repo is denied too — the config hid the whole of rule 3's evidence, not just the --autostash half"
else
    no "c43 --autostash over config-hidden untracked dirt is denied" \
       "the uno fixture is not in the defect state (plain porcelain: ${UNO_HIDDEN:-<empty>}, -u normal: ${UNO_REAL:-<empty>})"
    no "c44 a plain merge over config-hidden untracked dirt is denied" \
       "the uno fixture is not in the defect state"
fi
if [ -z "$(git -C "$UNO_CLEAN" status --porcelain --untracked-files=normal 2>/dev/null)" ]; then
    fire git-guardrails.py "$TMP/c45.json"
    expect_silent "c45 r15 CONTROL for c43/c44, which over-denying cannot satisfy: the SAME status.showUntrackedFiles=no config on a genuinely CLEAN repo is still allowed — pinning the query did not become refusing every repo that carries the setting"
else
    no "c45 control: the same config on a clean repo stays allowed" \
       "the uno-clean fixture did not come up clean"
fi
SUB_HIDDEN="$(git -C "$SUB_HOST" status --porcelain 2>/dev/null)"
SUB_REAL="$(git -C "$SUB_HOST" status --porcelain --ignore-submodules=none 2>/dev/null)"
if [ -z "$SUB_HIDDEN" ] && [ -n "$SUB_REAL" ]; then
    fire git-guardrails.py "$TMP/c46.json"
    expect_deny   "c46 r15: the SECOND config of the same class — diff.ignoreSubmodules=all hides a submodule holding modified work from porcelain, and the merge over it is denied. Found by auditing the query, not by a referee; it is why the flag is pinned rather than only the untracked one"
else
    no "c46 a merge over config-hidden submodule dirt is denied" \
       "the submodule fixture is not in the defect state (plain porcelain: ${SUB_HIDDEN:-<empty>}, --ignore-submodules=none: ${SUB_REAL:-<empty>})"
fi
MC_DIRTY_STATUS="$(git -C "$MC_DIRTY" status --porcelain 2>/dev/null)"
MC_CLEAN_STATUS="$(git -C "$MC_CLEAN" status --porcelain 2>/dev/null)"
if [ -n "$MC_DIRTY_STATUS" ] && [ -z "$MC_CLEAN_STATUS" ]; then
    fire git-guardrails.py "$TMP/c47.json"
    expect_deny   "c47 r15: git -C <dirty> -C . merge, fired from a CLEAN event cwd, is denied. git composes multiple -C left to right and lands in <dirty>; the guard kept only the LAST one and resolved it against the event cwd, so it read the clean repo and allowed"
    fire git-guardrails.py "$TMP/c48.json"
    expect_silent "c48 r15 CONTROL, which denying every multi--C cannot satisfy: git -C <clean> -C . merge, fired from a DIRTY event cwd, stays allowed — the composed directory is the clean repo, which is where git will actually operate"
    fire git-guardrails.py "$TMP/c49.json"
    expect_deny   "c49 r15: the COMPOSING form, git -C <dirty> -C sub merge from a clean cwd — a relative second -C resolves against the first, not against the event cwd, and the tree read is still the dirty one"
    fire git-guardrails.py "$TMP/c50.json"
    expect_silent "c50 r15 CONTROL: an ABSOLUTE second -C REPLACES the first, so git -C <dirty> -C <clean> merge from the dirty cwd is allowed — the fold follows git's rule rather than picking a -C"
else
    no "c47 a composed -C landing in a dirty repo is denied" "the mc fixtures are not dirty/clean as required"
    no "c48 control: a composed -C landing in a clean repo is allowed" "the mc fixtures are not dirty/clean as required"
    no "c49 a relative second -C composes against the first" "the mc fixtures are not dirty/clean as required"
    no "c50 control: an absolute second -C replaces the first" "the mc fixtures are not dirty/clean as required"
fi
if [ -n "$MC_DIRTY_STATUS" ]; then
    fire git-guardrails.py "$TMP/c51.json" PATH="$SHIM_SLOW:$PATH" CLAUDE_GIT_STATUS_TIMEOUT=1
    expect_contains "c51 r15: a git status that TIMES OUT on a dirty repo is denied, naming the reason. It used to fall into the 'not a repository at all' branch and ALLOW — the same unanswered question r13 fixed for the -C path and left here" \
                    "could not determine the tree state"
    fire git-guardrails.py "$TMP/c52.json" PATH="$SHIM_FAIL:$PATH"
    expect_deny   "c52 r15: a git status that EXITS NON-ZERO inside a real repository is denied too — read_status returned the same None for all three causes and the caller allowed on it"
else
    no "c51 a status that times out denies" "the mc-dirty fixture did not come up dirty"
    no "c52 a status that exits non-zero denies" "the mc-dirty fixture did not come up dirty"
fi
if [ ! -e "$NOT_A_REPO_DIR/.git" ] && [ -z "$(git -C "$NOT_A_REPO_DIR" rev-parse --show-toplevel 2>/dev/null)" ]; then
    fire git-guardrails.py "$TMP/c53.json"
    expect_silent "c53 r15 CONTROL for c51/c52: the one BENIGN unanswered status — a directory that is not a git repository at all — is still allowed. Repo-ness is decided from the FILESYSTEM (a .git at or above the directory), so a broken or shimmed git cannot claim it"
else
    no "c53 control: a directory that is not a repository stays allowed" \
       "the temp directory is inside a git repository, so the control cannot discriminate"
fi

# c54 (r16): the heredoc opener scan reaching the CLEAN-TREE rule, not just the
# deny list (b18-b20). `_strip_heredocs` runs first in `dirty_tree_reason` too,
# so a herestring on line 1 deleted the history op on line 2 and the merge over
# uncommitted work went SILENT. Measured at 7b8848d on a dirty fixture repo.
C54_CMD='tr a-z A-Z <<< hello\ngit merge feature-x'
cat > "$TMP/c54.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"$C54_CMD"},"cwd":"$MC_DIRTY"}
EOF

# c55/c56 (r16): THE DENY MUST FIT INSIDE THE REGISTRATION. A PreToolUse hook
# says "deny" by writing a decision to stdout; the harness kills it at the
# `"timeout"` registered in .claude/settings.json, and a killed hook has written
# NOTHING — which is exactly what an ALLOW looks like. r15 raised the internal
# `git status` bound to 10 s so a slow worktree would not wedge a session, while
# the registration stayed at 5 s, so on that very worktree the deny branch could
# never run. Measured at 7b8848d against a dirty fixture with a `git` shim that
# sleeps 30: unbounded, the hook took 10 s and emitted the deny; under
# `timeout -s KILL 5`, it took 5 s, exited 137 and wrote ZERO BYTES.
#
# c51 above cannot see this — it shortens the internal bound with
# CLAUDE_GIT_STATUS_TIMEOUT=1 and fires the hook with no harness bound at all.
# c55 does the opposite: the internal bound is left at its shipped default and
# the hook is run UNDER the registered one, killed at it like the harness would.
# `timeout(1)` is not on a stock macOS, so the bound is enforced from python3,
# which the battery already requires.
cat > "$TMP/under_registration.py" <<'PYEOF'
import subprocess, sys, time
hook, event, budget = sys.argv[1], sys.argv[2], float(sys.argv[3])
with open(event) as fh:
    p = subprocess.Popen([sys.executable, hook], stdin=fh,
                         stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                         text=True)
    t0 = time.time()
    try:
        out, _ = p.communicate(timeout=budget)
    except subprocess.TimeoutExpired:
        p.kill(); p.communicate()
        print("KILLED-AT-THE-REGISTERED-BOUND-%gs-NO-DECISION-WRITTEN" % budget)
        raise SystemExit(0)
el = time.time() - t0
if '"permissionDecision": "deny"' in (out or ""):
    print("deny-returned-within-the-registration (%.1fs of %gs)" % (el, budget))
else:
    print("NO-DENY-EMITTED in %.1fs: %r" % (el, (out or "")[:160]))
PYEOF

# A `git` that never answers inside the hook's own default bound, so the deny
# branch is the one under test rather than the shim's exit code.
SHIM_STALLED="$TMP/shim-stalled"; mkdir -p "$SHIM_STALLED"
printf '#!/bin/sh\nsleep 60\nexit 0\n' > "$SHIM_STALLED/git"; chmod +x "$SHIM_STALLED/git"
cat > "$TMP/c55.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git merge feature-x"},"cwd":"$MC_DIRTY"}
EOF
GG_REG="$(python3 -c '
import json, sys
for gs in json.load(open(sys.argv[1]))["hooks"].get("PreToolUse", []):
    for h in gs["hooks"]:
        if "git-guardrails.py" in h.get("command", ""):
            print(h.get("timeout"))
' "$ROOT/.claude/settings.json" 2>/dev/null | head -1)"

if [ -n "$MC_DIRTY_STATUS" ]; then
    fire git-guardrails.py "$TMP/c54.json"
    expect_deny   "c54 r16: a HERESTRING on line 1 no longer swallows the history op on line 2 — the merge over a dirty tree is seen and denied. _strip_heredocs runs first in dirty_tree_reason too, so this silenced the clean-tree rule as well as the deny list"
    if [ -n "$GG_REG" ]; then
        OUT="$(env -u ALLOW_ROOT_OF_TRUST_WRITE -u ALLOW_DIRTY_MERGE -u CLAUDE_STRICT_PATHS \
               -u CLAUDE_GIT_STATUS_TIMEOUT "${UNSET_GIT_ENV[@]}" PATH="$SHIM_STALLED:$PATH" \
               python3 "$TMP/under_registration.py" "$HOOKS/git-guardrails.py" \
               "$TMP/c55.json" "$GG_REG" 2>/dev/null)"
        verdict "$OUT"
    else
        verdict "NO-REGISTRATION-FOUND: .claude/settings.json registers no timeout for git-guardrails.py"
    fi
    expect_contains "c55 r16: with a stalled git and the SHIPPED internal bound, git-guardrails.py still RETURNS a deny inside the timeout it is registered with. A hook killed before it writes a decision is indistinguishable from one that allowed, so a deny branch that cannot finish inside the registration does not exist" \
                    "deny-returned-within-the-registration"
else
    no "c54 a herestring no longer hides a history op on a dirty tree" "the mc-dirty fixture did not come up dirty"
    no "c55 the deny is returned inside the registered timeout" "the mc-dirty fixture did not come up dirty"
fi

# c56: the two numbers c55 depends on, pinned against each other and against
# settings.json — so raising one without the other goes red here instead of
# silently re-opening the hole. Also proves CLAUDE_GIT_STATUS_TIMEOUT is CLAMPED:
# the deny message used to tell the user to raise it, which moved them further
# from a deny, not closer.
C56="$(python3 - "$HOOKS/git-guardrails.py" "$ROOT/.claude/settings.json" <<'PYEOF' 2>/dev/null
import importlib.util, json, os, sys
spec = importlib.util.spec_from_file_location("_gg_budget_probe", sys.argv[1])
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
reg = None
for gs in json.load(open(sys.argv[2]))["hooks"].get("PreToolUse", []):
    for h in gs["hooks"]:
        if "git-guardrails.py" in h.get("command", ""):
            reg = float(h.get("timeout"))
decl = getattr(mod, "_HOOK_REGISTERED_TIMEOUT", None)
ceiling = getattr(mod, "_STATUS_TIMEOUT_CEILING", None)
if decl is None or ceiling is None:
    print("NO-DECLARED-BOUND: the hook states no _HOOK_REGISTERED_TIMEOUT/_STATUS_TIMEOUT_CEILING")
elif reg is None:
    print("NOT-REGISTERED: no PreToolUse entry names git-guardrails.py")
elif reg != decl:
    print("REGISTRATION-DRIFT: settings.json registers %gs, the hook declares %gs" % (reg, decl))
elif not ceiling < reg:
    print("BUDGET-NOT-UNDER-REGISTRATION: internal ceiling %gs, registration %gs" % (ceiling, reg))
else:
    os.environ["CLAUDE_GIT_STATUS_TIMEOUT"] = "600"
    got = mod._status_timeout()
    if got > ceiling:
        print("ENV-NOT-CLAMPED: CLAUDE_GIT_STATUS_TIMEOUT=600 yielded %gs" % got)
    else:
        print("budget-strictly-under-the-registration (%gs < %gs; env 600 clamped to %gs)"
              % (ceiling, reg, got))
PYEOF
)"
verdict "$C56"
expect_contains "c56 r16: git-guardrails.py's internal git-status budget is STRICTLY under the timeout it is registered with in .claude/settings.json, both numbers derive from one declared constant, and CLAUDE_GIT_STATUS_TIMEOUT is clamped rather than honoured — an escape hatch that pushes the bound past the registration is a silent allow, not a longer wait" \
                "budget-strictly-under-the-registration"

# ── (c) continued — r18: THE `-C` FOLD WAS LEXICAL, GIT'S IS THE KERNEL'S ──
# c47-c50 fixed WHICH `-C` wins. r18 is about how each one is RESOLVED. The fold
# went through `os.path.normpath`, which pops a `..` off the path as WRITTEN;
# git folds `-C` by `chdir()`, and the kernel pops a `..` off the path RESOLVED
# — the physical parent of a symlink's TARGET, not of the link. The two diverge
# the instant a `..` follows a symlinked component, and the guard's own
# docstring claimed it read "the directory git will chdir into".
#
# Measured at e0c4cdb on the fixtures below: `git -C link/.. rev-parse
# --show-toplevel` fired from the CLEAN repo prints the DIRTY one, while
# `normpath` prints the clean one. The guard read the clean tree, said nothing,
# and real bash then fast-forwarded the dirty repository — 'Updating
# b558893..4fe1bdd / Fast-forward', its HEAD advanced, its ' M sub/f.txt' still
# sitting there on top of merged history. That is the exact outcome the
# clean-tree rule exists to refuse, reached with no `cd` (rule 0 denies those),
# no chain, and no unresolvable selector: it resolves — to the wrong repository.
# The byte-equivalent `-C <dirty absolute>` DENIED, so the verdict turned on
# whether the path was spelled through the symlink.
#
# c62-c64 are the controls, and c63 is the sharp one: a `..` that follows a
# symlink but LANDS IN THE CLEAN REPOSITORY must stay allowed, because that is
# where git will actually operate. A "deny whenever `..` follows a symlink"
# repair passes c57-c61 and fails c63; the kernel-faithful fold passes both.
#
# CORRECTED AT r19: c60 (the ATTACHED `-Clink/..`) was recorded here as one of
# the spellings that reached the r18 false ALLOW. It cannot have been — git
# rejects an attached `-C<path>` outright (`git -C.` exits 129 on 2.50.1, while
# `git -C .` exits 0), so that spelling never runs at all. It is relabelled
# below as a DEFENSIVE CONTROL and is no longer counted as a reproduction; the
# demonstrated r18 class is the FOUR separated spellings c57-c59 and c61.
SYM_DIRTY="$TMP/sym-dirty"
mkdir -p "$SYM_DIRTY/sub"
git -C "$SYM_DIRTY" init -q >/dev/null 2>&1
printf 'v1\n' > "$SYM_DIRTY/sub/f.txt"
git -C "$SYM_DIRTY" add sub/f.txt >/dev/null 2>&1
git -C "$SYM_DIRTY" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1
printf 'v2\n' > "$SYM_DIRTY/sub/f.txt"         # ' M sub/f.txt'

SYM_CLEAN="$TMP/sym-clean"
mkdir -p "$SYM_CLEAN/sub"
git -C "$SYM_CLEAN" init -q >/dev/null 2>&1
printf 'k\n' > "$SYM_CLEAN/sub/keep.txt"
# MSYS `ln -s` COPIES unless asked for a native symlink, and a copy cannot
# exercise a case about what a link resolves to. nativestrict makes it fail
# loudly instead of copying silently; Windows grants the privilege only under
# Developer Mode or elevation, which cases c57-c64 then report as unreached.
export MSYS="${MSYS:-}${MSYS:+ }winsymlinks:nativestrict"
ln -s "$SYM_DIRTY/sub" "$SYM_CLEAN/link"        # -> the DIRTY repo's subdirectory
ln -s "$SYM_CLEAN/sub" "$SYM_CLEAN/selflink"    # -> this CLEAN repo's own subdirectory
git -C "$SYM_CLEAN" add sub/keep.txt link selflink >/dev/null 2>&1
git -C "$SYM_CLEAN" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "seed" >/dev/null 2>&1

cat > "$TMP/c57.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C link/.. merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF
cat > "$TMP/c58.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C ./link/.. merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF
cat > "$TMP/c59.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C link/../. merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF
cat > "$TMP/c60.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -Clink/.. merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF
cat > "$TMP/c61.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C . -C link/.. merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF
cat > "$TMP/c62.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C sub/.. merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF
cat > "$TMP/c63.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C selflink/.. merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF
cat > "$TMP/c64.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git -C link merge feature-x"},"cwd":"$SYM_CLEAN"}
EOF

# The precondition that makes these cases able to fail, stated and CHECKED: the
# kernel must land `link/..` in the DIRTY repo while a lexical fold lands
# somewhere else, and the two fixtures must really be dirty and clean.
SYM_LANDS="$(git -C "$SYM_CLEAN/link/.." rev-parse --show-toplevel 2>/dev/null)"
SYM_REAL_DIRTY="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$SYM_DIRTY" 2>/dev/null)"
SYM_LEXICAL="$(python3 -c 'import os,sys; print(os.path.normpath(sys.argv[1]))' "$SYM_CLEAN/link/.." 2>/dev/null)"
SYM_DIRTY_STATUS="$(git -C "$SYM_DIRTY" status --porcelain 2>/dev/null)"
SYM_CLEAN_STATUS="$(git -C "$SYM_CLEAN" status --porcelain 2>/dev/null)"
if [ -n "$SYM_LANDS" ] && [ "$SYM_LANDS" = "$SYM_REAL_DIRTY" ] \
   && [ "$SYM_LEXICAL" != "$SYM_LANDS" ] \
   && [ -n "$SYM_DIRTY_STATUS" ] && [ -z "$SYM_CLEAN_STATUS" ]; then
    fire git-guardrails.py "$TMP/c57.json"
    expect_deny   "c57 r18 THE AUDITOR'S FAILING CASE: git -C link/.. merge, fired from a CLEAN repo whose tracked symlink points into a DIRTY one, is denied. The fold was lexical (normpath popped 'link'), git's is the kernel's (chdir pops the LINK TARGET's parent), so the guard read the clean tree and bash then fast-forwarded the dirty repository with the uncommitted work still in it"
    fire git-guardrails.py "$TMP/c58.json"
    expect_deny   "c58 r18: the ./-prefixed spelling (-C ./link/..) reaches the same repository and is denied"
    fire git-guardrails.py "$TMP/c59.json"
    expect_deny   "c59 r18: a trailing . after the climb (-C link/../.) is denied — the class is the resolution, not one spelling"
    fire git-guardrails.py "$TMP/c60.json"
    expect_deny   "c60 r19 DEFENSIVE CONTROL over a spelling GIT ITSELF REJECTS (relabelled at r19; it was recorded as an r18 reproduction). git does NOT accept an attached -C<path>: measured on the git this file's other numbers come from (2.50.1, Apple Git-155), 'git -C . status --porcelain' exits 0 while 'git -C. status --porcelain' exits 129, 'unknown option: -C.'. So -Clink/.. could never have reached the r18 false ALLOW, and counting it inflated that recall class by one spelling. The case stays because _walk_git_globals does parse the attached form and must keep denying it if a future git ever accepts it — but it demonstrates nothing about the r18 defect"
    fire git-guardrails.py "$TMP/c61.json"
    expect_deny   "c61 r18: the COMPOSED form (-C . -C link/..) is denied — the r15 left-to-right fold and the r18 kernel resolution hold together, not one at the other's expense"
    fire git-guardrails.py "$TMP/c62.json"
    expect_silent "c62 r18 CONTROL: an ORDINARY -C sub/.. inside ONE repository, with no symlink anywhere, still reads that repository — clean here, so still allowed. Resolving through the kernel did not become denying every -C that carries a .."
    fire git-guardrails.py "$TMP/c63.json"
    expect_silent "c63 r18 CONTROL, the sharp one: a .. that follows a SYMLINK but lands back in the CLEAN repo (-C selflink/..) stays allowed — a 'deny whenever .. follows a symlink' repair passes c57-c61 and fails HERE, because the guard would be refusing the repository git actually operates in"
    fire git-guardrails.py "$TMP/c64.json"
    expect_deny   "c64 r18 CONTROL: a -C through a symlink with NO .. (-C link, landing in the dirty repo's subdirectory) keeps its pre-r18 verdict — it denied before the fix and denies after, so the change is confined to the .. resolution"
else
    no "c57 a -C whose .. follows a symlink is read in the repository git lands in" \
       "the sym fixtures are not in the defect state (kernel lands: ${SYM_LANDS:-<none>}, dirty realpath: ${SYM_REAL_DIRTY:-<none>}, lexical: ${SYM_LEXICAL:-<none>}, dirty porcelain: ${SYM_DIRTY_STATUS:-<empty>}, clean porcelain: ${SYM_CLEAN_STATUS:-<empty>})"
    no "c58 the ./-prefixed spelling of the same" "the sym fixtures are not in the defect state"
    no "c59 the trailing-dot spelling of the same" "the sym fixtures are not in the defect state"
    no "c60 defensive control: the attached -Clink/.. spelling git itself rejects" "the sym fixtures are not in the defect state"
    no "c61 the composed -C . -C link/.. spelling of the same" "the sym fixtures are not in the defect state"
    no "c62 control: an ordinary -C sub/.. stays allowed" "the sym fixtures are not in the defect state"
    no "c63 control: a .. past a symlink landing in the CLEAN repo stays allowed" "the sym fixtures are not in the defect state"
    no "c64 control: a -C through a symlink with no .. keeps its verdict" "the sym fixtures are not in the defect state"
fi

# ── (c) continued — r19: THE PARSER'S OWN SPELLINGS REACH THE TREE READING ──
# The deny list (b24-b33) and the clean-tree precondition go through the SAME
# `_segments` → `_unquote` → `_git_segment` parser, and r10 shared it precisely
# so the two halves of one guard could not disagree about what a command says.
# Both r19 spellings therefore have to be pinned on THIS side too, or the fix is
# only known to hold on the half that was measured. Against the shipped hook on
# a dirty fixture, `git $'merge' other` and `Git merge other` were both ALLOWED
# (silent) while `git merge other` DENIED.
#
# c67 is the control that stops the case fold from being a blanket deny: the
# SAME uppercase invocation in a CLEAN repository must still be allowed, because
# the verdict is supposed to be the tree reading and not the spelling. c68 is
# the other direction — a `$'…'` word that is not a history op at all stays
# silent, so recognising the opener did not turn every quoted word into a merge.
#
# These need their OWN pair of fixtures: `$REPO` starts dirty but is committed
# clean at the r15 block above (that is what its clean-tree controls need), so a
# case placed down here that expected `$REPO` to be dirty would pass for the
# wrong reason — or, as it did while this block was being written, fail for the
# right one.
R19_DIRTY="$TMP/r19-dirty"
mkdir -p "$R19_DIRTY"
git -C "$R19_DIRTY" init -q >/dev/null 2>&1
: > "$R19_DIRTY/untracked.txt"     # one untracked file == a dirty tree
R19_CLEAN="$TMP/r19-clean"
mkdir -p "$R19_CLEAN"
git -C "$R19_CLEAN" init -q >/dev/null 2>&1   # no files == a clean tree

cat > "$TMP/c65.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git \$'merge' feature-x"},"cwd":"$R19_DIRTY"}
EOF
cat > "$TMP/c66.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"GIT merge feature-x"},"cwd":"$R19_DIRTY"}
EOF
cat > "$TMP/c67.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"GIT merge feature-x"},"cwd":"$R19_CLEAN"}
EOF
cat > "$TMP/c68.json" <<EOF
{"tool_name":"Bash","tool_input":{"command":"git \$'log' --oneline -5"},"cwd":"$R19_DIRTY"}
EOF

fire git-guardrails.py "$TMP/c65.json"
expect_deny   "c65 r19: an ANSI-C quoted history VERB (git \$'merge' feature-x) on a dirty tree is denied — the clean-tree precondition reads the same tokens the deny list does, so the \$-quoting hole silenced this half as well"
fire git-guardrails.py "$TMP/c66.json"
expect_deny   "c66 r19: the case-varied program word (GIT merge feature-x) on a dirty tree is denied — the uppercase spelling really runs git on a case-insensitive filesystem"
fire git-guardrails.py "$TMP/c67.json"
expect_silent "c67 r19 CONTROL: the SAME uppercase invocation in a CLEAN repository stays allowed — the verdict is still the live tree reading, not the spelling of the command word"
fire git-guardrails.py "$TMP/c68.json"
expect_silent "c68 r19 CONTROL: a \$'…' word that is not a history op (git \$'log' --oneline -5) stays silent on a dirty tree — teaching the unquoter an opener did not make every quoted word a merge"

# ── (d) claim-reconcile ────────────────────────────────────────────────────
# One synthetic passport, one claim: produced by an analysis script, shown in
# two places. Editing the producer stales it; editing one display puts it out
# of step with the other; editing an unrelated file must say nothing.
echo ""
echo "  (d) claim-reconcile.py — numeric claims a just-edited file can stale"

PROJ="$TMP/proj"
mkdir -p "$PROJ/quality_reports/passports" "$PROJ/scripts"
cat > "$PROJ/quality_reports/passports/demo.yaml" <<'EOF'
claims:
  - id: C1
    description: headline estimate
    source_file: scripts/analysis.R
    location: paper.tex
    appears_in:
      - path: paper.tex
      - path: slides.qmd
EOF
: > "$PROJ/scripts/analysis.R"
: > "$PROJ/paper.tex"
: > "$PROJ/slides.qmd"
: > "$PROJ/notes.md"

cat > "$TMP/d1.json" <<EOF
{"tool_name":"Edit","tool_input":{"file_path":"$PROJ/scripts/analysis.R"},"cwd":"$PROJ"}
EOF
cat > "$TMP/d2.json" <<EOF
{"tool_name":"Edit","tool_input":{"file_path":"$PROJ/paper.tex"},"cwd":"$PROJ"}
EOF
cat > "$TMP/d3.json" <<EOF
{"tool_name":"Edit","tool_input":{"file_path":"$PROJ/notes.md"},"cwd":"$PROJ"}
EOF

# HOME is redirected so the hook's per-session throttle state lands in the temp
# directory: no leftovers, and no earlier run can throttle this one into silence.
fire claim-reconcile.py "$TMP/d1.json" HOME="$TMP" CLAUDE_PROJECT_DIR="$PROJ"
expect_contains "d1 editing the source script flags the claim STALE" "STALE"
fire claim-reconcile.py "$TMP/d2.json" HOME="$TMP" CLAUDE_PROJECT_DIR="$PROJ"
expect_contains "d2 editing one display warns the others may disagree" "disagree"
fire claim-reconcile.py "$TMP/d3.json" HOME="$TMP" CLAUDE_PROJECT_DIR="$PROJ"
expect_silent   "d3 clean control: a file no passport mentions is silent"

# ── (e) the battery's own isolation from git's hook environment ────────────
# This battery runs INSIDE .githooks/pre-commit. Everything above is worthless
# if the battery's own fixtures escape into the repository the hook was fired
# from — and for one release they did: `git -C <fixture>` does not isolate
# against an exported GIT_DIR, so from a linked worktree the fixture's
# init/add/commit wrote a junk `seed` commit onto the USER'S branch, left a
# phantom deletion in their tree, and aborted their commit on every retry.
#
# The check re-enters this script with git's hook environment exported at a
# DECOY repository — the same two variables git really exports, absolute, as
# they arrive from a linked worktree — and then asks the decoy three questions.
#
# The three verdicts are computed here and handed to `expect_contains` through
# `verdict`, rather than calling ok/no directly, because the derived-counts
# gate counts `expect_` CALL SITES as the case count and the battery prints
# PASS+FAIL: a case that skips the helpers makes those two numbers disagree,
# which is the drift that gate exists to stop. Exactly three calls are made on
# every path, including the one where the decoy repo cannot be built.
echo ""
echo "  (e) hook-battery.sh — isolation from the git environment it runs inside"

DECOY="$TMP/decoy"
mkdir -p "$DECOY"
git -C "$DECOY" init -q >/dev/null 2>&1
: > "$DECOY/keep.txt"
git -C "$DECOY" add keep.txt >/dev/null 2>&1
git -C "$DECOY" -c commit.gpgsign=false -c tag.gpgsign=false \
    -c user.email=battery@example.invalid -c user.name=hook-battery \
    commit -q -m "decoy baseline" >/dev/null 2>&1
DECOY_HEAD_BEFORE="$(git -C "$DECOY" rev-parse HEAD 2>/dev/null)"

E1=""; E2=""; E3=""
if [ -z "$DECOY_HEAD_BEFORE" ]; then
    E1="DECOY-REPO-UNUSABLE: it would not reach a baseline commit"
    E2="$E1"; E3="$E1"
else
    SELFTEST_OUT="$(GIT_DIR="$DECOY/.git" GIT_INDEX_FILE="$DECOY/.git/index" \
                    GIT_PREFIX="" bash "$SELF_PATH" --fixture-selftest 2>/dev/null)"
    SELFTEST_RC=$?
    DECOY_HEAD_AFTER="$(git -C "$DECOY" rev-parse HEAD 2>/dev/null)"
    DECOY_STATUS="$(git -C "$DECOY" status --porcelain 2>/dev/null)"

    # e1: the fixture's own commit must be UNREACHABLE from the inherited
    # repository — not merely "a different sha". Before the fix the child
    # printed a real sha too; it was just the decoy's, freshly written.
    if [ "$SELFTEST_RC" -ne 0 ] || [ -z "$SELFTEST_OUT" ]; then
        E1="FIXTURE-BUILD-FAILED: the self-test exited $SELFTEST_RC saying '${SELFTEST_OUT:-<empty>}' (the user's own commit fails the same way)"
    elif git -C "$DECOY" cat-file -e "${SELFTEST_OUT}^{commit}" 2>/dev/null; then
        E1="FIXTURE-COMMIT-LANDED-IN-THE-INHERITED-REPO: $SELFTEST_OUT exists there, so the exported GIT_DIR was honoured"
    else
        E1="fixture-commit-absent-from-inherited-repo"
    fi

    if [ "$DECOY_HEAD_AFTER" = "$DECOY_HEAD_BEFORE" ]; then
        E2="inherited-HEAD-unmoved"
    else
        E2="INHERITED-HEAD-MOVED: $DECOY_HEAD_BEFORE -> $DECOY_HEAD_AFTER"
    fi

    if [ -z "$DECOY_STATUS" ]; then
        E3="inherited-tree-untouched"
    else
        E3="INHERITED-TREE-DIRTIED: $DECOY_STATUS"
    fi
fi

verdict "$E1"
expect_contains "e1 a fixture built under git's hook environment commits into the FIXTURE, not into the repository the environment names" \
                "fixture-commit-absent-from-inherited-repo"
verdict "$E2"
expect_contains "e2 the inherited repository's HEAD is untouched (no junk 'seed' commit lands on the user's branch)" \
                "inherited-HEAD-unmoved"
verdict "$E3"
expect_contains "e3 the inherited repository's working tree is untouched (no phantom deletion left behind)" \
                "inherited-tree-untouched"

# ── verdict ────────────────────────────────────────────────────────────────
TOTAL=$((PASS + FAIL))
echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "hook-battery: ALL PASS ($TOTAL cases)"
    exit 0
fi
echo "hook-battery: $FAIL of $TOTAL cases FAILED:"
for f in "${FAILED[@]}"; do echo "  - $f"; done
echo "A guard that no longer fires is worse than no guard: it looks like coverage."
exit 1
