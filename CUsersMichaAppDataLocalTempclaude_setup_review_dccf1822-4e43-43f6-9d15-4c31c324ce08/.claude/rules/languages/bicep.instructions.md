---
description: "Azure Bicep implementation guardrails for infrastructure-as-code best practices."
applyTo: "**/*.bicep"
---

## Guiding Principles

- Embrace Bicep's declarative nature. Let the Azure Resource Manager handle
  dependency ordering and parallel deployment where possible.
- Keep modules focused on a single responsibility. A module should manage one
  logical unit of infrastructure (e.g., a virtual network, a storage account,
  an application service).
- Use explicit dependencies with `dependsOn` only when Azure cannot infer the
  relationship from resource references.

## File Organization

- Use consistent file naming: `main.bicep` for primary deployment, and
  descriptive names for modules (e.g., `network.bicep`, `storage.bicep`).
- Separate parameter files by environment (e.g., `main.dev.bicepparam`,
  `main.prod.bicepparam`).
- Organize shared modules in a central `modules/` directory with versioning.
- Keep `.bicepparam` files alongside the main template for discoverability.

## Style and Formatting

- Use camelCase for parameter names, variable names, and output names.
- Use PascalCase for user-defined types and decorators.
- Keep resource symbolic names descriptive but concise (e.g., `storageAccount`
  not `sa` or `myVeryLongStorageAccountName`).
- Run `az bicep format` or use the Bicep VS Code extension for consistent
  formatting.

## Parameters and Variables

- Add `@description()` decorators to all parameters for documentation.
- Use `@allowed()`, `@minLength()`, `@maxLength()`, `@minValue()`, `@maxValue()`
  decorators to validate inputs at deployment time.
- Mark sensitive parameters with `@secure()` decorator.
- Provide sensible defaults for optional parameters.
- Use variables to simplify complex expressions and improve readability.

## User-Defined Types

- Define custom types for complex parameter structures using the `type` keyword.
- Use discriminated unions for parameters that accept multiple shapes.
- Document custom types with inline comments explaining expected values.

## Module Development

- Design modules with clear input/output contracts documented in comments.
- Use `@export()` decorator for types that should be available to consumers.
- Version modules and document breaking changes in module READMEs.
- Avoid hardcoding resource API versions; centralize version management.
- Expose only necessary outputs; keep internal resources private.

## Scope and Targeting

- Explicitly set deployment scope (resourceGroup, subscription, managementGroup,
  tenant) using the `targetScope` declaration.
- Use scope functions (`resourceGroup()`, `subscription()`) to deploy resources
  across scopes when necessary.
- Document required permissions for each deployment scope.

## Security Considerations

- Never hardcode secrets in Bicep files. Reference Azure Key Vault secrets
  using the `getSecret()` function in parameter files.
- Review RBAC assignments, network rules, and encryption settings for
  least-privilege and defense-in-depth compliance.
- Enable diagnostic settings and logging on resources where applicable.
- Scan Bicep code with Azure Policy and PSRule for compliance validation.

## Testing and Validation

- Run `az bicep build` to compile Bicep to ARM JSON and catch errors early.
- Use `az deployment validate` to check deployment validity before execution.
- Generate and review `az deployment what-if` output before any deployment.
- Consider ARM-TTK or PSRule for additional template testing.

## Deployment Practices

- Use Azure DevOps or GitHub Actions to automate deployment workflows with
  approval gates and what-if checks.
- Tag resources consistently for cost allocation, ownership, and compliance.
- Deploy to non-production environments before production with identical
  parameter configurations where possible.
- Document rollback procedures and maintain deployment history for auditing.
