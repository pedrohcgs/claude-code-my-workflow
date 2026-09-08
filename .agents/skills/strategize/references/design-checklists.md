# Design-specific strategy checklists

Read only the section matching the proposed design. These are prompts for
setting-specific reasoning, not universal estimator prescriptions. Verify
method and software details against primary methodological sources and the
installed environment before implementation.

## Difference-in-differences

- Define treatment timing, reversals, intensity, anticipation, and eligible
  comparison groups.
- State the group/time estimand and aggregation weights. If adoption is
  staggered, justify the estimator under treatment-effect heterogeneity rather
  than relying on an unexamined two-way fixed-effects coefficient.
- Support parallel trends with institutional reasoning and available
  pre-treatment evidence; absence of detected pre-trends does not prove the
  assumption.
- Assess spillovers, compositional change, differential trends, and treatment
  timing endogeneity.
- Match clustering or randomization inference to the assignment process and
  number of independent assignment units.
- Pre-specify alternative comparison groups, cohort/event-time summaries,
  leave-cohort-out checks, placebos, and sensitivity to trend violations.

## Event study

- Define the event, event time, observation window, reference period, endpoint
  bins, and whether treatment is staggered or reversible.
- State which estimand each plotted coefficient represents and whether the
  estimator remains valid under heterogeneous dynamic effects.
- Separate diagnostics for anticipation from evidence about untreated trends.
- Plan pointwise and, when substantively needed, simultaneous uncertainty.
- Pre-specify sensitivity to windows, bins, reference period, comparison group,
  influential cohorts, and plausible trend violations.
- Make plot axes, treatment onset, binned endpoints, and uncertainty explicit.

## Instrumental variables

- Define the instrument, treatment, outcome, timing, and institutional mechanism
  linking the instrument to treatment.
- Address relevance, independence, exclusion, and—when interpreting a local
  average treatment effect—monotonicity and the complier population.
- Treat exclusion as an institutional claim, not a consequence of a significant
  reduced form or an overidentification test.
- Plan first-stage and reduced-form displays, weak-instrument-robust inference,
  and sensitivity to controls, samples, and instrument subsets.
- Identify every plausible direct or correlated channel from instrument to
  outcome and a negative-control or sensitivity analysis where possible.
- Explain the scope and policy relevance of the identified local estimand.

## Regression discontinuity

- Define the running variable, cutoff, treatment rule, assignment precision,
  and whether the design is sharp, fuzzy, discrete, or geographic.
- State the continuity or local-randomization argument and threats from sorting,
  manipulation, co-treatments, and measurement heaping.
- Pre-specify bandwidth and polynomial selection, kernel, bias correction,
  effective sample size, and uncertainty procedure; justify deviations.
- Plan density and predetermined-covariate diagnostics without treating either
  as proof of validity.
- Include bandwidth, polynomial, donut, placebo-cutoff, and running-variable
  measurement sensitivity appropriate to the setting.
- For fuzzy designs, define the first stage and local population explicitly.

## Structural estimation

- Explain which research question requires a model and which counterfactual,
  welfare, or mechanism claim the model licenses.
- Specify agents, timing, information, state and choice variables, constraints,
  equilibrium concept, normalizations, and solution method.
- Map each key parameter to moments or variation in the data and explain the
  economic identification logic; an estimation method is not an identification
  argument.
- Record likelihood or moment conditions, calibrated inputs, weighting, seeds,
  simulation draws, optimization starts, convergence rules, and failure handling.
- Separate moments used for estimation from validation evidence; plan model fit,
  external or held-out validation where feasible, and reduced-form consistency.
- Define counterfactual support, equilibrium selection, welfare aggregation,
  parameter uncertainty, functional-form sensitivity, and extrapolation limits.

## Descriptive or measurement work

- Define the construct, target population, unit, time coverage, and the gap
  between the construct and its empirical proxy.
- Document sources, linkage keys and rates, transformations, thresholds,
  imputation, weighting, aggregation, restrictions, and an observation-flow
  accounting.
- Plan internal validity checks, known-case checks, comparison with established
  measures, and external validation where feasible.
- Identify which construction choices drive the measure and map a sensitivity
  frontier over defensible alternatives.
- State whether variation is cross-sectional, temporal, within-unit, or mixed;
  match decompositions and uncertainty to that structure.
- Keep descriptive language noncausal unless a separate identification design
  licenses a causal claim.
