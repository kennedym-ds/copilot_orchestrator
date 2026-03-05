---
description: "Rust implementation guardrails for safe and efficient systems programming."
applyTo: "**/*.rs"
---

## Guiding Principles

- Embrace Rust's ownership and borrowing system. Let the compiler guide
  you to memory-safe code.
- Follow the principle of zero-cost abstractions. Use high-level constructs
  without runtime overhead.
- Make invalid states unrepresentable through the type system.
- Be explicit about error handling. Use `Result` and `Option` effectively.
- Write idiomatic Rust that leverages the language's strengths.

## Style and Formatting

- Use `rustfmt` to format all code automatically. Configure it in
  `rustfmt.toml` if needed.
- Use `clippy` for linting and catching common mistakes. Fix clippy
  warnings in CI.
- Follow the Rust API Guidelines for public APIs.
- Use snake_case for functions and variables, CamelCase for types and traits.
- Use SCREAMING_SNAKE_CASE for constants and statics.
- Keep line length under 100 characters.

## Ownership and Borrowing

- Understand ownership rules: each value has one owner, ownership can be
  transferred (moved), and borrowing allows temporary access.
- Prefer borrowing over moving when the caller retains ownership.
- Use immutable references (`&T`) by default; use mutable references
  (`&mut T`) only when necessary.
- Keep borrow scopes as short as possible to minimize lifetime complexity.
- Use `clone()` judiciously; understand the performance implications.
- Avoid `Rc`/`Arc` unless truly needed for shared ownership.
- Use `Cow` (Clone on Write) for efficient read-heavy workloads with
  occasional writes.

## Error Handling

- Use `Result<T, E>` for operations that can fail. Avoid panicking in
  library code.
- Use `Option<T>` for values that may be absent.
- Use the `?` operator to propagate errors concisely.
- Implement the `Error` trait for custom error types.
- Use `anyhow` for application error handling, `thiserror` for library
  error types.
- Use `unwrap()` and `expect()` only when you're certain a value exists
  or want to intentionally panic.
- Provide meaningful error messages with context using `context()` from
  anyhow.

## Functions and Methods

- Keep functions small and focused. Extract helpers when functions grow
  too large.
- Use descriptive function names that express intent.
- Prefer taking slices (`&[T]`) over `&Vec<T>` for flexibility.
- Take string slices (`&str`) instead of `&String` as parameters.
- Return owned types (`String`, `Vec<T>`) when the caller needs ownership.
- Use `impl Trait` for return types when the concrete type is an
  implementation detail.
- Use associated functions (`Type::new()`) for constructors.

## Types and Traits

- Use enums for types with distinct variants, especially with pattern
  matching.
- Derive common traits (`Debug`, `Clone`, `PartialEq`) when appropriate.
- Implement traits explicitly for custom behavior.
- Use newtype pattern (`struct UserId(u64)`) for type safety.
- Keep trait definitions focused; prefer many small traits over large ones.
- Use trait bounds to constrain generic types effectively.
- Use associated types in traits when the type is determined by the
  implementation.

## Pattern Matching

- Use pattern matching extensively for control flow and destructuring.
- Make matches exhaustive; avoid catch-all patterns unless necessary.
- Use `if let` and `while let` for single-pattern scenarios.
- Use guards in match arms for additional conditions.
- Destructure structs and tuples in patterns for clarity.
- Use `@` bindings to bind and match simultaneously.

## Collections and Iterators

- Use iterators extensively for collection operations. They're zero-cost
  abstractions.
- Chain iterator methods for functional-style transformations.
- Use `collect()` to materialize iterators into collections when needed.
- Prefer iterators over index-based loops for clarity and safety.
- Use `Vec<T>` for growable arrays, `&[T]` for slices, arrays for
  fixed-size data.
- Use `HashMap` for key-value lookups, `HashSet` for unique collections.
- Use `BTreeMap`/`BTreeSet` when you need sorted collections.

## Concurrency and Parallelism

- Use threads with `std::thread` for concurrent operations.
- Use channels (`mpsc`) for message passing between threads.
- Share data across threads with `Arc<Mutex<T>>` or `Arc<RwLock<T>>`.
- Use `async`/`await` with Tokio or async-std for asynchronous I/O.
- Use `Send` and `Sync` traits to ensure thread safety at compile time.
- Avoid `unsafe` in concurrent code unless absolutely necessary and
  thoroughly reviewed.
