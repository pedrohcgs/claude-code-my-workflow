# scripts/ — analysis map

Analysis for the review-ratings project, organized by language (skills expect these paths) and tagged by
component. **Stata is primary; R and Python are secondary.**

| Path | Role | Components served |
| --- | --- | --- |
| `stata/` | **PRIMARY** — distributional statistics on rating shapes | Empirical |
| `python/scraping/` | Platform data collection (Google/Yelp, not-recommended pile) | Empirical |
| `python/classifier/` | LLM review-text classifier: build + validation | Empirical |
| `R/theory/` | 2×2 model numerics: equilibrium, comparative statics | Theory |
| `R/experiment/` | Consumer-inference experiment analysis | Experiment |
| `R/00_run_all.R` + `R/01–05` | Reproducibility orchestrator + numbered pipeline stubs | (shared) |

Supporting scripts in this directory (`quality_score.py`, `check-*.py/.sh`, `validate-setup.sh`,
`sync_to_docs.sh`, `install-hooks.sh`, etc.) are **template machinery** — mostly dormant for this project.
Per `CLAUDE.md`, do not run `install-hooks.sh`, and treat `quality_score.py` as advisory (it errors on
`.md`/`.py`/`.do`).

Conventions live in `.claude/rules/{stata,r,python}-code-conventions.md`. Reproducibility contract:
`.claude/rules/replication-protocol.md`.
