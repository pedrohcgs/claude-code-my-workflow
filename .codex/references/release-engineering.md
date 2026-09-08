# Release Engineering — shipping research software as an artifact

**The question this answers:** the code works. What else has to be true before it is a
*release* — something a stranger installs, runs, misuses, and files a bug against, with you not
in the room? Writing the code is no longer the slow part; making its behaviour **legible,
enumerated, and pinned** is.

Applies to an R package, a Python module, a replication package shipped
as a versioned artifact, and any port or reimplementation of a reference implementation.

---

## 1. The user-facing message audit — census first, rewrite second

Every string the software shows a human is API — errors, warnings, notes, printed summaries, the
surface on which a user decides what to do next. **Enumerate it mechanically, and commit the
census *before* touching a single message:** one grep-and-tabulate pass over every emitting call
site — `stop()` / `warning()` / `message()` in R, `raise` / `warnings.warn` / logger calls in
Python, and explicit R conditions — into a tracked file recording source path, line,
class, condition or return code, and the **verbatim** text.

> An enumerator that runs after the rewrite cannot tell *"there were forty bad messages and I
> fixed them"* from *"I found the forty I had already fixed."* The pre-rewrite census is the
> denominator; without it the audit grades its own homework.

Then hold each message to a written standard — four questions, answered in the user's
vocabulary and not the implementation's:

| The message must say | Failure mode when it does not |
|---|---|
| **what happened** | names an internal object the user has never seen |
| **why** | states the symptom, hides the cause |
| **what it means for the result** | user cannot tell "wrong answer" from "cosmetic" |
| **what to do next** | technically accurate, operationally useless |

**Anything a caller branches on gets a classed condition** — an R condition class, a Python
exception type, or R condition class — never a substring match on the text. A downstream package
that greps your error string has a dependency on your prose, and your next copy-edit is its
outage. **Tests pin the exact text**, so a rewrite is a deliberate reviewed act that shows up as
a test diff rather than drift nobody noticed.

---

## 2. The silent-resolution census

Separately, enumerate every place the software **decides something on the user's behalf**:

- a **default** chosen when an argument is absent — especially a *data-dependent* one;
- a **fallback** taken when the preferred path is unavailable (a solver that switches method,
  an optimiser that retries from a different start);
- a **coercion** — string to numeric, character to factor, a partially-matched option name;
- **data dropped** — missing values, singleton groups, zero-weight units, collinear columns
  removed, duplicate keys deduplicated;
- an **ordering, reference level, or tie-break imposed** where the input did not fix one.

Each entry gets exactly one of two dispositions: it **speaks** — emits a classed condition and
records the fact in the returned object — or it is **documented-silent**, with a written reason
why the noise would cost more than the silence. There is no third disposition, and *"nobody has
complained"* is not a reason.

> A user cannot report a bug in a decision they were never told was made. Silent resolution is
> how two runs of "the same" analysis differ and nobody can reconstruct why.

**Anything that changes the analysis sample is a returned number, not a message.** Messages
scroll off; a field in the return object survives into the log and the replication package.

---

## 3. The frozen feature matrix (ports and reimplementations)

A port is judged against a reference, so the comparison surface must exist before the port does.
Write a matrix with **one row per user-visible behaviour** — not per function — carrying
behaviour id, reference behaviour, port behaviour, status (`matched` / `divergent` /
`out-of-scope` / `not-yet`), and for anything not `matched`, its divergence id and kind from the
taxonomy in [`provenance-and-ground-truth.md`](provenance-and-ground-truth.md) §3.

**Frozen** means the matrix *governs* the port rather than describing it: a divergence found
during implementation gets its **owner-approved row** first and is implemented second. Reversed,
the matrix degenerates into a transcript of whatever the port happened to do. Make it a merge
gate — a change introducing a `divergent` row with no approval marker does not merge. Which side
governs when the two disagree is a precedence question decided in advance
([`provenance-and-ground-truth.md`](provenance-and-ground-truth.md) §2); the comparison
mechanics are [`$differential-audit`](../../.agents/skills/differential-audit/SKILL.md).

---

## 4. Inherited tests are claimed by name **and** hash

If the reference implementation has a test suite, you inherit it. *"We ported the upstream
tests"* is a claim; a manifest is evidence — one row per upstream test: upstream path, test
name, **content hash of that file at the pinned commit**, the local test claiming it, and a
status (`inherited` / `adapted` / `not-applicable`, the last with a reason). The hash is the
load-bearing column: a name-only manifest goes stale in silence when upstream *strengthens* a
test you still claim to satisfy.

