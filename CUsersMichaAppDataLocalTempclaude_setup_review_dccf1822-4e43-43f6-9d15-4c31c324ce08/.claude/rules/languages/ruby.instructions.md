---
description: "Ruby implementation guardrails for elegant and productive development."
applyTo: "**/*.rb"
---

## Guiding Principles

- Write beautiful, expressive code that reads like natural language. Ruby
  optimizes for developer happiness.
- Follow the principle of least surprise. Code should behave as expected.
- Embrace duck typing. Focus on what objects can do, not what they are.
- Keep methods small and focused. Each method should do one thing well.
- Optimize for readability and maintainability over cleverness.

## Style and Formatting

- Follow the Ruby Style Guide or use RuboCop to enforce consistency.
- Use 2-space indentation consistently.
- Use snake_case for methods and variables, CamelCase for classes and
  modules.
- Use SCREAMING_SNAKE_CASE for constants.
- Keep line length under 80-100 characters.
- Use Ruby's expressive syntax: prefer `unless` over `if !`, use guard
  clauses, use blocks idiomatically.

## Methods and Blocks

- Keep methods short, ideally under 10-15 lines. Extract private methods
  for complex logic.
- Use descriptive method names that express intent. Ruby allows long,
  readable names.
- Use `?` suffix for predicate methods returning boolean (`empty?`, `valid?`).
- Use `!` suffix for dangerous methods that modify state or can raise
  exceptions.
- Prefer keyword arguments over positional arguments for clarity.
- Use blocks idiomatically with `each`, `map`, `select`, `reduce`.
- Use `do...end` for multi-line blocks, `{...}` for single-line blocks.

## Object-Oriented Programming

- Use classes and modules to organize code. Favor composition over inheritance.
- Define clear interfaces with public methods; use `private` and `protected`
  for encapsulation.
- Use `attr_reader`, `attr_writer`, `attr_accessor` for simple attribute access.
- Implement `initialize` for object construction and setup.
- Use modules for mixins and shared behavior across classes.
- Implement custom `==`, `eql?`, and `hash` when defining value objects.
- Use `self` explicitly when calling setter methods or for clarity.

## Error Handling

- Use exceptions for exceptional conditions, not for control flow.
- Create custom exception classes inheriting from `StandardError` for
  domain errors.
- Use `raise` to raise exceptions with meaningful messages.
- Use `rescue` to handle specific exceptions; avoid bare `rescue`.
- Use `ensure` for cleanup code that must run regardless of exceptions.
- Use `begin...rescue...end` for exception handling blocks.
- Log exceptions with full context before handling or re-raising.

## Collections and Enumeration

- Use Ruby's rich enumerable methods: `each`, `map`, `select`, `reject`,
  `find`, `reduce`.
- Prefer enumerable methods over manual iteration for clarity and
  expressiveness.
- Use `Array` for ordered collections, `Hash` for key-value pairs, `Set`
  for unique values.
- Use symbols (`:symbol`) for hash keys for performance and idiomaticity.
- Use the new hash syntax for symbol keys: `{name: "John"}` not
  `{:name => "John"}`.
- Chain enumerable methods for functional-style transformations.

## String Manipulation

- Prefer string interpolation over concatenation: `"Hello #{name}"` not
  `"Hello " + name`.
- Use single quotes for strings without interpolation or escape sequences.
- Use double quotes for strings with interpolation or special characters.
- Use `%w[]` for arrays of strings: `%w[apple banana cherry]`.
- Use heredocs for multi-line strings with proper indentation (`<<~HEREDOC`).
- Use `String#freeze` or frozen string literals for immutable strings.

## Testing and Quality Gates

- Write tests using RSpec, Minitest, or the project's test framework.
- Follow test-driven development (TDD): write failing tests first, then
  implement.
- Use descriptive test names with `describe`, `context`, and `it` in RSpec.
- Use mocking and stubbing judiciously; prefer real objects when possible.
- Target high coverage for critical business logic; use SimpleCov for
  coverage reports.
- Separate unit tests from integration tests.
- Use factories (FactoryBot) or fixtures for test data setup.

## Dependency Management

