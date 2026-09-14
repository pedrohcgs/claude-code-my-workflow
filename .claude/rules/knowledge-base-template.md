---
paths:
  - "report/**/*.md"
  - "scripts/**/*.do"
  - "scripts/**/*.R"
  - "scripts/**/*.py"
---

# Project Knowledge Base: Online Review Ratings

<!-- Claude reads this before drafting/analysis. Keep it current: when a metric
     is defined, a variable is constructed, or a modeling decision is locked,
     record it here so every session uses the same definitions. -->

Metrics + decisions registry for the review-ratings project (theory 2×2 solicitation model + the
Google-vs-Yelp field comparison "The Silence of the Satisfied" + a consumer-inference experiment).
Fill in `(confirm)` / `(tbd)` cells as construction is finalized. The `domain-reviewer` agent reads this
before flagging "inconsistencies."

## Rating & Distribution-Shape Metrics Registry

| Term | Definition | Notes / how measured here |
|------|-----------|---------------------------|
| Average rating | Mean of displayed star ratings for an establishment | State whether platform-displayed or recomputed |
| Rating distribution | Histogram over {1,2,3,4,5} stars | Primary object — the paper is about *shape*, not just mean |
| Variance / spread | Dispersion of the rating distribution | Sun (2012): spread raises demand only when the average is low |
| Polarization / J-shape | Mass at the extremes (1 and 5) vs. the middle | Bimodality is the organic-review signature (self-selection) |
| Skew | Asymmetry of the distribution | |
| Share 5-star / share 1-star | Fraction at each extreme | One-star mass is especially consequential (Chevalier & Mayzlin 2006) |
| Compression toward truth | Reduction in spread when moderate reviewers are pulled in | The predicted effect of soliciting |
| Not-recommended count/share | Yelp's filtered-review pile | Selection into it is non-random (Luca & Zervas 2016) — treat with care |

## Solicitation & Platform Variables

| Variable | Meaning | Construction / notes |
|----------|---------|----------------------|
| `platform` | Google vs. Yelp | Policy differs: Google permits soliciting; Yelp forbids asking |
| `solicit_regime` | Whether soliciting is permitted | Google = all four cells feasible; Yelp = consumer-driven only |
| `solicited` (firm strategy) | Firm solicits vs. relies on organic reviews | Latent; proxied by traces (below) — validate, don't assume |
| `solicitation_trace` | Observable signature of soliciting | e.g. review bursts, first-time-reviewer share `(confirm)` |
| `quality_proxy` | Establishment quality independent of the ratings | MUST be independent of the ratings under study (else circular) `(tbd)` |
| establishment id | Matching unit across platforms | Same-establishment Google↔Yelp link `(confirm match method)` |

## LLM Text-Classifier Fields

| Field | Meaning | Construction / notes |
|-------|---------|----------------------|
| `llm_score` | LLM-assigned score of review text | Define the construct scored (sentiment? experience valence? `(confirm)`) |
| model + version | Which model, which version, which date | Time-stamp: models are non-stationary |
| prompt id | Prompt template used | Report sensitivity across phrasings |
| run/seed | Repetition + sampling settings | Characterize within-model variance |
| label (ground truth) | Human label on the hold-out | Fixed taxonomy set in advance; report inter-rater agreement |
| validation metric | Accuracy / F1 / agreement on hold-out | On the labeled hold-out, NOT training data |

## Experiment Variables (consumer inference)

| Variable | Meaning | Construction / notes |
|----------|---------|----------------------|
| distribution shape (manipulated) | Tight solicited-looking vs. polarized | Within/between `(confirm design)` |
| average rating (manipulated) | Varies the displayed mean | Crossed with shape |
| collection-method disclosure | Whether the participant is told how reviews were gathered | The lever that tests design question (b) |
| choice (outcome) | Which of two competing businesses is chosen | Maps to the model's consumer-inference assumption |
| attention / comprehension checks | Data-quality screens | Pre-register handling |

