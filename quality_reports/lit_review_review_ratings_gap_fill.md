# Literature Review: Gap-Fill for the Online Review-Ratings Project

**Date:** 2026-09-14
**Query:** Targeted additions the existing 44-entry bibliography under-covers — (1) competitive
solicitation / firms choosing collection strategy; (2) whether consumers adjust for *how* reviews were
collected; (3) LLM-as-classifier validation methods. Candidates must be Crossref-verified and not
duplicate the 44 already in `Bibliography_base.bib`.

## Summary

The existing bibliography (transcribed from the lit-review table) is **exhaustive relative to the source
documents**: all 43 table rows are captured (44 entries, Hu et al. split into its 2009 + 2017 versions),
every Part-2 narrative citation maps to an entry, and the *Silence of the Satisfied* proposal cites only
six papers — Hu/Pavlou/Zhang 2009, Schoenmueller et al. 2020, Brandes et al. 2022, Askalidis et al. 2017,
Karaman 2021, Luca & Zervas 2016 — **all already present**. So nothing the current source set cites is
missing.

As a *field* bibliography it is deliberately not saturated (the review says so). Three areas the project
will lean on are thin. Area 2 (does the consumer adjust for collection method) and Area 3 (LLM-classifier
validation) are **load-bearing** — the proposal's H6–H8 rest on a hand-validated LLM classifier, and the
model's design question (b) is about consumer adjustment. Area 1 (competitive review-strategy neighbours)
matters for the theory paper's positioning, but the exact competitive-*solicitation* model remains the
contribution, so few additions are needed there.

Every candidate below was verified against the Crossref REST API on 2026-09-14 (DOI, title, venue, authors).

## Candidate additions (verified; not yet in the .bib)

### Area 2 — consumers & collection method  *(recommend: add both)*
- **Marinescu, Chamberlain, Smart & Klein (2021)** — "Incentives Can Reduce Bias in Online Employer
  Reviews," *J. Experimental Psychology: Applied* 27(2), 393–407. Glassdoor evidence that incentivized
  ratings are less extreme than voluntary ones — the direct companion to Karaman/Askalidis/Fradkin&Holtz
  and to the proposal's premise that solicitation corrects self-selection. → stream *Changing who reviews*.
- **Xie, Yeoh & Wang (2024)** — "How Self-Selection Bias in Online Reviews Affects Buyer Satisfaction: A
  Product-Type Perspective," *Decision Support Systems* 181, 114199. Downstream consequence of the bias.
  → stream *Why ratings are biased*.

### Area 3 — LLM-as-classifier validation  *(load-bearing for H6–H8; recommend Gilardi + Ziems core)*
- **Gilardi, Alizadeh & Kubli (2023)** — "ChatGPT Outperforms Crowd Workers for Text-Annotation Tasks,"
  *PNAS* 120(30), e2305016120. Canonical evidence LLMs can annotate at/above crowd quality.
- **Ziems, Held, Shaikh, Chen, Zhang & Yang (2024)** — "Can Large Language Models Transform Computational
  Social Science?" *Computational Linguistics* 50(1), 237–291. The validation-framework reference.
- **Heseltine & Clemm von Hohenberg (2024)** — "Large Language Models as a Substitute for Human Experts in
  Annotating Political Text," *Research & Politics* 11(1). A published validation-against-human-experts study.
- **Lin & Zhang (2025)** — "Navigating the Risks of Using Large Language Models for Text Annotation in
  Social Science Research," *Social Science Computer Review* 44(3), 403–427. The skeptical counterweight —
  useful for the classifier-validity threats section.
  → new stream *LLM text measurement (methods)*.

### Area 1 — competitive review-strategy neighbours  *(optional; positioning for the theory paper)*
- **Yang, Zheng, Mookerjee & Chen (2023)** — "Responding to Online Reviews in Competitive Markets: A
  Controlled Diffusion Approach," *MIS Quarterly* 47(1), 161–194. Two competing firms, review lever =
  management response. → stream *Theory of firms and reviews*.
- **Zhao, Peng & Li (2023)** — "The Influence of Online Customer Reviews on Two-Stage Product Strategy in a
  Competitive Market," *Annals of Operations Research* 326(1), 411–503. Duopoly + reviews (price/quality
  levers). Marginal — a further neighbour to Zhao et al. 2022 already in the .bib.

## Gaps and opportunities

1. **The exact competitive-solicitation model still has no direct precedent** — confirmed. Every Area-1
   neighbour uses price/quality/response/manipulation as the lever, not the choice to solicit genuine
   reviews. This is the theory paper's contribution, not a hole to fill.
