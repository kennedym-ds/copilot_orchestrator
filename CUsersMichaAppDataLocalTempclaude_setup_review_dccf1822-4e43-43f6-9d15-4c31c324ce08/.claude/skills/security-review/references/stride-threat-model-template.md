# STRIDE Threat Model Template

Use this template when performing threat analysis on new features or changes.

## Feature Under Review

- **Name**: {feature name}
- **Description**: {brief description}
- **Data Flow**: {what data enters, is processed, and exits}
- **Trust Boundaries**: {where trust levels change}

## Threat Analysis

### Spoofing (Identity)

> Can an attacker pretend to be someone else?

| Threat | Likelihood | Impact | Mitigation |
|--------|------------|--------|------------|
| {threat description} | Low/Med/High | Low/Med/High | {mitigation} |

**Common checks:**
- Authentication required for all sensitive operations
- Session tokens are cryptographically random
- API keys validated on every request

### Tampering (Data Integrity)

> Can an attacker modify data they shouldn't?

| Threat | Likelihood | Impact | Mitigation |
|--------|------------|--------|------------|
| {threat description} | Low/Med/High | Low/Med/High | {mitigation} |

**Common checks:**
- Input validation on all user-supplied data
- Database constraints enforce integrity
- File uploads validated for type and size

### Repudiation (Auditability)

> Can an attacker deny performing an action?

| Threat | Likelihood | Impact | Mitigation |
|--------|------------|--------|------------|
| {threat description} | Low/Med/High | Low/Med/High | {mitigation} |

**Common checks:**
- Audit logging for sensitive operations
- Logs are tamper-resistant (append-only, signed)
- User actions traceable to authenticated identity

### Information Disclosure (Confidentiality)

> Can an attacker access data they shouldn't see?

| Threat | Likelihood | Impact | Mitigation |
|--------|------------|--------|------------|
| {threat description} | Low/Med/High | Low/Med/High | {mitigation} |

**Common checks:**
- No secrets in source code, logs, or error messages
- PII masked in non-production environments
- Encryption at rest and in transit

### Denial of Service (Availability)

> Can an attacker make the system unavailable?

| Threat | Likelihood | Impact | Mitigation |
|--------|------------|--------|------------|
| {threat description} | Low/Med/High | Low/Med/High | {mitigation} |

**Common checks:**
- Rate limiting on public endpoints
- Timeouts on all external calls
- Resource limits (memory, CPU, connections)

### Elevation of Privilege (Authorization)

> Can an attacker gain higher access than intended?

| Threat | Likelihood | Impact | Mitigation |
|--------|------------|--------|------------|
| {threat description} | Low/Med/High | Low/Med/High | {mitigation} |

**Common checks:**
- Least-privilege access enforced
- Role checks on every protected operation
- No admin functions accessible without explicit role

## Summary

| Category | Threats Found | Mitigated | Residual Risk |
|----------|---------------|-----------|---------------|
| Spoofing | | | |
| Tampering | | | |
| Repudiation | | | |
| Info Disclosure | | | |
| DoS | | | |
| Elevation | | | |

**Overall Risk Level**: Low / Medium / High / Critical
**Reviewer**: {agent or human name}
**Date**: {ISO 8601}
