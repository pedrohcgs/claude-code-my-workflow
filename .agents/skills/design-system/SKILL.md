---
name: design-system
description: "Extract a complete design system from an existing website or screenshot into a DESIGN.md file. Analyses colours, typography, component styles, spacing, and atmosphere through browser automation and HTML inspection. Produces a semantic design system document optimised for consistent page generation. Triggers: 'extract design system', 'design system', 'create DESIGN.md', 'analyse the design', 'what design does this site use', 'extract styles from', 'reverse engineer the design'."
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Design System Extractor

Analyse an existing website, HTML file, or screenshot and synthesise a semantic design system into a `DESIGN.md` file. The output should stand on its own as a reusable design reference for this repo or project.

## When to Use

- Starting a new project based on an existing site's visual language
- Documenting a site's design system that was never formally written down
- Preparing a reusable `DESIGN.md` reference before design or implementation work
- Extracting brand guidelines from a client's existing website
- Creating consistency documentation for a multi-page project
- Extracting design tokens from a Google Stitch project

## Workflow

### Step 1: Identify the Source

Ask the user for one of:

| Source | Method |
|--------|--------|
| **Live URL** | Browse via Playwright CLI or scraper, screenshot + extract HTML |
| **Local HTML file** | Read the file directly |
| **Screenshot image** | Analyse visually (limited — no exact hex extraction) |
| **Existing project** | Scan the workspace for HTML entry points, screenshots, or built pages to analyse |
| **Stitch project** | Use `@google/stitch-sdk` to fetch screen HTML + design theme |

### Step 2: Extract Raw Design Data

#### From a Live URL

1. Open the URL with any available browser automation or browser MCP
2. Capture a desktop screenshot
3. Capture a mobile screenshot (around 375px wide)
4. Extract the full HTML or DOM snapshot if tooling allows it

#### From a Local HTML File

Read the file directly and extract design tokens from the source.

#### From a Screenshot Only

Analyse the image visually. Note: colour extraction will be approximate without HTML source. Flag this limitation in the output.

#### From a Google Stitch Project

If `@google/stitch-sdk` is installed and `STITCH_API_KEY` is set:

```typescript
import { stitch } from "@google/stitch-sdk";

// List projects to find the target
const projects = await stitch.projects();

// Get project details (includes designTheme)
const project = stitch.project(projectId);
const screens = await project.screens();

// Get HTML from the main screen
const screen = screens[0]; // or find by title
const htmlUrl = await screen.getHtml();
const imageUrl = await screen.getImage();
```

The Stitch `designTheme` object provides structured tokens directly:

```json
{
  "colorMode": "DARK",
  "font": "INTER",
  "roundness": "ROUND_EIGHT",
  "customColor": "#40baf7",
  "saturation": 3
}
```

Map these to DESIGN.md sections:
- `colorMode` → Theme (Light/Dark)
- `font` → Typography font family
- `roundness` → Component border-radius (`ROUND_EIGHT` = 8px, `ROUND_SIXTEEN` = 16px, etc.)
- `customColor` → Primary brand colour
- `saturation` → Colour vibrancy (1-5 scale)

