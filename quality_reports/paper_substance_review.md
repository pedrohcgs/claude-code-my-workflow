# Substance Review: Manuscript/paper.md
**Date:** 2026-09-02
**Reviewer:** domain-reviewer agent

## Summary
- **Overall assessment:** MAJOR ISSUES
- **Total issues:** 46
- **Blocking issues (CRITICAL or MAJOR — would draw major revision):** 27
- **Non-blocking issues (MINOR):** 19

The draft is well-read and the §3a rewrite is genuinely solid. The problems are structural, and they cluster in one place: **the paper's headline theoretical contribution — the instrumentation asymmetry that explains *why* some justifications dominate — has no research question and no method that can produce it.** Trace it backwards from §5 and the chain breaks twice. Everything else is secondary to that.

---

## Lens 1: Economies of Worth Conceptual Fidelity
### Issues Found: 9

#### Issue 1.1: Green order of worth misattributed to Boltanski & Chiapello (2005)
- **Location:** §3b, sentence 1
- **Severity:** MAJOR
- **Claim in text:** "…including the market, industrial, civic, domestic, inspired, and fame orders, later extended with a green order and a project or connexionist order valuing flexibility and network position ([@boltanskiChiapello2005])."
- **Problem:** The single citation covers both extensions, but Boltanski & Chiapello introduce only the **projective city / cité par projets** (the connexionist order). The **green order** comes from Lafaye & Thévenot (1993), *Une justification écologique? Conflits dans l'aménagement de la nature*, and is developed in Thévenot, Moody & Lafaye (2000). This is the single fastest thing for an EoW referee to catch, and it sits in the sentence that establishes the paper's command of the framework.
- **Suggested fix:** Split the citation: green → Lafaye & Thévenot (1993) / Thévenot, Moody & Lafaye (2000); projective/connexionist → Boltanski & Chiapello (2005). Add both to `Bibliography_base.bib`.

#### Issue 1.2: "Compromise" inferred from individual Q-sorts is a category error
- **Location:** §5 ¶1; RQ2 (§2); §3b
- **Severity:** CRITICAL
- **Claim in text:** "…each associated with a dominant order of worth or a recognizable compromise between orders" / RQ2: "what compromises do they construct to hold these orders together?"
- **Problem:** In Boltanski & Thévenot a compromise is not an attitude held by a person. It is a **situated arrangement around a composite object or device** that several parties treat as satisfying multiple orders at once — which is exactly why §3b correctly notes it is fragile and reopenable ("the objects gathered within them continue to belong to their order of origin"). A by-person factor analysis yields the structure of individual subjectivity at one occasion. What it can show is that a factor *loads high on statements associated with two orders*. That is a viewpoint combining registers; it is not, on its own, evidence of a compromise, because the compromise's defining features — the composite object, the parties, the suspension of the dominance question in a live dispute — are unobserved. The manuscript's own §3b definition is the standard against which this fails.
- **Suggested fix:** Two options. (a) Downgrade the claim: factors that combine registers are *candidate* compromises, and the composite objects that would stabilize them are identified through post-sort interviews (which then must be specified in §4 — see Issue 2.5). (b) Keep the strong claim and add the data source that supports it, which per §6.2 is case studies of actual negotiations — i.e., move RQ2 to the follow-up study.

#### Issue 1.3: Dispute-resolution mechanisms are incomplete, and the canon is cited second-hand
- **Location:** §3b
- **Severity:** MAJOR
- **Claim in text:** "…disputes are resolved through prioritization, in which one order is ordered above the others, or through compromise…" ([@trevisanMouritsen2023])
- **Problem:** Three linked problems. First, "prioritization" is not Boltanski & Thévenot's own vocabulary; their account of dispute closure runs through **clarification within a single world** (a test settles which order governs), **local arrangement** (*arrangement local* — a private settlement that appeals to no general principle at all), **compromise**, and **relativization**. Second, the two omitted mechanisms are precisely the ones that matter here: a great many data-sharing deals are **local arrangements** — bilateral, convenient, justified to nobody — and the paper as written has no way to distinguish a local arrangement from a compromise, which will contaminate the RQ2 analysis. Third, the canonical apparatus (tests, compromise) is attributed to a 2023 secondary source rather than to Boltanski & Thévenot (2006) directly; a top-journal referee reads that as the author knowing the framework through a summary.
- **Suggested fix:** Cite B&T (2006, ch. on the critique and the compromise) for the apparatus, keeping Trevisan & Mouritsen for the accounting-domain application. Add local arrangement and relativization, and state how the analysis will distinguish a compromise from a local arrangement.

