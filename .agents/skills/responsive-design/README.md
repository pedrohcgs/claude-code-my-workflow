# Responsive Design Skill

A comprehensive skill for building mobile-first, responsive web interfaces using modern CSS techniques.

## Overview

This skill provides everything you need to create responsive, adaptive layouts that work seamlessly across all device sizes. From mobile phones to ultra-wide desktop monitors, learn to build interfaces that adapt gracefully to any viewport.

## What You'll Learn

### Core Responsive Concepts

- **Mobile-First Philosophy**: Why and how to start with mobile and progressively enhance
- **Breakpoint Strategy**: Choosing the right breakpoints for your content
- **Fluid Layouts**: Creating layouts that adapt smoothly to any screen size
- **Flexible Typography**: Scaling text appropriately across devices
- **Responsive Images**: Optimizing and adapting images for different contexts

### Modern CSS Techniques

- **Flexbox**: One-dimensional responsive layouts
- **CSS Grid**: Two-dimensional responsive layouts
- **Media Queries**: Viewport, orientation, and feature queries
- **Container Queries**: Component-based responsive design
- **Modern CSS Functions**: clamp(), min(), max(), aspect-ratio

### Performance and Accessibility

- **Critical CSS**: Loading strategies for optimal performance
- **Lazy Loading**: Images and content optimization
- **Touch Targets**: Ensuring accessible interactive elements
- **Readable Text**: Typography best practices for all devices
- **Motion Preferences**: Respecting user accessibility settings

## Quick Start

### Basic Mobile-First Layout

```css
/* Start with mobile styles */
.container {
  padding: 1rem;
  width: 100%;
}

/* Enhance for larger screens */
@media (min-width: 768px) {
  .container {
    max-width: 720px;
    margin: 0 auto;
    padding: 2rem;
  }
}

@media (min-width: 1024px) {
  .container {
    max-width: 960px;
  }
}
```

### Responsive Grid

```css
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: clamp(1rem, 3vw, 2rem);
}
```

### Fluid Typography

```css
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
}

body {
  font-size: clamp(1rem, 0.9rem + 0.5vw, 1.25rem);
}
```

## Common Use Cases

### 1. Responsive Navigation

Transform navigation from hamburger menu on mobile to horizontal menu on desktop:

```css
.nav-menu {
  display: none; /* Hidden by default on mobile */
}

.nav-menu.active {
  display: flex;
  flex-direction: column;
}

@media (min-width: 768px) {
  .nav-menu {
    display: flex; /* Always visible on desktop */
    flex-direction: row;
    gap: 2rem;
  }

  .nav-toggle {
    display: none; /* Hide hamburger on desktop */
  }
}
```

### 2. Adaptive Card Layouts

Cards that stack on mobile and grid on larger screens:

```css
.card-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}
```

### 3. Responsive Images

Serve different images based on viewport size:

```html
<img
  src="image-800.jpg"
  srcset="
    image-400.jpg 400w,
    image-800.jpg 800w,
    image-1200.jpg 1200w
  "
  sizes="
    (max-width: 480px) 100vw,
    (max-width: 768px) 90vw,
    700px
  "
  alt="Responsive image"
  loading="lazy"
/>
```

### 4. Flexible Hero Section

Hero that adapts from single column to two-column layout:

```css
.hero {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  padding: clamp(2rem, 5vw, 4rem);
}

@media (min-width: 768px) {
  .hero {
    grid-template-columns: 1fr 1fr;
    align-items: center;
  }
}
```

### 5. Responsive Tables

Transform tables into cards on mobile:

```css
@media (max-width: 767px) {
  table, thead, tbody, th, td, tr {
    display: block;
  }

  thead tr {
    position: absolute;
    top: -9999px;
    left: -9999px;
  }

  tr {
    margin-bottom: 1rem;
    border: 1px solid #ddd;
  }

  td {
    position: relative;
    padding-left: 50%;
  }

  td::before {
    content: attr(data-label);
    position: absolute;
    left: 1rem;
    font-weight: bold;
  }
}
```

## Responsive Design Patterns

### Holy Grail Layout

Three-column layout that adapts to single column on mobile:

```css
.layout {
  display: grid;
  grid-template-areas:
    "header"
    "nav"
    "main"
    "aside"
    "footer";
}

@media (min-width: 1024px) {
  .layout {
    grid-template-areas:
      "header header header"
      "nav main aside"
      "footer footer footer";
    grid-template-columns: 200px 1fr 250px;
  }
}
```

### Sidebar Layout

Responsive sidebar that becomes a drawer on mobile:

```css
.sidebar {
  position: fixed;
  left: -100%;
  transition: left 0.3s;
}

.sidebar.open {
  left: 0;
}

@media (min-width: 1024px) {
  .sidebar {
    position: static;
  }
}
```

