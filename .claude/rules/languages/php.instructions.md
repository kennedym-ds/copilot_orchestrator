---
description: "PHP implementation guardrails for modern web application development."
applyTo: "**/*.php"
---

## Guiding Principles

- Write modern PHP (7.4+, preferably 8.0+) using type declarations and
  recent language features.
- Follow PHP Standards Recommendations (PSR) for interoperability and
  consistency.
- Embrace object-oriented programming with clear separation of concerns.
- Keep security at the forefront; validate inputs and sanitize outputs.
- Write maintainable code that's easy to understand and modify.

## Style and Formatting

- Follow PSR-12 coding style standard for consistency.
- Use PHP_CodeSniffer or PHP CS Fixer to enforce style automatically.
- Use 4-space indentation consistently.
- Use opening braces on the same line for methods and functions (PSR-12).
- Use `camelCase` for methods and variables, `PascalCase` for classes.
- Use UPPER_CASE for constants.
- Keep line length under 120 characters.

## PHP Version and Features

- Target PHP 8.0+ for new projects to leverage modern features.
- Use strict types: `declare(strict_types=1);` at the top of each file.
- Use type declarations for parameters, return types, and properties.
- Use nullable types (`?Type`) or union types (`Type1|Type2`) as appropriate.
- Use named arguments (PHP 8.0+) for clarity in function calls with many
  parameters.
- Use constructor property promotion (PHP 8.0+) for cleaner code:
  ```php
  public function __construct(
      public string $name,
      public int $age
  ) {}
  ```
- Use match expressions (PHP 8.0+) instead of switch when appropriate.
- Use readonly properties (PHP 8.1+) for immutable data.

## Object-Oriented Programming

- Use classes and objects to organize code and encapsulate behavior.
- Use interfaces to define contracts and enable polymorphism.
- Use abstract classes for shared implementation across related classes.
- Follow SOLID principles: Single Responsibility, Open/Closed,
  Liskov Substitution, Interface Segregation, Dependency Inversion.
- Use dependency injection instead of creating dependencies directly.
- Use traits for code reuse across unrelated classes, but use sparingly.
- Favor composition over inheritance for flexibility.

## Functions and Methods

- Keep methods small and focused, ideally under 20-30 lines.
- Use descriptive method names that express intent and action.
- Limit method parameters to 3-4; use objects for complex configurations.
- Use type declarations for all parameters and return types.
- Return early from functions to reduce nesting and improve readability.
- Use void return type when methods don't return a value.
- Make methods private or protected by default; expose only what's necessary.

## Error Handling

- Use exceptions for error handling, not error codes or boolean returns.
- Create custom exception classes extending `Exception` or SPL exceptions.
- Throw specific exception types that describe the error condition.
- Catch exceptions at appropriate boundaries; don't catch everything everywhere.
- Use try-catch-finally for cleanup code that must run.
- Log exceptions with full context including stack traces.
- Use type-hinted catch blocks: `catch (SpecificException $e)`.
- Never catch `Throwable` unless you're a framework or top-level error handler.

## Arrays and Collections

- Use array syntax `[]` instead of `array()` for cleaner code.
- Use typed arrays in documentation: `@param array<int, string> $items`.
- Use array functions: `array_map`, `array_filter`, `array_reduce` for
  transformations.
- Use spread operator `...` for array merging and unpacking (PHP 7.4+).
- Consider using Collections libraries (Laravel Collections, Doctrine
  Collections) for rich operations.
- Use associative arrays for key-value pairs, indexed arrays for lists.

## Strings

- Use single quotes for simple strings, double quotes for interpolation.
- Use concatenation operator `.` for joining strings.
- Use sprintf or string interpolation for complex string formatting.
- Use heredoc or nowdoc for multi-line strings.
- Sanitize strings before output to prevent XSS attacks.
- Use mb_* functions for multi-byte string operations (UTF-8).

## Database Access

- Use PDO or prepared statements to prevent SQL injection.
- Never concatenate user input directly into SQL queries.
- Use parameter binding with placeholders: `?` or `:name`.
- Use transactions for operations requiring atomicity.
- Use an ORM like Doctrine or Eloquent for complex database interactions.
- Handle database errors properly; don't expose internal errors to users.
- Use connection pooling and persistent connections appropriately.

## Security Considerations

- Validate all user inputs; never trust external data.
- Sanitize outputs to prevent XSS attacks using `htmlspecialchars()` or
  templating engines with auto-escaping.
- Use prepared statements or ORMs to prevent SQL injection.
- Hash passwords with `password_hash()` and verify with `password_verify()`.
- Use `password_hash()` with PASSWORD_DEFAULT or PASSWORD_ARGON2ID.
- Store secrets in environment variables or secure configuration, not in code.
- Implement CSRF protection for state-changing operations.
- Use HTTPS for all production traffic; set secure cookie flags.
- Validate file uploads; check MIME types and file extensions.
- Limit file upload sizes and store uploads outside the web root.
- Keep PHP and all dependencies updated to patch vulnerabilities.
- Use Content Security Policy (CSP) headers to mitigate XSS.

