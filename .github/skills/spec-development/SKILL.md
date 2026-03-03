---
name: spec-development
description: "Requirements elicitation methodology, specification completeness patterns, and complexity-scaled templates for producing project specs that drive downstream planning and implementation."
---

# Spec Development Skill

## Description

This skill provides structured methodology for developing comprehensive project specifications. It guides agents through requirements elicitation, scope definition, acceptance criteria authoring, and risk identification — producing specs that serve as the authoritative contract for all downstream work (planning, implementation, review).

## When to Use

- User requests a specification, requirements document, or project brief
- Before starting a new feature, system, or significant refactor
- When scope is ambiguous and needs structured decomposition
- When the conductor identifies a task that benefits from upfront specification
- When existing requirements are incomplete or contradictory

## Complexity Tiers

### LIGHTWEIGHT (single concern, 1-2 files)
- **Sections**: Project Overview, Goals & Non-Goals, Requirements, Acceptance Criteria
- **Duration**: 5-10 minutes
- **Elicitation**: 1-3 clarifying questions
- **Example**: Rename a config key, add a validation rule, fix a broken link

### STANDARD (feature-level, 3-15 files)
- **Sections**: Project Overview, Goals & Non-Goals, Requirements, Technical Architecture, Dependencies, Security, Testing Strategy, Acceptance Criteria, Open Questions
- **Duration**: 15-30 minutes
- **Elicitation**: 5-10 clarifying questions + codebase research
- **Example**: Add webhook support, implement caching layer, create new API endpoint

### COMPREHENSIVE (project/system-level, 15+ files or new system)
- **Sections**: All 14 sections from `docs/templates/spec.md`
- **Duration**: 30-60 minutes
- **Elicitation**: 10+ questions + researcher delegation + prior art analysis
- **Example**: New CLI tool, authentication system, database migration framework

## Requirements Elicitation Patterns

### Functional Requirements

Ask these questions to uncover what the system must do:

1. **Core behavior**: "What should happen when [trigger]?"
2. **Input/output**: "What data goes in? What comes out? In what format?"
3. **User actions**: "What will the user do? What steps do they take?"
4. **Business rules**: "Are there conditional rules? Thresholds? Limits?"
5. **State changes**: "What data gets created, updated, or deleted?"

### Non-Functional Requirements

Ask these to uncover quality attributes:

1. **Performance**: "What response time is acceptable? Expected load?"
2. **Security**: "Who can access this? What data is sensitive?"
3. **Reliability**: "What happens on failure? Is retry needed?"
4. **Scalability**: "How many users/requests/records? Growth expected?"
5. **Compatibility**: "What systems, browsers, or versions must be supported?"

### Implicit Requirements

Probe for unstated assumptions:

1. **Error handling**: "What should happen when things go wrong?"
2. **Edge cases**: "What about empty input? Maximum values? Concurrent access?"
3. **Migration**: "Is there existing data or behavior to preserve?"
4. **Observability**: "How will we know if this is working correctly?"
5. **Rollback**: "Can this be undone? What's the recovery path?"

### Anti-Patterns (Avoid These)

- **Requirements by example only**: "Make it work like X" without specifying *which* behaviors of X
- **Vague acceptance criteria**: "It should be fast" instead of "Response under 200ms at P95"
- **Missing non-goals**: Without stating what's out of scope, everything is in scope
- **Gold-plating**: Adding nice-to-have features as requirements
- **Assumed context**: Skipping background that downstream agents need

## Requirement ID Convention

Every requirement gets a unique, traceable ID:

| Prefix | Category | Example |
|--------|----------|---------|
| `REQ-F-` | Functional | `REQ-F-001`: System shall send webhook on order creation |
| `REQ-NF-` | Non-functional | `REQ-NF-001`: API response time < 200ms at P95 |
| `REQ-S-` | Security | `REQ-S-001`: Webhook payloads shall be HMAC-signed |
| `REQ-D-` | Data/Schema | `REQ-D-001`: Webhook events table with retry tracking |
| `REQ-I-` | Integration | `REQ-I-001`: Support Slack, Teams, and generic HTTP targets |

