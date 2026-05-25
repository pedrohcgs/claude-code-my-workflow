# Troubleshooting

Top failure modes newcomers hit, with the fix. If you're stuck somewhere else, run `./scripts/validate-setup.sh` — it reports exactly what's missing.

## Environment / setup

### `claude: command not found`

Claude Code isn't installed. Install it from [claude.ai/install](https://claude.ai/install) (or your OS's package manager). Then re-run `./scripts/validate-setup.sh`.

### `xelatex: command not found`

No TeX Live on the system. Install MacTeX (macOS) or TeX Live (Linux/Windows). Until you do, `/compile-latex` and `/extract-tikz` are disabled; `/deploy` (Quarto) still works.

### `quarto: command not found`

Install Quarto from [quarto.org/docs/get-started](https://quarto.org/docs/get-started/). Until you do, `/deploy` and `/qa-quarto` are disabled; Beamer workflows still work.

### `pdf2svg: command not found`

Required by `/extract-tikz`. `brew install pdf2svg` (macOS) / `apt install pdf2svg` (Debian/Ubuntu) / `dnf install pdf2svg` (Fedora).

### `/stata-replication` halts at "stata-mcp not registered"

The Stata pipeline skill needs the [`stata-mcp`](https://github.com/SepineTam/stata-mcp) MCP server. Install once per user:

```bash
claude mcp add stata-mcp --scope user -- uvx stata-mcp
```

`uvx` is the `uv` package runner (`brew install uv` if missing). The MCP server requires a local Stata installation — it's a bridge, not a replacement. Once installed, restart your Claude Code session so the MCP server registers.

Verify with `claude mcp list` — `stata-mcp` should appear with status `connected`. The skill also halts if Stata itself is not on `PATH`; the install instructions documented in [`/stata-replication`](/.claude/skills/stata-replication/SKILL.md) Phase 0 cover both pre-flight checks.

### Claude keeps asking permission for every tool

Default permission mode prompts on every `Bash`, `Edit`, `Write`. Two fixes:

- **Auto-accept edits** — keybinding in Claude Code; see guide's [permission modes section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#settings---permissions-and-hooks).
- **Bypass mode** — `claude --permission-mode acceptEdits` (auto-approves edits but still prompts for sensitive ops) or `claude --permission-mode bypassPermissions` (skips prompts entirely — use only on trusted repos).

The template's `.claude/settings.json` pre-approves ~100 common patterns, so even at default most routine work is unattended.

## Models and API

### Sonnet 4 / original Opus 4 retire 2026-06-15

Anthropic retires **Sonnet 4** and the **original Opus 4** on **2026-06-15**. If your environment pins one of these, requests will fail after that date.

Migration checklist:

- **Check `ANTHROPIC_MODEL` env:** `echo $ANTHROPIC_MODEL` — if it's `claude-sonnet-4-*` or `claude-opus-4-*` (without a 4.5/4.6/4.7 suffix), update.
- **Check `.claude/settings.json` and `.claude/settings.local.json`** for any `model:` override at the project layer.
- **Check agent frontmatter:** `grep -rn "claude-sonnet-4\b\|claude-opus-4\b" .claude/agents/` — agents that pin to retired models will fall through to inherit, which is usually fine, but worth knowing.
- **Check CI:** any GitHub Actions or other CI that calls `claude -p` with `--model`.

Recommended replacements: `claude-sonnet-4-6` for Sonnet 4, `claude-opus-4-7` for original Opus 4 (Max/Team Premium default as of 2026-04-16, same pricing as 4.6). The 1M-context beta for Sonnet 4.5 / Sonnet 4 retired 2026-04-30 — migrate to Sonnet 4.6 for long-context workflows.

### `/coarse-review` and other `claude -p` skills may bill differently after 2026-06-15

Starting **2026-06-15**, headless subprocess calls (`claude -p`, Agent SDK) on subscription plans draw from a **separate Agent SDK credit pool**, decoupled from interactive credits. Skills affected in this template: `/coarse-review` (every pipeline stage runs as a `claude -p` subprocess). If `/coarse-review` fails after the cutover with a credit-exhaustion error even though your interactive session works, check the Agent SDK credit balance separately. See [Anthropic's release notes](https://platform.claude.com/docs/en/release-notes/overview) for the current credit allocation per plan tier.

## Compilation / rendering

### `Undefined citation` in Beamer

The `.bib` key isn't in `Bibliography_base.bib`. Run `/validate-bib` to cross-check citations against the bib file. The 3-pass XeLaTeX + bibtex sequence in `/compile-latex` resolves keys that exist; it can't invent them.

### `Overfull \hbox` warnings

Text exceeds the slide's printable width. Either shorten the offending content, wrap it in a `text width=...` node (for TikZ), or switch to `\resizebox`. `/visual-audit` flags these; `/proofread` does too.

### Quarto render fails with `No valid input files`

You likely invoked `quarto render` from the wrong cwd. Run it from the repo root. `/deploy` handles this automatically.

### HelloWorld.tex fails to compile

`./scripts/validate-setup.sh` first. If XeLaTeX is installed, re-fork a clean copy — you may have edited the sample deck without realizing it. HelloWorld is intentionally minimal and should always compile on a fresh clone.

### `/extract-tikz` halts at prevention pre-check

Good — the pre-check caught a P3 (bare `scale=`) or P4 (missing directional keyword on an edge label) violation. Fix the offending line in the Beamer source and re-run. See `.claude/rules/tikz-prevention.md`.

## Git / hooks / CI

### Hook script permission denied

`chmod +x .claude/hooks/*.py .claude/hooks/*.sh`. `./scripts/validate-setup.sh` also reports non-executable hooks.

### Pre-compact hook didn't save the plan

The PreCompact hook (`.claude/hooks/pre-compact.py`) writes state to `~/.claude/sessions/<hash>/`. If the state isn't there after compaction:

- Check the hook's exit code: `echo '{}' | python3 .claude/hooks/pre-compact.py` should exit 0.
- Check permissions on `~/.claude/sessions/`.
- Check the session hash matches — compaction logs the hash.

### `/commit` fails with `quality_score.py` below threshold

The script detected issues in changed files. Either fix them (recommended) or re-run `/commit` and explicitly tell Claude **"commit anyway"** or **"skip quality gate"** with a reason — the override is logged in the commit message. (There is no `--skip-quality-gate` CLI flag; the override is a natural-language signal to the skill.)

## Palette / theming

### Beamer and Quarto renderings use different colors

The palette contract broke. Run `./scripts/check-palette-sync.sh` — it reports which color names are missing from one surface. Fix HEX values in **both** `Preambles/header.tex` and `Quarto/theme-template.scss` to match. See `Preambles/README.md` for the full contract.

## R / data analysis

### `here::here()` resolves to the wrong directory

`here` needs a project root marker (`.here`, `.git`, `DESCRIPTION`, or `.Rproj`). If you see wrong paths, create an empty `.here` file at the repo root.

### `sessionInfo.txt` not updated after analysis changes

You ran `03_analyze.R` directly instead of `00_run_all.R`. Re-run `00_run_all.R` (e.g. via the `/data-analysis` skill or your usual pipeline runner) — that entrypoint writes the session snapshot as its last step.

## Permissions / bypass / statusline (v1.6.0 / v1.8.0)

### "Prompts fire despite `bypassPermissions`"

Mid-session permission-mode toggles override file settings until session end. The 6-tier stack (VSCode user → VSCode workspace → CLI user `~/.claude/settings.json` → project `.claude/settings.json` → project-local `.claude/settings.local.json` → in-session runtime) is **last-wins**. Run `/permission-check` — it diffs every layer and reports which wins. Then either exit and restart the session, or `/permission-mode bypassPermissions` to set it for the current session.

### `/permission-check` asks before reading `~/.claude/`

That's intentional. Host-global config can contain unrelated paths and secrets. Phase A (repo-local) is automatic; Phase B (host-global, with key redaction) requires explicit confirmation. See [CHANGELOG v1.6.0 — privacy boundary](CHANGELOG.md) for context.

### Seeing too many permission prompts?

If `/permission-check` confirms your config is permissive but you're still being prompted, the built-in Claude Code skill **`/fewer-permission-prompts`** (Apr 2026) scans your transcripts for common read-only Bash and MCP tool calls and proposes a prioritized allowlist for `.claude/settings.json`. Pairs with our `/permission-check`: `permission-check` diagnoses; `fewer-permission-prompts` remediates.

### Statusline shows `[UNKNOWN]` or blank

Session JSON parse failure. Check `.claude/scripts/statusline.sh` is executable (`chmod +x`) and that `python3` is on `PATH`. Fallback output is `[?] <model> @ <pwd>` — if you see that, the hook caught a malformed session file. Restart Claude Code.

### Bypass mode still prompts on edits to `.claude/`, `.git/`, `.vscode/` (v1.8.0)

This is **not a bug.** Per Anthropic's [permission-modes docs](https://code.claude.com/docs/en/permission-modes), a small set of paths are *protected* and never auto-approved in any mode except `auto`. The protected list as of Apr 2026:

- Directories: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (carve-outs: `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees` — these *do* auto-approve under bypass).
- Files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`.

So edits to `.claude/references/`, `.claude/rules/`, `.claude/hooks/`, `.claude/scripts/` will always prompt under bypass. The only mode that doesn't fire an interactive prompt on protected paths is **auto mode** (Anthropic's Mar 2026 Week 13 release) — protected-path writes route through a classifier model instead. The classifier is still a gate (it can block) — it's just not human-in-the-loop, so you don't get the click-through interruption. Auto mode requires Max / Team / Enterprise / API plan + Sonnet 4.6, Opus 4.6, or Opus 4.7 + Anthropic API provider; toggle visibility in the VSCode mode dropdown by setting `allowDangerouslySkipPermissions: true` in `.vscode/settings.json` and reloading the window.

If you're stuck on bypass and don't qualify for auto mode, two workarounds:

1. **Edit through the Bash tool** — `python3 -c '...'` or `python3 << EOF ... EOF` heredoc patterns can write to `.claude/references/` etc. without firing the protected-paths gate, because Bash isn't subject to it the same way Edit is. Useful for batch refactors.
2. **Move the edit out of `.claude/`** when possible — keep field-customization content under `templates/` or root-level documentation that's not protected.

### `.vscode/settings.json` — `claudeCode.allowDangerouslySkipPermissions` is the wrong key (v1.8.0)

The Claude Code VSCode extension expects **`allowDangerouslySkipPermissions: true`** (no `claudeCode.` prefix). The prefixed form `claudeCode.allowDangerouslySkipPermissions` is silently ignored, leaving the protected-paths gate active even with broad CLI bypass. Fix: drop the `claudeCode.` prefix on that one key (`claudeCode.initialPermissionMode` keeps its prefix). Reload the VSCode window after editing `.vscode/settings.json` for the change to register.

## Peer-review pipeline (v1.5.0)

### `/review-paper --peer AER` fails with "journal not found"

The target must be in [`.claude/references/journal-profiles.md`](.claude/references/journal-profiles.md). Ships with AER / QJE / JPE / ECMA / ReStud. To add your field's journal, copy [`templates/journal-profile-template.md`](templates/journal-profile-template.md) into `journal-profiles.md` and fill in the 7 schema sections (focus, bar, domain adjustments, methods adjustments, typical concerns, referee-pool weights, optional table format).

### Referees return near-identical reports

They weren't dispositioned. The editor agent should select **two different** dispositions from the 6-way taxonomy (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC). If reports are clones, the editor collapsed selection — usually because the paper is narrow enough that only one taxonomy applies. Try `--peer <journal> --stress` to force adversarial disposition pairing.

### R&R follow-up loses prior round context

Use `--r2` / `--r3` to continue a prior review. The editor agent reloads the previous `quality_reports/peer_review_*/decision.md` and classifies each revision (addressed / partially / deferred / disagreement). If the prior decision file is missing or renamed, the chain breaks — start fresh with `--peer`.

## Surface-sync gate (v1.6.0)

### `/commit` fails at Step 0b with "count drift detected"

`scripts/check-surface-sync.sh` detected a count mismatch (skills / agents / rules / hooks) across docs. The script reports which surface has the stale number. Fix every surface the script flags, then re-run. **Do not bypass** — the gate exists because manual `replace_all` has missed sibling phrasings three times (PRs #70/#76/#78 in v1.5.x).

### Adding a new skill / agent / rule breaks the gate

Expected. The gate counts `.claude/skills/` on disk vs prose assertions. After adding a skill, update the counts in README.md, CLAUDE.md (if mentioned), `guide/workflow-guide.qmd`, `docs/index.html` og:description, and `templates/skill-template.md`. The script tells you which are stale.

## Pre-Flight Reports (v1.6.0)

### Skill halts at "Pre-Flight Report failed — inputs not readable"

The skill couldn't read one of its required inputs (dataset, journal profile, notation registry, `r-code-conventions.md`, etc.). Check the file path in the error, confirm permissions, and confirm that fresh forks have the expected file (e.g., `/create-lecture` has a fresh-fork fallback for the notation registry; other skills do not). Do NOT edit the skill to skip Pre-Flight — the point is to catch hallucinated variable names and missing conventions before real work starts.

### Pre-Flight passes but the agent hallucinates anyway

Open an issue with the Pre-Flight Report attached. Either the input schema was incomplete, or the agent ignored the report. Both are bugs worth filing.

## Decision records (v1.6.0)

### Where do I save an ADR?

`quality_reports/decisions/YYYY-MM-DD_short-description.md` using [`templates/decision-record.md`](templates/decision-record.md). The directory is gitignored like `plans/` and `specs/` — commit only if you want the record visible to others. (Most forkers keep decisions local.)

## Post-Flight Verification / Chain-of-Verification (v1.7.0)

### `/verify-claims` times out or errors

The forked `claim-verifier` agent is conservative by design: it won't mark a claim as verified unless it has evidence. If it times out or errors mid-run, the skill surfaces a warning block instead of silently shipping the draft (fail-closed, like Pre-Flight). The draft is returned as **provisional** — treat it as unverified. Next steps:

- **Retry** with a narrower source scope. `/verify-claims --source <specific-paper.pdf>` is faster and more reliable than letting the agent guess.
- **Switch from WebSearch to direct fetch.** If the agent is timing out on web searches, download the PDF to `master_supporting_docs/` and pass it as `--source`.
- **Downgrade to warning-only** with `--no-fail-closed` if you are actively reading the source yourself and just want a report.

### Verifier says "cannot-verify" on a claim you believe is correct

This is the verifier being honest, not stubborn. It means:

- The source material is inaccessible (paywalled, broken URL, restricted dataset codebook not public).
- The claim is worded in a way that doesn't map to a specific verifiable question (e.g., "this is a promising direction" is an opinion, not a factual claim).
- The evidence exists but in a venue the agent can't reach (conference proceedings behind a login wall, working paper not on arXiv).

Resolution: supply a canonical source (DOI / arXiv / repo path), or accept the `cannot-verify` flag in the final output and manually confirm yourself.

### Integration skill (e.g., `/lit-review`) hangs at Post-Flight step

If the invoking skill doesn't return after launching `claim-verifier`, check:

1. `Task` tool is available to the invoking skill (check its `allowed-tools` in `SKILL.md`).
2. The agent's `allowed-tools` include what it needs (`WebFetch`, `WebSearch`, `Read`).
3. Network access: WebSearch + WebFetch require internet; on an offline fork they must be disabled or the verifier gated behind a check.

If blocked, bypass with `--no-verify` for the current run. File an issue if the hang persists.

### Opting out of Post-Flight

Every affected skill accepts `--no-verify` to skip the Post-Flight step. Use when:

- You are iterating rapidly and verifying yourself.
- You have already fact-checked the sources manually.
- CoVe's extra ~2× token cost is blocking a tight budget.

Do **not** opt out when:

- Producing a deliverable for external readers (literature review for a committee, R&R response for an editor, grant-proposal lit survey).
- The draft contains >5 citations you haven't personally verified.
- `/lit-review` just returned results — the most common hallucination vector in the whole template.

## `check-skill-integrity` failures

The surface-sync gate now chains `check-skill-integrity.py` after the count-sync check. It runs four mechanical parity checks (frontmatter↔body tools, argument-hint↔body flags, internal anchor resolution, rule↔skill keyword parity) and reports P0/P1/P2 findings per file.

### P0: body invokes tool X but frontmatter allowed-tools is [...]

The skill's Steps/Workflow section says to use a tool (typically `Task` to spawn an agent, or `Edit`/`Write`/`MultiEdit`/`NotebookEdit`) but the frontmatter `allowed-tools` array doesn't list it. Runtime behavior: the skill will hit a tool-permission error or silently skip the step. Fix: add the missing tool to `allowed-tools`.

### P1: anchor `#foo` not found in path/to/file.md

An internal markdown link `[text](path#anchor)` targets a heading that doesn't exist. Either the heading was renamed, the anchor slug was hand-typed and doesn't match the GitHub-flavored-markdown transform of the heading, or the link target file is wrong. Fix: either update the anchor to match an existing heading, or add the missing heading.

### P2: body documents `--foo` as option flag but argument-hint is '...'

A flag is described in the skill's body (in a table, a list, or with opt-out language) but doesn't appear in the one-line `argument-hint`. Users won't discover the flag from the hint. Fix: append the flag to `argument-hint` (or remove it from the body if it's not a real option).

### P0: rule foo.md lists this skill in paths: but the skill body contains none of [...]

A rule's `paths:` claims the skill follows the rule's protocol, but the skill body doesn't mention the protocol's keywords. Either add the protocol to the skill (preferred) or remove the skill from the rule's `paths:`. The keyword map lives in `scripts/check-skill-integrity.py` under `RULE_KEYWORDS` — new rules need an entry there.

### False positives and regex tuning

If a finding looks wrong (e.g., a shell command flag being treated as a skill flag, or an example link being treated as a real link), the regex in `scripts/check-skill-integrity.py` needs tuning. Shared helper: `strip_code()` blanks out inline code spans and fenced code blocks. For new classes of false positive, add an exclusion to the relevant check and document it inline.

## Scheduling autonomous work

### `CronCreate` dies when my session closes

By design. `CronCreate` schedules in the Claude Code REPL's own event loop — when the REPL exits (you close the window, Claude Code crashes, your usage hits a rate limit and the session terminates), the cron goes with it. Even `durable: true` doesn't save you if no REPL is running at fire time.

For **short-delay polling within an active session** (e.g. "check the build every 5 minutes while I work"), `CronCreate` is fine. For anything that must **survive session termination**, use **Claude Code Routines** (Apr 2026) instead. Routines run on Anthropic's web infrastructure — your Mac does not need to be online for each fire. Use Routines for: scheduled audits, overnight batch work, autonomous execution while you're away. See `.claude/references/audit-pet-peeves.md` entry 17 for the full comparison.

### PreCompact keeps blocking even after I approved the plan

You probably have `CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT=1` set in your environment. The hook blocks compaction at most **once** per DRAFT plan — subsequent compactions of the same plan proceed normally. If it's blocking repeatedly, either the plan's status line hasn't been updated from DRAFT to APPROVED/IN_PROGRESS (check the plan file header), or you've got a different DRAFT plan every time (the hook tracks by plan path). Unset the env var to disable the guard entirely: `unset CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT`.

## Still stuck?

- Read the [guide's troubleshooting section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#troubleshooting) for longer-form recovery scenarios.
- Open an issue at <https://github.com/pedrohcgs/claude-code-my-workflow/issues> — the bug-report template asks for the environment details we need to help.
