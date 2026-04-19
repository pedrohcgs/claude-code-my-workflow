# Plan: Simulation Section Revision (2026-04-18)

**Status:** DRAFT
**Goal:** Align simulation code, figures, and paper §5 text with the `simulation_design_plan.md` specification — 4 clean experiments, 3 figures, ECMA/AER standard.

---

## Mind Map of Current Project State

### Paper (`paper/main.tex`)
- **Fully drafted and complete** (~2 300 lines). All sections written and polished.
- **§5 (lines 1162–1258):** Describes a 4-panel main figure:
  - Panel (a): Coverage vs. sparsity β → currently described as a coverage curve
  - Panel (b): RMSE comparison (low-rank vs. naive within-arm mean)
  - Panel (c): Variance decomposition (oracle, sandwich, naive)
  - Panel (d): DAC degradation (K_d = 2 vs 3 dense arms)
- **Appendix:** Sims 6–7 (approximate low-rank, rank misspecification)
- **Bibliography:** `paper/references.bib`

### Simulation Code
- **Core:** `src/dgp/combinatorial_dgp.py`, `src/estimator/lowrank_estimator.py`, `src/inference/sandwich_se.py`
- **7 experiments** in `conf/sim1.yaml`–`sim7.yaml` + `conf/sim_main.yaml`
- **Runner:** `run/simulate.py` (~69 KB)
- **Baselines currently implemented:** naive within-arm mean only
- **Baselines MISSING:** Fully Additive estimator, Oracle estimator (uses true U*)
- **DGP gap:** U* is currently random; design plan calls for U* generated nonlinearly from covariates X_i

### Gap Analysis

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| Baselines | naive within-arm mean | + Fully Additive + Oracle |
| DGP | random U* | U* = nonlinear fn of X_i |
| sim_main panel (a) | boxplots of errors | coverage curves vs. β |
| sim5 | allocation comparison (not in paper) | retire / move to appendix |
| Figures | 8 outputs (sim1–7 + sim_main) | 3 main + 2 appendix |

---

## What Needs to Change

### Layer 1: Code (`src/`)

#### 1a. Add Baseline Estimators (`src/estimator/baselines.py` — NEW FILE)

```python
def estimate_dim(delta_obs, arm_assignments, K):
    """Difference-in-means: tau_hat[k] = sample mean of observed Delta[i,k]."""

def estimate_fully_additive(tau_singletons, arm_definitions, K):
    """Fully Additive: tau[A+B+C] = tau[A] + tau[B] + tau[C].
    For each arm, sum the singleton ATEs for its constituent treatments."""

def estimate_oracle(U_star, V_star):
    """Oracle: uses true latent factors U*, V* (infeasible lower bound on MSE)."""
```

Key design choices:
- DiM = `np.nanmean` per arm (already in runner — extract into reusable function)
- Fully Additive: for arm k with active components S_k, sum DiM estimates of singleton arms in S_k
- Oracle: apply Stage 2 OLS on true U* (not estimated Û)

#### 1b. Extend DGP to Generate U* from Covariates (`src/dgp/combinatorial_dgp.py`)

Add optional `covariate_nonlinear=True` parameter:
```python
# Generate covariates X_i ~ N(0, I_p), p = 5
# U_star[i, :] = MLP(X_i) or polynomial features of X_i
# This tests that Stage 1 CATE estimation generalizes from train → predict on all N
```

Default stays as current (random U*) for backward compat. New parameter activates nonlinear DGP.

#### 1c. Panel (a): Keep as Boxplots

Panel (a) stays as boxplots of estimation errors — no change needed.
Paper §5 description will be updated to match (describe boxplots rather than coverage curves).

#### 1d. Retire Sim5 or Move to Appendix

`conf/sim5.yaml` / Sim 5 in runner tests allocation strategies (RMSE by arm under different β). Not referenced in paper. Options:
- Move to `conf/appendix/sim5.yaml`
- Add a single-sentence footnote in paper: "Simulation 5 (allocation strategies) is in the Online Appendix."

**Decision needed from user** — we will move it to appendix (least disruptive).

---

### Layer 2: Configuration (`conf/`)

