# scripts/stata/ — PRIMARY analysis (distributional statistics)

Stata `.do` files are the **primary** analysis for this project: distributional statistics on the
scraped star-rating data (comparing the *shape* of Google vs. Yelp rating distributions for matched
establishments, and testing whether the solicit/organic split tracks quality).

## Conventions

Follow `.claude/rules/stata-code-conventions.md`. Headline rules:

- **No hardcoded absolute paths** — resolve paths relative to the repo root.
- **`set seed` once**, near the top; record the value.
- **Version-stamp** the run (`version` / `about`) for the replication package (`/capture-environment`).
- Save outputs to a documented location; export tables/figures in a durable format.
- The claim is about **shape, not just the mean** — use distributional comparisons (e.g. KS,
  earth-mover / moment tests), not only a difference in means. See the pitfalls table in
  `.claude/rules/knowledge-base-template.md`.

## Reviewing

- `/stata-replication` — replicate-to-the-dot before extending.
- `/audit-reproducibility` — verify numeric claims in the draft against the do-file outputs.

*(No do-files yet — the influencer-marketing Essay 2 files were removed on 2026-09-14 when the repo was
repurposed. Add files as the distributional analysis is written.)*
