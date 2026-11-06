---
name: new-skill
description: Scaffold a new skill that follows this repo's conventions — interviews for purpose, trigger phrases, and tool needs, then writes `.claude/skills/<name>/SKILL.md` from the skill template with frontmatter and body that pass the integrity gates on first try. Use when user says "write a skill", "scaffold a skill", "create a new skill", "I keep doing X, make it a skill", "new slash command", or "turn this workflow into a skill". NOT for capturing a one-off session discovery — that is `/learn`.
argument-hint: "[skill-name (kebab-case)] [--from-learn] [--dry-run]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash"]
disable-model-invocation: true
effort: medium
---

# /new-skill — Author a Convention-Compliant Skill

Scaffold a new skill the way this template's gold-standard skills are written: a **deep module behind a simple interface** (Ousterhout, *A Philosophy of Software Design* — "deep modules": a small surface that hides substantial implementation). The user supplies a fuzzy intent; this skill interviews it into a tight spec, then writes `.claude/skills/<name>/SKILL.md` with frontmatter and body that are mutually consistent — so `check-skill-integrity.py` and `check-surface-sync.sh` pass without a second pass.

Adapted from the *write-a-skill* pattern in [mattpocock/skills](https://github.com/mattpocock/skills), reshaped to this repo's frontmatter, section, and gate conventions.

## When to use

- You keep re-explaining the same 3+ step workflow to Claude and want it captured as a reusable slash command.
- You need a domain-specific check or output format (citation style, replication gate, a new review lens).
- You want a new skill that is consistent with the 40+ siblings in `.claude/skills/` — same sections, same cross-reference style, same gate-passing frontmatter.

**Use `/learn` instead** when you just discovered something non-obvious *this session* and want it preserved — `/learn` captures a discovery; `/new-skill` deliberately designs an interface. With `--from-learn`, this skill upgrades a `/learn`-shaped stub into a full convention-compliant skill.

## Phases

### Phase 0 — Resolve the name and check for collisions

1. Take the kebab-case name from `$0` (or ask). Reject non-kebab-case, names that collide with an existing `.claude/skills/<name>/`, or names that shadow a built-in (`commit`, `learn`, …) — `ls .claude/skills/` and stop if taken.
2. Read [`templates/skill-template.md`](../../../templates/skill-template.md) for the canonical structure and the frontmatter-field reference.
3. Skim 2-3 sibling skills near the intended domain (e.g. `Glob .claude/skills/*/SKILL.md`, then `Read` the closest matches) so the new skill borrows real conventions, not invented ones.

### Phase 1 — Interview (collect everything *before* writing)

A skill cannot stop to ask mid-write, so gather all interactivity up front (the [orchestrator-protocol.md](../../rules/orchestrator-protocol.md) RUN_CONFIG discipline). Ask, in one batch:

1. **Purpose** — one sentence: what does it accomplish and why does it exist?
2. **When it should fire** — the 2-4 *situations* a user is in when they need it (e.g. "preparing a submission", "a number changed between runs"), plus one or two example phrasings. These become the `description`'s "Use when…" clause. Name intent categories rather than enumerating near-synonyms: every model-invocable description is loaded into every session, and `description` + `when_to_use` are truncated in the skill listing (at 1,536 characters per the Claude Code skills docs, 2026-09) — put the key use first.
3. **Inputs / arguments** — positional args and any **flags** (each must become a documented `--token`).
4. **Tools** — does the body Read? Write? Grep/Glob? run `Bash`? fan out to a subagent (Agent)? hit the web via `WebSearch`/`WebFetch`? Only declare what it actually uses.
5. **Output** — a written file (where?), a chat report, or an in-place edit? Should it be read-only?
6. **Scope boundary** — the one or two things it explicitly does NOT do (and which sibling owns those).
7. **Side effects** — which steps send, post or upload anything (email, GitHub, an external model, cloud sync) or cannot be undone by git? Each such step shows the user what it will do and waits for a yes before it runs; restricted data follows [`confidential-data.md`](../../rules/confidential-data.md).
8. **Fresh eyes** — does the skill critique something this session produced? That part runs in a fresh-context subagent, never a conversation fork ([`post-flight-verification.md`](../../rules/post-flight-verification.md)).

Echo a one-paragraph **design brief** back for confirmation before writing.

### Phase 2 — Write the SKILL.md (deep module, simple interface)

Write `.claude/skills/<name>/SKILL.md` from the template, with these gold-standard sections:

- Frontmatter: `name`, `description` (third person — what it does, then when to use it by intent category), `argument-hint`, `allowed-tools`, and `effort` only if the skill genuinely needs a level other than the session's (see `model-routing.md` § effort — a skill pin *overrides* the session, downward as well as up). Add `disable-model-invocation: true` if it writes a persistent, load-bearing file (template's "when to disable" rule) — and note that other skills then cannot invoke it; they must Read its `SKILL.md` and follow it.
- Body sections: **When to use**; the **goal and deliverable**; the **constraints, each with its reason**; **how to verify it is done**; an **Output / report format**; **Exit behavior**; **Cross-references** (to real sibling files); **What this skill does NOT do**; and a **## Flags** section if any flags are advertised. Number phases only where order genuinely matters (interview before writing, verify before reporting) — current models plan well, and a step-by-step script for a judgment task makes the output worse, not safer.
- Keep `SKILL.md` readable in one sitting (well under ~500 lines). Move long rubrics, worked examples, and reference tables into files beside it (e.g. `references/`) and link them, so they load only when needed.
- Keep the *interface* small (a few args) and the *implementation* deep (the phases carry the weight) — resist exposing a knob for every internal choice.

