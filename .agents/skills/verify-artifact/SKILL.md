---
name: verify-artifact
description: "Prove that the file you are about to send, publish, or hand off IS the thing you mean — before it leaves your hands. Rebuild from source, check integrity, diff the derived artifact against its source, and require the recipient to echo what they received. Use before sending a paper/PDF for review, shipping a release or replication package, handing files to a coauthor or collaborator, uploading anything to an external reviewer or model, or publishing. Prevents an entire review/QA cycle from being spent on defects that exist only in the artifact, not in the work."
---




# Verify the artifact before it leaves

A review is only as good as the thing reviewed. If the artifact is corrupt, truncated, stale, or silently renumbered, a competent reviewer will return confident findings about defects **that do not exist in your work** — and you will spend a cycle chasing them. This is cheap to prevent and expensive to miss.

**Rule: never send a derived artifact you have not diffed against its source.**

## 1. Rebuild from source, in one shell invocation

Never send yesterday's build. Rebuild, then copy to the send location in the *same* command, so nothing can change underneath you.

Cloud-synced folders (Dropbox/iCloud/OneDrive) **dehydrate files**: a PDF can become 0 bytes or a partial copy between building and reading it. Symptoms: `Syntax Error: Couldn't find trailer dictionary`, a 70 KB file that should be 700 KB. Build-tool "up to date" messages are *not* evidence the file is intact — the tool checks timestamps, not content. Always stage to a local (non-synced) directory and verify there.

## 2. Integrity checks (mechanical, fast, non-negotiable)

- **Size and structure**: byte size in the expected range; page/record/row count as expected.
- **It parses**: open it with a real reader (`pdfinfo`, `pdftotext`, a JSON/CSV parser, `unzip -t`). A file that exists is not a file that works.
- **Sample the content**: first and last page/record actually contain what you expect — truncation shows up at the end.
- **Unresolved markers**: for documents, count `??`, `[cite]`, `TODO`, `XXX`, `\ref{` leftovers, "Chapter ??"; for code/data, NaNs, empty cells, placeholder values.

## 3. Diff the derived artifact against its source

This is the step people skip and the one that pays. If you produced the artifact by transforming, excerpting, compressing, or subsetting, then **enumerate what could have been lost** and check it:

- **Labels/anchors/IDs**: set of identifiers in source vs artifact. Anything defined in source and *referenced but missing* in the artifact is a break.
- **Numbering**: removing a numbered object silently renumbers everything after it, so a citation that was "Lemma 10" becomes "Lemma 6" — every downstream reference now points somewhere plausible and wrong. Check numbering stability, not just presence.
- **Counts**: sections, tables, figures, rows, functions, endpoints — before vs after.
- **Nested content**: excerpting a block can remove *statements* nested inside it, not just the prose you meant to cut.

If you cut anything, leave a visible in-artifact note saying so, so a reviewer does not read an omission as a gap.

## 4. Make the recipient prove what they got

Ask the reviewer (human or model) to **state, at the top of their response, the exact filenames, page/record counts, and version they are reviewing**. This catches stale caches, wrong attachments, and silent fallbacks to an older upload — failures that are otherwise invisible until the findings make no sense.

Use unique filenames per round (`report_r6.pdf`, not `report.pdf`). Repeated identical names invite the recipient's system to serve a cached earlier copy.

## 5. If findings look strange, suspect the artifact first

Before acting on a review, ask: could this finding be an artifact of what I sent? Signals: complaints about missing/undefined references, "sections appear truncated", "the proof ends mid-argument", numbering that does not match your copy, or objections to text you know is present. **Re-verify the artifact before you re-verify the work.** Applying "fixes" for artifact-induced findings actively damages correct material.

## Minimum checklist

1. Rebuild from source; stage to a local dir in the same shell command.
2. Verify it parses; check size, counts, first/last content.
3. Count unresolved markers — expect zero.
4. Diff identifiers/numbering/counts against source; note any deliberate omissions in the artifact itself.
5. Unique filename for this round.
6. Require the recipient to echo filename + counts.

## Cross-references

- [`verification-ladder.md`](../../../.codex/references/verification-ladder.md) — rung 2 (existence → substantiveness → wiring → coherence)
- [`external-oracle-process.md`](../../../.codex/references/external-oracle-process.md) §7 — cloud-synced files upload corrupt