Then also download and analyse the HTML for the full palette (Stitch's theme object only has the primary colour — the full palette is in the generated CSS).

### Step 3: Analyse Design Tokens

Extract these from the HTML/CSS source:

#### Colours

Look in these locations (priority order):

1. **CSS custom properties** — `:root { --primary: #hex; }` or `@theme` blocks
2. **Tailwind config** — `<script>` block with `tailwind.config` or `@theme` in `<style>`
3. **Inline styles** — `style="color: #hex"` or `style="background: #hex"`
4. **Tailwind classes** — `bg-blue-600`, `text-gray-900` (map to palette)
5. **Computed from screenshot** — last resort, approximate

For each colour found, determine its **role**:

| Role | How to identify |
|------|-----------------|
| Primary | Buttons, links, active states, brand elements |
| Background | `<body>` or `<html>` background |
| Surface | Cards, containers, elevated elements |
| Text Primary | `<h1>`, `<h2>`, main body text |
| Text Secondary | Captions, metadata, muted text |
| Border | Dividers, input borders, card borders |
| Accent | Badges, notifications, highlights |

#### Typography

Extract:

| Token | Where to find |
|-------|---------------|
| Font families | Google Fonts `<link>`, `@import`, `font-family` in CSS |
| Heading weights | `font-bold`, `font-semibold`, or explicit `font-weight` |
| Body size | Base `font-size` on `<body>` or root |
| Line height | `leading-*` classes or `line-height` CSS |
| Letter spacing | `tracking-*` classes or `letter-spacing` CSS |

#### Components

Identify patterns for:

- **Buttons** — shape (rounded-full, rounded-lg), colours, padding, hover states
- **Cards** — background, border, shadow, border-radius, padding
- **Navigation** — sticky/static, background treatment, active indicator
- **Forms** — input style, focus ring, label positioning
- **Hero sections** — layout pattern, overlay treatment, CTA placement

#### Spacing & Layout

- **Max content width** — look for `max-w-*` or explicit `max-width`
- **Section padding** — typical vertical padding between sections
- **Grid system** — column count, gap values
- **Whitespace philosophy** — tight, balanced, generous, or dramatic

### Step 4: Synthesise into Natural Language

**Critical**: The DESIGN.md should describe the design in **semantic, natural language** supported by exact values. This is not a CSS dump — it's a document a designer or AI can read to understand and reproduce the visual language.

| Don't write | Write instead |
|-------------|---------------|
| `rounded-xl` | "Softly rounded corners (12px)" |
| `shadow-md` | "Subtle elevation with diffused shadow" |
| `#1E40AF` | "Deep Ocean Blue (#1E40AF) for primary actions" |
| `py-16` | "Generous section spacing with breathing room" |

### Step 5: Write DESIGN.md

Output the file to `DESIGN.md` at the repo root by default.
If the project already uses a `.design/` directory, preserve that convention instead of creating a second location.

Use this structure directly in the generated file:

1. **Visual Theme & Atmosphere** — mood, vibe, philosophy
2. **Colour Palette & Roles** — table with role, name, hex, usage
3. **Typography** — font families, weights, sizes, line heights
4. **Component Styles** — buttons, cards, nav, forms
5. **Layout Principles** — max width, spacing, grid, whitespace
6. **Design System Notes for Generation** — the copy-paste block for baton prompts

### Step 6: Verify Accuracy

If browser automation is available:

1. Generate a small test section (e.g. a card + button + heading) using the extracted design system
2. Screenshot it alongside the original
3. Compare visually — adjust any values that don't match

### Step 7: Report to User

Present:
- Summary of extracted tokens (colour count, fonts, component patterns)
- The generated DESIGN.md location
- Any tokens that were approximate (flagged with ⚠️)
- Suggestions for manual review (colours from screenshots, ambiguous typography)

## Handling Multiple Pages

If the site has multiple pages with different styles:

1. Analyse the **homepage first** — it usually has the most complete design language
2. Spot-check 2-3 inner pages for consistency
3. Note any **page-specific overrides** in the Component Styles section
4. If pages are wildly different, ask the user which page to use as the canonical source

## Tips

- **Tailwind sites are easiest** — the config block has everything
- **Google Fonts links are gold** — they specify exact families and weights
- **CSS custom properties are reliable** — they represent intentional design tokens
- **Inline Tailwind classes need interpretation** — `bg-slate-900` needs mapping to a role
- **Screenshots are last resort** — accurate hex extraction from images is unreliable
- **Dark mode**: Check for `.dark` class overrides or `prefers-color-scheme` media queries

## Common Pitfalls

- ❌ Listing raw CSS values without semantic description
- ❌ Missing the dark mode palette (check for `.dark` class or media query)
- ❌ Ignoring component patterns (just listing colours isn't enough)
- ❌ Not including Section 6 (the copy-paste generation block)
- ❌ Approximate colours from screenshots without flagging the uncertainty
