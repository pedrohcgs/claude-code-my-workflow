# Checklist

## Pre-flight

Before touching the workbook:

1. List the active artifacts:
   - raw table
   - workbook
   - slide
   - user search results
2. Confirm whether outside search is allowed.
3. Confirm the rounding rule the user cares about:
   - exact
   - 1 decimal
   - 2 decimals
4. Identify which columns represent:
   - list price
   - spec quantity
   - spec unit
   - unit price
   - multiplier

## Unit normalization

Normalize before comparing:

- `1 lb = 16 oz`
- `1 qt = 32 fl oz`
- `count` stays `count`
- `each` stays `each`

Visible workbook spec must match formula basis.

## Conflict audit

Check every disputed line for:

- title vs spec mismatch
- link text vs spec mismatch
- spec vs formula mismatch
- single pack vs multi-pack
- product form mismatch
- shipping distortion

## Slide reconciliation

For every line that does not match the slide:

1. compute actual normalized multiplier
2. compare with slide target
3. classify the gap:
   - candidate issue
   - source conflict
   - impossible target
   - stale cache

## Note templates

### Backup candidate note

`备选：<product> 售价<$X>。若只看商品价、不计运费，单位价约<Y>，倍率约<Z>x；但其为<multi-pack / shipping listing / 非同形态商品>，因此不适合作为主表对比口径。`

### Impossible target note

`按当前提供候选，保持同品类、同品质层级、同形态比较时，实际倍率约为<Z>x，无法支撑片子中的<T>x。该差异来自<reason>。`

### Source conflict note

`该行存在底表冲突：商品标题写为<A>，但规格列/公式实际按<B>计算；片子倍率继承了<B>口径，而非标题口径。`
