---
description: "Go implementation guardrails for idiomatic and efficient Go development."
applyTo: "**/*.go"
---

## Guiding Principles

- Write simple, clear, and idiomatic Go code. Follow the Go proverbs and
  community conventions.
- Favor composition over inheritance. Use interfaces for abstraction.
- Make the zero value useful whenever possible.
- Handle errors explicitly; don't ignore them.
- Keep packages focused and cohesive with minimal public APIs.

## Style and Formatting

- Run `go fmt` or `gofmt` on all code before committing. This is
  non-negotiable in Go.
- Use `goimports` to manage imports automatically and alphabetically.
- Follow the standard Go project layout for larger projects.
- Use meaningful package names that are short, lowercase, and without
  underscores.
- Keep line length reasonable, typically under 100 characters.
- Use `golint` or `staticcheck` to catch common style issues.

## Naming Conventions

- Use MixedCaps or mixedCaps rather than underscores for multi-word names.
- Use short, concise names for local variables (e.g., `i`, `r`, `buf`).
- Use descriptive names for exported identifiers and package-level variables.
- Use single-letter receivers (`r`, `c`, `s`) that relate to the type name.
- Prefix interface names with -er when describing behavior (Reader, Writer,
  Closer).
- Avoid stuttering: `http.Server` not `http.HTTPServer`.

## Error Handling

- Always check and handle errors explicitly. Never ignore returned errors.
- Return errors as the last return value from functions.
- Use `errors.New` or `fmt.Errorf` for simple error messages.
- Use `%w` verb with `fmt.Errorf` to wrap errors for unwrapping with
  `errors.Unwrap`.
- Create custom error types implementing the `error` interface for complex
  error scenarios.
- Use `errors.Is` and `errors.As` for error checking and type assertions.
- Log errors with sufficient context; include relevant data for debugging.

## Functions and Methods

- Keep functions short and focused. If a function exceeds 40-50 lines,
  consider extracting helpers.
- Use named return values sparingly; use them primarily for documentation
  or naked returns in short functions.
- Accept interfaces, return concrete types when possible.
- Use variadic functions (`...T`) sparingly and document their behavior.
- Keep method receivers consistent within a type (all pointer or all value).
- Use pointer receivers when mutating state or for large structs.

## Interfaces and Composition

- Keep interfaces small. The best interfaces have one or two methods.
- Accept interfaces, return structs to maintain flexibility.
- Define interfaces where they're used, not where they're implemented.
- Use embedding for composition rather than inheritance.
- Use type assertions and type switches when necessary, but sparingly.

## Concurrency

- Use goroutines for concurrent operations, but manage them carefully.
- Always consider how goroutines will be stopped; don't leak goroutines.
- Use channels to communicate between goroutines; "share memory by
  communicating."
- Close channels from the sender side only; document who owns closing.
- Use `sync.WaitGroup` to wait for multiple goroutines to complete.
- Use `context.Context` for cancellation and timeout propagation.
- Protect shared state with mutexes (`sync.Mutex`, `sync.RWMutex`) or
  use concurrent-safe structures.
- Use buffered channels judiciously; understand blocking behavior.

## Packages and Imports

- Organize code into packages with clear responsibilities.
- Keep package-level variables and init functions to a minimum.
- Use internal packages (`internal/`) to prevent external use of
  implementation details.
- Group imports into standard library, third-party, and local packages
  with blank lines.
- Avoid circular dependencies between packages.
- Use vendoring or Go modules for dependency management.

## Testing and Quality Gates

- Write tests in `_test.go` files alongside the code they test.
- Use table-driven tests for multiple test cases of the same function.
- Use subtests with `t.Run()` for organized test output.
- Name test functions `TestXxx` for unit tests and `BenchmarkXxx` for
  benchmarks.
- Use the `testing` package; avoid external test frameworks unless necessary.
- Use test helpers that call `t.Helper()` to improve error reporting.
- Target high coverage for critical business logic; run `go test -cover`.
- Write examples in tests for documentation; they appear in godoc.

## Dependency Management

- Use Go modules (`go.mod`, `go.sum`) for dependency management.
- Run `go mod tidy` regularly to clean up dependencies.
- Pin dependency versions; review changes when updating.
- Use `go list -m -u all` to check for available updates.
- Minimize dependencies; avoid large frameworks for simple needs.
- Audit dependencies with `govulncheck` for security vulnerabilities.

## Security Considerations

- Validate and sanitize all external inputs (user input, API requests,
  file data).
- Use parameterized queries or ORMs for database access; never concatenate
  SQL strings.
- Use `crypto/rand` for cryptographic operations, never `math/rand`.
- Use established libraries for cryptography (crypto/* packages) rather
  than rolling your own.
- Store secrets in environment variables or secret managers; never in code.
- Use HTTPS for all network communication; configure TLS properly.
- Keep dependencies updated to patch security vulnerabilities.
- Validate all file paths to prevent directory traversal attacks.

## Performance Guidance

- Profile with `pprof` before optimizing. Measure actual bottlenecks.
- Use appropriate data structures for access patterns (map for lookups,
  slice for sequential).
- Minimize allocations in hot paths; use pooling with `sync.Pool` when
  appropriate.
- Use `strings.Builder` for efficient string concatenation.
- Preallocate slices when the final size is known (`make([]T, 0, size)`).
- Avoid unnecessary pointer indirection for small structs.
- Use `go build -gcflags=-m` to check for escape analysis and allocations.
- Write benchmarks to validate performance improvements.

## Logging and Monitoring

- Use structured logging libraries (slog, zap, logrus) for production code.
- Log at appropriate levels: Error, Warn, Info, Debug.
- Include contextual information in logs (correlation IDs, user IDs).
- Never log sensitive information (passwords, tokens, PII).
- Use `context.Context` to propagate request-scoped values like trace IDs.
- Implement health check endpoints for monitoring.
- Export metrics using Prometheus or similar monitoring systems.

## Modern Go Features (Go 1.18+)

- Use generics for type-safe, reusable data structures and algorithms.
- Use type parameters sparingly; don't over-generalize.
- Use `any` instead of `interface{}` for empty interfaces.
- Use workspace mode (`go.work`) for multi-module development.
- Use the new `strings.Cut` and similar functions for clearer string
  operations.

## HTTP and API Development (when applicable)

- Use the standard `net/http` package or popular routers (chi, gorilla/mux).
- Implement proper middleware for cross-cutting concerns (logging, auth,
  recovery).
- Use appropriate HTTP status codes (200, 201, 400, 404, 500).
- Validate request bodies before processing.
- Implement graceful shutdown handling interrupt signals.
- Use context timeouts for external HTTP requests.
- Return JSON using `encoding/json` or faster alternatives (jsoniter).
- Implement rate limiting for public APIs.

## Database Access (when applicable)

- Use `database/sql` with appropriate drivers for SQL databases.
- Use prepared statements to prevent SQL injection.
- Use connection pooling (`SetMaxOpenConns`, `SetMaxIdleConns`).
- Always use context-aware methods (`QueryContext`, `ExecContext`).
- Handle NULL values properly with `sql.Null*` types.
- Use transactions for operations requiring atomicity.
- Consider ORMs like GORM for complex data models, but understand the
  trade-offs.

## Code Organization

- Keep files reasonably sized; split large files by logical components.
- Put related functionality together in the same file.
- Use constructors (`NewXxx`) for complex initialization.
- Export only what's necessary; keep implementation details private.
- Document exported types, functions, and methods with comments starting
  with the name.
- Use package-level documentation in `doc.go` for complex packages.
