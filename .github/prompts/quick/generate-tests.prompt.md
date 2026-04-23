---
name: generate-tests
description: "Generate unit and integration tests for specified code with edge cases and mocking."
argument-hint: "Specify the function, class, or module to generate tests for"
model: GPT-5 mini (copilot)
agent: agent
tools: [search, edit, execute]
---

## Purpose
Generate comprehensive tests for target code following TDD principles and language-specific testing frameworks.

## Instructions
- Read the target code, its public API, and any existing tests.
- Identify the appropriate test framework (Pester for PowerShell, pytest for Python, Jest/Vitest for JS/TS, etc.).
- Write tests covering:
  - **Happy path** — expected inputs produce expected outputs.
  - **Edge cases** — boundary values, empty inputs, nulls, large datasets.
  - **Error cases** — invalid inputs, exceptions, error responses.
  - **Integration points** — mock external dependencies, verify interactions.
- Follow the Arrange-Act-Assert pattern consistently.
- Run the tests to confirm they pass against the current implementation.
- Report coverage gaps if any critical paths remain untested.

## Output Format
Return:
1. **Test file(s) created** — paths and frameworks used.
2. **Test cases** — summary table of test name, category (happy/edge/error), and status.
3. **Coverage** — which functions/methods are now covered.
4. **Gaps** — any untested paths and why they were deferred.
