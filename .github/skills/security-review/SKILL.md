---
name: security-review
description: "Security analysis patterns for STRIDE threat modeling, compliance checks (SOC2, GDPR, HIPAA), vulnerability assessment, and secure coding. Use for security reviews at planning, implementation, and review phases."
user-invocable: true
argument-hint: "[file, PR, or path to review for vulnerabilities]"
---

# Security Review & Threat Modeling

Provides security analysis patterns for threat modeling, compliance checks, vulnerability assessment, and secure coding practices across the conductor workflow lifecycle.

## Description

This skill teaches security agents how to evaluate code changes, architecture decisions, and configurations for security posture, compliance impacts, and threat vectors. It covers threat modeling frameworks (STRIDE), vulnerability assessment patterns, compliance requirements (SOC2, GDPR, HIPAA), secure coding guidelines, and risk rating systems.

Security reviews occur at multiple points: planning phase (threat model), implementation phase (secure coding), review phase (vulnerability scan), and completion phase (compliance validation). This skill provides the patterns to identify, assess, and mitigate security risks systematically.

## When to Use

This skill is relevant when:
- Reviewing authentication/authorization implementations
- Evaluating data handling and storage patterns
- Assessing third-party dependencies and integrations
- Validating compliance with security standards (SOC2, GDPR, HIPAA)
- Conducting threat modeling for new features
- Reviewing API endpoint security
- Analyzing cryptographic implementations
- Evaluating access control mechanisms

### When NOT to Use

- Do not use for general code quality or style review — use the reviewer agent instead.
- Do not use for performance analysis — use the `performance-analysis` skill.
- Do not use for functional correctness testing — use the `tdd` skill.

## Entry Points

### Trigger Phrases
- "security review"
- "threat model"
- "compliance check"
- "vulnerability assessment"
- "secure this implementation"
- "check for security risks"
- "evaluate security posture"

### Context Patterns
- Authentication/authorization code changes
- Data encryption or storage modifications
- API endpoint additions or changes
- Third-party integration implementations
- Configuration changes (secrets, permissions)
- Deployment pipeline modifications
- User input handling code

## Core Knowledge

### STRIDE Threat Modeling

**Framework:** Identify threats across six categories

| Category | Threat | Example | Mitigation |
|----------|--------|---------|------------|
| **S**poofing | Identity forgery | Weak authentication | MFA, certificate pinning, token validation |
| **T**ampering | Data modification | Unvalidated input | Input validation, integrity checks, signing |
| **R**epudiation | Action denial | Missing audit logs | Comprehensive logging, immutable audit trail |
| **I**nformation Disclosure | Data leakage | Exposed secrets | Encryption at rest/transit, secrets management |
| **D**enial of Service | Availability attack | No rate limiting | Rate limiting, resource quotas, timeout enforcement |
| **E**levation of Privilege | Unauthorized access | Broken access control | Principle of least privilege, RBAC, permission checks |

**Threat Modeling Process:**
```markdown
1. Identify assets: What needs protection? (user data, API keys, PII, financial data)
2. Identify entry points: Where can attackers interact? (API endpoints, upload forms, webhooks)
3. Apply STRIDE: Check each category for potential threats
4. Rate risks: Likelihood Ã— Impact = Risk Score (1-5 scale)
5. Recommend mitigations: Prioritize by risk score
```

### Risk Rating System

**Severity Levels:**
- **CRITICAL:** Immediate exploitation possible, severe impact (data breach, RCE, auth bypass)
- **HIGH:** Exploitable with effort, significant impact (privilege escalation, sensitive data leak)
- **MEDIUM:** Requires specific conditions, moderate impact (CSRF, XSS, information disclosure)
- **LOW:** Difficult to exploit or minimal impact (verbose errors, missing security headers)
- **INFORMATIONAL:** Best practice violation, no immediate risk (outdated dependency, weak cipher)

