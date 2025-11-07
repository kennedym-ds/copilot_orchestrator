---
description: "Minimum security posture for Copilot-driven tasks."
applyTo: "**/*.{md,ps1,psm1,psd1,yml,yaml,json}"
---

# Security Baseline

- Assume zero trust: validate inputs, sanitize outputs, and avoid executing unverified code or binaries.
- When touching secrets, credentials, or tokens, use secure storage mechanisms and never print the raw values.
- Prefer least-privilege access; highlight when proposed solutions require new permissions or network exposure.
- Always note threat surfaces such as SSRF, injection, and privilege escalation. Recommend mitigations or additional reviews.
- Require dependency risk assessment (licenses, vulnerabilities) when introducing new packages.
- Document audit trails: reference tickets, incident IDs, or approvals relevant to the change.
