---
description: "C++ implementation guardrails for modern, safe, and efficient development."
applyTo: "**/*.cpp,**/*.hpp,**/*.cc,**/*.h,**/*.cxx"
---

## Guiding Principles

- Write modern C++ (C++17 or later) using RAII, smart pointers, and the
  standard library.
- Embrace zero-overhead abstractions. Use high-level constructs without
  runtime cost.
- Make resource management automatic with RAII and smart pointers.
- Follow the C++ Core Guidelines for best practices and safety.
- Optimize for correctness first, then readability, then performance.

## Style and Formatting

- Use clang-format or similar tool to maintain consistent formatting.
- Use consistent naming: `CamelCase` for types, `snake_case` for functions
  and variables.
- Use `k` prefix or `ALL_CAPS` for constants based on project convention.
- Use 2 or 4-space indentation consistently.
- Place opening braces on the same line or new line consistently across
  the project.
- Keep line length under 100-120 characters.
- Use consistent include guard or `#pragma once` for header files.

## Modern C++ Features (C++11 and later)

- Use `auto` for type deduction when the type is obvious or verbose.
- Use range-based for loops instead of iterator loops: `for (auto& item : container)`.
- Use `nullptr` instead of `NULL` or `0` for null pointers.
- Use `constexpr` for compile-time constants and functions.
- Use `override` and `final` for virtual function annotations.
- Use `enum class` instead of plain enums for type safety.
- Use `using` instead of `typedef` for type aliases.
- Use structured bindings (C++17) for tuple decomposition: `auto [x, y] = point;`.
- Use `std::optional` (C++17) for optional values instead of pointers or
  sentinel values.
- Use `std::variant` (C++17) for type-safe unions.
- Use `std::string_view` (C++17) for non-owning string references.

## Memory Management

- Use RAII (Resource Acquisition Is Initialization) for all resource
  management.
- Prefer stack allocation over heap allocation when possible.
- Use smart pointers instead of raw pointers for ownership:
  - `std::unique_ptr` for exclusive ownership
  - `std::shared_ptr` for shared ownership
  - `std::weak_ptr` to break reference cycles
- Use raw pointers only for non-owning references (consider references
  instead).
- Never use `new` and `delete` directly; use `std::make_unique` and
  `std::make_shared`.
- Avoid manual memory management; let destructors handle cleanup.

## Functions and Parameters

- Keep functions small and focused. Extract helpers when functions exceed
  40-50 lines.
- Pass small types by value, large types by `const&` for reading, by `&`
  for modification.
- Use `std::move` to transfer ownership and enable move semantics.
- Use forwarding references (`T&&`) with `std::forward` for perfect
  forwarding.
- Return values directly; rely on return value optimization (RVO) and
  move semantics.
- Use trailing return types when needed: `auto function() -> ReturnType`.
- Mark functions `const`, `noexcept`, or `constexpr` when appropriate.

## Classes and Objects

- Use the Rule of Zero: rely on compiler-generated special members when
  possible.
- If you need a custom destructor, copy constructor, or copy assignment,
  you likely need all three (Rule of Three).
- For move semantics, implement move constructor and move assignment (Rule
  of Five).
- Use `= default` and `= delete` to explicitly control special member
  functions.
- Use initialization lists in constructors for efficiency.
- Prefer in-class member initialization for default values.
- Use `explicit` for single-argument constructors to prevent implicit
  conversions.
- Make member functions `const` when they don't modify the object.

## Error Handling

- Use exceptions for error handling in most cases; they separate error
  handling from normal flow.
- Throw by value, catch by `const` reference: `catch (const std::exception& e)`.
- Create custom exception classes deriving from `std::exception`.
- Use `noexcept` to declare functions that don't throw exceptions.
- Use `std::optional` or `std::expected` (C++23) for expected failures.
- Ensure exception safety: basic, strong, or no-throw guarantees.
- Use RAII to maintain invariants in the presence of exceptions.
- Document which exceptions functions may throw.

## Templates and Generic Programming

- Use templates for type-safe generic code.
- Constrain templates with concepts (C++20) for clearer error messages:
  `template<std::integral T>`.