**The re-sync tool decides nothing.** It re-hashes the pinned upstream, reports every row whose
hash moved, and exits non-zero — it does not edit the manifest, mark rows not-applicable, or
re-bless anything. A sync tool permitted to resolve its own findings eventually resolves all of
them, and re-blessing inside the commit that moved the baseline destroys the distinction between
*measured* and *assumed* ([`provenance-and-ground-truth.md`](provenance-and-ground-truth.md) §6).

---

## 5. Release preflight archives

Preflight is a **dated, hashed record on disk**, not a feeling that things looked fine. Each
archive holds the timestamp, the commit, a **clean-tree receipt** (the porcelain status output,
captured verbatim and empty), the environment snapshot, every gate's verbatim output, and the
hashes of the built payload.

**Build the payload from the commit — `git archive HEAD` or the equivalent export — never from
the working tree.** A payload assembled from the working directory can contain a file you never
committed, and it passes every gate you run, because *you* have that file; the first person to
clone the repository does not. This is the most common way a green release breaks on a
stranger's machine.

**The shipped artifact must rebuild itself and run its own gates** — the payload carries its
build entry point, its environment lock, and its test entry point. Software that only builds
inside its author's checkout has not been released; it has been described.

**Development-only requirements are scoped by an explicit marker** — `Suggests` plus
`requireNamespace()` guards in R, a dev/extras group in Python, a separately documented install
step for external runtime dependencies — and preflight runs at least one gate in an environment
holding **only** the runtime requirements. Otherwise the first missing-dependency error is filed
by a user, against a package that passed all its tests.

Keep the archives — *"did the release we shipped pass its own gates?"* stays answerable a year
later. The locks themselves come from [`$capture-environment`](../../.agents/skills/capture-environment/SKILL.md),
and the last integrity check before the payload leaves is [`$verify-artifact`](../../.agents/skills/verify-artifact/SKILL.md).

---

## 6. Downstream pinning

A release becomes real when its consumers pin it. In every consumer, the verify receipt records
the **commit or content hash** of the artifact its numbers were produced against — not the
version string. Versions get re-tagged; hashes do not.

A change that moves a number the downstream reports is **one round** containing all four of: the
change itself; **before/after** evidence for every number that moved; regenerated downstream
artifacts; and the re-pin. Split across rounds, there is an interval in which a receipt claims a
pin it was not produced against. Within the round the ordering still holds — land the change
against the **old** pin so the downstream gate *reports* the drift, then re-pin in a follow-up
commit that cites the measurement. Find the consumers before you change anything shared:
[`$blast-radius`](../../.agents/skills/blast-radius/SKILL.md).

---

## 7. Status contracts are generated, not written

Any promise the documentation makes about the **set** of statuses, condition classes, warning
classes, or return codes the software can emit is generated **from the source by a tool**: a
**generator** walks the source and extracts the emitted set; the generated table ships **as
package data**, readable at runtime rather than only as prose in a manual; and a **test**
regenerates and compares, so a newly-added status fails the build until the contract is
regenerated and reviewed.

A hand-maintained status list is wrong within two releases: a branch adds a status, nobody edits
the vignette, and a downstream dispatch silently falls through its cases. This is the
release-engineering instance of *one source of truth per repo, and governance never ships* —
[`research-agent-laws.md`](research-agent-laws.md) law 17.

---

## 8. A declared bound that fails is a disposition, not a dial

Preflight declares bounds: a performance budget, a numerical tolerance, a coverage floor, a
memory ceiling. When one fails at release time the answer is a **disposition**, never an edit to
the bound — a gate turned green by rewriting the gate has changed nothing about the software.
For a preregistered bound the evidence does not support, that disposition is **WITHDRAW**; the
demotion path and the obligations that discharge it are in
[`verification-ladder.md`](verification-ladder.md).

What release engineering adds is the **record**: the bound as declared, the measurement, the
disposition, and who approved it, in the dated preflight archive — so a release that shipped
with something withdrawn says so where the next person will find it.

---

## Cross-references

- [`provenance-and-ground-truth.md`](provenance-and-ground-truth.md) — oracles, precedence, divergence kinds, the no-re-bless rule
- [`verification-ladder.md`](verification-ladder.md) — dispositions, and rung 0: qualify the gate before trusting its green
- [`research-agent-laws.md`](research-agent-laws.md) — laws 4 (a green gate is scoped), 16–17 (rules live with the code; governance never ships)
- [`$differential-audit`](../../.agents/skills/differential-audit/SKILL.md) · [`$verify-artifact`](../../.agents/skills/verify-artifact/SKILL.md) · [`$capture-environment`](../../.agents/skills/capture-environment/SKILL.md) · [`$blast-radius`](../../.agents/skills/blast-radius/SKILL.md)
- [`.codex/guidance/r-package-conventions.md`](../guidance/r-package-conventions.md) — the language-specific standards this genre sits on top of
