---
description: "Swift implementation guardrails for iOS, macOS, and Apple ecosystem development."
applyTo: "**/*.swift"
---

## Guiding Principles

- Write clean, expressive Swift code that leverages the language's safety
  and modern features.
- Embrace Swift's type safety and optionals to prevent runtime errors.
- Follow Apple's API Design Guidelines for consistency with the ecosystem.
- Optimize for clarity and safety first, then performance.
- Make invalid states unrepresentable through the type system.

## Style and Formatting

- Follow the Swift Style Guide or use SwiftLint to enforce consistency.
- Use 4-space indentation consistently.
- Use camelCase for properties and methods, PascalCase for types.
- Use lowercase for acronyms in camelCase: `urlString` not `URLString`.
- Keep line length under 100-120 characters.
- Use trailing closures for the last closure parameter.
- Use implicit returns for single-expression closures and computed properties.

## Type System and Optionals

- Use optionals (`?`) to represent values that may be absent.
- Prefer optional binding (`if let`, `guard let`) over force unwrapping (`!`).
- Use `guard` statements for early exits and to maintain the golden path.
- Use nil coalescing operator (`??`) for default values.
- Use optional chaining (`?.`) for safe property access.
- Avoid implicitly unwrapped optionals (`!`) except for view outlets.
- Use `Result` type for operations that can succeed or fail with typed errors.

## Properties and Methods

- Use `let` for immutable values, `var` for mutable ones. Prefer `let`
  by default.
- Use computed properties for derived values instead of methods when
  appropriate.
- Use property observers (`didSet`, `willSet`) for side effects on value
  changes.
- Use lazy properties for expensive initialization that may not be needed.
- Use static properties for type-level constants and computed values.
- Keep methods focused and concise, ideally under 20-30 lines.

## Functions and Closures

- Use clear, descriptive parameter labels for readability.
- Use `_` for the first parameter label when it reads naturally without it.
- Use trailing closure syntax when the closure is the last parameter.
- Use shorthand argument names (`$0`, `$1`) for simple closures.
- Use capture lists `[weak self]` or `[unowned self]` to prevent retain cycles.
- Mark functions with `@discardableResult` when return values are optional to use.
- Use `throws` and `throw` for error handling in functions that can fail.

## Error Handling

- Use Swift's error handling with `throws`, `throw`, and `try`.
- Create custom error types conforming to `Error` protocol.
- Use `do-catch` blocks to handle errors appropriately.
- Use `try?` for optional conversion when you don't care about the error.
- Use `try!` only when you're certain an error won't occur (rarely).
- Use `defer` for cleanup code that must run before exiting scope.
- Provide meaningful error messages with associated values in error enums.

## Protocols and Extensions

- Use protocols to define interfaces and enable polymorphism.
- Prefer protocol composition over class inheritance for flexibility.
- Use protocol extensions to provide default implementations.
- Use extensions to organize code by functionality or protocol conformance.
- Keep type definitions focused; use extensions to add conformances.
- Use `where` clauses to constrain protocol extensions conditionally.
- Document protocol requirements and default behaviors clearly.

## Generics

- Use generics for type-safe, reusable code.
- Constrain generic types with protocol conformances when needed.
- Use associated types in protocols for type relationships.
- Use `where` clauses for complex generic constraints.
- Keep generic code readable; extract complex logic into helpers.
- Prefer protocols with associated types over generic classes when possible.

## Collections

- Use `Array` for ordered collections, `Set` for unique unordered items,
  `Dictionary` for key-value pairs.
- Use collection literals for initialization: `[1, 2, 3]`, `["key": "value"]`.
- Use higher-order functions: `map`, `filter`, `reduce`, `compactMap`,
  `flatMap`.
- Use `for-in` loops for iteration when higher-order functions aren't clearer.
- Use array slicing and ranges for subsequences.
- Prefer immutable collections (`let`) by default for safety and performance.

## Memory Management

- Understand ARC (Automatic Reference Counting) and reference semantics.
- Use `weak` references to prevent retain cycles in closures and delegates.
- Use `unowned` when the referenced object will never be nil after first
  assignment.
- Be cautious with closures that capture `self`; use capture lists to
  prevent leaks.
- Use value types (structs, enums) by default; use reference types (classes)
  when needed.
- Profile for memory leaks using Instruments; check retain cycles.

## Structs vs Classes

- Prefer structs for simple data types and value semantics.
- Use classes when you need reference semantics, inheritance, or deinitializers.
- Use structs for immutability by default; copies don't affect the original.
- Use classes for shared mutable state or identity-based equality.
- Consider copy-on-write for large structs that may be mutated.

## Enums and Pattern Matching

- Use enums for related values and state machines.
- Use associated values in enums for data attached to cases.
- Use pattern matching with `switch` for exhaustive handling of cases.
- Make switches exhaustive; avoid `default` when you want compile-time
  checking of all cases.
- Use `if case` and `guard case` for single-case matching.
- Use enum raw values for simple underlying types (Int, String).

## Concurrency and Async/Await