Update `conf/sim_main.yaml` to add:
- `baselines: [dim, fully_additive, oracle]`
- `dgp.covariate_nonlinear: true` (once implemented)
- Keep `sparsity_beta_grid: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]`
- Keep `reps: 500`, `N: 1000`, `d: 3`, `r: 3`

---

### Layer 3: Runner (`run/simulate.py`)

Update `run_one_rep()` to:
1. Compute DiM, Fully Additive, and Oracle ATE for each arm
2. Log all four estimates (two-stage, DiM, fully-additive, oracle) in result dict
3. Compute RMSE and coverage for each estimator

Update plotting:
- Figure 1 (Experiment 1): RMSE ratio vs. sparse sample size — all 4 estimators
- Figure 2 (Experiment 2): Coverage vs. β — sandwich vs. naive
- Figure 3 (Experiment 3 + 4): DAC failure (panel a) + σ_E sweep (panel b)

---

### Layer 4: Paper §5 Text (`paper/main.tex`)

**Minimal changes — paper structure is already correct.** Specific line edits:

| Location | Current | Revised |
|----------|---------|---------|
| Comparators description | "naive within-arm mean" | "DiM, Fully Additive model, and Oracle estimator" |
| Panel (a) description | coverage curves (paper text) | update to describe boxplots (matches figure) |
| Panel (b) caption | just mentions naive | add Fully Additive and Oracle lines |
| Appendix note | references sims 6–7 separately | add brief note that sim 5 (allocation) is in Online Appendix |
| Figure reference | `fig:sims` | confirm consistent with regenerated figure |

---

### Layer 5: Figures (regenerate after code changes)

| Figure | Content | Path |
|--------|---------|------|
| `sim_main.pdf` | 4-panel: coverage, RMSE-all-baselines, variance decomp, DAC | `paper/sim_main.pdf` |
| `sim6_approx_lowrank.pdf` | σ_E sweep (Exp 4) — existing, may regenerate | `paper/sim6_approx_lowrank.pdf` |
| `sim7_rank_misspec.pdf` | rank misspec (appendix) | `paper/sim7_rank_misspec.pdf` |

---

## Files to Modify

| File | Change |
|------|--------|
| `src/estimator/baselines.py` | **CREATE** — DiM, Fully Additive, Oracle functions |
| `src/dgp/combinatorial_dgp.py` | **MODIFY** — add optional covariate-based nonlinear U* |
| `run/simulate.py` | **MODIFY** — integrate baselines, fix panel (a), update plotting |
| `conf/sim_main.yaml` | **MODIFY** — add baselines config |
| `conf/sim5.yaml` | **MOVE** → `conf/appendix/sim5.yaml` |
| `paper/main.tex` | **MODIFY** — update comparator names, panel captions, appendix note |
| `tests/test_estimator.py` | **MODIFY** — add tests for new baseline estimators |

---

## Order of Execution

1. **Create `src/estimator/baselines.py`** with DiM, Fully Additive, Oracle
2. **Extend DGP** with nonlinear covariate option
3. **Update `run/simulate.py`**: integrate baselines + fix panel (a) plot
4. **Update `conf/sim_main.yaml`** + move sim5 to appendix
5. **Run simulations** to regenerate figures (`uv run python run/simulate.py --config-name sim_main`)
6. **Update `tests/test_estimator.py`** with baseline tests
7. **Edit `paper/main.tex` §5** — update comparator names and captions
8. **Verify:** `uv run pytest tests/`, check figures compile in paper

---

## Verification

```bash
# Run tests
uv run pytest tests/ -v

# Regenerate main figure
uv run python run/simulate.py --config-name sim_main

# Compile paper to confirm figure imports correctly
cd paper && pdflatex main.tex
```

Expected: `sim_main.pdf` with 4 panels, paper §5 references DiM/Fully Additive/Oracle, all tests pass.

---

## What Is NOT Changed

- `src/estimator/lowrank_estimator.py` — Core two-stage estimator (no changes)
- `src/inference/sandwich_se.py` — SE estimation (no changes)
- `conf/sim1.yaml`–`conf/sim4.yaml`, `sim6.yaml`, `sim7.yaml` — individual experiment configs (no changes unless runner refactor requires it)
- Paper §1–4, §6, appendix — no changes
- All Claude Code workflow files (CLAUDE.md, skills, agents, etc.)
