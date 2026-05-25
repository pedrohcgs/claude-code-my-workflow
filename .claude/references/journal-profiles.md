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

## Political Science (Top-3)

Three flagship general-interest political-science journals. The `paper_type` taxonomy here typically resolves to `reduced-form`, `formal-theory`, or `survey-experiment` (added in v1.8.0 to support these journals). Other types still apply when relevant.

### American Political Science Review (APSR)

**Short name:** `APSR`

**Focus.** Highest-bar general-interest political-science journal; APSA's flagship. Publishes across IR, comparative politics, American politics, formal theory, and political theory. Strongest preference for theoretically motivated work that speaks to multiple subfields.

**Bar.** "Top-3 in your subfield should know this." A clear theoretical contribution is load-bearing — purely descriptive or purely empirical papers without a theoretical home rarely clear desk.

**Domain-referee adjustments.**
- Contribution 30 → 35 (theoretical-importance bar is high)
- Lit positioning 25 → 25 (unchanged)
- Fit 10 → 5 (APSR publishes broadly across subfields; fit is rarely a binding constraint)

**Methods-referee adjustments.**
- Identification 35 → 30 (still cared about, but APSR rewards theoretical novelty even when identification is observational)
- For `formal-theory` papers: Comparative-static sharpness 25 → 30 (the theoretical contribution must produce sharp predictions)
- For `survey-experiment` papers: Sampling-frame validity is a desk-level concern; convenience samples (uncalibrated MTurk) face an uphill battle.

**Typical concerns.**
- "Where is the theoretical contribution? What would a theorist in a different subfield take from this?"
- "Is the design appropriate to the population the paper claims to speak about?"
- "Does the paper engage seriously with formal theory, or only with reduced-form empirics?"
- "Is the conclusion testable, or vacuous?"

**Referee-pool weights.**
- THEORY: 0.30
- CREDIBILITY: 0.20
- STRUCTURAL: 0.15
- MEASUREMENT: 0.15
- POLICY: 0.10
- SKEPTIC: 0.10

**Table format override.** Footnotes and citations follow APSA Style Manual; tables typically use significance stars (* p<0.05, ** p<0.01, *** p<0.001 — note 0.05 floor differs from AEA convention).

### American Journal of Political Science (AJPS)

**Short name:** `AJPS`

**Focus.** General political-science journal with strong methods orientation. AJPS is the methodologists' favourite among the top-3 — receptive to causal-inference, survey experiments, formal-empirical work, and methodological innovation alongside substantive contribution.

**Bar.** "The method is at least as interesting as the substance." Not a methods-only journal, but methodologically novel papers compete favourably with merely-clean empirical work. AJPS Replication Policy (since 2015) is enforced — replication archive is mandatory at acceptance.

**Domain-referee adjustments.**
- Contribution 30 → 30 (unchanged)
- Lit positioning 25 → 25 (unchanged)
- External validity 15 → 20 (AJPS expects engagement with whether the result generalises beyond the specific setting)

**Methods-referee adjustments.**
- Identification 35 → 40 (the credibility bar is real)
- Inference 20 → 20 (unchanged)
- For `survey-experiment` papers: Manipulation checks and balance tables are mandatory in the manuscript; absence is a desk-level concern.
- Replication 5 → 10 (AJPS replication policy)

**Typical concerns.**
- "Is identification credible to a methodologist who has read the recent econometrics literature?"
- "Is the design pre-registered? If not, why not?"
- "Are the standard errors clustered at the right level, with the right type of clustering for the design?"
- "Is the replication archive complete (data, code, README)?"
- "Does the method scale to other contexts the paper gestures at?"

**Referee-pool weights.**
- CREDIBILITY: 0.30
- MEASUREMENT: 0.20
- STRUCTURAL: 0.15
- THEORY: 0.15
- SKEPTIC: 0.10
- POLICY: 0.10

**Table format override.** APSA Style; significance stars allowed (0.05/0.01/0.001 floor); regression tables typically include observations, R², and SE-clustering specification.

### Journal of Politics (JOP)

**Short name:** `JOP`

**Focus.** Top-3 political-science journal alongside APSR and AJPS, with a slight tilt toward American politics and comparative politics. Publishes across all subfields; receptive to shorter, sharper papers ("research notes" track) alongside full articles.

**Bar.** "A clear contribution to a substantive question that political scientists care about." Lower theoretical-novelty bar than APSR; lower methods-novelty bar than AJPS — but a higher *clarity-of-contribution* bar than either. The desk asks: "what specifically does this paper teach me?"

**Domain-referee adjustments.**
- Contribution 30 → 35 (clarity of contribution is the binding constraint)
- Substance 20 → 25 (JOP rewards a tight argument over a broad one)
- Fit 10 → 5 (JOP publishes broadly)

**Methods-referee adjustments.**
- Identification 35 → 35 (unchanged)
- Robustness 15 → 20 (JOP referees frequently push back on robustness)

**Typical concerns.**
- "What specifically does this paper add that we didn't already know?"
- "Is the argument tight, or is it three loosely-related claims?"
- "Are the robustness checks responsive to obvious threats, or are they ritual?"
- "Could this be a research note (8,000 words) instead of a full article?"

**Referee-pool weights.**
- SKEPTIC: 0.25
- CREDIBILITY: 0.20
- THEORY: 0.15
- MEASUREMENT: 0.15
- STRUCTURAL: 0.15
- POLICY: 0.10

**Table format override.** APSA Style; standard significance stars allowed.

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

**Examples for fields we don't yet ship** (to be filled in by adopters — we ship econ + political-science as concrete profiles; psych / sociology / public health are template-only):

- `### Nature Human Behaviour (NHB)` — flagship interdisciplinary. Bar: broad impact + pre-registration + replication. Referee weights: MEASUREMENT high, CREDIBILITY high.
- `### Psychological Science` — flagship psych. Bar: open-science compliance + theoretical contribution. Referee weights: CREDIBILITY high, MEASUREMENT high. Preregistration expected.
- `### American Journal of Sociology (AJS)` — top sociology. Bar: theoretical contribution + careful argument. Referee weights: THEORY medium, SKEPTIC medium, MEASUREMENT medium.
- `### PNAS` — multi-disciplinary. Bar: generalizability + public interest. Referee weights: POLICY high, SKEPTIC high.

---

## Cross-references

- `.claude/agents/editor.md` — reads this file.
- `.claude/agents/domain-referee.md` — applies domain-referee adjustments.
- `.claude/agents/methods-referee.md` — applies methods-referee adjustments.
- `.claude/skills/review-paper/SKILL.md` — `--peer [journal]` mode entry point.
- `templates/journal-profile-template.md` — skeleton for adding your own.
