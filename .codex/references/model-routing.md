# Model-routing review record

**Last reviewed:** 2026-09-08  
**Review again by:** 2026-12-07

This repository pins agent models by task risk:

- `gpt-6-astra`, high reasoning: claim verifier, domain referee, editor, methods referee, research strategist, simulation reviewer, TikZ reviewer.
- `gpt-5.6-sol`, high reasoning: presentation-domain reviewer, R-package reviewer, R reviewer, artifact verifier, paper writer, research-talk storyteller.
- `gpt-5.6-terra`, high reasoning: humanize auditor and slide auditor.
- `gpt-5.6-terra`, medium reasoning: memory-promotion council.
- `gpt-5.6-luna`, medium reasoning: proofreader.

The operational source of truth is each TOML file under `.codex/agents/`; `.codex/guidance/model-routing.md` states policy. Update all three surfaces together when pins change.

Review early when an identifier is unavailable, latency/cost makes a workflow impractical, a capability requirement changes, or official OpenAI model guidance changes. Validate current official documentation before changing identifiers. Preserve the judgment boundary: high-stakes factual, editorial, methodological, simulation, and geometric review must not be downgraded solely for cost.
