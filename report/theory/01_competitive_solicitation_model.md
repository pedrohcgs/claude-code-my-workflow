# A 2×2 Model of Competitive Review Solicitation

<!-- SCAFFOLD (Markdown). Skeleton derived from docs/coauthor_note_2x2_model.md.
     Not final prose. [CITE:key] resolves against Bibliography_base.bib;
     [PROP], [ASSUMPTION], [LEMMA] mark objects to be stated/proved.
     This is the analytical component (coauthor's contribution). Companion
     numerics: scripts/R/theory/. Paste polished text into Word/Docs. -->

## 0. One-paragraph summary

Two competing firms each choose how genuine reviews are collected — **solicit** (firm-prompted) or
**consumer-driven** (organic). Soliciting pulls moderate-experience customers into the corpus and so
**compresses the rating distribution toward the truth** [CITE:AskalidisKimMalthouse2017_biases;
CITE:Karaman2021_solicitation_extremity]. Because dispersion raises demand only when the average is low
[CITE:Sun2012_variance], a **high-quality** firm prefers the tight, solicited distribution while a **low-quality**
firm prefers to keep the organic spread that reads as "niche." Review strategy therefore **sorts firms by
quality** into the *asymmetric* (off-diagonal) cells. Platform policy then decides **which cells are feasible at
all**: Google permits soliciting (all four cells), Yelp forbids it (only the both-organic cell), so the two
platforms make firms play different games — and that is the model's testable prediction for the field comparison.

## 1. Setup

- **Players.** Two firms $i \in \{1,2\}$, differing in an underlying type (see the quality-vs-taste choice in §5).
- **Strategies.** Each firm chooses a collection regime $s_i \in \{\text{Solicit } (A), \text{ Consumer-driven } (B)\}$.
- **The 2×2.** The strategy profiles form a matrix; the **off-diagonal cells** $(A,B)$ and $(B,A)$ — one firm
  solicits, its rival stays organic — are the **outcomes of interest** (the shaded cells in the note; *confirm the
  shading denotes exactly this*).
- **What a regime does to the rating distribution.** Soliciting draws in moderate experiences, **narrowing spread**
  and moving the mean toward true quality; consumer-driven collection leaves a **self-selected, more dispersed
  (J-shaped)** distribution [CITE:HuPavlouZhang2009_jshaped; CITE:SchoenmuellerNetzerStahl2020_polarity].
- **[ASSUMPTION A1] Solicitation compresses toward the truth.** State formally as a mean-preserving-*contraction*
  (or a shift toward true quality) of the displayed rating distribution. This is the premise inherited from the
  empirical literature, not a result to prove here.

## 2. Demand: why spread matters (the Sun 2012 mechanism)

- **[ASSUMPTION A2] Demand in (mean, spread).** Demand rises in the average rating and, **conditional on a low
  average**, rises in dispersion — a spread-out distribution reads as a niche product some consumers love
  [CITE:Sun2012_variance]. Conditional on a **high** average, dispersion does **not** help (and may hurt).
- Consumers' reading of dispersion is itself context-dependent — attributed to taste heterogeneity when tastes
  look varied [CITE:HeBond2015_dispersion] — which matters for §5(a) and §5(b).
- **[LEMMA 1] Sign of the solicitation effect on demand.** Because soliciting reduces spread, its demand effect
  flips with the average: **positive for a high-average (high-quality) firm, negative for a low-average firm.**
  (Follows from A1 + A2.)

## 3. Result: strategy sorts firms by quality

- **[PROP 1] Sorting.** Under quality differentiation (§5a), the high-quality firm strictly prefers **Solicit** and
  the low-quality firm strictly prefers **Consumer-driven**, so the unique equilibrium lands in an **off-diagonal
  cell**. *(Prove via Lemma 1: the tight distribution around a high mean dominates for the strong firm; the weak
  firm retains the niche-signaling spread.)*
- **[PROP 2] When the diagonal survives.** Characterize the parameter region where both firms solicit (both high)
  or neither does (both low / soliciting too costly — §5c), i.e. when the *symmetric* cells are the equilibrium.
- **[COROLLARY] Comparative statics.** How the sorting threshold moves with the quality gap, the demand weight on
  dispersion, and the solicitation cost. *(Numerical illustration: `scripts/R/theory/`.)*

## 4. Platform policy as a restriction on feasible cells

- **Google** permits soliciting (bans incentives + selective solicitation) → **all four cells feasible**.
- **Yelp** forbids asking → every firm is forced Consumer-driven → **only the $(B,B)$ cell exists**; the asymmetric
  outcomes cannot occur.
- **[PROP 3] Policy changes the game, not just the treatment.** On a permissive platform the equilibrium is the
  off-diagonal sorting cell (Prop 1); on a prohibitive platform it is forced to $(B,B)$. The **field prediction**:
  firms **diverge in collection strategy where permitted and cannot where forbidden** — exactly the Google-vs-Yelp
  contrast the empirical paper tests (`report/empirical/`).

## 5. Three modelling choices to settle first (the analysis branches on these)

See `MEMORY.md`. Each must be fixed *consistently* across the model.

- **(a) Quality vs. taste.** **Quality** differentiation gives the sorting story above (§3). **Taste** differentiation
  gives instead a *positioning* story (one firm broad, one niche) — different equilibrium logic and different
  comparative statics. **The model as sketched assumes quality;** state this and note the taste variant as an
  alternative.
- **(b) Do consumers adjust for collection method?** If consumers take ratings at face value
  [CITE:DeLangheFernbachLichtenstein2016_navigating_stars], soliciting is a **straight advantage** for the strong
  firm. If they **adjust**, soliciting becomes a **signal** and can **backfire** (a solicited tight distribution is
  discounted). **This assumption is what the experiment tests** (`report/experiment/`) — the seam where the
  analytical and empirical components depend on each other.
- **(c) Is soliciting costly and visible?** If a solicited distribution is **indistinguishable** from an organic one
  to consumers, there is **no signal — only a different displayed rating**, and (b) is moot. Costly/visible
  soliciting (e.g. leaving traces such as bursts of first-time reviewers) can instead support a separating
  equilibrium. Fix the cost $c \ge 0$ and a visibility parameter.

## 6. Positioning (what the model is *not*)

Each neighbour gets part of the way; the gap is a model where **competing firms choose whether to solicit genuine
reviews**, that choice **changes the shape** of the distribution (not what reviews *say*), consumers infer quality
from shape, and **platform policy** decides whether firms may diverge:

- [CITE:Dellarocas2006_manipulation] — competition, but the lever is **fake content**, not genuine solicitation.
- [CITE:HuangGuoWang2026_reporting_bias] — reporting bias + a platform lever, but **one firm** and a **pricing**
  lever.
- [CITE:ZhangEtal2025_platform_governance] — two asymmetric firms + a platform, but **manipulation**, not
  solicitation.
- [CITE:ZhaoEtal2022_competition_quality_price] — competing firms with reviews, but levers are **price and
  quality**.
- [CITE:Sun2012_variance] supplies the reason the **asymmetric cells** can be the equilibrium rather than a
  curiosity.

## 7. What the model hands to the empirical and experimental halves

- **Empirical** (`report/empirical/`): test whether Google establishments **split** into the two strategies and
  whether the split **tracks quality** (with a quality proxy **independent** of the ratings). Solicitation leaves
  observable traces (review bursts from first-time reviewers).
- **Experimental** (`report/experiment/`): show participants two competing businesses — one with a tight,
  solicited-looking distribution, one polarized — vary the averages, and see which is chosen. This tests design
  question (b), the consumer-inference assumption the model rests on.

<!-- OPEN ITEMS (do not paste):
  - Confirm the shaded cells in the sketch are the off-diagonal (asymmetric) profiles.
  - Choose (a)/(b)/(c) before formalizing payoffs; Props 1-3 are stated for the quality + face-value + costless
    branch and must be restated if a branch changes.
  - Decide the demand primitive (A2): functional form for demand in (mean, spread) consistent with Sun (2012).
  - Numerical equilibrium + comparative statics: scripts/R/theory/. -->
