---
name: responsive-design
description: Mobile-first responsive design covering fluid layouts, media queries, flexbox, grid, viewport units, and responsive images
category: frontend
tags: [css, responsive, mobile-first, flexbox, grid, media-queries]
version: 1.0.0
---

# Responsive Design Skill

## When to Use This Skill

Use this skill when you need to:

- Design and implement mobile-first responsive layouts
- Create fluid, adaptive interfaces that work across all device sizes
- Implement modern CSS layout techniques (Flexbox, Grid)
- Optimize images and media for different screen sizes
- Build accessible, touch-friendly interfaces
- Implement responsive typography and spacing systems
- Create container-based responsive components
- Optimize performance for mobile devices
- Ensure consistent user experience across devices
- Implement responsive navigation patterns
- Design responsive forms and data tables
- Create adaptive card layouts and galleries
- Build responsive dashboards and admin interfaces

## Core Concepts

### Mobile-First Philosophy

Mobile-first design means starting with mobile layout and progressively enhancing for larger screens.

**Why Mobile-First?**

- Forces focus on essential content and features
- Easier to scale up than scale down
- Better performance on mobile devices
- Aligns with modern usage patterns (mobile-first world)
- Simpler CSS with fewer overrides

**Mobile-First Approach:**

```css
/* Base styles for mobile (320px+) */
.container {
  padding: 1rem;
  width: 100%;
}

/* Tablet (768px+) */
@media (min-width: 768px) {
  .container {
    padding: 2rem;
    max-width: 720px;
    margin: 0 auto;
  }
}

/* Desktop (1024px+) */
@media (min-width: 1024px) {
  .container {
    max-width: 960px;
    padding: 3rem;
  }
}

/* Large Desktop (1280px+) */
@media (min-width: 1280px) {
  .container {
    max-width: 1200px;
  }
}
```

### Breakpoint Strategy

Standard breakpoints based on common device sizes:

```css
/* Extra Small (Mobile) - Default */
/* No media query needed */

/* Small (Large Mobile) */
@media (min-width: 480px) { }

/* Medium (Tablet) */
@media (min-width: 768px) { }

/* Large (Desktop) */
@media (min-width: 1024px) { }

/* Extra Large (Wide Desktop) */
@media (min-width: 1280px) { }

/* XXL (Ultra-wide) */
@media (min-width: 1536px) { }
```

**Custom Breakpoints:**

```css
/* Use custom breakpoints based on content, not devices */

/* When text becomes too long to read comfortably */
@media (min-width: 40em) { /* 640px */ }

/* When sidebar can fit alongside content */
@media (min-width: 60em) { /* 960px */ }

/* When multi-column layout makes sense */
@media (min-width: 75em) { /* 1200px */ }
```

### Fluid Layouts

Create layouts that adapt smoothly to any screen size:

```css
/* Fluid container with constraints */
.container {
  width: 100%;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  padding-left: clamp(1rem, 5vw, 3rem);
  padding-right: clamp(1rem, 5vw, 3rem);
}

/* Fluid grid */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: clamp(1rem, 3vw, 2rem);
}

/* Fluid typography */
.heading {
  font-size: clamp(1.5rem, 4vw + 1rem, 3rem);
  line-height: 1.2;
}
```

## CSS Techniques

### Flexbox for Responsive Layouts

Flexbox excels at one-dimensional layouts (row or column):

```css
/* Responsive navigation */
.nav {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: space-between;
  align-items: center;
}

.nav-links {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  list-style: none;
}

@media (max-width: 767px) {
  .nav {
    flex-direction: column;
    align-items: stretch;
  }

  .nav-links {
    flex-direction: column;
  }
}

/* Flexible card layout */
.card-container {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.card {
  flex: 1 1 300px; /* grow, shrink, base width */
  min-width: 0; /* Allow flex items to shrink below content size */
}

/* Responsive sidebar layout */
.layout {
  display: flex;
  flex-wrap: wrap;
  gap: 2rem;
}

.sidebar {
  flex: 1 1 250px;
}

.main-content {
  flex: 3 1 500px;
}
```

### CSS Grid for Complex Layouts

Grid is perfect for two-dimensional layouts:

