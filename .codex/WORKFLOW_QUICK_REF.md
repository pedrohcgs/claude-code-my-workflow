# Codex Research Workflow — Quick Reference

## Start safely

1. Start Codex at the repository root with `codex`.
2. Trust the project only after reviewing `AGENTS.md` and `.codex/config.toml`.
3. Open `/hooks`; review and trust the exact hashes of the project hooks.
4. Run `./scripts/validate-setup.sh --platform codex`.

Project defaults use a workspace-write sandbox, reject approval prompts rather than
escalating, and disable network access for sandboxed shell commands. Web search and
connectors have their own controls. The native status line shows the model, reasoning
effort, directory, branch, and remaining context.

## Invoke work

Skills use `$name`, for example:

```text
$data-analysis analyze the cleaned panel and produce the registered robustness table
$strategize turn the approved research question and data inventory into an analysis contract
$draft-paper draft the results section from the verified tables and figures
$create-talk --engine quarto --paper paper/main.tex --minutes 20
$review-paper review paper/draft.tex as a methods referee
$compile-latex compile Slides/seminar.tex and inspect the rendered PDF
$checkpoint record the current research state before changing direction
```

Use `/status` or `/statusline` for live session information. Use `/agents` to inspect
available custom agents and their model, reasoning, and sandbox settings. Reviewer
agents are read-only. The strategist, writer, and storyteller may write only the
creation artifacts explicitly authorized by their dispatch; the verifier may
write ordinary build and test artifacts.

Use `.codex/guidance/research-lifecycle.md` to identify handoffs among strategy,
analysis, manuscript, review, and presentation. The map does not auto-invoke the
next stage.

## Verify and finish

```bash
./scripts/validate-setup.sh --platform codex
./scripts/backtest.sh
```

Also run the artifact-specific oracle: execute affected R/Python analysis, compile
changed LaTeX, visually inspect PDFs, and run `$audit-reproducibility` after numeric
sources or displays change. State exactly what was and was not verified.

## Model pins

Agent model pins are intentional defaults in `.codex/agents/*.toml`; their inventory
and next review date live in `.codex/port-manifest.toml`. Override a pin in the
specific agent file when the configured model is unavailable, then update the
manifest and re-run validation.

## Durable state

- Plans and checkpoints: `quality_reports/plans/`, `quality_reports/checkpoints/`
- Session records: `quality_reports/session_logs/`
- Reusable corrections: `MEMORY.md`
- Qualification evidence: `quality_reports/qualification/LEDGER.md`
