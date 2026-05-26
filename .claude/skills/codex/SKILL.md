---
name: codex
description: Drive the OpenAI Codex CLI (`codex exec`, `codex exec resume`) for code analysis, refactoring, automated editing, or a plan-refinement debate where Claude and Codex iterate a plan automatically for up to 5 rounds (or `--interactive` to decide each round), escalating to the user if they do not converge. Critically evaluates Codex output as a peer rather than an authority. Use when the user says "run codex", "use codex to ...", "ask codex", "codex resume", "debate this plan with Codex", or otherwise references OpenAI Codex. Picks the model (or the CLI default), reasoning effort, and sandbox mode; pins resumes to an explicit session id; gates high-impact flags behind explicit permission.
author: Claude Code Academic Workflow
version: 1.7.3
argument-hint: "[task, 'resume', or 'debate <plan> [--interactive]' to refine a plan with Codex]"
allowed-tools: ["Bash", "Read", "Write", "WebSearch", "WebFetch"]
---

# `/codex`: drive the Codex CLI, then evaluate its output critically

Run a task through the OpenAI Codex CLI, capture the result, and report it back
with your own critical read. Treat Codex as a colleague with a different
knowledge cutoff, not as an authority.

## When to use

- The user wants a second model to analyze, refactor, or edit code.
- The user explicitly asks to run, resume, or continue a Codex session.
- A task benefits from a parallel opinion you can then cross-check.
- The user wants to refine a plan or design by debating it with Codex (see the
  **Plan-refinement debate** section below).

## When NOT to use

- The task is squarely within your own competence and the user has not asked
  for Codex. Just do it directly.
- The user wants a literature search or fact-check. Use [`/lit-review`](../lit-review/SKILL.md)
  or [`/verify-claims`](../verify-claims/SKILL.md).

## Pre-flight

1. Confirm the CLI is present: `codex --version`. If it exits non-zero, stop and
   report that Codex is not installed or not on `PATH`; ask how to proceed.

## Running a task

### Step 1: Choose model and reasoning effort

**Default to the CLI's own configured model: omit `-m` entirely.** Codex's model
lineup changes often, so do not hard-code or assume specific model names. Pass
`-m <MODEL>` only when the user names a specific model they want to use.

Use `AskUserQuestion` with a **single prompt containing two questions**:

- **Model:** offer "Default (use whatever `codex` is configured for)" as the
  recommended option. The user can name a specific model via "Other" if they
  want one. Do not present a fixed menu of model names: it goes stale as the
  lineup changes, and a wrong name makes the command fail.
- **Reasoning effort:** `xhigh`, `high`, `medium`, or `low` (stable config
  values), passed via `--config model_reasoning_effort="..."`.

### Step 2: Choose the sandbox mode

Pick the least-privileged mode the task needs. Default to `read-only`.

- `read-only`: review or analysis with no writes.
- `workspace-write`: apply local edits inside the working directory.
- `danger-full-access`: permit network or broad filesystem access.

Before using a genuinely high-impact flag, `--sandbox danger-full-access` or
`--dangerously-bypass-approvals-and-sandbox` (no sandbox and no approvals), ask
the user for permission with `AskUserQuestion` unless they have already granted
it this session. (`--skip-git-repo-check` is benign and always passed: see
Step 3.)

### Step 3: Assemble the command

Available options:

| Option | Purpose |
| --- | --- |
| `-m, --model <MODEL>` | Select the model |
| `--config model_reasoning_effort="<xhigh\|high\|medium\|low>"` | Set reasoning effort |
| `--sandbox <read-only\|workspace-write\|danger-full-access>` | Select sandbox mode |
| `-C, --cd <DIR>` | Run from another directory |
| `--skip-git-repo-check` | Do not require a git repo |
| `--dangerously-bypass-approvals-and-sandbox` | No sandbox and no approvals; externally-sandboxed environments only |
| `"your prompt here"` | The task, as the final positional argument |

Always pass `--skip-git-repo-check`.

### Step 4: Deliver the prompt safely on stdin, suppress thinking tokens

By default append `2>/dev/null` to every `codex exec` command to suppress
thinking tokens on stderr. Show stderr only if the user asks to see thinking
tokens or you are debugging a failure.

**Pass the prompt on stdin via a *quoted* here-doc, not as a double-quoted
argument.** A double-quoted positional prompt is processed by the shell first,
so any `$(...)`, backtick, `$VAR`, or embedded quote in the prompt (common in
plans and code) is expanded, executed, or mangled before Codex sees it. A
here-doc whose delimiter is quoted (`<<'CODEX_PROMPT'`) passes the body
verbatim, and it closes stdin so Codex never blocks. (`codex exec` always reads
stdin; if stdin is left open it blocks forever.)

