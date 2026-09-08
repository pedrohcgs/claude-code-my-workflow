#!/usr/bin/env bash
# backtest.sh — prove the whole repo is internally consistent and currently true.
#
# Run this after ANY change. It is the difference between a maintained repo and
# one that merely looks maintained. Ten gates:
#
#   1. surface-sync        Claude + Codex counts/inventories match what is on disk
#   2. skill-integrity     frontmatter <-> body tool parity, anchors, flag parity
#   3. model-versions      no superseded model presented as current (internal
#                         consistency against the model SSoT; the EXPIRY on that
#                         SSoT is enforced by gate 6, staleness)
#   4. links               every relative link and heading anchor resolves
#   5. spec-conformance    every skill obeys the Agent Skills spec; native Codex
#                         config/agents/hooks/manifest and port leakage are checked
#   6. staleness           stale recommendations, source/render divergence, expired currency
#   7. repo-hygiene       no scratch-as-main, no root clutter, archives documented
#   8. derived-counts     enumerable claims (journals, patterns, phases, snippets)
#                         verified against their own source of truth
#   9. ledger-coverage    the qualification ledger and the checks that actually run
#                         agree in BOTH directions, and every Claude/Codex hook
#                         registry points to a live, tracked file
#  10. hook-battery       the active guard hooks are driven with synthetic events
#                         and must still go red on the failure each one targets —
#                         gate 9 proves a hook is wired, this proves it still acts
#   +  findings-validator  smoke test, so a review run cannot fail at the last step
#
# Every gate runs to completion even if an earlier one fails — you get the whole
# picture in one pass. Exit code is the max of all gates.
#
# No `set -e`: it would abort after the first failure and hide the rest.
set -uo pipefail

DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "backtest: cannot resolve script directory" >&2; exit 2
fi

RC=0
run() {  # run <label> <command...>
    local label="$1"; shift
    echo ""
    echo "── $label ──"
    "$@"
    local rc=$?
    [ "$rc" -gt "$RC" ] && RC=$rc
    return 0
}

echo "═══ BACKTEST: is this repo internally consistent and currently true? ═══"

run "surface-sync"       python3 "$DIR/check-surface-sync.py"
run "skill-integrity"    python3 "$DIR/check-skill-integrity.py"
run "model-versions"     "$DIR/check-model-versions.sh"
run "links"              python3 "$DIR/check-links.py"
run "spec-conformance"   python3 "$DIR/check-spec-conformance.py"
run "staleness"          python3 "$DIR/check-staleness.py"
run "repo-hygiene"       python3 "$DIR/check-repo-hygiene.py"
run "derived-counts"     python3 "$DIR/check-derived-counts.py"
run "ledger-coverage"    python3 "$DIR/check-ledger-coverage.py"
run "hook-battery"       bash "$DIR/hook-battery.sh"

echo ""
echo "── findings-validator smoke test ──"
echo '[]' | python3 "$DIR/validate-findings.py"
rc=$?; [ "$rc" -gt "$RC" ] && RC=$rc

echo ""
if [ "$RC" -eq 0 ]; then
    echo "═══ BACKTEST PASSED — repo is fresh and internally consistent ═══"
else
    echo "═══ BACKTEST FAILED (exit $RC) — fix before shipping ═══"
fi
exit "$RC"
