# The External Oracle Process — Codex → GPT-5.6 Sol Pro

**Verified 2026-08-21.** How to get an independent frontier-model referee on a paper, proof,
or estimator implementation, and — more importantly — how to *adjudicate* what it returns.

> **Two different things are called "oracle".** Keep them apart.
>
> | Sense | What it is | Ground truth for |
> |---|---|---|
> | **Reference oracle** | a *pinned checkout* of a canonical implementation (e.g. R `did` at a fixed release commit, sitting beside your port) | **numbers** |
> | **External-model oracle** | a different vendor's frontier model acting as a referee | **judgment** — advisory only |
>
> This file is about the second. The first lives in [`provenance-and-ground-truth.md`](provenance-and-ground-truth.md).

---

## 1. Why bother

1. **Independence you cannot get from a fork of yourself.** A second vendor's model has
   different training, different priors, different failure modes. A forked subagent shares
   yours.
2. **It forces an evidence bar.** The prompt contract below makes the referee produce a
   *failing case*, not an opinion. You can adjudicate a failing case; you can only agree or
   disagree with a vibe.
3. **Coverage becomes a manifest, not a sample.** "Check a couple of proofs" makes coverage
   stochastic. Assigning statements per round makes union coverage reach 100%.
4. **Economics.** Browser engine runs on a ChatGPT subscription, not API billing. That is
   what makes dozens of consults affordable.

**And the limit, stated as loudly:** *agreement is not confirmation.* Two models correlate on
the same wrong answer. An external oracle is **advisory**; a mechanical check outranks it.

---

## 2. Setup (one time)

The [Oracle CLI](https://github.com/steipete/oracle) (`@steipete/oracle`, MIT) bundles a
prompt plus files and drives a **dedicated browser profile** against ChatGPT — no API key.

```bash
brew install steipete/tap/oracle        # or: npm install -g @steipete/oracle
```

First run creates the automation profile and waits for you to log in:

```bash
oracle --engine browser --browser-manual-login \
       --browser-keep-browser --browser-input-timeout 120000 -p "HI"
```

Then set defaults once in `~/.oracle/config.json`:

```json
{ "engine": "browser",
  "model": "gpt-5.6-sol",
  "browser": {
    "manualLogin": true,
    "manualLoginProfileDir": "~/.oracle/browser-profile",
    "thinkingTime": "pro",
    "attachmentTimeoutMs": 900000,
    "inputTimeoutMs": 900000,
    "autoReattachDelayMs": 5000,
    "autoReattachIntervalMs": 3000,
    "autoReattachTimeoutMs": 60000,
    "archiveConversations": "never"
  } }
```

`thinkingTime: "pro"` is the **GPT-5.6 Sol max effort tier** (the CLI's own valid levels are
`light | standard | extended | heavy | pro`). `archiveConversations: "never"` keeps threads
alive for follow-ups.

**Smoke-check before relying on it:** `oracle -s smoke-check-now -p "Reply with OK."` — a run
that produces no conversation URL never happened.

---

## 3. Running a consult

With config in place:

```bash
oracle -s did-proof-audit-r1 -p "$(cat prompt.md)" -f main.tex supplement.tex --files-report
```

| Flag | Use |
|---|---|
| `--files-report` | token cost per attached file — **always use it**; the browser composer has a payload cliff (~35k tokens) above which nothing happens |
| `--followup <slug>` | reopen the exact saved conversation; inherits profile, model, and verifies prior turns |
| `--browser-follow-up "..."` | multi-turn in one run: answer → *"challenge your recommendation"* → *"final decision, smallest safe next step"* |
| `--models "gpt-5.6-sol,gemini-3.1-pro"` | query several vendors in parallel (API engine) |
| `--copy-markdown --render` | assemble the bundle and paste it into ChatGPT by hand — the degradation path when **browser automation is unavailable** (no automation profile, expired login, broken capture). With no CLI at all, the fallback is the *contract*, not the tool: build the prompt per §4 and paste manually |
| `oracle session <slug> --render` | reattach and recover a finished answer |

### Artifacts — where the evidence lives

```
~/.oracle/sessions/<slug>/
├── meta.json                 # status, model, full prompt, file list,
│                             # browser.runtime.tabUrl + conversationId
├── output.log
└── artifacts/transcript.md   # prompt, final answer, conversation URL
```

`browser.runtime.tabUrl` is the **send-committed signal**. No URL → the run never happened.

> **Archive the transcript into the repo — the session directory is not the record.**
> `~/.oracle/sessions/` is machine-local, unversioned, and one `--force` respawn away from
> being overwritten. Copy each consult's `artifacts/transcript.md` and its `meta.json` (which
> carries the exact prompt, the file list, and the conversation URL) into a dated directory:
> `quality_reports/oracle_audits/YYYY-MM-DD_<topic>/`. Then **any claim that rests on a
> consult cites the archived transcript**, never "the oracle said" recalled from session
> memory — the claim record in §5 names that path. A consult nobody can reopen is an
> anecdote, and a later reader cannot tell an adjudicated finding from a remembered one.