#### Issue 1.4: "Investments of form" is glossed as proof devices, losing the investment
- **Location:** §1 ¶3; §2 ¶1; §5; §6.3
- **Severity:** MAJOR
- **Claim in text:** "…investments of form, which are durable, standardized articulations, such as prices, statistics, and certifications, that make a claim about worth defensible."
- **Problem:** Thévenot's (1984) concept is an *investment*: one **sacrifices particularity to gain generality and durability over space and time**, and that sacrifice has a cost which someone must bear. The manuscript keeps the output (a stable, defensible form) and drops the economics (the cost that determines whether a form ever gets built). This matters because the cost dimension is the actual explanation the paper wants: civic and green worth are not weakly instrumented because they are less legitimate but because **nobody has paid the investment**, and §6.3's design-science proposal is literally a proposal to pay it. As written, the mechanism is a description of an asymmetry, not an explanation of it. Two smaller points: the canonical English rendering is **"investment in forms"** (Thévenot 1984, *Social Science Information* 23(1)), and the paper should note that this is distinct from the **"investment formula"** (*formule d'investissement*), one of the six axioms of a *cité* in *On Justification* — the two are easily confused and a referee will check that the author knows which is which.
- **Suggested fix:** Add one clause on the sacrifice/cost dimension in §1 or §2, and align §5/§6.3 to it — the asymmetry is then a claim about who has borne form-investment costs, which is both stronger and more falsifiable.

#### Issue 1.5: Certifications are assigned to market/industrial, contradicting the expected asymmetry
- **Location:** §5 ¶3 vs §1 ¶3, §2 ¶1
- **Severity:** MAJOR
- **Claim in text:** "…market and industrial orders to be backed by heavy-duty, standardized proof devices such as prices, key performance indicators, and certifications … whereas civic, domestic, inspired, and green orders remain comparatively weakly instrumented."
- **Problem:** Certification is the paradigm case of a **civic and green** form investment, not a market one. Fair-trade labels, organic certification, B-Corp, ISO 26000, FSC, GDPR/ISO 27701 data-protection certification — these exist *because* civic and green worth needed durable proof devices and someone built them. Carbon accounting, life-cycle assessment and ESG reporting make green worth among the most heavily instrumented orders in contemporary practice, not one of the weakest. Fame/opinion worth is likewise heavily equipped (rankings, sentiment metrics, audience analytics) and never appears in the paper's strong/weak split at all. As stated, the expected asymmetry is refuted by the paper's own list of examples.
- **Suggested fix:** Either narrow the claim to the **data-value domain specifically** — where it is plausible that market/industrial devices (price, ROI, KPI) exist and civic devices do not — and say so explicitly, or reframe from "which orders are instrumented" to "which orders are instrumented *for the data-sharing test*." The second is the stronger and more defensible claim.

#### Issue 1.6: Order coverage drifts across §3b, §5 and §6
- **Location:** §3b (8 orders listed); §5 (market, industrial, civic, domestic, inspired, green); §6.3 ("civic, domestic, connection, and green")
- **Severity:** MINOR
- **Problem:** Fame/opinion is introduced in §3b and then never applied anywhere. The connexionist order is introduced in §3b, absent from §5, and returns in §6.3 renamed "connection." §4 promises "systematic sampling across orders of worth" without saying across how many.
- **Suggested fix:** Fix the naming ("project/connexionist" throughout), state which orders the Q-set samples, and either apply fame/opinion or say why it is excluded — for data, reputational worth is not obviously irrelevant.

#### Issue 1.7: "Test" used in the technical and ordinary senses without signalling
- **Location:** §2 ("their explanatory power has not yet been tested"; "testing this mechanism"); §3b ("worth is established through tests"); §6.2 ("deploy and test justifications")
- **Severity:** MINOR
- **Problem:** §3b and §6.2 use *test* in the EoW sense (*épreuve*); §2 uses it twice in the ordinary sense, in the same paragraph that establishes the framework. In an EoW paper this reads as imprecision.
- **Suggested fix:** Reserve "test" for the technical sense; use "extended to" / "examined" in §2. Consider italicising the first technical use.

#### Issue 1.8: Illustrative viewpoint labels drift from the orders' definitions
- **Location:** §5 bullets
- **Severity:** MINOR
- **Problem:** "An inspired, innovation-oriented viewpoint" — the inspired order is grace, singularity, spontaneity, the non-measurable; *innovation* in an organizational setting maps at least as readily onto the projective/connexionist order or onto industrial efficiency. "A civic, redistributive viewpoint treating worth as inseparable from who benefits and who bears risk" — the civic order is the general will and collective solidarity; risk-bearing distribution is a defensible proxy but drifts toward a distributive-justice framing that is not quite civic worth.
- **Suggested fix:** These are illustrative, so the cost is low, but sharpen them — creative *reuse* as an end in itself is a better inspired exemplar than "innovation," which readers will hear as market/industrial.

#### Issue 1.9: §5's "blind spots" contradicts §3b's "complementary, not competing"
- **Location:** §5 ¶4 vs §3b final sentence
- **Severity:** MINOR
- **Claim in text:** "complementing institutional logics theory's blind spots ([@cloutierLangley2013])"
- **Problem:** §3b carefully positions EoW as "complementary to institutional logics theory rather than as a competing grand theory," which is the right reading of Cloutier & Langley (2013). §5 then says the study addresses institutional logics' "blind spots," which is a deficiency claim Cloutier & Langley do not make — theirs is a comparative argument about what French pragmatist sociology makes explicit that logics leaves implicit. (The phrase is also semantically odd: one *fills* a blind spot; one does not *complement* it.) See also Issue 4.6.
- **Suggested fix:** "…complementing institutional logics theory at the justification level ([@cloutierLangley2013])."

---

## Lens 2: Q-Methodology Design Soundness
### Issues Found: 8

#### Issue 2.1: §4 contains no methodological citations and no design specifications
- **Location:** §4 (entire)
- **Severity:** MAJOR
- **Problem:** The methodology section cites nothing — not Stephenson, not Brown (1980), not Watts & Stenner (2012), not Webler, Danielson & Tuler (2009), and not Zabala et al. (2018), which §2 already has in the bibliography. And the following are all unspecified and, crucially, **not flagged as to-be-specified**: factor-extraction method (centroid vs. PCA — a live methodological choice in Q, with different epistemological commitments); rotation (varimax vs. judgmental/by-hand); the criterion for the number of retained factors (eigenvalue >1, Humphrey's rule, two significant loadings, cumulative variance); the significance threshold for loadings (conventionally 2.58 × 1/√N, here 2.58/√40 ≈ 0.41); the flagging rule for defining sorts; the distribution's shape, range and kurtosis; and the software (PQMethod / KADE / the `qmethod` R package). The text reads as if the design is settled, which invites the referee to assume it is settled badly.
- **Suggested fix:** Even at abstract stage, name the extraction and rotation approach, the retention criterion, and the loading threshold — that is three sentences and it converts the section from assertion to design. Mark anything genuinely open as open.

#### Issue 2.2: Concourse construction is asserted rather than argued
- **Location:** §4, sentence 2
- **Severity:** MAJOR
- **Claim in text:** "A concourse of value statements is developed from twelve semi-structured expert interviews together with arguments found in the literature reviewed above, ensuring it spans the full range of viewpoints on data's value rather than a single researcher's assumptions."
- **Problem:** Three gaps. (a) The **concourse size is never reported** — Q convention is to report the concourse (often hundreds of statements) and the reduction logic down to the Q-set; without it the reader cannot judge the sampling. (b) The **twelve experts have no sampling frame**: what sectors, roles, seniority, relation to data-sharing decisions? Twelve is a defensible number, but adequacy is a function of *spread*, not count, and no spread is described. (c) "**Ensuring** it spans the **full range**" is a completeness claim no concourse procedure can support. A referee will circle that word.
- **Suggested fix:** Report the concourse size; give the expert-sampling rationale in one sentence (roles × organizational form); replace "ensuring it spans the full range" with a claim about broad coverage across identified dimensions, and state the saturation stopping rule.

#### Issue 2.3: A theory-structured Q-set risks confirming the theory it samples on
- **Location:** §4, sentence 3, with §5 ¶1
- **Severity:** MAJOR
- **Claim in text:** "…theoretical content analysis, to ensure systematic sampling across orders of worth and the value-creation and value-capture distinction."
- **Problem:** Structured (deductive) Q-set design is legitimate and is arguably the right choice here. But it has a known consequence the manuscript does not address: if the Q-set is constructed to sample evenly across orders of worth, then (a) finding that viewpoints organize along orders of worth is partly an artifact of the instrument, and (b) — more damagingly for §5 — the **relative prevalence of orders in participants' sorts is fixed by the Q-set's composition and cannot be read as a finding about the field**. §5's hedge ("this alignment is anticipated rather than assumed in advance") acknowledges the risk in words but is undercut by the design in §4.
- **Suggested fix:** Say explicitly what would count as *disconfirmation* — e.g. factors that cut across the theoretical cells, or statements that load in ways the structured design did not predict. That converts the hedge into a stated falsification condition. And state that the concourse's interview half provides statements not generated from the framework, so the design is not purely deductive.

#### Issue 2.4: The P-set's structural variation is stated but not justified
- **Location:** §4, sentence 4
- **Severity:** MAJOR
- **Claim in text:** "…a purposively heterogeneous P-set of thirty participants, drawn roughly two-thirds from hybrid and social-economy organizations and one-third from commercial organizations, so the sample varies deliberately along mission and organizational form."
- **Problem:** **To be clear, I am not flagging N = 30 as underpowered** — for a 40-statement Q-set that is a conventional and appropriate P-set, and the statement-to-participant ratio is fine. The problem is *which* heterogeneity. The paper varies on organizational form only, and gives no argument that organizational form is the dominant source of viewpoint variance on data value. **Role/function is at least as plausible a differentiator** — a data scientist, a CEO, a DPO/legal counsel, a fundraiser and a beneficiary-facing programme lead within the *same* hybrid organization will very likely occupy different orders of worth, and if the P-set does not sample roles, those viewpoints are structurally invisible. Nor is the 2:1 ratio justified against 1:1. Also unstated: prior data-sharing experience, sector, and organization size.
- **Suggested fix:** Add a second sampling dimension (role/function) and present the P-set as a matrix — form × role. Justify 2:1 explicitly (presumably: hybrids are the focal population, commercial actors are the contrast group).

#### Issue 2.5: The source of the qualitative triangulation data is ambiguous
- **Location:** §4, final sentence
- **Severity:** MAJOR
- **Claim in text:** "…each interpreted through its most significant statements, participant characteristics, and supporting qualitative interview data."
- **Problem:** *Whose* interview data? The only interviews described are the **twelve expert interviews used to build the concourse**. If those are the qualitative source, they cannot illuminate the thirty sorters' factor positions — different people, different purpose. If **post-sort interviews with the P-set** are intended (which is standard and strongly advisable), they are nowhere described. This is not a bookkeeping gap: post-sort interviews are the only realistic route to answering RQ2 about compromise construction (Issue 1.2, Issue 4.3), so the missing procedure is load-bearing. Overlap between the twelve experts and the thirty sorters is also undeclared.
- **Suggested fix:** State that each participant completes a post-sort interview (on the extreme placements at minimum), and declare any overlap between the interview and P-set samples.

#### Issue 2.6: The forced-distribution rationale is asserted, and slightly overstated
- **Location:** §4, sentence 5
- **Severity:** MINOR
- **Claim in text:** "…a procedure that sharpens critical engagement and reduces the tendency toward neutral responses common in conventional surveys."
- **Problem:** This is the conventional defence and it is broadly right, but it is uncited, and the Q literature's own finding (Block 1956; Brown 1980) is that forced versus free distributions make **little difference to the resulting factor structure** — the standard justification is pragmatic (comparability across sorts, forcing engagement with the whole set), not that forced sorting yields better data. Asserting the stronger version invites a referee who knows the literature to push back.
- **Suggested fix:** Cite Brown (1980) or Watts & Stenner (2012) and state the pragmatic rationale (comparability + engagement), then specify the grid shape and range.

#### Issue 2.7: "Comprehensiveness" is a concourse property; piloting tests comprehensibility
- **Location:** §4, sentence 3
- **Severity:** MINOR
- **Claim in text:** "…through empirical piloting, to test comprehensiveness and clarity"
- **Problem:** Piloting a Q-set with participants tests whether statements are **comprehensible**, unambiguous, non-double-barrelled and balanced. **Comprehensiveness** (coverage) is a property of the concourse-to-Q-set reduction and is normally checked differently — by asking pilot participants whether anything important is missing, or by a residual/catch-all category. If "comprehensiveness" is meant, the procedure that establishes it is missing; if it is a slip for "comprehensibility," it should be corrected.
- **Suggested fix:** Clarify which is meant, and if coverage is intended, name the procedure.

#### Issue 2.8: Q terminology is inconsistent within §5
- **Location:** §5 ¶2 vs §4 final sentence
- **Severity:** MINOR
- **Claim in text:** "results are to derive consensus and divisive statements" (§5) vs. "statements that sharply distinguish one viewpoint from another" (§4)
- **Problem:** The technical terms are **consensus statements** and **distinguishing statements**. "Divisive statements" is not standard, and §4 already uses the right concept in longhand. Similarly, "most significant statements" (§4) is loose — the standard terms are characterizing statements / highest- and lowest-ranked z-scores. (Also in the same §5 sentence: "various orders **or** worth" should be "of worth.")
- **Suggested fix:** Standardize on consensus / distinguishing statements throughout.

---

## Lens 3: Citation Fidelity
### Issues Found: 16

**Citekey resolution — clean.** All 32 `[@citekey]` references in the manuscript resolve to entries in `Bibliography_base.bib`, and every `.bib` entry is cited at least once. No orphans in either direction. Per instruction, stub status (`TODO: verify`) is not itself flagged below; what *is* flagged is a specific factual claim resting on a stub that reads as mismatched or internally inconsistent.

#### Issue 3.2: §3a's opening citation pair does not support the "social organizations" clause
- **Location:** §3a, sentence 1
- **Severity:** MAJOR
- **Claim in text:** "…from economic and computational approaches to data's application within business organizations, and, more recently, to its role in supporting social organizations ([@coyleManley2024]; [@kvalvik2026])."
- **Problem:** Coyle & Manley (2024) is a review of empirical valuation *methods*; Kvalvik et al. (2026) is on data's economic traits and monetization. Neither is about data's role in supporting **social organizations** — which is the clause that motivates the entire paper's hybrid-organization focus. This is newly rewritten, newly verified text in which the verified sources are cited for something they do not say.
- **Suggested fix:** Either cite a source that does support the social-organizations claim, or drop the clause and let §1's hybrid-organization motivation carry it.

#### Issue 3.3: Coyle & Manley subsumed under a cost-based generalization by the sentence's own syntax
- **Location:** §3a
- **Severity:** MAJOR
- **Claim in text:** "Much of this literature concentrates on the properties that make data monetizable … treating data's value as approximating its costs of production and maintenance: Coyle and Manley's [-@coyleManley2024] review divides existing practice into cost-based, income-based, and market-based methods and finds no consensus…"
- **Problem:** The colon makes Coyle & Manley an *instance* of "treating data's value as approximating its costs of production and maintenance." Their review covers three families, of which cost-based is one, and they are notably **critical** of cost-based approaches — the whole point of the review is that no single family is adequate. The summary of the review (per your own verification, C9) is accurate; the sentence that frames it is not. This is a construction error that produces a misattribution.
- **Suggested fix:** Break the sentence. State the cost-approximation tendency separately, then introduce Coyle & Manley as the review that *maps and critiques* the three families.

#### Issue 3.6: §3a's organizing distinction is uncited
- **Location:** §3a, sentence 2
- **Severity:** MAJOR
- **Claim in text:** "A recurring distinction within this literature separates data's intrinsic value from its usage value, the latter more heavily represented…"
- **Problem:** This is the claim that organizes the entire subsection into its two strands, and it carries a quantitative sub-claim ("more heavily represented") — both uncited. It is also not obviously the same distinction as Castro Fernandez's data/documents split, onto which the next sentence maps it: his "objective value proportional to representational precision" is not what the data-asset literature means by "intrinsic value."
- **Suggested fix:** Cite the distinction (Mohan et al. 2026 or Kvalvik et al. 2026 likely carry it), drop or support "more heavily represented," and either argue the mapping onto Castro Fernandez explicitly or keep the two distinctions separate.

#### Issue 3.7: "For the first time" overstates the 2025 SNA asset-boundary change
- **Location:** §1 ¶1; §3a (repeated)
- **Severity:** MAJOR
- **Claim in text:** "In 2025, the System of National Accounts brought data into the asset boundary for the first time" / "…bringing data into the asset boundary for the first time"
- **Problem:** **Databases** have been inside the SNA asset boundary since the 1993/2008 revisions, as intellectual property products (software and databases). What the 2025 revision does is recognize **data as an asset distinct from the database that holds it**. As written, the claim is wrong to any reader from national accounts or the economics-of-data literature, and it appears twice — once in the paper's opening paragraph, where it carries the "even the statisticians only just got here" rhetorical move. (Note that the underlying framing is right; only the "first time" is not.)
- **Suggested fix:** "…recognized data itself, as distinct from the databases that store it, as a produced asset for the first time." Also worth noting that the claim rests on two stub entries (`sna2025`, `eurostat2025`) and is doing real argumentative work in §1 — it should be near the top of the verification queue.

#### Issue 3.8: The Spiekermann & Korunovska gloss reads as a mismatch
- **Location:** §1 ¶1
- **Severity:** MAJOR (verification-dependent)
- **Claim in text:** "…and a smaller set of attempts to build stakeholder consultation and dimensional character into the value construct itself ([@spiekermannKorunovska2017])."
- **Problem:** The obvious referent is Spiekermann & Korunovska, "Towards a value theory for personal data" (*Journal of Information Technology*, 2017), which is an empirical study of **how individuals value their own personal data** (willingness-to-accept, endowment effects, the instability of personal-data valuations). "Stakeholder consultation and dimensional character built into the value construct" does not describe that paper — it describes something closer to a multi-stakeholder valuation-framework paper. This is exactly the plausible-sounding-paraphrase pattern: the sentence would be true of *some* paper, and I do not believe it is true of this one.
- **Suggested fix:** Verify against the source. If the referent is the personal-data value-theory paper, either rewrite the gloss (individuals' own valuations of personal data are unstable and context-dependent — which actually supports the paper's thesis *better*) or find the source that matches the current claim.

#### Issue 3.9: Badewitz (2020) credited with the per-datapoint contribution method
- **Location:** §1 ¶1
- **Severity:** MAJOR (verification-dependent)
- **Claim in text:** "…computational approaches that estimate the contribution of individual data points to a model's performance ([@badewitz2020])."
- **Problem:** That description is a near-exact statement of the **Data Shapley** line of work (Ghorbani & Zou 2019; Jia et al. 2019), which is the canonical citation for it. Whether Badewitz (2020) makes that contribution or surveys it is unclear from the stub, and the `.bib` note flags an uncertain author list. Citing a peripheral source for a canonical method is a standard referee objection.
- **Suggested fix:** Verify; if Badewitz (2020) is a survey or an adjacent contribution, cite the canonical source for the method and Badewitz alongside.

#### Issue 3.10: Nienstedt & Trenz used inconsistently across §1 and §3c
- **Location:** §1 ¶4 vs §3c
- **Severity:** MAJOR
- **Claim in text:** §1: "Nienstedt and Trenz [-@nienstedtTrenz2025] similarly note that **little is known about** what determines an organization's capacity to create value from shared data and what ensures its effective appropriation." §3c: "Nienstedt and Trenz **extend this by showing** the capacity to create value and the strategies actors use to appropriate it are interdependent…"
- **Problem:** The same source is credited in §1 with identifying X as unknown and in §3c with having shown X. Both can be true of a paper that opens with a gap and then addresses it, but as written the two characterizations are inconsistent, and §1's version is what carries the paper's gap claim. If the source *shows* creation-appropriation interdependence, then §1 cannot cite it as evidence that little is known.
- **Suggested fix:** Reconcile. If they both identify and address the gap, say so in §1 ("…identify, and begin to address…"), and adjust the gap claim in §2 accordingly.

#### Issue 3.17: Novelty-by-absence claims are undocumented and internally strained
- **Location:** §2 ¶1
- **Severity:** MAJOR
- **Claim in text:** "Neither the framework nor testing this mechanism has yet been applied to data value." / "…but not yet combined with economies of worth as an analytical lens." / §2 ¶4: "no study has produced an actor-grounded account… and none has examined why…"
- **Problem:** Three absolute absence claims with no search protocol behind them — always the most attacked sentences in a gap section. Worse, the first is in visible tension with the sentence immediately before it, which cites **Sharon (2018)** on orders of worth in digital health and **Siffels (2020)** on a contact-tracing-app justification analysis — both are EoW applied to data-intensive controversies. The paper needs to draw the line it is relying on (EoW applied to data *politics/ethics* vs. EoW applied to data *value and its capture*) rather than leaving the reader to notice the tension. Q methodology has also been used extensively on plural and shared values in environmental valuation, some of it adjacent to justification theory, so "not yet combined" needs at least a stated search.
- **Suggested fix:** Draw the boundary explicitly in one sentence ("these apply the framework to the legitimacy of data *practices*; none addresses how data's *value* is justified or how the resulting value is captured"), and either document the search or soften to "we are not aware of."

#### Issue 3.4: Xu et al. (2024) glossed with an empirical-validation claim
- **Location:** §3a
- **Severity:** MINOR
- **Claim in text:** "Xu, Indulska, Asadi Someh, and Shanks [-@xuEtAl2024] **formalize** the resulting plurality directly, distinguishing four roles data can play… each generating value along a different, **empirically distinguishable** pathway."
- **Problem:** Your own verification record (C11/C6) says "each with a distinct value-creation pathway" — a conceptual typology. "Formalize" and "empirically distinguishable" both upgrade that: the first implies formalization, the second implies the pathways have been empirically separated. This gloss drift was introduced in the rewrite, past what the verification pass confirmed.
- **Suggested fix:** "…distinguishing four roles data can play …, each associated with a distinct value-creation pathway."

#### Issue 3.5: Kvalvik et al. review type and the non-excludability claim
- **Location:** §3a
- **Severity:** MINOR
- **Claim in text:** "…a **systematic review** of the economic traits that set data apart from conventional commodities — non-rivalry, non-excludability, and scalability."
- **Problem:** Two small things. (a) Your verification record describes it as a **multivocal** literature review (64 of 850 screened), which is a different and specifically-named method. (b) **Non-excludability** as a defining trait of data is contestable and is presented here without qualification — data is frequently highly *excludable* through technical access control and contract, which is precisely what makes data markets possible; the standard economists' formulation is non-rival *but* excludable. Reporting the source faithfully is fine, but an IS or economics referee will expect the tension acknowledged, especially since the paper's whole value-capture argument presupposes that access can be controlled.
- **Suggested fix:** "multivocal review"; and add a half-clause noting that excludability is contested and is achieved in practice through technical and contractual means — which incidentally strengthens §3c.

#### Issue 3.11: The Ammann & Hess claim inflates across three restatements
- **Location:** §1 ¶4 → §2 ¶3 → §5 ¶4
- **Severity:** MINOR
- **Claim in text:** §1: "value-capture principles **which need not be monetary**" → §2: "the **fairer**, and not necessarily only monetary value capture principles" → §5: "the **fair**, not-necessarily-monetary value-capture principles"
- **Problem:** A fairness/normative dimension appears in §2 and §5 that §1's own characterization of the source does not contain. Classic citation drift: each restatement is slightly stronger than the last, and the strongest version is the one in the contributions paragraph.
- **Suggested fix:** Fix the characterization once and reuse it verbatim; if the source does call for fairness, say so in §1.

#### Issue 3.12: Fourcade (2011) listed as an application of economies of worth
- **Location:** §2 ¶1
- **Severity:** MINOR
- **Claim in text:** "For instance, Fourcade [-@fourcade2011] on competing valuation regimes for environmental damage…"
- **Problem:** The description is accurate to Fourcade's comparison of monetary valuation of nature across the Amoco Cadiz and Exxon Valdez cases. But the sentence frames the list as applications of *economies of worth*, and Fourcade's paper is economic sociology of valuation broadly, not an orders-of-worth analysis — unlike Sharon (2018) and Siffels (2020), which explicitly are. She is the odd one out in a list of three.
- **Suggested fix:** Either move Fourcade to a separate clause on the wider valuation-studies literature, or replace her with a genuine EoW application (the Thévenot/Lafaye environmental-justification work would double as the fix for Issue 1.1).

#### Issue 3.13: Grönroos rendered as "only facilitate," dropping half his argument
- **Location:** §3a
- **Severity:** MINOR
- **Claim in text:** "Grönroos [-@gronroos2011] sharpens the claim further: firms do not create value directly but **only** facilitate it…"
- **Problem:** Grönroos's position is that firms are value *facilitators* through goods and services **but become co-creators when they engage in direct interactions with customers** — that second half is the substance of his critique of Vargo & Lusch. "Only facilitate" states the first half as the whole.
- **Suggested fix:** Add the direct-interaction clause; it is one phrase and it makes the citation accurate.

#### Issue 3.14: Alaimo, Kallinikos & Aaltonen — entry type and attribution to verify
- **Location:** §1 ¶2; `.bib` entry
- **Severity:** MINOR
- **Problem:** The likely referent, "Data and Value," is a **book chapter** (in the *Handbook of Digital Innovation*, Edward Elgar), typed `@article` in the `.bib`. Separately, this author group has several adjacent papers ("Managing by Data," *Organization Studies* 2021; "The Making of Data Commodities," *JMIS* 2021), and the specific claim in §1 about collection/structuring/analysis as the value-conferring processes may belong to one of the others. Worth checking that the argument is attributed to the right item in the set.
- **Suggested fix:** Verify the specific item and correct the entry type to `@incollection`.

#### Issue 3.15: Bowman & Ambrosini's "total value" pie
- **Location:** §3c
- **Severity:** MINOR
- **Claim in text:** "value creation enlarges the total value available in an exchange, while value capture, or appropriation, determines who gets what share of it, a division they locate in the bargaining power between the parties involved."
- **Problem:** The bargaining half is accurate. The first half imports a single-currency "total value pie" that Bowman & Ambrosini are careful about: their apparatus is **use value** (subjective, judged by the user) versus **exchange value** (the monetary amount realized), and new use value is created by organizational members' labour. Their point is partly that these are *not* commensurable, which is — notably — the same point the present paper is making, and a missed alliance.
- **Suggested fix:** Use their own use-value/exchange-value vocabulary. It links directly to Castro Fernandez's task-dependent document value (§3a) and to the paper's plural-worth thesis, at no argumentative cost.

#### Issue 3.16: Canonical EoW apparatus carried by a 2023 secondary source
- **Location:** §3b
- **Severity:** MINOR
- **Problem:** See Issue 1.3. Recorded separately here because it is a citation-practice issue in its own right: tests, compromise and the fragility of compromises should be cited to Boltanski & Thévenot (2006) with page references, with Trevisan & Mouritsen (2023) as the domain application.

---

## Lens 4: Argument & Construct Alignment
### Issues Found: 8

#### Issue 4.1: §3c claims the RQs are organized around creation/capture; the RQs are not
- **Location:** §3c final sentence vs. RQ1 and RQ2 (§2)
- **Severity:** CRITICAL
- **Claim in text:** §3c: "…it supplies the precise empirical dyad, creation and capture, around which **the paper's research questions and Q-set are organized**." RQ1: "What distinct viewpoints on data value can be identified among these actors, and which orders of worth, or compromises between orders, characterize each?" RQ2: "When actors' justifications draw on conflicting orders of worth, what compromises do they construct to hold these orders together?"
- **Problem:** Neither sub-RQ mentions value creation or value capture. The dyad appears only in a tail clause of the main RQ ("over value capture and distribution"), and value *creation* appears nowhere in any RQ at all. So §3c makes a factual claim about the paper's own structure that the paper contradicts one section earlier. The consequence is not cosmetic: **§5's most concrete expected finding — consensus concentrating on value-creation statements, divergence concentrating on value-capture statements — has no research question that asks for it.** A third conceptual pillar is thereby justified by a role it does not play in the question structure.
- **Suggested fix:** Add a sub-RQ: "On which aspects of data value do viewpoints converge, and on which do they diverge — and how does that convergence map onto the creation/capture distinction?" That single addition rescues the pillar, the expected finding, and §3c's claim simultaneously.

#### Issue 4.2: The instrumentation-asymmetry finding cannot be produced by by-person factor analysis
- **Location:** §5 ¶3 and ¶4, against §4
- **Severity:** CRITICAL
- **Claim in text:** "A second expected finding is an asymmetry of investments of form. This means market and industrial orders to be backed by heavy-duty, standardized proof devices … whereas civic, domestic, inspired, and green orders remain comparatively weakly instrumented … leaving actors who invoke them at a structural disadvantage." And: "explains, through the instrumentation-asymmetry finding, not merely that justifications differ but **why** some come to dominate data-value disputes."
- **Problem:** This is the paper's headline theoretical contribution and **the stated method cannot yield it.** A Q-sort tells you how a person ranks 40 statements. It does not tell you which orders of worth are backed by more developed proof devices in the field, because proof devices are not the object of measurement — they are documents, metrics, standards, contracts, certification schemes, accounting conventions. Establishing an instrumentation asymmetry requires evidence *about the devices*: a device inventory, document analysis of actual data-sharing agreements, or interviews about what evidence actors bring to a negotiation. The strongest thing Q could deliver is that participants *report* market claims as easier to defend — and only if statements to that effect are deliberately in the Q-set, in which case the finding is about **perceived defensibility**, not about form investment. Compounding this: because the Q-set is balanced across orders by design (Issue 2.3), the relative prominence of market/industrial statements in the sorts is partly an artifact of the instrument and cannot be read as evidence of field-level dominance.
- **Suggested fix:** Choose one. (a) **Add the data source** — a small documentary component (what proof devices appear in the participating organizations' data-sharing agreements, impact reports, dashboards), which is modest work and makes the claim genuinely defensible. (b) **Restate the finding at the level Q can support**: "participants perceive market and industrial justifications as more readily defensible," derived from named statements in the Q-set, with the field-level asymmetry offered as an interpretation rather than a finding. Option (b) costs nothing and is honest; option (a) is what makes it the contribution the paper wants it to be.

#### Issue 4.3: RQ2 asks a process question a single-occasion Q study cannot answer
- **Location:** RQ2 (§2) against §4 and §6.2
- **Severity:** CRITICAL
- **Claim in text:** "When actors' justifications draw on conflicting orders of worth, what compromises do they **construct** to hold these orders together?"
- **Problem:** "Construct," "when justifications come into dispute" — these are process and interaction predicates. A Q study observes a ranking at one moment, by one person, outside any dispute. It cannot observe construction, and it cannot observe a dispute. The manuscript itself names the design that could: §6.2 proposes "case studies of real data-sharing negotiations, examining how actors deploy and test justifications from different orders **in interaction**." So the paper's own future-research section contains the method for its own RQ2. (See also Issue 1.2 — the conceptual half of the same problem. Note in passing that RQ2's parent sentence is also ungrammatical: "and how **they construct**" should be "and how **do they construct**.")
- **Suggested fix:** Rewrite RQ2 to what Q can answer — e.g. "Which viewpoints combine orders that are conventionally in tension, and what do participants invoke to hold them together?" — with the construction-in-interaction question explicitly handed to the follow-up study. The paper loses nothing; it gains a defensible scope.

#### Issue 4.4: Population/construct mismatch between the title, the RQs, and the P-set
- **Location:** Title, §2 RQs, §4 P-set
- **Severity:** MAJOR
- **Problem:** The title and both RQs are about **hybrid-organization actors**. The P-set is one-third **commercial** organizations, and the other two-thirds are "hybrid **and social-economy** organizations" — which conflates two non-identical categories, since social-economy organizations (co-operatives, mutuals, associations) are not automatically hybrids in Battilana & Lee's sense of combining commercial and social-welfare logics in a single organizing form. So the study's data include a substantial population the RQs do not ask about, and the focal category is itself blurred. §2 does gesture at this ("Hybrid organizations **and their commercial data-sharing counterparts**"), but that framing never reaches the title, the RQs, or the definition in §1.
- **Suggested fix:** Decide and propagate. Either the study is about actors in data-sharing across hybrid *and* commercial organizations (adjust title and RQs, and justify the commercial third as a contrast group in §4), or the commercial third is explicitly a comparison sample and the RQs say so. Also separate "hybrid" from "social-economy" in the sampling frame, or state that the study treats social-economy organizations as hybrids and why.

#### Issue 4.5: The Nabben contribution claim does not follow from the method
- **Location:** §5 ¶4
- **Severity:** MAJOR
- **Claim in text:** "…turns Nabben's [-@nabben2025] **relational** concept of value into an empirically derived typology"
- **Problem:** Per §1, Nabben's claim is that value is **co-produced through socio-technical relationships mediated by infrastructures**. A by-person factor analysis produces a typology of **individual subjectivities** — it measures persons, not relations, and no infrastructure is observed anywhere in the design. Converting a relational concept into a typology of individual viewpoints is not an operationalization of it; it is a substitution of a different unit of analysis. (The claim also rests on a stub source, so the characterization of Nabben's position is itself unverified.)
- **Suggested fix:** Either drop this contribution claim, or restate it at the right level: the study identifies the *justificatory repertoires* actors bring to socio-technically mediated data relations, complementing rather than operationalizing a relational account.

#### Issue 4.6: The §5 contributions sentence is broken, and the break conceals a logic gap
- **Location:** §5 ¶4
- **Severity:** MAJOR
- **Claim in text:** "**Theoretically**, the study operationalizes the microfoundations of value empirically, complementing institutional logics theory's blind spots ([@cloutierLangley2013]) turns Nabben's [-@nabben2025] relational concept of value into an empirically derived typology, and explains, through the instrumentation-asymmetry finding, not merely that justifications differ but why some come to dominate data-value disputes."
- **Problem:** **Confirmed — this is a real error, and it is more than punctuation.** Grammatically, the sentence attempts three coordinated predicates but the second is a participle ("complementing") spliced directly onto a finite verb ("turns") with no comma and no conjunction. Adding a comma does *not* fix it; the participle must become a finite verb: "the study **operationalizes** …, **complements** …, **turns** …, **and explains** …". Three further problems the broken syntax masks: (a) "complementing institutional logics theory's **blind spots**" is semantically incoherent — one fills or addresses a blind spot, one complements a theory — and it contradicts §3b's "complementary rather than competing" framing (Issue 1.9); (b) the three claims are an **unconnected list, not an argument** — nothing explains how operationalizing microfoundations relates to the Nabben typology or to the dominance explanation, so the reader gets three assertions in a row; (c) **the second and third items are the two least supported claims in the paper** (Issues 4.5 and 4.2 respectively), and the run-on hurries the reader past exactly the two places where they should slow down. So yes: a punctuation gap sitting on top of a logic gap.
- **Suggested fix:** Break into three sentences, one per contribution, each stating what produces it. That forces the question "what produces the instrumentation-asymmetry finding?" to be answered — which is the point.

#### Issue 4.7: Creation/capture enters at the main RQ before it is defined
- **Location:** §2 main RQ (line 23) vs §3c (line 46)
- **Severity:** MINOR
- **Problem:** The main RQ turns on "value capture and distribution," but the creation/capture distinction is not introduced until §3c, one section later. §1 and §2 use informal proxies ("recognized and distributed," "create and distribute value") without naming the construct.
- **Suggested fix:** One clause in §1 ¶4 introducing the distinction with Bowman & Ambrosini, so the RQ lands on defined terms.

#### Issue 4.8: The why-Q justification is adequate for the DCE alternative, thin for the case-study alternative
- **Location:** §2 ¶2, §4 sentence 1, §6
- **Severity:** MINOR
- **Problem:** The paper does give a real answer, not just a novelty claim — Q "is built for surfacing shared subjectivity rather than testing predefined hypotheses" (§4) and gives orders of worth "an empirically operationalized, factor-analytic counterpart" (§2). And §6.1 justifies the sequencing against a survey/DCE well: the Q typology supplies the input set the DCE needs. But the case-study alternative is not answered, and it is the harder objection, because EoW is a sociology of *situated* disputes — a referee will ask why one would surface justifications outside the situations in which they are actually deployed. §6.2 concedes the point by scheduling the case studies later.
- **Suggested fix:** One sentence: Q establishes the population of viewpoints and their prevalence structure, which a small-N case study cannot; the case studies then examine how those viewpoints are deployed in interaction. That is a genuine and defensible division of labour — it just needs saying.

---

## Lens 5: Backward Logic Check
### Issues Found: 5 (plus one clean trace and one observation)

#### Issue 5.1: The gap's second half has no RQ and no method — the full chain break
- **Location:** §2 ¶4 → RQs → §4 → §5 ¶3
- **Severity:** CRITICAL (restatement of 4.1/4.2/4.3 as a backward trace — the same defect, reported here because the backward read is what makes it visible)
- **Problem:** §2 states a twofold gap: "(i) no study has produced an actor-grounded account of the specific orders of worth hybrid-organization actors invoke … and (ii) **none has examined why some of these justifications come to dominate in practice.**" Tracing forward:
  - Gap (i) → **RQ1** → §4 by-person factor analysis → §5 named viewpoints. **This chain is intact and sound.**
  - Gap (ii) → **no RQ exists.** RQ2 asks about *compromise*, which is a different EoW mechanism from *dominance* — a compromise is precisely the case where dominance is *not* settled. So the second half of the stated gap is orphaned at the question stage.
  - Gap (ii) → §5's instrumentation-asymmetry finding → **no methodological step produces it** (Issue 4.2).
  - §6.3's design-science line depends entirely on the asymmetry finding, so the future-research programme inherits the break.

  Read backwards, the paper's most distinctive claim — the "why," not just the "that" — is asserted in the gap, promised in the results, extended in the future work, and supported nowhere.
- **Suggested fix:** Either add the RQ and the data source that close the chain (Issue 4.2 option a), or restate gap (ii) and the corresponding expected finding at the level the design supports (option b). Do not leave the gap statement stronger than the design.

#### Issue 5.2: §2 treats §1's conjecture as established literature
- **Location:** §2 ¶1 sentence 1, against §1 ¶4
- **Severity:** MAJOR
- **Claim in text:** §2: "The literature above establishes that data's value is plural and contested, **and that this plurality carries real costs when organizations try to create and distribute value from data**."
- **Problem:** The first half is genuinely established by §1 (Alaimo et al., Nabben, WEF, Castro Fernandez). The second half is not: §1's corresponding sentence is the authors' own conjecture, and it is correctly hedged as such — "mission-oriented considerations **risk** being systematically outcompeted … **for lack of** comparably robust terms." No cited source in §1 demonstrates that cost. §2 then re-describes the conjecture as something "the literature above establishes." That is an assertion laundered into a premise, and it is load-bearing, because the practical motivation for the whole study rests on it.
- **Suggested fix:** Either cite evidence for the cost (Ammann & Hess on contested capture may partly do it) or keep the honest framing: "…and suggests, though it has not shown, that this plurality carries costs…". The second is perfectly adequate motivation for an exploratory study and is safer under review.

#### Issue 5.3: Circularity risk — the Q-set is built from the framework it will confirm
- **Location:** §4 sentence 3 → §5 ¶1
- **Severity:** MAJOR (cross-references Issue 2.3)
- **Problem:** Working backwards from "each associated with a dominant order of worth or a recognizable compromise between orders": that association is possible because the Q-set was constructed by "systematic sampling across orders of worth." The finding is therefore partly guaranteed by the instrument. §5's hedge ("this alignment is anticipated rather than assumed in advance") shows awareness but does not defuse it, because the design in §4 does assume it.
- **Suggested fix:** State the disconfirmation condition (Issue 2.3). A factor that cuts across the theoretical cells, or a viewpoint organized around something other than orders of worth, would be a real finding — say so in advance, and the circularity becomes a testable design rather than a trap.
- **On the other candidate circularity:** the "value is plural, therefore use a framework about plurality, whose findings show value is plural" loop is *not* committed here. §1 establishes plurality from independent sources before EoW is introduced, and §5 does not cite the study's plural results back as evidence for EoW. Worth guarding against in the eventual discussion section, not a present defect.

#### Issue 5.5: §1 and §3a duplicate the Castro Fernandez exposition
- **Location:** §1 ¶3 and §3a
- **Severity:** MINOR
- **Problem:** The data/documents distinction, the objective/subjective split, and the "leaves the use-dependent side undeveloped" move all appear twice in near-identical terms. In a short paper this is noticeable.
- **Suggested fix:** State it once in §3a and have §1 gesture forward, or keep §1's short version and have §3a add only what is new (the mapping onto the two strands).

#### Issue 5.6: The "rigour" parallel with Castro Fernandez is overstated
- **Location:** §1 ¶3; §3a final sentence
- **Severity:** MINOR
- **Claim in text:** "What remains missing is a vocabulary rigorous enough to hold that judgment to the **same standard** he applies to data's objective value."
- **Problem:** Castro Fernandez's treatment of objective value is formal and quantitative (value proportional to representational precision). Economies of worth is a rigorous *analytical grammar*, not a measurement apparatus, and it will never hold subjective use-value to that standard — nor should it. Promising the "same standard" sets up an expectation the paper cannot meet and that a data-science-adjacent reader will hold it to.
- **Suggested fix:** "…a vocabulary **disciplined** enough to give that judgment articulable, defensible structure" — the claim the paper actually delivers on.

#### Trace confirmations and one observation (not issues)
- **§6.1 traces cleanly:** discrete choice experiment ← §5 typology ← §4 by-person factor analysis. The typology genuinely is the input set a DCE needs, and this is the strongest link in the paper.
- **RQ1 traces cleanly:** RQ1 ← gap (i) ← §1's plurality literature. Intact.
- **§3a is no longer the weak link.** The brief anticipated a WIP §3a breaking the chain for a reader skipping it; after today's rewrite, §3a is the **most complete and best-sourced section in the manuscript**, and the §1→§3a→§3b bridge ("what remains missing is a vocabulary…") is a clean handoff. **The incompleteness has migrated to §4**, which now carries the most argumentative load per word of any section and has the least specification and zero citations. §2's "(further applications to be added)" remains correctly and visibly marked as a known gap — not silently dropped.

---

## Critical Recommendations (Priority Order)

1. **[CRITICAL]** **Close the loop on the instrumentation asymmetry (Issues 4.2, 5.1).** This is the paper's distinctive contribution and nothing in the design produces it. Either add a small documentary/device component (what proof devices actually appear in participants' data-sharing agreements, impact reports and dashboards), or restate the finding as *perceived defensibility* derived from named Q-set statements. Do not leave the gap statement, the expected result, and §6.3 all resting on an unsupported step.

