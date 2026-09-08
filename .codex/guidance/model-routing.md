---
paths: [".codex/agents/**/*.toml", ".agents/skills/**/SKILL.md"]
---
# Codex model routing

Use the least expensive tier that preserves the required judgment:

| Tier | Effort | Work |
|---|---|---|
| `gpt-6-astra` | high | claim verification, research strategy, journal editing, domain/methods refereeing, simulation and TikZ review |
| `gpt-5.6-sol` | high | manuscript and talk creation; presentation-domain, R, R-package, and end-to-end verification |
| `gpt-5.6-terra` | high | humanize and slide audits |
| `gpt-5.6-terra` | medium | memory-promotion council |
| `gpt-5.6-luna` | medium | proofreading |

Do not silently downgrade adversarial judgment, source reconciliation, methodological reasoning, or geometric inspection. Pins are defaults, not permanent availability claims. Review this table and `.codex/references/model-routing.md` by **2026-12-07**, or earlier if identifiers or official guidance change.
