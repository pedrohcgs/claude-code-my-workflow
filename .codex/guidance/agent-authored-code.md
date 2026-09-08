---
paths:
  - "**/*.sh"
  - "**/*.py"
  - "**/*.R"
  - "**/*.do"
---

# Agent-authored code — the bugs are usually ours

Across 367 hours of logged sessions, the single most common friction was **buggy code**, and
most of it was **not in the existing codebase**. It was written by the agent during the
session: bulk regexes, monitoring loops, and generated runner scripts.

These are not exotic failures. They are the same four, over and over.

---

## 1. Never run a repo-wide transformation without a dry run

A regex that looks right on the example you tested it against will do something else on file 40.

**Before any bulk edit — `sed -i`, a Python rewrite loop, a `replace_all`:**

1. Print the **count** of files that will change and the **first three diffs**.
2. Confirm the diffs are what you expected — read them, do not skim.
3. Only then apply.
4. **Verify the output afterwards**, not the exit code. A regex that ran successfully and
   produced wrong text exits 0.

*Incident:* a `Task` → `Agent` migration regex left a stray backtick in **14 files**, because
an optional trailing `` `? `` did not consume what the author assumed. The script reported
success. The corruption was found later by an unrelated link checker.

*Incident:* the same migration turned `["Read", "Task"]` into `["Read", "Agent, Task"]` in
**33 skills** — one tool with a comma in its name, not two tools. Caught only by reading the
output.

> **The rule:** a bulk edit is not done when the script exits 0. It is done when you have read
> a sample of the result.

---

## 2. Resolve paths before any `cd`, not after

```bash
# WRONG — $0 is RELATIVE when invoked as ./run.sh, so after any cd the
# saved path points at the wrong place (or nowhere)
SCRIPT_DIR="$(dirname "$0")"     # e.g. "."
cd /tmp/workdir
source "$SCRIPT_DIR/lib.sh"      # resolves against /tmp/workdir — breaks

# RIGHT — resolve to an ABSOLUTE path before any cd
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd /tmp/workdir
source "$SCRIPT_DIR/lib.sh"      # still correct from anywhere
```

A script that works when invoked from the repo root and silently misbehaves from anywhere else
is worse than one that fails, because it produces output.

---

## 3. Monitor by PID file, never by `pgrep` pattern

```bash
# WRONG — the watcher's own command line contains the pattern, so it waits on itself, forever
while pgrep -f "run_simulation" > /dev/null; do sleep 60; done

# RIGHT — the job records its PID; the watcher checks that specific process
nohup Rscript run_simulation.R > sim.log 2>&1 & echo $! > sim.pid
while kill -0 "$(cat sim.pid)" 2>/dev/null; do sleep 60; done
```

*Incident:* a monitoring chain matched its own `pgrep` pattern and waited on itself while a
deadline ran out.

**And cover every terminal state.** A monitor that greps only for the success line is silent
through a crash — and **silence looks identical to "still running."** Check for completion,
failure, *and* the process being gone without either.

---

## 4. Long runs: `nohup` + a heartbeat file + a written runbook

Before any multi-hour run, write the **endgame runbook** to a version-controlled file first:
the resume command, the artifact paths, and the verdicts to check. Context gets compressed;
disk does not.

The job writes a heartbeat (a timestamp, a completed-count) that the watcher polls. **Compute
ETAs from artifact timestamps, not from impressions.**

---

## Prefer a committed script to an improvised one

If a loop has been written twice, it belongs in `scripts/` with:

- absolute path resolution **before** any `cd`;
- **PID-file** based monitoring;
- a **`--dry-run`** flag;
- a non-zero exit on failure, and a message naming what failed.

An invoked known-good script beats a freshly-improvised fragile one, every session.

---

## Claims about code carry a revision

Any statement about what the code currently does — "the gate rejects an unregistered fixture",
"this function returns six elements", "that bug is fixed" — names the revision it was read at:
run `git rev-parse --short HEAD` at read time and carry that short SHA with the claim. **An
unstamped claim goes stale silently** — nothing distinguishes a statement that is still true
from one describing a file three commits ago. [`issue-ledger.md`](issue-ledger.md) already
requires the exact source revision on a defect report; this is the same standard for every claim
about code state, not only the ones that become issues.

---

## Cross-references

- [`.codex/guidance/simulation-conventions.md`](simulation-conventions.md) — seed by task, not worker; prove run-shape independence
- [`.codex/guidance/repo-hygiene.md`](repo-hygiene.md) — the scratch scripts these produce must not become main files
- [`issue-ledger.md`](issue-ledger.md) — the same revision-stamping standard, required on every defect report
- [`.codex/references/research-agent-laws.md`](../references/research-agent-laws.md) — laws 1, 10
