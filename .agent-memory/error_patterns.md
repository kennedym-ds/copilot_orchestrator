<!-- Template: Error patterns and remediation guidance (durable). Edit via scripts/add-agent-decision.ps1 -->

# Error Patterns

Document recurring error patterns, typical root causes, and recommended remediation steps. Keep entries succinct and evidence-backed.

- Pattern: ExampleException on startup
  - Symptom: service fails with ExampleException when env var X missing
  - Root cause: missing config validation at bootstrap
  - Remediation: add validation in bootstrap and fallback default
  - Citations: scripts/init.ps1, docs/README.md
