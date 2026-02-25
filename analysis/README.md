# Analysis: Task-Based DAG Structure

Each analysis task lives in its own directory with three subfolders:

```
analysis/
├── task_name/
│   ├── code/          # .do files (main.do is entry point)
│   ├── inputs/        # Symlinks to other tasks' outputs/
│   └── outputs/       # Results: .dta, .csv, .tex, .png
```

## Convention

- **`code/`** contains Stata .do files. `main.do` is always the entry point.
- **`inputs/`** contains ONLY symbolic links to another task's `outputs/` directory.
- **`outputs/`** contains all produced files (data, figures, tables, logs).
- Task names use `snake_case`.
- All paths within .do files are relative to the task root.

## Running a Task

```bash
cd analysis/task_name && stata-mp -b do code/main.do
```

## Creating a New Task

```bash
mkdir -p analysis/new_task/{code,inputs,outputs}
# Create symlinks to upstream dependencies:
ln -s ../../upstream_task/outputs/data.dta analysis/new_task/inputs/data.dta
```

## Current Tasks

| Task | Purpose | Upstream Dependencies |
|------|---------|----------------------|
| `build_nipa_shares` | Construct factor shares from BEA NIPA data | -- (raw data) |
| `build_bls_employment` | Process BLS employment and wage data | -- (raw data) |
