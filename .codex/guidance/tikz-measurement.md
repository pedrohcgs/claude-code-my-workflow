---
paths:
  - "Slides/**/*.tex"
  - "Figures/**/*.tex"
  - "Preambles/**/*.tex"
  - "scripts/**/*.py"
  - "scripts/**/*.R"
---

# TikZ & Figure Measurement Rules

**Compute every label position. Never eyeball a curved arrow.** Applies to TikZ diagrams, matplotlib figures, and ggplot figures with curved annotations.

> Adapted from Scott Cunningham's `tikz_rules.md` in [MixtapeTools](https://github.com/scunning1975/MixtapeTools). Used with attribution.

The LaTeX and Python compilers render overlapping labels and curves crossing arrows without warning. The reviewer (`tikz-reviewer`) and any human looking at the figure catch these visually, but fixing them after the fact is expensive. Computing positions up front is cheap.

Use this file as the reference when authoring, extracting (`$extract-tikz`), or reviewing (`tikz-reviewer`). Reviewers must cite the specific formula or table row when reporting a collision.

---

## The six-pass protocol

Run these checks on every diagram, in order. Do not stop at the first pass — later passes catch collisions earlier passes miss.

### Pass 0 — Cross-slide consistency

When the same diagram, cycle, or visual element appears on more than one slide:

1. **Colors must match.** A node labeled "Inspect" in `slate` on slide 31 must stay `slate` on slide 32.
2. **Layout must match.** Same nodes at same positions, same spacing, same font sizes.
3. **Deliberate changes are the ONLY changes.** If slide 32 adds a red highlight to flag the bottleneck, that highlight should be the only difference.

```bash
# Find frames sharing the same node names
rg -n "node.*<shared-name>" Slides/presentation.tex
```

### Pass 1 — Bézier curves

```bash
rg -n "bend" Slides/presentation.tex
```

For each curved arrow:

**Step 1.** Identify endpoints and bend angle.

**Step 2.** Compute maximum curve depth:

$$\text{max depth} = \frac{\text{chord length}}{2} \times \tan\!\left(\frac{\text{bend angle}}{2}\right)$$

**Step 3.** Safe distance:

$$\text{safe distance} = \text{max depth} + 0.5\,\text{cm}$$

**Step 4.** Any label within `safe_distance` of the baseline (in the bend direction) **must** be moved.

**Step 5.** Any other arrow crossing the curve? If the return curve bends down and a vertical arrow runs through the middle, they will cross. Fix by flipping bend direction (`bend right` ↔ `bend left`) or routing the curve around.

#### Pre-computed bend table

| Bend angle | `tan(angle/2)` | Multiplier for half-chord |
|------------|---------------|---------------------------|
| 20° | 0.176 | × 0.18 |
| 25° | 0.222 | × 0.22 |
| 30° | 0.268 | × 0.27 |
| 35° | 0.315 | × 0.32 |
| 40° | 0.364 | × 0.36 |
| 45° | 0.414 | × 0.41 |

**Worked example.** Arrow spans 8.4 cm with `bend left=35`:

- Half-chord: 4.2 cm
- Depth: 4.2 × 0.315 = **1.32 cm**
- Safe distance: 1.32 + 0.5 = **1.82 cm**
- Any label must sit at `y ≤ −1.82` (not −1.2, not −1.5)

### Pass 2 — Label gaps between nodes

For every label positioned between two nodes:

$$
\begin{aligned}
\text{available gap} &= \text{center-to-center} - \tfrac{1}{2}\text{width}(A) - \tfrac{1}{2}\text{width}(B) \\
\text{usable space} &= \text{available gap} - 0.6\,\text{cm} \quad \text{(0.3 cm padding each side)}
\end{aligned}
$$

Estimate label width from font size:

| Font size | Width per character |
|-----------|---------------------|
| `\scriptsize` | 0.10 cm |
| `\footnotesize` | 0.12 cm |
| `\small` | 0.15 cm |
| `\normalsize` | 0.18 cm |

Bold: +10%. Monospace: +15%.

If `label width > usable space`: collision guaranteed. Move the label above or below, or shorten it.

**Worked example — the "via the terminal" problem.** Two 5 cm boxes with centers at `x = 0` and `x = 6.5`:

