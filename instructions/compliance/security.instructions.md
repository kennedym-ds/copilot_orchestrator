---
description: "Supplemental security and compliance requirements."
applyTo: "**/*.{md,ps1,psm1,psd1,yml,yaml,json}"
---

# Compliance Overlay

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

**Good** — escalates when touching auth:
```
This change modifies the OAuth2 token refresh flow. Pausing for security review
before proceeding. Escalating to security agent.
```

**Bad** — proceeds without review:
```
Updated the auth token handling. Committed and pushed.
```
