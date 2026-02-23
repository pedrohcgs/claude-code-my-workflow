# Claude Code workflow for data analysis

Personal upstream repo for economics research projects using Claude Code with LaTeX/Beamer slides and Python/Stata analysis scripts.

## What this is

A ready-to-clone template that gives Claude Code the infrastructure to work as a research assistant: plan-first workflow, quality gates, specialized review agents, and automated hooks. You describe what you want; Claude plans the approach, executes, verifies, and reports back.

## Quick start

### 1. Clone and set up remotes

```bash
# Clone as a new project
git clone https://github.com/etjernst/claude-code-my-workflow.git my-project
cd my-project

# Keep the workflow repo as 'workflow' remote (for pulling updates later)
git remote rename origin workflow

# Point 'origin' to your new project repo
git remote add origin https://github.com/YOUR_USERNAME/my-project.git
git push -u origin main
```

### 2. Start Claude Code and paste this prompt

```bash
claude
```

Then paste the following, filling in your project details:

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2--3 sentences---what you're building, who it's for, what tools you use.]**
>
> I want our collaboration to be structured, precise, and rigorous. When creating visuals, everything must be polished and publication-ready.
>
> I've set up a Claude Code academic workflow. The configuration files are already in this repo. Please read them, understand the workflow, and then **update all configuration files to fit my project**: fill in placeholders in `CLAUDE.md`, adjust rules if needed, and propose any customizations specific to my use case.
>
> Set up sync by running `bash templates/setup-sync.sh`---my main Dropbox folder is **[path, e.g., C:/Users/me/Dropbox/shared-project]** and my Overleaf Dropbox folder is **[path, e.g., C:/Users/me/Dropbox/Apps/Overleaf/my-paper]** with outputs going to **[mappings, e.g., project/output/tables:tables and project/output/figures:figures]**. After setup, pull existing files with `bash sync-from-dropbox.sh`. *(If no Dropbox or Overleaf, delete this paragraph and just copy files into `project/` manually.)*
>
> After that, use the plan-first workflow for all non-trivial tasks. Once I approve a plan, switch to contractor mode---coordinate everything autonomously and only come back to me when there's ambiguity or a decision to make.
>
> Enter plan mode and start by adapting the workflow configuration for this project.

Claude reads the configuration files, sets up Dropbox sync if applicable, pulls in your project files, fills in placeholders, and enters contractor mode. You approve the plan and Claude handles the rest.

## How it works

You describe a task. Claude plans the approach, implements it, runs specialized review agents, fixes issues, re-verifies, and scores against quality gates---all autonomously. You see a summary when the work meets quality standards.

Eight focused agents each check one dimension: proofreading, slide layout, pedagogy, Python code, Stata code, domain correctness, TikZ diagrams, and end-to-end verification. The `/slide-excellence` skill runs them all in parallel.

See `CLAUDE.md` for full configuration, available commands, and quality thresholds.

## Syncing workflow improvements

Infrastructure lives in `.claude/`, `templates/`, `preambles/`, and `scripts/quality_score.py`. Project-specific files (`CLAUDE.md`, `MEMORY.md`, `project/`, `.claude/settings.json`) are never synced.

### Pull updates from the workflow repo into a project

```bash
cd /path/to/my-project
bash /path/to/workflow-repo/templates/sync-from-workflow.sh
git diff          # review
git add -p        # stage what you want
git commit
```

### Push improvements from a project back to the workflow repo

```bash
cd /path/to/my-project
bash templates/sync-to-workflow.sh /path/to/workflow-repo
cd /path/to/workflow-repo
git diff          # review
git add -p        # stage what you want
git commit
```

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- XeLaTeX via MikTeX (Windows) or TeX Live
- Python (Anaconda or standard)
- Stata (stata-mp on PATH)
- GitHub CLI (`gh`) for PR workflows

Not all tools are needed---install only what your project uses. Claude Code is the only hard requirement.

## Origin

Adapted from [Pedro Sant'Anna's Claude Code workflow](https://github.com/pedrohcgs/claude-code-my-workflow). The original project used R + Quarto + Beamer. This fork uses Stata + Python + LaTeX/Beamer on Windows.

## License

MIT License. Use freely for teaching, research, or any academic purpose.
