# Failure Patterns

## 1. Mixed visible units create fake multipliers

Symptom:

- workbook shows `1 lb` on one side and `12 oz` on the other
- formula directly divides unit prices that were not normalized to the same basis
- absurd outputs appear, such as `0.08x` or `0.06x`

Fix:

- normalize both sides to `oz` or `fl oz`
- update the displayed spec so it matches the formula basis

## 2. Slide inherits a bad raw-table formula

Symptom:

- slide multiplier looks clean
- raw-table formula also produces that number
- but the product title disagrees with the spec column used in the formula

Concrete pattern:

- title says `20 fl oz`
- spec column says `1 qt`
- formula uses `32 fl oz`

Interpretation:

- this is a source conflict, not a rounding issue
- do not say the slide is "supported" without naming the contradiction

## 3. Comparable products cannot hit the slide target

Symptom:

- user provides many candidates
- clean same-form comparisons still cannot reach the multiplier shown in the slide

Concrete pattern:

- finished sea moss gel candidates could not support `3.2x`
- closest clean candidates stayed materially below target

Fix:

- keep the clean comparison
- note that the slide target is not supported by the provided evidence

## 4. Multi-pack candidate reaches the target but should not be the main line

Symptom:

- a `pack of 2` or shipping-heavy listing lands near the desired multiplier
- normal single-SKU candidates do not

Concrete pattern:

- a multi-pack blue cheese dressing candidate could round to `1.7x`
- but it required ignoring shipping and accepting a `2-pack`

Fix:

- record it as a backup note only
- do not use it as the main comparison unless the slide itself is clearly based on multi-packs

## 5. Oat milk / milk line is impossible under current evidence

Symptom:

- slide target is close to parity, such as `1.02x`
- all provided Walmart candidates cluster around a different real value, such as `0.96x`

Fix:

- say the target cannot be reached from the provided candidate set
- keep the closest clean candidate

## 6. Workbook state can lag behind the real file

Symptom:

- screenshot and local workbook appear inconsistent
- a row looks highlighted or outdated even after edits

Fix:

- reopen the workbook
- recalculate formulas
- verify cached values after saving