**Risk Score Formula:**
```
Risk Score = Likelihood (1-5) Ã— Impact (1-5)

20-25: CRITICAL (immediate action required)
12-19: HIGH (fix before deployment)
6-11:  MEDIUM (fix in next sprint)
2-5:   LOW (fix when convenient)
1:     INFORMATIONAL (improve over time)
```

### Common Vulnerability Patterns

#### 1. Authentication/Authorization

**Vulnerabilities:**
- Weak password policies (no complexity, no MFA)
- Broken access control (IDOR, horizontal/vertical escalation)
- Session fixation or hijacking
- JWT vulnerabilities (weak signature, no expiry, algorithm confusion)
- OAuth misconfigurations (open redirect, token leakage)

**Secure Patterns:**
```javascript
// âŒ BAD: No authentication check
app.get('/api/user/:id', (req, res) => {
  const user = db.getUser(req.params.id);
  res.json(user);
});

// âœ… GOOD: Authentication + authorization
app.get('/api/user/:id', authenticate, (req, res) => {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const user = db.getUser(req.params.id);
  res.json(sanitize(user)); // Remove sensitive fields
});
```

#### 2. Input Validation

**Vulnerabilities:**
- SQL injection (unparameterized queries)
- Command injection (unvalidated shell execution)
- XSS (unescaped user input)
- Path traversal (unvalidated file paths)
- XXE (XML external entity attacks)

**Secure Patterns:**
```javascript
// âŒ BAD: SQL injection vulnerability
const query = `SELECT * FROM users WHERE email = '${req.body.email}'`;
db.query(query);

// âœ… GOOD: Parameterized query
const query = 'SELECT * FROM users WHERE email = ?';
db.query(query, [req.body.email]);

// âŒ BAD: Command injection
exec(`ping ${req.query.host}`);

// âœ… GOOD: Input validation + safe execution
if (!/^[\w.-]+$/.test(req.query.host)) {
  return res.status(400).json({ error: 'Invalid host' });
}
execFile('ping', ['-c', '4', req.query.host]);
```

#### 3. Data Protection

**Vulnerabilities:**
- Plaintext secrets in code/config
- Weak encryption (MD5, SHA1, ECB mode)
- Missing encryption in transit (HTTP instead of HTTPS)
- Insufficient key rotation
- Exposed PII in logs

**Secure Patterns:**
```javascript
// âŒ BAD: Plaintext secret
const apiKey = 'sk_live_abc123';

// âœ… GOOD: Environment variable or secrets manager
const apiKey = process.env.API_KEY;

// âŒ BAD: Weak hashing
const hash = crypto.createHash('md5').update(password).digest('hex');

// âœ… GOOD: Strong hashing with salt
const hash = await bcrypt.hash(password, 12);

// âŒ BAD: PII in logs
logger.info(`User login: ${user.email}, SSN: ${user.ssn}`);

// âœ… GOOD: Sanitized logging
logger.info(`User login: ${user.id}`, { email_hash: hash(user.email) });
```

### Compliance Requirements

#### SOC 2 Type II
- Access control: Role-based permissions, MFA for admin
- Audit logging: Immutable logs, 90-day retention minimum
- Data encryption: At rest (AES-256) and in transit (TLS 1.2+)
- Incident response: Detection, containment, recovery procedures
- Vendor management: Third-party security assessments

#### GDPR (EU Data Protection)
- Consent management: Explicit opt-in, granular controls
- Data minimization: Collect only necessary data
- Right to erasure: Hard delete within 30 days
- Data portability: Export in machine-readable format
- Breach notification: Within 72 hours of discovery

#### HIPAA (Healthcare)
- PHI protection: Encryption, access controls, BAA required
- Minimum necessary: Access limited by role
- Audit controls: Who accessed what PHI and when
- Transmission security: End-to-end encryption for PHI
- Breach notification: HHS notification for breaches >500 records

### Secure Coding Checklist

**Before Implementation:**
- [ ] Threat model completed (STRIDE analysis)
- [ ] Security requirements documented
- [ ] Third-party dependencies reviewed (known CVEs?)
- [ ] Data classification determined (public, internal, confidential, restricted)

