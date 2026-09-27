#!/usr/bin/env python3
"""Verify enumerable claims that surface-sync does not cover.

surface-sync checks skills/agents/rules/hooks. This checks the OTHER numbers a
reader might rely on — journal profiles, workflow patterns, TikZ snippets,
translation phases, review passes — each counted from its own source of truth.

Exit: 0 all claims match, 1 mismatch, 2 internal error.
"""
import glob, re, os, subprocess, sys
from collections import namedtuple

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def read(p):
    try: return open(os.path.join(ROOT, p), encoding="utf-8", errors="ignore").read()
    except FileNotFoundError: return ""

def n_econ_journals():
    t = read(".claude/references/journal-profiles.md")
    seg = re.search(r'^## Econ Top.*?(?=^## (?!#)|\Z)', t, re.S | re.M)
    return len(re.findall(r'^### ', seg.group(0), re.M)) if seg else 0

def n_patterns():
    return len(set(re.findall(r'^#{2,3} Pattern (\d+)', read("guide/workflow-guide.qmd"), re.M)))

def n_tikz():
    d = os.path.join(ROOT, "templates", "tikz-snippets")
    return len([f for f in os.listdir(d) if f.endswith(".tex")]) if os.path.isdir(d) else 0

def n_translate_phases():
    # \d+(?:\.\d+)? so an inserted phase (6.5) counts as its own phase, not as a second "6"
    ph = set(re.findall(r'^#{2,4} Phase (\d+(?:\.\d+)?)', read(".claude/skills/translate-to-quarto/SKILL.md"), re.M))
    return len(ph - {"0"})            # Phase 0 is pre-flight, not a translation phase

def n_gates():
    t = read("scripts/backtest.sh")
    n = len(re.findall(r'^run "', t, re.M))
    return n

# --- release-inventory counts -------------------------------------------------
#
# These MIRROR check-surface-sync.py's GROUND_TRUTH definitions exactly — skills
# are `*/SKILL.md`, agents/rules are `*.md`, hooks are `*.py` + `*.sh` — so the
# two gates can never disagree about what a "skill" or a "hook" is. If you change
# a definition there, change it here in the same commit.
def _glob_count(pat):
    # glob.escape: a clone at "Paper [2026]" read its own path as a character class,
    # counted 0 of everything, and failed on four true claims (#171).
    return len(glob.glob(os.path.join(glob.escape(ROOT), pat)))

def n_skills(): return _glob_count(".claude/skills/*/SKILL.md")
def n_agents(): return _glob_count(".claude/agents/*.md")
def n_rules():  return _glob_count(".claude/rules/*.md")
def n_hooks():  return _glob_count(".claude/hooks/*.py") + _glob_count(".claude/hooks/*.sh")


def changelog_current_release():
    """The text under the TOPMOST `## v…` heading of CHANGELOG.md, and nothing else.

    WHY THIS IS SCOPED, and not simply "scan CHANGELOG.md" the way every other
    row scans a whole file: the changelog keeps the `**Inventory at release: …**`
    line of EVERY past release. Those numbers were TRUE at their release and are
    a historical record — `.claude/references/audit-pet-peeves.md` #12
    ("historical CHANGELOG entries — do not update") is why CHANGELOG.md is not a
    check-surface-sync surface at all. Comparing them against today's disk would
    turn a CORRECT record red, and the only way to quiet that red would be to
    falsify or delete the history. So the view handed to the gate ends at the
    next `## ` heading: exactly ONE inventory line — the current release's — is
    ever compared, and v2.5.0's `36 rules, 7 hooks` (correct then, wrong now) is
    invisible to it.

    The window MOVES on its own. When the next release heading is added above,
    the line this gate checks becomes that release's, and the previous one
    becomes history — on the same commit, with no gate change and no exclusion
    list to maintain. And because these rows' surface is REQUIRED, deleting or
    rewording the current inventory line does not silently drop coverage: the
    row reports NO CLAIM MATCHED and the gate goes red.
    """
    m = re.search(r'^## v[^\n]*\n(.*?)(?=^## |\Z)', read("CHANGELOG.md"), re.S | re.M)
    return m.group(1) if m else ""

