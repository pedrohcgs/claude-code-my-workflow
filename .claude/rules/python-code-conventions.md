---
paths:
  - "**/*.py"
  - "scripts/**/*.py"
  - "Figures/**/*.py"
---

# Python Code Standards

**Standard:** Senior empirical Python workflow suitable for replication-sensitive work.

## 1. Reproducibility

- Set one project seed near the top of the orchestration layer.
- Use `pathlib.Path` for repo-relative paths.
- Create output directories explicitly before writing files.
- Record environment details when the pipeline runs end to end.

## 2. Project Structure

- Keep the staged pipeline split: load, clean, analyze, tables, figures.
- Use descriptive snake_case names.
- Put reusable logic in small functions instead of long inline notebooks.
- Keep `if __name__ == "__main__":` entry points for runnable scripts.

## 3. Data and Estimation Hygiene

- Avoid hidden global state.
- Make sample restrictions explicit.
- Document clustering, fixed effects, weights, and transformations.
- Save machine-readable outputs for anything cited in manuscripts or slides.

## 4. Figures and Tables

- Export with explicit dimensions.
- Prefer transparent backgrounds when figures may appear on slides.
- Save publication-facing tables in `.tex`, `.csv`, or `.html`.

## 5. Common Pitfalls

| Pitfall | Impact | Prevention |
| --- | --- | --- |
| Hardcoded absolute paths | Breaks on other machines | Use `Path(__file__).resolve()` and repo-relative paths |
| Notebook-only logic | Hard to reproduce | Move production code into scripts |
| Unseeded randomness | Irreproducible estimates | Set one seed in the orchestrator |
| Silent overwrite of outputs | Audit trail loss | Use explicit output names and directories |

## 6. Checklist

```
[ ] Repo-relative paths via pathlib
[ ] Seed set if randomness appears
[ ] Output directories created explicitly
[ ] Publication outputs saved to scripts/python/_outputs/
[ ] Machine-readable artifacts saved for downstream audit
[ ] Comments explain identification or modeling choices, not obvious syntax
```
