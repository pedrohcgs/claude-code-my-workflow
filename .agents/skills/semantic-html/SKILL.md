---
name: semantic-html
description: Write well-considered semantic HTML that serves all users. Use when creating components, page structures, or reviewing markup. Emphasizes native HTML elements over ARIA. Treats proper document structure and accessibility as foundations rather than afterthoughts.
---

# Semantic HTML

Write HTML that conveys meaning, serves all users, and respects the web platform.

## When to Use This Skill

Use this skill when:

- Creating new components or page sections
- Reviewing markup for accessibility and semantics
- Deciding between native HTML elements and ARIA attributes
- Structuring documents with proper heading hierarchy
- Making interactive elements accessible
- Building forms with proper labelling and error handling
- Creating responsive tables

## Core Principles

### Content Realism

Design content is idealized. Real content is messy. Always account for:

- Long sentences and long words
- Images with varying aspect ratios and sizes
- Multi-language support (even if not planned—users can translate via browser)
- Dynamic content that changes in length and structure

Build components that handle real-world content gracefully, not just what looks good in design tools.

### Landmarks-First Planning

Before diving into individual components, consider the full page structure. This allows you to:

- Identify key landmarks for assistive technology users
- Plan heading hierarchy across the document
- Make informed decisions about element choice
- Avoid overusing landmarks (which diminishes their usefulness)

### Native Over ARIA

Follow the first rule of ARIA: if a native HTML element provides the semantics and behaviour you need, use it instead of adding ARIA to a generic element.

**Red flag:** High div count combined with high ARIA count on non-complex components signals reaching for patches rather than foundations.

### Separation of Visual and Semantic Hierarchy

Visual styling and semantic meaning are related but not coupled. CSS classes bridge the gap:

- Use the appropriate heading level based on document structure
- Apply CSS classes to control visual appearance (size, weight, colour)
- Create utility classes like `.u-Heading-XXL` for consistent visual treatment regardless of semantic level

## Document Structure

### Landmark Elements

Use landmark elements to convey page structure:

| Element   | Use When                     | Notes                                                                            |
| --------- | ---------------------------- | -------------------------------------------------------------------------------- |
| `header`  | Page or section header       | Can appear multiple times in different contexts                                  |
| `footer`  | Page or section footer       | Contact info, copyright, related links                                           |
| `nav`     | Navigation sections          | Must be labelled; avoid "navigation" in the label (screen readers announce this) |
| `main`    | Primary content              | Only one per page                                                                |
| `aside`   | Tangentially related content | Sidebars, pull quotes, advertising                                               |
| `search`  | Search functionality         | Contains the search form, not the results                                        |
| `form`    | User input                   | Only becomes a landmark when labelled via `aria-labelledby` or `aria-label`      |
| `article` | Self-contained content       | Would make sense syndicated or standalone                                        |
| `section` | Thematic grouping            | Only becomes a landmark when labelled                                            |

### The Section Element

A `section` without an accessible name behaves like a `div` semantically. When using `section`:

- Associate it with a heading via `aria-labelledby`
- This transforms it into a valid landmark region
- If you cannot provide a meaningful label, question whether `section` is the right choice

### The Article Element

Think beyond blog posts. Use `article` for any self-contained content that would make sense on its own:

- Blog posts and news articles
- Comments on a post
- Product cards in a listing
- Social media posts in a feed
- Forum posts

**Test:** Would this content make sense if extracted and placed elsewhere with no surrounding context?

### The Address Element

Often misunderstood. From the HTML specification:

> The address element represents the contact information for its nearest article or body element ancestor.

Use for contact information about the author or owner—not for generic postal addresses. For postal addresses, use a standard `<p>` or structured markup appropriate to the context.

## Headings

### Heading Hierarchy

Maintain a logical heading structure:

- One `h1` per page (typically the main title)
- Don't skip levels (h1 → h3)
- Headings create an outline—ensure it makes sense when read in sequence

### Headings in Components

For reusable components containing headings:

1. **Make heading level configurable** — Components may appear in different contexts
2. **Provide sensible defaults** — Not all content authors understand heading hierarchy
3. **Consider inheritance** — Generic components become specific ones; heading config should flow through

**Example pattern:**

```
Card (generic) → heading level configurable, default h3
  └─ ProductCard (specific) → inherits config, may set default based on known context
       └─ Used in section with h2 → heading level set to h3
```

### Visual Heading Without Semantic Heading

Sometimes text looks like a heading but shouldn't be one semantically. Use CSS classes to apply heading-like styling without affecting document outline:

```html
<p class="u-Heading-L">This looks like a heading</p>
```

## Lists

### When to Use Lists

Lists are most useful when **knowing the number of items helps the user**:

- Navigation menus (how many options?)
- Search results (how many matches?)
- Image galleries (how many images?)
- Steps in a process

**Questions to ask:**

- Are these items genuinely peers?
- Would removing one make the others feel incomplete?
- Is there an implicit "here are N things" being communicated?

### List Types

| Type   | Use When                                 | Example                               |
| ------ | ---------------------------------------- | ------------------------------------- |
| `ul`   | Unordered collection where count matters | Nav items, search results             |
| `ol`   | Sequential steps or ranked items         | Recipes, instructions, top-10 lists   |
| `dl`   | Term-description pairs                   | Glossaries, metadata, key-value pairs |
| `menu` | Toolbar commands                         | Action buttons, not navigation        |