def n_hook_battery_cases():
    # The battery prints "ALL PASS (N cases)" where N = TOTAL = PASS + FAIL + UNREACH —
    # the `TOTAL=$((PASS + FAIL + UNREACH))` roll-up in the final summary block of
    # scripts/hook-battery.sh (find it with `grep -n 'ALL PASS'`; it is cited
    # by name, not by line number, because line numbers rot as the battery
    # grows — this comment previously said "line ~276", which by round 7
    # pointed into an unrelated fixture comment). Every case runs exactly one
    # expect_ helper (expect_deny / expect_silent / expect_contains). Count
    # those CALL sites — the SAME tokens the battery itself counts — so this
    # gate and the battery's printed N can never disagree. A call is the helper
    # name followed by whitespace (`expect_deny   "a1..."`); a definition is the
    # name followed by `()` (`expect_deny() {`), so the `[ \t]` after the name
    # excludes the three definitions.
    t = read("scripts/hook-battery.sh")
    return len(re.findall(r'^[ \t]*expect_(?:deny|silent|contains)[ \t]', t, re.M))


def _battery_sections():
    """hook-battery.sh split by its own `# ── (x) ` section banners, so a count
    can be taken PER GUARD as well as for the whole battery."""
    parts = re.split(r'^# ── \((\w)\) ', read("scripts/hook-battery.sh"), flags=re.M)
    secs = {}
    for i in range(1, len(parts) - 1, 2):
        secs[parts[i]] = secs.get(parts[i], "") + parts[i + 1]
    return secs

def n_battery_named(letters):
    # The LEDGER's grading-the-grader row records, per guard, the expect_deny /
    # expect_contains cases in that guard's OWN `# ── (x)` sections. Until
    # 2026-08-23 these three numbers (17 / 13 / 2) were the ledger's own,
    # ungated: planting 99 in each left every gate green, which is the r7 defect
    # one document over.
    #
    # NARROWED 2026-08-24, and the narrowing IS the fix. This comment used to
    # assert a premise the count does not support: "a stub allows everything, so
    # exactly the expect_deny / expect_contains cases in that guard's sections
    # fail — count those call sites." False, and falsifiably so. A section letter
    # records which hook a case FIRES; a stub outcome turns on which hook
    # DECIDES, and those are two different partitions.
    # `root-of-trust-guard.py` imports `git-guardrails.py` and delegates the
    # destructive-verb deny list to it, so a set of section-(a) cases go red
    # under EITHER guard's stub. MEASURED at 727a66c, with an import-safe
    # always-allow stub of `git-guardrails.py` built exactly as the ledger's
    # reproduction note prescribes and run as
    #   HOOK_DIR=<copy> bash scripts/hook-battery.sh
    # the run reddened 81 cases — 8 in (a) + 24 in (b) + 49 in (c) — against the
    # 73 this function returns for "bc". So the gate did not merely miss the
    # right number, it DEFENDED the wrong one: planting the reproducible 81 in
    # the ledger made check-derived-counts FAIL.
    #
    # Widening the count was tried first and measured wrong inside the same
    # session, which is why the claim is narrowed instead. Widening needs a way
    # to IDENTIFY the routed cases, and the battery offers only prose — the
    # `CROSS-HOOK` marker some labels carry. That proxy was implemented and
    # returned 8; the r20 wave then added `a106`, a case the sibling decides
    # whose label says "cross-hook" in running prose and carries no marker, so
    # the marker-derived figure said 81 while the stub reddened 82. Which guard
    # DECIDES a case is a RUNTIME property. No static read of the battery text
    # recovers it, and a gate resting on an unenforced labelling convention
    # under-counts SILENTLY — precisely the failure this file exists to prevent.
    #
    # So the gate certifies what it can actually compute: the per-guard section
    # tally, which is also each guard row's N and the companion of its FPR
    # denominator. The stub OUTCOMES live in the ledger's reproduction note as
    # dated measurements carrying the command that reproduces them — a number
    # nobody can derive from this file should not be asserted by this file.
    secs = _battery_sections()
    body = "".join(secs.get(l, "") for l in letters)
    return len(re.findall(r'^[ \t]*expect_(?:deny|contains)[ \t]', body, re.M))


def n_laws():
    # Each law in research-agent-laws.md opens a paragraph as **N. Title.**
    # Counting the numbered openers keeps CLAUDE.md's "N laws" honest: the
    # count was hand-edited 17 -> 21 once, with nothing to catch a wrong value.
    t = read(".claude/references/research-agent-laws.md")
    return len(re.findall(r'^\*\*(\d+)\.', t, re.M))