**During Implementation:**
- [ ] Input validation on all external data
- [ ] Parameterized queries (no string concatenation)
- [ ] Principle of least privilege applied
- [ ] Secrets stored in environment variables or vault
- [ ] Error messages don't leak sensitive information
- [ ] Rate limiting on public endpoints
- [ ] HTTPS enforced (HSTS header)

**After Implementation:**
- [ ] Static analysis scan (Snyk, SonarQube, Bandit)
- [ ] Dependency vulnerability scan (npm audit, pip-audit)
- [ ] Manual code review with security focus
- [ ] Penetration testing for critical paths
- [ ] Security documentation updated

### Code Review Security Patterns

**Review Template:**
```markdown
## Security Review: [Feature Name]

### Threat Model
**Assets:** [What needs protection]
**Entry Points:** [Where attackers can interact]
**STRIDE Analysis:**
- Spoofing: [Assessment]
- Tampering: [Assessment]
- Repudiation: [Assessment]
- Information Disclosure: [Assessment]
- Denial of Service: [Assessment]
- Elevation of Privilege: [Assessment]

### Findings

#### CRITICAL: [Title]
- **Vulnerability:** [Description]
- **Impact:** [What can an attacker do]
- **Location:** [File:line]
- **Mitigation:** [Specific fix recommendation]
- **Risk Score:** [Likelihood Ã— Impact]

### Compliance Impact
- SOC 2: [Affects control X, requires audit log update]
- GDPR: [Processes PII, requires consent mechanism]
- HIPAA: [N/A - no PHI involved]

### Recommendations
1. [Priority 1 fix]
2. [Priority 2 improvement]

### Verdict
- [ ] APPROVED (no blockers)
- [ ] CHANGES_REQUIRED (N critical, M high findings)
- [ ] INSUFFICIENT_CONTEXT (need architecture diagram)
```

## Examples

### Example 1: OAuth2 Implementation Review

**Request:** "Review OAuth2 authentication implementation for security risks"

**Security Agent Response:**
```markdown
## Security Review: OAuth2 Authentication

### Threat Model
**Assets:** User credentials, access tokens, refresh tokens, user profile data
**Entry Points:** /auth/login, /auth/callback, /auth/token, /api/* (protected endpoints)

**STRIDE Analysis:**
- **Spoofing:** MITIGATED - Auth0 provider handles identity verification with MFA
- **Tampering:** MITIGATED - JWT signature verification on all requests
- **Repudiation:** PARTIAL - Audit logs for token issuance, missing for failed auth attempts
- **Information Disclosure:** RISK - Access tokens logged in debug mode (see finding #1)
- **Denial of Service:** MITIGATED - Rate limiting on /auth/token (10 req/min)
- **Elevation of Privilege:** RISK - Missing scope validation on admin endpoints (see finding #2)

### Findings

#### HIGH: Access Tokens in Debug Logs
- **Vulnerability:** Access tokens logged at DEBUG level in auth.js:45
- **Impact:** Token leakage via log aggregation, attacker can impersonate users
- **Location:** src/auth/auth.js:45
- **Mitigation:** Remove token logging, log only token ID or hash
- **Risk Score:** 4 (likelihood) Ã— 4 (impact) = 16 (HIGH)

```javascript
// âŒ CURRENT (VULNERABLE)
logger.debug(`Token issued: ${accessToken}`);

// âœ… RECOMMENDED
logger.debug(`Token issued: ${tokenId}`, { user_id: userId });
```

#### HIGH: Missing Scope Validation
- **Vulnerability:** Admin endpoints check authentication but not authorization scopes
- **Impact:** Authenticated users can access admin functions (user management, config changes)
- **Location:** src/api/admin.js:12-34
- **Mitigation:** Validate 'admin' scope in JWT claims before processing
- **Risk Score:** 3 (likelihood) Ã— 5 (impact) = 15 (HIGH)

```javascript
// âŒ CURRENT (VULNERABLE)
router.post('/admin/users', authenticate, createUser);

