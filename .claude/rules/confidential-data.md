---
paths:
  - "data/**"
  - "**/*.dta"
  - "**/*.sav"
  - "**/raw/**"
  - "**/restricted/**"
  - "**/confidential/**"
---

# Confidential & Restricted-Data Protocol

**Some data must never leave the machine it was approved for, and some results must never leave the data center.** Economists work constantly with restricted-access data — Census FSRDC, IRS, administrative registers, health records, proprietary firm panels, IRB-governed human-subjects data. This rule is the standing contract for handling it; it is path-scoped to data directories and restricted formats so it loads exactly when relevant.

This is a **template** — replace the placeholder thresholds and providers with your data-use-agreement's actual terms.

---

## The three hard rules

1. **Never commit raw confidential data.** Raw microdata, identifiers, and provider-supplied files do not belong in git — not even in a private repo, not even once. `.gitignore` must cover `data/raw/`, `data/restricted/`, `*.dta`/`*.sav` containing microdata, and any path your DUA names. Commit *code* and *derived, disclosure-cleared* outputs only.
2. **Nothing leaves without disclosure clearance.** Any table, figure, coefficient, or count built on restricted data must pass disclosure-avoidance review *before* it appears in a draft, a slide, a commit, or an email. Pre-screen with [`/disclosure-check`](../skills/disclosure-check/SKILL.md); the data provider's official review is still mandatory and final.
3. **Access is per-person, per-agreement.** A co-author without the DUA cannot receive the data, the identifiers, or outputs that fail disclosure rules. Handoffs ([`/coauthor-brief`](../skills/coauthor-brief/SKILL.md)) carry *instructions to obtain access*, never the data.

## Keep restricted data off the model

Anything Claude reads is sent to the model provider, so "never leaves the machine" includes the model's context. Claude writes code that runs *on* the data; it does not read the data.

- **Deny rules hold in every permission mode, bypass included — unless a mod overrides them:** a *mod* (plugin code that runs inside Claude Code, 2.1.287 and later) can approve a call that a deny rule refuses or a `PreToolUse` hook blocked, unless managed settings are on the machine or the session is signed in with a Team or Enterprise account. On a restricted-data project, install no third-party mods and check `/plugin` for any that are active. Add `Read`/`Edit` deny rules for your restricted paths — a paste-ready block is in [TROUBLESHOOTING.md → "Keep restricted data off the model"](../../TROUBLESHOOTING.md#keep-restricted-data-off-the-model). They cover Claude's file tools, not every shell command, so they back up this rule rather than replace it.
- **External capture tools record your session.** Memory and observability add-ons (e.g. ai-memory, MemPalace, claude-mem, hosted tracing) store prompts, and some store tool output and shell output. On a restricted-data project use none, or one with an explicit allowlist that excludes these paths — and check where its store lives.
- **Claude Code keeps its own record of the session.** Transcripts, including tool output word for word, sit in `~/.claude/projects/<project>/`, and earlier copies of edited files in `~/.claude/file-history/`, until Claude Code's cleanup (`cleanupPeriodDays`, 30 days by default; sessions from Claude Desktop or Cowork are kept at any age unless `desktopSessionCleanupPeriodDays` is set). Two stores are never swept: your typed and pasted prompts in `~/.claude/history.jsonl` (large pastes also land in `~/.claude/paste-cache/`), and the project's auto memory in `~/.claude/projects/<project>/memory/`. If restricted content entered a session, do not `--resume` or `/checkpoint` it: run `claude project purge <path>` (preview with `--dry-run`), which removes the project's transcripts, file history, auto memory and its lines in `history.jsonl`, then clear `paste-cache/` and the session scratchpad, which it does not touch. Your data-use agreement's destruction terms cover all of these copies.
- **External-model consults upload what you attach.** [`/oracle-review`](../skills/oracle-review/SKILL.md) sends the files you attach to another vendor — your own paper and code are fine to send; a manuscript or proposal you are reviewing for a journal or funder is not, and neither are restricted microdata or outputs that have not cleared disclosure review.

## Disclosure avoidance (the short version)

The thresholds your provider enforces — encode them in `/disclosure-check`'s config:

- **Minimum cell count** (e.g., suppress any cell with n < 10; FSRDC and IRS differ — use yours).
- **Dominance / concentration** (p-percent and (n,k) rules for establishment data).
- **Complementary suppression** (suppressing one cell can leak via row/column totals — suppress complements too).
- **No exact extreme values, no unrounded sensitive statistics, no small-group identifiers, no fine geography.**

When a numeric claim is built on restricted data, its passport entry ([`replication-protocol.md`](replication-protocol.md)) should note the disclosure status, and the replication package ([`/replication-package`](../skills/replication-package/SKILL.md)) deposits only the cleared outputs plus *access instructions* for the data — never the data itself (this is exactly the AEA Data Editor's "restricted data" deposit path).

## Human subjects / IRB

If the data is human-subjects: record the IRB protocol number, the approved use, and any consent constraints in the project spec. Do not analyze beyond the approved scope. The [`/data-management-plan`](../skills/data-management-plan/SKILL.md) captures the storage, retention, and destruction terms.

## Multi-author git topology (restricted-data-safe collaboration)

- **Feature branches per author**, merged via PR — the same flow the rest of the template uses; no author force-pushes shared history (the [`git-guardrails`](../hooks/git-guardrails.py) hook blocks `--force` and `git add -A`, which is how raw data usually leaks into a commit).
- **`MEMORY.md` syncs via git; native auto memory (`~/.claude/projects/<project>/memory/`) stays machine-local** (`meta-governance.md`). Machine-specific restricted-data *paths* live in native auto memory, never in committed files.
- A collaborator joining a restricted-data project gets a [`/coauthor-brief`](../skills/coauthor-brief/SKILL.md) with environment setup ([`/capture-environment`](../skills/capture-environment/SKILL.md) lockfiles) and **access-request steps**, not a data drop.
- Enable strict path-leak protection while in restricted dirs: `CLAUDE_STRICT_PATHS=1` makes `git-guardrails` *deny* (not just warn) hardcoded machine paths in code.

## Cross-references

- [`/disclosure-check`](../skills/disclosure-check/SKILL.md) — pre-screen outputs against these thresholds.
- [`/data-management-plan`](../skills/data-management-plan/SKILL.md) — the funder-facing version of this contract.
- [`/replication-package`](../skills/replication-package/SKILL.md) — restricted-data deposit path (cleared outputs + access instructions).
- [`.claude/rules/replication-protocol.md`](replication-protocol.md) — passport entries note disclosure status.
- [`.claude/rules/meta-governance.md`](meta-governance.md) — the committed-vs-local two-tier model this builds on.
