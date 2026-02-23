# Project files

Drop your existing project folder contents here. Do not reorganize---describe the structure in `CLAUDE.md` instead, and Claude will navigate it as-is.

## Convention

- Raw data files are protected by `.claude/hooks/protect-files.sh` and `.gitignore`
- Code files (.py, .do, .tex) are tracked by git
- Output files (tables, figures) are gitignored by default

## What goes here

Anything your collaborators need: data, code, output, documentation. The repo's infrastructure (`.claude/`, `quality_reports/`, `templates/`, `preambles/`, `scripts/`) stays at the root level and never enters Dropbox.

## Dropbox and Overleaf sync

If your project lives in a shared Dropbox folder, or if you push outputs to an Overleaf Dropbox folder, run the one-time setup script from the repo root:

```bash
bash templates/setup-sync.sh
```

The script asks which sync targets you use and configures everything:

- Main Dropbox: bidirectional sync between `project/` and a Dropbox folder. Every commit pushes automatically; run `bash sync-from-dropbox.sh` to pull collaborator changes.
- Overleaf Dropbox: one-way push of output directories (tables, figures) to an Overleaf-synced Dropbox folder on every commit.

All paths are stored in `.sync-config` (gitignored). After setup, pull in existing Dropbox contents:

```bash
bash sync-from-dropbox.sh
```

### Daily workflow

```bash
# Start of session: pull any collaborator changes
bash sync-from-dropbox.sh

# Work normally---commit as usual
git add -A && git commit -m "update analysis"
# post-commit hook automatically pushes to Dropbox and Overleaf
```

### If you don't use Dropbox or Overleaf

Skip this entirely. The workflow functions without it.