**Ordered list attributes:** Use `reversed` for countdown-style lists (e.g., a top 10 listed from 10 to 1). Use `start` to begin numbering from a specific value. Both are native HTML—no JavaScript required.

### Definition Lists

Often overlooked or confused with `details`/`summary`. Use `dl` for:

- Glossary definitions
- Metadata display (label: value pairs)
- Any term with one or more descriptions

Note: A single `dt` can have multiple `dd` elements for multiple related descriptions.

## Interactive Elements

### Buttons vs Links

**Traditional rule:** Buttons do things, links go places.

**Progressive enhancement lens:** If a URL provides a meaningful fallback when JavaScript fails, a link is valid even for action-like interactions.

| Interaction             | Default Choice | Consider Link When                            |
| ----------------------- | -------------- | --------------------------------------------- |
| Show more content       | `button`       | URL params could load the content server-side |
| Toggle view (grid/list) | `button`       | URL could preserve view preference            |
| Copy to clipboard       | `button`       | Copied content is a shareable URL             |
| Tab selection           | `button`       | URL could load specific tab content           |

**Key question:** What happens when JavaScript fails? If a URL provides graceful degradation, a link may be the better choice.

### The Details/Summary Pattern

Use for progressive disclosure:

- FAQ sections
- Expandable content sections
- Collapsible navigation

Not a replacement for proper heading structure or definition lists.

## Forms

### Grouping with Fieldset/Legend

Use `fieldset` and `legend` for **thematic grouping**, not layout:

- Address fields
- Personal information sections
- Privacy/consent checkboxes
- Payment details

Benefits:

- Enables progressive disclosure (reveal sections as user completes others)
- Reduces overwhelm (avoids "wall of form fields")
- Provides context for screen reader users

Legends can be visually hidden while still providing accessible names.

### Labels

**Always use a `label` element.** No exceptions.

- Visually hidden labels are acceptable when design requires it
- Never rely on placeholder text as a label substitute
- Never use `aria-label` when a proper `label` element works

**Why placeholders fail:**

- Disappear on input (problematic for cognitive challenges, stress, or distraction)
- Often have poor contrast
- Don't provide persistent identification

### Error Messages

Current best practice (due to browser support gaps with `aria-errormessage`):

1. Set `aria-invalid="true"` on the invalid input
2. Associate error message via `aria-describedby`
3. Ensure error message is actionable (state the problem AND guide the fix)
4. For dynamic errors (shown on blur), consider `aria-live` on the error container

```html
<label for="email">Email</label>
<input
  type="email"
  id="email"
  aria-invalid="true"
  aria-describedby="email-error"
/>
<p id="email-error" class="error">
  Enter a valid email address, like name@example.com
</p>
```

## Tables

### When to Use Tables

Use a table when data has **meaningful relationships in both dimensions**:

- Data must be presented as rows AND columns
- Clear association between headers and data
- Each row has the same columns
- Within each column, data is of the same type

### When NOT to Use Tables

- Simple lists (one dimension)
- Key-value pairs (use `dl`)
- Form layouts
- Hierarchical data (use nested lists)

### Table Semantics Baseline

Always include:

- `caption` — Describes the table's purpose
- `thead`, `tbody`, `tfoot` — Structural grouping
- `th` with `scope` — Identifies header cells and their direction

### Responsive Tables

In order of preference:

1. **Hide non-essential columns** — User still gets main takeaways; offer button to show full table
2. **Horizontal scroll** — Preserves semantics but may challenge users with motor difficulties
3. **Component duplication (cards on mobile)** — Last resort; maintain accessibility in both versions

Note: Modern browsers (including Safari) no longer strip table semantics when applying `display: grid` or `display: flex`, opening new responsive possibilities.

## Code Review Checklist

When reviewing markup, look for:

### Positive Signals

- [ ] Landmark elements used appropriately
- [ ] Logical heading hierarchy
- [ ] Native interactive elements (buttons, links) used correctly
- [ ] Forms have proper labels and fieldsets
- [ ] Tables have full semantic structure
- [ ] ARIA used sparingly and correctly

### Warning Signs

- [ ] High div count in non-complex components
- [ ] ARIA attributes compensating for missing native semantics
- [ ] Placeholders used as labels
- [ ] Heading levels chosen for visual size rather than structure
- [ ] Generic elements with click handlers instead of buttons/links
- [ ] Tables used for layout
- [ ] Missing form labels

## Resources

- [HTML Living Standard: Sections](https://html.spec.whatwg.org/dev/sections.html)
- [HTML Living Standard: Grouping Content](https://html.spec.whatwg.org/dev/grouping-content.html)
- [HTML Living Standard: Forms](https://html.spec.whatwg.org/dev/forms.html)
- [HTML Living Standard: Tables](https://html.spec.whatwg.org/dev/tables.html)
- [MDN: ARIA](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA)

## References

See the `references/` directory for detailed guidance on specific topics:

- `element-decision-trees.md` — Quick decision frameworks for element selection
- `heading-patterns.md` — Component heading patterns and configuration strategies