### Dashboard Grid

Complex dashboard that reflows from 1 to 4 columns:

```css
.dashboard {
  display: grid;
  gap: 1.5rem;
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
  }
}
```

## Viewport Units Guide

### Understanding Units

- **vw**: 1% of viewport width
- **vh**: 1% of viewport height
- **vmin**: 1% of smaller viewport dimension
- **vmax**: 1% of larger viewport dimension
- **dvh**: Dynamic viewport height (accounts for mobile browser chrome)
- **svh**: Small viewport height (smallest possible)
- **lvh**: Large viewport height (largest possible)

### Practical Examples

```css
/* Full-height section */
.hero {
  min-height: 100vh;
}

/* Better for mobile with dynamic toolbars */
.mobile-section {
  min-height: 100dvh;
}

/* Fluid spacing */
.container {
  padding: clamp(1rem, 5vw, 3rem);
}

/* Responsive square */
.square {
  width: 50vmin;
  height: 50vmin;
}
```

## Modern CSS Functions

### Clamp()

Create fluid, constrained values:

```css
/* Syntax: clamp(MIN, PREFERRED, MAX) */

/* Fluid font size */
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
}

/* Fluid spacing */
section {
  padding: clamp(2rem, 5vh, 5rem) clamp(1rem, 5vw, 3rem);
}

/* Fluid width */
.container {
  width: clamp(320px, 90%, 1200px);
}
```

### Min() and Max()

```css
/* Min() - use smallest value */
.container {
  width: min(90%, 1200px); /* 90% but never exceeds 1200px */
}

/* Max() - use largest value */
.button {
  padding: max(1rem, 3vw); /* At least 1rem */
}
```

### Aspect-Ratio

Maintain aspect ratios without padding hacks:

```css
.video-container {
  aspect-ratio: 16 / 9;
  width: 100%;
}

.square {
  aspect-ratio: 1;
}

.portrait {
  aspect-ratio: 3 / 4;
}
```

## Accessibility Best Practices

### Touch Targets

Ensure interactive elements are large enough to tap:

```css
button,
a,
input[type="checkbox"] {
  min-width: 44px;
  min-height: 44px;
}

/* Increase on touch devices */
@media (hover: none) and (pointer: coarse) {
  button {
    padding: 1rem 2rem;
  }
}
```

### Readable Text

Maintain readability across all devices:

```css
/* Optimal line length */
.content {
  max-width: 65ch; /* 65 characters */
}

/* Minimum font size */
body {
  font-size: clamp(1rem, 0.9rem + 0.5vw, 1.25rem);
  line-height: 1.6;
}
```

### Motion Preferences

Respect user preferences for reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Focus Indicators

Provide clear focus indicators:

```css
:focus-visible {
  outline: 2px solid var(--focus-color);
  outline-offset: 2px;
}

/* Enhanced on touch devices */
@media (hover: none) {
  :focus-visible {
    outline-width: 3px;
  }
}
```

## Performance Optimization

### Critical CSS

Load essential styles first:

```html
<head>
  <!-- Inline critical CSS -->
  <style>
    /* Above-the-fold styles only */
    .header { /* ... */ }
    .hero { /* ... */ }
  </style>

  <!-- Load full CSS asynchronously -->
  <link rel="preload" href="styles.css" as="style" onload="this.rel='stylesheet'">
  <noscript><link rel="stylesheet" href="styles.css"></noscript>
</head>
```

### Lazy Loading

Defer loading of below-the-fold content:

```html
<!-- Lazy load images -->
<img src="image.jpg" loading="lazy" alt="Lazy loaded" />

<!-- Eager load hero image -->
<img src="hero.jpg" loading="eager" alt="Hero" />
```

### CSS Containment

Optimize rendering performance:

```css
.card {
  contain: layout style paint;
}

.article {
  content-visibility: auto;
  contain-intrinsic-size: 0 500px;
}
```

## Testing Checklist

### Device Testing

- [ ] Test on real iOS devices (iPhone, iPad)
- [ ] Test on real Android devices (various sizes)
- [ ] Test on tablets in portrait and landscape
- [ ] Test at various viewport sizes between breakpoints
- [ ] Test with browser zoom at 200% and 50%

### Functionality Testing

- [ ] All interactive elements have 44x44px touch targets
- [ ] Navigation works on mobile and desktop
- [ ] Images load correctly at different sizes
- [ ] Forms are usable on mobile
- [ ] Tables are readable on small screens
- [ ] Modals/overlays work on all devices

### Performance Testing

- [ ] Lighthouse score > 90 on mobile
- [ ] First Contentful Paint < 1.8s on 3G
- [ ] Images are optimized and responsive
- [ ] Critical CSS is inlined
- [ ] Lazy loading is implemented

