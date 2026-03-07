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
- Ensure all sensitive operations are tracked with ticket IDs or approval references.
- For features touching personal data, require a privacy impact assessment before implementation.
- Document logging, monitoring, and rollback plans in phase summaries.
- Escalate to the security team if proposed changes modify authentication, authorization, or data retention flows.
- When unsure about compliance implications, pause and request human guidance before proceeding.

## Escalation Checklist

When any of these conditions are met, **pause and escalate** to the security agent or human reviewer:

1. Changes modify authentication, authorization, or session management
2. New external dependencies are introduced (check licenses and CVEs)
3. Personal data (PII) is processed, stored, or transmitted
4. API keys, tokens, or credentials are referenced in code
5. Network exposure changes (new ports, endpoints, or CORS rules)
6. Data retention or deletion logic is modified

## Threat Categories (STRIDE Reference)

| Category | Agent Check |
|----------|-------------|
| **S**poofing | Verify identity validation on all auth flows |
| **T**ampering | Ensure input validation and integrity checks |
| **R**epudiation | Confirm audit logging for sensitive operations |
| **I**nformation Disclosure | Check for PII leaks, verbose errors, debug output |
| **D**enial of Service | Review resource limits, rate limiting, timeouts |
| **E**levation of Privilege | Validate least-privilege access controls |

## Audit Trail Requirements

- Every security-relevant change must reference a ticket ID or approval
- Log format: `[ISO-8601] [agent-name] [action] [resource] [justification]`
- Persist security findings to `artifacts/security/` with date-stamped filenames

## Examples

**Good** — uses environment variables for secrets:
```python
import os
api_key = os.environ.get("API_KEY")
if not api_key:
    raise ValueError("API_KEY environment variable is required")
```

**Bad** — hardcodes secrets:
```python
api_key = "sk-abc123-real-secret-key"
# Never commit secrets — use env vars or a secret manager
```