```css
/* Auto-responsive grid */
.grid-auto {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

/* Named grid areas for semantic layouts */
.page-layout {
  display: grid;
  grid-template-areas:
    "header"
    "nav"
    "main"
    "aside"
    "footer";
  gap: 1rem;
}

@media (min-width: 768px) {
  .page-layout {
    grid-template-areas:
      "header header"
      "nav nav"
      "main aside"
      "footer footer";
    grid-template-columns: 2fr 1fr;
  }
}

@media (min-width: 1024px) {
  .page-layout {
    grid-template-areas:
      "header header header"
      "nav main aside"
      "footer footer footer";
    grid-template-columns: 200px 1fr 250px;
  }
}

.header { grid-area: header; }
.nav { grid-area: nav; }
.main { grid-area: main; }
.aside { grid-area: aside; }
.footer { grid-area: footer; }

/* Responsive grid with precise control */
.gallery {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 1rem;
}

.gallery-item {
  grid-column: span 12; /* Full width on mobile */
}

@media (min-width: 480px) {
  .gallery-item {
    grid-column: span 6; /* Half width on small screens */
  }
}

@media (min-width: 768px) {
  .gallery-item {
    grid-column: span 4; /* Third width on tablets */
  }
}

@media (min-width: 1024px) {
  .gallery-item {
    grid-column: span 3; /* Quarter width on desktop */
  }
}

/* Featured item spans more columns */
.gallery-item.featured {
  grid-column: span 12;
}

@media (min-width: 768px) {
  .gallery-item.featured {
    grid-column: span 8;
  }
}
```

### Media Queries Advanced Techniques

```css
/* Orientation-based queries */
@media (orientation: portrait) {
  .image-hero {
    aspect-ratio: 3/4;
  }
}

@media (orientation: landscape) {
  .image-hero {
    aspect-ratio: 16/9;
  }
}

/* Hover capability detection */
@media (hover: hover) and (pointer: fine) {
  /* Desktop with mouse */
  .button:hover {
    transform: scale(1.05);
  }
}

@media (hover: none) and (pointer: coarse) {
  /* Touch devices */
  .button:active {
    transform: scale(0.95);
  }
}

/* Prefers reduced motion */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Prefers color scheme */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-color: #1a1a1a;
    --text-color: #f0f0f0;
  }
}

/* Combining media queries */
@media (min-width: 768px) and (max-width: 1023px) {
  /* Tablet only styles */
  .container {
    padding: 2rem;
  }
}

/* Print styles */
@media print {
  .no-print {
    display: none;
  }

  body {
    font-size: 12pt;
    color: black;
    background: white;
  }
}
```

### Container Queries

Modern alternative to viewport-based media queries:

```css
/* Define container */
.card-container {
  container-type: inline-size;
  container-name: card;
}

/* Query based on container size */
.card {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

@container card (min-width: 400px) {
  .card {
    flex-direction: row;
    align-items: center;
  }

  .card-image {
    width: 40%;
  }

  .card-content {
    width: 60%;
  }
}

@container card (min-width: 600px) {
  .card-title {
    font-size: 1.5rem;
  }
}

/* Multiple containers */
.sidebar {
  container-type: inline-size;
  container-name: sidebar;
}

.main-content {
  container-type: inline-size;
  container-name: main;
}

@container sidebar (min-width: 300px) {
  .widget {
    padding: 1.5rem;
  }
}

@container main (min-width: 600px) {
  .article {
    column-count: 2;
  }
}
```

## Responsive Images

### Srcset and Sizes

Provide different image sizes for different viewport widths:

```html
<!-- Responsive image with srcset -->
<img
  src="image-800.jpg"
  srcset="
    image-400.jpg 400w,
    image-800.jpg 800w,
    image-1200.jpg 1200w,
    image-1600.jpg 1600w
  "
  sizes="
    (max-width: 480px) 100vw,
    (max-width: 768px) 90vw,
    (max-width: 1024px) 700px,
    1000px
  "
  alt="Responsive image"
  loading="lazy"
/>
```

```css
/* Ensure images are responsive by default */
img {
  max-width: 100%;
  height: auto;
  display: block;
}

/* Maintain aspect ratio */
.image-container {
  position: relative;
  aspect-ratio: 16 / 9;
  overflow: hidden;
}

.image-container img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
```

### Picture Element for Art Direction

Different images for different screen sizes:

```html
<!-- Art direction with picture -->
<picture>
  <!-- Mobile: portrait crop -->
  <source
    media="(max-width: 767px)"
    srcset="
      mobile-400.jpg 400w,
      mobile-800.jpg 800w
    "
    sizes="100vw"
  />

  <!-- Tablet: square crop -->
  <source
    media="(max-width: 1023px)"
    srcset="
      tablet-600.jpg 600w,
      tablet-1200.jpg 1200w
    "
    sizes="90vw"
  />

  <!-- Desktop: landscape crop -->
  <source
    media="(min-width: 1024px)"
    srcset="
      desktop-800.jpg 800w,
      desktop-1600.jpg 1600w,
      desktop-2400.jpg 2400w
    "
    sizes="(max-width: 1280px) 900px, 1200px"
  />

  <!-- Fallback -->
  <img src="desktop-800.jpg" alt="Art directed image" />
</picture>

<!-- WebP with fallback -->
<picture>
  <source type="image/webp" srcset="image.webp" />
  <source type="image/jpeg" srcset="image.jpg" />
  <img src="image.jpg" alt="Image with format fallback" />
</picture>
```

### Background Images

```css
/* Responsive background images */
.hero {
  background-image: url('hero-mobile.jpg');
  background-size: cover;
  background-position: center;
  min-height: 300px;
}

@media (min-width: 768px) {
  .hero {
    background-image: url('hero-tablet.jpg');
    min-height: 500px;
  }
}

@media (min-width: 1024px) {
  .hero {
    background-image: url('hero-desktop.jpg');
    min-height: 600px;
  }
}

/* High-density displays */
@media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
  .hero {
    background-image: url('hero-mobile@2x.jpg');
  }

  @media (min-width: 768px) {
    .hero {
      background-image: url('hero-tablet@2x.jpg');
    }
  }

  @media (min-width: 1024px) {
    .hero {
      background-image: url('hero-desktop@2x.jpg');
    }
  }
}
```

## Viewport Units

### Understanding Viewport Units

```css
/* Viewport Width (vw) - 1vw = 1% of viewport width */
.full-width-text {
  font-size: 5vw; /* Scales with viewport */
}

/* Viewport Height (vh) - 1vh = 1% of viewport height */
.full-screen-section {
  min-height: 100vh;
}

/* Viewport Minimum (vmin) - 1vmin = 1% of smaller dimension */
.responsive-square {
  width: 50vmin;
  height: 50vmin;
}

/* Viewport Maximum (vmax) - 1vmax = 1% of larger dimension */
.diagonal-element {
  width: 70vmax;
}

/* Combining units for fluid sizing */
.fluid-padding {
  padding: clamp(1rem, 5vw, 4rem);
}

.fluid-heading {
  font-size: clamp(1.5rem, 3vw + 1rem, 3.5rem);
}

/* Dynamic viewport units (dvh, svh, lvh) */
/* Small Viewport Height - smallest possible viewport */
.mobile-header {
  height: 10svh;
}

/* Large Viewport Height - largest possible viewport */
.mobile-footer {
  height: 10lvh;
}

/* Dynamic Viewport Height - adjusts to current state */
.modal {
  height: 100dvh; /* Better for mobile with hiding address bars */
}
```

### Practical Viewport Applications

```css
/* Hero section that adapts to screen */
.hero-section {
  min-height: clamp(400px, 80vh, 800px);
  padding: clamp(2rem, 5vh, 4rem) clamp(1rem, 5vw, 3rem);
}

/* Responsive spacing system */
:root {
  --spacing-xs: clamp(0.25rem, 1vw, 0.5rem);
  --spacing-sm: clamp(0.5rem, 2vw, 1rem);
  --spacing-md: clamp(1rem, 3vw, 2rem);
  --spacing-lg: clamp(2rem, 5vw, 4rem);
  --spacing-xl: clamp(3rem, 8vw, 6rem);
}

/* Responsive card grid with viewport-based gaps */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: clamp(1rem, 3vw, 2.5rem);
}
```

## Modern CSS Functions

### Clamp() for Fluid Sizing

```css
/* Syntax: clamp(MIN, PREFERRED, MAX) */

/* Fluid typography */
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
  /* Min: 2rem, Grows with viewport, Max: 4rem */
}

body {
  font-size: clamp(1rem, 0.9rem + 0.5vw, 1.25rem);
}

/* Fluid spacing */
.container {
  padding-inline: clamp(1rem, 5%, 3rem);
  padding-block: clamp(2rem, 8vh, 5rem);
}

/* Fluid widths */
.content {
  width: clamp(320px, 90%, 1200px);
  margin-inline: auto;
}

/* Fluid gaps */
.grid {
  gap: clamp(0.5rem, 2vw, 2rem);
}
```