---

## 4. The prompt contract — force evidence, not conclusions

Every objection must carry:

- **an exact location** (section / equation / page + a short quote),
- **a one-sentence defect**,
- **a failing case** — a concrete configuration that breaks the claim, or the exact missing
  hypothesis.

Require the referee to **classify** each finding —
*false statement · proof gap · overclaim · scope/consistency · exposition* — and assign
*fatal · major · minor*. Require it to say **which credibility question** the finding
concerns (§6). Instruct it to **compute the computable**: evaluate population objects on
small adversarial designs (truncation, atoms, misspecification) and show the arithmetic.
That is the highest-yield attack class on an econometrics paper.

Two clauses that matter as much as the rest:

> **Blocked-route honesty.** If something cannot be concluded from what is shown, say exactly
> what is missing — never "this is standard."

> **No productivity theatre.** "No new confirmed defect" is a valid and useful answer.
> Inventing a marginal finding to appear productive is worse than silence.

The second exists because a reviewer told to find gaps will find them in sound work.

### Coverage manifest — never let the referee sample

Keep a **statement inventory** (every theorem / proposition / lemma by label) and a
cross-round **coverage ledger**. Each round *assigns* what to audit and requires the referee
to list what it actually verified. Rotate so the union reaches 100%, weighted to
newest / least-covered / highest-risk. Run exhaustive in-house coverage **first**, so the
external oracle is *confirmation, not discovery* — cheaper and sharper.

### The HELD list

Carry standing decisions into every prompt: *"Do NOT relitigate the settled verdicts above,
the class architecture, R-parity conventions, or line counts."* Findings that re-raise a held
item are **recorded, not acted on**.

---

## 5. Adjudicate — never ingest

Oracle findings are **candidates**, not verdicts.

1. **Judge every finding against the actual text.** Open the cited location. Is the
   hypothesis present elsewhere? Does the failing case arise under the stated conditions?
   Verdict: **CONFIRMED / REFUTED / DOWNGRADED**.
2. **Mechanical checks first.** If a finding is computable — an integral, an identity, a
   counterexample, a simulation — compute it. *Oracle agreeing with your own reading is not
   independent confirmation.*
3. **Filter the HELD list.**
4. **Batch the fixes.** Apply *all* confirmed fixes in one pass, re-verify, then run **at
   most one** confirmation round. No one-finding-per-round drip.
5. **Claim record** every cycle: what was fixed (location + evidence), what was REFUTED and
   why, what remains unresolved, and which decisions are yours.

**Convergence:** when a confirmation run returns no new CONFIRMED correctness defect — only
held items and exposition taste — the loop is done. Stop launching rounds.

---

## 6. Keep the five credibility questions separate

Evidence for one **never** clears another:

| Question | Answered by | Does *not* establish |
|---|---|---|
| **Reproducibility** — does the code run and produce the reported numbers? | `$audit-reproducibility`, the passport | that the estimator is right |
| **Implementation fidelity** — does the code implement the estimator it claims? | differential audit vs a pinned reference oracle | that the estimator performs well |
| **Statistical performance** — does it behave in finite samples? | `$simulation-study`, coverage against truth | that the measure is valid |
| **Measurement validity** — does the variable capture the construct? | domain review, data documentation | that the causal claim holds |
| **Identification / causal warrant** | design, sensitivity statistics, falsification | anything about the code |

A green reproducibility check being read as a validated causal claim is the most common way
AI-assisted empirical work goes wrong.

---

## 7. Hard-won mechanics

| Failure | Guard |
|---|---|
| Cloud-synced files (Dropbox/iCloud) dehydrate mid-read and upload **corrupt** | copy to a **local** scratchpad *in the same shell invocation*, then verify `pdfinfo` page count + `pdftotext` of the last page |
| Payload above the composer cliff → nothing is sent | `--files-report`; split into focused single-decision runs (answers are sharper anyway) |
| Capture timeout ≠ lost run | auto-reattach recovers into `artifacts/transcript.md` — **check the artifact before declaring failure** |
| Duplicate prompt already running | blocked unless `--force`; **prefer reattaching over respawning** |
| CLI timeout on a detached run | `oracle session <slug>` — do **not** re-run |
| Wrong-tab capture | verify thread identity *before* reading content; quarantine a suspect capture with a warning header |
| Concurrency | soft cap of 3 ChatGPT tabs per profile; a 4th caller waits. Matters when Codex and Codex both consult |
| A judge that can see what changed grades the diff | **blind the judge** — strip revision markers before a fresh-context comparison |

---

## Cross-references

- [`verification-ladder.md`](verification-ladder.md) — where the external oracle sits among the other checks
- [`provenance-and-ground-truth.md`](provenance-and-ground-truth.md) — reference oracles, pinned SHAs, clean-room boundary
- [`orchestration-schemas.md`](orchestration-schemas.md) — the FINDING / SCORECARD contracts
- [`.codex/guidance/orchestrator-protocol.md`](../guidance/orchestrator-protocol.md) — the in-house loop the oracle confirms
