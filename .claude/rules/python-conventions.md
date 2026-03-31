---
paths:
  - "**/*.py"
  - "scripts/python/**/*.py"
  - "gee/**/*.py"
---

# Python Code Conventions: Scientific Computing + GEE + ML

Apply these rules whenever writing or reviewing Python scripts for this thesis.

---

## Reproducibility (Non-Negotiable)

- **Random seeds:** Always set at the top of any script that uses randomness:
  ```python
  import numpy as np
  import random
  np.random.seed(42)
  random.seed(42)
  # For torch: torch.manual_seed(42); torch.cuda.manual_seed_all(42)
  ```
- **Relative paths only:** Use `pathlib.Path` relative to project root. Never hardcode absolute paths.
  ```python
  from pathlib import Path
  ROOT = Path(__file__).parent.parent  # adjust depth as needed
  data_path = ROOT / "Data" / "satellite" / "ndvi.tif"
  ```
- **No credentials in code:** GEE project IDs, API keys, and service account paths go in a `config.yaml` or environment variables — never hardcoded in scripts.
  ```python
  import yaml
  with open(ROOT / "config.yaml") as f:
      cfg = yaml.safe_load(f)
  ee.Initialize(project=cfg["gee"]["project_id"])
  ```

---

## Google Earth Engine (GEE) Patterns

- **Batch exports only:** Never use `.getInfo()` inside loops or for large data. Use `ee.batch.Export.*` for any output intended for analysis.
  ```python
  # WRONG: ee.Image(...).getInfo()  ← blocks execution, quota risk
  # RIGHT: ee.batch.Export.image.toDrive(...)
  ```
- **Document temporal windows:** Every GEE image collection filter must state the date range in a comment.
  ```python
  collection = (ee.ImageCollection("MODIS/006/MOD13Q1")
      .filterDate("2010-01-01", "2022-12-31")  # 12-year window, annual NDVI
      .filterBounds(ethiopia_roi))
  ```
- **Document spatial resolution:** State the nominal resolution in comments when exporting or resampling.
  ```python
  task = ee.batch.Export.image.toDrive(
      image=ndvi_composite,
      scale=250,  # MODIS NDVI: 250m nominal resolution
      ...
  )
  ```
- **Name assets descriptively:** GEE asset IDs should follow `project/year_variable_region` pattern (e.g., `projects/my-project/assets/2015_ndvi_sidama`).
- **Clip before processing:** Always `.clip(roi)` before computing indices, not after.
  ```python
  # WRONG: compute_ndvi(image).clip(roi)
  # RIGHT: compute_ndvi(image.clip(roi))
  ```

---

## Satellite Data Conventions

- **Assert nodata before computing:** Check for masked/nodata pixels before computing derived indices.
  ```python
  # Document nodata handling: MODIS NDVI fill value = -28672
  ndvi = image.select("NDVI").unmask(-28672).rename("ndvi")
  ```
- **CRS and resolution in every output:** Include CRS and resolution in the filename or in an accompanying `.json` metadata file.
- **Provenance:** Every file in `Figures/` must trace to a script in `scripts/python/`. Add a comment at the top of each script naming its outputs:
  ```python
  # OUTPUTS: Figures/maps/ndvi_trend_sidama.png
  #          output/tables/ndvi_summary_stats.csv
  ```

---

## ML Conventions

- **Separate stages into separate scripts:**
  - `prepare_data.py` — load, clean, label generation
  - `train_model.py` — model definition, training loop
  - `evaluate_model.py` — metrics, confusion matrix, validation
- **Spatial cross-validation required:** Do NOT use random train/test splits on satellite data — spatial autocorrelation will inflate accuracy. Use spatial blocks (e.g., `sklearn_spatial` or manual block splits by woredas/zones).
- **Save checkpoints:** Model checkpoints go to `output/models/` with a timestamp:
  ```python
  import torch
  torch.save(model.state_dict(), ROOT / "output/models/clf_ndvi_2024-01-15.pt")
  ```
- **Log metrics to file:** Do not print-only. Write confusion matrix and accuracy metrics to `output/metrics/`:
  ```python
  import json
  metrics = {"accuracy": acc, "f1": f1, "spatial_cv_folds": 5}
  with open(ROOT / "output/metrics/clf_metrics.json", "w") as f:
      json.dump(metrics, f, indent=2)
  ```
- **Document class imbalance:** If degradation/no-degradation labels are imbalanced, state the class ratio in a comment and document the handling strategy (oversampling, class weights, etc.).

---

## Code Quality

- **snake_case** for all function and variable names.
- **Docstrings** for any function >10 lines or with non-obvious behavior:
  ```python
  def compute_spei(precip: np.ndarray, pet: np.ndarray, scale: int = 12) -> np.ndarray:
      """Compute SPEI drought index at given timescale.

      Args:
          precip: Monthly precipitation array (mm), shape (T,)
          pet: Potential evapotranspiration array (mm), shape (T,)
          scale: Accumulation period in months (default 12 = annual)

      Returns:
          SPEI values, shape (T,), NaN where insufficient history
      """
  ```
- **Type hints** for function signatures.
- **Line length:** ≤100 characters. GEE filter chains may extend to 120 characters if splitting would harm readability — document with `# noqa: E501`.
- **Imports:** Standard library → third-party → local. One blank line between groups.