### Accessibility Testing

- [ ] Keyboard navigation works everywhere
- [ ] Focus indicators are visible
- [ ] Text is readable without zoom
- [ ] Color contrast meets WCAG AA standards
- [ ] Screen reader testing completed
- [ ] Reduced motion preference respected

## Common Pitfalls

### Don't Do This

```css
/* Fixed pixel widths */
.container {
  width: 1200px; /* ❌ Breaks on smaller screens */
}

/* Tiny touch targets */
.icon-button {
  width: 20px;
  height: 20px; /* ❌ Too small to tap */
}

/* Disable zoom */
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"> /* ❌ Accessibility issue */

/* Desktop-first approach */
.container {
  width: 1200px;
}
@media (max-width: 768px) {
  .container {
    width: 100%; /* ❌ More CSS to override */
  }
}
```

### Do This Instead

```css
/* Flexible widths */
.container {
  max-width: 1200px;
  width: min(90%, 1200px); /* ✅ Responsive and constrained */
}

/* Adequate touch targets */
.icon-button {
  min-width: 44px;
  min-height: 44px; /* ✅ Accessible */
}

/* Allow zoom */
<meta name="viewport" content="width=device-width, initial-scale=1"> /* ✅ Accessible */

/* Mobile-first approach */
.container {
  width: 100%;
}
@media (min-width: 768px) {
  .container {
    max-width: 1200px;
    margin: 0 auto; /* ✅ Progressive enhancement */
  }
}
```

## Recommended Breakpoints

```css
/* Mobile-first breakpoints */

/* Extra Small (Mobile) - Default */
/* 320px - 479px */

/* Small (Large Mobile) */
@media (min-width: 480px) { }
/* 480px - 767px */

/* Medium (Tablet) */
@media (min-width: 768px) { }
/* 768px - 1023px */

/* Large (Desktop) */
@media (min-width: 1024px) { }
/* 1024px - 1279px */

/* Extra Large (Wide Desktop) */
@media (min-width: 1280px) { }
/* 1280px - 1535px */

/* XXL (Ultra-wide) */
@media (min-width: 1536px) { }
/* 1536px+ */
```

## Browser Support

### Modern Features

- **Flexbox**: All modern browsers (IE 11+ with prefixes)
- **CSS Grid**: All modern browsers (IE 11 with -ms- prefix, limited)
- **Container Queries**: Chrome 105+, Safari 16+, Firefox 110+
- **Aspect-Ratio**: Chrome 88+, Safari 15+, Firefox 89+
- **clamp()**: Chrome 79+, Safari 13.1+, Firefox 75+
- **dvh/svh/lvh**: Chrome 108+, Safari 15.4+, Firefox 101+

### Fallbacks

```css
/* Provide fallbacks for older browsers */
.container {
  width: 90%; /* Fallback */
  width: min(90%, 1200px); /* Modern browsers */
}

.hero {
  min-height: 500px; /* Fallback */
  min-height: clamp(400px, 70vh, 800px); /* Modern browsers */
}

/* Feature detection with @supports */
@supports (aspect-ratio: 1) {
  .video {
    aspect-ratio: 16 / 9;
  }
}

@supports not (aspect-ratio: 1) {
  .video {
    padding-bottom: 56.25%; /* 16:9 ratio */
  }
}
```

## Additional Resources

### Documentation

- [MDN: Responsive Design](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)
- [MDN: Media Queries](https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries)
- [Web.dev: Responsive Images](https://web.dev/responsive-images/)
- [Can I Use](https://caniuse.com/) - Browser support tables

### Tools

- Chrome DevTools Device Mode
- Firefox Responsive Design Mode
- [Responsively App](https://responsively.app/) - Multi-device preview
- [BrowserStack](https://www.browserstack.com/) - Real device testing
- [Lighthouse](https://developers.google.com/web/tools/lighthouse) - Performance auditing

### Articles and Guides

- [A Complete Guide to Flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)
- [A Complete Guide to CSS Grid](https://css-tricks.com/snippets/css/complete-guide-grid/)
- [The Power of clamp()](https://web.dev/min-max-clamp/)
- [Modern Fluid Typography](https://www.smashingmagazine.com/2022/01/modern-fluid-typography-css-clamp/)

## Next Steps

1. Review the SKILL.md for comprehensive techniques and examples
2. Explore EXAMPLES.md for 20+ practical responsive patterns
3. Practice building mobile-first layouts
4. Test on real devices regularly
5. Measure performance with Lighthouse
6. Stay updated with modern CSS features

## Contributing

Found an issue or have a suggestion? This skill is part of the Claude Code skills library. Share your feedback to help improve it!

## License

This skill is part of the Claude Code skills library and follows the same license terms.