// âœ… RECOMMENDED
router.post('/admin/users', authenticate, requireScope('admin'), createUser);

function requireScope(scope) {
  return (req, res, next) => {
    if (!req.user.scopes.includes(scope)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
}
```

#### MEDIUM: Missing Audit Logs for Failed Auth
- **Vulnerability:** No logging for failed authentication attempts
- **Impact:** Cannot detect credential stuffing or brute force attacks
- **Location:** src/auth/auth.js (missing)
- **Mitigation:** Log failed auth attempts with IP, timestamp, reason
- **Risk Score:** 3 (likelihood) Ã— 3 (impact) = 9 (MEDIUM)

#### LOW: Refresh Token Rotation Not Implemented
- **Vulnerability:** Refresh tokens not rotated on use (Auth0 best practice)
- **Impact:** Longer window for stolen refresh token abuse
- **Location:** src/auth/auth.js:78
- **Mitigation:** Enable refresh token rotation in Auth0 dashboard
- **Risk Score:** 2 (likelihood) Ã— 2 (impact) = 4 (LOW)

### Compliance Impact
- **SOC 2:** Token logging violates Access Control (CC6.1) - must fix for audit
- **GDPR:** User profile data properly encrypted, consent mechanism present âœ“
- **HIPAA:** N/A (no PHI involved)

### Recommendations
1. **Immediate (before deployment):** Fix HIGH findings (#1, #2)
2. **Next sprint:** Implement audit logging for failed auth (MEDIUM)
3. **Backlog:** Enable refresh token rotation (LOW)

### Verdict
**CHANGES_REQUIRED** - 2 HIGH severity findings must be addressed before production deployment.

**Overall Risk Level:** MEDIUM (adequate safeguards with identified gaps)
```

### Example 2: API Endpoint Threat Model

**Request:** "Threat model new /api/upload endpoint for user file uploads"

**Security Agent Response:**
```markdown
## Threat Model: File Upload Endpoint

### Asset Analysis
**Assets:**
- User files (potentially sensitive documents)
- Server storage and compute resources
- Application integrity (malware upload risk)

**Entry Point:** POST /api/upload
- Accepts multipart/form-data
- Max file size: 10MB (configured)
- Allowed types: PDF, DOCX, JPG, PNG
- Authentication: Required (JWT)

### STRIDE Analysis

#### Spoofing Identity
**Threat:** Attacker uploads files as another user
**Likelihood:** 2/5 (JWT authentication present)
**Impact:** 4/5 (unauthorized file association)
**Risk Score:** 8 (MEDIUM)
**Mitigation:** âœ“ JWT validation already implemented

#### Tampering with Data
**Threat 1:** File content modified after upload
**Likelihood:** 2/5 (requires server access)
**Impact:** 5/5 (integrity compromise)
**Risk Score:** 10 (MEDIUM)
**Mitigation:** âœ“ Integrity check with SHA-256 hash stored

**Threat 2:** MIME type spoofing (malicious exe as .pdf)
**Likelihood:** 4/5 (easy to exploit)
**Impact:** 5/5 (malware execution)
**Risk Score:** 20 (CRITICAL)
**Mitigation:** âŒ MISSING - Only checks file extension, not magic bytes

#### Repudiation
**Threat:** User denies uploading malicious file
**Likelihood:** 3/5 (if incident occurs)
**Impact:** 3/5 (legal/compliance issue)
**Risk Score:** 9 (MEDIUM)
**Mitigation:** âœ“ Audit log records user_id, timestamp, filename, hash

#### Information Disclosure
**Threat:** Uploaded files accessible without authorization
**Likelihood:** 2/5 (depends on storage config)
**Impact:** 5/5 (data breach)
**Risk Score:** 10 (MEDIUM)
**Mitigation:** âŒ PARTIAL - Files stored in S3, but bucket policy not reviewed

#### Denial of Service
**Threat 1:** Upload flood (many large files)
**Likelihood:** 4/5 (no rate limiting)
**Impact:** 4/5 (storage/cost exhaustion)
**Risk Score:** 16 (HIGH)
**Mitigation:** âŒ MISSING - No rate limiting on upload endpoint

**Threat 2:** Zip bomb (compressed bomb decompresses to huge size)
**Likelihood:** 3/5 (if zip files allowed)
**Impact:** 5/5 (server crash)
**Risk Score:** 15 (HIGH)
**Mitigation:** âŒ MISSING - No decompression size validation

#### Elevation of Privilege
**Threat:** Path traversal in filename (../../etc/passwd)
**Likelihood:** 4/5 (common attack)
**Impact:** 5/5 (arbitrary file write)
**Risk Score:** 20 (CRITICAL)
**Mitigation:** âŒ MISSING - Filename not sanitized

### Critical Findings

1. **CRITICAL: MIME Type Spoofing**
   - Validate magic bytes, not just extension
   - Use library like `file-type` or `python-magic`

2. **CRITICAL: Path Traversal**
   - Sanitize filename: strip path separators, use UUID for storage
   - Never use user-provided filename directly

3. **HIGH: No Rate Limiting**
   - Implement: 10 uploads/hour per user
   - Use Redis-backed rate limiter

4. **HIGH: Zip Bomb Risk**
   - If accepting zip files, validate decompressed size before extracting
   - Limit max decompressed size to 100MB

5. **MEDIUM: S3 Bucket Policy**
   - Review: ensure private access only
   - Require pre-signed URLs for downloads (expiring links)

### Recommended Implementation

```javascript
const fileType = require('file-type');
const rateLimit = require('express-rate-limit');
const sanitize = require('sanitize-filename');
const { v4: uuidv4 } = require('uuid');

// Rate limiting
const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,
  message: 'Too many uploads, try again later'
});

