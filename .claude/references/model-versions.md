<!-- CURRENT: Fable 5 | Opus 4.8 | Sonnet 4.6 | Haiku 4.5 -->

# Current Model Versions (single source of truth)

**Last verified against Anthropic docs:** 2026-06-10

This file is the **one place** that names current Claude model point versions. Everything else in the template should either refer to tiers abstractly ("newest Opus", "the Haiku tier") or point here. `scripts/check-model-versions.sh` flags any **superseded** version that is presented as **current** in the template's user-facing surfaces.

The machine-readable `<!-- CURRENT: ... -->` marker at the top is parsed by the checker — keep it in sync with the table.

Text provider models and regional compatibility endpoints live in [`model-providers.json`](model-providers.json). The same CI-wired gate validates that registry before scanning current-state surfaces.

| Tier | Current version | Model ID | Notes |
|------|-----------------|----------|-------|
| Fable (Mythos-class; hardest, long-horizon) | **Fable 5** | `claude-fable-5` (alias `fable`; 1M variant `claude-fable-5[1m]`) | most capable model in Claude Code; **opt-in** (`/model fable` or the `best` alias) — NOT the default on any account type; GA 2026-06-09; $10/$50 per MTok; 1M context (128k max output); defaults to `high`; requires Claude Code ≥ 2.1.170; falls back to Opus 4.8 on flagged cyber/bio content |
| Opus (high-judgment) | **Opus 4.8** | `claude-opus-4-8` | current Opus tier; **API/account default**; GA 2026-05-28; $5/$25 per MTok; 1M context; defaults to `high` effort; the content-fallback target for Fable 5 |
| Sonnet (workhorse) | **Sonnet 4.6** | `claude-sonnet-4-6` | 1M context |
| Haiku (fast / mechanical) | **Haiku 4.5** | `claude-haiku-4-5-20251001` | fast tier; ID is the snapshot-pinned alias |

**Retiring 2026-06-15:** Sonnet 4 + original Opus 4 → migrate to Sonnet 4.6 / Opus 4.8.

**Fast mode:** Opus 4.8 fast mode is $10/$50 per MTok (~2.5× speed). Opus 4.7 fast mode is $30/$150; Opus 4.6 fast mode is deprecated (~2026-06).

**Fable 5 maturity caveat (2026-06-10):** routing guidance lives in [`model-routing.md`](../rules/model-routing.md) — as of launch week, Fable 5 is deliberately **not** routed to the forked-reviewer fleet (2× the Opus price on the judgment tier, and day-one forced-tool-protocol reliability was observed to lag Opus 4.8: 28/28 structured-output subagent failures in one session's workflow vs 0 on Opus). Re-evaluate as point releases land.

## Prior generations

It is fine to mention older versions in **historical** contexts (CHANGELOG entries) or in explicit **"prior generation" / comparison** lines (e.g. "Opus 4.8's `high` does what Opus 4.7's `xhigh` did"). They must **not** be presented as the current / newest / default model.

- **Opus 4.7** — prior Opus generation.

The checker allows a line to mention an older version when it carries a marker such as `prior generation`, `retire`, `migrat`, `deprecat`, `or later`, `historical`, an `X.Y's` comparison, or an inline `<!-- model-allow -->` comment.

## Update protocol (when Anthropic ships a new model)

1. Update the table **and** the `<!-- CURRENT: ... -->` marker above, plus the "Last verified" date.
2. Run `./scripts/check-model-versions.sh` and fix every current-state surface it flags.
3. **Manually grep for superlatives** — `grep -rniE "newest|most capable" README.md CLAUDE.md guide/ docs/index.html .claude/rules/` — and re-verify each hit. The checker validates *version strings*; a claim like "X is the newest model" is a **semantic** assertion it can only partially catch (it flags `newest`/`most capable` lines that name a non-top tier, but tier-relative phrasings like "the newest Opus" are legitimately allowed). The 2026-06-09 Fable 5 launch made exactly this class of claim false while the gate stayed green.
4. Add a "Changed — model refresh" entry to `CHANGELOG.md`; leave historical CHANGELOG entries intact.
