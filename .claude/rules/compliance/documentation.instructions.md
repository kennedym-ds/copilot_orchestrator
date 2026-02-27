---
description: "Documentation quality and compliance overlay for onboarding and knowledge base assets."
applyTo: "docs/**/*.md"
---

# Documentation Compliance Rules

- Include YAML front matter with `title`, `version`, `lastUpdated`, and `status` fields to support auditing.
- Cross-link references to templates, scripts, and instructions so readers can verify guidance quickly.
- Note when AI assistance contributed to content and capture review owners for future updates.
- When documenting procedures that interact with production systems, include escalation contacts and rollback guidance.
- Flag any prerequisites involving credentials or elevated access and reference the security baseline for handling secrets.
