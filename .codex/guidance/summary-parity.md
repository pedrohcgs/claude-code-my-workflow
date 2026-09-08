---
paths:
  - "CHANGELOG.md"
  - "README.md"
  - "**/*.md"
  - ".agents/skills/*/SKILL.md"
  - ".codex/guidance/*.md"
  - ".codex/agents/*.md"
alwaysApply: false
---

# Summary–Body Parity (anti–whack-a-mole)

**When editing any summary paragraph, do NOT apply surgical word-level fixes.** Summaries drift from their bodies when the body changes but the summary is not re-verified. Surgical edits to the flagged phrase almost always introduce a new drift elsewhere in the same paragraph.

## What counts as a "summary paragraph"

- CHANGELOG opening paragraph of a version entry (the lede before the first `###` subheading)
- README.md tagline and section ledes
- PR title and `## Summary` block
- Skill / rule / agent frontmatter `description:` field
- Guide and reference-document section abstracts
- MEMORY.md `[LEARN:*]` entry headlines (the single-sentence summary before the prose)
- Any paragraph of the form "This release does X. It does not do Y. Counts are Z." — the triple-claim shape is a drift magnet

## The protocol

When you edit a summary paragraph (or when a reviewer — human, Copilot, or Codex — flags one):

1. **Read the full body** the summary is summarizing. Not just the diff. The whole thing.
2. **Enumerate every substantive claim** in the current summary: every noun list ("skills, rules, hooks"), every count, every superlative ("no new"), every inclusion/exclusion ("except X").
3. **Check each claim against the body.** For each claim, find the body content that supports or refutes it.
4. **Edit the whole paragraph, not just the flagged phrase.** Any specific claim that doesn't hold must be corrected in-place.
5. **Re-scan for orphan references.** A claim removed from the summary must not reappear in the body unreferenced, and vice versa.

## When to stop patching and rewrite

If a reviewer flags the same summary paragraph **twice in a row** (even on different words), stop patching — rewrite structurally. Two hits on the same paragraph means the paragraph itself is the wrong shape, not the specific wording.

**Rewrite bias:** prefer abstraction over specificity in summaries. A summary that makes zero enumerative claims cannot drift.

| Drift-prone (specific) | Drift-proof (abstract) |
|------------------------|------------------------|
| "No new skills, no new rules, no new hooks" | "No new directories on disk" |
| "27 skills / 13 agents / 22 rules / 6 hooks" | "On-disk inventory unchanged — see README for counts" |
| "Edits to `.codex/agents/X.md` and `.agents/skills/Y/SKILL.md`" | "Existing infrastructure revised" |
| "Fixes Copilot finding #3 and Codex finding #7" | "Addresses pre-merge review" |

The specific form is more informative when fresh but more likely to rot. The abstract form stays true across edits.

## Lesson: Copilot / Codex are drift detectors

Treat repeated review-bot findings on the same paragraph as a **structural signal**, not a list of bugs to patch one at a time. Each patch narrows the drift window but doesn't close it — the next edit to the body reopens it elsewhere.

## The two-strikes pattern travels

The "flagged twice → stop patching, escalate" rule is not specific to summaries. It applies wherever a disagreement can be quietly re-papered-over each round instead of resolved:

- `review-paper --adversarial` — the same concern raised in rounds N and N+2 is flagged for the user rather than patched a third time.
- `audit-reproducibility` — a numeric claim downgraded to **EXPLAINED** in two consecutive audits without ever being corrected to PASS is surfaced prominently ("contested number EXPLAINED twice, never corrected") rather than left to hide behind its recorded note.

In each case, two strikes means the *artifact is the wrong shape*, not that the wording needs one more touch.

## Cross-references

- `MEMORY.md` — `[LEARN:audit]` on summary-body whack-a-mole (the originating incident: three consecutive Copilot findings on the v1.6.1 CHANGELOG opening paragraph, PRs #88–#90).
- `.agents/skills/commit/SKILL.md` — when writing the commit message for a doc-heavy PR, apply this rule to the `## Summary` section before pushing.
- `.agents/skills/audit-reproducibility/SKILL.md` — "Repeated EXPLAINED is a signal (two-strikes)" reuses this pattern for contested numeric claims.
