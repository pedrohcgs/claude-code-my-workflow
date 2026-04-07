# Heading Patterns in Component Systems

Strategies for maintaining proper heading hierarchy in component-based architectures.

## The Challenge

Component-based development creates a tension:

- Components should be reusable across contexts
- Heading levels depend on surrounding document structure
- Content authors may not understand heading hierarchy
- Hardcoded levels break in different contexts

## Pattern 1: Configurable Heading Level

Make heading level a prop/parameter with a sensible default.

```jsx
// React example
function Card({ title, headingLevel = 3, children }) {
  const Heading = `h${headingLevel}`;
  return (
    <article className="card">
      <Heading>{title}</Heading>
      {children}
    </article>
  );
}
```

```twig
{# Twig example #}
{% set heading_tag = heading_level|default(3) %}
<article class="card">
  <h{{ heading_tag }}>{{ title }}</h{{ heading_tag }}>
  {{ content }}
</article>
```

### When to Use

- Generic components used in multiple contexts
- Components where nesting depth varies
- CMS-driven content where authors control usage

### Trade-offs

- Moves responsibility to component consumer
- Authors may not choose correctly
- Sensible default reduces but doesn't eliminate risk

## Pattern 2: Context-Aware Defaults

Set defaults based on known component relationships.

```jsx
// Section always starts a new heading context
function Section({ title, children }) {
  return (
    <section aria-labelledby="section-title">
      <h2 id="section-title">{title}</h2>
      {children}
    </section>
  );
}

// Cards within sections default to h3
function CardList({ cards }) {
  return (
    <ul className="card-list">
      {cards.map((card) => (
        <li key={card.id}>
          <Card title={card.title} headingLevel={3} />
        </li>
      ))}
    </ul>
  );
}
```

### When to Use

- Known parent-child component relationships
- Design system with predictable nesting patterns
- When you control both container and child components

### Trade-offs

- Less flexible
- Breaks if components are used outside expected context
- Requires documentation of expected usage

## Pattern 3: Heading Component Abstraction

Create a heading component that handles both semantic and visual concerns.

```jsx
function Heading({ level, visualLevel = level, children, className = "" }) {
  const Tag = `h${level}`;
  const visualClass = `u-heading-${visualLevel}`;

  return <Tag className={`${visualClass} ${className}`}>{children}</Tag>;
}

// Usage: semantic h3, visual appearance of h2
<Heading level={3} visualLevel={2}>
  Section Title
</Heading>;
```

### When to Use

- Design requires visual hierarchy different from semantic
- Large headings needed at deep nesting levels
- Consistent visual treatment across varying semantic levels

### Benefits

- Separates concerns clearly
- Documents the distinction explicitly
- Enables correct semantics without design compromise

## Pattern 4: Inherited Configuration

Generic components inherit heading config when specialised.

```jsx
// Generic card
function Card({ title, headingLevel = 3, headingClass, children }) {
  const Heading = `h${headingLevel}`;
  return (
    <article className="card">
      <Heading className={headingClass}>{title}</Heading>
      {children}
    </article>
  );
}

// Specialised product card - knows its context
function ProductCard({ product, headingLevel = 3 }) {
  return (
    <Card
      title={product.name}
      headingLevel={headingLevel}
      headingClass="product-card__title"
    >
      <p className="product-card__price">{product.price}</p>
      <p className="product-card__description">{product.description}</p>
    </Card>
  );
}

// Page section - sets context for children
function FeaturedProducts({ products }) {
  return (
    <section aria-labelledby="featured-heading">
      <h2 id="featured-heading">Featured Products</h2>
      <ul className="product-grid">
        {products.map((product) => (
          <li key={product.id}>
            <ProductCard product={product} headingLevel={3} />
          </li>
        ))}
      </ul>
    </section>
  );
}
```

### When to Use

- Design systems with component inheritance
- When generic components are always wrapped by specific ones
- Clear ownership of heading level decision

## Visual-Only Headings

When text should look like a heading but not affect document outline:

```html
<!-- Looks like a heading, but isn't one semantically -->
<p class="u-heading-xl">Sale ends tomorrow!</p>

<!-- Compare to actual heading -->
<h2 class="u-heading-xl">Product Categories</h2>
```

### When to Use

- Promotional text that looks prominent but isn't structural
- Decorative typography
- Labels that don't introduce content sections

### CSS Utility Classes

```css
/* Size-based utilities separate from semantic level */
.u-heading-xs {
  font-size: var(--font-size-xs);
}
.u-heading-s {
  font-size: var(--font-size-s);
}
.u-heading-m {
  font-size: var(--font-size-m);
}
.u-heading-l {
  font-size: var(--font-size-l);
}
.u-heading-xl {
  font-size: var(--font-size-xl);
}

/* All share heading-like properties */
.u-heading-xs,
.u-heading-s,
.u-heading-m,
.u-heading-l,
.u-heading-xl {
  font-weight: var(--font-weight-bold);
  line-height: var(--line-height-tight);
}
```

## Checklist for Component Headings

When building a component with a heading:

- [ ] Is the heading level configurable?
- [ ] Is there a sensible default?
- [ ] Is the default documented?
- [ ] Can visual appearance be controlled independently?
- [ ] Does the component work at all reasonable heading levels?
- [ ] Is the expected context documented?

## Common Mistakes

### Hardcoded Levels

```jsx
// Fragile: breaks when used outside expected context
function Card({ title }) {
  return (
    <article>
      <h3>{title}</h3> {/* What if this is used at h2 level? */}
    </article>
  );
}
```

### Level Chosen for Appearance

```html
<!-- Wrong: h4 chosen because it's smaller -->
<h4 class="card-title">Product Name</h4>

<!-- Right: appropriate level with visual override -->
<h3 class="card-title u-heading-s">Product Name</h3>
```

### Missing Defaults

```jsx
// Dangerous: undefined heading level
function Card({ title, headingLevel }) {
  const Heading = `h${headingLevel}`; // h undefined if not passed
  return <Heading>{title}</Heading>;
}

// Safe: always has a valid level
function Card({ title, headingLevel = 3 }) {
  const Heading = `h${headingLevel}`;
  return <Heading>{title}</Heading>;
}
```