- Edge-to-edge gap: 6.5 − 2.5 − 2.5 = 1.5 cm
- Usable: 1.5 − 0.6 = 0.9 cm
- Label "via the terminal" (16 chars at `\small`): 16 × 0.15 = 2.4 cm
- 2.4 > 0.9 → collision → move the label above both boxes.

### Pass 3 — Arrow-label positioning

Every arrow label must declare a positional keyword (enforced by `tikz-prevention.md` Rule P4).

- Horizontal arrows: `above` or `below`.
- Vertical arrows: `left` or `right`.
- Diagonal: whichever side has more space.
- Curved: `above` on the *outside* of the bend.

### Pass 4 — The Boundary Rule (labels vs. drawn shapes)

**The compiler gives zero warnings for labels colliding with shape edges.** Every label near a drawn shape must be verified against the shape's computed boundary, not positioned for aesthetic alignment.

**Minimum clearance: 0.4 cm** (external or internal).

#### Circles

`\draw (cx, cy) circle (r);` → boundary from `y = cy − r` to `y = cy + r`.

```latex
% WRONG — label at y = 2.0 sits exactly on top edge
\draw (4, 0.5) circle (1.5cm);   % top edge: 0.5 + 1.5 = 2.0
\node at (4, 2.0) {Sample};      % COLLISION

% RIGHT — 0.4 cm clearance
\node at (4, 2.4) {Sample};      % 2.0 + 0.4 ✓
```

#### Rectangles / `FancyBboxPatch`

Bottom-left `(x, y)` with width `w`, height `h` → top edge `y + h`. Same 0.4 cm rule.

**Corollary — do not match y-coordinates across different-size shapes.** A `y` that's safe for one shape can collide with another. Compute boundaries per shape.

#### For matplotlib / Python figures

The same rule applies. `ax.text()` with `va='center'` extends ~½ the font height above and below the anchor. Account for this when placing text near `FancyBboxPatch` or `Circle` objects.

### Pass 4b — Matplotlib `arc3` arrows

Matplotlib's `connectionstyle='arc3,rad=R'` has an exact Bézier equivalent. **Always compute where the curve passes before placing a label.**

Control point:

```python
# Start (x1, y1), End (x2, y2), bend parameter R
cx = (x1 + x2) / 2 + R * (y2 - y1)
cy = (y1 + y2) / 2 - R * (x2 - x1)
```

Curve position at parameter `t ∈ [0, 1]`:

```
B(t) = (1 - t)^2 * P0 + 2 * (1 - t) * t * P1 + t^2 * P2
```

Copy-paste helper functions — include in any Python/matplotlib figure with `arc3`:

```python
import numpy as np

def arc3_control_point(x1, y1, x2, y2, rad):
    """Control point for matplotlib's arc3 connectionstyle."""
    dx, dy = x2 - x1, y2 - y1
    cx = (x1 + x2) / 2 + rad * dy
    cy = (y1 + y2) / 2 - rad * dx
    return cx, cy

def find_t_for_x(target_x, x1, cx, x2, num_samples=1000):
    """Bézier parameter t where x(t) ≈ target_x."""
    ts = np.linspace(0, 1, num_samples)
    xs = (1 - ts) ** 2 * x1 + 2 * (1 - ts) * ts * cx + ts ** 2 * x2
    return ts[np.argmin(np.abs(xs - target_x))]

def bezier_y_at_t(t, y1, cy, y2):
    """Y-coordinate of quadratic Bézier at parameter t."""
    return (1 - t) ** 2 * y1 + 2 * (1 - t) * t * cy + t ** 2 * y2
```

Label an arc3 arrow at the midpoint of the gap between two shapes:

```python
cx, cy   = arc3_control_point(x1, y1, x2, y2, rad)
t_mid    = find_t_for_x(gap_mid_x, x1, cx, x2)
curve_y  = bezier_y_at_t(t_mid, y1, cy, y2)
ax.text(gap_mid_x, curve_y + 0.35, label,
        ha="center", va="bottom",
        bbox=dict(facecolor="white", edgecolor="none", alpha=0.8, pad=1))
```

**Offset direction.** Curve bends up → label above (`va="bottom"`). Curve bends down → label below (`va="top"`). Straight → label above.

### Pass 4c — Anchor-based centering of text pairs

Multi-line text extends further from its anchor than single-line text. Symmetric y-coordinates therefore produce visually asymmetric layouts.

