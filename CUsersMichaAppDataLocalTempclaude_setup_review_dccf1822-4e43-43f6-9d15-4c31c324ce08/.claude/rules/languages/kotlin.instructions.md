---
description: "Kotlin implementation guardrails for modern JVM and Android development."
applyTo: "**/*.kt,**/*.kts"
---

## Guiding Principles

- Write concise, expressive Kotlin code that leverages the language's modern
  features and null safety.
- Embrace Kotlin's interoperability with Java while using idiomatic Kotlin
  patterns.
- Use the type system to prevent errors at compile time.
- Follow Kotlin's coding conventions for consistency across the ecosystem.
- Write clean, maintainable code that expresses intent clearly.

## Style and Formatting

- Follow the official Kotlin Coding Conventions.
- Use ktlint or ktfmt for automatic code formatting.
- Use 4-space indentation consistently.
- Use camelCase for functions and properties, PascalCase for classes.
- Use UPPER_SNAKE_CASE for constants (top-level or object declarations).
- Keep line length under 100-120 characters.
- Use trailing commas in multi-line declarations and function calls.

## Null Safety

- Leverage Kotlin's null safety to prevent NullPointerException at compile time.
- Use nullable types (`?`) explicitly for values that may be null.
- Use safe call operator (`?.`) for safe property access.
- Use Elvis operator (`?:`) for default values when null.
- Use `!!` only when you're certain a value is non-null (use sparingly).
- Use `let`, `run`, `apply`, `also`, `with` for safe null handling.
- Use `requireNotNull()` or `checkNotNull()` for assertions with messages.

## Functions and Lambdas

- Use `fun` to define functions with clear, descriptive names.
- Use single-expression functions for simple operations: `fun double(x: Int) = x * 2`.
- Use default parameters instead of overloading methods.
- Use named arguments for clarity when calling functions with many parameters.
- Use lambda syntax for functional operations and callbacks.
- Use trailing lambda syntax when lambda is the last parameter.
- Use `it` for single-parameter lambdas, explicit names for multiple parameters.
- Mark functions with `inline` for performance when passing lambdas.

## Properties and Variables

- Use `val` for immutable values, `var` for mutable ones. Prefer `val` by default.
- Use custom getters/setters when logic is needed beyond simple storage.
- Use backing properties with `private` visibility when needed.
- Use lazy properties with `by lazy` for expensive initialization.
- Use `lateinit` for non-null properties initialized later (avoid when possible).
- Use delegated properties (`by`) for reusable property behaviors.
- Use const for compile-time constants: `const val MAX_SIZE = 100`.

## Classes and Objects

- Use data classes for simple data holders; they provide equals, hashCode,
  toString automatically.
- Use sealed classes for restricted class hierarchies (alternative to enums
  with state).
- Use object declarations for singletons.
- Use companion objects for factory methods and constants related to a class.
- Use primary constructors for simple initialization.
- Use secondary constructors when multiple initialization paths are needed.
- Use `init` blocks for initialization logic.

## Interfaces and Inheritance

- Use interfaces to define contracts and enable polymorphism.
- Provide default implementations in interfaces when appropriate.
- Override functions and properties with the `override` keyword.
- Mark classes `open` if they're designed for inheritance; classes are
  final by default.
- Use abstract classes when you need to share state or implementation.
- Prefer composition over inheritance for flexibility.

## Extension Functions

- Use extension functions to add functionality to existing classes.
- Keep extension functions focused and cohesive.
- Place extension functions close to their usage or in dedicated utility files.
- Be aware that extensions are resolved statically based on receiver type.
- Avoid shadowing existing member functions with extensions.
- Use receiver types to make DSLs readable: `"string".toInt()`.

## Collections

- Use Kotlin's collection types: `List`, `Set`, `Map` for read-only,
  `MutableList`, `MutableSet`, `MutableMap` for mutable.
- Prefer read-only collections by default; use mutable only when necessary.
- Use collection literals: `listOf()`, `setOf()`, `mapOf()`, `mutableListOf()`.
- Use collection operations: `map`, `filter`, `reduce`, `fold`, `flatMap`,
  `groupBy`.
- Use sequences for lazy evaluation of large or infinite collections.
- Use array-specific functions when working with arrays.

## Type System

- Use type inference when the type is obvious from context.
- Specify types explicitly for public APIs for clarity.
- Use generics for type-safe reusable code.
- Use variance annotations: `out` for covariance, `in` for contravariance.
- Use type aliases (`typealias`) for complex type signatures.
- Use reified type parameters with inline functions for type information
  at runtime.
- Use star projection (`*`) for unknown types in generics.

## Coroutines and Concurrency

- Use coroutines for asynchronous programming (kotlinx.coroutines).
- Mark suspending functions with `suspend` keyword.
- Use `launch` to start a coroutine without returning a result.
- Use `async/await` for concurrent operations that return results.
- Use structured concurrency with `coroutineScope` and `supervisorScope`.
- Use `withContext` to switch coroutine context (e.g., to Dispatchers.IO).
- Use `Flow` for asynchronous data streams.
- Handle cancellation properly; use `isActive` or cancellable operations.
- Use `Mutex` or `Semaphore` for synchronization when needed.

## Error Handling

- Use exceptions for exceptional conditions.
- Use `try-catch-finally` for exception handling.
- Create custom exception classes extending appropriate base exceptions.
- Use `runCatching` for functional-style exception handling returning `Result`.
- Use sealed classes or `Result` for typed error handling.
- Use `check()`, `require()`, and `requireNotNull()` for preconditions.
- Document exceptions that functions may throw.