### Min() and Max()

```css
/* Min() - use the smallest value */
.responsive-width {
  width: min(90%, 1200px);
  /* Width is 90% but never exceeds 1200px */
}

.image {
  width: min(100%, 500px);
  /* Responsive but caps at 500px */
}

/* Max() - use the largest value */
.minimum-padding {
  padding: max(1rem, 3vw);
  /* Ensures minimum 1rem padding */
}

.readable-width {
  max-width: max(60ch, 50%);
  /* At least 60 characters or 50% */
}

/* Combining min() and max() */
.flexible-container {
  width: min(max(300px, 50%), 900px);
  /* Between 300px and 900px, preferring 50% */
}
```

### Aspect-Ratio

```css
/* Modern aspect ratio control */
.video-container {
  aspect-ratio: 16 / 9;
  width: 100%;
}

.square-avatar {
  aspect-ratio: 1;
  width: 100px;
}

.portrait-card {
  aspect-ratio: 3 / 4;
}

/* Responsive aspect ratios */
.adaptive-media {
  aspect-ratio: 16 / 9;
}

@media (max-width: 767px) {
  .adaptive-media {
    aspect-ratio: 4 / 3;
  }
}

/* With object-fit */
.image-box {
  aspect-ratio: 1;
  overflow: hidden;
}

.image-box img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
}
```

## Performance Optimization

### Critical CSS

```html
<!-- Inline critical CSS in head -->
<style>
  /* Above-the-fold styles only */
  body {
    margin: 0;
    font-family: system-ui, -apple-system, sans-serif;
  }

  .header {
    position: sticky;
    top: 0;
    background: white;
    z-index: 100;
  }

  .hero {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>

<!-- Load full CSS asynchronously -->
<link rel="preload" href="styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="styles.css"></noscript>
```

### Lazy Loading

```html
<!-- Lazy load images -->
<img src="image.jpg" loading="lazy" alt="Lazy loaded image" />

<!-- Lazy load iframes -->
<iframe src="video.html" loading="lazy"></iframe>

<!-- Eager load above-the-fold images -->
<img src="hero.jpg" loading="eager" alt="Hero image" />
```

```css
/* Blur-up effect for lazy images */
.lazy-image {
  filter: blur(20px);
  transition: filter 0.3s;
}

.lazy-image.loaded {
  filter: blur(0);
}
```

### Performance Best Practices

```css
/* Use CSS containment */
.card {
  contain: layout style paint;
}

/* Optimize animations */
.animated {
  will-change: transform;
  transform: translateZ(0); /* Force GPU acceleration */
}

/* Avoid expensive properties in animations */
@media (prefers-reduced-motion: no-preference) {
  .button {
    transition: transform 0.2s, opacity 0.2s;
    /* Animate transform and opacity, not width/height */
  }
}

/* Use content-visibility for off-screen content */
.article-list > article {
  content-visibility: auto;
  contain-intrinsic-size: 0 500px;
}
```

## Accessibility

### Touch Targets

```css
/* Minimum touch target size: 44x44px (WCAG) */
.button,
.link,
.checkbox {
  min-width: 44px;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

/* Increase spacing on touch devices */
@media (hover: none) and (pointer: coarse) {
  .nav-link {
    padding: 0.75rem 1rem;
    margin: 0.25rem 0;
  }

  .button {
    padding: 1rem 2rem;
    font-size: 1.125rem;
  }
}
```

### Readable Text

```css
/* Optimal line length for readability: 45-75 characters */
.content {
  max-width: 65ch;
  margin-inline: auto;
}

/* Minimum font size */
body {
  font-size: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  line-height: 1.6;
}

/* Ensure sufficient color contrast */
:root {
  --text-primary: #1a1a1a;
  --text-secondary: #4a4a4a;
  --bg-primary: #ffffff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --text-primary: #f0f0f0;
    --text-secondary: #b0b0b0;
    --bg-primary: #1a1a1a;
  }
}

/* Scalable spacing */
.section {
  padding-block: clamp(2rem, 5vh, 4rem);
}
```

### Focus Indicators