router.post('/upload', authenticate, uploadLimiter, async (req, res) => {
  const file = req.file;

  // 1. Validate magic bytes (MIME type)
  const fileTypeResult = await fileType.fromBuffer(file.buffer);
  const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];

  if (!fileTypeResult || !allowedTypes.includes(fileTypeResult.mime)) {
    return res.status(400).json({ error: 'Invalid file type' });
  }

  // 2. Sanitize filename, use UUID for storage
  const originalName = sanitize(file.originalname);
  const storageKey = `${uuidv4()}.${fileTypeResult.ext}`;

  // 3. Calculate integrity hash
  const hash = crypto.createHash('sha256').update(file.buffer).digest('hex');

  // 4. Upload to S3 with private ACL
  await s3.putObject({
    Bucket: 'private-uploads',
    Key: storageKey,
    Body: file.buffer,
    ContentType: fileTypeResult.mime,
    ServerSideEncryption: 'AES256',
    Metadata: {
      'original-name': originalName,
      'uploader-id': req.user.id,
      'integrity-hash': hash
    }
  });

  // 5. Audit log
  logger.info('File uploaded', {
    user_id: req.user.id,
    storage_key: storageKey,
    original_name: originalName,
    size: file.size,
    hash: hash
  });

  res.json({ file_id: storageKey });
});
```

### Verdict
**CHANGES_REQUIRED** - 2 CRITICAL and 2 HIGH findings must be addressed before deployment.

```

## Bundled References

- [OWASP Top 10 Checklist](references/owasp-top-10-checklist.md) — Actionable checklist for each OWASP category
- [STRIDE Threat Model Template](references/stride-threat-model-template.md) — Fill-in template for threat modeling sessions

## References

- **OWASP Top 10:** https://owasp.org/www-project-top-ten/
- **STRIDE Threat Modeling:** https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
- **Secure Coding Guidelines:** `instructions/compliance/security.instructions.md`
- **Compliance Standards:** `instructions/compliance/`
- **Security Agent:** `.github/agents/security.agent.md`
