---
paths:
  - "**/*.ps1"
  - "**/*.psm1"
  - "**/*.psd1"
---

---
description: "PowerShell implementation guardrails for scripting and automation best practices."
applyTo: "**/*.ps1"
---

## Guiding Principles

- Write scripts that are idempotent and safe to re-run. Check current state
  before making changes and handle existing resources gracefully.
- Prefer cmdlets over aliases in scripts for clarity and cross-platform
  compatibility. Aliases are acceptable in interactive sessions only.
- Use approved verbs from `Get-Verb` for function names to maintain consistency
  with the PowerShell ecosystem.

## File Organization

- Use PascalCase for script and module file names (e.g., `Invoke-Deployment.ps1`,
  `MyModule.psm1`).
- Place related functions in a module (`.psm1`) with a manifest (`.psd1`).
- Keep script files focused on a single task or workflow.
- Use `#Requires` statements to declare dependencies on modules and versions.

## Style and Formatting

- Use PascalCase for function names, parameter names, and public variables.
- Use camelCase for local variables within function scope.
- Use 4-space indentation; avoid tabs for cross-editor consistency.
- Place opening braces on the same line as the statement (One True Brace style).
- Run PSScriptAnalyzer to catch style and best-practice violations.

## Functions and Parameters

- Include `[CmdletBinding()]` attribute for advanced function features.
- Document parameters with `[Parameter()]` attributes specifying mandatory
  status, position, pipeline input, and help messages.
- Use strong typing for parameters (`[string]`, `[int]`, `[switch]`).
- Validate inputs with `[ValidateNotNullOrEmpty()]`, `[ValidateSet()]`,
  `[ValidateRange()]`, and `[ValidateScript()]` attributes.
- Support `-WhatIf` and `-Confirm` for functions that make changes.

## Error Handling

- Use `try/catch/finally` blocks for structured error handling.
- Set `$ErrorActionPreference = 'Stop'` at script start for consistent
  error behavior in automation contexts.
- Use `Write-Error` for terminating errors and `Write-Warning` for
  non-critical issues.
- Log errors with sufficient context (timestamps, affected resources,
  suggested remediation).

## Output and Logging

- Use `Write-Verbose`, `Write-Debug`, and `Write-Information` for
  different verbosity levels; avoid `Write-Host` for automation scripts.
- Return structured objects rather than formatted strings for downstream
  processing.
- Use `Write-Progress` for long-running operations to provide user feedback.
- Consider structured logging (JSON format) for scripts that integrate
  with monitoring systems.

## Security Considerations

- Never hardcode credentials in scripts. Use `Get-Credential`, Azure Key Vault,
  or environment variables from secure sources.
- Validate and sanitize all external inputs, especially when constructing
  commands or paths dynamically.
- Use `SecureString` for sensitive data in memory when possible.
- Set execution policy appropriately and sign scripts for production use.
- Audit scripts with PSScriptAnalyzer security rules before deployment.

## Testing and Validation

- Write Pester tests for all functions with unit and integration coverage.
- Use `BeforeAll`, `BeforeEach`, `AfterAll`, `AfterEach` for test setup
  and cleanup.
- Mock external dependencies (`Mock`) to isolate unit tests.
- Aim for 80%+ code coverage on critical automation scripts.
- Include `-WhatIf` tests to verify non-destructive behavior.

## Module Development

- Create a module manifest (`.psd1`) with accurate metadata, version,
  and exported function list.
- Use `Export-ModuleMember` or manifest entries to control public API.
- Document public functions with comment-based help (`<#.SYNOPSIS`, etc.).
- Version modules semantically and maintain a changelog.
- Publish to private or public gallery with proper dependency declarations.

## Cross-Platform Considerations

- Test scripts on Windows PowerShell 5.1 and PowerShell 7+ if cross-platform
  support is required.
- Avoid Windows-specific features (registry, WMI) in cross-platform scripts
  or provide fallback implementations.
- Use `[Environment]::OSVersion` or `$IsWindows`/`$IsLinux`/`$IsMacOS` for
  platform-specific logic.
