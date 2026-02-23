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
# Interactive (asks for paths)
bash templates/setup-sync.sh

# Non-interactive (Claude Code uses this)
bash templates/setup-sync.sh \
  --dropbox "C:/Users/me/Dropbox/shared-project" \
  --overleaf "C:/Users/me/Dropbox/Apps/Overleaf/my-paper" \
  --push "project/output/tables:tables,project/output/figures:figures" \
  --pull ".:project/paper"
```

All flags are optional---omit `--dropbox` or `--overleaf` if you don't use them. The script configures:

- Main Dropbox: bidirectional sync between `project/` and a Dropbox folder. Every commit pushes automatically; run `bash sync-pull.sh` to pull collaborator changes.
- Overleaf Dropbox: bidirectional sync with an Overleaf-synced Dropbox folder. Push mappings send outputs (tables, figures) on every commit; pull mappings bring back paper edits at session start.

All paths are stored in `.sync-config` (gitignored). After setup, pull in existing Dropbox contents:

```bash
bash sync-pull.sh
```

### Daily workflow

```bash
# Start of session: pull any collaborator changes
bash sync-pull.sh

# Work normally---commit as usual
git add -A && git commit -m "update analysis"
# post-commit hook automatically pushes to Dropbox and Overleaf
```

### If you don't use Dropbox or Overleaf

Skip this entirely. The workflow functions without it.