```python
# WRONG — symmetric coordinates, visually asymmetric
title_y = box_mid_y + 0.7   # 2-line title with va='center' → top-heavy
math_y  = box_mid_y - 0.7   # 1-line math with va='center' → too low

# RIGHT — anchor outward from center
ax.text(x, box_mid_y + 0.15, "Title\nLine 2", va="bottom", ...)  # grows UP
ax.text(x, box_mid_y - 0.15, r"$\hat{\beta}$", va="top",    ...) # grows DOWN
```

### Pass 5 — Margins (mandatory)

Every pair of distinct visual objects — labels, arrows, boxes, axis lines, tick marks, curve endpoints — must show visible margin space. Minimum clearances:

| Object pair | Minimum clearance |
|---|---|
| Label ↔ label | 0.3 cm |
| Label ↔ axis line | 0.3 cm |
| Label ↔ arrow | 0.3 cm |
| Arrow origin ↔ box edge | 0.15 cm |
| Label ↔ drawn-shape boundary | 0.4 cm (Pass 4) |
| Any object ↔ slide edge | 0.5 cm |

Additional checks:

- Multi-line nodes: `align=center`?
- No nodes clipped by slide edges (0.5 cm margin)?
- If scaled: nodes scaled too, not just coordinates (see `tikz-prevention.md` P3)?
- Arrow colors and stealth sizes consistent across the deck?

### Pass 5b — Plotted curves (normals, arbitrary functions)

TikZ `\draw plot` renders curves but never checks them for collisions with nearby objects.

**Rule.** For every plotted curve, compute its y-value at every x-coordinate where another object exists. Verify 0.3 cm clearance.

For Gaussian curves of the form `plot ({A*\x}, {B + C*exp(-\x*\x/2)})`:

- Peak: `y_peak = B + C` at `x = 0`.
- At TikZ x-coordinate X: `x_norm = X / A`, `y = B + C * exp(-x_norm^2 / 2)`.

**Worked example.** Curve `plot ({1.5*\x}, {0.3 + 2.0*exp(-\x*\x/2)})`:

- Peak: 0.3 + 2.0 = 2.3
- At `x = 1.5` (one SD): 0.3 + 2.0 × 0.607 = 1.51
- At `x = 3.0` (two SD): 0.3 + 2.0 × 0.135 = 0.57
- Label at `y = 3.0` near `x = 0` clears the peak by 0.7 ✓
- Box with bottom edge at `y = 3.6` clears the peak by 1.3 ✓

### Pass 6 — Open the PDF, visually confirm

Debug bounding boxes help: wrap suspect nodes in red outlines temporarily (`draw=red, very thin`) to see what's actually rendering. Remove before commit.

---

## Full-deck re-audit

After **any** TikZ fix, re-audit **every** TikZ figure in the deck. The same error pattern repeats across slides because the same code structure gets reused. `grep -n "bend"` finds all curves — checking each takes two minutes.

---

## Common collision patterns

1. **Label between wide boxes** → exceeds gap → move above/below.
2. **Timeline with era labels** → adjacent labels overlap → stagger above/below.
3. **Flow diagram with many arrows** → labels pile up → label only non-obvious transitions.
4. **Node near slide edge** → text extends past boundary → explicit `text width`, 0.5 cm margin.
5. **Return arrow crossing vertical branch** → curve passes through another arrow → flip bend direction.
6. **Label in curved arrow's path** → placed "below" the baseline but inside the curve's sweep → use the Pass 1 depth formula, add 0.5 cm safety.

---

## Integration with the workflow

- **`$extract-tikz` and `$new-diagram`** — both run a Step 1 prevention pre-check against the rules in [`tikz-prevention.md`](tikz-prevention.md) (P3 bare `scale=`, P4 missing directional keyword) before compiling. Both skills use identical grep patterns so behavior doesn't drift.
- **`tikz-reviewer` agent** — runs the measurement passes here (Pass 1 Bézier, Pass 2 gaps, Pass 3 keywords, Pass 4 boundaries, Pass 4b arc3, Pass 4c text pairs, Pass 5 margins, Pass 5b plotted curves, Pass 6 visual). Must cite the specific pass and formula when reporting a collision.
- **`quality_score.py`** — see [`quality-gates.md`](quality-gates.md) for the authoritative TikZ rubric. A label/arrow overlap finding is a hard presentation-quality defect.
