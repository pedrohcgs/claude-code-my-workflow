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
2. **Nothing leaves without disclosure clearance.** Any table, figure, coefficient, or count built on restricted data must pass disclosure-avoidance review *before* it appears in a draft, a slide, a commit, or an email. Pre-screen with [`$disclosure-check`](../../.agents/skills/disclosure-check/SKILL.md); the data provider's official review is still mandatory and final.
3. **Access is per-person, per-agreement.** A co-author without the DUA cannot receive the data, the identifiers, or outputs that fail disclosure rules. Handoffs ([`$coauthor-brief`](../../.agents/skills/coauthor-brief/SKILL.md)) carry *instructions to obtain access*, never the data.

## Disclosure avoidance (the short version)

The thresholds your provider enforces — encode them in `$disclosure-check`'s config:

- **Minimum cell count** (e.g., suppress any cell with n < 10; FSRDC and IRS differ — use yours).
- **Dominance / concentration** (p-percent and (n,k) rules for establishment data).
- **Complementary suppression** (suppressing one cell can leak via row/column totals — suppress complements too).
- **No exact extreme values, no unrounded sensitive statistics, no small-group identifiers, no fine geography.**

When a numeric claim is built on restricted data, its passport entry ([`replication-protocol.md`](replication-protocol.md)) should note the disclosure status, and the replication package ([`$replication-package`](../../.agents/skills/replication-package/SKILL.md)) deposits only the cleared outputs plus *access instructions* for the data — never the data itself (this is exactly the AEA Data Editor's "restricted data" deposit path).

## Human subjects / IRB

If the data is human-subjects: record the IRB protocol number, the approved use, and any consent constraints in the project spec. Do not analyze beyond the approved scope. The [`$data-management-plan`](../../.agents/skills/data-management-plan/SKILL.md) captures the storage, retention, and destruction terms.

## Multi-author git topology (restricted-data-safe collaboration)

- **Feature branches per author**, merged via PR — the same flow the rest of the template uses; no author force-pushes shared history (the [`git-guardrails`](../hooks/git-guardrails.py) hook blocks `--force` and `git add -A`, which is how raw data usually leaks into a commit).
- **`MEMORY.md` syncs via git.** Machine-specific restricted-data paths stay in approved local notes, never committed files.
- A collaborator joining a restricted-data project gets a [`$coauthor-brief`](../../.agents/skills/coauthor-brief/SKILL.md) with environment setup ([`$capture-environment`](../../.agents/skills/capture-environment/SKILL.md) lockfiles) and **access-request steps**, not a data drop.
- Enable the repository's strict path-leak hook while working in restricted directories so hard-coded machine paths are denied rather than merely warned.

## Cross-references

- [`$disclosure-check`](../../.agents/skills/disclosure-check/SKILL.md) — pre-screen outputs against these thresholds.
- [`$data-management-plan`](../../.agents/skills/data-management-plan/SKILL.md) — the funder-facing version of this contract.
- [`$replication-package`](../../.agents/skills/replication-package/SKILL.md) — restricted-data deposit path (cleared outputs + access instructions).
- [`.codex/guidance/replication-protocol.md`](replication-protocol.md) — passport entries note disclosure status.
- [`.codex/guidance/meta-governance.md`](meta-governance.md) — the committed-vs-local two-tier model this builds on.
