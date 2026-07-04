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

## WRDS / licensed commercial data (this project's primary constraint)

This project pulls from **WRDS** (Wharton Research Data Services). WRDS data —
CRSP, Compustat / Compustat Global, SDC Platinum (new issues / IPOs), Datastream /
Worldscope, and similar — is **licensed, not public**. The binding concern is
**redistribution**, not statistical disclosure. The rules:

1. **Never commit raw WRDS extracts.** Not vendor tables, not row-level pulls, not
   merged panels that still contain licensed row-level data — not even once, not in a
   private repo. `.gitignore` covers `data/wrds/`, `data/raw/`, and `*.parquet` /
   `*.dta` / `*.rds` under those paths. Commit **code** and **derived, aggregated
   outputs** (summary tables, coefficients, figures) only.
2. **Credentials never touch git or code.** WRDS username/password live in a
   gitignored `.Renviron` (`WRDS_USER=` / `WRDS_PASS=`) or the OS keychain, read at
   runtime (e.g. `Sys.getenv("WRDS_USER")` / `RPostgres`). Never hardcode them.
3. **Redistribution is per-subscription.** A collaborator without a WRDS
   subscription cannot receive the raw data. A handoff carries the *pull scripts* and
   *access instructions*, never the extract. The replication package deposits code +
   derived outputs + a data-access note, never the WRDS tables (this is the AEA Data
   Editor's "third-party licensed data" path).
4. **Attribution / terms.** Cite the WRDS source and vendor per the subscription
   terms. **Jay Ritter's IPO data** (his website) is public-with-attribution — usable
   and citable, but still not "yours" to relabel; cite it.

Aggregated outputs derived from WRDS (e.g. mean underpricing by year × region) are
publishable — they are not row-level licensed data. When in doubt about an output's
granularity, treat it as licensed until you confirm it is aggregate.

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
- **`MEMORY.md` syncs via git; `.claude/state/personal-memory.md` stays local** (`meta-governance.md`). Machine-specific restricted-data *paths* live in personal-memory, never in committed files.
- A collaborator joining a restricted-data project gets a [`/coauthor-brief`](../skills/coauthor-brief/SKILL.md) with environment setup ([`/capture-environment`](../skills/capture-environment/SKILL.md) lockfiles) and **access-request steps**, not a data drop.
- Enable strict path-leak protection while in restricted dirs: `CLAUDE_STRICT_PATHS=1` makes `git-guardrails` *deny* (not just warn) hardcoded machine paths in code.

## Cross-references

- [`/disclosure-check`](../skills/disclosure-check/SKILL.md) — pre-screen outputs against these thresholds.
- [`/data-management-plan`](../skills/data-management-plan/SKILL.md) — the funder-facing version of this contract.
- [`/replication-package`](../skills/replication-package/SKILL.md) — restricted-data deposit path (cleared outputs + access instructions).
- [`.claude/rules/replication-protocol.md`](replication-protocol.md) — passport entries note disclosure status.
- [`.claude/rules/meta-governance.md`](meta-governance.md) — the committed-vs-local two-tier model this builds on.