- Use SFINAE or `if constexpr` (C++17) for conditional compilation.
- Define templates in header files; use explicit instantiation sparingly.
- Keep template code readable; extract complex logic into helper functions.
- Use template specialization when appropriate.
- Prefer standard library algorithms and containers over custom implementations.

## Standard Library

- Use standard containers: `std::vector`, `std::array`, `std::map`,
  `std::unordered_map`, `std::set`.
- Prefer `std::vector` as the default container; use others when specific
  properties are needed.
- Use algorithms from `<algorithm>`: `std::sort`, `std::find`,
  `std::transform`, etc.
- Use `std::string` for strings; avoid C-style strings and manual memory
  management.
- Use `std::filesystem` (C++17) for file system operations.
- Use `std::thread`, `std::mutex`, and `std::condition_variable` for
  threading.
- Use `std::chrono` for time operations.

## Concurrency and Threading

- Use `std::thread` for thread management.
- Protect shared data with `std::mutex` or `std::shared_mutex`.
- Use `std::lock_guard` or `std::unique_lock` for automatic lock management.
- Use `std::atomic` for lock-free operations on simple types.
- Use `std::future` and `std::promise` for asynchronous results.
- Avoid data races; use thread sanitizers to detect them.
- Consider `std::jthread` (C++20) for automatic joining.
- Use thread pools for managing multiple threads efficiently.

## Testing and Quality Gates

- Write unit tests using Google Test, Catch2, or similar frameworks.
- Use test-driven development for complex logic.
- Test edge cases, boundary conditions, and error paths.
- Use mocking frameworks when appropriate.
- Run tests with sanitizers: AddressSanitizer, UndefinedBehaviorSanitizer,
  ThreadSanitizer.
- Target high coverage for critical code paths.
- Separate unit tests from integration tests.

## Build Systems and Dependencies

- Use CMake, Bazel, or Meson for build configuration.
- Use package managers like Conan or vcpkg for dependency management.
- Specify minimum C++ standard in build configuration (C++17, C++20, C++23).
- Enable warnings and treat warnings as errors: `-Wall -Wextra -Werror` or
  equivalent.
- Enable compiler optimizations for release builds: `-O2` or `-O3`.
- Use link-time optimization (LTO) for production builds when appropriate.

## Security Considerations

- Validate all inputs, especially from external sources.
- Use bounds-checked containers and algorithms to prevent buffer overflows.
- Avoid pointer arithmetic and raw arrays; use `std::vector` or `std::array`.
- Use static analysis tools (clang-tidy, cppcheck) to detect vulnerabilities.
- Use AddressSanitizer and UndefinedBehaviorSanitizer during development.
- Avoid deprecated or unsafe functions: `strcpy`, `sprintf`, `gets`.
- Use `std::string` and standard containers to manage memory safely.
- Keep dependencies updated to patch security vulnerabilities.

## Performance Guidance

- Profile with perf, Valgrind, or vendor-specific tools before optimizing.
- Use the right data structure for access patterns and performance needs.
- Minimize copies; use move semantics and pass by reference.
- Reserve capacity for containers when the size is known: `vector.reserve(n)`.
- Use `constexpr` for compile-time computation when possible.
- Consider cache locality; structure data for sequential access.
- Use `inline` judiciously for small, frequently called functions.
- Enable compiler optimizations and link-time optimization for production.

## Code Organization

- Separate interface (header) from implementation (source file).
- Use include guards or `#pragma once` to prevent multiple inclusion.
- Forward declare types in headers when possible to reduce dependencies.
- Organize includes: standard library, third-party, local headers.
- Use namespaces to prevent naming conflicts.
- Keep header files minimal; include only what's necessary.
- Use precompiled headers for frequently included headers.

## Documentation

- Document public APIs with clear comments describing purpose, parameters,
  and return values.
- Use Doxygen or similar tools for generating API documentation.
- Document complex algorithms and non-obvious code.
- Keep comments up-to-date with code changes.
- Prefer self-documenting code with clear names over excessive comments.

## Modern Best Practices

- Follow the C++ Core Guidelines (https://isocpp.github.io/CppCoreGuidelines/).
- Use static analyzers and linters to enforce best practices.
- Enable and fix all compiler warnings.
- Use sanitizers during development and testing.
- Keep up with modern C++ standards (C++17, C++20, C++23).
- Prefer standard library features over third-party or custom solutions.