```css
/* Visible focus indicators */
:focus-visible {
  outline: 2px solid var(--focus-color, #0066cc);
  outline-offset: 2px;
}

/* Enhanced focus for touch devices */
@media (hover: none) {
  :focus-visible {
    outline-width: 3px;
    outline-offset: 3px;
  }
}

/* Skip to content link */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  padding: 8px;
  background: #000;
  color: #fff;
  z-index: 1000;
}

.skip-link:focus {
  top: 0;
}
```

## Responsive Layout Examples

### Example 1: Holy Grail Layout

```css
.holy-grail {
  display: grid;
  grid-template-areas:
    "header"
    "nav"
    "main"
    "aside"
    "footer";
  min-height: 100vh;
  gap: 1rem;
}

.header { grid-area: header; }
.nav { grid-area: nav; }
.main { grid-area: main; }
.aside { grid-area: aside; }
.footer { grid-area: footer; }

@media (min-width: 768px) {
  .holy-grail {
    grid-template-areas:
      "header header"
      "nav main"
      "nav aside"
      "footer footer";
    grid-template-columns: 200px 1fr;
    grid-template-rows: auto 1fr auto auto;
  }
}

@media (min-width: 1024px) {
  .holy-grail {
    grid-template-areas:
      "header header header"
      "nav main aside"
      "footer footer footer";
    grid-template-columns: 200px 1fr 250px;
    grid-template-rows: auto 1fr auto;
  }
}
```

### Example 2: Responsive Card Grid

```css
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: clamp(1rem, 3vw, 2rem);
  padding: clamp(1rem, 3vw, 2rem);
}

.card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  transition: transform 0.2s;
}

@media (hover: hover) {
  .card:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  }
}

.card-image {
  aspect-ratio: 16 / 9;
  overflow: hidden;
}

.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.card-content {
  padding: 1.5rem;
  flex: 1;
}

.card-title {
  font-size: clamp(1.125rem, 2vw + 0.5rem, 1.5rem);
  margin-bottom: 0.5rem;
}
```

### Example 3: Responsive Navigation

```css
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.nav-menu {
  display: none;
  flex-direction: column;
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.nav-menu.active {
  display: flex;
}

.nav-toggle {
  display: block;
  padding: 0.5rem;
  background: none;
  border: none;
  cursor: pointer;
}

@media (min-width: 768px) {
  .nav-menu {
    display: flex;
    flex-direction: row;
    position: static;
    box-shadow: none;
    gap: 2rem;
  }

  .nav-toggle {
    display: none;
  }
}

.nav-link {
  padding: 1rem;
  text-decoration: none;
  color: #333;
  transition: background-color 0.2s;
}

@media (min-width: 768px) {
  .nav-link {
    padding: 0.5rem 1rem;
  }
}

.nav-link:hover {
  background-color: #f0f0f0;
}
```

### Example 4: Flexible Hero Section

```css
.hero {
  min-height: clamp(400px, 70vh, 800px);
  display: grid;
  grid-template-columns: 1fr;
  align-items: center;
  padding: clamp(2rem, 5vw, 4rem);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

@media (min-width: 768px) {
  .hero {
    grid-template-columns: 1fr 1fr;
    gap: 3rem;
  }
}

.hero-content {
  text-align: center;
}

@media (min-width: 768px) {
  .hero-content {
    text-align: left;
  }
}

.hero-title {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
  margin-bottom: 1rem;
  line-height: 1.1;
}

.hero-subtitle {
  font-size: clamp(1rem, 2vw + 0.5rem, 1.5rem);
  margin-bottom: 2rem;
  opacity: 0.9;
}

.hero-image {
  aspect-ratio: 1;
  border-radius: 8px;
  overflow: hidden;
}

.hero-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
```

### Example 5: Responsive Form

```css
.form-container {
  max-width: 600px;
  margin: 0 auto;
  padding: clamp(1rem, 3vw, 2rem);
}

.form-grid {
  display: grid;
  gap: 1.5rem;
}

@media (min-width: 768px) {
  .form-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .form-field.full-width {
    grid-column: 1 / -1;
  }
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-label {
  font-weight: 500;
  font-size: 0.875rem;
  color: #333;
}

.form-input,
.form-textarea,
.form-select {
  padding: 0.75rem 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 4px;
  font-size: 1rem;
  transition: border-color 0.2s;
  min-height: 44px; /* Accessibility */
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: #0066cc;
}

.form-textarea {
  min-height: 120px;
  resize: vertical;
}

.form-button {
  padding: 1rem 2rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s;
  min-height: 44px;
}

.form-button:hover {
  background: #0052a3;
}

@media (hover: none) {
  .form-button {
    padding: 1.25rem 2rem;
  }
}
```

