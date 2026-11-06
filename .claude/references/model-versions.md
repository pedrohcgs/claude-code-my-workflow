<!-- CURRENT: Fable 5.1 | Opus 5.5 | Sonnet 5.5 | Haiku 5.5 -->

# Current Model Versions (single source of truth)

**Last verified against Anthropic docs:** 2026-11-06  
**Expires:** 2027-01-05 (60 days) — after this date the currency gate fails until re-verified.

This file is the **one place** that names current Claude model point versions. Everything else in the template should either refer to tiers abstractly ("newest Opus", "the Haiku tier") or point here. `scripts/check-model-versions.sh` flags any **superseded** version that is presented as **current** in the template's user-facing surfaces.

The machine-readable `<!-- CURRENT: ... -->` marker at the top is parsed by the checker — keep it in sync with the table.

Sources: platform.claude.com `about-claude/pricing`, `about-claude/model-deprecations`, `build-with-claude/fast-mode`, `models/haiku-5-5/overview` and `models/haiku-5-5/migration-guide`, and code.claude.com `changelog` (re-read 2026-11-06); platform.claude.com `about-claude/models/overview` and code.claude.com `model-config` (read 2026-11-04); platform.claude.com `build-with-claude/prompt-engineering/prompting-claude-opus-5-5`.

