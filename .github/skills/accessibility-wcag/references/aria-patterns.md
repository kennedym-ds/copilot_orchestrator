# ARIA Patterns and Anti-Patterns

Common ARIA usage patterns for accessible interactive components.

## Golden Rule

> Use native HTML elements and attributes first. Only add ARIA when native semantics are insufficient.

## Landmarks

```html
<!-- Good: semantic HTML (ARIA implicit) -->
<header>...</header>
<nav>...</nav>
<main>...</main>
<aside>...</aside>
<footer>...</footer>

<!-- When needed: explicit ARIA landmarks -->
<div role="banner">...</div>
<div role="navigation" aria-label="Primary">...</div>
<div role="main">...</div>
<div role="complementary">...</div>
<div role="contentinfo">...</div>
```

## Buttons and Links

```html
<!-- Good: native button -->
<button type="button" onclick="doAction()">Save</button>

<!-- Bad: div as button (missing keyboard, role, states) -->
<div onclick="doAction()">Save</div>

<!-- If you must use a non-native element -->
<div role="button" tabindex="0"
     onkeydown="if(event.key==='Enter'||event.key===' ')doAction()"
     onclick="doAction()">Save</div>

<!-- Link vs Button: links navigate, buttons perform actions -->
<a href="/page">Go to page</a>        <!-- navigates -->
<button type="button">Open dialog</button>  <!-- performs action -->
```

## Dialogs / Modals

```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Delete</h2>
  <p>Are you sure you want to delete this item?</p>
  <button>Cancel</button>
  <button>Delete</button>
</div>
```

**Requirements:**
- Focus moves into dialog on open
- Focus is trapped inside (Tab cycles within dialog)
- Escape key closes dialog
- Focus returns to trigger element on close

## Expandable Sections (Disclosure)

```html
<button aria-expanded="false" aria-controls="details-panel">
  Show Details
</button>
<div id="details-panel" hidden>
  <p>Detailed content here.</p>
</div>
```

**Toggle `aria-expanded` and `hidden` attribute on click.**

## Tabs

```html
<div role="tablist" aria-label="Settings">
  <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">
    General
  </button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2" tabindex="-1">
    Advanced
  </button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">...</div>
<div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>...</div>
```

**Keyboard:** Arrow keys move between tabs; Tab moves into panel.

## Live Regions

```html
<!-- Polite: announced at next pause (status messages, updates) -->
<div aria-live="polite" aria-atomic="true">3 results found</div>

<!-- Assertive: announced immediately (errors, urgent alerts) -->
<div role="alert">Payment failed. Please try again.</div>

<!-- Status: implicit aria-live="polite" -->
<div role="status">Saving...</div>
```

## Form Validation

```html
<label for="email">Email</label>
<input id="email" type="email"
       aria-required="true"
       aria-invalid="true"
       aria-describedby="email-error" />
<span id="email-error" role="alert">Please enter a valid email address.</span>
```

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `role="button"` on `<a>` | Confuses navigation vs action | Use `<button>` for actions |
| `aria-label` on `<div>` | Non-interactive elements shouldn't have labels | Use on interactive elements only |
| `tabindex="5"` | Positive tabindex breaks natural order | Use `tabindex="0"` or `-1` only |
| Hiding content with `display:none` but expecting screen reader access | Content is hidden from everyone | Use visually-hidden class instead |
| `role="presentation"` on focusable element | Strips semantics but element is still interactive | Remove role or make non-focusable |
| Redundant ARIA: `<button role="button">` | Native element already has this role | Remove redundant ARIA |
| Missing `aria-label` on icon-only button | No accessible name | Add `aria-label="Close"` |

## Visually Hidden Utility Class

```css
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```
