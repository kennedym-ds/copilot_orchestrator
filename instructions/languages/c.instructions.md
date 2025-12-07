---
description: "C implementation guardrails for portable and efficient systems programming."
applyTo: "**/*.c,**/*.h"
---

## Guiding Principles

- Write clear, portable C code that works across platforms and compilers.
- Follow the principle of least surprise. Code should behave predictably.
- Manage memory carefully and explicitly. Prevent leaks and corruption.
- Keep functions small and focused on a single responsibility.
- Write defensive code that checks for errors and invalid inputs.

## Style and Formatting

- Follow a consistent style guide (K&R, Linux kernel style, or project-specific).
- Use 2, 4, or 8-space indentation consistently across the project.
- Use consistent brace placement (K&R style or Allman style).
- Use `snake_case` for functions and variables, `SCREAMING_SNAKE_CASE` for
  macros and constants.
- Use `PascalCase` or `snake_case` for typedef'd types based on project
  convention.
- Keep line length under 80-100 characters for readability.
- Use clang-format or indent for automatic formatting.

## Language Standard

- Target C99 or C11 as a minimum; use C17 or C23 when available.
- Use standard library functions from `<stdlib.h>`, `<string.h>`, `<stdio.h>`.
- Avoid compiler-specific extensions unless necessary and properly guarded.
- Use standard types from `<stdint.h>` for precise integer sizes: `int32_t`,
  `uint64_t`.
- Use `<stdbool.h>` for boolean types: `bool`, `true`, `false` (C99+).
- Use `<stddef.h>` for `size_t`, `ptrdiff_t`, and `NULL`.

## Memory Management

- Always initialize pointers to `NULL` or a valid address.
- Check return values from memory allocation functions (`malloc`, `calloc`,
  `realloc`).
- Free all dynamically allocated memory; every `malloc` needs a corresponding
  `free`.
- Set pointers to `NULL` after freeing to prevent use-after-free bugs.
- Use `calloc` when you need zero-initialized memory.
- Avoid memory leaks by freeing memory on all code paths, including error
  paths.
- Use tools like Valgrind, AddressSanitizer to detect memory errors.
- Consider using arena allocators or memory pools for performance-critical
  code.

## Functions and Parameters

- Keep functions small and focused, ideally under 50-100 lines.
- Use descriptive function names that express intent and action.
- Limit function parameters to 5-7; use structs for complex configurations.
- Pass large structures by pointer, small types by value.
- Use `const` for pointer parameters that won't be modified: `const char*`.
- Return error codes or use output parameters for error reporting.
- Document preconditions, postconditions, and side effects.
- Use static functions for file-local helpers to limit scope.

## Error Handling

- Always check return values from functions that can fail.
- Return error codes (0 for success, negative or positive for errors) or
  use `errno`.
- Use `perror` or `strerror` to get human-readable error messages from `errno`.
- Clean up resources (memory, file handles) on all error paths.
- Use `goto` for cleanup code in error handling (controversial but common):
  ```c
  if (error) {
      goto cleanup;
  }
  cleanup:
      free(resource);
      return error_code;
  ```
- Define error codes as enums or macros for clarity.
- Document which error codes functions return.

## Pointers and Arrays

- Always check for NULL before dereferencing pointers.
- Use array indexing carefully; prevent buffer overflows.
- Pass array size explicitly to functions; don't rely on sizeof in functions.
- Use pointer arithmetic carefully and only when necessary.
- Prefer array notation over pointer arithmetic for readability when possible.
- Use `const` to document that pointers won't modify the pointed-to data.
- Understand pointer aliasing and use `restrict` when appropriate (C99+).

## Strings

- Always null-terminate strings. C strings are null-terminated by convention.
- Use `strncpy`, `strncat`, `snprintf` instead of unsafe `strcpy`, `strcat`,
  `sprintf`.
- Check buffer sizes before copying or concatenating strings.
- Consider using safer string libraries like `strlcpy` (BSD) or custom
  wrappers.
- Be aware of the difference between character arrays and string literals.
- Use `strlen` carefully; it scans until null terminator.
- Allocate strings with `strlen(s) + 1` to account for null terminator.

## Structures and Types

- Use `typedef` for struct definitions for cleaner syntax:
  ```c
  typedef struct {
      int x;
      int y;
  } Point;
  ```
- Group related data in structures for cohesion.
- Use bit fields for flags and packed data structures when appropriate.
- Use `union` for type punning or space optimization, but document carefully.
- Use `enum` for related constants and state machines.
- Consider struct padding and alignment for performance and memory efficiency.
- Use opaque pointers (forward declarations) to hide implementation details.