def n_rungs():
    # CLAUDE.md's "the seven rungs" is the same shape as the law count two
    # bullets below it — an enumerable count of another file's headings — and it
    # sat UNGATED in the very hunk where the law count was corrected 17 -> 21 and
    # gated. A planted-lie probe confirmed it: "the ninety-nine rungs" left every
    # gate at exit 0. Not hypothetical drift either: verification-ladder.md grew a
    # whole section this release. Counted from the rung headings themselves.
    return len(re.findall(r'^## Rung ', read(".claude/references/verification-ladder.md"), re.M))

# English number words 0-99, so a spelled-out count ("Twelve cases",
# "Twenty-two cases") is compared as a number like a digit claim.
_ONES = {"zero":0,"one":1,"two":2,"three":3,"four":4,"five":5,"six":6,"seven":7,
         "eight":8,"nine":9,"ten":10,"eleven":11,"twelve":12,"thirteen":13,
         "fourteen":14,"fifteen":15,"sixteen":16,"seventeen":17,"eighteen":18,
         "nineteen":19}
_TENS = {"twenty":20,"thirty":30,"forty":40,"fifty":50,"sixty":60,"seventy":70,
         "eighty":80,"ninety":90}
def words_to_int(tok):
    if tok is None: return None
    tok = tok.strip().lower()
    if tok.isdigit(): return int(tok)
    if tok in _ONES: return _ONES[tok]
    if tok in _TENS: return _TENS[tok]
    if "-" in tok:
        a, _, b = tok.partition("-")
        if a in _TENS and b in _ONES and _ONES[b] < 10:
            return _TENS[a] + _ONES[b]
    return None

# The SAME token set words_to_int() parses, as a regex fragment — DERIVED from
# _ONES/_TENS rather than hand-listed, so the pattern and the parser cannot drift
# apart. That drift was a real, latent failure: the "backtest gates" row below
# hard-coded `(one|two|...|ten|\d+)`, which stops at TEN while words_to_int has
# handled 0-99 (hyphens included) all along. The suite went 8 -> 10 on this
# branch, so the ELEVENTH gate was the trigger: a maintainer who correctly
# rewrote every surface to "eleven gates" would have made the claim invisible to
# the pattern, and an unmatched pattern on a REQUIRED surface is a RED gate (see
# main()). Four surfaces with correct prose would have gone red at once, and the
# cheapest way out of that red is to mark them OPT — "exactly how coverage
# disappears quietly", per the note below. Executed 2026-08-23 against an 11-gate
# copy: the old alternation produced four false NO CLAIM MATCHED failures; this
# fragment produces none.
#
# Longest-first so `twenty-one` is tried before `twenty`. Kept a CLOSED set of
# number words rather than the open `[A-Za-z]+` capture some rows use: an open
# capture matches any word before the noun ("backtest gates"), which sets the
# surface's found flag and can mask a genuine loss of coverage.
_NUM = "(" + "|".join([r"\d+"] + sorted(
    list(_ONES) + list(_TENS) + [f"{t}-{o}" for t in _TENS for o in _ONES if 0 < _ONES[o] < 10],
    key=len, reverse=True)) + ")"

def rubric_parity():
    """quality-gates.md must embed quality_score.py's --print-rubric output verbatim.

    Until 2026-09-26 the rule's tables and the script's dicts were kept by hand and
    had drifted both ways: each carried rows the other lacked. The script is now the
    single source, the rule embeds its generated tables between markers, and any
    difference fails. Returns (ok, message).
    """
    rule = read(".claude/rules/quality-gates.md")
    m = re.search(r'<!-- BEGIN rubric[^\n]*-->\n(.*?)<!-- END rubric -->', rule, re.S)
    if not m:
        return False, ".claude/rules/quality-gates.md: rubric markers missing — the tables are no longer gated"
    try:
        gen = subprocess.run([sys.executable, os.path.join(ROOT, "scripts", "quality_score.py"), "--print-rubric"],
                             capture_output=True, text=True, check=True, timeout=60).stdout
    except Exception as e:
        return False, f"quality_score.py --print-rubric failed: {e}"
    if m.group(1) != gen:
        return False, (".claude/rules/quality-gates.md: rubric tables differ from quality_score.py — "
                       "regenerate them with `python3 scripts/quality_score.py --print-rubric`")
    return True, "quality-gates.md rubric == quality_score.py --print-rubric"

def n_seven_pass():
    t = read(".claude/skills/seven-pass-review/SKILL.md")
    return len(set(re.findall(r'^\| (\d) \|', t, re.M)))

