# Responsive Design Examples

This document contains 20+ practical, production-ready responsive design examples covering common UI patterns and layouts.

## Table of Contents

1. [Responsive Navigation Patterns](#1-responsive-navigation-patterns)
2. [Hero Section Variations](#2-hero-section-variations)
3. [Card Grid Layouts](#3-card-grid-layouts)
4. [Form Layouts](#4-form-layouts)
5. [Data Table Solutions](#5-data-table-solutions)
6. [Image Gallery Patterns](#6-image-gallery-patterns)
7. [Dashboard Layouts](#7-dashboard-layouts)
8. [Sidebar Patterns](#8-sidebar-patterns)
9. [Footer Designs](#9-footer-designs)
10. [Pricing Tables](#10-pricing-tables)
11. [Feature Showcases](#11-feature-showcases)
12. [Timeline Layouts](#12-timeline-layouts)
13. [Modal and Dialog Patterns](#13-modal-and-dialog-patterns)
14. [Blog and Article Layouts](#14-blog-and-article-layouts)
15. [E-commerce Product Grids](#15-e-commerce-product-grids)
16. [Video and Media Players](#16-video-and-media-players)
17. [Tabs and Accordions](#17-tabs-and-accordions)
18. [Search and Filter Interfaces](#18-search-and-filter-interfaces)
19. [Profile and User Card](#19-profile-and-user-card)
20. [Notification and Alert Patterns](#20-notification-and-alert-patterns)

---

## 1. Responsive Navigation Patterns

### Example 1.1: Hamburger to Horizontal Nav

```html
<nav class="navbar">
  <div class="navbar-brand">
    <a href="/" class="logo">Logo</a>
    <button class="nav-toggle" aria-label="Toggle navigation">
      <span></span>
      <span></span>
      <span></span>
    </button>
  </div>

  <ul class="nav-menu">
    <li><a href="#" class="nav-link">Home</a></li>
    <li><a href="#" class="nav-link">About</a></li>
    <li><a href="#" class="nav-link">Services</a></li>
    <li><a href="#" class="nav-link">Contact</a></li>
  </ul>
</nav>
```

```css
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem clamp(1rem, 3vw, 2rem);
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.navbar-brand {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

@media (min-width: 768px) {
  .navbar-brand {
    width: auto;
  }
}

.logo {
  font-size: 1.5rem;
  font-weight: 700;
  text-decoration: none;
  color: #333;
}

.nav-toggle {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 0.5rem;
  background: none;
  border: none;
  cursor: pointer;
}

.nav-toggle span {
  width: 25px;
  height: 3px;
  background: #333;
  transition: all 0.3s;
  border-radius: 2px;
}

.nav-toggle.active span:nth-child(1) {
  transform: rotate(45deg) translate(5px, 5px);
}

.nav-toggle.active span:nth-child(2) {
  opacity: 0;
}

.nav-toggle.active span:nth-child(3) {
  transform: rotate(-45deg) translate(7px, -6px);
}

@media (min-width: 768px) {
  .nav-toggle {
    display: none;
  }
}

.nav-menu {
  display: none;
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  flex-direction: column;
  background: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-menu.active {
  display: flex;
}

@media (min-width: 768px) {
  .nav-menu {
    display: flex;
    position: static;
    flex-direction: row;
    box-shadow: none;
    gap: clamp(1rem, 3vw, 2.5rem);
  }
}

.nav-link {
  display: block;
  padding: 1rem 1.5rem;
  text-decoration: none;
  color: #333;
  transition: background-color 0.2s;
}

@media (min-width: 768px) {
  .nav-link {
    padding: 0.5rem 0;
  }
}

.nav-link:hover {
  background-color: #f5f5f5;
}

@media (min-width: 768px) {
  .nav-link:hover {
    background-color: transparent;
    color: #0066cc;
  }
}
```

### Example 1.2: Mega Menu Navigation

```html
<nav class="mega-nav">
  <div class="mega-nav-container">
    <a href="/" class="mega-logo">Brand</a>

    <ul class="mega-menu">
      <li class="mega-item">
        <a href="#" class="mega-link">Products</a>
        <div class="mega-dropdown">
          <div class="mega-dropdown-grid">
            <div class="mega-column">
              <h3>Category 1</h3>
              <ul>
                <li><a href="#">Product A</a></li>
                <li><a href="#">Product B</a></li>
                <li><a href="#">Product C</a></li>
              </ul>
            </div>
            <div class="mega-column">
              <h3>Category 2</h3>
              <ul>
                <li><a href="#">Product D</a></li>
                <li><a href="#">Product E</a></li>
                <li><a href="#">Product F</a></li>
              </ul>
            </div>
          </div>
        </div>
      </li>
      <li class="mega-item">
        <a href="#" class="mega-link">Solutions</a>
      </li>
      <li class="mega-item">
        <a href="#" class="mega-link">Resources</a>
      </li>
    </ul>
  </div>
</nav>
```

```css
.mega-nav {
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.mega-nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem clamp(1rem, 3vw, 2rem);
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
}

.mega-logo {
  font-size: 1.5rem;
  font-weight: 700;
  text-decoration: none;
  color: #333;
}

.mega-menu {
  display: flex;
  list-style: none;
  padding: 0;
  margin: 0;
  gap: 2rem;
  flex-wrap: wrap;
  width: 100%;
  margin-top: 1rem;
}

@media (min-width: 768px) {
  .mega-menu {
    width: auto;
    margin-top: 0;
  }
}

.mega-item {
  position: relative;
}

.mega-link {
  text-decoration: none;
  color: #333;
  font-weight: 500;
  padding: 0.5rem 0;
  display: block;
}

.mega-dropdown {
  display: none;
  position: static;
  background: white;
  margin-top: 1rem;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

@media (min-width: 768px) {
  .mega-dropdown {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-top: 0.5rem;
    min-width: 600px;
  }
}

.mega-item:hover .mega-dropdown {
  display: block;
}

.mega-dropdown-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  padding: 2rem;
}

@media (min-width: 768px) {
  .mega-dropdown-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

.mega-column h3 {
  margin-bottom: 1rem;
  font-size: 1rem;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.mega-column ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.mega-column li {
  margin-bottom: 0.75rem;
}

.mega-column a {
  text-decoration: none;
  color: #333;
  transition: color 0.2s;
}

.mega-column a:hover {
  color: #0066cc;
}
```

---

## 2. Hero Section Variations

### Example 2.1: Split Hero with Image

```html
<section class="split-hero">
  <div class="split-hero-content">
    <h1 class="split-hero-title">Build Amazing Products</h1>
    <p class="split-hero-subtitle">Create stunning websites with modern tools and frameworks</p>
    <div class="split-hero-actions">
      <button class="btn btn-primary">Get Started</button>
      <button class="btn btn-secondary">Learn More</button>
    </div>
  </div>
  <div class="split-hero-image">
    <img src="hero.jpg" alt="Hero image" />
  </div>
</section>
```

```css
.split-hero {
  display: grid;
  grid-template-columns: 1fr;
  min-height: clamp(500px, 70vh, 800px);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

@media (min-width: 768px) {
  .split-hero {
    grid-template-columns: 1fr 1fr;
  }
}

.split-hero-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: clamp(2rem, 5vw, 4rem);
  text-align: center;
}

@media (min-width: 768px) {
  .split-hero-content {
    text-align: left;
  }
}

.split-hero-title {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
  margin-bottom: 1rem;
  line-height: 1.1;
  font-weight: 700;
}

.split-hero-subtitle {
  font-size: clamp(1.125rem, 2vw + 0.5rem, 1.5rem);
  margin-bottom: 2rem;
  opacity: 0.95;
  line-height: 1.5;
}

.split-hero-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  justify-content: center;
}

@media (min-width: 768px) {
  .split-hero-actions {
    justify-content: flex-start;
  }
}

.btn {
  padding: 1rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  display: inline-block;
  min-height: 44px;
}

.btn-primary {
  background: white;
  color: #667eea;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid white;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.3);
}

.split-hero-image {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  order: -1;
}

@media (min-width: 768px) {
  .split-hero-image {
    order: 0;
  }
}

.split-hero-image img {
  max-width: 100%;
  height: auto;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
}
```

### Example 2.2: Full-Width Background Hero

```html
<section class="fullwidth-hero">
  <div class="fullwidth-hero-overlay"></div>
  <div class="fullwidth-hero-content">
    <h1>Welcome to Our Platform</h1>
    <p>Transform your ideas into reality</p>
    <button class="hero-cta">Start Free Trial</button>
  </div>
</section>
```

```css
.fullwidth-hero {
  position: relative;
  min-height: clamp(500px, 80vh, 900px);
  display: flex;
  align-items: center;
  justify-content: center;
  background-image: url('hero-mobile.jpg');
  background-size: cover;
  background-position: center;
  color: white;
  overflow: hidden;
}

@media (min-width: 768px) {
  .fullwidth-hero {
    background-image: url('hero-tablet.jpg');
  }
}

@media (min-width: 1024px) {
  .fullwidth-hero {
    background-image: url('hero-desktop.jpg');
  }
}

@media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
  .fullwidth-hero {
    background-image: url('hero-mobile@2x.jpg');
  }

  @media (min-width: 768px) {
    .fullwidth-hero {
      background-image: url('hero-tablet@2x.jpg');
    }
  }

  @media (min-width: 1024px) {
    .fullwidth-hero {
      background-image: url('hero-desktop@2x.jpg');
    }
  }
}

.fullwidth-hero-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(
    135deg,
    rgba(102, 126, 234, 0.8) 0%,
    rgba(118, 75, 162, 0.8) 100%
  );
}

.fullwidth-hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
  padding: 2rem;
  max-width: 800px;
}

.fullwidth-hero h1 {
  font-size: clamp(2.5rem, 6vw + 1rem, 5rem);
  margin-bottom: 1.5rem;
  font-weight: 700;
  line-height: 1.1;
}

.fullwidth-hero p {
  font-size: clamp(1.25rem, 3vw + 0.5rem, 2rem);
  margin-bottom: 2.5rem;
  opacity: 0.95;
}

.hero-cta {
  padding: 1.25rem 3rem;
  background: white;
  color: #667eea;
  border: none;
  border-radius: 50px;
  font-size: 1.125rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  min-height: 44px;
}

.hero-cta:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
}
```

---

## 3. Card Grid Layouts

### Example 3.1: Auto-Responsive Card Grid

```html
<div class="card-grid">
  <article class="card">
    <img src="card1.jpg" alt="Card image" class="card-image" loading="lazy" />
    <div class="card-content">
      <h3 class="card-title">Card Title</h3>
      <p class="card-description">Brief description of the card content goes here.</p>
      <a href="#" class="card-link">Read More</a>
    </div>
  </article>
  <!-- More cards -->
</div>
```

```css
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: clamp(1.5rem, 3vw, 2.5rem);
  padding: clamp(1.5rem, 3vw, 2.5rem);
  max-width: 1400px;
  margin: 0 auto;
}

.card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
}

@media (hover: hover) {
  .card:hover {
    transform: translateY(-8px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }
}

.card-image {
  width: 100%;
  aspect-ratio: 16 / 9;
  object-fit: cover;
  display: block;
}

.card-content {
  padding: 1.5rem;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-title {
  font-size: clamp(1.25rem, 2vw + 0.5rem, 1.75rem);
  margin-bottom: 0.75rem;
  color: #333;
  line-height: 1.2;
}

.card-description {
  color: #666;
  line-height: 1.6;
  margin-bottom: 1.5rem;
  flex: 1;
}

.card-link {
  color: #0066cc;
  text-decoration: none;
  font-weight: 600;
  align-self: flex-start;
  padding: 0.5rem 0;
  transition: color 0.2s;
}

.card-link:hover {
  color: #0052a3;
  text-decoration: underline;
}
```

### Example 3.2: Featured Card Layout

```html
<div class="featured-grid">
  <article class="featured-card featured">
    <!-- Featured card content -->
  </article>
  <article class="featured-card">
    <!-- Regular card content -->
  </article>
  <!-- More cards -->
</div>
```

```css
.featured-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

@media (min-width: 768px) {
  .featured-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .featured-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

.featured-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.featured-card.featured {
  grid-column: 1 / -1;
}

@media (min-width: 768px) {
  .featured-card.featured {
    grid-column: 1 / -1;
  }
}

@media (min-width: 1024px) {
  .featured-card.featured {
    grid-column: 1 / 3;
    grid-row: span 2;
  }
}
```

---

## 4. Form Layouts

### Example 4.1: Multi-Column Responsive Form

```html
<form class="responsive-form">
  <div class="form-grid">
    <div class="form-group">
      <label for="firstName">First Name</label>
      <input type="text" id="firstName" required />
    </div>

    <div class="form-group">
      <label for="lastName">Last Name</label>
      <input type="text" id="lastName" required />
    </div>

    <div class="form-group full-width">
      <label for="email">Email</label>
      <input type="email" id="email" required />
    </div>

    <div class="form-group full-width">
      <label for="message">Message</label>
      <textarea id="message" rows="5"></textarea>
    </div>

    <div class="form-group full-width">
      <button type="submit" class="form-submit">Submit</button>
    </div>
  </div>
</form>
```

```css
.responsive-form {
  max-width: 800px;
  margin: 0 auto;
  padding: clamp(1.5rem, 3vw, 2.5rem);
}

.form-grid {
  display: grid;
  gap: 1.5rem;
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .form-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-group label {
  font-weight: 600;
  color: #333;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.form-group input,
.form-group textarea,
.form-group select {
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  transition: border-color 0.2s;
  min-height: 44px;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: #0066cc;
}

.form-group textarea {
  resize: vertical;
  min-height: 120px;
}

.form-submit {
  width: 100%;
  padding: 1.25rem 2rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  min-height: 44px;
}

.form-submit:hover {
  background: #0052a3;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 102, 204, 0.3);
}

@media (hover: none) and (pointer: coarse) {
  .form-submit {
    padding: 1.5rem 2rem;
  }
}
```

### Example 4.2: Stepped Form Layout

```html
<div class="stepped-form">
  <div class="form-steps">
    <div class="step active">1. Personal Info</div>
    <div class="step">2. Address</div>
    <div class="step">3. Payment</div>
  </div>

  <form class="step-content">
    <!-- Step content -->
  </form>

  <div class="form-actions">
    <button class="btn-secondary">Previous</button>
    <button class="btn-primary">Next</button>
  </div>
</div>
```

```css
.stepped-form {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}

.form-steps {
  display: flex;
  margin-bottom: 3rem;
  position: relative;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
}

@media (min-width: 768px) {
  .form-steps::before {
    content: '';
    position: absolute;
    top: 50%;
    left: 0;
    right: 0;
    height: 2px;
    background: #e0e0e0;
    z-index: -1;
  }
}

.step {
  flex: 1;
  text-align: center;
  padding: 1rem;
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-weight: 600;
  color: #999;
  transition: all 0.3s;
  min-width: 120px;
}

.step.active {
  border-color: #0066cc;
  color: #0066cc;
  background: #f0f7ff;
}

.step.completed {
  border-color: #00cc66;
  color: #00cc66;
  background: #f0fff7;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  margin-top: 2rem;
  flex-wrap: wrap;
}

.form-actions button {
  flex: 1;
  min-width: 120px;
}

@media (max-width: 479px) {
  .form-actions {
    flex-direction: column;
  }

  .form-actions button {
    width: 100%;
  }
}
```

---

## 5. Data Table Solutions

### Example 5.1: Card-Based Mobile Table

```html
<div class="table-wrapper">
  <table class="responsive-table">
    <thead>
      <tr>
        <th>Name</th>
        <th>Email</th>
        <th>Role</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td data-label="Name">John Doe</td>
        <td data-label="Email">john@example.com</td>
        <td data-label="Role">Admin</td>
        <td data-label="Status"><span class="status-active">Active</span></td>
        <td data-label="Actions">
          <button class="btn-small">Edit</button>
        </td>
      </tr>
      <!-- More rows -->
    </tbody>
  </table>
</div>
```

```css
.table-wrapper {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  margin: 2rem 0;
}

.responsive-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  overflow: hidden;
}

.responsive-table thead {
  background: #f5f5f5;
}

.responsive-table th {
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  color: #333;
  white-space: nowrap;
}

.responsive-table td {
  padding: 1rem;
  border-top: 1px solid #e0e0e0;
}

@media (max-width: 767px) {
  .responsive-table thead {
    position: absolute;
    top: -9999px;
    left: -9999px;
  }

  .responsive-table tbody tr {
    display: block;
    margin-bottom: 1.5rem;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    overflow: hidden;
  }

  .responsive-table td {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    border-top: 1px solid #f0f0f0;
  }

  .responsive-table td:first-child {
    background: #f5f5f5;
    font-weight: 600;
    border-top: none;
  }

  .responsive-table td::before {
    content: attr(data-label);
    font-weight: 600;
    color: #666;
    flex: 0 0 40%;
  }
}

.status-active {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background: #00cc66;
  color: white;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
}

.btn-small {
  padding: 0.5rem 1rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  min-height: 36px;
}
```

### Example 5.2: Horizontal Scroll Table

```html
<div class="scroll-table-container">
  <div class="scroll-hint">← Scroll for more →</div>
  <div class="scroll-table-wrapper">
    <table class="scroll-table">
      <!-- Table content -->
    </table>
  </div>
</div>
```

```css
.scroll-table-container {
  position: relative;
  margin: 2rem 0;
}

.scroll-hint {
  display: none;
  text-align: center;
  padding: 0.5rem;
  background: #fff3cd;
  color: #856404;
  font-size: 0.875rem;
  border-radius: 4px 4px 0 0;
}

@media (max-width: 1023px) {
  .scroll-hint {
    display: block;
  }
}

.scroll-table-wrapper {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
}

.scroll-table {
  width: 100%;
  min-width: 800px;
  border-collapse: collapse;
  background: white;
}

.scroll-table th,
.scroll-table td {
  padding: 1rem;
  text-align: left;
  white-space: nowrap;
}

.scroll-table th {
  background: #f5f5f5;
  font-weight: 600;
  position: sticky;
  top: 0;
  z-index: 10;
}

.scroll-table th:first-child,
.scroll-table td:first-child {
  position: sticky;
  left: 0;
  background: white;
  z-index: 5;
}

.scroll-table th:first-child {
  z-index: 15;
  background: #f5f5f5;
}

.scroll-table td {
  border-top: 1px solid #e0e0e0;
}
```

---

## 6. Image Gallery Patterns

### Example 6.1: Masonry Gallery

```html
<div class="masonry-gallery">
  <div class="masonry-item">
    <img src="image1.jpg" alt="Gallery image" loading="lazy" />
    <div class="masonry-caption">
      <h3>Image Title</h3>
      <p>Description</p>
    </div>
  </div>
  <!-- More items -->
</div>
```

```css
.masonry-gallery {
  column-count: 1;
  column-gap: 1.5rem;
  padding: 1.5rem;
}

@media (min-width: 480px) {
  .masonry-gallery {
    column-count: 2;
  }
}

@media (min-width: 768px) {
  .masonry-gallery {
    column-count: 3;
  }
}

@media (min-width: 1024px) {
  .masonry-gallery {
    column-count: 4;
  }
}

@media (min-width: 1280px) {
  .masonry-gallery {
    column-count: 5;
  }
}

.masonry-item {
  break-inside: avoid;
  margin-bottom: 1.5rem;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
  cursor: pointer;
}

@media (hover: hover) {
  .masonry-item:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }
}

.masonry-item img {
  width: 100%;
  display: block;
  transition: transform 0.3s;
}

@media (hover: hover) {
  .masonry-item:hover img {
    transform: scale(1.05);
  }
}

.masonry-caption {
  padding: 1rem;
}

.masonry-caption h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
  color: #333;
}

.masonry-caption p {
  margin: 0;
  font-size: 0.875rem;
  color: #666;
}
```

### Example 6.2: Grid Gallery with Lightbox

```html
<div class="grid-gallery">
  <figure class="gallery-figure">
    <img src="thumbnail.jpg" alt="Gallery image" loading="lazy" />
    <figcaption>Image caption</figcaption>
  </figure>
  <!-- More figures -->
</div>
```

```css
.grid-gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
  padding: 1rem;
}

@media (min-width: 768px) {
  .grid-gallery {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1.5rem;
  }
}

.gallery-figure {
  position: relative;
  margin: 0;
  aspect-ratio: 1;
  overflow: hidden;
  border-radius: 8px;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.gallery-figure img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

@media (hover: hover) {
  .gallery-figure:hover img {
    transform: scale(1.1);
  }
}

.gallery-figure figcaption {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 1rem;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.8), transparent);
  color: white;
  font-size: 0.875rem;
  transform: translateY(100%);
  transition: transform 0.3s;
}

@media (hover: hover) {
  .gallery-figure:hover figcaption {
    transform: translateY(0);
  }
}

@media (hover: none) {
  .gallery-figure figcaption {
    transform: translateY(0);
  }
}
```

---

## 7. Dashboard Layouts

### Example 7.1: Admin Dashboard

```html
<div class="dashboard">
  <aside class="dashboard-sidebar">
    <!-- Sidebar content -->
  </aside>

  <main class="dashboard-main">
    <div class="dashboard-stats">
      <div class="stat-card">
        <div class="stat-value">1,234</div>
        <div class="stat-label">Total Users</div>
      </div>
      <!-- More stat cards -->
    </div>

    <div class="dashboard-charts">
      <div class="chart-card">
        <h3>Revenue</h3>
        <!-- Chart content -->
      </div>
      <!-- More charts -->
    </div>
  </main>
</div>
```

```css
.dashboard {
  display: grid;
  grid-template-columns: 1fr;
  min-height: 100vh;
  background: #f5f7fa;
}

@media (min-width: 1024px) {
  .dashboard {
    grid-template-columns: 260px 1fr;
  }
}

.dashboard-sidebar {
  background: #1a1a1a;
  color: white;
  padding: 2rem 1rem;
  position: fixed;
  left: -100%;
  top: 0;
  height: 100vh;
  width: 260px;
  transition: left 0.3s;
  z-index: 1000;
  overflow-y: auto;
}

.dashboard-sidebar.open {
  left: 0;
}

@media (min-width: 1024px) {
  .dashboard-sidebar {
    position: static;
    left: 0;
  }
}

.dashboard-main {
  padding: clamp(1rem, 3vw, 2rem);
}

.dashboard-stats {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

@media (min-width: 480px) {
  .dashboard-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .dashboard-stats {
    grid-template-columns: repeat(4, 1fr);
  }
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.stat-value {
  font-size: clamp(1.75rem, 3vw + 1rem, 2.5rem);
  font-weight: 700;
  color: #333;
  margin-bottom: 0.5rem;
}

.stat-label {
  font-size: 0.875rem;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.dashboard-charts {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;
}

@media (min-width: 768px) {
  .dashboard-charts {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1280px) {
  .dashboard-charts {
    grid-template-columns: 2fr 1fr;
  }
}

.chart-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.chart-card h3 {
  margin: 0 0 1.5rem 0;
  font-size: 1.125rem;
  color: #333;
}
```

---

## 8. Sidebar Patterns

### Example 8.1: Collapsible Sidebar

```html
<div class="layout-with-sidebar">
  <button class="sidebar-toggle">
    <span></span>
    <span></span>
    <span></span>
  </button>

  <aside class="collapsible-sidebar">
    <nav>
      <!-- Navigation content -->
    </nav>
  </aside>

  <main class="main-content">
    <!-- Main content -->
  </main>

  <div class="sidebar-overlay"></div>
</div>
```

```css
.layout-with-sidebar {
  display: grid;
  grid-template-columns: 1fr;
  min-height: 100vh;
  position: relative;
}

@media (min-width: 1024px) {
  .layout-with-sidebar {
    grid-template-columns: 280px 1fr;
  }
}

.sidebar-toggle {
  position: fixed;
  top: 1rem;
  left: 1rem;
  z-index: 1001;
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 0.75rem;
  background: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

@media (min-width: 1024px) {
  .sidebar-toggle {
    display: none;
  }
}

.sidebar-toggle span {
  width: 24px;
  height: 3px;
  background: #333;
  transition: all 0.3s;
  border-radius: 2px;
}

.collapsible-sidebar {
  position: fixed;
  left: -100%;
  top: 0;
  height: 100vh;
  width: 280px;
  background: #f5f5f5;
  padding: 2rem;
  transition: left 0.3s;
  z-index: 1000;
  overflow-y: auto;
}

.collapsible-sidebar.open {
  left: 0;
}

@media (min-width: 1024px) {
  .collapsible-sidebar {
    position: static;
    left: 0;
  }
}

.main-content {
  padding: clamp(1.5rem, 3vw, 3rem);
}

.sidebar-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

.sidebar-overlay.active {
  display: block;
}

@media (min-width: 1024px) {
  .sidebar-overlay {
    display: none !important;
  }
}
```

---

## 9. Footer Designs

### Example 9.1: Multi-Column Footer

```html
<footer class="site-footer">
  <div class="footer-content">
    <div class="footer-column">
      <h3>About Us</h3>
      <p>Company description goes here.</p>
    </div>

    <div class="footer-column">
      <h3>Quick Links</h3>
      <ul>
        <li><a href="#">Home</a></li>
        <li><a href="#">About</a></li>
        <li><a href="#">Services</a></li>
      </ul>
    </div>

    <div class="footer-column">
      <h3>Contact</h3>
      <p>Email: info@example.com</p>
    </div>

    <div class="footer-column">
      <h3>Newsletter</h3>
      <form class="newsletter-form">
        <input type="email" placeholder="Your email" />
        <button type="submit">Subscribe</button>
      </form>
    </div>
  </div>

  <div class="footer-bottom">
    <p>&copy; 2024 Company Name. All rights reserved.</p>
    <div class="footer-social">
      <a href="#">Facebook</a>
      <a href="#">Twitter</a>
      <a href="#">LinkedIn</a>
    </div>
  </div>
</footer>
```

```css
.site-footer {
  background: #1a1a1a;
  color: white;
  padding: clamp(2rem, 5vw, 4rem) clamp(1rem, 3vw, 2rem);
  margin-top: auto;
}

.footer-content {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto 3rem;
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
    grid-template-columns: 2fr 1fr 1fr 1.5fr;
  }
}

.footer-column h3 {
  margin-bottom: 1rem;
  font-size: 1.125rem;
  color: white;
}

.footer-column p {
  color: #b0b0b0;
  line-height: 1.6;
}

.footer-column ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.footer-column li {
  margin-bottom: 0.75rem;
}

.footer-column a {
  color: #b0b0b0;
  text-decoration: none;
  transition: color 0.2s;
}

.footer-column a:hover {
  color: white;
}

.newsletter-form {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.newsletter-form input {
  flex: 1;
  min-width: 200px;
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 4px;
  font-size: 0.875rem;
}

.newsletter-form button {
  padding: 0.75rem 1.5rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
  transition: background-color 0.2s;
}

.newsletter-form button:hover {
  background: #0052a3;
}

.footer-bottom {
  max-width: 1200px;
  margin: 0 auto;
  padding-top: 2rem;
  border-top: 1px solid #333;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  align-items: center;
  text-align: center;
}

@media (min-width: 768px) {
  .footer-bottom {
    flex-direction: row;
    justify-content: space-between;
    text-align: left;
  }
}

.footer-bottom p {
  color: #b0b0b0;
  margin: 0;
}

.footer-social {
  display: flex;
  gap: 1.5rem;
}

.footer-social a {
  color: #b0b0b0;
  text-decoration: none;
  transition: color 0.2s;
}

.footer-social a:hover {
  color: white;
}
```

---

## 10. Pricing Tables

### Example 10.1: Three-Tier Pricing

```html
<div class="pricing-section">
  <h2 class="pricing-heading">Choose Your Plan</h2>

  <div class="pricing-grid">
    <div class="pricing-card">
      <div class="pricing-header">
        <h3>Basic</h3>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">9</span>
          <span class="period">/month</span>
        </div>
      </div>

      <ul class="pricing-features">
        <li>10 Projects</li>
        <li>2 GB Storage</li>
        <li>Email Support</li>
      </ul>

      <button class="pricing-button">Get Started</button>
    </div>

    <div class="pricing-card featured">
      <div class="badge">Popular</div>
      <div class="pricing-header">
        <h3>Pro</h3>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">29</span>
          <span class="period">/month</span>
        </div>
      </div>

      <ul class="pricing-features">
        <li>Unlimited Projects</li>
        <li>10 GB Storage</li>
        <li>Priority Support</li>
        <li>Advanced Analytics</li>
      </ul>

      <button class="pricing-button">Get Started</button>
    </div>

    <div class="pricing-card">
      <div class="pricing-header">
        <h3>Enterprise</h3>
        <div class="price">
          <span class="currency">$</span>
          <span class="amount">99</span>
          <span class="period">/month</span>
        </div>
      </div>

      <ul class="pricing-features">
        <li>Unlimited Everything</li>
        <li>100 GB Storage</li>
        <li>24/7 Phone Support</li>
        <li>Custom Integration</li>
        <li>Dedicated Manager</li>
      </ul>

      <button class="pricing-button">Contact Sales</button>
    </div>
  </div>
</div>
```

```css
.pricing-section {
  padding: clamp(3rem, 8vw, 6rem) clamp(1.5rem, 3vw, 2rem);
  max-width: 1400px;
  margin: 0 auto;
}

.pricing-heading {
  text-align: center;
  font-size: clamp(2rem, 4vw + 1rem, 3rem);
  margin-bottom: 3rem;
  color: #333;
}

.pricing-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

@media (min-width: 768px) {
  .pricing-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .pricing-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

.pricing-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  position: relative;
  transition: all 0.3s;
}

@media (hover: hover) {
  .pricing-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  }
}

.pricing-card.featured {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

@media (min-width: 1024px) {
  .pricing-card.featured {
    transform: scale(1.05);
  }
}

.badge {
  position: absolute;
  top: -12px;
  right: 2rem;
  background: #ff6b6b;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
}

.pricing-header {
  text-align: center;
  margin-bottom: 2rem;
}

.pricing-header h3 {
  font-size: clamp(1.5rem, 3vw + 0.5rem, 2rem);
  margin-bottom: 1rem;
}

.price {
  display: flex;
  align-items: flex-start;
  justify-content: center;
  gap: 0.25rem;
}

.currency {
  font-size: 1.5rem;
  font-weight: 600;
}

.amount {
  font-size: clamp(2.5rem, 5vw + 1rem, 4rem);
  font-weight: 700;
  line-height: 1;
}

.period {
  font-size: 1rem;
  opacity: 0.8;
  align-self: flex-end;
  padding-bottom: 0.5rem;
}

.pricing-features {
  list-style: none;
  padding: 0;
  margin: 0 0 2rem 0;
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
  padding: 1.25rem 2rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.pricing-card.featured .pricing-button {
  background: white;
  color: #667eea;
}

.pricing-button:hover {
  background: #0052a3;
  transform: translateY(-2px);
}

.pricing-card.featured .pricing-button:hover {
  background: #f0f0f0;
}
```

---

## 11. Feature Showcases

### Example 11.1: Icon Feature Grid

```html
<section class="features-section">
  <h2>Our Features</h2>
  <div class="features-grid">
    <div class="feature-card">
      <div class="feature-icon">
        <svg><!-- Icon --></svg>
      </div>
      <h3>Fast Performance</h3>
      <p>Lightning-fast load times for optimal user experience.</p>
    </div>
    <!-- More feature cards -->
  </div>
</section>
```

```css
.features-section {
  padding: clamp(3rem, 8vw, 6rem) clamp(1.5rem, 3vw, 2rem);
  max-width: 1400px;
  margin: 0 auto;
}

.features-section h2 {
  text-align: center;
  font-size: clamp(2rem, 4vw + 1rem, 3rem);
  margin-bottom: 3rem;
  color: #333;
}

.features-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
}

@media (min-width: 768px) {
  .features-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .features-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

.feature-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  text-align: center;
  transition: all 0.3s;
}

@media (hover: hover) {
  .feature-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }
}

.feature-icon {
  width: 80px;
  height: 80px;
  margin: 0 auto 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.feature-card h3 {
  font-size: clamp(1.25rem, 2vw + 0.5rem, 1.5rem);
  margin-bottom: 1rem;
  color: #333;
}

.feature-card p {
  color: #666;
  line-height: 1.6;
}
```

---

## 12. Timeline Layouts

### Example 12.1: Vertical Timeline

```html
<div class="timeline">
  <div class="timeline-item">
    <div class="timeline-marker"></div>
    <div class="timeline-content">
      <span class="timeline-date">2024</span>
      <h3>Achievement Title</h3>
      <p>Description of the achievement or milestone.</p>
    </div>
  </div>
  <!-- More timeline items -->
</div>
```

```css
.timeline {
  max-width: 900px;
  margin: 3rem auto;
  padding: 2rem 1rem;
  position: relative;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 30px;
  top: 0;
  bottom: 0;
  width: 3px;
  background: linear-gradient(to bottom, #667eea, #764ba2);
}

@media (min-width: 768px) {
  .timeline::before {
    left: 50%;
    transform: translateX(-50%);
  }
}

.timeline-item {
  position: relative;
  margin-bottom: 3rem;
  padding-left: 80px;
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

.timeline-marker {
  position: absolute;
  left: 21px;
  top: 0;
  width: 20px;
  height: 20px;
  background: #667eea;
  border-radius: 50%;
  border: 4px solid white;
  box-shadow: 0 0 0 3px #667eea;
  z-index: 1;
}

@media (min-width: 768px) {
  .timeline-marker {
    left: auto;
    right: -10px;
  }

  .timeline-item:nth-child(even) .timeline-marker {
    right: auto;
    left: -10px;
  }
}

.timeline-content {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.timeline-date {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background: #667eea;
  color: white;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
}

.timeline-content h3 {
  font-size: 1.25rem;
  margin-bottom: 0.75rem;
  color: #333;
}

.timeline-content p {
  color: #666;
  line-height: 1.6;
}
```

---

## 13. Modal and Dialog Patterns

### Example 13.1: Responsive Modal

```html
<div class="modal-overlay" id="modal">
  <div class="modal-container">
    <button class="modal-close">&times;</button>
    <div class="modal-header">
      <h2>Modal Title</h2>
    </div>
    <div class="modal-body">
      <p>Modal content goes here.</p>
    </div>
    <div class="modal-footer">
      <button class="btn-secondary">Cancel</button>
      <button class="btn-primary">Confirm</button>
    </div>
  </div>
</div>
```

```css
.modal-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  z-index: 1000;
  padding: 1rem;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

.modal-overlay.active {
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-container {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  margin: auto;
}

@media (min-width: 768px) {
  .modal-container {
    max-height: 80vh;
  }
}

.modal-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #666;
  line-height: 1;
  padding: 0.5rem;
  min-width: 44px;
  min-height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: all 0.2s;
}

.modal-close:hover {
  background: #f0f0f0;
  color: #333;
}

.modal-header {
  padding: 2rem 2rem 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.modal-header h2 {
  margin: 0;
  font-size: clamp(1.5rem, 3vw + 0.5rem, 2rem);
  color: #333;
  padding-right: 3rem;
}

.modal-body {
  padding: 2rem;
}

.modal-body p {
  color: #666;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.modal-footer {
  padding: 1rem 2rem 2rem;
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  flex-wrap: wrap;
}

@media (max-width: 479px) {
  .modal-footer {
    flex-direction: column-reverse;
  }

  .modal-footer button {
    width: 100%;
  }
}
```

---

## 14. Blog and Article Layouts

### Example 14.1: Article Grid with Sidebar

```html
<div class="blog-layout">
  <main class="blog-main">
    <article class="blog-post">
      <img src="post-image.jpg" alt="Post image" />
      <div class="blog-post-content">
        <span class="blog-post-date">October 17, 2024</span>
        <h2>Article Title</h2>
        <p>Article excerpt goes here...</p>
        <a href="#" class="read-more">Read More</a>
      </div>
    </article>
    <!-- More posts -->
  </main>

  <aside class="blog-sidebar">
    <div class="sidebar-widget">
      <h3>Categories</h3>
      <ul>
        <li><a href="#">Design</a></li>
        <li><a href="#">Development</a></li>
      </ul>
    </div>
  </aside>
</div>
```

```css
.blog-layout {
  display: grid;
  grid-template-columns: 1fr;
  gap: 3rem;
  max-width: 1400px;
  margin: 0 auto;
  padding: clamp(2rem, 4vw, 3rem);
}

@media (min-width: 1024px) {
  .blog-layout {
    grid-template-columns: 2fr 1fr;
  }
}

.blog-main {
  display: grid;
  gap: 2rem;
}

.blog-post {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: grid;
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .blog-post {
    grid-template-columns: 300px 1fr;
  }
}

.blog-post img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  min-height: 250px;
}

@media (min-width: 768px) {
  .blog-post img {
    min-height: auto;
  }
}

.blog-post-content {
  padding: 2rem;
}

.blog-post-date {
  display: inline-block;
  color: #666;
  font-size: 0.875rem;
  margin-bottom: 0.75rem;
}

.blog-post h2 {
  font-size: clamp(1.5rem, 3vw + 0.5rem, 2rem);
  margin-bottom: 1rem;
  color: #333;
}

.blog-post p {
  color: #666;
  line-height: 1.6;
  margin-bottom: 1.5rem;
}

.read-more {
  color: #0066cc;
  text-decoration: none;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.read-more:hover {
  text-decoration: underline;
}

.blog-sidebar {
  display: grid;
  gap: 2rem;
  align-content: start;
}

.sidebar-widget {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.sidebar-widget h3 {
  font-size: 1.25rem;
  margin-bottom: 1.5rem;
  color: #333;
}

.sidebar-widget ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.sidebar-widget li {
  margin-bottom: 0.75rem;
}

.sidebar-widget a {
  color: #666;
  text-decoration: none;
  transition: color 0.2s;
}

.sidebar-widget a:hover {
  color: #0066cc;
}
```

---

## 15. E-commerce Product Grids

### Example 15.1: Product Catalog Grid

```html
<div class="product-grid">
  <div class="product-card">
    <div class="product-image">
      <img src="product.jpg" alt="Product" loading="lazy" />
      <button class="wishlist-btn" aria-label="Add to wishlist">
        <svg><!-- Heart icon --></svg>
      </button>
    </div>
    <div class="product-info">
      <span class="product-category">Category</span>
      <h3 class="product-name">Product Name</h3>
      <div class="product-rating">
        <span>★★★★☆</span>
        <span class="rating-count">(24)</span>
      </div>
      <div class="product-price">
        <span class="price-current">$29.99</span>
        <span class="price-original">$39.99</span>
      </div>
      <button class="add-to-cart">Add to Cart</button>
    </div>
  </div>
  <!-- More products -->
</div>
```

```css
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(250px, 100%), 1fr));
  gap: clamp(1.5rem, 3vw, 2.5rem);
  padding: clamp(1.5rem, 3vw, 2.5rem);
  max-width: 1600px;
  margin: 0 auto;
}

.product-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
}

@media (hover: hover) {
  .product-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }
}

.product-image {
  position: relative;
  aspect-ratio: 1;
  overflow: hidden;
  background: #f5f5f5;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

@media (hover: hover) {
  .product-card:hover .product-image img {
    transform: scale(1.1);
  }
}

.wishlist-btn {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 40px;
  height: 40px;
  background: white;
  border: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
}

.wishlist-btn:hover {
  transform: scale(1.1);
  background: #ff6b6b;
  color: white;
}

.product-info {
  padding: 1.5rem;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.product-category {
  font-size: 0.75rem;
  color: #999;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.5rem;
}

.product-name {
  font-size: 1rem;
  margin-bottom: 0.75rem;
  color: #333;
  line-height: 1.3;
}

.product-rating {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  color: #ffa500;
}

.rating-count {
  font-size: 0.875rem;
  color: #999;
}

.product-price {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.price-current {
  font-size: 1.5rem;
  font-weight: 700;
  color: #333;
}

.price-original {
  font-size: 1rem;
  color: #999;
  text-decoration: line-through;
}

.add-to-cart {
  width: 100%;
  padding: 1rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: auto;
}

.add-to-cart:hover {
  background: #0052a3;
}
```

---

## 16. Video and Media Players

### Example 16.1: Responsive Video Player

```html
<div class="video-container">
  <video class="responsive-video" controls poster="poster.jpg">
    <source src="video.mp4" type="video/mp4">
    <source src="video.webm" type="video/webm">
    Your browser doesn't support HTML5 video.
  </video>
</div>

<!-- Or with iframe for YouTube/Vimeo -->
<div class="video-wrapper">
  <iframe
    src="https://www.youtube.com/embed/VIDEO_ID"
    frameborder="0"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    allowfullscreen
  ></iframe>
</div>
```

```css
.video-container {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
}

.responsive-video {
  width: 100%;
  height: auto;
  aspect-ratio: 16 / 9;
  background: #000;
  border-radius: 12px;
  overflow: hidden;
}

/* For iframe videos (YouTube, Vimeo) */
.video-wrapper {
  position: relative;
  aspect-ratio: 16 / 9;
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
}

.video-wrapper iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
}

/* Different aspect ratios */
.video-wrapper.aspect-4-3 {
  aspect-ratio: 4 / 3;
}

.video-wrapper.aspect-1-1 {
  aspect-ratio: 1;
}

.video-wrapper.aspect-9-16 {
  aspect-ratio: 9 / 16;
  max-width: 600px;
}
```

---

## 17. Tabs and Accordions

### Example 17.1: Responsive Tabs

```html
<div class="tabs-container">
  <div class="tabs-nav">
    <button class="tab-btn active" data-tab="tab1">Tab 1</button>
    <button class="tab-btn" data-tab="tab2">Tab 2</button>
    <button class="tab-btn" data-tab="tab3">Tab 3</button>
  </div>

  <div class="tabs-content">
    <div class="tab-pane active" id="tab1">
      <p>Content for tab 1</p>
    </div>
    <div class="tab-pane" id="tab2">
      <p>Content for tab 2</p>
    </div>
    <div class="tab-pane" id="tab3">
      <p>Content for tab 3</p>
    </div>
  </div>
</div>
```

```css
.tabs-container {
  max-width: 900px;
  margin: 2rem auto;
  padding: 0 1rem;
}

.tabs-nav {
  display: flex;
  gap: 0.5rem;
  border-bottom: 2px solid #e0e0e0;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  flex-wrap: nowrap;
}

@media (min-width: 768px) {
  .tabs-nav {
    flex-wrap: wrap;
  }
}

.tab-btn {
  padding: 1rem 1.5rem;
  background: none;
  border: none;
  border-bottom: 3px solid transparent;
  color: #666;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  min-height: 44px;
}

.tab-btn:hover {
  color: #0066cc;
  background: #f5f5f5;
}

.tab-btn.active {
  color: #0066cc;
  border-bottom-color: #0066cc;
}

.tabs-content {
  padding: 2rem 0;
}

.tab-pane {
  display: none;
}

.tab-pane.active {
  display: block;
}

.tab-pane p {
  line-height: 1.6;
  color: #666;
}
```

### Example 17.2: Accordion

```html
<div class="accordion">
  <div class="accordion-item">
    <button class="accordion-header">
      <span>Question 1</span>
      <span class="accordion-icon">+</span>
    </button>
    <div class="accordion-content">
      <p>Answer to question 1 goes here.</p>
    </div>
  </div>
  <!-- More accordion items -->
</div>
```

```css
.accordion {
  max-width: 800px;
  margin: 2rem auto;
  padding: 0 1rem;
}

.accordion-item {
  background: white;
  border-radius: 8px;
  margin-bottom: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.accordion-header {
  width: 100%;
  padding: 1.5rem;
  background: none;
  border: none;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  font-size: 1.125rem;
  font-weight: 600;
  color: #333;
  text-align: left;
  transition: background-color 0.2s;
  min-height: 44px;
}

.accordion-header:hover {
  background: #f5f5f5;
}

.accordion-icon {
  font-size: 1.5rem;
  font-weight: 300;
  transition: transform 0.3s;
}

.accordion-item.active .accordion-icon {
  transform: rotate(45deg);
}

.accordion-content {
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease;
}

.accordion-item.active .accordion-content {
  max-height: 500px;
}

.accordion-content p {
  padding: 0 1.5rem 1.5rem;
  line-height: 1.6;
  color: #666;
}
```

---

## 18. Search and Filter Interfaces

### Example 18.1: Search with Filters

```html
<div class="search-container">
  <form class="search-form">
    <input type="search" class="search-input" placeholder="Search products..." />
    <button type="submit" class="search-btn">Search</button>
  </form>

  <div class="filters">
    <button class="filter-toggle">Filters</button>

    <div class="filter-panel">
      <div class="filter-group">
        <h3>Category</h3>
        <label><input type="checkbox" /> Electronics</label>
        <label><input type="checkbox" /> Clothing</label>
        <label><input type="checkbox" /> Books</label>
      </div>

      <div class="filter-group">
        <h3>Price Range</h3>
        <input type="range" min="0" max="1000" />
      </div>
    </div>
  </div>
</div>
```

```css
.search-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.search-form {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.search-input {
  flex: 1;
  min-width: 200px;
  padding: 1rem 1.5rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: #0066cc;
}

.search-btn {
  padding: 1rem 2rem;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
  min-width: 120px;
}

.search-btn:hover {
  background: #0052a3;
}

.filters {
  position: relative;
}

.filter-toggle {
  padding: 0.75rem 1.5rem;
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

@media (min-width: 768px) {
  .filter-toggle {
    display: none;
  }
}

.filter-panel {
  display: none;
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  padding: 1.5rem;
  margin-top: 1rem;
  position: absolute;
  top: 100%;
  left: 0;
  min-width: 300px;
  z-index: 10;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.filter-panel.active {
  display: block;
}

@media (min-width: 768px) {
  .filter-panel {
    display: flex;
    position: static;
    flex-wrap: wrap;
    gap: 2rem;
    box-shadow: none;
  }
}

.filter-group {
  margin-bottom: 1.5rem;
}

@media (min-width: 768px) {
  .filter-group {
    margin-bottom: 0;
    flex: 1;
    min-width: 200px;
  }
}

.filter-group h3 {
  font-size: 1rem;
  margin-bottom: 1rem;
  color: #333;
}

.filter-group label {
  display: block;
  margin-bottom: 0.75rem;
  cursor: pointer;
}

.filter-group input[type="checkbox"] {
  margin-right: 0.5rem;
}

.filter-group input[type="range"] {
  width: 100%;
}
```

---

## 19. Profile and User Card

### Example 19.1: User Profile Card

```html
<div class="profile-card">
  <div class="profile-cover">
    <img src="cover.jpg" alt="Cover" />
  </div>

  <div class="profile-avatar">
    <img src="avatar.jpg" alt="User avatar" />
  </div>

  <div class="profile-info">
    <h2>John Doe</h2>
    <p class="profile-title">Web Developer</p>
    <p class="profile-bio">Passionate about creating beautiful and functional web experiences.</p>

    <div class="profile-stats">
      <div class="stat">
        <span class="stat-value">1.2K</span>
        <span class="stat-label">Followers</span>
      </div>
      <div class="stat">
        <span class="stat-value">845</span>
        <span class="stat-label">Following</span>
      </div>
      <div class="stat">
        <span class="stat-value">42</span>
        <span class="stat-label">Posts</span>
      </div>
    </div>

    <div class="profile-actions">
      <button class="btn-primary">Follow</button>
      <button class="btn-secondary">Message</button>
    </div>
  </div>
</div>
```

```css
.profile-card {
  max-width: 500px;
  margin: 2rem auto;
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.profile-cover {
  height: 150px;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

@media (min-width: 768px) {
  .profile-cover {
    height: 200px;
  }
}

.profile-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.profile-avatar {
  margin: -60px auto 0;
  width: 120px;
  height: 120px;
  position: relative;
  z-index: 1;
}

@media (min-width: 768px) {
  .profile-avatar {
    width: 150px;
    height: 150px;
    margin-top: -75px;
  }
}

.profile-avatar img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 5px solid white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  object-fit: cover;
}

.profile-info {
  padding: 1.5rem 2rem 2rem;
  text-align: center;
}

.profile-info h2 {
  font-size: clamp(1.5rem, 3vw + 0.5rem, 2rem);
  margin-bottom: 0.5rem;
  color: #333;
}

.profile-title {
  color: #666;
  margin-bottom: 1rem;
  font-weight: 500;
}

.profile-bio {
  color: #666;
  line-height: 1.6;
  margin-bottom: 2rem;
}

.profile-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1.5rem 0;
  border-top: 1px solid #e0e0e0;
  border-bottom: 1px solid #e0e0e0;
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.stat-value {
  font-size: clamp(1.25rem, 2vw + 0.5rem, 1.75rem);
  font-weight: 700;
  color: #333;
}

.stat-label {
  font-size: 0.875rem;
  color: #666;
}

.profile-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.profile-actions button {
  flex: 1;
  padding: 1rem 2rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  min-height: 44px;
}

@media (max-width: 479px) {
  .profile-actions {
    flex-direction: column;
  }

  .profile-actions button {
    width: 100%;
  }
}
```

---

## 20. Notification and Alert Patterns

### Example 20.1: Toast Notifications

```html
<div class="toast-container">
  <div class="toast toast-success">
    <div class="toast-icon">✓</div>
    <div class="toast-content">
      <h4>Success!</h4>
      <p>Your changes have been saved.</p>
    </div>
    <button class="toast-close">&times;</button>
  </div>

  <div class="toast toast-error">
    <div class="toast-icon">✕</div>
    <div class="toast-content">
      <h4>Error</h4>
      <p>Something went wrong. Please try again.</p>
    </div>
    <button class="toast-close">&times;</button>
  </div>

  <div class="toast toast-info">
    <div class="toast-icon">ⓘ</div>
    <div class="toast-content">
      <h4>Info</h4>
      <p>New updates are available.</p>
    </div>
    <button class="toast-close">&times;</button>
  </div>
</div>
```

```css
.toast-container {
  position: fixed;
  top: 1rem;
  right: 1rem;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: calc(100% - 2rem);
  width: 100%;
}

@media (min-width: 480px) {
  .toast-container {
    width: auto;
    min-width: 350px;
  }
}

.toast {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
  padding: 1rem;
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  animation: slideIn 0.3s ease;
  border-left: 4px solid;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.toast-success {
  border-left-color: #00cc66;
}

.toast-error {
  border-left-color: #ff6b6b;
}

.toast-info {
  border-left-color: #0066cc;
}

.toast-icon {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: white;
}

.toast-success .toast-icon {
  background: #00cc66;
}

.toast-error .toast-icon {
  background: #ff6b6b;
}

.toast-info .toast-icon {
  background: #0066cc;
}

.toast-content {
  flex: 1;
}

.toast-content h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1rem;
  color: #333;
}

.toast-content p {
  margin: 0;
  font-size: 0.875rem;
  color: #666;
  line-height: 1.4;
}

.toast-close {
  flex-shrink: 0;
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #999;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: all 0.2s;
}

.toast-close:hover {
  background: #f0f0f0;
  color: #333;
}
```

---

## Summary

This comprehensive examples collection provides 20+ production-ready responsive design patterns covering:

1. **Navigation**: Hamburger menus, mega menus, sticky headers
2. **Hero Sections**: Split layouts, full-width backgrounds, CTAs
3. **Card Layouts**: Auto-responsive grids, featured items, masonry
4. **Forms**: Multi-column, stepped wizards, validation
5. **Tables**: Card-based mobile views, horizontal scroll, sticky headers
6. **Galleries**: Masonry, grid, lightbox integration
7. **Dashboards**: Stat cards, charts, responsive data viz
8. **Sidebars**: Collapsible, off-canvas, persistent
9. **Footers**: Multi-column, newsletter signup, social links
10. **Pricing**: Tiered plans, featured highlights, comparison tables
11. **Features**: Icon grids, service showcases
12. **Timelines**: Vertical, horizontal, alternating
13. **Modals**: Centered, full-screen on mobile, accessible
14. **Blog Layouts**: Grid, list, sidebar combinations
15. **E-commerce**: Product grids, cards, wishlist integration
16. **Media**: Responsive videos, aspect ratios, embeds
17. **Tabs/Accordions**: Mobile-friendly, accessible controls
18. **Search/Filter**: Responsive filters, mobile toggles
19. **Profiles**: User cards, stats, social features
20. **Notifications**: Toast messages, alerts, dismissible

All examples follow:
- Mobile-first approach
- Modern CSS (Flexbox, Grid, clamp())
- Accessibility best practices (44px touch targets, ARIA)
- Performance optimization (lazy loading, containment)
- Cross-browser compatibility
- Touch-friendly interactions
- Responsive typography and spacing