2. **[CRITICAL]** **Add the missing research question, or narrow §3c's claim (Issue 4.1).** §3c asserts the RQs are organized around value creation and capture; they are not, and §5's most concrete expected finding therefore answers no question. One added sub-RQ fixes the pillar, the finding, and the contradiction at once.

3. **[CRITICAL]** **Bring RQ2 within reach of the method (Issues 1.2, 4.3).** A compromise in Boltanski & Thévenot is a situated arrangement around a composite object, and "construct" is a process verb; a single-occasion Q study can observe neither. Reframe RQ2 to what factor analysis plus post-sort interviews can deliver, and hand the construction-in-interaction question to the §6.2 case studies — where the paper has already put the right design.

4. **[MAJOR]** **Specify §4 (Issues 2.1, 2.2, 2.5).** Extraction method, rotation, factor-retention criterion, loading-significance threshold, grid shape, software, concourse size, expert-sampling frame — and above all, **whether post-sort interviews with the P-set exist**, since recommendations 1 and 3 both depend on them. Add methodological citations; the section currently has none.

5. **[MAJOR]** **Fix the green-order attribution (Issue 1.1).** Green worth is Lafaye & Thévenot (1993), not Boltanski & Chiapello (2005). Cheap to fix, and it is the first thing an EoW referee will check.

