#!/usr/bin/env bash
# Validates text provider mappings before the version scan.
# Flags SUPERSEDED Claude model versions that are presented as CURRENT in the
# template's user-facing surfaces. The single source of truth is the
# `<!-- CURRENT: ... -->` marker in .claude/references/model-versions.md.
#
# Historical references (CHANGELOG.md is excluded entirely) and explicit
# "prior generation" / comparison / "or later" lines are allowed via markers.
# Rendered HTML is derived from the .qmd, so we scan the source, not the HTML.
#
# Exit codes: 0 = clean, 1 = drift detected, 2 = internal error.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)"
if [ -z "$REPO" ] || [ ! -d "$REPO" ]; then
    echo "check-model-versions: cannot resolve repo root" >&2
    exit 2
fi

SSOT="$REPO/.claude/references/model-versions.md"
if [ ! -f "$SSOT" ]; then
    echo "check-model-versions: SSoT missing: $SSOT" >&2
    exit 2
fi

PROVIDER_REGISTRY="$REPO/.claude/references/model-providers.json"
PROVIDER_CHECK="$REPO/scripts/check-model-providers.py"
if [ ! -f "$PROVIDER_CHECK" ]; then
    echo "check-model-versions: provider checker missing: $PROVIDER_CHECK" >&2
    exit 2
fi

python3 "$PROVIDER_CHECK" "$PROVIDER_REGISTRY"
PROVIDER_RC=$?
[ "$PROVIDER_RC" -eq 0 ] || exit "$PROVIDER_RC"

CURRENT_LINE="$(grep -E "<!-- CURRENT:" "$SSOT" | head -1)"
if [ -z "$CURRENT_LINE" ]; then
    echo "check-model-versions: no '<!-- CURRENT: ... -->' marker in $SSOT" >&2
    exit 2
fi

# Current-state surfaces to scan (sources; rendered HTML is derived from the qmd).
SURFACES=(
    "README.md"
    "CLAUDE.md"
    "TROUBLESHOOTING.md"
    "MEMORY.md"
    "guide/workflow-guide.qmd"
    "docs/index.html"
    ".claude/rules/model-routing.md"
    ".claude/scripts/statusline.sh"
)

# A line is allowed to name an older version if it carries one of these markers.
ALLOW='prior generation|prior gen|prior Opus|retire|migrat|historical|deprecat|was:|was |or later|incl\. 4\.|rolling out|GA 2026-0|beta|4\.[0-9]+.s |model-allow'

# Version token: "4.8", "5", "5.1" — Fable has no minor version at launch, so
# the regex must accept a bare major (the old `4\.[0-9]+` silently skipped it).
VER='[0-9]+(\.[0-9]+)?'

drift=0
for tier in "Fable" "Opus" "Sonnet" "Haiku"; do
    current="$(echo "$CURRENT_LINE" | grep -oE "$tier $VER" | head -1)"
    [ -n "$current" ] || continue
    for f in "${SURFACES[@]}"; do
        [ -f "$REPO/$f" ] || continue
        while IFS=: read -r lineno text; do
            ver="$(echo "$text" | grep -oE "$tier $VER" | head -1)"
            [ -n "$ver" ] || continue
            [ "$ver" = "$current" ] && continue                 # names the current version → fine
            echo "$text" | grep -qiE "$ALLOW" && continue       # allow-marked line → fine
            echo "  $f:$lineno  presents '$ver' (current $tier is '$current')" >&2
            echo "      → $(echo "$text" | sed -E 's/^[[:space:]]+//' | cut -c1-110)" >&2
            drift=1
        done < <(grep -nE "$tier $VER" "$REPO/$f")
    done
done

# Superlative drift: "newest model" / "most capable" claims are SEMANTIC, not
# version strings — the 2026-06-09 Fable 5 launch made "Opus 4.8 is the newest"
# false while the version check above stayed green. Flag any superlative line
# that names a non-top tier (Opus/Sonnet/Haiku) without mentioning the top tier
# (Fable) and without an allow-marker. Tier-relative phrasings ("the newest
# Opus") are fine and excluded.
TOP_TIER="$(echo "$CURRENT_LINE" | sed -E 's/.*<!-- CURRENT: *//; s/ .*//')"   # e.g. "Fable"
for f in "${SURFACES[@]}"; do
    [ -f "$REPO/$f" ] || continue
    while IFS=: read -r lineno text; do
        echo "$text" | grep -qiE "$TOP_TIER" && continue                       # already credits the top tier
        echo "$text" | grep -qiE "newest (Opus|Sonnet|Haiku)" && continue      # tier-relative superlative → fine
        echo "$text" | grep -qiE "(Opus|Sonnet|Haiku) $VER" || continue        # only flag lines naming a versioned tier
        # NOTE: deliberately NOT short-circuiting on the general $ALLOW list here.
        # A superlative is a claim about the WHOLE lineup; an allow-marker earned by a
        # different clause in the same sentence ("Opus 4.7 is the prior generation",
        # a "GA 2026-.." date) must not suppress it — that exact interaction let
        # "Opus 4.8 is the newest model" slip past this check in v2.1 review. The only
        # explicit escape is an inline model-allow comment placed for THIS claim.
        echo "$text" | grep -q "model-allow" && continue
        echo "  $f:$lineno  superlative claim may be stale (top tier is now '$TOP_TIER'):" >&2
        echo "      → $(echo "$text" | sed -E 's/^[[:space:]]+//' | cut -c1-110)" >&2
        drift=1
    done < <(grep -niE "newest|most capable" "$REPO/$f")
done

if [ "$drift" -ne 0 ]; then
    echo "" >&2
    echo "MODEL-VERSION DRIFT: a superseded version is presented as current." >&2
    echo "Fix the surface to name the current version, or add an allow-marker" >&2
    echo "(e.g. 'prior generation', 'or later', a comparison) if the mention is intentional." >&2
    echo "Source of truth: .claude/references/model-versions.md" >&2
    exit 1
fi

echo "check-model-versions: current-state surfaces match $(echo "$CURRENT_LINE" | sed -E 's/.*<!-- CURRENT: *//; s/ *-->.*//')"
exit 0
