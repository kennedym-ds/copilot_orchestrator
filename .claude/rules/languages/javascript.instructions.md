---
description: "JavaScript implementation guardrails for modern ECMAScript development."
applyTo: "**/*.js,**/*.mjs,**/*.cjs"
---

## Guiding Principles

- Write modern JavaScript using ES6+ features. Prefer clarity and maintainability
  over clever one-liners.
- Keep functions small and focused. A function should do one thing well.
- Use descriptive names for variables and functions that express intent.
- Optimize for readability first; profile before pursuing micro-optimizations.

## Style and Formatting

- Use ESLint with a standard configuration (Airbnb, Standard, or project-specific).
  Run it in CI pipelines to enforce consistency.
- Use Prettier for automatic code formatting to eliminate style debates.
- Use `const` by default; use `let` only when reassignment is necessary.
  Avoid `var` entirely to prevent hoisting confusion.
- Prefer single quotes for strings unless using template literals with
  interpolation.
- Use 2-space indentation consistently across the codebase.

## Modern JavaScript Features

- Use arrow functions for callbacks and functional operations, but prefer
  regular functions for methods that need `this` context.
- Use destructuring for objects and arrays to extract values cleanly.
- Use template literals for string interpolation and multi-line strings.
- Use spread operator (`...`) for array/object manipulation instead of
  `concat`, `apply`, or `Object.assign`.
- Use default parameters instead of checking for `undefined` values.
- Use async/await for asynchronous code; avoid callback pyramids and
  minimize raw Promise chains.

## Functions and Modules

- Keep functions under 30-40 lines. Extract helpers when functions grow
  too large.
- Use named exports for better tree-shaking and refactoring. Use default
  exports sparingly, only for single-purpose modules.
- Organize imports in logical groups: external dependencies first, then
  internal modules.
- Avoid circular dependencies between modules; refactor shared code into
  separate utilities.

## Error Handling

- Always handle Promise rejections using `try/catch` with async/await or
  `.catch()` handlers.
- Create custom error classes extending `Error` for domain-specific errors.
- Include meaningful error messages with context to aid debugging.
- Never swallow errors silently; log with sufficient context or rethrow
  with additional information.
- Use error boundaries in React applications to catch and handle errors
  gracefully.

## Data Structures and Iteration

- Use `Map` and `Set` for collections that need frequent lookups or
  uniqueness guarantees.
- Use array methods (`map`, `filter`, `reduce`, `find`, `some`, `every`)
  for functional transformations instead of manual loops.
- Avoid mutating arrays or objects in place unless necessary for
  performance; prefer immutable patterns.
- Use `for...of` for iterating over arrays; use `for...in` only for
  object keys with proper `hasOwnProperty` checks.

## Testing and Quality Gates

- Write tests alongside implementation using Jest, Mocha, or the project's
  test framework.
- Target at least 80% branch coverage for critical business logic.
- Use test-driven development (TDD) for complex logic: write failing tests
  first, then implement.
- Mock external dependencies and APIs to keep tests fast and isolated.
- Use descriptive test names that explain the expected behavior.

## Security Considerations

- Validate and sanitize all external inputs (user input, API responses,
  environment variables).
- Never use `eval()`, `Function()`, or similar dynamic code execution
  patterns unless absolutely necessary and sandboxed.
- Use parameterized queries or ORMs for database access; never concatenate
  user input into SQL strings.
- Implement Content Security Policy (CSP) headers for web applications.
- Keep dependencies updated and audit with `npm audit` regularly. Address
  high-severity vulnerabilities promptly.
- Store secrets in environment variables or secure secret stores; never
  commit them to version control.

## Performance Guidance

- Profile with browser DevTools or Node.js profiler before optimizing.
  Measure, don't guess.
- Use lazy loading and code splitting for large web applications.
- Debounce or throttle frequent event handlers (scroll, resize, input).
- Cache expensive computations with memoization when appropriate.
- Use Web Workers for CPU-intensive operations in the browser.
- Consider bundle size impact when adding dependencies; use bundler
  analysis tools.

## Node.js Specific

- Use the latest LTS version of Node.js for production applications.
- Use `fs/promises` for file system operations instead of callback-based
  `fs` methods.
- Handle uncaught exceptions and unhandled rejections at the process level
  to prevent crashes.
- Use environment variables for configuration; use packages like `dotenv`
  for local development.
- Implement proper logging with structured logs (JSON format) for
  production services.

## Browser Specific

- Support modern browsers by default; document minimum version requirements.
- Use progressive enhancement: start with working HTML, enhance with
  JavaScript.
- Test across target browsers and devices; use polyfills sparingly.
- Optimize for First Contentful Paint (FCP) and Time to Interactive (TTI).
- Use browser APIs appropriately: localStorage for simple data, IndexedDB
  for complex storage needs.
