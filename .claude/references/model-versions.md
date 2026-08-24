<!-- CURRENT: Fable 5 | Opus 5 | Sonnet 5 | Haiku 4.5 -->

# Current Model Versions (single source of truth)

**Last verified against Anthropic docs:** 2026-08-21  
**Expires:** 2026-10-20 (60 days) — after this date the currency gate fails until re-verified.

This file is the **one place** that names current Claude model point versions. Everything else in the template should either refer to tiers abstractly ("newest Opus", "the Haiku tier") or point here. `scripts/check-model-versions.sh` flags any **superseded** version that is presented as **current** in the template's user-facing surfaces.

The machine-readable `<!-- CURRENT: ... -->` marker at the top is parsed by the checker — keep it in sync with the table.

Text provider models and regional compatibility endpoints live in [`model-providers.json`](model-providers.json). The same CI-wired gate validates that registry before scanning current-state surfaces.

| Tier | Current version | Model ID | Notes |
|------|-----------------|----------|-------|
| Fable (Mythos-class; hardest, long-horizon) | **Fable 5** | `claude-fable-5` (alias `fable`; 1M variant `claude-fable-5[1m]`) | most capable model in Claude Code; **opt-in** (`/model fable` or the `best` alias) — NOT the default on any account type; GA 2026-06-09; $10/$50 per MTok; 1M context (128k max output); defaults to `high`; requires Claude Code ≥ 2.1.170; falls back to the current Opus tier on flagged cyber/bio content |
| Opus (high-judgment) | **Opus 5** | `claude-opus-5` (alias `opus`; 1M variant `claude-opus-5[1m]`) | current Opus tier; what `opus` resolves to on the Anthropic API; shipped Week 30 (2026-07-20/24); 1M context; **fast mode $10/$50 per MTok**; requires Claude Code ≥ 2.1.219. *Base per-MTok pricing not verified in this pass — do not quote it until checked.* |
| Sonnet (workhorse) | **Sonnet 5** | `claude-sonnet-5` (alias `sonnet`) | default model for Pro / Team Standard / Enterprise seats; shipped Week 27 (2026-06-29/07-03); **native 1M context**; adaptive thinking on by default; requires Claude Code ≥ 2.1.197 |
| Haiku (fast / mechanical) | **Haiku 4.5** | `claude-haiku-4-5-20251001` | fast tier; ID is the snapshot-pinned alias |

**Alias resolution is provider-dependent** (verified 2026-08-21): on the Anthropic API `opus`→Opus 5 and `sonnet`→Sonnet 5; on Claude Platform on AWS `sonnet`→Sonnet 4.6; on Amazon Bedrock and Google Cloud's Agent Platform `sonnet`→Sonnet 4.5; on Microsoft Foundry `opus`→Opus 4.6 and `sonnet`→Sonnet 4.5. Pin with a full model name or `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL` where an alias resolves older. The `best` alias selects Fable 5 where the organization has access, otherwise the latest Opus.

**Fast mode:** Opus 5 fast mode is $10/$50 per MTok. *(Prior generation, historical: Opus 4.8 fast mode was also $10/$50; Opus 4.7 was $30/$150.)*

**Fable 5 remains the top tier** (Anthropic's own wording, re-verified 2026-08-21: "the most capable model in Claude Code", suited to tasks larger than a single sitting; it investigates before acting and verifies its own work more often than smaller models). It is **opt-in**, not the default on any account type, and may bill to usage credits.

**Fable 5 routing caveat — needs re-measurement.** [`model-routing.md`](../rules/model-routing.md) still keeps Fable 5 off the forked-reviewer fleet on the basis of a **launch-week (2026-06) observation** (28/28 structured-output subagent failures vs 0 on Opus). That evidence is now ~10 weeks old and predates Opus 5. **Treat the routing rule as unverified until re-measured** — it is a stale recommendation of exactly the class this file exists to prevent.

**The advisor tool is the native form of "strongest model adjudicates"** (verified 2026-08-21; experimental, Anthropic API only): set `advisorModel` or `/advisor`, and the main model consults a stronger advisor at hard decisions. An Opus 4.7-or-later main accepts a Fable advisor. This is worth evaluating against the current per-agent model pinning.

## Prior generations

It is fine to mention older versions in **historical** contexts (CHANGELOG entries) or in explicit **"prior generation" / comparison** lines (e.g. "Opus 4.8's `high` does what Opus 4.7's `xhigh` did"). They must **not** be presented as the current / newest / default model.

- **Opus 4.8** — prior Opus generation (was the default until Opus 5 shipped Week 30, 2026).
- **Opus 4.7**, **Opus 4.6** — prior Opus generations.
- **Sonnet 4.6**, **Sonnet 4.5** — prior Sonnet generations; still what `sonnet` resolves to on some third-party providers (see alias table above).

The checker allows a line to mention an older version when it carries a marker such as `prior generation`, `retire`, `migrat`, `deprecat`, `or later`, `historical`, an `X.Y's` comparison, or an inline `<!-- model-allow -->` comment.

## Update protocol (when Anthropic ships a new model)

1. Update the table **and** the `<!-- CURRENT: ... -->` marker above, plus the "Last verified" date.
2. Run `./scripts/check-model-versions.sh` and fix every current-state surface it flags.
3. **Manually grep for superlatives** — `grep -rniE "newest|most capable" README.md CLAUDE.md guide/ docs/index.html .claude/rules/` — and re-verify each hit. The checker validates *version strings*; a claim like "X is the newest model" is a **semantic** assertion it can only partially catch (it flags `newest`/`most capable` lines that name a non-top tier, but tier-relative phrasings like "the newest Opus" are legitimately allowed). The 2026-06-09 Fable 5 launch made exactly this class of claim false while the gate stayed green.
4. Add a "Changed — model refresh" entry to `CHANGELOG.md`; leave historical CHANGELOG entries intact.
