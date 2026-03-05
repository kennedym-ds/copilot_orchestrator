---
description: "Python implementation guardrails aligned with the Zen of Python."
applyTo: "**/*.py"
---

## Guiding principles

- Honor the Zen of Python (PEP 20): prefer clarity, explicit behavior, and
  simplicity over cleverness. When trade-offs arise, choose the option that keeps
  the code obvious to future readers.
- Keep modules focused. A file should express a cohesive responsibility and
  expose a minimal public API.
- Optimize for maintainability first; profile before pursuing micro-optimizations
  that complicate the design.

## Style and formatting

- Follow PEP 8 as the baseline code style. Use automated formatters (Black or
  Ruff format) to keep formatting consistent and deterministic.
- Group imports by standard library, third-party, and local modules. Maintain
  alphabetical order within each block and avoid unused imports.
- Prefer f-strings for string interpolation. Use raw strings for regular
  expressions to improve readability.
- Keep functions and methods small and purposeful. If a function exceeds 30–40
  lines, consider extracting helpers.

## Typing and documentation

- Adopt type hints (PEP 484) throughout new or modified code. Treat `from
  __future__ import annotations` as the default for modules targeting Python 3.11
  or earlier to avoid runtime import cycles.
- Run a type checker (e.g., `mypy`, `pyright`) in strict or near-strict mode;
  resolve warnings rather than suppressing them.
- Write docstrings that follow PEP 257. For public APIs, prefer Google or
  NumPy-style docstrings that document parameters, return values, raised
  exceptions, and side effects.
- Use `dataclasses` (PEP 557) or `typing.NamedTuple` for simple data carriers.
  Reach for `pydantic` or similar validation libraries only when runtime
  validation is truly required.

## Testing and quality gates

- Practice test-driven or test-first development. Add or update tests alongside
  code changes using `pytest` (recommended) or the repository's prevailing test
  framework.
- Target at least 90% branch coverage for new modules. Use coverage reports to
  highlight untested branches before merging.
- Include property-based tests (`hypothesis`) when logic benefits from randomized
  input exploration.
- Keep fast unit tests in the main suite; reserve slow or integration tests for a
  separate marker so CI can orchestrate them independently.

## Dependency and packaging hygiene

- Use `pyproject.toml` (PEP 621) for new projects or packages. Prefer
  `poetry.lock`, `uv.lock`, or `requirements.txt` plus hashes for reproducible
  installs. Document the chosen workflow in `README.md`.
- Pin direct dependencies and monitor transitive dependencies with `pip-audit`
  or `python -m pip audit`. Address high-severity advisories before release.
- Avoid dynamic execution (e.g., `exec`, `eval`) and reflective imports unless a
  plugin system demands it. Document the threat model when such patterns are
  unavoidable.

## Runtime reliability

- Fail fast with informative exceptions. Log actionable context and re-raise
  custom exceptions when translating low-level errors to domain-specific ones.
- Use context managers (`with` statements) for resources that require cleanup.
  Prefer `pathlib.Path` for filesystem interactions and `subprocess.run`
  (with `check=True`) for shell commands.
- For concurrency, default to `asyncio` or thread pools for I/O-bound work and
  `multiprocessing` or job queues for CPU-bound tasks. Guard shared state with
  appropriate synchronization primitives.
- Surface metrics, tracing, or structured logs (JSON) when building long-running
  services to aid observability and incident response.

## Security considerations

- Treat user input as untrusted. Validate and sanitize before use, especially
  when constructing SQL queries, shell commands, or serialization payloads.
- Store secrets in managed secret stores; load them via environment variables or
  configuration files outside of version control. Never bake secrets into code.
- Enable `hashlib.pbkdf2_hmac` or `bcrypt` for password handling instead of
  custom cryptography. Verify third-party cryptographic libraries are actively
  maintained before adoption.
- Keep production dependencies up to date. Automate dependency scanning and
  patching to minimize exposure windows.

## Performance guidance

- Measure with `time.perf_counter`, `cProfile`, or `py-spy` before attempting to
  optimize. Document profiling results to justify changes.
- Use vectorized operations (NumPy, pandas) for data-heavy workloads. Avoid
  premature optimization when idiomatic Python is sufficient.
- Cache expensive pure functions with `functools.lru_cache` or memoization only
  when it materially improves runtime and memory usage remains acceptable.
