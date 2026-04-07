---
name: price-comparison-data-hygiene
description: Handle retail price-comparison projects that reconcile raw source tables, Excel workbooks, and slide multipliers. Use whenever the user asks to compare prices across retailers, map a bottom table to a PPT page, normalize unit prices, explain why workbook numbers do not match slides, or update Excel comparison sheets for Erewhon, Whole Foods, Trader Joe's, Walmart, or similar product-comparison workflows. This skill is especially important when titles, units, pack sizes, product forms, or slide multipliers may conflict.
---

# Price Comparison Data Hygiene

Use this skill for retail price-comparison work where one project may contain:

- a raw or "bottom" table
- a working Excel workbook
- one or more slides with multiplier callouts
- user-provided search results that may or may not support the slide numbers

The goal is to keep the comparison **comparable first, on-slide second**. Do not force a target multiplier by silently mixing units, product forms, or pack structures.

## Core workflow

### 1. Freeze scope before editing

Identify the active source surfaces up front:

- raw table / bottom table
- working workbook
- slide / PPT
- user-provided search results

If the user says to stay within provided data, do not browse or add outside candidates. If a needed candidate is missing, say so and ask for more inputs only if truly blocked.

### 2. Build the comparison on product identity first

Before looking at the target multiplier, match the two sides on the strongest comparable identity you can get:

- same category
- same quality tier
- same product form
- same organic / non-organic level when material
- same cut, origin, flavor, or function when material
- same consumption context

Use the user's business rule when relevant:

- lower-price examples should skew toward staple / livelihood items
- higher-price examples should skew toward differentiated or premium items

Do not treat a dried ingredient, a multi-pack, or a flavored variant as equivalent to a finished single-SKU product just because the multiplier looks better.

### 3. Normalize units before comparing

Never compare raw package prices directly when the displayed sizes differ.

Convert both sides to the same unit-price basis first:

- weight: `lb -> 16 oz`
- volume: `qt -> 32 fl oz`
- counts: compare on `count`
- each: compare on `each`

Hard rule: the visible spec shown in the workbook must match the unit-price basis used in the formula. If the formula uses `oz`, the displayed spec cannot still say `1 lb`.

Do not silently mix:

- `lb` with `oz`
- `qt` with `fl oz`
- `count` with `lb`
- a title saying `20 fl oz` with a spec column saying `1 qt`

### 4. Run conflict checks before trusting any multiplier

Always check for these conflict types:

1. **Title/spec conflict**
   Example: product title says `20 fl oz`, but the spec column says `1 qt`.

2. **Spec/formula conflict**
   Example: the formula effectively prices a Walmart item as `32 fl oz` even though the title says `16 fl oz`.

3. **Product-form conflict**
   Example: finished gel vs dried raw ingredient; refrigerated milk vs barista concentrate.

4. **Pack-structure conflict**
   Example: single bottle vs `pack of 2`; shipping-heavy listing vs normal in-store listing.

5. **Slide-target conflict**
   Example: a comparable candidate exists, but it cannot mathematically reach the multiplier shown in the slide.

6. **Cache/state conflict**
   Example: the workbook view shows stale values, reverted rows, or old formula caches.

If a conflict exists, name it explicitly. Do not "smooth it over" by tweaking only one field.

### 5. Reconcile workbook vs slide

After the actual ratio is computed:

- state the actual ratio
- state the slide target
- decide whether the gap is acceptable under the rounding rule being used
- if not acceptable, decide whether the issue is:
  - a bad candidate
  - a source conflict
  - an impossible target

If a comparable candidate cannot reach the slide target, preserve the comparable candidate and document the gap. Do not reverse-engineer a bad SKU just to make the slide land.

### 6. Document the decision in the workbook

Whenever a line is ambiguous or rejected, leave a short note that explains:

- what candidate was considered
- what normalized unit price it implies
- what multiplier it would produce
- why it was rejected or downgraded

Use notes especially for:

- multi-pack candidates
- listings with separate shipping
- close-but-not-clean candidates
- rows where the slide target cannot be supported by the provided evidence

## Decision rules

### Use as main comparison

Use a candidate when all of the following are true:

- product form is comparable
- quality tier is comparable
- unit basis is clean
- pack structure is normal
- no title/spec contradiction remains

### Keep as backup only

Keep a candidate as a note, not a main line, when any of the following is true:

- it is a multi-pack
- it has separate shipping that changes economics
- it only reaches the slide number by using a less-clean structure
- it is more expensive or cheaper only because of a pack-size artifact

### Mark as source conflict

Mark a row as a source conflict when:

- title and spec disagree
- link description and formula unit disagree
- the slide number is traceable to a formula that conflicts with the displayed SKU

In that case, explain which field the slide inherited and which field contradicts it.

## Output expectations

When reporting back, keep the explanation short and concrete:

1. what the normalized basis is
2. what the actual multiplier is
3. whether the slide number is supportable
4. if not, why not

## Read next when needed

- For a step-by-step execution checklist and note templates, read [references/checklist.md](references/checklist.md).
- For concrete failure patterns from prior price-comparison work, read [references/failure-patterns.md](references/failure-patterns.md).