### Phase 3 — Enforce parity so the gates pass first try

`check-skill-integrity.py` enforces two parities this phase must satisfy (`scripts/check-skill-integrity.py` is the checker; `./scripts/backtest.sh` runs every gate):

- **Flag parity (both directions).** Every flag in `argument-hint` MUST appear in the body as a bare-backticked token, and every flag documented in the body MUST appear in `argument-hint`. So `--from-learn` and `--dry-run` are listed in the hint *and* described under `## Flags`. A stale hint flag fails the gate as surely as a missing one.
- **allowed-tools parity.** The body may only invoke tools listed in `allowed-tools`. If a phase fans out to a subagent, `Agent` must be in the list; if it never does, do not list it. This skill lists exactly `Read, Write, Glob, Grep, Bash` — the tools its phases use; it does no subagent fan-out.
- **Anchor resolution.** Internal `[text](path#anchor)` links must resolve — only link to headings that exist.

Run `python3 scripts/check-skill-integrity.py --verbose` and fix any P0/P1 before declaring done.

### Phase 4 — Remind: register the surface (table-row and count gates)

The skill is NOT discoverable to a reader until it is listed, and the inventory counts must match what is on disk. `check-surface-sync.sh` runs two surface checks. The **table-row gate** requires the `<!-- surface-sync-table: skills -->` table in `README.md` to have exactly one data row per skill on disk. The **count assertions** require every inventory phrasing that states a skill count (e.g. "N agents, M skills, …") in `README.md`, `CLAUDE.md`, `guide/workflow-guide.qmd`, both rendered guide copies (`guide/workflow-guide.html`, `docs/workflow-guide.html`), `docs/index.html`, `templates/skill-template.md` and `.claude/skills/commit/SKILL.md` to equal the number of skill directories. A new skill fails the gate if it has no row or if the counts are not bumped.

REMIND the user to:

