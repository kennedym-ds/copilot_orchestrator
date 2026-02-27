# OWASP Top 10 (2025) Quick-Reference Checklist

Use this checklist when reviewing code for security vulnerabilities.

## A01: Broken Access Control

- [ ] Verify authorization on every endpoint/function, not just the UI
- [ ] Deny by default — require explicit grants
- [ ] Check for IDOR (Insecure Direct Object Reference) — user can't access other users' data
- [ ] Validate that CORS is restrictively configured
- [ ] Disable directory listing; verify no metadata files are exposed

## A02: Cryptographic Failures

- [ ] No hardcoded secrets, keys, or passwords
- [ ] Use strong algorithms (AES-256, SHA-256+, RSA-2048+)
- [ ] Encrypt data in transit (TLS 1.2+) and at rest
- [ ] Don't use deprecated algorithms (MD5, SHA-1, DES)
- [ ] Properly manage key rotation and storage

## A03: Injection

- [ ] Parameterize all queries (SQL, NoSQL, LDAP, OS commands)
- [ ] Validate and sanitize all user input
- [ ] Use allowlists over denylists for input validation
- [ ] Escape output based on context (HTML, JS, URL, CSS)
- [ ] Use ORM/query builders with parameterized queries

## A04: Insecure Design

- [ ] Threat model exists for the feature
- [ ] Business logic abuse scenarios considered
- [ ] Rate limiting on sensitive operations
- [ ] Fail securely — errors don't expose internals

## A05: Security Misconfiguration

- [ ] Remove default credentials and unnecessary features
- [ ] Error messages don't leak stack traces or internals
- [ ] Security headers set (CSP, X-Frame-Options, HSTS)
- [ ] Dependencies updated; no known vulnerable versions

## A06: Vulnerable and Outdated Components

- [ ] Run dependency audit (npm audit, pip-audit, safety check)
- [ ] No components with known CVEs
- [ ] Components from official sources only
- [ ] License compatibility verified

## A07: Identification and Authentication Failures

- [ ] Strong password policy enforced
- [ ] Multi-factor authentication available for sensitive ops
- [ ] Session tokens rotated after login
- [ ] Brute-force protection (lockout, CAPTCHA, rate limiting)

## A08: Software and Data Integrity Failures

- [ ] CI/CD pipeline secured against unauthorized modifications
- [ ] Dependencies verified with checksums or lock files
- [ ] Deserialization of untrusted data avoided or validated
- [ ] Code review required before merge

## A09: Security Logging and Monitoring Failures

- [ ] Authentication events logged (success and failure)
- [ ] Access control failures logged and alerted
- [ ] Logs don't contain sensitive data (passwords, tokens, PII)
- [ ] Log integrity protected against tampering

## A10: Server-Side Request Forgery (SSRF)

- [ ] Validate and sanitize all URLs before fetching
- [ ] Use allowlists for permitted domains/IPs
- [ ] Block requests to internal/private IP ranges
- [ ] Don't return raw responses from fetched URLs to users
