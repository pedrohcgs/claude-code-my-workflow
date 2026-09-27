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

Verify with `claude mcp list` — `stata-mcp` should appear with status `connected`. The skill also halts if Stata itself is not on `PATH`; the install instructions documented in [`/stata-replication`](.claude/skills/stata-replication/SKILL.md) Phase 0 cover both pre-flight checks.

### Claude keeps asking permission for every tool

In Manual mode Claude asks before most edits and shell commands the allow list doesn't cover. Options, from most oversight to least (see the guide's [permission modes section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#settings---permissions-and-hooks)):

- **Auto mode** — the built-in starting mode on Claude Code ≥ 2.1.283 (and on Pro/Max/Team since 2026-08-14 on earlier versions): a classifier approves routine actions and blocks or asks about risky ones.
- **Accept edits** — `Shift+Tab`, or `claude --permission-mode acceptEdits`: auto-approves file edits and common filesystem commands in the working directory.
- **Bypass** — `claude --permission-mode bypassPermissions` skips permission prompts and safety checks (deny rules still apply). Anthropic scopes it to isolated containers and VMs, and it takes effect from the CLI flag, `--settings`, or user/managed settings — a `bypassPermissions` in a project's `.claude/settings.json` is not honoured and the session starts in Manual mode. (In VS Code, bypass is a user-settings choice: set `claudeCode.initialPermissionMode` to `bypassPermissions` and turn on `claudeCode.allowDangerouslySkipPermissions` in your VS Code *user* settings. Both are machine-scoped, so the extension ignores workspace values and the template's `.vscode/settings.json` does not change the starting mode.)

The template's `.claude/settings.json` ships broad allow rules (`Edit(**)`, `Write(**)`, `Bash(*)`, …) and no default mode, so in Manual mode most routine work runs unprompted. Auto mode drops the blanket `Bash(*)` rule and sends shell commands through its classifier instead. To keep restricted data off the model in every mode, add deny rules — see ["Keep restricted data off the model"](#keep-restricted-data-off-the-model) below.

## Models and API

### `/model` doesn't offer the current Opus, or a pinned model ID fails

The current lineup, minimum Claude Code versions, and retirement floors live in [`model-versions.md`](.claude/references/model-versions.md). Two failure shapes are common after a model launch:

- **The new model is missing from `/model`.** Each model needs a minimum Claude Code version (the current Opus needs ≥ 2.1.280). Run `claude --version`; update with `claude update` or your installer (`npm install -g @anthropic-ai/claude-code@latest` for an npm install). The VS Code extension bundles its own CLI, so the terminal `claude` on your `PATH` can lag behind it.
- **A pinned model ID fails.** Sonnet 4 and the original Opus 4 retired on 2026-06-15, and the current Haiku model's retirement floor is 2026-10-15. Find pins before they break:
  - **Environment:** `echo $ANTHROPIC_MODEL $ANTHROPIC_DEFAULT_FABLE_MODEL $ANTHROPIC_DEFAULT_OPUS_MODEL $ANTHROPIC_DEFAULT_SONNET_MODEL $ANTHROPIC_DEFAULT_HAIKU_MODEL $CLAUDE_CODE_SUBAGENT_MODEL`.
  - **Settings:** a `model` key in `.claude/settings.json`, `.claude/settings.local.json`, or `~/.claude/settings.json`.
  - **Agents and skills:** `grep -rn "^model:" .claude/agents/ .claude/skills/` — the template pins tier aliases (`opus` / `sonnet` / `haiku`), which follow the current model automatically; a full model ID does not.
  - **CI:** any workflow that calls `claude -p --model <id>`.

Prefer tier aliases over full IDs unless you need a frozen snapshot for a reproducibility claim — and if you do, record the ID and date alongside the result.

### An update broke something mid-deadline

Claude Code updates itself from the `latest` channel by default. For deadline weeks, follow the slower channel in `~/.claude/settings.json`:

