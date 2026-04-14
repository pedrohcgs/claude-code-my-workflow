<!-- Adapted from Hugo Sant'Anna's clo-author (github.com/hugosantanna/clo-author),
     used with permission. Journal-calibration schema credit: Hugo Sant'Anna. -->

# Journal Profiles

Calibration data for the `/review-paper --peer [journal]` simulated peer-review pipeline. Each profile tells the editor how to select referees (disposition-pool weights), what concerns that journal typically emphasizes, and any journal-specific formatting conventions.

**How this file is used.** The `editor` agent reads this file before each `--peer` run, picks the requested `[journal]`, and uses its Referee-pool weights + Typical concerns to select two referees with different dispositions and to seed their pet-peeve priors.

**Customizing for your field.** This file ships with **five top-5 econ journals** as a concrete example. To use `--peer` for a different field (finance, political science, biology, CS, etc.), copy `templates/journal-profile-template.md` into a new section below, fill in the schema, and reference it by the short name you define. See the [Field adaptation](#field-adaptation) section at the bottom.

---

## Schema

Every profile has these fields:

- **Short name** — the string you pass to `--peer [name]` (e.g., `AER`, `QJE`).
- **Focus** — what the journal publishes; what it doesn't.
- **Bar** — what it takes to clear the desk; typical acceptance rate context.
- **Domain-referee adjustments** — how the substance referee should re-weight their dimensions for this journal (e.g., "Contribution 30 → 35, External validity 15 → 20 for AER policy relevance").
- **Methods-referee adjustments** — how the methods referee should re-weight for this journal (e.g., "Identification 35 → 40 for QJE credibility bar").
- **Typical concerns** — 3–5 direct-quote questions a referee at this journal will ask.
- **Referee-pool weights** — probability weights over the 6 dispositions (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC). Editor draws two *different* dispositions from this distribution.
- **Table format override** (optional) — any journal-specific formatting rule. AEA journals: no significance stars. QJE: three-decimal point estimates.

---

## Econ Top-5

### American Economic Review (AER)

**Short name:** `AER`

**Focus.** General-interest economics across all fields. Strongest bar for substantive contribution and policy relevance. Favors credible identification + interpretable magnitudes + clear narrative over technical novelty.

**Bar.** "Publishing here means the top-10 people in your field will read it." Topic must matter beyond specialists. Contribution must be crisp in one paragraph.

**Domain-referee adjustments.**
- Contribution 30 → 35 (the bar on importance is higher)
- External validity 15 → 20 (generalizability matters more)
- Fit 10 → 5 (AER publishes across fields; fit is less of a constraint)

**Methods-referee adjustments.**
- Identification 35 → 40 (credibility is load-bearing)
- Replication 5 → 10 (AER Data and Code Availability Policy is strict)

**Typical concerns.**
- "Is the research question important enough for a general-interest journal?"
- "Is the identification strategy credible to a skeptical non-specialist?"
- "Does the magnitude tell us something we didn't already know?"
- "Are the robustness checks addressing the obvious threats, or are they theater?"
- "Is the replication package complete enough for the AEA Data Editor?"

**Referee-pool weights.**
- CREDIBILITY: 0.30
- POLICY: 0.25
- STRUCTURAL: 0.15
- MEASUREMENT: 0.15
- THEORY: 0.05
- SKEPTIC: 0.10

**Table format override.** No significance stars (AEA policy since 2023). Use SE in parentheses only; indicate p-values in notes if needed.

---

### Quarterly Journal of Economics (QJE)

**Short name:** `QJE`

**Focus.** Identification-first empirical work and theory with sharp predictions. Taste for clever natural experiments, rich data, and economic insight over methodological flash.

**Bar.** Identification must be near-airtight. Willing to accept narrow settings if the design is exceptional. Wants a paper that could be taught in a graduate class.

**Domain-referee adjustments.**
- Contribution 30 → 30 (unchanged)
- Substance 20 → 25 (taste matters — clever > competent)

**Methods-referee adjustments.**
- Identification 35 → 45 (this is the QJE house style)
- Robustness 15 → 10 (QJE referees are less tolerant of robustness-as-theater)

**Typical concerns.**
- "Is the research design genuinely clever, or is this yet another DiD?"
- "Does the first-stage / exclusion restriction / parallel-trends assumption have teeth?"
- "Would I teach this paper's identification strategy?"
- "What's the one-sentence economic insight here?"

**Referee-pool weights.**
- CREDIBILITY: 0.40
- STRUCTURAL: 0.20
- MEASUREMENT: 0.15
- POLICY: 0.10
- THEORY: 0.10
- SKEPTIC: 0.05

**Table format override.** Three-decimal point estimates standard; SE in parentheses.

---

### Journal of Political Economy (JPE)

**Short name:** `JPE`

**Focus.** Economic theory + empirical work tightly connected to theory. Chicago-flavored taste: markets, incentives, mechanism. Less sympathetic to pure reduced-form.

**Bar.** Theory component must be present and nontrivial — even in empirical papers, "what does the theory predict before we estimate" is expected.

**Domain-referee adjustments.**
- Contribution 30 → 30 (unchanged)
- Substance 20 → 30 (theory connection is load-bearing)

**Methods-referee adjustments.**
- If paper type is `theory+empirics`: Model 20 → 30, Prediction sharpness 25 → 30
- If paper type is `reduced-form`: Identification 35 → 30, expect explicit theoretical framing

**Typical concerns.**
- "What does the theory predict, and does the empirical work speak to that prediction?"
- "Is the mechanism spelled out, or are we just estimating a reduced-form coefficient?"
- "Do the magnitudes match what a reasonable model would imply?"
- "Is the paper arguing against a specific alternative theory, or waving at 'possible mechanisms'?"

**Referee-pool weights.**
- THEORY: 0.30
- STRUCTURAL: 0.25
- CREDIBILITY: 0.15
- MEASUREMENT: 0.10
- POLICY: 0.10
- SKEPTIC: 0.10

**Table format override.** None journal-specific.

---

### Econometrica (ECMA)

**Short name:** `ECMA`

**Focus.** Econometric theory, structural estimation, formal theory. Less sympathetic to reduced-form papers without methodological contribution. Mathematical rigor expected.

**Bar.** A methodological or theoretical advance must be visible. Applied papers clear the bar only if they bring a new estimator or a novel identification argument.

**Domain-referee adjustments.**
- Contribution 30 → 35 (methodological contribution weight)
- Fit 10 → 5 (ECMA tolerates narrower settings if the method generalizes)

**Methods-referee adjustments.**
- If paper type is `structural`: Model spec 20 → 30, Parameter ID 30 → 35, Counterfactuals 15 → 15
- If paper type is `reduced-form`: Identification 35 → 40, expect proofs / formal arguments
- Replication 5 → 10 (code + proofs must match)

**Typical concerns.**
- "What's the methodological contribution?"
- "Are the identifying assumptions stated formally, not just verbally?"
- "Are the asymptotic properties of the estimator established?"
- "Would an econometrician who reads only the abstract know what's new here?"

**Referee-pool weights.**
- STRUCTURAL: 0.30
- THEORY: 0.25
- MEASUREMENT: 0.20
- CREDIBILITY: 0.15
- POLICY: 0.05
- SKEPTIC: 0.05

**Table format override.** None specific; mathematical notation must be consistent throughout.

---

### Review of Economic Studies (ReStud)

**Short name:** `ReStud`

**Focus.** Conceptually ambitious work across theory, empirical, and macro. European-flavored taste: willing to publish unfashionable topics if the idea is strong. Values careful reasoning over technical fireworks.

**Bar.** A clear "intellectual arc" — the paper should leave the reader understanding something new about how the world works, not just a new estimate.

**Domain-referee adjustments.**
- Contribution 30 → 35
- Substance 20 → 25

**Methods-referee adjustments.**
- Identification 35 → 35 (unchanged; care but not QJE-level obsession)
- Honesty (for theory+empirics) 15 → 20

**Typical concerns.**
- "What do we understand about the world that we didn't before?"
- "Is the argument careful, or is it a victory lap?"
- "Are the limitations honestly stated, or buried?"
- "Does the conclusion generalize beyond this specific setting, and if so, how?"

**Referee-pool weights.**
- STRUCTURAL: 0.20
- CREDIBILITY: 0.20
- THEORY: 0.20
- POLICY: 0.15
- MEASUREMENT: 0.15
- SKEPTIC: 0.10

**Table format override.** None specific.

---

## Field adaptation

The five profiles above are econ-specific. The **pipeline is field-agnostic** — nothing in `editor.md`, `domain-referee.md`, or `methods-referee.md` hard-codes economics. What varies by field is the journal profile.

**To adapt for a different field:**

1. Copy `templates/journal-profile-template.md` into a new section below (use `### Journal Name (SHORT)`).
2. Fill each schema field:
   - **Focus** — what the journal publishes (look at the last 6 months of TOC).
   - **Bar** — acceptance rate + one sentence on what the editor is looking for.
   - **Domain-referee adjustments** — re-weight contribution / lit-positioning / substance / external validity / fit for this journal's taste.
   - **Methods-referee adjustments** — for non-econ fields, you will want to rename the paper types in `methods-referee.md` (see the next section).
   - **Typical concerns** — read 2–3 recent reviews (published alongside papers at Nature Communications, eLife, etc., or solicit from a colleague) and distill 3–5 recurring referee questions.
   - **Referee-pool weights** — the 6 dispositions are general enough to apply to any field. Re-weight based on what that journal's referees actually ask about. Weights must sum to 1.0.
   - **Table format** — any field-specific conventions (e.g., APA tables for psychology, Chicago-style footnotes for history, Vancouver citations for medicine).

**For non-econ paper types.** The `methods-referee.md` paper-type branching uses `reduced-form / structural / theory+empirics / descriptive`. If your field uses different categories (e.g., biology: `observational / experimental / computational / review`; political science: `case-study / comparative / formal-model / survey`), edit `methods-referee.md` to add your field's paper types and their dimension weights. Keep the `reduced-form` / etc. branches for econ users.

**Examples for non-econ fields** (to be filled in by adopters — we ship econ only):

- `### Nature Human Behaviour (NHB)` — flagship interdisciplinary. Bar: broad impact + pre-registration + replication. Referee weights: MEASUREMENT high, CREDIBILITY high.
- `### Journal of Politics (JOP)` — political science. Bar: theoretical contribution + identification. Referee weights: THEORY high, CREDIBILITY medium.
- `### PNAS` — multi-disciplinary. Bar: generalizability + public interest. Referee weights: POLICY high, SKEPTIC high.

---

## Cross-references

- `.claude/agents/editor.md` — reads this file.
- `.claude/agents/domain-referee.md` — applies domain-referee adjustments.
- `.claude/agents/methods-referee.md` — applies methods-referee adjustments.
- `.claude/skills/review-paper/SKILL.md` — `--peer [journal]` mode entry point.
- `templates/journal-profile-template.md` — skeleton for adding your own.