## Scope Functions

- Use `let` for null checks and transformations: `value?.let { use(it) }`.
- Use `run` for executing a block and returning result.
- Use `apply` for object configuration (returns the receiver).
- Use `also` for side effects (returns the receiver).
- Use `with` for calling multiple methods on an object without returning it.
- Choose the right scope function based on receiver (`this` vs `it`) and
  return value.

## Testing and Quality Gates

- Write unit tests using JUnit 5 or Kotest.
- Use MockK or Mockito-Kotlin for mocking.
- Follow test-driven development for complex business logic.
- Use descriptive test names or Given-When-Then structure.
- Test coroutines with `runTest` from kotlinx-coroutines-test.
- Target high coverage for critical code paths.
- Separate unit tests from integration tests.

## Dependency Management

- Use Gradle with Kotlin DSL for build configuration.
- Use version catalogs for centralized dependency management.
- Keep dependencies updated regularly.
- Audit dependencies for security vulnerabilities.
- Minimize dependency footprint; use standard library when sufficient.
- Use dependency injection frameworks (Koin, Dagger, Hilt) appropriately.

## Security Considerations

- Validate all external inputs before processing.
- Use parameterized queries or ORMs to prevent SQL injection.
- Store secrets in secure storage; use environment variables or secret
  managers.
- Use HTTPS for all network communication.
- Implement proper authentication and authorization.
- Handle sensitive data appropriately; don't log passwords or tokens.
- Keep Kotlin, dependencies, and runtime updated for security patches.

## Performance Guidance

- Profile with Android Profiler or JVM profilers before optimizing.
- Use inline functions for higher-order functions to reduce overhead.
- Use sequences for lazy evaluation of large collections.
- Minimize object allocations in hot paths.
- Use primitive types when boxing overhead matters.
- Use data classes for automatic equals/hashCode with good performance.
- Cache expensive computations when appropriate.
- Use appropriate data structures for access patterns.

## Android Specific (when applicable)

- Use Android Architecture Components: ViewModel, LiveData, Room.
- Follow MVVM or MVI architecture for clear separation of concerns.
- Use ViewBinding or DataBinding for view access (avoid findViewById).
- Use Jetpack Compose for modern declarative UI (when appropriate).
- Handle Android lifecycle properly; clean up in appropriate lifecycle methods.
- Use coroutines with lifecycle-aware scopes: `viewModelScope`,
  `lifecycleScope`.
- Implement proper dependency injection with Hilt or Koin.
- Use WorkManager for background tasks.

## Jetpack Compose (when applicable)

- Write composable functions with the `@Composable` annotation.
- Keep composables small and focused; extract reusable components.
- Use state hoisting to make composables reusable and testable.
- Use `remember` to preserve state across recompositions.
- Use `rememberSaveable` for state that survives configuration changes.
- Use `derivedStateOf` for computed state that depends on other state.
- Use side effects appropriately: `LaunchedEffect`, `DisposableEffect`,
  `SideEffect`.
- Follow Material Design guidelines for consistent UI.

## Multiplatform (when applicable)

- Use Kotlin Multiplatform for sharing code across platforms.
- Structure code into `commonMain`, `androidMain`, `iosMain`, etc.
- Use `expect`/`actual` for platform-specific implementations.
- Keep common code truly common; minimize platform-specific code.
- Use platform-specific APIs through expect/actual declarations.
- Test on all target platforms.

## Logging and Debugging

- Use SLF4J or Logback for logging in JVM applications.
- Use Timber for logging in Android applications.
- Log at appropriate levels: ERROR, WARN, INFO, DEBUG, VERBOSE.
- Never log sensitive information (passwords, tokens, PII).
- Include contextual information in logs for debugging.
- Use breakpoints and debugger for troubleshooting.

## Documentation

- Write KDoc comments for public APIs using `/**  */`.
- Document parameters with `@param`, returns with `@return`, exceptions
  with `@throws`.
- Keep documentation concise and up-to-date.
- Use code examples in documentation when helpful.
- Generate documentation with Dokka.

## Interoperability with Java

- Use `@JvmStatic` for functions in companion objects to be called as
  static from Java.
- Use `@JvmField` to expose properties as fields to Java.
- Use `@JvmName` to customize JVM method names for overloads.
- Use `@JvmOverloads` to generate overloaded methods for default parameters.
- Be aware of platform types from Java (nullable/non-null ambiguity).
- Handle checked exceptions from Java with `@Throws` annotation.

## Modern Kotlin Features

- Use type-safe builders for DSL creation.
- Use operator overloading for intuitive APIs when appropriate.
- Use destructuring declarations for data classes and Pair/Triple.
- Use ranges and progressions: `1..10`, `10 downTo 1`.
- Use `when` expressions for powerful conditional logic.
- Use sealed interfaces (Kotlin 1.5+) for sealed hierarchies.
- Use context receivers (experimental) for contextual abstractions.

## Best Practices

- Follow the official Kotlin coding conventions.
- Use ktlint or detekt for static analysis and code quality.
- Enable compiler warnings and treat them as errors.
- Prefer immutability with `val` by default.
- Use null safety features to prevent null pointer issues.
- Write expressive code using Kotlin's language features.
- Keep functions and classes small and focused.
- Test thoroughly with appropriate test frameworks.
- Review Kotlin evolution proposals and adopt stable features.
