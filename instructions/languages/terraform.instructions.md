---
description: "Terraform implementation guardrails for infrastructure-as-code best practices."
applyTo: "**/*.tf"
---

## Guiding Principles

- Treat infrastructure as immutable. Prefer replacing resources over in-place
  modifications when the change is significant.
- Keep modules focused on a single responsibility. A module should manage one
  logical unit of infrastructure (e.g., a VPC, a database, an application stack).
- Use explicit resource dependencies rather than relying on implicit ordering.
  Document non-obvious dependencies with comments.

## File Organization

- Use consistent file naming: `main.tf` for resources, `variables.tf` for inputs,
  `outputs.tf` for outputs, `providers.tf` for provider configuration, and
  `versions.tf` for version constraints.
- Group related resources in the same file when they share lifecycle concerns.
- Keep `terraform.tfvars` out of version control; use environment-specific
  `.tfvars` files or workspace variables.

## Style and Formatting

- Run `terraform fmt` before committing changes to ensure consistent formatting.
- Use snake_case for resource names, variable names, and output names.
- Prefix resource names with a project or environment identifier to avoid
  naming collisions across workspaces.
- Keep variable descriptions concise but informative. Include type constraints
  and validation rules where applicable.

## Variables and Outputs

- Define sensible defaults for optional variables. Mark required variables with
  `nullable = false` or validation blocks.
- Use `sensitive = true` for variables and outputs containing secrets or PII.
- Provide descriptions for all variables and outputs to aid discoverability.
- Use variable validation blocks to enforce constraints at plan time rather
  than waiting for provider errors.

## State Management

- Use remote state backends (S3, Azure Blob, GCS, Terraform Cloud) for team
  environments. Never store state locally in shared projects.
- Enable state locking to prevent concurrent modifications.
- Configure state encryption at rest and audit access to state files.
- Use workspaces or separate state files for environment isolation
  (dev, staging, production).

## Module Development

- Version modules explicitly using Git tags or Terraform Registry versions.
- Document module usage with a README including required inputs, outputs,
  and example configurations.
- Use `for_each` and `count` judiciously; prefer `for_each` with maps for
  clearer resource addressing.
- Expose only necessary outputs; avoid leaking internal implementation details.

## Security Considerations

- Never hardcode secrets in Terraform files. Use secret management tools
  (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) and reference
  them via data sources.
- Review IAM policies and security group rules for least-privilege compliance.
- Enable logging and monitoring on infrastructure resources where applicable.
- Scan Terraform code with security tools (tfsec, Checkov, Terrascan) and
  address findings before deployment.

## Testing and Validation

- Run `terraform validate` to catch syntax and configuration errors early.
- Generate and review `terraform plan` output before any apply operation.
- Use `terraform plan -detailed-exitcode` in CI pipelines to detect drift.
- Consider infrastructure testing frameworks (Terratest, Kitchen-Terraform)
  for complex modules.

## Deployment Practices

- Use CI/CD pipelines to automate plan and apply workflows with approval gates.
- Tag resources consistently for cost allocation, ownership, and compliance.
- Document rollback procedures for critical infrastructure changes.
- Maintain a change log for significant infrastructure modifications.
