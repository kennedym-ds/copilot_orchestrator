# Tooling Maintainer Guidance

Scripts in this directory provide validation, metadata normalization, and reporting for the Copilot Orchestrator. Maintain them with the following principles:

- PowerShell 5.1 compatibility is mandatory; avoid cmdlets or syntax requiring newer runtimes.
- Include `Set-StrictMode -Version 2.0` and prefer terminating errors (`$ErrorActionPreference = 'Stop'`).
- Accept a `-RepositoryRoot` or `-Path` parameter so scripts can run from CI and local terminals without relying on relative paths.
- Avoid third-party module dependencies; rely only on built-in cmdlets.
- Emit friendly console output plus non-zero exit codes when validation fails. Provide actionable remediation hints.
- When adding new scripts, document usage in `AGENTS.md` (root) and `docs/operations.md`, and wire them into CI if they gate quality.
- Update `docs/CHANGELOG.md` whenever script behavior changes and capture follow-up tasks in the operations backlog.
