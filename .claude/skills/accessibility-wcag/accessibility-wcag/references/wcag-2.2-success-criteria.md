# WCAG 2.2 Success Criteria Reference (Level A & AA)

Quick reference for the most impactful success criteria when reviewing code and UI.

## Perceivable

### 1.1 Text Alternatives (Level A)
- **1.1.1** All non-text content has a text alternative (alt text, labels, descriptions)
- Images: `alt` attribute required; decorative images use `alt=""`
- Icons: Must have accessible name via `aria-label` or visually hidden text

### 1.3 Adaptable (Level A)
- **1.3.1** Info and relationships conveyed visually are available programmatically
- Use semantic HTML (`<nav>`, `<main>`, `<aside>`, `<header>`, `<footer>`)
- Tables use `<th>`, `<caption>`, and `scope` attributes
- **1.3.5** Identify input purpose with `autocomplete` attributes (Level AA)

### 1.4 Distinguishable
- **1.4.1** Color is not the sole means of conveying information (Level A)
- **1.4.3** Contrast ratio ≥ 4.5:1 for normal text, ≥ 3:1 for large text (Level AA)
- **1.4.4** Text can be resized to 200% without loss of content (Level AA)
- **1.4.11** Non-text contrast ≥ 3:1 for UI components and graphics (Level AA)

## Operable

### 2.1 Keyboard Accessible (Level A)
- **2.1.1** All functionality available via keyboard (no mouse-only interactions)
- **2.1.2** No keyboard traps — user can always navigate away
- Custom widgets need `tabindex`, `onkeydown`/`onkeyup` handlers

### 2.4 Navigable
- **2.4.1** Skip navigation link available (Level A)
- **2.4.2** Pages have descriptive `<title>` elements (Level A)
- **2.4.3** Focus order is logical and intuitive (Level A)
- **2.4.6** Headings and labels are descriptive (Level AA)
- **2.4.7** Focus indicator is visible (Level AA)
- **2.4.11** Focus not obscured by sticky headers/footers (Level AA — new in 2.2)

### 2.5 Input Modalities
- **2.5.8** Target size ≥ 24×24 CSS pixels (Level AA — new in 2.2)

## Understandable

### 3.1 Readable
- **3.1.1** Page language identified with `lang` attribute on `<html>` (Level A)
- **3.1.2** Language of parts identified when different from page language (Level AA)

### 3.2 Predictable
- **3.2.1** No unexpected context changes on focus (Level A)
- **3.2.2** No unexpected context changes on input (Level A)
- **3.2.6** Consistent help location across pages (Level A — new in 2.2)

### 3.3 Input Assistance
- **3.3.1** Error identification — errors described in text (Level A)
- **3.3.2** Labels or instructions provided for user input (Level A)
- **3.3.7** Redundant entry — don't ask for same info twice (Level A — new in 2.2)
- **3.3.8** Accessible authentication — no cognitive function tests (Level AA — new in 2.2)

## Robust

### 4.1 Compatible
- **4.1.2** Custom components have name, role, and value exposed to assistive tech (Level A)
- Use ARIA only when native HTML semantics are insufficient