| Tier | Current version | Model ID | Notes |
|------|-----------------|----------|-------|
| Fable (Mythos-class; hardest, long-horizon) | **Fable 5.1** | `claude-fable-5-1` (alias `fable`; also what `best` selects where Fable is available) | most capable model in Claude Code; **opt-in** (`/model fable`) — NOT the default on any plan or provider; GA 2026-09-01; $10/$50 per MTok (cache reads $0.25); 1M context, 128K max output; adaptive thinking always on; defaults to `high` effort; requires Claude Code ≥ 2.1.257 |
| Opus (high-judgment) | **Opus 5.5** | `claude-opus-5-5` (alias `opus`) | **the Claude Code default** on Pro / Max / Team / Enterprise / Anthropic API (and on Claude Platform on AWS, Bedrock, Google Cloud's Agent Platform); GA 2026-09-22; $4/$20 per MTok (cache reads $0.20); 1M context, 128K max output; adaptive thinking **always on** (cannot be disabled — effort is the only depth control); **defaults to `medium` effort**; requires Claude Code ≥ 2.1.280 |
| Sonnet (workhorse) | **Sonnet 5.5** | `claude-sonnet-5-5` (alias `sonnet`) | GA 2026-09-28; $2/$10 per MTok (cache reads dropped 50% to $0.10/MTok); native 1M context, 128K max output; adaptive thinking; defaults to `high` effort on the API |
| Haiku (fast / mechanical) | **Haiku 5.5** | `claude-haiku-5-5` (alias `haiku`) | GA 2026-10-07 (replaces Haiku 4.5); tiered pricing: $0.10/$0.50 per MTok up to 100K tokens ($0.50/$2.50 over 100K; cache reads $0.01/$0.05); native 1M context (up from 200K), 128K max output (up from 64K); adaptive thinking; **the first Haiku with `effort` (`low` through `max`, defaults to `medium`)**; accepts a forced `tool_choice`, but the response then skips thinking |

**Effort defaults differ by tier — set `effort` explicitly rather than assuming one.** Opus 5.5 and Haiku 5.5 default to `medium`; Fable 5.1 and Sonnet 5.5 default to `high` on the API. Anthropic's Opus 5.5 guidance: its `medium` matches or exceeds the prior Opus generation at `high` on coding and knowledge-work evaluations, and at a given level it thinks *more* per turn — so lower effort before adding "think less" prose, and reserve `xhigh`/`max` for measured gains. Routing consequences live in [`model-routing.md`](../rules/model-routing.md).

**Alias resolution is provider-dependent** (verified 2026-11-04): on the Anthropic API `opus`→Opus 5.5, `sonnet`→Sonnet 5.5, and `haiku`→Haiku 5.5; third-party providers (Claude Platform on AWS, Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry) roll aliases forward on their own schedules and may still resolve `sonnet`, `haiku`, or `opus` to prior generations. `fable` resolves to Fable 5.1 except in Claude apps gateway sessions (Fable 5 there). Pin with a full model name or `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_HAIKU_MODEL` / `ANTHROPIC_DEFAULT_FABLE_MODEL` where an alias resolves older; `CLAUDE_CODE_SUBAGENT_MODEL` sets the default model and `CLAUDE_CODE_SUBAGENT_EFFORT` sets the default effort for subagents.

**Fast mode** (research preview, Claude API only): Opus 5.5 is $8/$40 per MTok. *(Prior generation, historical: Opus 5 fast mode was $10/$50; Opus 4.8 fast mode is deprecated and will be removed on 2026-11-30.)*

**Fable vs Opus, in Anthropic's words** (models overview, 2026-11-04): "start with Claude Opus 5.5 for most workloads. Use Claude Fable 5.1 for demanding reasoning and long-horizon agentic work, or when your evals on Claude Opus 5.5 at higher effort still fall short." Fable 5.1 is 2.5× the Opus 5.5 per-token price.

**Forced tool choice is gone on the Fable, Opus and Sonnet tiers.** Fable 5.1, Opus 5.5 and Sonnet 5.5 reject `tool_choice` `any`/`tool` at the API (Haiku 5.5 still accepts it, and then answers without thinking); harnesses steer with `auto` + `strict` tool schemas or structured outputs. The launch-week "28/28 structured-output failures" observation that once kept Fable off the reviewer fleet was about a forced-tool protocol that no longer exists on the Fable and Opus tiers — the routing rule now rests on cost and Anthropic's own guidance alone.

**The advisor tool is the native form of "strongest model adjudicates"** (verified 2026-08-21; experimental, Anthropic API only): set `advisorModel` or `/advisor`, and the main model consults a stronger advisor at hard decisions. An Opus 4.7-or-later main accepts a Fable advisor. This is worth evaluating against the current per-agent model pinning.

## Prior generations

It is fine to mention older versions in **historical** contexts (CHANGELOG entries) or in explicit **"prior generation" / comparison** lines (e.g. "Opus 4.8's `high` does what Opus 4.7's `xhigh` did"). They must **not** be presented as the current / newest / default model.

- **Fable 5** (`claude-fable-5`) — prior Fable generation; still served (and what `fable` resolves to in Claude apps gateway sessions).
- **Opus 5** (`claude-opus-5`) — prior Opus generation (the Claude Code default from Week 30 until Opus 5.5, v2.1.280); defaulted to `high` effort.
- **Opus 4.8**, **Opus 4.7**, **Opus 4.6** — prior Opus generations.
- **Sonnet 5** (`claude-sonnet-5`), **Sonnet 4.6**, **Sonnet 4.5** — prior Sonnet generations; may still be what `sonnet` resolves to on some third-party providers (see alias resolution above).
- **Haiku 4.5** (`claude-haiku-4-5-20251001`) — prior Haiku generation, succeeded by Haiku 5.5 on 2026-10-07; still served and not deprecated (re-checked 2026-11-06). Its retirement floor (not sooner than 2026-10-15) has passed, so a retirement can now be announced, with at least 60 days' notice. 200K context, no effort parameter.

The checker allows a line to mention an older version when it carries a marker such as `prior generation`, `retire`, `migrat`, `deprecat`, `or later`, `historical`, an `X.Y's` comparison, or an inline `<!-- model-allow -->` comment.

## Update protocol (when Anthropic ships a new model)

1. Update the table **and** the `<!-- CURRENT: ... -->` marker above, plus the "Last verified" and "Expires" dates.
2. Run `./scripts/check-model-versions.sh` and fix every current-state surface it flags.
3. **Manually grep for superlatives and default claims** — `grep -rniE "newest|most capable|defaults? to" README.md CLAUDE.md TROUBLESHOOTING.md guide/ docs/index.html .claude/rules/ .claude/references/` — and re-verify each hit. The checker validates *version strings*; "X is the newest model" or "the Opus tier defaults to `high`" are **semantic** assertions it can only partially catch. The 2026-06-09 Fable 5 launch and the 2026-09-22 Opus 5.5 launch (default effort `high` → `medium`) each made exactly this class of claim false while the gate stayed green.
4. **Re-check effort pins.** A new default effort changes what every `effort:` pin in `.claude/agents/` and `.claude/skills/` means; re-read [`model-routing.md`](../rules/model-routing.md) § effort against the new default.
5. Add a "Changed — model refresh" entry to `CHANGELOG.md`; leave historical CHANGELOG entries intact.
