---
paths:
  - "**/*.cs"
---

---
description: "C# implementation guardrails for .NET development."
applyTo: "**/*.cs"
---

## Guiding Principles

- Follow .NET's design guidelines and idiomatic C# patterns. Embrace
  object-oriented and functional programming paradigms.
- Write expressive code using C#'s rich feature set. Let the language work
  for you.
- Keep classes and methods focused. Each should have a single, clear
  responsibility.
- Optimize for maintainability and clarity over clever solutions.

## Style and Formatting

- Follow Microsoft's C# Coding Conventions or use .editorconfig to enforce
  project standards.
- Use 4-space indentation consistently.
- Place opening braces on new lines (Allman style) following .NET conventions.
- Use PascalCase for public members, camelCase for private fields (prefix
  with underscore), and PascalCase for types.
- Keep line length reasonable, typically under 120 characters.
- Use file-scoped namespaces (C# 10+) to reduce indentation.
- Enable nullable reference types and treat warnings as errors.

## Type System and Nullability

- Use appropriate access modifiers to enforce encapsulation.
- Enable nullable reference types (`<Nullable>enable</Nullable>`) in all
  new projects.
- Use `?` suffix for nullable types and handle null cases explicitly.
- Return `null` sparingly; prefer `Optional<T>` pattern, exceptions, or
  default values.
- Use value types (`struct`) for small, immutable data; use reference types
  (`class`) for larger, mutable entities.
- Prefer records for immutable data transfer objects (DTOs).

## Properties and Methods

- Use properties instead of getter/setter methods for simple value access.
- Use auto-properties when no additional logic is needed.
- Use expression-bodied members for simple one-liners.
- Keep methods small and focused, ideally under 30-40 lines.
- Use async/await for I/O-bound operations; avoid blocking calls.
- Name async methods with `Async` suffix (e.g., `GetDataAsync`).
- Use appropriate method names: `Get`, `Set`, `Create`, `Update`, `Delete`
  for CRUD operations.

## Exception Handling

- Use exceptions for exceptional conditions, not for control flow.
- Create custom exception classes deriving from `Exception` for
  domain-specific errors.
- Use specific exception types (`ArgumentNullException`,
  `InvalidOperationException`) over generic `Exception`.
- Always provide meaningful exception messages with context.
- Use `using` statements or `IDisposable` pattern for resource management.
- Implement proper exception handling at appropriate boundaries; don't
  catch-all at every level.
- Log exceptions with full context before rethrowing or handling.

## Collections and LINQ

- Use generic collections (`List<T>`, `Dictionary<TKey, TValue>`) instead
  of non-generic types.
- Prefer interfaces (`IEnumerable<T>`, `ICollection<T>`, `IList<T>`) over
  concrete types.
- Use LINQ for querying and transforming collections. Keep queries readable.
- Use method syntax for simple queries, query syntax for complex multi-step
  operations.
- Avoid unnecessary `ToList()` calls; work with `IEnumerable<T>` when
  possible for lazy evaluation.
- Use `ImmutableCollections` from System.Collections.Immutable for
  thread-safe collections.

## Asynchronous Programming

- Use async/await for all I/O-bound operations (file, network, database).
- Avoid `async void` except for event handlers; use `async Task` instead.
- Use `ConfigureAwait(false)` in library code to avoid capturing
  synchronization context.
- Don't block on async code with `.Result` or `.Wait()`; use async all
  the way up.
- Use `Task.WhenAll` for concurrent operations, `Task.WhenAny` for racing
  operations.
- Implement cancellation support with `CancellationToken` for long-running
  operations.

## Modern C# Features

- Use pattern matching for type checks and deconstruction (C# 7+).
- Use tuples for returning multiple values from methods.
- Use local functions for helper methods used in a single method.
- Use `using` declarations (C# 8+) for simplified resource management.
- Use switch expressions for concise conditional assignments.
- Use records (C# 9+) for immutable data types and value-based equality.
- Use init-only properties for immutable initialization.
- Use required properties (C# 11+) to enforce initialization.

## Dependency Management

- Use NuGet for package management. Keep packages updated regularly.
- Use central package management for multi-project solutions.
- Audit dependencies with `dotnet list package --vulnerable` regularly.
- Minimize dependency footprint; avoid large libraries for simple utilities.
- Use package references (`<PackageReference>`) instead of packages.config.

## Testing and Quality Gates

- Write unit tests using xUnit, NUnit, or MSTest following project standards.
- Use test-driven development (TDD): write failing tests, implement, refactor.
- Use mocking frameworks (Moq, NSubstitute) to isolate units under test.
- Target at least 80% branch coverage for critical business logic.
- Use descriptive test method names with Given-When-Then or Arrange-Act-Assert.
- Separate unit tests from integration tests using test categories or projects.
- Use `[Theory]` with `[InlineData]` for parameterized tests.

## Security Considerations

- Validate and sanitize all external inputs (user input, API requests,
  uploads).
- Use parameterized queries with Entity Framework Core or ADO.NET; never
  concatenate SQL.
- Implement authentication and authorization using ASP.NET Core Identity
  or similar.
- Store secrets in Azure Key Vault, AWS Secrets Manager, or environment
  variables.
- Use HTTPS for all network communication. Configure HSTS in production.
- Enable security headers (CSP, X-Frame-Options, X-Content-Type-Options).
- Hash passwords with appropriate algorithms (bcrypt, Argon2, PBKDF2).
- Keep .NET runtime and all dependencies updated to patch vulnerabilities.

## Performance Guidance

- Profile with Visual Studio Profiler, dotTrace, or BenchmarkDotNet before
  optimizing.
- Use appropriate collection types for access patterns (Dictionary for
  lookups, List for sequential).
- Use `StringBuilder` for string concatenation in loops.
- Cache expensive operations with `MemoryCache` or distributed caching
  (Redis).
- Use `Span<T>` and `Memory<T>` for high-performance scenarios to reduce
  allocations.
- Minimize boxing/unboxing of value types.
- Use value types for small, short-lived data to reduce GC pressure.
- Use object pooling (`ObjectPool<T>`) for frequently allocated objects.

## Logging and Monitoring

- Use `Microsoft.Extensions.Logging` abstraction for consistent logging.
- Use structured logging with log levels: Critical, Error, Warning, Info,
  Debug, Trace.
- Use logging scopes for contextual information in distributed systems.
- Never log sensitive information (passwords, tokens, PII, credit cards).
- Implement health checks with `Microsoft.Extensions.Diagnostics.HealthChecks`.
- Use Application Insights or similar for production monitoring and telemetry.

## ASP.NET Core Specific (when applicable)

- Use dependency injection throughout; register services in `Program.cs`.
- Follow minimal API pattern for simple endpoints or Controllers for complex logic.
- Use appropriate HTTP status codes (200, 201, 400, 404, 500, etc.).
- Implement proper model validation with data annotations or FluentValidation.
- Use middleware for cross-cutting concerns (logging, error handling, auth).
- Implement proper exception handling with exception middleware.
- Use API versioning for backward compatibility.
- Enable response compression for production APIs.
- Use output caching for expensive, cacheable operations.

## Entity Framework Core Specific (when applicable)

- Use code-first migrations for database schema management.
- Always use async methods (`ToListAsync`, `FirstOrDefaultAsync`) for
  database operations.
- Use appropriate tracking behavior; use `AsNoTracking()` for read-only
  queries.
- Avoid N+1 query problems; use `Include()` for eager loading.
- Use projection (`Select`) to retrieve only needed columns.
- Implement proper indexing for frequently queried columns.
- Use connection pooling and configure appropriate timeout values.