# --- Per-surface expectation --------------------------------------------------
#
# A row's `surfaces` entry is EITHER a bare path string — meaning this surface is
# REQUIRED to carry the claim, and a surface that stops matching is a gate
# failure — OR `OPT(path, why)`, meaning this surface is scanned but may
# legitimately make no such claim, with the reason written down.
#
# Why explicit expectation, and not inference: until 2026-08-23 `found` was ONE
# boolean per ROW, so the round-7 UNGATED failure fired only when EVERY surface
# in a row stopped matching. Reword the claim on one surface of a multi-surface
# row and the row stayed green on its sibling — the surface silently left
# coverage while the output still read like a pass ("hook battery cases
# CHANGELOG.md claims 51 actual 51 ok"). That is the r7 defect one dimension
# over. The obvious repair — "every declared surface must match" — is wrong on
# its own, because three declared surfaces legitimately carry no claim of their
# row's kind today (see the OPT reasons below); it would have made the gate red
# on a correct repo, and the fix for that noise would have been to DELETE those
# surfaces from the row, which is exactly how coverage disappears quietly.
#
# So the expectation is DECLARED, never guessed:
#   * a REQUIRED surface that matches nothing            -> UNGATED failure (red)
#   * an OPT surface that matches nothing                -> printed as
#     "no claim (optional: <why>)" — visible in the log, not silent
#   * an OPT surface that DOES match                     -> value-checked like
#     any other, so coverage can only grow by accident, never shrink
#   * a row with NO required surface at all              -> failure, because
#     such a row can never go red and is not a gate
# Demoting a REQUIRED surface to OPT therefore costs a diff with a written
# reason in it — a reviewable act — instead of an invisible non-match.
#
# 2026-08-23, one dimension further in: `found` moved from per-ROW to per-SURFACE
# and stopped there, so the SAME leak reappeared per INSTANCE. A surface that
# states its claim at several sites — LEDGER.md carries the battery count at
# eight, README.md carries the gate count at two — could have ONE instance
# reworded and stay green on its siblings, with the file then asserting two
# different numbers for one measurement. Proven, not assumed: rewriting the
# FIRST "(131 cases, exit 0)" in LEDGER.md to "(99 cases pass, exit 0)" left
# check-derived-counts, check-surface-sync, check-ledger-coverage and
# check-staleness all at exit 0. There is no way to detect an instance the
# pattern no longer matches, so the expectation is DECLARED like everything else
# here: REQ(path, n) says this surface carries the claim at EXACTLY n sites.
#
# EXACTLY, not "at least" — corrected 2026-08-24, and this is the second defect
# the same declaration produced. The rule shipped as "n AT LEAST: below n is a
# failure; above it is fine, so adding a site never goes red and losing one
# always does". The second clause was FALSE whenever the declared number fell
# behind the file, and it had: the row below declared six while LEDGER.md
# carried the claim at SEVEN (`grep -o '146 cases, exit 0' … | wc -l` -> 7),
# the only under-declared surface among the 31 in CHECKS. Measured on a copy of
# c285699 with all six count gates green: rewriting ONE of the seven out of
# coverage left check-derived-counts, check-surface-sync, check-staleness,
# check-ledger-coverage, check-skill-integrity and check-spec-conformance all at
# exit 0 — verified for each of the seven in turn — while rewriting TWO went
# red. So the machinery worked and the LITERAL had drifted, silently, because
# nothing checked it against the file it describes. A REQ surface carrying MORE
# sites than declared is now a FAILURE too: adding a site costs one number in
# this file, and in exchange the declared count can never again be quietly below
# reality. Disclosed residual: a BARE path still means "at least one", so a file
# that grows a second site and later loses it is still silent — promote such a
# surface to REQ (that is what REQ is for) rather than assuming the bare form
# gates instance counts.
OPT = namedtuple("OPT", "path why")
REQ = namedtuple("REQ", "path n")

# A third surface form: a SECTION of a file rather than the whole file. `label`
# is what the log prints, `text` is the already-extracted view the pattern is
# matched against. It is REQUIRED like a bare path — a section that stops
# carrying its claim is an UNGATED failure, same as a file that stops carrying
# one. Used for the CHANGELOG's current-release inventory line, where scanning
# the whole file would compare CORRECT historical entries against today's disk
# (see changelog_current_release() for the full reasoning).
SEC = namedtuple("SEC", "label text")