### Example 6: Responsive Table

```css
.table-container {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.responsive-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 600px;
}

.responsive-table th,
.responsive-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #e0e0e0;
}

.responsive-table th {
  background: #f5f5f5;
  font-weight: 600;
  position: sticky;
  top: 0;
  z-index: 1;
}

/* Card-based table for mobile */
@media (max-width: 767px) {
  .responsive-table,
  .responsive-table thead,
  .responsive-table tbody,
  .responsive-table th,
  .responsive-table td,
  .responsive-table tr {
    display: block;
  }

  .responsive-table thead tr {
    position: absolute;
    top: -9999px;
    left: -9999px;
  }

  .responsive-table tr {
    margin-bottom: 1rem;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    overflow: hidden;
  }

  .responsive-table td {
    position: relative;
    padding-left: 50%;
    border: none;
    border-bottom: 1px solid #f0f0f0;
  }

  .responsive-table td:last-child {
    border-bottom: none;
  }

  .responsive-table td::before {
    content: attr(data-label);
    position: absolute;
    left: 1rem;
    width: 45%;
    font-weight: 600;
    white-space: nowrap;
  }
}
```

### Example 7: Dashboard Layout

```css
.dashboard {
  display: grid;
  gap: 1.5rem;
  padding: 1.5rem;
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .dashboard {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .dashboard {
    grid-template-columns: repeat(4, 1fr);
    grid-template-rows: auto auto 1fr;
  }
}

.dashboard-stat {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

@media (min-width: 1024px) {
  .dashboard-stat:nth-child(1) { grid-column: 1 / 2; }
  .dashboard-stat:nth-child(2) { grid-column: 2 / 3; }
  .dashboard-stat:nth-child(3) { grid-column: 3 / 4; }
  .dashboard-stat:nth-child(4) { grid-column: 4 / 5; }
}

.dashboard-chart {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  grid-column: 1 / -1;
}

@media (min-width: 1024px) {
  .dashboard-chart.large {
    grid-column: 1 / 4;
    grid-row: 2 / 4;
  }

  .dashboard-chart.medium {
    grid-column: 4 / 5;
    grid-row: 2 / 3;
  }
}
```

### Example 8: Magazine Layout

```css
.magazine-layout {
  display: grid;
  gap: 2rem;
  padding: 2rem;
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .magazine-layout {
    grid-template-columns: repeat(6, 1fr);
    grid-auto-rows: 200px;
  }
}

.article-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

@media (min-width: 768px) {
  .article-card.featured {
    grid-column: span 4;
    grid-row: span 2;
  }

  .article-card.medium {
    grid-column: span 2;
    grid-row: span 2;
  }

  .article-card.small {
    grid-column: span 2;
    grid-row: span 1;
  }
}

.article-image {
  height: 200px;
  overflow: hidden;
}

@media (min-width: 768px) {
  .article-card.featured .article-image,
  .article-card.medium .article-image {
    height: 60%;
  }
}

.article-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.article-content {
  padding: 1.5rem;
  flex: 1;
}
```

### Example 9: Sidebar Layout with Toggle

```css
.layout-with-sidebar {
  display: grid;
  grid-template-columns: 1fr;
  min-height: 100vh;
}

@media (min-width: 1024px) {
  .layout-with-sidebar {
    grid-template-columns: 280px 1fr;
  }
}

.sidebar {
  background: #f5f5f5;
  padding: 2rem;
  position: fixed;
  top: 0;
  left: -100%;
  height: 100vh;
  width: 280px;
  transition: left 0.3s;
  z-index: 1000;
  overflow-y: auto;
}

.sidebar.open {
  left: 0;
}

@media (min-width: 1024px) {
  .sidebar {
    position: static;
    left: 0;
    height: auto;
  }
}

.sidebar-toggle {
  position: fixed;
  top: 1rem;
  left: 1rem;
  z-index: 1001;
  padding: 0.75rem;
  background: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

@media (min-width: 1024px) {
  .sidebar-toggle {
    display: none;
  }
}

.main-content {
  padding: 2rem;
}

@media (min-width: 1024px) {
  .main-content {
    padding: 3rem;
  }
}

.overlay {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

.overlay.active {
  display: block;
}

@media (min-width: 1024px) {
  .overlay {
    display: none !important;
  }
}
```

### Example 10: Masonry Grid