1. Add a row to the **README.md** skills table: `` | `/<name>` | <what it does> | `` (the gated table).
2. Add a row to the guide's `## All Skills` appendix table in `guide/workflow-guide.qmd`. That table has no surface-sync marker, so no gate catches a missing row.
3. Bump every skill count. Run `python3 scripts/check-surface-sync.py`: each `asserts N skills (actual: M)` line names a file:line to update. For the guide, edit `guide/workflow-guide.qmd`, then `quarto render guide/workflow-guide.qmd`, `cp guide/workflow-guide.html docs/workflow-guide.html` and `./scripts/stamp-render.sh`, so both HTML copies carry the new count and the staleness gate stays green.
4. Optionally add the skill to CLAUDE.md's "Skills Quick Reference" bullet list — only if it belongs among the most-used skills; no gate checks that list.
5. Decide whether Codex and Antigravity should get it. If one agent can run it end to end (no fan-out to independent reviewers, nothing specific to Claude Code's own sessions), add its name to `INCLUDE` in `scripts/sync-agent-skills.py` and run `python3 scripts/sync-agent-skills.py`; otherwise add it to `EXCLUDE` with the reason. Left in neither list, it stays Claude-only and `check-skill-integrity.py` prints a P2 reminder.
6. Run `./scripts/check-surface-sync.sh` and `python3 scripts/check-skill-integrity.py` — both must exit 0.
6. Check what the skill costs and whether it fires: `/skill-doctor` shows its context cost and usage; `./scripts/run-skill-eval.sh` runs its eval cases once they exist.

Print the ready-to-paste README row so the user can drop it in.

## Output / report format

- A new file at `.claude/skills/<name>/SKILL.md`.
- A chat summary: the resolved name, the design brief, the gate results (integrity + a reminder that surface-sync still needs the README skills-table row and the count bumps), and the paste-ready README row.
- With `--dry-run`: emit the proposed SKILL.md to chat only and write nothing.

## Exit behavior

- **Skill written, gates green:** exit 0 with the path, the README row, and the explicit "now add that row, bump the counts, and run the two checks" reminder.
- **Name collision or non-kebab-case:** stop in Phase 0 with the conflict named; write nothing.
- **`check-skill-integrity.py` reports P0/P1:** fix in-place and re-run before returning; never hand back a skill that fails its own gate.
- **`--dry-run`:** print the draft, write nothing, exit 0.

## Flags

- `--from-learn` — Seed the interview from an existing `/learn`-style stub (or the current session's discovery) and upgrade it into a full convention-compliant skill rather than starting blank.
- `--dry-run` — Produce the SKILL.md content in chat for review without writing it to disk or touching any surface table.

## Cross-references

- [`templates/skill-template.md`](../../../templates/skill-template.md) — the canonical structure, frontmatter-field reference, and the "when to set `disable-model-invocation`" rule this skill follows.
- [`.claude/skills/learn/SKILL.md`](../learn/SKILL.md) — capture a session discovery (the lighter sibling); `--from-learn` upgrades its output.
- [`.claude/skills/coauthor-brief/SKILL.md`](../coauthor-brief/SKILL.md) — a gold-standard skill to imitate (interview → write → flags → exit-behavior shape).
- [`.claude/rules/orchestrator-protocol.md`](../../rules/orchestrator-protocol.md) — why the interview collects all interactivity *before* writing.
- `scripts/check-skill-integrity.py` and `scripts/check-surface-sync.sh` (both run by `scripts/backtest.sh`) — the gates this skill is built to pass on the first try.

## What this skill does NOT do

- **Capture a session discovery** — that is [`/learn`](../learn/SKILL.md). This skill designs an interface; `/learn` records a finding.
- **Edit the README skills table (or CLAUDE.md's quick-reference list) for you.** It *prints* the README row and reminds you; registering it (and re-running `./scripts/check-surface-sync.sh`) is a deliberate human step so the surface gate is never silently satisfied.
- **Write agents, rules, or hooks.** It scaffolds a skill only; an agent goes in `.claude/agents/`, a rule in `.claude/rules/`.
- **Commit anything.** Branch, commit and PR are [`/commit`](../commit/SKILL.md)'s job; a merge is the user's call.