- Use async/await for asynchronous operations (Swift 5.5+).
- Mark functions with `async` that perform asynchronous work.
- Use `await` to call async functions and wait for results.
- Use `Task` to create concurrent work.
- Use `async let` for concurrent binding and parallel execution.
- Use actors for safe mutable state across concurrency (Swift 5.5+).
- Use `@MainActor` for UI-related code that must run on the main thread.
- Avoid callback-based patterns; prefer structured concurrency.

## Testing and Quality Gates

- Write unit tests using XCTest or Swift Testing framework.
- Follow test-driven development for complex business logic.
- Use descriptive test function names that explain the scenario.
- Use XCTest assertions: `XCTAssertEqual`, `XCTAssertTrue`, `XCTAssertNil`.
- Use mocking and stubbing for external dependencies.
- Target high coverage for critical code paths.
- Separate unit tests from UI tests and integration tests.

## Dependency Management

- Use Swift Package Manager (SPM) for dependency management in modern projects.
- Use CocoaPods or Carthage for legacy projects or when SPM isn't sufficient.
- Keep dependencies minimal; prefer standard library and Apple frameworks.
- Audit dependencies for security vulnerabilities.
- Specify version constraints carefully to prevent breaking changes.
- Review dependency updates before integrating.

## Security Considerations

- Validate all user inputs before processing or storing.
- Use Keychain for storing sensitive data like passwords and tokens.
- Avoid hardcoding secrets in code; use configuration or secure storage.
- Use HTTPS for all network communication; enable App Transport Security (ATS).
- Implement proper authentication and authorization.
- Sanitize data before display to prevent injection attacks.
- Keep dependencies and iOS/macOS versions updated for security patches.
- Use Face ID / Touch ID for sensitive operations when appropriate.

## Performance Guidance

- Profile with Instruments before optimizing; measure actual bottlenecks.
- Use value types (structs) for better performance through stack allocation.
- Minimize reference counting overhead by using value types.
- Use lazy properties for expensive initialization.
- Use `@autoclosure` for delayed evaluation when appropriate.
- Avoid premature optimization; write clear code first.
- Use copy-on-write for large collections that may be mutated.
- Cache expensive computations when appropriate.

## SwiftUI Specific (when applicable)

- Use SwiftUI's declarative syntax for UI construction.
- Keep views small and composable; extract subviews for clarity.
- Use `@State` for view-local state, `@Binding` for two-way bindings.
- Use `@ObservedObject` or `@StateObject` for reference type models.
- Use `@EnvironmentObject` for shared data across the view hierarchy.
- Use `@Published` in ObservableObject to trigger view updates.
- Prefer primitive types in view state to avoid unnecessary redraws.
- Use view modifiers to customize appearance and behavior.

## UIKit Specific (when applicable)

- Use Interface Builder or programmatic UI consistently within a project.
- Use Auto Layout for responsive, adaptive interfaces.
- Implement proper view lifecycle methods: `viewDidLoad`,
  `viewWillAppear`, etc.
- Avoid retain cycles between view controllers and closures.
- Use delegation pattern for communication between view controllers.
- Implement proper memory management; override `deinit` for cleanup.
- Use MVC, MVVM, or other architectural patterns consistently.

## Combine Framework (when applicable)

- Use Combine for reactive programming and data flow.
- Use publishers and subscribers for asynchronous event handling.
- Use operators to transform, filter, and combine streams.
- Cancel subscriptions in `deinit` or use `AnyCancellable` storage.
- Use `@Published` for observable properties in view models.
- Understand backpressure and buffering for stream management.

## Logging and Debugging

- Use `os_log` or unified logging for production logging.
- Use appropriate log levels: debug, info, default, error, fault.
- Avoid `print()` statements in production code; use proper logging.
- Never log sensitive information (passwords, tokens, PII).
- Use breakpoints and LLDB for debugging.
- Use Instruments for performance profiling and memory analysis.

## Documentation

- Write documentation comments using triple-slash `///` for public APIs.
- Use markup for formatted documentation: parameters, returns, notes.
- Document complex logic, business rules, and non-obvious code.
- Keep documentation up-to-date with code changes.
- Generate documentation with DocC (Xcode 13+) for browsable docs.

## Modern Swift Features

- Use result builders for DSL-style APIs (used in SwiftUI).
- Use property wrappers for reusable property behaviors.
- Use opaque return types (`some Protocol`) to hide concrete types.
- Use `@available` to annotate API availability across OS versions.
- Use string interpolation for formatted strings: `"Hello \(name)"`.
- Use multi-line string literals with proper indentation.

## Best Practices

- Follow the Swift API Design Guidelines from Apple.
- Use SwiftLint or SwiftFormat for consistent code style.
- Enable compiler warnings and treat them as errors in projects.
- Write clear, self-documenting code with descriptive names.
- Prefer immutability with `let` by default.
- Use guard statements for preconditions and early exits.
- Handle errors explicitly; don't ignore them.
- Test on actual devices, not just simulators, when possible.
- Keep up with Swift evolution proposals and adopt new features
  appropriately.
