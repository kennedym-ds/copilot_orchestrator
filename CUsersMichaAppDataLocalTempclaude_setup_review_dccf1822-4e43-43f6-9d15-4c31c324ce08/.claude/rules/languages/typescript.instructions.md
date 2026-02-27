---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

---
description: "TypeScript implementation guardrails for type-safe JavaScript development."
applyTo: "**/*.ts,**/*.tsx"
---

## Guiding Principles

- Leverage TypeScript's type system to catch errors at compile time rather
  than runtime. Prefer strict typing over `any` escape hatches.
- Write code that is self-documenting through types. Good type definitions
  often reduce the need for comments.
- Keep modules focused and cohesive. Export only what consumers need and
  hide implementation details.

## Configuration

- Enable strict mode in `tsconfig.json` (`"strict": true`) as the baseline.
  Address type errors rather than loosening checks.
- Configure path aliases for cleaner imports (e.g., `@/components/*`).
- Set target and module settings appropriate for your runtime environment
  (Node.js version, browser support requirements).
- Use `noEmitOnError` to prevent emitting JavaScript when type errors exist.

## Style and Formatting

- Use Prettier for consistent formatting and ESLint with TypeScript rules
  for linting. Run both in CI pipelines.
- Use camelCase for variables and functions, PascalCase for types, interfaces,
  and classes.
- Prefer `interface` over `type` for object shapes that may be extended.
- Use `const` by default; use `let` only when reassignment is necessary.
  Avoid `var` entirely.

## Type Definitions

- Avoid `any`; use `unknown` when the type is truly uncertain and narrow
  with type guards.
- Define explicit return types for exported functions to document contracts
  and catch refactoring errors.
- Use union types and discriminated unions for values that can be multiple
  types.
- Leverage utility types (`Partial`, `Required`, `Pick`, `Omit`, `Record`)
  to derive types and reduce duplication.
- Create branded types for domain concepts that need type-level distinction
  (e.g., `UserId`, `OrderId`).

## Functions and Modules

- Keep functions small and focused. If a function exceeds 30-40 lines,
  consider extracting helpers.
- Use async/await for asynchronous code; avoid raw Promise chains for
  readability.
- Prefer named exports for better tree-shaking and refactoring support.
- Document public APIs with JSDoc comments that complement type information.

## Error Handling

- Define custom error classes that extend `Error` for domain-specific
  error handling.
- Use discriminated unions or Result types for functions that may fail,
  making error handling explicit in the type system.
- Never swallow errors silently; log with sufficient context or rethrow
  with additional information.
- Use `try/catch` at appropriate boundaries; avoid wrapping every operation.

## Testing

- Write tests alongside implementation using Jest, Vitest, or the project's
  test framework.
- Type test files to catch type errors in test code.
- Use type utilities like `expectType` from `tsd` or similar to test type
  definitions themselves.
- Mock dependencies with proper typing using `jest.Mock<T>` or equivalent.
- Aim for high coverage on critical business logic; focus on behavior rather
  than implementation details.

## Security Considerations

- Validate and sanitize all external inputs (API responses, user input,
  environment variables) using runtime validation libraries like Zod.
- Use parameterized queries and ORMs for database access; never concatenate
  user input into SQL strings.
- Configure CSP headers and sanitize HTML output in web applications.
- Keep dependencies updated and audit with `npm audit` regularly.
- Avoid `eval()`, `Function()`, and other dynamic code execution patterns.

## Performance Guidance

- Profile before optimizing; use browser DevTools or Node.js profiler to
  identify actual bottlenecks.
- Use lazy loading and code splitting for large applications.
- Memoize expensive computations with appropriate cache invalidation.
- Consider bundle size impact when adding dependencies; use bundler
  analysis tools to identify large imports.

## React/TSX Specific (when applicable)

- Define component prop types with interfaces or type aliases.
- Use React.FC sparingly; prefer explicit return type annotations.
- Type event handlers with React's built-in event types
  (`React.MouseEvent<HTMLButtonElement>`).
- Use generic components for reusable abstractions with type-safe props.