```bash
codex exec --skip-git-repo-check [-m <MODEL>] \
  --config model_reasoning_effort="<EFFORT>" --sandbox <MODE> [-C <DIR>] \
  2>/dev/null <<'CODEX_PROMPT'
Your prompt here, on its own lines.
It may safely contain $(...), backticks, "quotes", and $VARS.
CODEX_PROMPT
```

Symptom of leaving stdin open (no here-doc and no redirect): zero bytes of
stdout, no CPU accumulated, the process appears hung indefinitely. A short
prompt with no shell metacharacters may instead be passed as a positional
argument with `</dev/null` appended, but the here-doc is the safe default.

### Step 5: Run, capture the resume coordinates, summarize

Run the command and capture stdout as the answer. To make the session safely
resumable, send stderr to a temp file instead of `/dev/null`: Codex prints a
header there (`workdir:`, `model:`, `sandbox:`, `reasoning effort:`,
`session id:`), and the rest of that file (thinking tokens) stays out of view.
Resume inherits **none** of the runtime config (see Rules for resume), so you
must record all five fields, not just the id, to reconstruct an exact resume
later, even after a compaction or from a concurrent Claude session:

```bash
CODEX_ERR="$(mktemp)"
codex exec --skip-git-repo-check --sandbox read-only 2>"$CODEX_ERR" <<'CODEX_PROMPT'
...your prompt...
CODEX_PROMPT
SESSION_ID="$(grep -oiE 'session id: [0-9a-f-]{36}' "$CODEX_ERR" | awk '{print $3}')"
MODEL="$(grep -oiE '^model: [^ ]+'            "$CODEX_ERR" | awk '{print $2}')"
EFFORT="$(grep -oiE 'reasoning effort: [a-z]+' "$CODEX_ERR" | awk '{print $3}')"
SANDBOX="$(grep -oiE '^sandbox: [a-z-]+'       "$CODEX_ERR" | awk '{print $2}')"
WORKDIR="$(grep -oiE '^workdir: .+'            "$CODEX_ERR" | sed 's/^workdir: //I')"
```

Read `MODEL` from stderr even when you let the CLI pick the default: the header
reports the **resolved** name (for example `gpt-5.5`), which is what a resume must
replay, not the word "default". Capture `WORKDIR` for the same reason: resume does
not inherit the original `-C` directory, so without replaying it a
`workspace-write` follow-up can edit the wrong repo. Write all five (`SESSION_ID`,
`MODEL`, `EFFORT`, `SANDBOX`, `WORKDIR`) into the session log or the plan for this
task. Then summarize the outcome and tell the user: "You can resume this exact
Codex session by saying 'codex resume'; I have pinned its id (`<SESSION_ID>`) and
its model / effort / sandbox / working directory." Fall back to `2>/dev/null` only
for a throwaway call you are certain you will never resume.

## Resuming a session

**Resume by the explicit session id captured in Step 5, not by `--last`.**
`--last` resumes the most recent recorded session in the current directory
(newest wins). That is race-prone: if two Claude sessions share a repo and each
drives Codex, one session's `--last` can resume the *other's* Codex thread. The
session id has no such ambiguity. Pass the id (or a thread name) as the first
positional, `-` as the second so `resume` reads the prompt from stdin:

```bash
codex exec --skip-git-repo-check -C <WORKDIR> resume \
  -m <MODEL> --config model_reasoning_effort="<EFFORT>" -c 'sandbox_mode="<MODE>"' \
  <SESSION_ID> - 2>/dev/null <<'CODEX_PROMPT'
Your follow-up prompt here.
CODEX_PROMPT
```

The `-C <WORKDIR>` (before `resume`), and the `-m`, `--config`, and
`-c 'sandbox_mode=...'` (after it), are not optional polish: resume inherits
**none** of them from the original session (see Rules for resume). Replay the
same working directory, model, effort, and sandbox you started with, or the
follow-up silently runs in the wrong directory or on different settings.

Use `--last` only as a fallback, when there is exactly one active Codex
conversation or the user accepts the ambiguity:

```bash
codex exec --skip-git-repo-check -C <WORKDIR> resume \
  -m <MODEL> --config model_reasoning_effort="<EFFORT>" -c 'sandbox_mode="<MODE>"' \
  --last - 2>/dev/null <<'CODEX_PROMPT'
Your follow-up prompt here.
CODEX_PROMPT
```

Rules for resume:

