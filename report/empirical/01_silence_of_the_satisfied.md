# The Silence of the Satisfied — Platform Solicitation Policy as a Determinant of What a Rating Measures

<!-- SCAFFOLD (Markdown). Skeleton derived from docs/Silence_of_the_Satisfied_Proposal.docx
     (Draft, Aug 2026). Not final prose. [CITE:key] marks a citation resolved against
     Bibliography_base.bib. Hypotheses are the author's own, transcribed from the proposal.
     Paste polished text into Word/Docs; the repo stays the source of truth for numbers. -->

## 1. Motivation

Voluntary reviewing is a self-selected sample: unprompted distributions are J-shaped — the furious and the
delighted write, the modal customer stays silent — so a mean rating is a biased estimator of quality
[CITE:HuPavlouZhang2009_jshaped; CITE:SchoenmuellerNetzerStahl2020_polarity; CITE:BrandesGodesMayzlin2022_attrition].
The corrective is also established: soliciting reviews raises engagement among moderate-experience customers
more than extreme ones and increases representativeness [CITE:AskalidisKimMalthouse2017_biases;
CITE:Karaman2021_solicitation_extremity] (see also incentives reducing extremity, [CITE:MarinescuEtal2021_incentives_bias]).
**This paper takes both as the premise, not the claim.**

The unexamined step is *who decides whether solicitation happens at all.* The literature treats it as a firm
choice; it is more fundamentally a **platform** choice. Yelp instructs businesses never to ask; Google permits
asking (genuine experiences) while prohibiting incentives and selective solicitation of favourable reviews.
Google thus draws the sampling-vs-content line the literature draws; Yelp does not. Two consequences:
representativeness becomes a **design parameter** studiable at the institution that sets it, and **the same
establishment carries two ratings under opposing rules simultaneously** — a comparison needing no shock and no
waiting. Managerially the stakes are concentrated on independents, whose ratings are the primary quality
signal with no brand-equity substitute.

## 2. Research Question and Hypotheses

**RQ.** How much of the difference between two platforms' ratings of the same establishment is attributable to
their opposing solicitation policies, and which policy produces the better measure?

| # | Hypothesis (short) | Tier | Where |
|---|---|---|---|
| H1 | Cross-platform shape: Google less polarized than Yelp for the same establishment (more mass at 2–4★, less at 1/5★, lower within-establishment variance) | Histogram | `scripts/stata/` |
| H2 | Within-Yelp: the not-recommended pile is less polarized than the recommended pile and resembles Google — holds platform + user base fixed | Review-level | `scripts/stata/` |
| H3 | Sampling, not manipulation: the shape gap exceeds the mean gap (manipulation ⇒ level shift + fattened right tail; sampling ⇒ middle fills in, centre stable) | Histogram | `scripts/stata/` |
| H4 | Volume: shape difference larger at establishments with fewer total ratings | Histogram | `scripts/stata/` |
| H4b | Relative accuracy: Google@t predicts Yelp@t+k better than the reverse (cross-lagged prediction ranks the policies with **no external benchmark**) | Histogram (panel) | `scripts/stata/` |
| H5 | Chain status: shape difference larger for independents than chains | Histogram | `scripts/stata/` |
| H6 | Text signature of sampling: conditional on the star given, less-filtered reviews are shorter, lower arousal, less likely to report a specific incident | Review-level (LLM) | `scripts/python/classifier/` |
| H7 | Text separates the two constructs: manipulated vs solicited-but-genuine reviews are separable in text | Review-level (LLM) | `scripts/python/classifier/` |
| H8 | Filter decomposition: the excess middle mass in the Yelp not-recommended pile carries the **solicitation** signature, not the **manipulation** signature | Review-level (LLM) | `scripts/python/classifier/` |

*The consumer-response extension (do consumers treat the two ratings as equivalent?) is a **separate paper**
— design question (b) of the model; see `report/experiment/` and `MEMORY.md`.*

## 3. Data and Sample

- **Primary outcome needs no review-level collection:** both platforms publish an establishment-level
  **rating histogram** (counts per star) on the business page — the full displayed distribution, so H1/H3/H4/H5
  run from aggregates. Removes the main measurement risk (a scraper returning a non-random review subset).
- **Review-level data** (H2, H6–H8): Yelp not-recommended reviews are on a separate public page, used before
  [CITE:LucaZervas2016_fake_it].
- **Text measures:** an LLM classifier against a **hand-developed, human-validated codebook**; the
  *manipulation* and *solicitation* signatures are scored **independently** (a review may show both, neither, or
  one). Validate on a stratified human-coded sample before scaling [CITE:GilardiAlizadehKubli2023_chatgpt_annotation;
  CITE:ZiemsEtal2024_llm_css].
- **Frame:** restaurants across several US metros with open municipal licensing/inspection records (e.g. Chicago
  lists 11,076 licensed restaurants inspected since Jan 2024) supplying identity/address/category independent of
  either platform. Cross-platform match on name + street address + coordinates.
