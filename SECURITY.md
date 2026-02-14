# Security Policy

## Reporting a vulnerability

Please **do not** report security vulnerabilities in public issues, pull requests, or discussions.

Use a private reporting channel:

- Preferred: GitHub private vulnerability reporting (Security Advisories) for this repository.
- If unavailable, contact maintainers directly through a private channel.

Include:

- Affected file(s) or component(s)
- Reproduction steps or proof of concept
- Impact assessment
- Suggested remediation (if known)

## Response expectations

Maintainers will:

1. Acknowledge receipt as quickly as possible.
2. Investigate and validate impact.
3. Coordinate remediation and release timing.
4. Share a public fix summary after mitigation, without exposing sensitive exploit details.

## Disclosure guidance

Please avoid public disclosure until a fix or mitigation is available and maintainers confirm it is safe to publish details.

## Scope notes

Security-sensitive areas in this repository include:

- Agent and prompt instructions that influence tool behavior
- Automation scripts in `scripts/`
- CI workflows and release tooling