- Use Bundler for dependency management with `Gemfile` and `Gemfile.lock`.
- Run `bundle update` carefully; review changes before updating gems.
- Use `bundle audit` to check for security vulnerabilities.
- Minimize dependencies; prefer the standard library when sufficient.
- Specify version constraints in `Gemfile` to prevent breaking changes.
- Use groups in `Gemfile` to organize dependencies by environment.

## Security Considerations

- Validate and sanitize all user inputs before processing or storing.
- Use strong parameters in Rails to prevent mass assignment vulnerabilities.
- Use parameterized queries or ActiveRecord to prevent SQL injection.
- Never use `eval`, `instance_eval`, or `class_eval` with user input.
- Store secrets in environment variables or secure vaults; use `dotenv`
  for local development.
- Keep gems updated to patch security vulnerabilities.
- Use secure cookie sessions with encryption and signing.
- Implement proper authentication and authorization (Devise, Pundit, CanCanCan).

## Performance Guidance

- Profile with `ruby-prof`, `stackprof`, or `benchmark-ips` before optimizing.
- Avoid premature optimization; measure actual bottlenecks first.
- Use appropriate data structures for access patterns.
- Minimize object allocations in hot paths.
- Use `Symbol` instead of `String` for repeated identifiers.
- Consider memoization with `||=` for expensive computations.
- Use background jobs (Sidekiq, Resque) for long-running operations.
- Use caching (Redis, Memcached) for expensive database queries.

## Rails Specific (when applicable)

- Follow Rails conventions for directory structure and naming.
- Use ActiveRecord effectively; understand N+1 queries and use `includes`
  for eager loading.
- Keep controllers thin; move business logic to models or service objects.
- Use strong parameters to whitelist allowed attributes.
- Use validations in models to ensure data integrity.
- Use callbacks sparingly; prefer explicit method calls when possible.
- Use concerns for shared behavior across models or controllers.
- Implement proper pagination for large datasets (kaminari, pagy).
- Use ActiveJob for background processing with various backends.

## Metaprogramming

- Use metaprogramming judiciously; prefer explicit code when possible.
- Use `method_missing` sparingly; implement `respond_to_missing?` when
  using it.
- Use `define_method` for dynamic method definitions when appropriate.
- Use `send` to call methods dynamically, but prefer direct calls.
- Document metaprogramming clearly; it can be hard to understand.
- Test metaprogrammed code thoroughly with various inputs.

## Concurrency

- Understand Ruby's Global Interpreter Lock (GIL) limitations in MRI.
- Use threads for I/O-bound operations; use processes for CPU-bound work.
- Use thread-safe data structures or synchronization primitives (`Mutex`).
- Consider using Ractors (Ruby 3.0+) for true parallelism.
- Use background job processors (Sidekiq) for asynchronous work.
- Be cautious with mutable shared state in concurrent code.

## Modern Ruby Features (Ruby 2.7+)

- Use pattern matching for complex conditional logic (Ruby 2.7+).
- Use numbered parameters (`_1`, `_2`) for simple blocks (Ruby 2.7+).
- Use the new hash syntax for symbol keys: `{name: "John"}`.
- Use keyword arguments with proper defaults and required parameters.
- Use `then` (or `yield_self`) for method chaining transformations.
- Use endless methods for simple one-liners (Ruby 3.0+): `def double(x) = x * 2`.
- Use rightward assignment for experimental inline transformations.

## Logging and Monitoring

- Use Ruby's Logger or structured logging libraries (semantic_logger).
- Log at appropriate levels: FATAL, ERROR, WARN, INFO, DEBUG.
- Include contextual information in logs (request IDs, user IDs).
- Never log sensitive information (passwords, tokens, PII).
- Use monitoring tools (New Relic, Datadog, Scout) for production systems.
- Implement health check endpoints for monitoring.
- Track application metrics (response times, error rates, throughput).

## Documentation

- Write clear comments for complex logic, but prefer self-documenting code.
- Use RDoc or YARD for API documentation.
- Document public methods with parameter descriptions and return values.
- Keep README files updated with setup instructions and usage examples.
- Document configuration options and environment variables.

## Code Organization

- Keep files focused on a single class or module.
- Use Ruby's file naming convention: `user_account.rb` for `UserAccount`.
- Organize code into logical directories following Rails or project conventions.
- Use namespaces (modules) to prevent naming conflicts.
- Keep related functionality together in the same directory.
- Extract shared behavior into modules or lib files.