- **A resumed session inherits the conversation history, but NOT the runtime
  config.** Verified on codex-cli 0.133.0: working directory, model, reasoning
  effort, and sandbox all silently revert to the CLI / `config.toml` / shell-cwd
  defaults on resume. Inside a trusted git repo the sandbox default is
  `workspace-write`, so a session you started `read-only` comes back as
  `workspace-write` unless you re-pin it; likewise a run started elsewhere with
  `-C` comes back in the shell's current directory. Always replay `-C <WORKDIR>`,
  `-m <MODEL>`, `--config model_reasoning_effort="<EFFORT>"`, and the sandbox to
  match the original. Track those four (plus the id) from Step 5 so you can replay
  them.
- `resume` does **not** accept `--sandbox` (passing it errors with
  `unexpected argument '--sandbox'`). Set the sandbox on resume with
  `-c 'sandbox_mode="<read-only|workspace-write|danger-full-access>"'` instead.
  `-C <WORKDIR>` goes before `resume` (it is an `exec` flag, not a `resume` flag).
- **Fail closed on any missing coordinate.** If the `SESSION_ID` from Step 5 came
  back empty, do not silently fall back to `--last`: tell the user an exact resume
  is unavailable and ask whether to proceed with `--last` (accepting it may target
  another session's thread) or re-run. If `MODEL`, `EFFORT`, `SANDBOX`, or
  `WORKDIR` came back empty, do not resume with a malformed command or let the
  field fall back to a default, re-derive it (re-read the stderr header or ask the
  user) before resuming.
- Flags (such as `--skip-git-repo-check`) go between `exec` and `resume`. The
  `-` positional, after the id or `--last`, tells `resume` to read the prompt
  from stdin (the here-doc).
- The quoted here-doc delimiter (`'CODEX_PROMPT'`) keeps the prompt verbatim and
  closes stdin, so shell metacharacters are safe and the call never blocks.

## Quick reference

Assemble the full command with the here-doc template in Step 4 (run) or in
Resuming a session (resume). This table is the sandbox-mode lookup.

| Use case | Sandbox mode | Extra flags |
| --- | --- | --- |
| Read-only review or analysis | `read-only` | *(default)* |
| Apply local edits | `workspace-write` | none |
| Permit network or broad access | `danger-full-access` | ask permission first |
| Resume a session | re-pin it | `-C <WD> resume -m <M> --config model_reasoning_effort="<E>" -c 'sandbox_mode="<MODE>"' <SESSION_ID> -` (workdir + config **not** inherited; prefer the id over `--last`) |
| Run from another directory | per task | `-C <DIR>` |

## Following up

After a **one-off** Codex task, and at the **final exit** of a debate, use
`AskUserQuestion` to confirm the next step: accept the result, clarify, or
resume. Restate the session id, working directory, model, reasoning effort, and
sandbox mode so the user knows which session a resume targets and which settings
you will replay (only the conversation history carries over; workdir, model,
effort, and sandbox do not).

This does **not** apply between rounds of an auto-mode debate: by design it does
not prompt the user until it converges or hits the round cap (see
**Plan-refinement debate**).

## Critically evaluating Codex output

Codex runs on OpenAI models with their own knowledge cutoffs and blind spots.
Treat it as a peer.

- **Trust your own knowledge when you are confident.** If Codex asserts
  something you know is wrong, say so directly.
- **Research disagreements** with WebSearch or documentation before accepting a
  contested claim. Be especially wary of Codex's claims about model names and
  capabilities, recent library or API changes, and best practices that may have
  shifted after its training cutoff.
- **Do not defer blindly.** Either model can be wrong.

When you and Codex disagree:

1. State the disagreement to the user and give your evidence (your own
   knowledge, a web search, or docs).
2. Optionally resume the session to discuss it, using the resume here-doc from
   **Resuming a session** and pinning `-c 'sandbox_mode="read-only"'` (a
   discussion touches no files). Identify yourself as Claude with your
   actual current model name so Codex knows it is a peer-AI exchange, then state
   the disagreement and your evidence and ask for Codex's take. Put your message
   in the here-doc body so it is passed verbatim.
3. Frame it as a discussion, not a correction.
4. If genuine ambiguity remains, let the user decide.

## Plan-refinement debate

Use this when the user wants to refine a *plan or design* with Codex rather than
run a one-off task: "debate this plan with Codex", "have Codex critique my
approach", `/codex debate <plan>`.

This is a planning activity, so keep Codex in read-only for every round: pass
`--sandbox read-only` on round 1, and re-pin `-c 'sandbox_mode="read-only"'` on
every resume, because resume does not inherit it (see **Resuming a session**).
No files are touched while the plan is still being argued. Choose model and
reasoning effort the same way as in **Running a task, Step 1**; higher effort
usually earns its keep here.

You are a participant, not a stenographer. Apply the **Critically evaluating
Codex output** principles above on every round: weigh each point, take what
improves the plan, push back on what does not, and say why.

### Cadence (who decides when to stop)

| Mode | Flag | Behaviour |
| --- | --- | --- |
| Auto | *(default)* | Claude and Codex iterate automatically up to 5 rounds. Stop early on convergence. If not converged by round 5, stop and hand the open disagreements to the user. The user is not asked between rounds. |
| Interactive | `--interactive` | Pause after every round; the user chooses **continue** / **accept** / **redirect**. For high-stakes plans the user wants to steer turn by turn. The user ends it; no fixed cap. |

5 is the same loop ceiling the repo uses elsewhere (see
[`orchestrator-protocol.md`](../../rules/orchestrator-protocol.md)). The user may
override the cap in plain language (for example "debate, up to 3 rounds").

### The loop

Steps 1 to 3 are identical in both modes. Step 4 is where the cadence differs.

1. **Draft.** Write the starting plan, or load the user's. Keep it short: a
   numbered list of decisions plus open questions. Set the round counter to 1.
2. **Send to Codex in read-only.** Round 1 uses the run here-doc (Step 4) with
   `--sandbox read-only` and captures the session id (Step 5). Every later round
   resumes that **pinned id** (Resuming a session), never `--last`, so a
   concurrent Claude session cannot hijack the debate mid-thread; on each resume
   re-pin `-c 'sandbox_mode="read-only"'` and replay the same `-C <WORKDIR>`,
   `-m`, and `--config model_reasoning_effort=`, since resume inherits none of
   them. Put
   the `<plan>` inside the here-doc body so its contents pass verbatim. Identify
   yourself as Claude (with your current model name) and ask Codex to critique
   the plan as a peer: what is wrong, missing, or risky, and what it would change
   and why. Tell it to argue the changes, not rewrite the plan.

3. **Evaluate and revise.** Read the critique critically. For each point decide
   accept / reject / needs-evidence, and research contested claims with
   WebSearch or docs before conceding. Revise the plan and keep a
   one-line-per-change record of what you accepted and what you rejected, with
   reasons. Log a one-paragraph round summary.
4. **Decide whether to continue.**
   - **Auto (default):** no user prompt here.
     - *Converged* (this round produced no substantive change, or you and Codex
       now agree on every open point): go to step 5.
     - *Round counter = 5 and not converged:* go to step 5 (not-converged path).
     - *Otherwise:* resume the pinned session id with the revised plan plus your
       rebuttals, increment the counter, and repeat from step 3.
   - **`--interactive`:** report the round to the user (Codex's main points, what
     you changed versus pushed back on, the current plan), then use
     `AskUserQuestion`: **continue** (resume, repeat from step 3) / **accept**
     (go to step 5, converged path) / **redirect** (fold the user's steer in,
     resume, repeat from step 3).
5. **Finish.** Convergence between Claude and Codex is not user approval. Only
   the user's acceptance marks a plan APPROVED
   ([`plan-first-workflow.md`](../../rules/plan-first-workflow.md): plans are
   user-approved before implementation).
   - **Interactive, user accepted:** save to
     `quality_reports/plans/YYYY-MM-DD_<slug>.md` (status **APPROVED**), then
     implement or hand back as the user directs.
   - **Auto, converged:** Claude and Codex agree, the user has not yet. Save as
     **DRAFT**, show the round-by-round trace and the final plan, and ask the
     user to approve before any implementation. Mark APPROVED only on the user's
     go-ahead.
   - **Auto, not converged after 5 rounds:** save as **DRAFT**, show the trace,
     the points you and Codex settled, and each remaining open disagreement as a
     pair (your position with evidence vs Codex's position). Use
     `AskUserQuestion` to let the user decide the open points or how to proceed.

### Guardrails

- **5 is a ceiling, not a target.** Each round is a real Codex call (time and
  cost). Stop the instant the plan stabilises; do not spend rounds circling the
  same points to reach 5.
- A round that produces no substantive change counts as convergence (both
  modes). Declare it and stop rather than resuming for its own sake.
- Keep the running plan in one artifact you re-show at the end, so the trace is
  legible and the summary never drifts from the plan body.
- Read-only throughout, which on resume means re-pinning
  `-c 'sandbox_mode="read-only"'` every round (resume otherwise defaults to
  `workspace-write` in a git repo). Switch to `workspace-write` only after the
  user has approved the plan (interactive accept, or the user's go-ahead in auto
  mode) and asks to implement.

## Error handling

- If `codex --version` or any `codex exec` command exits non-zero, stop, report
  the failure, and ask for direction before retrying.
- If output contains warnings or partial results, summarize them and ask how to
  adjust with `AskUserQuestion`.