```css
.masonry-grid {
  column-count: 1;
  column-gap: 1.5rem;
  padding: 1.5rem;
}

@media (min-width: 480px) {
  .masonry-grid {
    column-count: 2;
  }
}

@media (min-width: 768px) {
  .masonry-grid {
    column-count: 3;
  }
}

@media (min-width: 1024px) {
  .masonry-grid {
    column-count: 4;
  }
}

.masonry-item {
  break-inside: avoid;
  margin-bottom: 1.5rem;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.masonry-item img {
  width: 100%;
  display: block;
}

.masonry-item-content {
  padding: 1rem;
}
```

### Example 11: Pricing Table

```css
.pricing-container {
  display: grid;
  gap: 2rem;
  padding: 2rem;
  grid-template-columns: 1fr;
  max-width: 1200px;
  margin: 0 auto;
}

@media (min-width: 768px) {
  .pricing-container {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .pricing-container {
    grid-template-columns: repeat(3, 1fr);
  }
}

.pricing-card {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  transition: transform 0.2s;
}

@media (hover: hover) {
  .pricing-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }
}

.pricing-card.featured {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  transform: scale(1);
}

@media (min-width: 1024px) {
  .pricing-card.featured {
    transform: scale(1.05);
  }
}

.pricing-header {
  text-align: center;
  margin-bottom: 2rem;
}

.pricing-title {
  font-size: clamp(1.25rem, 2vw + 0.5rem, 1.75rem);
  margin-bottom: 1rem;
}

.pricing-price {
  font-size: clamp(2rem, 4vw + 1rem, 3rem);
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.pricing-features {
  list-style: none;
  padding: 0;
  margin-bottom: 2rem;
  flex: 1;
}

.pricing-features li {
  padding: 0.75rem 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.pricing-card.featured .pricing-features li {
  border-bottom-color: rgba(255, 255, 255, 0.2);
}

.pricing-button {
  width: 100%;
  padding: 1rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.pricing-card.featured .pricing-button {
  background: white;
  color: #667eea;
}

.pricing-button:hover {
  background: #0052a3;
}

.pricing-card.featured .pricing-button:hover {
  background: #f0f0f0;
}
```

### Example 12: Footer Layout

```css
.footer {
  background: #1a1a1a;
  color: white;
  padding: clamp(2rem, 5vw, 4rem) clamp(1rem, 3vw, 2rem);
}

.footer-content {
  display: grid;
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  grid-template-columns: 1fr;
}

@media (min-width: 480px) {
  .footer-content {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 768px) {
  .footer-content {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (min-width: 1024px) {
  .footer-content {
    grid-template-columns: 2fr 1fr 1fr 1fr;
  }
}

.footer-section {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.footer-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.footer-links {
  list-style: none;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.footer-link {
  color: #b0b0b0;
  text-decoration: none;
  transition: color 0.2s;
}

.footer-link:hover {
  color: white;
}

.footer-bottom {
  margin-top: 3rem;
  padding-top: 2rem;
  border-top: 1px solid #333;
  text-align: center;
}

@media (min-width: 768px) {
  .footer-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    text-align: left;
  }
}

.footer-social {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 1rem;
}

@media (min-width: 768px) {
  .footer-social {
    margin-top: 0;
  }
}
```

### Example 13: Feature Grid

```css
.features {
  display: grid;
  gap: clamp(2rem, 4vw, 3rem);
  padding: clamp(2rem, 5vw, 4rem);
  max-width: 1200px;
  margin: 0 auto;
}

@media (min-width: 768px) {
  .features {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .features {
    grid-template-columns: repeat(3, 1fr);
  }
}

.feature-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

@media (hover: hover) {
  .feature-item:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  }
}

.feature-icon {
  width: 64px;
  height: 64px;
  margin-bottom: 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.feature-title {
  font-size: clamp(1.125rem, 2vw + 0.5rem, 1.5rem);
  margin-bottom: 1rem;
}

.feature-description {
  color: #666;
  line-height: 1.6;
}
```

### Example 14: Timeline Layout

