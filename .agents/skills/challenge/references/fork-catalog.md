# Fork catalogue — where competent analysts diverge, by design

Use when enumerating forks for a design you have not challenged before. A fork belongs in the
grid only if you would **defend either branch** in a seminar. Padding the grid with
indefensible alternatives dilutes the fragile cells and flatters the result.

Mark each fork **`estimand`** (changes what is being estimated) or **`estimate`** (same target,
different route). Estimand forks are reported separately — averaging over them is meaningless.

---

## Every design

| Fork | Alternatives | Kind |
|---|---|---|
| Outcome scale | level · log · IHS · share · rate | `estimand` if the elasticity target differs |
| Winsorization / trimming | none · 1% · 5% | `estimate` |
| Sample window | full · balanced · excluding a crisis period | `estimand` |
| Clustering | unit · assignment level · two-way | `estimate` (inference only) |
| Weighting | unweighted · population · IPW | `estimand` |
| Missing data | complete case · imputation · indicator | `estimate` |


> **Design-specific fork sections are deliberately absent** for the causal-identification
> designs (unvetted-methods veto): populate them from your field's canonical sources after
> vetting.

## Survey / experimental

Attention and manipulation-check screens · pre-registered vs full sample · multiple-comparison
correction (none · Holm · BH) · attrition handling. Screens are **`estimand`** — they change
the population.

---

## Sizing the grid

Grid size is the product of the alternatives. Six forks with three options each is **729 fits**.

- Start with the **3–4 forks most likely to move the result** — usually measure definition,
  comparison group, and control set.
- Run those fully, then expand only if the curve is tight.
- If a full grid is infeasible, run a **fractional design** and say so — a sampled grid honestly
  labelled beats a full grid nobody ran.
- **Log what you did not run.** Silent truncation reads as "we covered everything".

