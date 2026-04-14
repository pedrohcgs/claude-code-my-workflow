# Journal Profile Template

Copy this block into `.claude/references/journal-profiles.md` (under the appropriate regional/field section) and fill in every field. Weights for the 6 dispositions must sum to 1.0.

```markdown
### Journal Full Name (SHORT)

**Short name:** `SHORT`

**Focus.** [1-2 sentences: what this journal publishes and what it does NOT publish.]

**Bar.** [1-2 sentences: what it takes to clear the desk. Mention acceptance rate if known.]

**Domain-referee adjustments.**
- Contribution 30 → [new] ([reason])
- Lit positioning 25 → [new] ([reason])
- Substance 20 → [new] ([reason])
- External validity 15 → [new] ([reason])
- Fit 10 → [new] ([reason])

**Methods-referee adjustments.**
- [Dimension] [default] → [new] ([reason, e.g., "identification bar is higher at this journal"])
- [Paper-type-specific: e.g., "If paper type is `structural`: Parameter ID 30 → 35"]

**Typical concerns.** (3-5 direct-quote questions this journal's referees ask)
- "[Quote]"
- "[Quote]"
- "[Quote]"

**Referee-pool weights.** (must sum to 1.0)
- STRUCTURAL: 0.__
- CREDIBILITY: 0.__
- MEASUREMENT: 0.__
- POLICY: 0.__
- THEORY: 0.__
- SKEPTIC: 0.__

**Table format override.** [Optional: any journal-specific formatting rule. E.g., "No significance stars (APA 7th edition)" or "Three-decimal point estimates". Leave "None specific" if no override.]

---
```

## Disposition reference

The 6 dispositions used across the `--peer` pipeline:

| Disposition | Prior |
|---|---|
| STRUCTURAL | "Where's the mechanism? Where's the model?" |
| CREDIBILITY | "Show me pre-trends. What's the experiment?" |
| MEASUREMENT | "How is this measured? What about attrition / construct validity?" |
| POLICY | "Does this apply outside your sample? So what?" |
| THEORY | "What does the theory predict?" |
| SKEPTIC | "What would make this go away?" |

These dispositions are deliberately field-general. For a non-econ field, they should still apply — adjust the weights, not the labels.

## Field-specific paper types

The `methods-referee` agent branches on paper type. The default types (econ-centric) are:

- `reduced-form` — DiD, IV, RD, event study, etc.
- `structural` — structural estimation, DSGE, GE calibration, etc.
- `theory+empirics` — theoretical model with empirical test of its predictions.
- `descriptive` — measurement, data construction, pattern documentation.

For non-econ fields, add your own types to `.claude/agents/methods-referee.md` by duplicating the rubric block and editing the dimension weights. Examples:

- **Biology:** `observational / experimental / computational / review`.
- **Political science:** `case-study / comparative / formal-model / survey`.
- **Psychology:** `experimental / correlational / meta-analysis / pre-registered-replication`.

## Cross-references

- `.claude/references/journal-profiles.md` — the live calibration file.
- `.claude/agents/editor.md` — reads profiles, draws referee dispositions.
- `.claude/skills/review-paper/SKILL.md` — entry point for `--peer [SHORT]`.
