# Codex agent fleet

The 17 custom agents under `.codex/agents/` provide isolated specialist lenses
and bounded creation roles. Reviewers use `sandbox_mode = "read-only"`. The
strategist, writer, and storyteller use `workspace-write` only for artifacts
explicitly authorized by their dispatch; the verifier uses it for ordinary
build/test artifacts.

| Agent | Role | Model / effort | Typical dispatcher |
|---|---|---|---|
| `claim-verifier` | Independent factual and citation verification | `gpt-6-astra` / high | `$verify-claims`, post-flight gates |
| `domain-referee` | Manuscript contribution, positioning, scope, fit | `gpt-6-astra` / high | `$review-paper --peer` |
| `editor` | Desk review, referee selection, synthesis | `gpt-6-astra` / high | `$review-paper --peer` |
| `methods-referee` | Paper-type-aware methods review | `gpt-6-astra` / high | `$review-paper --peer` |
| `sim-reviewer` | DGP, estimand, MCSE, coverage, regime audit | `gpt-6-astra` / high | `$simulation-study` |
| `tikz-reviewer` | Measured geometric and visual audit | `gpt-6-astra` / high | `$extract-tikz`, `$new-diagram` |
| `strategist` | Estimand-first empirical-strategy creation | `gpt-6-astra` / high | `$strategize` |
| `presentation-domain-reviewer` | Substantive research-presentation review | `gpt-5.6-sol` / high | `$slide-excellence`, `$present-paper` |
| `r-package-reviewer` | Package checks and CRAN readiness | `gpt-5.6-sol` / high | `$r-package-check` |
| `r-reviewer` | Research R correctness and reproducibility | `gpt-5.6-sol` / high | `$review-r`, `$data-analysis` |
| `verifier` | End-to-end artifact checks | `gpt-5.6-sol` / high | `$commit`, `$verify-artifact` |
| `writer` | Evidence-grounded manuscript drafting | `gpt-5.6-sol` / high | `$draft-paper` |
| `storyteller` | Beamer/Quarto research-talk creation | `gpt-5.6-sol` / high | `$create-talk` |
| `humanize-auditor` | AI-voice pattern detection | `gpt-5.6-terra` / high | `$humanize` |
| `slide-auditor` | Research-presentation layout audit | `gpt-5.6-terra` / high | `$visual-audit`, `$slide-excellence` |
| `promote-memory-council` | Five-lens durable-memory vote | `gpt-5.6-terra` / medium | `$promote-memory` |
| `proofreader` | Language and consistency review | `gpt-5.6-luna` / medium | `$proofread` |

## Dispatch rules

- Fan out independent lenses in parallel when their inputs do not overlap.
- Fence answer keys, prior verdicts, or revision markers when they could bias the reviewer.
- Require structured findings compatible with `finding-schema.json`.
- A synthesizer may deduplicate or downgrade findings, but a new critical finding needs independent verification.
- Review agents report; the parent agent applies authorized edits. Creator
  agents may write only the artifact class and paths named in their dispatch.

See `model-routing.md`, `orchestration-schemas.md`, and `../guidance/review-fencing.md`.