```css
.timeline {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 1rem;
  position: relative;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 20px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #e0e0e0;
}

@media (min-width: 768px) {
  .timeline::before {
    left: 50%;
    transform: translateX(-50%);
  }
}

.timeline-item {
  position: relative;
  padding-left: 60px;
  margin-bottom: 3rem;
}

@media (min-width: 768px) {
  .timeline-item {
    width: 50%;
    padding-left: 0;
    padding-right: 3rem;
  }

  .timeline-item:nth-child(even) {
    margin-left: 50%;
    padding-right: 0;
    padding-left: 3rem;
  }
}

.timeline-dot {
  position: absolute;
  left: 11px;
  top: 0;
  width: 20px;
  height: 20px;
  background: #0066cc;
  border-radius: 50%;
  border: 4px solid white;
  box-shadow: 0 0 0 2px #0066cc;
}

@media (min-width: 768px) {
  .timeline-dot {
    left: auto;
    right: -10px;
  }

  .timeline-item:nth-child(even) .timeline-dot {
    right: auto;
    left: -10px;
  }
}

.timeline-content {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.timeline-date {
  font-weight: 600;
  color: #0066cc;
  margin-bottom: 0.5rem;
}

.timeline-title {
  font-size: 1.25rem;
  margin-bottom: 0.5rem;
}

.timeline-description {
  color: #666;
  line-height: 1.6;
}
```

### Example 15: Image Gallery

```css
.gallery {
  display: grid;
  gap: 1rem;
  padding: 1rem;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  grid-auto-rows: 150px;
  grid-auto-flow: dense;
}

@media (min-width: 480px) {
  .gallery {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    grid-auto-rows: 200px;
  }
}

@media (min-width: 768px) {
  .gallery {
    gap: 1.5rem;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    grid-auto-rows: 250px;
  }
}

.gallery-item {
  position: relative;
  overflow: hidden;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.2s;
}

@media (hover: hover) {
  .gallery-item:hover {
    transform: scale(1.02);
    z-index: 1;
  }
}

/* Vary item sizes for visual interest */
.gallery-item:nth-child(5n+1) {
  grid-column: span 2;
  grid-row: span 2;
}

.gallery-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.gallery-item-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
  color: white;
  padding: 1rem;
  text-align: center;
}

@media (hover: hover) {
  .gallery-item:hover .gallery-item-overlay {
    opacity: 1;
  }
}

@media (hover: none) {
  .gallery-item-overlay {
    opacity: 1;
    background: linear-gradient(to top, rgba(0, 0, 0, 0.8), transparent);
    align-items: flex-end;
    justify-content: flex-start;
  }
}
```

## Best Practices Summary

### Design Principles

1. **Mobile-First Always**: Start with mobile and enhance for larger screens
2. **Content-First**: Let content dictate breakpoints, not devices
3. **Progressive Enhancement**: Build a solid foundation, then add enhancements
4. **Performance Matters**: Optimize images, lazy load, use critical CSS
5. **Accessibility First**: Touch targets, readable text, keyboard navigation
6. **Flexible Everything**: Use relative units, fluid layouts, scalable typography
7. **Test on Real Devices**: Emulators aren't enough

### Testing Checklist

- [ ] Test on actual mobile devices (iOS and Android)
- [ ] Test at various viewport sizes (not just standard breakpoints)
- [ ] Test with slow network connections (3G)
- [ ] Test touch interactions (tap, swipe, pinch)
- [ ] Test with different font sizes (user preferences)
- [ ] Test keyboard navigation
- [ ] Test with screen readers
- [ ] Test in landscape and portrait orientations
- [ ] Test with different zoom levels
- [ ] Validate HTML and CSS

### Common Pitfalls to Avoid

- Don't use fixed pixel widths for containers
- Don't rely on hover states for essential functionality
- Don't use viewport units for everything (breaks zoom)
- Don't forget about landscape orientation
- Don't assume all touch devices are small
- Don't use tiny touch targets (<44px)
- Don't disable zoom (never use maximum-scale=1)
- Don't forget about intermediate breakpoints
- Don't test only in Chrome DevTools
- Don't ignore performance budgets

## Resources

### Tools

- Chrome DevTools Device Mode
- Firefox Responsive Design Mode
- BrowserStack / LambdaTest for real device testing
- Lighthouse for performance auditing
- WebPageTest for network performance
- Can I Use for browser compatibility

### Documentation

- MDN Web Docs: Responsive Design
- W3C Mobile Web Best Practices
- WCAG 2.1 Guidelines
- Google's Mobile-Friendly Test

### Further Reading

- "Responsive Web Design" by Ethan Marcotte
- "Mobile First" by Luke Wroblewski
- A List Apart articles on responsive design
- Smashing Magazine responsive design guides