- Use atomic types (`AtomicBool`, `AtomicUsize`) for lock-free
  synchronization when appropriate.

## Lifetimes

- Let the compiler infer lifetimes when possible; add annotations only
  when required.
- Use explicit lifetime annotations to document relationships between
  references.
- Keep lifetime complexity minimal; refactor if lifetimes become unwieldy.
- Use lifetime elision rules to reduce annotations.
- Understand the `'static` lifetime for data that lives for the entire
  program.
- Use lifetime bounds in generic types when necessary (`T: 'a`).

## Testing and Quality Gates

- Write unit tests in the same file using `#[cfg(test)]` modules.
- Write integration tests in the `tests/` directory.
- Use `#[test]` for test functions and `#[should_panic]` for panic tests.
- Use `assert!`, `assert_eq!`, and `assert_ne!` for test assertions.
- Write documentation tests in doc comments; they're compiled and run.
- Use `cargo test` to run all tests; use `cargo test --release` for
  performance tests.
- Aim for high coverage on critical logic; use `tarpaulin` or `grcov`
  for coverage reports.

## Dependency Management

- Use `Cargo.toml` for dependency management with semantic versioning.
- Run `cargo update` regularly to update within semver constraints.
- Run `cargo audit` to check for security vulnerabilities.
- Minimize dependencies; prefer the standard library when possible.
- Use `cargo tree` to inspect dependency graphs and avoid duplication.
- Use workspace for multi-crate projects to share dependencies.
- Pin versions in `Cargo.lock` for reproducible builds.

## Security Considerations

- Validate and sanitize all external inputs (user input, file data, network).
- Use parameterized queries or ORMs (diesel, sqlx) for database access.
- Use the `secrecy` crate to protect sensitive data in memory.
- Audit unsafe code blocks thoroughly; document safety invariants.
- Use `#![forbid(unsafe_code)]` to prevent unsafe in safe contexts.
- Keep dependencies updated to patch security vulnerabilities.
- Use constant-time comparison for cryptographic operations.
- Use established cryptography libraries (ring, rustls) rather than custom
  implementations.

## Performance Guidance

- Profile with `perf`, `cargo flamegraph`, or `criterion` before optimizing.
- Use `cargo build --release` for production builds with optimizations.
- Use `#[inline]` sparingly for hot functions after measuring.
- Minimize allocations; use stack allocation when possible.
- Use `Vec::with_capacity()` when the final size is known.
- Use `String::with_capacity()` for efficient string building.
- Use zero-copy operations with slices and references when possible.
- Consider using `SmallVec` or `ArrayVec` for small, stack-allocated
  collections.

## Unsafe Code

- Avoid `unsafe` unless absolutely necessary for performance or FFI.
- Document safety invariants thoroughly in comments.
- Keep unsafe blocks as small as possible.
- Ensure memory safety guarantees are maintained in unsafe code.
- Use safe abstractions to encapsulate unsafe operations.
- Review unsafe code carefully in code reviews.
- Consider using `-Zsanitizer` in nightly for detecting undefined behavior.

## Async/Await (when applicable)

- Use async/await for I/O-bound operations with runtimes like Tokio.
- Understand the difference between `async fn` and blocking functions.
- Use `.await` to wait for futures to complete.
- Use `tokio::spawn` for spawning concurrent tasks.
- Use `tokio::select!` for racing futures or handling multiple events.
- Handle cancellation and timeouts with `tokio::time::timeout`.
- Avoid blocking calls in async contexts; use async equivalents.

## Macros

- Use macros sparingly; prefer functions when possible.
- Use declarative macros (`macro_rules!`) for simple patterns.
- Use procedural macros for complex code generation (derives, attributes).
- Document macro behavior and expected inputs clearly.
- Test macros with various inputs to ensure correct expansion.

## Documentation

- Write documentation comments with `///` for public APIs.
- Include examples in doc comments; they're tested automatically.
- Document panics, errors, and safety requirements in doc comments.
- Use `//!` for module-level documentation.
- Generate documentation with `cargo doc --open` to review rendered output.
- Use `#![warn(missing_docs)]` to enforce documentation coverage.

## Project Organization

- Use modules to organize code logically within files or directories.
- Use `pub` to expose items; keep implementation details private.
- Use `mod.rs` or the new `module_name.rs` style for module organization.
- Group related functionality in modules with clear boundaries.
- Use re-exports to provide a clean public API.
