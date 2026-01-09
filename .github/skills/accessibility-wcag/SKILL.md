# Accessibility & WCAG Compliance

Provides WCAG 2.1 Level AA compliance patterns for accessible web development including semantic HTML, ARIA implementation, keyboard navigation, and screen reader compatibility.

## Description

This skill teaches accessibility agents how to evaluate and implement WCAG 2.1 Level AA standards across web applications. It covers the four POUR principles (Perceivable, Operable, Understandable, Robust), ARIA attributes, keyboard navigation patterns, color contrast requirements, and assistive technology compatibility.

## When to Use

- Reviewing UI components for accessibility compliance
- Implementing keyboard navigation
- Adding ARIA labels and roles
- Evaluating color contrast ratios
- Testing screen reader compatibility
- Conducting WCAG 2.1 audits

## Entry Points

**Trigger Phrases:** "accessibility review", "WCAG compliance", "screen reader", "keyboard navigation", "ARIA", "a11y audit"

**Context Patterns:** UI component implementations, form designs, interactive widgets, color scheme changes, content structure updates

## Core Knowledge

### POUR Principles

#### Perceivable
- **Text alternatives:** Alt text for images, transcripts for audio
- **Time-based media:** Captions for videos, audio descriptions
- **Adaptable:** Semantic HTML, proper heading hierarchy
- **Distinguishable:** Color contrast 4.5:1 (text), 3:1 (UI components)

#### Operable
- **Keyboard accessible:** All functionality via keyboard, no keyboard traps
- **Enough time:** Adjustable time limits, pause/stop animations
- **Seizures:** No flashing content >3 times per second
- **Navigable:** Skip links, focus indicators, meaningful link text

#### Understandable
- **Readable:** Language declared, simple language where possible
- **Predictable:** Consistent navigation, no unexpected context changes
- **Input assistance:** Error identification, labels/instructions, error suggestions

#### Robust
- **Compatible:** Valid HTML, proper ARIA usage, assistive tech support

### ARIA Attributes

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `role` | Define element purpose | `<div role="navigation">` |
| `aria-label` | Accessible name | `<button aria-label="Close dialog">×</button>` |
| `aria-labelledby` | Reference label ID | `<input aria-labelledby="username-label">` |
| `aria-describedby` | Additional context | `<input aria-describedby="password-hint">` |
| `aria-hidden` | Hide from screen readers | `<span aria-hidden="true">★</span>` |
| `aria-live` | Announce dynamic changes | `<div aria-live="polite">` |
| `aria-expanded` | Collapsible state | `<button aria-expanded="false">` |

### Color Contrast Requirements

**WCAG 2.1 Level AA:**
- Normal text: 4.5:1 minimum
- Large text (18pt+ or 14pt+ bold): 3:1 minimum
- UI components and graphics: 3:1 minimum

**Tools:** Chrome DevTools (Inspect > Accessibility), WebAIM Contrast Checker

### Keyboard Navigation Patterns

| Pattern | Keys | Example |
|---------|------|---------|
| Tab order | Tab, Shift+Tab | Form inputs, buttons, links |
| Menu navigation | Arrow keys | Dropdown menus, tree views |
| Dialog | Esc (close), Tab (trap focus) | Modal dialogs |
| Radio group | Arrow keys (select), Tab (exit group) | Radio button sets |
| Combobox | Arrow keys (options), Enter (select) | Autocomplete inputs |

### Accessibility Review Template

```markdown
## Accessibility Review: [Component]

### WCAG 2.1 Level AA Compliance

#### Perceivable
- [ ] Alt text for images (1.1.1)
- [ ] Color contrast ≥4.5:1 for text (1.4.3)
- [ ] Semantic HTML structure (1.3.1)
- [ ] Content not solely conveyed by color (1.4.1)

#### Operable
- [ ] All functionality keyboard accessible (2.1.1)
- [ ] No keyboard traps (2.1.2)
- [ ] Visible focus indicators (2.4.7)
- [ ] Skip navigation links (2.4.1)

#### Understandable
- [ ] Language declared (lang="en") (3.1.1)
- [ ] Labels for form inputs (3.3.2)
- [ ] Error identification and suggestions (3.3.1, 3.3.3)
- [ ] Consistent navigation (3.2.3)

#### Robust
- [ ] Valid HTML (4.1.1)
- [ ] ARIA attributes used correctly (4.1.2)
- [ ] Name, role, value for custom controls (4.1.2)

### Findings

#### BLOCKER: [Issue]
- **WCAG Criterion:** [Number and description]
- **Impact:** [Screen readers, keyboard users, low vision]
- **Location:** [Component:line]
- **Fix:** [Specific recommendation]

### Screen Reader Testing
- **NVDA:** [Pass/Fail with notes]
- **JAWS:** [Pass/Fail with notes]
- **VoiceOver:** [Pass/Fail with notes]

### Verdict
- [ ] APPROVED (WCAG 2.1 AA compliant)
- [ ] MINOR_ISSUES (usable, improvements recommended)
- [ ] MAJOR_ISSUES (blocks compliance, must fix)
```

## Examples

### Example: Inaccessible Form

**❌ Before (Non-compliant):**
```html
<form>
  <input type="text" placeholder="Username">
  <input type="password" placeholder="Password">
  <div style="color: red;">Invalid credentials</div>
  <span onclick="submit()">Submit</span>
</form>
```

**Issues:**
1. No labels (WCAG 3.3.2)
2. Error not associated with input (WCAG 3.3.1)
3. Submit not keyboard accessible (WCAG 2.1.1)
4. No focus indicators

**✅ After (Compliant):**
```html
<form>
  <div>
    <label for="username">Username</label>
    <input 
      id="username" 
      type="text" 
      aria-describedby="username-error"
      aria-invalid="true"
    >
    <span id="username-error" role="alert">
      Invalid credentials. Please check your username and password.
    </span>
  </div>
  
  <div>
    <label for="password">Password</label>
    <input 
      id="password" 
      type="password"
      aria-describedby="password-hint"
    >
    <span id="password-hint">
      Must be at least 8 characters
    </span>
  </div>
  
  <button type="submit">Submit</button>
</form>

<style>
  input:focus, button:focus {
    outline: 2px solid blue;
    outline-offset: 2px;
  }
</style>
```

**Improvements:**
- Explicit `<label>` elements (WCAG 3.3.2) ✓
- `aria-invalid` and `aria-describedby` for errors (WCAG 3.3.1) ✓
- `<button>` for keyboard accessibility (WCAG 2.1.1) ✓
- Visible focus indicators (WCAG 2.4.7) ✓

## References

- **WCAG 2.1:** https://www.w3.org/WAI/WCAG21/quickref/
- **ARIA Practices:** https://www.w3.org/WAI/ARIA/apg/
- **Testing Tools:** axe DevTools, WAVE, Pa11y