**Rules:**
- IDs are sequential within their prefix
- Once assigned, an ID is never reused (even if the requirement is removed)
- Removed requirements are marked `[REMOVED]` with rationale, not deleted
- Each ID maps to exactly one acceptance criterion

## Acceptance Criteria Format

Use Given/When/Then for behavioral criteria:

`
AC-001 (traces to REQ-F-001):
  Given: An order is placed with status "confirmed"
  When: The order confirmation event fires
  Then: A webhook POST is sent to all registered endpoints within 5 seconds
  And: The payload includes order ID, status, timestamp, and HMAC signature
`

Use measurable thresholds for non-functional criteria:

`
AC-NF-001 (traces to REQ-NF-001):
  Metric: API response time
  Target: < 200ms at P95 under 1000 concurrent requests
  Measurement: Load test with k6 against staging environment
`

## Section Completeness Checklist

For each section, verify these quality gates before marking `[CONFIRMED]`:

| Section | Completeness Check |
|---------|-------------------|
| Project Overview | Problem statement is concrete, not abstract |
| Goals & Non-Goals | Non-goals list is explicit (not empty) |
| Requirements | Every requirement has REQ-ID and acceptance criterion |
| Architecture | Components and data flow are described at right abstraction |
| Data Models | Schema includes types, constraints, and relationships |
| API Contracts | Endpoints include method, path, request/response shapes, errors |
| Dependencies | External systems, packages, and APIs are listed with versions |
| Security | Auth, authz, data classification, and threat surface addressed |
| Performance | Targets are quantified with measurement methodology |
| Testing | Test types (unit, integration, e2e) mapped to requirements |
| Acceptance Criteria | Every AC traces to a REQ-ID |
| Edge Cases | Failure modes, boundary conditions, and concurrent scenarios |
| Risks | Each risk has likelihood, impact, and mitigation strategy |
| Open Questions | Each question has an owner and resolution deadline |

## Spec-to-Plan Handoff Protocol

When the spec is approved and ready for planning:

1. **Save** the spec to `artifacts/specs/{project-slug}/spec.md`
2. **Verify** the quality checklist is satisfied
3. **Summarize** for conductor:
   - Total requirements count by category
   - Open questions count (should be 0 for full approval, or explicitly deferred)
   - Recommended complexity tier for planning (maps to conductor's FAST/STANDARD/DEEP/ULTRADEEP)
   - Key risks that affect planning decisions
4. **Handoff** with: `#runSubagent conductor "Spec approved. Artifact: artifacts/specs/{slug}/spec.md. Requirements: [count]. Risks: [count]. Recommended planning depth: [tier]."`

## Iteration Patterns

### Feedback Loop
When user provides feedback on a draft spec:
1. Acknowledge the feedback explicitly
2. Update affected sections (mark `[REVISED]`)
3. Check cascading impacts (does changing a requirement affect architecture?)
4. Re-validate acceptance criteria
5. Present a diff summary of what changed

### Scope Expansion Detection
When new requirements emerge during elicitation:
1. Check if they fit the original project boundary
2. If expansion is minor (< 20% scope increase): incorporate and note
3. If expansion is major: flag to user with trade-off analysis
4. Recommend splitting into separate specs if scope diverges significantly

### Ambiguity Resolution
When requirements are genuinely ambiguous:
1. State the ambiguity explicitly
2. Present 2-3 concrete interpretations with implications
3. Ask the user to choose
4. Document the decision with rationale

## References

- `docs/templates/spec.md` — Canonical specification template
- `docs/templates/plan.md` — Implementation plan template (downstream consumer)
- `instructions/workflows/spec.instructions.md` — Agent workflow guardrails
- `instructions/global/00_behavior.instructions.md` — Central persona and engineering tenets
- `.github/skills/conductor-lifecycle/SKILL.md` — Lifecycle integration patterns