6. **[MAJOR]** **Resolve the certification contradiction (Issue 1.5).** Certification is the paradigm civic/green form investment; as written, the paper's own examples refute its expected asymmetry. Narrow the claim to instrumentation *for the data-sharing test* specifically.

7. **[MAJOR]** **Reconcile the P-set with the title and RQs (Issue 4.4)**, separate "hybrid" from "social-economy," and add role/function as a second sampling dimension (Issue 2.4) — role is very likely a stronger viewpoint-differentiator than organizational form.

8. **[MAJOR]** **Repair the §5 contributions sentence properly (Issue 4.6)** — "complementing" → "complements", and split into three sentences so that each contribution has to name what produces it. The grammar fix alone would preserve the logic gap.

9. **[MAJOR]** **Verification queue, ordered by argumentative load** (Issues 3.7, 3.8, 3.9, 3.10): the SNA "for the first time" claim (wrong as stated, and it opens the paper); Spiekermann & Korunovska (the gloss reads as a mismatch with that paper's actual content); Badewitz (canonical attribution is the Data Shapley line); Nienstedt & Trenz (used inconsistently in §1 vs §3c). These four matter more than the remaining stubs because each carries a specific factual claim.

10. **[MAJOR]** **Repair the two §3a citation-support defects (Issues 3.2, 3.3)** — the social-organizations clause is unsupported by its two cited sources, and the colon construction misattributes a cost-based framing to Coyle & Manley. Both are in newly rewritten text, so they are cheap to fix now.

---

## Positive Findings

1. **The compromise/prioritization distinction in §3b is handled correctly and precisely** — including the detail that most papers get wrong: "Such compromises remain inherently fragile, since the objects gathered within them continue to belong to their order of origin and can be reopened by renewed critique." That is Boltanski & Thévenot's actual position, stated in one clause, and it is the sentence that tells a referee the author has read the book. The EoW/institutional-logics relationship in the same paragraph is also framed correctly as complementary and microfoundational rather than competing — the manuscript's own framing standard, which §3b meets even where §5 later drifts from it (Issue 1.9).

2. **The Q-methodology interpretation plan is genuinely well specified, and the §3a citation work is now strong.** §4's final sentence commits to interpreting factors through statement scores, participant characteristics, *and* qualitative data, cross-checked for both consensus and distinguishing statements — that is more than the loadings-only interpretation many published Q studies settle for, and it is the right plan. On citations: all 32 citekeys resolve, there are no orphan entries in either direction, the §3a rewrite correctly absorbed the verification pass's corrections (Kvalvik's fourth author and the scalability trait; Hunke et al.'s "analytics-based services" rather than "business models"; Wixom et al. retyped as a book), and the non-existent "Fletcher et al., 2014" was replaced with two verified sources rather than quietly dropped. That is disciplined citation hygiene, and it is visible in the text.

3. **The §6.1 future-research link is exemplary, and the P-set is right for Q.** Using the Q typology as the input set for a discrete choice experiment is a genuine methodological justification for doing Q *first*, not a decorative future-work bullet — it answers the "why not a survey" objection with a sequencing argument rather than a novelty claim. Relatedly, and worth stating explicitly since a survey-trained referee will get this wrong: **N = 30 with a 40-statement Q-set is entirely appropriate**, the statement-to-participant ratio is conventional, and nothing in this review should be read as a power objection. The problem with the P-set is *which* variation it samples, not how much of it there is.