## Preprocessor

- Use `#define` for constants or include guards, not complex macros when
  possible.
- Prefer `const` variables over `#define` for type-checked constants.
- Use include guards or `#pragma once` (non-standard but widely supported)
  in headers:
  ```c
  #ifndef HEADER_H
  #define HEADER_H
  /* content */
  #endif
  ```
- Use macros carefully; they don't respect scope or type safety.
- Parenthesize macro arguments and the entire expression to prevent operator
  precedence bugs.
- Use `do { ... } while(0)` for multi-statement macros.
- Document macro behavior and limitations clearly.

## File Organization

- Separate interface (header `.h`) from implementation (source `.c`).
- Include only necessary headers; forward declare when possible.
- Organize includes: standard library first, then third-party, then local.
- Use include guards in all header files.
- Declare functions in headers, define them in source files.
- Use `static` for file-local functions and variables.
- Keep related functionality in the same file.

## Testing and Quality Gates

- Write unit tests using CUnit, Check, Unity, or similar frameworks.
- Test edge cases, boundary conditions, and error paths thoroughly.
- Use assertions (`assert.h`) to catch programming errors during development.
- Disable assertions in production builds with `NDEBUG`.
- Run tests with Valgrind to detect memory errors and leaks.
- Use AddressSanitizer and UndefinedBehaviorSanitizer during development.
- Test on multiple platforms if portability is required.

## Build Systems

- Use Make, CMake, or other build systems for consistent builds.
- Enable compiler warnings and treat them as errors: `-Wall -Wextra -Werror`
  (GCC/Clang).
- Use optimization flags for release builds: `-O2` or `-O3`.
- Include debug symbols for development builds: `-g`.
- Use `pkg-config` for library dependencies when available.
- Document build dependencies and instructions in README.

## Security Considerations

- Validate all inputs, especially from untrusted sources.
- Use bounds-checked functions to prevent buffer overflows.
- Avoid format string vulnerabilities; never use user input as format strings.
- Prevent integer overflows; check arithmetic operations on untrusted input.
- Use compiler protections: stack canaries, ASLR, NX bit.
- Initialize all variables before use to prevent information leaks.
- Clear sensitive data from memory after use (with `memset_s` or similar).
- Keep dependencies updated to patch security vulnerabilities.
- Use static analysis tools (clang-tidy, cppcheck, splint) to find
  vulnerabilities.

## Performance Guidance

- Profile with `perf`, `gprof`, or Valgrind's callgrind before optimizing.
- Use appropriate data structures for access patterns.
- Minimize memory allocations in hot paths.
- Use `inline` for small, frequently called functions (C99+).
- Consider cache locality; structure data for sequential access.
- Use `restrict` keyword to enable compiler optimizations (C99+).
- Enable compiler optimizations for production builds.
- Measure actual performance impact before and after optimizations.

## Portability

- Avoid assuming sizes of types; use `sizeof` operator.
- Use `<stdint.h>` for fixed-width integer types across platforms.
- Check endianness when reading/writing binary data across systems.
- Use standard library functions; avoid platform-specific APIs when possible.
- Test on target platforms; don't assume behavior.
- Document platform-specific code clearly and isolate it.
- Use feature detection macros for conditional compilation.

## Concurrency (POSIX threads)

- Use `pthread` for threading on POSIX systems, or C11 `<threads.h>`.
- Protect shared data with mutexes (`pthread_mutex_t`).
- Always initialize and destroy synchronization primitives.
- Avoid deadlocks; acquire locks in consistent order.
- Use condition variables for thread synchronization.
- Be aware of race conditions; use thread sanitizers to detect them.
- Document thread-safety requirements for functions.

## Documentation

- Document all public functions with comments describing purpose, parameters,
  and return values.
- Use Doxygen-style comments for API documentation when appropriate.
- Document assumptions, invariants, and preconditions.
- Keep comments up-to-date with code changes.
- Prefer self-documenting code with clear names over excessive comments.
- Document why, not what, when the code isn't obvious.

## Best Practices

- Check for NULL pointers before dereferencing.
- Initialize all variables before use.
- Free all allocated memory; prevent leaks.
- Use const wherever possible to document intent and enable optimizations.
- Avoid global variables; use them only when necessary and document their use.
- Write portable code unless platform-specific features are required.
- Use static analysis tools regularly to catch bugs early.
- Follow the project's coding standards consistently.
