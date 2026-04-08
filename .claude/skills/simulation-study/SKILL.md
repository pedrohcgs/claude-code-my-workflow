---
name: simulation-study
description: Generate structured Monte Carlo simulation harness with DGP-estimator-evaluation scaffold following project conventions.
argument-hint: "[study-name] [topic description]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Simulation Study

Generate a structured R script for Monte Carlo simulation studies following project conventions.

## Usage

```
/simulation-study power_analysis DID estimator power under staggered adoption
/simulation-study coverage Bootstrap confidence interval coverage rates
```

## What It Generates

A scaffolded R script at `scripts/R/[study_name]_simulations.R` with:

1. **Header** (per r-code-conventions.md)
2. **Setup** -- packages, seed (`set.seed(YYYYMMDD)` format), project theme, output directory
3. **DGP functions** -- each DGP as a named function returning a data frame
4. **Estimator wrappers** -- each estimator as a function taking data, returning estimates + SEs
5. **Simulation runner** -- parallelized loop with L'Ecuyer-CMRG seeding
6. **Results aggregation** -- bias, RMSE, coverage, CI length as evidence tables
7. **Figure generation** -- density plots, comparison tables (project theme, transparent backgrounds)
8. **Output** -- CSV results to `output/simulations/results/`, plots to `output/simulations/plots/`

## Evidence Table Output

```markdown
| DGP | Estimator | Bias | RMSE | Coverage | CI Length | Verdict |
|-----|-----------|------|------|----------|-----------|---------|
| 1   | Method A  | 0.002 | 0.105 | 94.8%  | 0.41      | PASS    |
| 2   | Method B  | 0.015 | 0.132 | 93.1%  | 0.52      | PASS    |
```

## Conventions Enforced

- `set.seed(YYYYMMDD)` at top (one seed, no per-replication seeds)
- `on.exit(stopCluster(cl))` for parallel cleanup
- `message()` for milestones only, no `cat()`/`print()`
- Max 8 CPU cores: `min(max(1, parallel::detectCores() - 1), 8)`
- Checkpoint every 1000 replications for long runs
- Transparent backgrounds on all plots

## Autoresearch Pattern (Optional)

For autonomous exploration, create a `program.md` file (see `templates/research-program.md`) that defines:
- What the agent CAN modify (estimator implementations, DGP parameters)
- What is FROZEN (evaluation metrics, data generation pipeline)
- Success metric (e.g., minimize RMSE, maximize coverage)
- Keep-or-revert discipline with git

This enables overnight autonomous simulation sweeps following Karpathy's autoresearch pattern.

## Troubleshooting

- **Parallel issues on macOS:** Use `parallel::makeForkCluster()` instead of `makeCluster(type="PSOCK")`
- **Memory issues:** Reduce replications or use checkpointing
- **Reproducibility:** Always use L'Ecuyer-CMRG RNG kind with `RNGkind("L'Ecuyer-CMRG")`