def _surface_path(s):
    if isinstance(s, SEC):
        return s.label
    return s.path if isinstance(s, (OPT, REQ)) else s

def _surface_text(s):
    return s.text if isinstance(s, SEC) else read(_surface_path(s))

def _surface_required(s):
    return not isinstance(s, OPT)

def _surface_min(s):
    """How many matching instances this surface must carry. 0 for OPT (scanned,
    not required); the declared n for REQ; 1 for a bare path or a SEC."""
    if isinstance(s, OPT): return 0
    if isinstance(s, REQ): return s.n
    return 1

def _surface_max(s):
    """The most matching instances this surface may carry, or None for no upper
    bound. Only REQ has one: its declared n is EXACT, so a site added without
    updating the number is a failure — see the REQ comment above for the drift
    that made this necessary. OPT, SEC and bare paths keep "at least"."""
    return s.n if isinstance(s, REQ) else None

# Extracted once, so every release-inventory row below reads the SAME window.
_CL_CURRENT = changelog_current_release()

# (label, claimed-value regex, surfaces to scan, actual count)
CHECKS = [
    # Phrasings verified against the actual surfaces 2026-08-21. If you reword a
    # claim, update the pattern here too — an unmatched pattern reports nothing,
    # which is indistinguishable from a claim that is correct.
    ("econ journal profiles", r'top-(\d+) journal profiles',      ["README.md", "guide/workflow-guide.qmd"], n_econ_journals()),
    ("TikZ snippets",         r'(\d+) production-ready',       ["guide/workflow-guide.qmd"], n_tikz()),
    # guide/workflow-guide.qmd shows the translate-to-quarto phases as an ASCII
    # tree ("Phase 1-3 ... Phase 10-11") and never states an "N translation
    # phases" total, so it is scanned but not required to match.
    ("translation phases",    r'(\d+) translation phases',       ["README.md", OPT("guide/workflow-guide.qmd", "shows the phases as a tree, states no total")], n_translate_phases()),
    # The 7-vs-8 drift cluster: seven separate surfaces claimed the wrong gate
    # count after gate 8 landed. Counted from backtest.sh itself.
    # CLAUDE.md names the gate suite ("the full backtest gate suite") but states
    # no count; the vaccinate evals README says "the gates in ./scripts/backtest.sh"
    # for the same reason. Both are scanned so a count APPEARING there is caught,
    # neither is required to carry one.
    # r10: the noun is `(?:gates|checkers)`, not `gates` alone. README.md states
    # the gate-suite size TWICE — "ten gates" at line 79 and, above the fold in
    # the very first paragraph a prospective forker reads, "`./scripts/backtest.sh`
    # — 10 checkers". Only the first phrasing matched, and because `found` is per
    # SURFACE (not per phrasing) the sibling match kept the row green, so no
    # NO CLAIM MATCHED fired either: a planted-lie sweep set the second instance
    # to "99 checkers" and ./scripts/backtest.sh still exited 0. That number had
    # ALREADY drifted once — it was hand-repaired 8 -> 10 on this branch, the
    # exact pattern the "research-agent laws" row below was added for. Widening
    # the noun converts a second phrasing into coverage instead of deleting it.
    # Verified 2026-08-23: `\b<number> checkers?\b` occurs at exactly ONE site in
    # the repo (README.md:17), so the alternative adds coverage, not false hits.
    # r12: `scripts/backtest.sh` ITSELF is a surface. Its header comment states
    # the suite size ("Ten gates:") 45 lines above the `run "…"` block the count
    # is derived from, it was hand-edited `Eight gates:` -> `Ten gates:` on this
    # branch, and it was the LAST live gate-count claim in the repo that no row
    # covered: a planted-lie sweep seeding "ninety-nine gates:" at line 5 left
    # every gate at exit 0. The file being both the claim and the source of
    # truth is fine and was checked, not assumed — the pattern matches at
    # exactly ONE site in it (the header), because the enumeration below the
    # header numbers its gates `1.`…`10.` rather than restating a total, and
    # `n_gates()` counts `^run "` lines, which the pattern cannot match.
    # r13: the number alternation is `_NUM`, derived from words_to_int's own
    # token table, not a hand-written list that stopped at TEN — see _NUM.
    # r13: the three multi-instance surfaces declare HOW MANY sites they carry
    # (README.md "ten gates" + "10 checkers"; docs/index.html twice; the guide
    # three times), so rewording one of them is as loud as rewording the last.
    ("backtest gates",        r'(?i)\b' + _NUM + r' (?:gates|checkers)\b', [REQ("README.md", 2), REQ("docs/index.html", 2), OPT("CLAUDE.md", "names the gate suite, states no count"), REQ("guide/workflow-guide.qmd", 3), OPT(".claude/skills/vaccinate/evals/README.md", "refers to the suite by path, states no count"), ".claude/skills/commit/SKILL.md", ".github/CONTRIBUTING.md", "scripts/backtest.sh"], n_gates()),
    # CLAUDE.md's law count was hand-edited 17 -> 21 and nothing recomputed it,
    # so "99 laws" would have left every gate green. Counted from the laws file.
    ("research-agent laws",   r'(\d+) laws\b',                   ["CLAUDE.md"], n_laws()),
    # The count two bullets ABOVE the law count in the same CLAUDE.md paragraph,
    # gated for the same reason and counted the same way — see n_rungs(). The
    # guide states it once more; CHANGELOG.md states it inside the FROZEN
    # v2.5.0 section (the `verification-ladder.md` bullet — named, not given as
    # a line number, because that pointer had already drifted once) and is
    # deliberately not a surface (see
    # changelog_current_release() for why history is never dragged to today).
    ("verification rungs",    r'(?i)\bthe ' + _NUM + r' rungs\b', ["CLAUDE.md", "guide/workflow-guide.qmd", "docs/workflow-guide.html"], n_rungs()),
    ("seven-pass lenses",     r'(\d+) (?:forked|fresh-context) subagents',         [".claude/skills/seven-pass-review/SKILL.md"], n_seven_pass()),
    # The hook-battery case count drifted twice (12→16→…) because prose was
    # edited in parallel with case additions. Anchored on the vignette's own
    # ", about a second" tail so it matches ONLY the battery claim (not generic
    # "cases"), and counted from the battery's own expect_ call sites.
    # Tail alternatives, not one literal: the phrasing was reworded during v2.5.1
    # (the runtime claim "about a second" stopped being true as the battery grew)
    # and the single-literal anchor silently stopped matching — the gate printed
    # "(no claim found)" and stayed green, which is why an unmatched pattern is
    # now a FAILURE (see main()).
# r21 — THE CAPTURE IS CLOSED, NOT OPEN. These three rows used
# `(\d+|[A-Za-z]+(?:-[A-Za-z]+)?)`, which MATCHES any word. A site reworded to
# something `words_to_int` cannot parse therefore still counted toward `seen`,
# so the REQUIRED-surface check was satisfied, and then main() `continue`d
# without comparing — the site left coverage silently, which is the exact
# failure this file exists to prevent, one level up. Measured on a copy at
# 0d16939: rewording one site per surface to "all cases" / "many cases" /
# "hundreds of cases" left `check-derived-counts` at exit 0 every time. `_NUM`
# is the closed alternation (digits, or the spelled numbers 0-99) the gate rows
# above already use, so a real claim still matches and an unparseable one now
# fails the REQUIRED-surface count instead of passing.
    # 2026-09-26: the CHANGELOG surface is the CURRENT release section, not the
    # file. The only matching site had been the v2.5.1 entry's "(234 cases,
    # seconds to run)"; once v2.5.1 shipped that line was history, and adding one
    # battery case made the gate demand an edit to a published release — the
    # exact drag changelog_current_release() exists to prevent. Each release now
    # states its own battery size, and only the open one is compared to disk.
    ("hook battery cases",    _NUM + r' cases, (?:about a second|seconds to run|and it finishes in seconds)', [SEC("CHANGELOG.md (current release)", _CL_CURRENT), "guide/workflow-guide.qmd"], n_hook_battery_cases()),
    # The QUALIFICATION LEDGER states the same number in its own phrasing —
    # "(46 cases, exit 0)" in the Reproduction paragraph and "(46/46 cases, exit
    # 0)" in the grading-the-grader row — and until 2026-08-23 NEITHER was a
    # declared surface of any row. A planted-lie sweep confirmed it: replacing
    # each with 99 left check-surface-sync, check-derived-counts, check-staleness
    # and check-ledger-coverage all at exit 0, while the same sweep caught all
    # 24 other count-claim sites in the repo. That is the failure this ledger
    # exists to prevent, sitting in the ledger: a maintainer re-qualifying the
    # guards runs the battery, sees a different N, and cannot tell whether a
    # case was added or whether the recall DENOMINATOR was never updated.
    # EIGHT sites, declared and now EXACT: the ledger states this denominator
    # once per qualified guard, once per seeded-reproduction paragraph, and once
    # in the roll-up, and rewording any one of them used to be silent. The
    # number was declared as SIX while the file carried SEVEN until 2026-08-24 —
    # the drift that made REQ exact rather than a floor (see the REQ comment
    # above). Recompute it, do not guess it:
    #   grep -oE '[0-9]+ cases, exit 0' quality_reports/qualification/LEDGER.md | wc -l
    # (count-agnostic ON PURPOSE — the same shape this row's own regex matches.
    # The recipe used to hard-code the battery size of the day; once the battery
    # grew it returned 0, and a maintainer following it would have concluded the
    # REQ was wrong and dropped eight gated sites out of coverage.)
    ("battery cases (ledger)", _NUM + r' cases, exit 0',    [REQ("quality_reports/qualification/LEDGER.md", 8)], n_hook_battery_cases()),
    # The claim these three read used to be phrased "(N cases named)" — the
    # cases a stubbed run NAMES — while the value is a SECTION TALLY. The
    # phrasing is now the quantity (2026-08-24); see n_battery_named() for the
    # measurement that separated the two and why the tally is what gets gated.
    ("battery-named root-of-trust", r'`root-of-trust-guard\.py` \((\d+) cases in its own sections\)', ["quality_reports/qualification/LEDGER.md"], n_battery_named("a")),
    ("battery-named git-guardrails", r'`git-guardrails\.py` \((\d+) cases in its own sections\)',     ["quality_reports/qualification/LEDGER.md"], n_battery_named("bc")),
    ("battery-named claim-reconcile", r'`claim-reconcile\.py` \((\d+) cases in its own sections\)',   ["quality_reports/qualification/LEDGER.md"], n_battery_named("d")),
    # n_patterns() was COMPUTED (and printed as "sequential 1..N") but never
    # compared against the prose, so "Nineteen patterns is a reference shelf"
    # could go stale the moment Pattern 20 landed — sequentiality still passes
    # on 1..20. Anchored on the vignette's own "is a reference shelf" tail, and
    # the count is spelled out, which words_to_int already handles.
    ("workflow patterns",     r'(?i)' + _NUM + r' patterns is a reference shelf', ["guide/workflow-guide.qmd", "docs/workflow-guide.html"], n_patterns()),
    # --- the current release's inventory line (r10) ---------------------------
    # CHANGELOG.md's `**Inventory at release: N skills, N agents, N rules,
    # N hooks, N gates**` publishes five counts of this repository's own
    # surfaces and NOT ONE of them was read by any gate: CHANGELOG.md is absent
    # from check-surface-sync's SURFACES (deliberately — see
    # changelog_current_release() for why), and no row here declared it for
    # skills/agents/rules/hooks/gates. A planted-lie sweep put 99 in each, one
    # at a time, and ./scripts/backtest.sh exited 0 every time.
    #
    # That is not hypothetical drift: on THIS branch alone the rules directory
    # went 36 -> 37, hooks 7 -> 8, and gates 8 -> 10 while the release notes were
    # being written. Once the heading below it is no longer the top one, the line
    # freezes as history — so a wrong number here becomes permanent.
    #
    # SCOPING: the surface is the CURRENT release section only, never the file.
    # Historical inventory lines (v2.5.0's `36 rules, 7 hooks`, v2.1.0's
    # `52 skills`) were correct at their release and must NOT be dragged to
    # today's values; they are outside the window and cannot go red. See
    # changelog_current_release().
    #
    # Anchored on "Inventory at release:" and confined to one line by `[^\n*]*?`,
    # which also stops at the closing `**` — so the trailing "(was 60 / 18 / 36 /
    # 7 / 8 at v2.5.0)" comparison, a deliberate historical statement about the
    # PREVIOUS release, is not matched either.
    ("release inventory skills", r'Inventory at release:[^\n*]*?(\d+) skills', [SEC("CHANGELOG.md (current release)", _CL_CURRENT)], n_skills()),
    ("release inventory agents", r'Inventory at release:[^\n*]*?(\d+) agents', [SEC("CHANGELOG.md (current release)", _CL_CURRENT)], n_agents()),
    ("release inventory rules",  r'Inventory at release:[^\n*]*?(\d+) rules',  [SEC("CHANGELOG.md (current release)", _CL_CURRENT)], n_rules()),
    ("release inventory hooks",  r'Inventory at release:[^\n*]*?(\d+) hooks',  [SEC("CHANGELOG.md (current release)", _CL_CURRENT)], n_hooks()),
    ("release inventory gates",  r'Inventory at release:[^\n*]*?(\d+) gates',  [SEC("CHANGELOG.md (current release)", _CL_CURRENT)], n_gates()),
]