## Testing and Quality Gates

- Write unit tests using PHPUnit or similar frameworks.
- Follow test-driven development (TDD) for complex business logic.
- Use mocking for external dependencies (PHPUnit mocks, Mockery).
- Target high coverage for critical business logic (80%+).
- Write integration tests for database and API interactions.
- Use descriptive test method names that explain the scenario.
- Organize tests to mirror the source code structure.
- Run tests in CI/CD pipelines before deployment.

## Dependency Management

- Use Composer for dependency management.
- Keep `composer.json` and `composer.lock` in version control.
- Run `composer update` carefully; review changes before committing.
- Use semantic versioning constraints: `^2.0` for compatible updates.
- Run `composer audit` to check for security vulnerabilities.
- Minimize dependencies; avoid large packages for simple utilities.
- Use autoloading (PSR-4) for automatic class loading.

## Performance Guidance

- Profile with Xdebug, Blackfire, or New Relic before optimizing.
- Cache expensive operations (database queries, API calls) with Redis or
  Memcached.
- Use opcode caching (OPcache) enabled in production.
- Minimize database queries; use eager loading to prevent N+1 problems.
- Use appropriate data structures for access patterns.
- Defer expensive operations to background jobs (queue systems like RabbitMQ).
- Use lazy loading for resources that may not be needed.
- Enable compression for HTTP responses (gzip).

## Framework-Specific Practices

### Laravel (when applicable)
- Follow Laravel conventions and best practices.
- Use Eloquent ORM with relationships and eager loading.
- Use migrations for database schema management.
- Use validation rules for request validation.
- Use service providers for dependency injection configuration.
- Use middleware for cross-cutting concerns (auth, logging, CORS).
- Use queues for asynchronous processing.
- Use events and listeners for decoupled application flow.

### Symfony (when applicable)
- Follow Symfony best practices and conventions.
- Use dependency injection container for services.
- Use Doctrine ORM for database interactions.
- Use forms and validators for input handling.
- Use Twig for templating with auto-escaping.
- Use console commands for CLI applications.
- Use events for decoupled architecture.

## Logging and Monitoring

- Use PSR-3 compliant logging libraries (Monolog).
- Log at appropriate levels: DEBUG, INFO, WARNING, ERROR, CRITICAL.
- Include context in logs (user IDs, request IDs, timestamps).
- Never log sensitive information (passwords, tokens, credit cards, PII).
- Use structured logging for easier parsing and analysis.
- Implement error tracking (Sentry, Rollbar) for production monitoring.
- Monitor application performance and errors in production.

## Code Organization

- Follow PSR-4 autoloading standard for class organization.
- Organize code by feature or domain, not by type.
- Keep controllers thin; move business logic to services or domain models.
- Use namespaces to organize code and prevent naming conflicts.
- Separate configuration, business logic, and presentation layers.
- Use repositories for data access abstraction.
- Use service classes for complex business operations.

## Documentation

- Write PHPDoc comments for classes, methods, and complex functions.
- Document parameter types, return types, and exceptions: `@param`,
  `@return`, `@throws`.
- Use IDE-friendly type hints in PHPDoc for better autocomplete.
- Keep documentation up-to-date with code changes.
- Document complex algorithms, business rules, and non-obvious code.
- Generate API documentation with phpDocumentor or similar tools.

## Modern PHP Features (PHP 8.0+)

- Use union types for parameters and return types: `int|string`.
- Use named arguments for clarity: `function(name: "value")`.
- Use match expressions for cleaner switch alternatives.
- Use constructor property promotion to reduce boilerplate.
- Use attributes instead of annotations (PHP 8.0+).
- Use nullsafe operator: `$obj?->method()` (PHP 8.0+).
- Use throw expressions in expressions (PHP 8.0+).
- Use enums for type-safe sets of values (PHP 8.1+).
- Use readonly properties for immutability (PHP 8.1+).
- Use first-class callable syntax (PHP 8.1+): `strlen(...)`.

## Best Practices

- Follow PSR standards (PSR-1, PSR-2/PSR-12, PSR-3, PSR-4, PSR-7).
- Use strict types in all files for type safety.
- Never use `eval()` or similar dynamic code execution.
- Avoid superglobals (`$_GET`, `$_POST`) directly; use request objects.
- Use environment variables for configuration, not hardcoded values.
- Validate and sanitize all inputs; escape all outputs.
- Use version control (Git) for all code.
- Write tests for critical business logic.
- Keep dependencies updated and audit for vulnerabilities.
- Use static analysis tools (PHPStan, Psalm) to catch type errors.
