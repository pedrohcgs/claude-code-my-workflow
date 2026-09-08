# Orchestrator Protocol: the review runtime

**The review-fix loop is a real runtime contract, expressed with the primitive every Codex session has: the `Agent` subagents.** Skills fan out to forked reviewers, reduce their *structured* findings ([`orchestration-schemas.md`](../references/orchestration-schemas.md)) through a deterministic gate, judge with a hallucination guard, and loop until dry. What is *not* automatic is the **trigger**: nothing launches this loop on its own — the user (or a skill invocation) starts it. That boundary is deliberate (see "What is NOT automatic").

## Proportionality — match the process to the stakes

**Read this before the machinery below.** Everything that follows is a heavyweight apparatus, and
the fastest way to make it worthless is to point it at everything. An external referee reviewing
this template put the objection plainly: it *"treats too many exploratory and collaborative states
like release engineering."* The predicted failure is not careful partial compliance — it is
perfunctory artifacts, vocabulary games that route around a definition, hatches set globally, or
the whole template abandoned for exploratory work. The recommendation is adopted here as the
runtime's own doctrine:

| Surface | Appropriate posture |
|---|---|
| Destructive git operations; changes to the controls themselves | hard gate, or explicit external authorization |
| Claims entering a public paper, a release, or a handoff | reproducible provenance and named verification |
| Promoting a default; a preregistered evaluation | prespecified pass / fail / escalation rules, written first |
| Exploratory analysis and interim collaboration | exact status reporting, **minimal ceremony** |
| High-recall discovery screens | ambiguity retained, not resolved by a default verdict |

Two readings of that table carry the weight. **Exact status reporting is the one thing never cut**
— naming the state you actually reached ([`research-agent-laws.md`](../references/research-agent-laws.md)
law 19) costs nothing and is what makes a light-touch exploratory run trustworthy at all. And **a
surface moves up the table the moment its output does**: an exploratory run whose number is about
to enter a paper is no longer exploratory, and it acquires the row above it *before* the number is
quoted, not after.

## The loop (the contract)

```
Skill invoked (with a RUN_CONFIG)
  │
  Step 1: IMPLEMENT / DRAFT
  │
  Step 2: VERIFY — compile, render, check outputs   (retry ≤ 2)
  │
  Step 3: FAN-OUT REVIEW — parallel forked reviewers, each returns FINDINGs
  │
  Step 4: REDUCE + JUDGE — stack scorecards; gate predicate → verdict;
  │        run the post-judge hallucination gate on judge-introduced CRITICALs
  │
  Step 5: FIX — apply `mechanical: true` findings; everything touching an
  │        estimand / assumption / specification / inference / reporting
  │        language returns to the researcher (critical → major → minor)
  │
  Step 6: SCORE — quality_score.py / hard-gate roll-up
  │
  └── converged?  (a round adds 0 new CRITICAL/MAJOR — see loop-until-dry)
        YES → present summary
        NO  → back to Step 3, in FRESH context
              (hard fallback cap reached → present with remaining issues)
```

## The runtime primitives

These primitives are the runtime. Every fan-out skill is a composition of them; none should re-describe them in prose — they reference this section and [`orchestration-schemas.md`](../references/orchestration-schemas.md).

### 1. Fan-out

Spawn the reviewers **in parallel in a single message** — N `Agent` calls, each `context: fork` so the main thread stays clean and each reviewer gets full budget for its lens. `Agent` subagents are the **portable primitive**: they exist in every Codex install, so the template depends on them, not on the session-gated Workflow tool. *(Where the Workflow tool is available — e.g. an `ultracode`$dynamic-workflow session — a skill may use it for the same fan-out→reduce→judge shape; treat that as an optional accelerator, never a requirement.)*

Which agent fills which lens, at which model tier, is in [`agent-fleet.md`](../references/agent-fleet.md). When a lens's judgment could be contaminated by what the reviewer can see — the prior verdict, the revision markers, the author's own summary — fence the environment it runs in: [`review-fencing.md`](review-fencing.md).

### 2. Reduce (typed, not eyeballed)

Each reviewer returns `FINDING`s and a `SCORECARD` in the shared schema. The synthesizer **stacks typed objects** and applies the **gate predicate** — `CRITICAL>0 → BLOCK`, `MAJOR>0 → REVISE`, else `PASS`. The verdict is a deterministic function of the findings, not a re-judgment of the artifact.