def main():
    bad = []
    print("check-derived-counts: enumerable claims outside surface-sync's scope")
    for label, pat, surfaces, actual in CHECKS:
        # A row with no REQUIRED surface can never go red: every surface would be
        # free to drop its claim. Such a row is not a gate, so say so.
        if not any(_surface_required(s) for s in surfaces):
            print(f"  {label:<22} {'NO REQUIRED SURFACE':<28} actual {actual:>3}  UNGATED")
            bad.append(f"{label}: every declared surface is OPT, so this row can never "
                       f"fail — promote at least one surface to REQUIRED")
        for s in surfaces:
            f = _surface_path(s)
            need = _surface_min(s)   # PER INSTANCE, not per surface (see REQ above)
            seen = 0
            for m in re.finditer(pat, _surface_text(s)):
                seen += 1
                g = m.group(1)
                claimed = words_to_int(g)
                if claimed is None: continue
                ok = claimed == actual
                print(f"  {label:<22} {f:<28} claims {claimed:>3}  actual {actual:>3}  {'ok' if ok else 'MISMATCH'}")
                if not ok:
                    bad.append(f"{f}: claims {claimed} {label}, actual {actual}")
            if seen == 0 and not _surface_required(s):
                print(f"  {label:<22} {f:<28} no claim (optional: {s.why})")
            elif seen < need:
                # This surface is DECLARED to carry the claim at `need` sites. If
                # the pattern now matches fewer, a site was reworded or deleted
                # and has left coverage — indistinguishable from a claim that is
                # correct, and exactly how a count drifts unnoticed. Fail loudly,
                # naming the file, even when a SIBLING SURFACE or a SIBLING
                # INSTANCE still matches and the row therefore "looks" checked.
                what = "NO CLAIM MATCHED" if seen == 0 else f"ONLY {seen}/{need} SITES"
                print(f"  {label:<22} {f:<28} {what:<18}  UNGATED")
                lost = (f"the {label} pattern matched nothing there"
                        if seen == 0 else
                        f"the {label} pattern matched {seen} site(s) there, {need} expected")
                bad.append(f"{f}: {lost} — the claim "
                           f"was reworded, so that site is no longer checked "
                           f"(restore the phrasing, update the pattern, adjust the "
                           f"declared site count, or mark the surface OPT with a reason)")
            elif _surface_max(s) is not None and seen > _surface_max(s):
                # The declared count is EXACT (see the REQ comment). A surface
                # carrying MORE sites than declared is how the number silently
                # falls behind the file: every extra site is ungated, and one of
                # them can then be reworded out of coverage with every gate
                # green — which is the very leak REQ was added to close. Fail
                # here so the literal cannot drift away from reality again.
                print(f"  {label:<22} {f:<28} {f'{seen} SITES, {need} DECLARED':<18}  UNDER-DECLARED")
                bad.append(f"{f}: the {label} pattern matches {seen} site(s) there but "
                           f"REQ declares {need} — the extra site(s) are UNGATED and could be "
                           f"reworded out of coverage silently (raise the declared count to "
                           f"{seen}, or remove the extra site)")
    # patterns are sequential-by-construction: 1..N with no gaps
    ids = sorted(int(x) for x in set(re.findall(r'^#{2,3} Pattern (\d+)', read("guide/workflow-guide.qmd"), re.M)))
    if ids and ids != list(range(1, len(ids) + 1)):
        bad.append(f"workflow patterns are not sequential: {ids}")
        print(f"  workflow patterns      NOT SEQUENTIAL: {ids}")
    else:
        print(f"  workflow patterns      sequential 1..{len(ids)}  ok")
    ok, msg = rubric_parity()
    print(f"  quality rubric         {msg}  {'ok' if ok else 'MISMATCH'}")
    if not ok:
        bad.append(msg)
    if bad:
        print(f"\n{len(bad)} MISMATCH(ES):")
        for b in bad: print(f"  {b}")
        return 1
    print("\nAll derived counts match their source of truth.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
