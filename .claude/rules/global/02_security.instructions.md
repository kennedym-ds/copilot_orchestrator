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