- **Collection:** Apify actors (Google Maps routine; Yelp slower / more adversarial).

## 4. Variable Construction

*(to build — see the registry in `.claude/rules/knowledge-base-template.md`)*
Distribution-shape moments (polarization, within-establishment variance, share 1/5★, middle mass 2–4★);
mean rating; total ratings (volume); chain/independent flag; review length; classifier scores (arousal,
incident specificity, manipulation signature, solicitation signature).

## 5. Identification Strategy

Within-establishment, across-corpus. With **establishment fixed effects**, actual quality, location, price, and
category difference out; the estimand is the difference in **distributional moments** between corpora produced
under different solicitation rules.

- **H1's objection** — Google and Yelp users differ — cannot be answered within H1.
- **H2 answers it:** Yelp recommended vs not-recommended share one platform and one contributor population;
  the boundary is Yelp's own filter. If the H1 gap is solicitation policy, an analogous gap appears *inside*
  Yelp; if it is user composition, it does not. **Report H2 as the primary result, not a robustness check.**
- **H3** discriminates sampling vs manipulation by reporting **shape and level separately** — that separation
  *is* the test, not descriptive thoroughness.
- **H4b** by cross-lagged prediction: regress platform-A rating (later) on platform-B rating (earlier), and the
  reverse; compare predictive accuracy. Identifying assumption: both platforms read the same establishment;
  mitigate by restricting to establishments where both draw comparable review volume relative to size.
- **Text tests run within Yelp only** — platform writing norms (Yelp rewards long narrative reviews) confound
  any cross-platform text comparison, so no cross-platform text claim is made.

## 6. Threats to Validity and Mitigation

| Threat | Mitigation |
|---|---|
| Yelp filter is not a solicitation detector (pile mixes fakes, new accounts, conflicts, solicited) | Decompose with reviewer characteristics + fraud predictors; test whether excess middle mass survives conditioning on reviewer newness — this *is* H8 |
| Platform writing norms differ | Structural: text hypotheses within Yelp only |
| Text corpus selection (review-level returns a subset) | Report corpus recovery per establishment (reviews retrieved ÷ histogram total); test across recovery deciles |
| Classifier validity | Hand codebook; human coding on a stratified sample with reported agreement before scaling; two signatures scored independently [CITE:GilardiAlizadehKubli2023_chatgpt_annotation] |
| Prior use of the same data | Position explicitly vs [CITE:LucaZervas2016_fake_it]: fraud = what reviews *say*; this = *who writes them* (different shape predictions, H3) |
| Platform user composition | H2 is the mitigation; report as primary |
| Asymmetric filtering (Google filters but doesn't publish removals) | State the limit; the Google corpus is a filtered object of unknown composition |
| Histogram vs review corpus | Report the gap between histogram total and reviews recovered |
| Matching error (multi-unit brands, renamed establishments) | Require tight-radius coordinate agreement; report independents separately |

## 7. Expected Contribution and Target Outlet

Positioned one level up from [CITE:Karaman2021_solicitation_extremity] and
[CITE:AskalidisKimMalthouse2017_biases]: the **unit is the platform**, the **treatment is policy** (not firm
behaviour), and the comparison is **contemporaneous across platforms**. Contributions: (i) two policies can be
**ranked**, not merely contrasted, via cross-lagged prediction with no external benchmark; (ii) sampling vs
content control made **observable** in text via two independently scored signatures; (iii) methodological reach —
a large empirical literature uses platform ratings as a quality proxy, and if shape is partly a collection-policy
artefact, cross-platform comparisons inherit an undocumented platform design choice.

**Target outlets:** *Journal of Marketing Research* or *Marketing Science* (measurement emphasis); *Journal of
Marketing* if the platform-policy comparison leads.

## 8. Feasibility and Next Steps

1. **Pilot (cheap, decisive):** histograms for a few hundred matched establishments in one metro — check
   histogram retrievability on both platforms, the cross-platform match rate, and whether *any* shape gap exists.
   If distributions are indistinguishable, the project ends there.
2. **Stage 2 (expensive):** only if a gap appears — review-level collection of Yelp recommended + not-recommended
   for H2 and the text hypotheses.
3. **Stage 3:** validate the classifier before scale — hand-code a stratified sample; confirm the manipulation and
   solicitation signatures are **empirically separable, not collinear**. If not, H7/H8 fail and the paper reverts
   to its distributional core, which stands alone.

<!-- OPEN ITEMS (do not paste):
  - Section 4 (Variable Construction) is a stub in the proposal — build it out.
  - External-benchmark route (OpenTable / delivery platforms) was checked and set aside;
    design deliberately needs no external benchmark (H1–H4b). Keep it out unless revisited.
  - Confirm the three unsettled model design questions the theory paper shares (MEMORY.md);
    (b) is the consumer-response extension, a separate paper. -->
