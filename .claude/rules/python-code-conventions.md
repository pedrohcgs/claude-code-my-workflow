---
paths:
  - "**/*.py"
  - "notebooks/**"
---

# Python Code Conventions

## Reproducibility

- Always set random seeds: `np.random.seed(42)` or use `rng = np.random.default_rng(42)`
- Pin dependencies in `requirements.txt` with exact versions
- Use virtual environments (`venv` or `conda`)
- Record Python version in project metadata
- Never hardcode absolute paths; use `pathlib.Path` with relative paths

## Style

- Follow PEP 8; use `black` for auto-formatting
- Type hints for all public function signatures
- Docstrings: NumPy style for modules, classes, and public functions
- Max line length: 88 (black default)
- Import order: stdlib, third-party, local (enforced by `isort`)

## PV-Specific Conventions

- **Units:** Always document units in variable names or docstrings
  - Irradiance: W/m² (not kW/m²)
  - Temperature: °C (convert from K explicitly)
  - Efficiency: fraction (0-1) internally, % for display
  - Power: W or kW (state which)
- **pvlib naming:** Follow pvlib conventions for solar position, irradiance variables
  - `ghi`, `dni`, `dhi` for irradiance components
  - `solar_zenith`, `solar_azimuth` for position
  - `cell_temperature`, `module_temperature` for thermal
- **Timezone handling:** Always use timezone-aware datetimes for solar data
  - `pd.Timestamp(..., tz='UTC')` or localize explicitly
  - Never mix naive and aware timestamps

## Data Patterns

- Large datasets (>10 MB): use Parquet format
- Small reference data: CSV with clear headers and units row
- Intermediate results: Parquet in `data/processed/`
- Never commit raw data >50 MB to git (use `.gitignore`)
- Document data provenance in a `data/README.md`

## Visualization

- Default backend: matplotlib for static, plotly for interactive
- Publication figures: 300 DPI, transparent background, vector (SVG/PDF) when possible
- Use consistent color palette across project
- Always label axes with units: `"Irradiance (W/m²)"`, `"Temperature (°C)"`
- Save figures to `Figures/` with descriptive names

## Testing

- Use `pytest` for all tests
- Test critical calculations against known reference values
- Parametrize tests for multiple module types/conditions
- Regression tests for key metrics (Pmax, yield, degradation rate)

## Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Naive timestamps in solar calcs | Wrong solar position | Always use tz-aware datetimes |
| W/m² vs kW/m² confusion | 1000x error in yield | Document units at every boundary |
| STC vs real-world conditions | Overstated performance | Label all conditions explicitly |
| Spectral mismatch ignored | 2-5% error in energy yield | Use spectral correction when available |
| pvlib expects specific column names | Silent wrong results | Validate column names before passing |
| Integer division in Python 3 | Truncated results | Use `/` not `//` for real division |