```json
{ "autoUpdatesChannel": "stable" }
```

`minimumVersion` keeps auto-updates from installing anything below a version you know works. Prefer these to switching the updater off — updates carry security fixes and new-model support (a new model can require a minimum version).

### Headless `claude -p` runs bill from a separate pool on subscription plans

Since **2026-06-15**, headless subprocess calls (`claude -p`, the Agent SDK) on subscription plans draw from a **separate Agent SDK credit pool**, decoupled from interactive credits. In this template that affects `scripts/run-skill-eval.sh` and any scheduled or scripted `claude -p` you add (e.g. a `/triage-inbox` routine). If a headless run fails with a credit-exhaustion error while your interactive session works, check the Agent SDK balance separately. See [Anthropic's release notes](https://platform.claude.com/docs/en/release-notes/overview) for the current allocation per plan tier.

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

### Slide QA "could not run" (exit 2)

`scripts/slide-qa.py` measures a rendered Quarto deck in headless Chrome, and exit 2 means it measured nothing — the skills then fall back to reading the source. The message names the cause:

- **Playwright missing.** A Homebrew or system Python refuses a plain `pip install`, so install it once in a virtual environment and point the skills at it: `python3 -m venv ~/.venvs/slide-qa && ~/.venvs/slide-qa/bin/pip install playwright`, then `export SLIDE_QA_PYTHON=~/.venvs/slide-qa/bin/python` (add the export to your shell profile). `./scripts/validate-setup.sh` checks it.
- **No browser.** It uses your installed Google Chrome; without one, run `$SLIDE_QA_PYTHON -m playwright install chromium`.
- **Stale render.** The `.qmd` is newer than its `.html` — re-render first, or the numbers describe the old deck.
- **"Math was not typeset"** in a report (not an exit 2): MathJax or KaTeX never loaded, usually offline, so formulas were measured as raw TeX.

## Git / hooks / CI

### On Windows, the guards do not see PowerShell commands

Claude Code on Windows can run shell commands through two tools, Bash (Git Bash) and PowerShell. The template's guard hooks — `git-guardrails`, `root-of-trust-guard`, `issue-guard` — are wired to the **Bash** tool only, so a command Claude runs through PowerShell passes none of them.

- **Install [Git for Windows](https://git-scm.com/downloads/win).** Without Git Bash, Claude Code uses PowerShell for every shell command, and none of the guards run at all.
- **With Git Bash installed, the PowerShell tool is still on by default** for claude.ai and Console accounts. To keep every shell command on the guarded route, turn it off for your machine with `"env": { "CLAUDE_CODE_USE_POWERSHELL_TOOL": "0" }` in `.claude/settings.local.json`, or add `"PowerShell"` to your `permissions.deny`.
- Widening the guards' matchers to `Bash|PowerShell` would not be enough: they read bash syntax, and PowerShell spells the same operations differently (`Remove-Item -Recurse`, not `rm -rf`).

(Claude Code tools reference, "PowerShell tool", read 2026-09-27.)

### Hook script permission denied

`chmod +x .claude/hooks/*.sh`. The Python hooks are run as `python3 <file>`, so they need no executable bit; `./scripts/validate-setup.sh` reports only the shell hooks that lack it.

### Pre-compact hook didn't save the plan

The PreCompact hook (`.claude/hooks/pre-compact.py`) writes state to `~/.claude/sessions/<hash>/`. If the state isn't there after compaction:

- Check the hook's exit code: `echo '{}' | python3 .claude/hooks/pre-compact.py` should exit 0.
- Check permissions on `~/.claude/sessions/`.
- Check the session hash matches — compaction logs the hash.

### A handoff appears when a session starts

`session-handoff.py` hands a fresh session the newest `/checkpoint` or `/compress-session` file written in the last 7 days, labelled as notes to verify. It counts as used once you type a prompt in that session, so it appears once. To skip it, set `CLAUDE_HANDOFF=off` (shell, or under `env` in settings); to change the window, `CLAUDE_HANDOFF_MAX_AGE_DAYS`. Headless `claude -p` runs never receive it. If another memory tool also injects context at startup, turn one of them off.

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

Three causes, most common first:

1. **The setting sits in project settings.** A `defaultMode: "bypassPermissions"` in `.claude/settings.json` or `.claude/settings.local.json` is not honoured and the session starts in Manual mode (an `"auto"` there falls back to the built-in default instead). Remove it from the project files, then set bypass in `~/.claude/settings.json`, pass `--permission-mode bypassPermissions`, or (VS Code) set `claudeCode.initialPermissionMode` in your VS Code **user** settings with the extension's *Allow dangerously skip permissions* toggle (`claudeCode.allowDangerouslySkipPermissions`) on — both are machine-scoped, so values in the workspace `.vscode/settings.json` are ignored. The VS Code extension does not read project settings for the starting mode at all.
2. **A mid-session toggle.** `Shift+Tab` (CLI) or the mode indicator (VS Code) overrides file settings until the session ends.
3. **A stale session.** Settings changed after the session started; start a new one.

Run `/permission-check` — it lists every layer's value and which one wins.

### Keep restricted data off the model

Every file Claude reads is sent to the model provider. [`confidential-data.md`](.claude/rules/confidential-data.md) says restricted microdata never leaves the machine, and **deny rules hold in every permission mode, including bypass**. If your project has restricted directories, add deny rules — in `.claude/settings.json` to protect every collaborator, or `.claude/settings.local.json` for your machine only — naming the paths your data-use agreement covers:

```json
{
  "permissions": {
    "deny": [
      "Read(**/restricted/**)",
      "Read(**/confidential/**)",
      "Edit(**/restricted/**)",
      "Edit(**/confidential/**)"
    ]
  }
}
```

`**/` matches at any depth, but only under the project: a relative pattern cannot reach data kept elsewhere. For data outside the checkout, anchor the pattern with `//` (absolute) or `~/` (home) — `Read(//Volumes/secure-dua/**)`, `Read(~/Dropbox/ProjectX-DUA/**)` — and put such machine-specific lines in `.claude/settings.local.json` or `~/.claude/settings.json`, never the committed `settings.json`. A single leading `/` is not absolute: in `.claude/settings.json` or `.claude/settings.local.json` it anchors at the session's working directory (the project root when you start there), and in `~/.claude/settings.json` at `~/.claude/` — so use `//` for a truly absolute path. Start from the patterns `confidential-data.md` loads on (`data/**`, `**/raw/**`, `**/*.dta`, `**/*.sav`, `**/restricted/**`, `**/confidential/**`) and keep the ones your data-use agreement covers — denying all of `data/**` also blocks public data you may want Claude to read. Read/Edit deny rules cover Claude's file tools, the file commands Claude Code recognizes in Bash (`cat`, `head`, `tail`, `sed`, `tee`) and redirect targets, but not a command that reads files without naming them (`grep -r pattern .`) or a script that opens files itself — so they are a guardrail, not a proof: pair them with the rule's discipline (Claude writes code that runs *on* the data; it does not read the data) and with `/disclosure-check` before anything built on the data leaves the machine.

### `/permission-check` asks before reading `~/.claude/`

That's intentional. Host-global config can contain unrelated paths and secrets. Phase A (repo-local) is automatic; Phase B (host-global, with key redaction) requires explicit confirmation. See [CHANGELOG v1.6.0 — privacy boundary](CHANGELOG.md) for context.

### Seeing too many permission prompts?

If `/permission-check` confirms your config is permissive but you're still being prompted, the built-in Claude Code skill **`/fewer-permission-prompts`** (Apr 2026) scans your transcripts for common read-only Bash and MCP tool calls and proposes a prioritized allowlist for `.claude/settings.json`. Pairs with our `/permission-check`: `permission-check` diagnoses; `fewer-permission-prompts` remediates.

### Statusline shows `?` or is blank

Session JSON parse failure. Check `.claude/scripts/statusline.sh` is executable (`chmod +x`) and that `python3` is on `PATH`. Fallback output is `? @ <branch>` (no mode badge, `?` for the model) — if you see that, the script could not parse the session JSON. Restart Claude Code.

### Status line shows `gate:off`

The repo ships a pre-commit gate (`.githooks/pre-commit`), but git is not pointed at it, so a plain `git commit` skips every check — only `/commit` runs them. Run `./scripts/install-hooks.sh` once per clone (it sets `core.hooksPath` to `.githooks`) and the badge disappears.

### Edits to `.claude/`, `.git/`, `.vscode/` prompt (or go to the classifier)

This is **not a bug.** Per Anthropic's [permission-modes docs](https://code.claude.com/docs/en/permission-modes) (re-verified 2026-09-26), writes to *protected paths* — `.git`, `.vscode`, `.idea`, `.husky`, `.devcontainer`, `.claude` (except `.claude/worktrees`), shell rc files, `.mcp.json`, `.claude.json`, and a few others — are never auto-approved by an allow rule. What happens depends on the mode: **prompted** in Manual and Accept-edits, **routed to the classifier** in auto mode, **denied** in dontAsk, and **allowed** only in bypass (and in terminal plan-mode sessions with bypass available). When a prompt fires for the project's `.claude/` folder, it offers a session-scoped "allow Claude to edit files in this project's .claude folder" option.

For batch edits under `.claude/rules/`, `.claude/references/`, `.claude/skills/`, or `.claude/agents/`, a single scripted edit through the Bash tool avoids one prompt per file. The template's own `root-of-trust-guard.py` hook **denies** shell writes into `.claude/settings*.json`, `.claude/hooks/`, and `.githooks/` — use Edit/Write there, so every change to a gate leaves a reviewable diff.

### VS Code: bypass mode doesn't take effect from `.vscode/settings.json`

The Claude Code VS Code extension reads **`claudeCode.allowDangerouslySkipPermissions`**, with the `claudeCode.` prefix; a bare `allowDangerouslySkipPermissions` key is never read. The setting adds Bypass permissions to the mode selector, and while it is off the extension downgrades a `bypassPermissions` start to Manual mode, so writes to protected paths still prompt. Both it and `claudeCode.initialPermissionMode` are machine-scoped: VS Code reads them only from your **user** settings and ignores values in the workspace `.vscode/settings.json`. To start new conversations in bypass, open user settings (`Cmd+,` → Extensions → Claude Code), set `"claudeCode.allowDangerouslySkipPermissions": true` and `"claudeCode.initialPermissionMode": "bypassPermissions"`, then reload the window. Use bypass only in a sandbox with no internet access.

## Peer-review pipeline (v1.5.0)

### `/review-paper --peer AER` fails with "journal not found"

The target must be in [`.claude/references/journal-profiles.md`](.claude/references/journal-profiles.md). Ships with eight profiles: AER / QJE / JPE / ECMA / ReStud (economics) and APSR / AJPS / JOP (political science). To add your field's journal, copy [`templates/journal-profile-template.md`](templates/journal-profile-template.md) into `journal-profiles.md` and fill in the 7 schema sections (focus, bar, domain adjustments, methods adjustments, typical concerns, referee-pool weights, optional table format).

### Referees return near-identical reports

They weren't dispositioned. The editor agent should select **two different** dispositions from the 6-way taxonomy (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC). If reports are clones, the editor collapsed selection — usually because the paper is narrow enough that only one taxonomy applies. Try `--peer <journal> --stress` to force adversarial disposition pairing.

### R&R follow-up loses prior round context

Use `--peer <journal> --r2` / `--r3` to continue a prior review. The editor skips the fresh desk review, reloads the prior round's reports (`quality_reports/peer_review_<paper>/desk_review.md`, `referee_domain.md`, `referee_methods.md`), and reuses the same referee dispositions and peeves; each referee then classifies every prior major concern as Resolved / Partial / Not addressed. If those prior-round reports are missing or renamed, the chain breaks — start fresh with `--peer`.

## Surface-sync gate (v1.6.0)

### `/commit` fails at Step 0b with "DRIFT DETECTED"

Step 0b runs `./scripts/backtest.sh`. Its surface-sync gate (`scripts/check-surface-sync.py`) found that a count claimed in the docs, or the number of rows in a `<!-- surface-sync-table -->` table, does not match what is on disk (skills / agents / rules / hooks). It lists each stale surface as `file:line  asserts N <kind> (actual: M)`. Fix every surface it flags, then re-run `./scripts/backtest.sh` (or `python3 scripts/check-surface-sync.py` alone). If a different gate is red, read that gate's own output. **Do not bypass** — the gate exists because manual `replace_all` has missed sibling phrasings three times (PRs #70/#76/#78 in v1.5.x).

### Adding a new skill / agent / rule breaks the gate

Expected. The gate counts `.claude/skills/` on disk vs prose assertions, and requires each `<!-- surface-sync-table: ... -->` table in README.md to have exactly one row per item on disk. After adding a skill, add its row to the README.md skills table (for an agent, the agents table), then update the counts in README.md, CLAUDE.md (if mentioned), `guide/workflow-guide.qmd` and both rendered copies (`guide/workflow-guide.html`, `docs/workflow-guide.html`), `docs/index.html` (og:description and the "What you get" section), `templates/skill-template.md`, and `.claude/skills/commit/SKILL.md`. The script tells you which are stale; re-run it until it exits 0.

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

1. The `Agent` tool (legacy alias `Task`) is available to the invoking skill (check its `allowed-tools` in `SKILL.md`).
2. The agent's `tools:` frontmatter in `.claude/agents/<name>.md` includes what it needs (`WebFetch`, `WebSearch`, `Read`).
3. Network access: WebSearch + WebFetch require internet; on an offline fork they must be disabled or the verifier gated behind a check.

If blocked, bypass with `--no-verify` for the current run. File an issue if the hang persists.

### Opting out of Post-Flight

Every affected skill except `/review-paper` accepts `--no-verify` to skip the Post-Flight step. `/review-paper` has no `--no-verify`: pass `--no-novelty-check` to turn off the `--peer` novelty probe, which also removes its Post-Flight step (whenever the probe runs, Post-Flight is mandatory). Use when:

- You are iterating rapidly and verifying yourself.
- You have already fact-checked the sources manually.
- CoVe's extra ~2× token cost is blocking a tight budget.

Do **not** opt out when:

- Producing a deliverable for external readers (literature review for a committee, R&R response for an editor, grant-proposal lit survey).
- The draft contains >5 citations you haven't personally verified.
- `/lit-review` just returned results — the most common hallucination vector in the whole template.

## `check-skill-integrity` failures

The surface-sync gate now chains `check-skill-integrity.py` after the count-sync check. It runs five mechanical checks (frontmatter↔body tools, argument-hint↔body flags, internal anchor resolution, rule↔skill keyword parity, and completeness of the `RULE_KEYWORDS` registry — every rule scoped to `.claude/skills/` must be registered) and reports P0/P1/P2 findings per file.

### P0: body invokes tool X but frontmatter allowed-tools is [...]

The skill's Steps/Workflow section says to use a tool (typically `Agent`, or its legacy alias `Task`, to spawn an agent, or `Edit`/`Write`/`MultiEdit`/`NotebookEdit`) but the frontmatter `allowed-tools` array doesn't list it. Runtime behavior: the skill will hit a tool-permission error or silently skip the step. Fix: add the missing tool to `allowed-tools`.

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