### 3. Judge + hallucination gate

A synthesizer/editor may freely *downgrade* or *de-duplicate* lens findings, but any **CRITICAL it introduces that no lens raised** must survive the post-judge hallucination gate ([`orchestration-schemas.md` §4](../references/orchestration-schemas.md)): re-verify it in a fresh `claim-verifier` fork; if it can't be grounded, drop it to `[JUDGE-HALLUCINATED]` and recompute. This is what makes an autonomous review trustworthy next to a credibility-sensitive artifact.

### 4. Loop-until-dry

Replace bespoke "max 5 rounds" stopping logic with **convergence**: stop after **2 consecutive dry rounds** (a round that adds 0 new CRITICAL/MAJOR findings). **Dedup is exact, not fuzzy (v2.5):** every finding carries `id = sha1("<file>:<line>:<locus>")`, so the same defect gets the same id in every round, **including when a different lens rediscovers it**. A round is dry when it produces no *new* id. Guards:

- **Fallback cap** — `RUN_CONFIG.max_rounds` (default 5) bounds a non-converging loop.
- **Two-strikes** — the *same* finding (**same `id`** — now mechanically checkable rather than eyeballed) surviving rounds N and N+2 is escalated to the user, not patched a third time ([`summary-parity.md`](summary-parity.md)).
- **Spend cap** — `RUN_CONFIG.spend_cap_tokens` (default ~500k) warns-and-asks; it is a spend ceiling, not a context limit (each re-audit is fresh).
- **Runaway backstop** — never exceed the harness's hard subagent cap; cost-pilot any ≥7× fan-out on one section before a full sweep.

### 5. Validate the findings (v2.5)

The `FINDING` contract is **machine-checked**, not prose. Every fan-out review ends by writing
its confirmed findings as a JSON **array** and validating it:

```bash
echo '[]' | python3 scripts/validate-findings.py          # smoke-test the harness FIRST
python3 scripts/validate-findings.py <report>.json        # exit 0 = valid
```

**Smoke-test before spending review effort.** A run that fans out ten reviewers and then cannot
write a valid report has wasted the whole pass.

The validator enforces what a reviewer must produce: a `rule` it violates (a finding citing no
documented rule is an opinion), a `failing_case` (not "this could be clearer"), an `id` derived
from its own coordinates, and a `mechanical` flag that is **never** true for an estimand,
assumption, specification, inference procedure, sample definition, or reporting-language change.

**The verifier pass is refute-biased.** The reviewer proposes; a separate pass tries to *break*
each finding. Only `verdict: "confirmed"` ships. A finding the verifier cannot ground is
**dropped**, not downgraded to a warning. Apply the per-lens evidence burdens and the
"does NOT count" filters in [`orchestration-schemas.md` §7](../references/orchestration-schemas.md)
*before* verification, so known false alarms never reach the judge.

### 6. Screening fan-outs

A **screen** — triage a candidate set down to the few worth real work — is a fan-out whose output is *verdicts* rather than findings, and it fails in the opposite direction from a review: not by inventing a defect, but by quietly including everything. So the screen is contracted before it launches.

- **Written rubric, before launch.** Criteria on disk, from [`templates/screening-rubric.md`](../../templates/screening-rubric.md). A rubric invented per candidate is the screener's taste applied N times.
- **The default verdict is declared, and it is a decision.** On a precision-first screen (a shortlist you will act on) EXCLUDE is the right default: a candidate is out unless cited evidence puts it in. On a **recall-first** screen — a literature sweep, prior-art search, anything asking *what are we missing* — that default silently drops relevant evidence and nothing downstream ever surfaces the loss, so the default belongs the other way or on a third verdict. Choose by asking **which error you could still catch later**, write the choice into the rubric, and send anything genuinely undecidable to **NEEDS-HUMAN** rather than resolving it toward whichever side is tidier.
- **Per-candidate evidence.** Each verdict names the field, line, or passage that decided it. A bare verdict is re-screened, not recorded.
- **Dispatcher spot-check.** Re-screen a sample by hand against the same rubric before acting on the wave; disagreement invalidates the wave rather than the one candidate.
- **Whole-wave adjudication.** Early returns are **status, not input** — nothing is decided until every agent has returned and the wave is reconciled in one pass, joining verdicts to candidates by `id`.

