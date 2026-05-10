# HTML Research Dashboard

Every research project gets a single-page HTML dashboard (`research_overview.html`) that tracks the full pipeline state. It is regenerated after every pipeline-related interaction.

---

## Format: Long Scrollable Page

The dashboard is a **single long scrollable page** with a sticky navigation bar. No tabs that hide content — every section is always visible.

### Structure

```
Header (title, stats row: target journal, word limit, counties, panel years)
Sticky nav (anchor links to each section)

Section: Overview
  - Abstract / research question
  - Causal chain diagram
  - Contributions (grid of cards)
  - Risk matrix (table with status pills)

Section: Data
  - Master inventory (table: role, dataset, source, status pill)
  - Treatment & IV details (cards per component)
  - Outcomes (cards per outcome variable)
  - Mechanism variables (table)
  - Wind/instrument deep-dive (if applicable)
  - Download queue (priority table with time estimates)

Section: Identification
  - First stage / second stage equations
  - Exclusion restriction threats (table)
  - Fallback design
  - Key prediction

Section: Literature
  - Three-literature positioning table
  - Contribution statement (draft)
  - Scooping risk (cards: HIGH/MODERATE/LOW)
  - Key papers by proximity (tables: 1-2, 3, 4)
  - Gaps we fill (cards)
  - Critic score (if reviewed)
  - Title options

Section: Results
  - Empty state until estimation runs
  - Populated with event-study plots, coefficient tables, robustness

Section: Paper
  - Figure/table budget
  - Word allocation by section
  - Journal-specific formatting notes
```

### Design System

Use the clo-author design system from `templates/html/base/styles.css`:
- Palette: ivory/clay/serif (light) with automatic dark mode
- Components: cards, pills, stat rows, report tables, collapsibles, alerts
- Self-contained: all CSS inline, no external dependencies
- Print-friendly: nav hidden, all content visible

### Rules

1. **Long page, no tabs.** All sections visible as you scroll. Use sticky nav with anchor links.
2. **Smooth scroll everywhere.** Set `html { scroll-behavior: smooth; }`. Clicking any link fluidly rolls to the target — never jumps.
3. **Mini nav bar per section.** Each major section (Data, Literature, etc.) has its own pill-style sub-nav with anchor links to its sub-sections. Class: `.section-nav` with `<a href="#subsection-id">` links.
4. **No `overflow-x: auto`** on navigation — it creates ugly scrollbars.
5. **Collapsibles only for genuinely optional detail** (e.g., "13 wind sources assessed").
6. **Every section keeps full detail** — long page doesn't mean less content.
7. **Status pills on everything** — IN HAND, READY, FOUND, PARTIAL, NEEDS AGG, GAP.
8. **Self-contained HTML** — one file, no dependencies. Shareable as email attachment.
9. **All anchor targets use `scroll-margin-top: 60px`** so the sticky nav doesn't overlap content.

---

## When to Regenerate

The dashboard is updated after any interaction that changes pipeline state:

| Trigger | What updates |
|---------|-------------|
| `/discover data` completes | Data section: new sources, status pills |
| `/discover lit` completes | Literature section: papers, positioning, gaps |
| `/strategize` completes | Identification section: equations, threats, prediction |
| `/analyze` produces results | Results section: tables, figures |
| `/write` drafts sections | Paper section: word counts, completion status |
| `/review` scores paper | Critic scores throughout |
| Data files added/verified | Data section: status pills updated |
| Risk resolved | Overview: risk matrix updated |

### How to regenerate

After any pipeline skill completes, rebuild `research_overview.html` by:
1. Reading current project state (CLAUDE.md, quality_reports/, data/raw/, git status)
2. Preserving all existing content
3. Updating only the sections affected by the latest change
4. Opening the file in the browser for the user

---

## Empty States

Sections that haven't been populated yet show an empty state card:
```html
<div class="empty-state">
  <p><strong>Not yet started.</strong></p>
  <p>This section will populate when [specific action] runs.</p>
</div>
```