2. **Consumer-adjustment ("do they discount solicited reviews?") is thin on the "yes, they adjust" side.**
   De Langhe et al. (don't adjust) and He & Bond (attribution) are in; the experiment (design question b)
   is where this is settled, so the literature here is a framing input, not a test.
3. **LLM-classifier validation is a live, fast-moving methods literature** — cite the canonical pair
   (Gilardi; Ziems) plus a risk paper (Lin & Zhang), and treat all elicitation as versioned/dated.

## Suggested next step

Approve which candidates to add; on approval I append them to `Bibliography_base.bib` (with a new
`% --- LLM text measurement (methods) ---` stream for Area 3) and re-run the structural checks.

## BibTeX (candidates — Crossref-verified 2026-09-14)

```bibtex
@article{MarinescuEtal2021_incentives_bias,
  author  = {Marinescu, Ioana and Chamberlain, Andrew and Smart, Morgan and Klein, Nadav},
  title   = {{Incentives Can Reduce Bias in Online Employer Reviews}},
  journal = {Journal of Experimental Psychology: Applied}, volume = {27}, number = {2}, pages = {393--407}, year = {2021},
  doi     = {10.1037/xap0000342}}

@article{XieYeohWang2024_selfselection_satisfaction,
  author  = {Xie, Yancong and Yeoh, William and Wang, Jingguo},
  title   = {{How Self-Selection Bias in Online Reviews Affects Buyer Satisfaction: A Product-Type Perspective}},
  journal = {Decision Support Systems}, volume = {181}, pages = {114199}, year = {2024},
  doi     = {10.1016/j.dss.2024.114199}}

@article{GilardiAlizadehKubli2023_chatgpt_annotation,
  author  = {Gilardi, Fabrizio and Alizadeh, Meysam and Kubli, Ma{\"e}l},
  title   = {{ChatGPT Outperforms Crowd Workers for Text-Annotation Tasks}},
  journal = {Proceedings of the National Academy of Sciences}, volume = {120}, number = {30}, pages = {e2305016120}, year = {2023},
  doi     = {10.1073/pnas.2305016120}}

@article{ZiemsEtal2024_llm_css,
  author  = {Ziems, Caleb and Held, William and Shaikh, Omar and Chen, Jiaao and Zhang, Zhehao and Yang, Diyi},
  title   = {{Can Large Language Models Transform Computational Social Science?}},
  journal = {Computational Linguistics}, volume = {50}, number = {1}, pages = {237--291}, year = {2024},
  doi     = {10.1162/coli_a_00502}}

@article{HeseltineClemm2024_llm_expert_annotation,
  author  = {Heseltine, Michael and Clemm von Hohenberg, Bernhard},
  title   = {{Large Language Models as a Substitute for Human Experts in Annotating Political Text}},
  journal = {Research \& Politics}, volume = {11}, number = {1}, year = {2024},
  doi     = {10.1177/20531680241236239}}

@article{LinZhang2025_llm_annotation_risks,
  author  = {Lin, Hao and Zhang, Yongjun},
  title   = {{Navigating the Risks of Using Large Language Models for Text Annotation in Social Science Research}},
  journal = {Social Science Computer Review}, volume = {44}, number = {3}, pages = {403--427}, year = {2025},
  doi     = {10.1177/08944393251366243}}

@article{YangEtal2023_responding_competitive,
  author  = {Yang, Mingwen and Zheng, Zhiqiang (Eric) and Mookerjee, Vijay and Chen, Hongyu},
  title   = {{Responding to Online Reviews in Competitive Markets: A Controlled Diffusion Approach}},
  journal = {MIS Quarterly}, volume = {47}, number = {1}, pages = {161--194}, year = {2023},
  doi     = {10.25300/misq/2022/16163}}

@article{ZhaoPengLi2023_two_stage_strategy,
  author  = {Zhao, Cui and Peng, Xiaoshuai and Li, Zhendong},
  title   = {{The Influence of Online Customer Reviews on Two-Stage Product Strategy in a Competitive Market}},
  journal = {Annals of Operations Research}, volume = {326}, number = {1}, pages = {411--503}, year = {2023},
  doi     = {10.1007/s10479-023-05213-9}}
```

## Post-Flight Verification

All eight candidates were verified directly against the **Crossref REST API** (DOI resolves; title, venue,
volume/issue/pages, and author list read from the Crossref record) on 2026-09-14 — a stronger check than
CoVe for citation existence and metadata. No fabricated or unverifiable entries. The `Maël` and
`Research & Politics` special characters are escaped for BibTeX.
