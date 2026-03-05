---
description: "Java implementation guardrails for application development."
applyTo: "**/*.java"
---

## Guiding Principles

- Follow Java's object-oriented principles: encapsulation, inheritance, and
  polymorphism. Design with SOLID principles in mind.
- Write self-documenting code through clear naming and structure. Good code
  should explain itself.
- Favor composition over inheritance for code reuse and flexibility.
- Keep classes focused and cohesive. Each class should have a single,
  well-defined responsibility.

## Style and Formatting

- Follow the Google Java Style Guide or Oracle's Code Conventions as a
  baseline. Use tools like Checkstyle to enforce consistency.
- Use 4-space or 2-space indentation consistently across the project.
- Place opening braces on the same line (K&R style) for consistency.
- Use meaningful names: classes in PascalCase, methods and variables in
  camelCase, constants in UPPER_SNAKE_CASE.
- Keep line length under 100-120 characters for readability.
- Organize imports alphabetically and remove unused imports. Use IDE
  auto-formatting features.

## Type System and Nullability

- Use appropriate access modifiers (`private`, `protected`, `public`) to
  enforce encapsulation.
- Prefer interfaces for public contracts; use abstract classes when sharing
  implementation.
- Use generics for type-safe collections and avoid raw types.
- Return `Optional<T>` for methods that may return null, making the
  nullability explicit.
- Use annotations like `@NonNull` and `@Nullable` to document nullability
  expectations.
- Check for null defensively when accepting parameters from external sources.

## Methods and Classes

- Keep methods small and focused. If a method exceeds 30-40 lines, consider
  extracting helpers.
- Use descriptive method names that express intent: `calculateTotalPrice()`
  not `calc()`.
- Limit method parameters to 3-4; use builder pattern or parameter objects
  for complex configurations.
- Override `equals()`, `hashCode()`, and `toString()` consistently when
  defining value objects.
- Use final fields for immutable state and prefer immutable classes when
  possible.

## Exception Handling

- Use checked exceptions for recoverable errors that callers should handle.
- Use unchecked exceptions (RuntimeException) for programming errors and
  unrecoverable conditions.
- Create custom exception classes for domain-specific errors extending
  appropriate base exceptions.
- Always provide meaningful exception messages with context.
- Use try-with-resources for automatic resource management (AutoCloseable
  resources).
- Never catch and swallow exceptions silently; log or rethrow with context.

## Collections and Streams

- Prefer interfaces over implementations: `List<String>` not
  `ArrayList<String>`.
- Use immutable collections from `Collections.unmodifiable*()` or Guava
  when appropriate.
- Use Java Streams API for functional-style operations on collections.
- Keep stream pipelines readable; break into intermediate variables if
  becoming too complex.
- Avoid side effects in stream operations; use collectors for terminal
  operations.
- Use parallel streams judiciously; measure performance before parallelizing.

## Concurrency and Threading

- Use `java.util.concurrent` utilities over low-level thread management.
- Prefer `ExecutorService` and thread pools over creating raw threads.
- Use `CompletableFuture` for asynchronous programming and composition.
- Synchronize access to shared mutable state with appropriate locks or
  concurrent collections.
- Document thread-safety expectations with annotations like `@ThreadSafe`
  and `@GuardedBy`.
- Prefer immutable objects to eliminate synchronization needs.

## Testing and Quality Gates

- Write unit tests using JUnit 5 (Jupiter) or the project's test framework.
- Follow test-driven development (TDD): write failing tests first, then
  implement.
- Use mocking frameworks (Mockito, EasyMock) to isolate units under test.
- Target at least 80% branch coverage for critical business logic.
- Organize tests with given-when-then or arrange-act-assert patterns.
- Use descriptive test method names that explain the scenario and expected
  outcome.
- Separate unit tests from integration tests; use different test suites.

## Dependency Management

- Use Maven or Gradle for dependency management. Keep `pom.xml` or
  `build.gradle` organized and documented.
- Declare explicit version numbers for dependencies; avoid version ranges
  in production.
- Regularly update dependencies and check for security vulnerabilities
  with OWASP Dependency-Check.
- Minimize dependency footprint; avoid including large libraries for small
  utility functions.
- Use dependency management sections to centralize version control in
  multi-module projects.

## Security Considerations

- Validate and sanitize all external inputs (user input, API requests,
  file uploads).
- Use parameterized queries or JPA/Hibernate for database access; never
  concatenate user input into SQL.
- Implement proper authentication and authorization. Use Spring Security
  or similar frameworks.
- Store secrets in secure configuration stores (environment variables,
  secret managers).
- Use HTTPS for all network communication in production.
- Implement proper logging without exposing sensitive data (passwords,
  tokens, PII).
- Keep the JVM and all dependencies updated to patch security
  vulnerabilities.

## Performance Guidance

- Profile with JProfiler, YourKit, or VisualVM before optimizing. Measure
  actual bottlenecks.
- Use appropriate data structures for the access patterns (HashMap for
  lookups, ArrayList for sequential access).
- Cache expensive computations when appropriate; use caching frameworks
  like Caffeine or Guava Cache.
- Minimize object creation in hot paths; reuse objects when safe.
- Use lazy initialization for expensive resources that may not be needed.
- Monitor garbage collection and tune JVM parameters for production
  workloads.

## Logging and Monitoring

- Use SLF4J with a concrete implementation (Logback, Log4j2) for logging.
- Log at appropriate levels: ERROR for failures, WARN for issues, INFO
  for significant events, DEBUG for diagnostics.
- Use structured logging with MDC (Mapped Diagnostic Context) for
  contextual information.
- Never log sensitive information (passwords, tokens, PII, credit cards).
- Include correlation IDs in logs for distributed tracing.
- Implement health checks and metrics for production monitoring.

## Modern Java Features (Java 8+)

- Use lambda expressions and method references for functional interfaces.
- Use the Streams API for collection processing.
- Use Optional to represent potentially absent values.
- Use default methods in interfaces for backward-compatible API evolution.
- Use the new Date/Time API (java.time) instead of legacy Date and Calendar.
- Use var for local variables when the type is obvious (Java 10+).
- Use records for simple data carriers (Java 14+).
- Use sealed classes for controlled inheritance hierarchies (Java 17+).

## Spring Framework Specific (when applicable)

- Use dependency injection and avoid creating dependencies manually.
- Prefer constructor injection over field injection for testability.
- Use Spring Boot for rapid application development and convention over
  configuration.
- Follow layered architecture: Controllers, Services, Repositories.
- Use appropriate annotations: `@Service`, `@Repository`, `@Component`,
  `@Controller`.
- Implement proper exception handling with `@ControllerAdvice`.
- Use Spring Data JPA for database access patterns.
