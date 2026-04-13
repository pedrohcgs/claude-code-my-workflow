# Research Program: [YOUR STUDY NAME]

<!-- Karpathy-style constraint document for autonomous research loops.
     Define what the agent CAN and CANNOT modify, and what success looks like.
     See: https://github.com/karpathy/autoresearch
     See: templates used with /simulation-study skill -->

## Project Summary

[1-2 paragraph description of the research project, its goals, and the specific
question this autonomous loop should explore.]

## What You CAN Modify

<!-- List the files, parameters, and implementations the agent is free to change -->
- [ ] `scripts/R/[study]_simulations.R` -- estimator implementations, tuning parameters
- [ ] DGP parameters: sample sizes, effect sizes, number of time periods
- [ ] Specification choices: bandwidth, kernel, trimming thresholds
- [ ] Number of replications (up to [MAX_REPS])

## What You CANNOT Modify

<!-- These are FROZEN -- the agent must never touch these -->
- [ ] `R/[prepare_data].R` -- data generation pipeline is frozen
- [ ] Evaluation metrics: [RMSE / coverage / bias] (defined below)
- [ ] Output format: results must be CSV with columns defined below
- [ ] Random seed convention: `set.seed(YYYYMMDD)`
- [ ] Core package versions (see `renv.lock`)

## Success Metric

**Primary:** [e.g., Minimize RMSE at n=500] (lower is better)
**Secondary:** [e.g., Coverage rate >= 93%] (constraint, not optimized)
**Tertiary:** [e.g., Computational time < 5 min per run]

If multiple criteria conflict, use this priority: [primary > secondary > tertiary].

## Experiment Protocol

1. Make ONE focused change to the editable files
2. Run the simulation: `Rscript scripts/R/[study]_simulations.R`
3. Record results in the experiment log below
4. If metric improved: `git add . && git commit -m "Exp N: [description] -> [metric]"`
5. If metric worsened or unchanged: `git checkout -- scripts/R/[study]_simulations.R`
6. Repeat from step 1

**Maximum runtime per experiment:** [e.g., 30 minutes]
**Maximum total experiments:** [e.g., 50]
**Never stop** -- keep exploring until the human interrupts or max experiments reached.

## Experiment Log

| # | Branch/Commit | Change Description | Primary Metric | Secondary | Status |
|---|--------------|-------------------|----------------|-----------|--------|
| 0 | baseline | Initial implementation | [value] | [value] | DONE |
| 1 | -- | -- | -- | -- | -- |

## Output Format

Results CSV must have these columns:
```
dgp, estimator, n, bias, rmse, coverage, ci_length, runtime_sec
```

## Constraints and Guardrails

- Always save results before starting next experiment
- Never modify files listed in "CANNOT Modify" section
- If an experiment crashes, log the error and revert before continuing
- Checkpoint every [1000] replications for long runs
- Use `message()` for progress updates, never `cat()` or `print()`
