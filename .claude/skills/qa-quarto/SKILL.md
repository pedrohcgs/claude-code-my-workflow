---
name: qa-quarto
description: Adversarial Quarto-vs-Beamer parity QA. A critic agent compares the Quarto HTML render to the Beamer PDF benchmark for content/visual parity; a fixer agent applies fixes; loops until APPROVED or two consecutive rounds turn up nothing new (fallback cap 5 rounds). Use when user says "qa the quarto", "check parity", "does the html match the pdf?", "quarto matches beamer?", or after a translate-to-quarto run. Requires both the `.qmd` rendered and a `.pdf` benchmark.
argument-hint: "[LectureN]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Agent", "Task"]
context: fork
background: false
---

# Adversarial Quarto vs Beamer QA Workflow

Compare Quarto HTML slides against their Beamer PDF benchmark using an iterative critic/fixer loop.

**Philosophy:** The Beamer PDF is the gold standard. The Quarto translation must be at least as good in every dimension.

---

## Workflow

```
Phase 0: Pre-flight → Phase 1: Critic audit → Phase 2: Fixer → Phase 3: Re-audit → Loop until APPROVED or dry (2 consecutive dry rounds; fallback cap 5)
```

## Hard Gates (Non-Negotiable)

| Gate | Condition |
|------|-----------|
| **Overflow** | NO content cut off |
| **Plot Quality** | Interactive charts >= static plots |
| **Content Parity** | No missing slides/equations/text |
| **Visual Regression** | Quarto >= Beamer in all dimensions |
| **Slide Centering** | Content centered, no jumping |
| **Notation Fidelity** | All math verbatim from Beamer |

## Phase 0: Pre-flight

1. Locate Beamer (.tex/.pdf) and Quarto (.qmd/.html) files
2. Check freshness (re-render if QMD newer than HTML)
3. Verify TikZ SVGs if applicable
4. Measure the render: `"${SLIDE_QA_PYTHON:-python3}" scripts/slide-qa.py Quarto/[Lecture].html`. It loads the deck in headless Chrome and writes `quality_reports/audits/slide-qa/[Lecture]/report.md` with per-slide overflow in pixels, plus one screenshot per slide. Exit 1 means it found something — overflow, clipped content, a broken image, or a missing or wrong-case file; exit 2 means it could not run (usually Playwright is missing — the script prints the one-time venv install and the `SLIDE_QA_PYTHON` line to set) — say so, and the critic falls back to reading the source.

## Phase 1: Initial Audit

Launch the `quarto-critic` agent to compare Beamer vs Quarto comprehensively, passing the slide-qa report path from Phase 0 for the Overflow gate. Report saved to `quality_reports/[Lecture]_qa_critic_round1.md`.

## Phase 2: Fix Cycle

If not APPROVED, launch `quarto-fixer` agent to apply fixes (Critical → Major → Minor), re-render, and verify.

## Phase 3: Re-Audit

Re-run `scripts/slide-qa.py` on the fixer's re-render, then re-launch the critic with the fresh report to verify fixes. Loop back to Phase 2 if needed.

## Iteration Limits — loop-until-dry

This is the **loop-until-dry** primitive from [`orchestrator-protocol.md`](../../rules/orchestrator-protocol.md): the critic returns `FINDING`s (the hard-gate table is the CRITICAL roll-up, per [`orchestration-schemas.md`](../../references/orchestration-schemas.md)); the loop **converges after 2 consecutive dry rounds** — rounds that add 0 new CRITICAL/MAJOR findings (deduped on `id = sha1(file:line:locus)`) — not at a fixed round count.

- **Fallback cap:** 5 rounds bounds a non-converging loop, then escalate to the user with remaining issues.
- **Two-strikes:** the same gate failing in rounds N and N+2 is flagged for the user, not patched again ([`summary-parity.md`](../../rules/summary-parity.md)).
- APPROVED iff every hard gate passes and no CRITICAL or MAJOR finding remains (minor ones are listed for the user).

## Final Report

Save to `quality_reports/[Lecture]_qa_final.md` with hard gate status, iteration summary, and remaining issues.

## Findings are validated, not just written (v2.5)

This skill's reviewers emit findings under the machine-checked contract in
[`finding-schema.json`](../../references/finding-schema.json). Reports are JSON **arrays**.

**Smoke-test the harness before spending review effort** — a run that fans out reviewers and
then cannot write a valid report has wasted the whole pass:

```bash
echo '[]' | python3 scripts/validate-findings.py
```

Reviewer agents are read-only, so **this skill writes the files**. For each reviewer's final
response: save the prose report to this skill's report path for that reviewer, copy its closing fenced `json` block
to a scratch file, and fill the ids while validating:

```bash
python3 scripts/validate-findings.py --fill-ids block.json > <report>.json.tmp \
  && mv <report>.json.tmp <report>.json || rm -f <report>.json.tmp   # exit 0 required; a failed run keeps no file
python3 scripts/validate-findings.py --check-quotes <report>.json   # each quote must be the file's own text (orchestration-schemas.md §1)
```

A reviewer that returned no `json` block, or a block that does not validate, has not reviewed:
re-dispatch it once with the validator's error text, then report the lens as missing rather
than reducing without it.

What the contract forces, and why:

- **`rule`** — the documented rule or standard violated. A finding citing no rule is an
  opinion, and opinions do not gate a commit.
- **`failing_case`** — a concrete configuration under which the claim breaks, or the exact
  missing hypothesis. *"This could be clearer"* does not validate.
- **`id = sha1("<file>:<line>:<locus>")`** — deterministic, so dedup across rounds is
  exact and the two-strikes rule is checkable rather than eyeballed.
- **`mechanical`** — `true` only for fixes that cannot change a result (typo, cross-reference,
  formatting, label). **Never** for an estimand, assumption, specification, inference
  procedure, sample definition, or reporting language: those return to the researcher.

Apply the **per-lens evidence burdens** and the **"does NOT count" filters** in
[`orchestration-schemas.md` §7](../../references/orchestration-schemas.md) *before*
verification, so known false alarms never reach the judge. The verifier pass is
**refute-biased** and sets each finding's `verdict` (reviewers leave it unset): only `verdict: "confirmed"` findings ship; anything it cannot ground is
dropped, not downgraded to a warning.