## Decisions & Assumptions Registry

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-09-14 | Repo repurposed from Influencer Marketing (Essay 2) → review-ratings project (delete-and-reset) | New project; git history retains old work. See `MEMORY.md`. |
| 2026-09-14 | Report in Word/Docs; repo holds data + analysis + Markdown drafts | Prose lives outside repo; repo is source of truth for numbers |
| 2026-09-14 | One shared `Bibliography_base.bib` (INV-5) for theory + empirical + experiment | Single canonical bibliography |
| 2026-09-14 | Stata primary (distributional statistics); R secondary (tables/figures, experiment, model numerics); Python for scraping + LLM classifier | Matches the work types; `(confirm Stata-primary)` |
| `(tbd)` | **Design question (a):** firms differ in **quality** or **taste** | Quality → sorting story; taste → positioning story. Analysis branches on this — see `MEMORY.md`. |
| `(tbd)` | **Design question (b):** whether consumers **adjust for collection method** | Settled by the experiment; the model's assumption depends on it |
| `(tbd)` | **Design question (c):** whether soliciting is **costly and visible** | If solicited ≈ organic to consumers, there is no signal, only a different displayed rating |

## Tolerance Thresholds

| Check | Tolerance |
|-------|-----------|
| Headline estimates reproduce | *(set when building replication package — `[confirm]`)* |
| Distribution-shape statistics | Report to precision claimed in text |
| p-values | Report to precision claimed; flag near-misses |
| LLM-classifier validation metrics | Report on the labeled hold-out with CIs |

## Analysis Pitfalls (log them as found)

| Pitfall | Impact | Fix |
|---------|--------|-----|
| Quality proxied by the ratings under study | Circular — "quality tracks the split" becomes tautological | Use a quality measure independent of the ratings |
| Comparing means when the claim is about shape | Misses the whole point (same mean, different spread) | Use distributional tests (KS / EMD / moment tests) |
| LLM validation on training data | Overstates classifier accuracy | Report on a held-out labeled set |
| Treating Yelp not-recommended pile as random | Filtered reviews are systematically more extreme | Model/acknowledge selection (Luca & Zervas 2016) |
| Unversioned/undated LLM elicitation | Not reproducible; models drift | Time-stamp model + version + prompt + seed |
| Selection into appearing on both platforms | Biases the same-establishment comparison | Characterize who is matched; bound the selection |

## Empirical Design Specifics — "The Silence of the Satisfied"

From `docs/Silence_of_the_Satisfied_Proposal.docx` (Draft, Aug 2026). Draft: `report/empirical/01_silence_of_the_satisfied.md`.

- **Design = platform policy as the treatment.** Yelp forbids soliciting; Google permits it (bans incentives + selective solicitation). Same establishment carries two ratings under opposing rules simultaneously. Unit of analysis = the **platform**, not the firm.
- **Two tiers.** (1) **Histograms** — establishment-level star counts, published by both platforms; cheap, complete, identical to what consumers see → H1, H3, H4, H4b, H5. (2) **Review-level** — Yelp recommended vs not-recommended (public), expensive, returns a subset → H2, H6–H8.
- **Identification.** Establishment fixed effects; estimand = difference in distributional *moments* across corpora. **H2 (within-Yelp recommended vs not-recommended) is the primary identification** — holds platform + user population fixed, answering the "different users" objection to H1. **H3** discriminates sampling vs manipulation by reporting *shape* and *level* separately (manipulation ⇒ mean shift + fat right tail; sampling ⇒ middle fills, centre stable). **H4b** = cross-lagged prediction (A@t → B@t+k vs reverse) ranks the two policies with **no external benchmark**.
- **Two text signatures, scored INDEPENDENTLY** (a review may show both/neither/one — do not force onto one scale): `manipulation_signature` (generic superlatives, marketing register, absent concrete detail, atypical fluency) and `solicitation_signature` (brevity + flat affect but retains mundane concrete detail). Plus `arousal`, `incident_specificity`, `review_length`. Condition on the star rating to isolate *who writes* from *what they scored*.
- **Classifier validation is load-bearing** (H6–H8): hand-developed codebook, human coding on a stratified sample with reported agreement before scaling; confirm the two signatures are empirically **separable, not collinear** — if not, H7/H8 fail and the paper reverts to its distributional core. Cites: [[GilardiAlizadehKubli2023_chatgpt_annotation]], [[ZiemsEtal2024_llm_css]].
- **Frame + collection.** Restaurants across US metros with open municipal licensing/inspection records (identity/address/category independent of platforms; e.g. Chicago 11,076 licensed since Jan 2024). Match on name + street + coordinates. Collection via **Apify** actors (Google routine; Yelp slower/adversarial).
- **Set aside:** external quality benchmark via OpenTable / delivery platforms (coverage too thin) — design deliberately needs none. Do not revive without a proper city-scoped check.
- **Separate paper:** the consumer-response experiment (do consumers treat the two ratings as equivalent?) = model design question (b); lives in `report/experiment/`, not this paper.