→ [`research-agent-laws.md`](../references/research-agent-laws.md) law 21; the dispatch side is [`templates/executor-contract.md`](../../templates/executor-contract.md).

### RUN_CONFIG: collect interactivity *before* launch

A forked subagent cannot stop to ask the user a question. So every interactive choice a fan-out needs — target journal, sampled dispositions, peeve budget, N referees, fresh-context flag, cross-artifact/novelty toggles — is gathered **before** the fleet spawns, echoed back as the **Pre-Flight Report**, and only then launched. Schema: [`orchestration-schemas.md` §5](../references/orchestration-schemas.md). An unresolved required field (e.g. an unknown journal) halts *before* launch, never mid-run. This is what lets `--peer`, `--variance`, and `editor` disambiguation keep their interactivity inside a no-mid-run-input runtime.

## Where the runtime is implemented

| Skill | Primitives | Notes |
|-------|-----------|-------|
| `$commit` | verify (Step 2), score (Step 6) | Halts on failure; `.githooks/pre-commit` enforces the same gates on every commit |
| `$seven-pass-review` | fan-out (7 lenses) → reduce → judge **+ hallucination gate** | Submission-ready / R&R papers |
| `$slide-excellence` | conditional fan-out → reduce | Spawns only lenses that can produce output; does not auto-fix |
| `$slide-excellence` | critics → fix → re-audit, **loop-until-dry** | Research-presentation review; hard gates = CRITICAL roll-up |
| `$review-paper --adversarial` | critic → fix → re-audit, **loop-until-dry** | Manuscript review |
| `$review-paper --peer` / `--variance` | RUN_CONFIG → editor → fan-out referees → editor synthesis **+ hallucination gate** | Cross-artifact pre-flight as Phase 0 |
| `$deep-audit` | mechanical checks → fan-out (4) → fix, **loop-until-dry** | Repo-wide consistency |
| `$data-analysis` | Pre-Flight → draft → verify | Pre-Flight required |

## What is NOT automatic

- **No post-plan-approval trigger / no daemon.** Exiting plan mode does not launch a fix loop, and there is no background service that points the runtime at an artifact unattended. A multi-agent fix loop with no human in it, run against a submission, shared data, or a co-author's draft, is exactly the failure mode we refuse — the loop is always user/skill-initiated. **This is a documented non-goal, not a missing feature.**
- **No repo-wide orchestrator chaining.** Skills compose the primitives within their own scope; they do not invoke each other without an explicit call.
- **Quality gate enforcement.** `quality_score.py` runs inside `$commit`, **and** — once `./scripts/install-hooks.sh` is run — the `.githooks/pre-commit` hook runs the full backtest gate suite plus the quality gate on every commit, so a direct `git commit` no longer bypasses the review (bypass is explicit: `SKIP_QUALITY_GATE=1` / `--no-verify`).

## "Just Do It" mode

When the user says "just do it" / "handle it" (within an already-invoked skill):

- Skip the final approval pause for the current skill; still run the full fan-out → reduce → judge → loop-until-dry; still present the summary.
- **Do NOT treat this phrase as commit authorization.** Commits require an explicit `$commit` or unambiguous request — see [`.agents/skills/commit/SKILL.md`](../../.agents/skills/commit/SKILL.md).

## Cross-references

- [`.codex/references/orchestration-schemas.md`](../references/orchestration-schemas.md) — FINDING / SCORECARD / RUN_CONFIG / hallucination-gate contracts.
- [`.codex/references/agent-fleet.md`](../references/agent-fleet.md) — the reviewer fleet + model tiers.
- [`.codex/guidance/plan-first-workflow.md`](plan-first-workflow.md) — when to enter plan mode before invoking a skill.
- [`.codex/guidance/quality-gates.md`](quality-gates.md) — threshold definitions + the pre-commit hook.
- [`.codex/guidance/post-flight-verification.md`](post-flight-verification.md) — the forked-verifier mechanism the hallucination gate reuses.
- [`.codex/guidance/cross-artifact-review.md`](cross-artifact-review.md) — paper ↔ code dependency-graph pattern.
