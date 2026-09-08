---
name: voice-profile
description: "Extract a written voice profile from your own prior papers, then use it to keep new drafts sounding like you. Reads a corpus one document at a time via subagents, produces a reusable profile on disk (lexicon, sentence rhythm, how you open and close, hedging habits, deliberate quirks), and audits a draft against it. Use when the user says \"make this sound like me\", \"match my voice\", \"profile my writing\", \"why does this draft not sound like my papers\", or before drafting prose that will carry their name. The positive counterpart to $humanize, which only detects AI tells."
---



# Voice profile — write toward something, not just away from tells

[`$humanize`](../humanize/SKILL.md) is the **negative** direction: it finds AI tells and says
what to remove. That leaves a draft that is merely *less bad*.

This is the **positive** direction: a written description of how *you* actually write,
extracted from your own published work, so a draft can be measured against a target instead of
a taboo list.

> **What this does not do.** A voice profile makes prose sound like your prose. It does **not**
> make model-generated text stop reading as model-generated to a neural detector — nothing an
> LLM applies to its own output does. See [`writing-with-ai.md`](../../../.codex/guidance/writing-with-ai.md).
> Use this to write well in your own register; write the load-bearing sentences yourself.

## Building the profile

### 1. Assemble the corpus, and count it

Three to twelve of **your own** pieces where you were the primary writer. Published papers
are best — they survived editing. Mix genres if you write in several (paper, referee report,
grant, presenting notes); the profile should note where your register changes.

```bash
find <corpus-dir> -maxdepth 1 \( -name '*.pdf' -o -name '*.tex' \) | wc -l
```

*(`find`, not a glob — in zsh an unmatched glob aborts the whole command, which
reports 0 and defeats the count this step exists for.)*

**Count before starting.** A corpus of eleven is a different task from four, and discovering
that halfway through is how a session gets reset.

### 2. One subagent per document — never load the corpus into one context

Per [`pdf-processing.md`](../../../.codex/guidance/pdf-processing.md): spawn **one subagent per document**
with `context: fork`. Each reads **only its own file**, writes a ~300-word note to
`notes/voice/<name>.md` against the fixed schema below, and **returns only the filename**.

The main session then reads only the notes. Loading a whole corpus at once has repeatedly
forced a session reset after partial work was already lost.

**Per-document note schema** — the same six headings every time, so the synthesis can compare:

```
## Lexicon      words and phrases used repeatedly; words conspicuously avoided
## Rhythm       typical sentence length; variance; where long sentences appear
## Openings     how sections and paragraphs begin; how the paper opens
## Transitions  the actual connectives used, verbatim, with rough frequency
## Hedging      how uncertainty is expressed; how strong claims are made
## Quirks       anything distinctive — punctuation habits, first person, humour, footnotes
```

### 3. Synthesize, and mark what is *stable*

Read only the notes. A trait belongs in the profile if it appears across **most** of the
corpus, not because one paper did it once. Record frequencies where you can: *"'note that'
appears in 7 of 9 papers; 'delve' appears in none."*

Write to `voice-profile.md` at the repo root (allowlisted in the repo-hygiene gate). Include:

- **Signature vocabulary** and **the avoid list** — words the author demonstrably does not use.
- **Sentence rhythm**, with a number: median length, and where the long ones land.
- **Structural habits** — how an introduction is built, where the contribution paragraph sits,
  how results are framed.
- **Hedging register** — the author's actual calibration language, which is usually narrower
  than a model's default.
- **Deliberate quirks, labelled as deliberate.** *"Uses em-dashes frequently and on purpose"*
  stops `$humanize` from flagging a habit as an AI tell.
- **Where the register shifts** by genre.

### 4. Wire it in

`$humanize` reads `voice-profile.md` when present and **respects documented preferences** — a
quirk you have declared deliberate is no longer a finding. Point drafting work at the profile
before it writes, not after.

## Auditing a draft

Pass `--audit` followed by a filename to compare an existing draft against the profile instead of building one:

```
$voice-profile --audit main.tex
```

Report, per section: distance from the profile, with concrete evidence — vocabulary outside
your range, hedging denser than your baseline, transitions you do not use, sentence rhythm
that has flattened. **Every finding cites the profile line it violates**, so it is a deduction
rather than taste.

**Read-only.** Auto-rewriting prose degrades it and introduces new tells, and it cannot change
what a detector sees. The report says where and why; the author edits.

## Anti-patterns

- **Profiling coauthored work you did not draft.** You will extract someone else's voice.
- **Treating the profile as a rulebook.** It describes what you have done, not what you must
  do. Voices change; re-profile after a few new papers.
- **Building it from AI-assisted drafts.** The profile will encode the model's register as
  yours — the corpus must be work you wrote.
- **Using it to pass a detector.** It is a writing aid, not a laundering step. If a venue wants
  an AI-use statement, make one ([`$submission-disclosures`](../submission-disclosures/SKILL.md)).

## Cross-references

- [`writing-with-ai.md`](../../../.codex/guidance/writing-with-ai.md) — readability vs provenance, and the human-readable standard
- [`$humanize`](../humanize/SKILL.md) — the negative direction; reads this profile when it exists
- [`$proofread`](../proofread/SKILL.md) — grammar and consistency, a separate lens
- [`pdf-processing.md`](../../../.codex/guidance/pdf-processing.md) — the one-subagent-per-document pattern

