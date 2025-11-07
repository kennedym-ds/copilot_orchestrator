---
title: "Prompt Engineering by Model Tier"
version: "0.1.0"
lastUpdated: "2025-11-08"
status: draft
---

# Prompt Engineering by Model Tier

## Overview

This guide provides tier-specific prompt crafting strategies to maximize effectiveness of the multi-tier LLM architecture. Premium models (planning/review tier) benefit from open-ended, exploratory prompting, while cost-efficient models (execution tier) perform best with structured, step-by-step instructions.

## Architecture Context

**Planning/Review Tier (20% of invocations):**
- Models: GPT-5, Claude Sonnet 4.5, Claude Opus, Gemini 2.5 Pro
- Strengths: Advanced reasoning, ambiguity handling, synthesis, creative problem-solving
- Use cases: Research, planning, architecture decisions, code review

**Execution Tier (80% of invocations):**
- Models: GPT-4.1, Claude Haiku 4.5, GPT-5 Mini
- Strengths: Structured execution, code generation, pattern following, efficiency
- Use cases: Implementation, testing, refactoring, documentation updates

## Planning/Review Tier Prompting

### Principles

1. **Open-ended exploration** — Premium models excel at navigating ambiguity
2. **Multi-perspective analysis** — Encourage options, trade-offs, implications
3. **Synthesis over prescription** — Let model integrate diverse information
4. **Uncertainty acknowledgment** — Request explicit discussion of assumptions and risks

### Effective Patterns

#### For Research (Researcher Agent)

**❌ Too prescriptive:**
```
Search for "API authentication best practices" and list 5 methods.
```

**✅ Open-ended and exploratory:**
```
Research authentication strategies for REST APIs, focusing on:
- Security vs. developer experience trade-offs
- Emerging standards and industry adoption trends
- Pros/cons of OAuth 2.0, API keys, JWTs, and newer approaches
- Recommendations based on use case (public API vs. internal services)

Synthesize findings into a decision framework with:
- Key considerations
- Recommended approaches for different contexts
- Open questions or areas requiring deeper investigation
```

**Why it works:**
- Encourages comprehensive research across multiple sources
- Requests synthesis and framework creation (premium model strength)
- Invites nuanced analysis of trade-offs
- Leaves room for model to surface unexpected insights

#### For Planning (Planner Agent)

**❌ Too prescriptive:**
```
Create a 3-phase plan to add user authentication:
1. Design database schema
2. Implement login endpoint
3. Add authorization middleware
```

**✅ Open-ended with constraints:**
```
Develop a multi-phase implementation plan for adding user authentication to the application.

Context:
- Current state: No authentication; all endpoints public
- Requirements: Role-based access control, secure password storage, session management
- Constraints: Minimize changes to existing API contracts, maintain backward compatibility for 2 weeks

For each phase, include:
- Objectives and deliverables
- Risks and mitigation strategies
- Dependencies and sequencing rationale
- Acceptance criteria and validation approach
- Open questions requiring clarification

Consider:
- Should we add authentication incrementally (per endpoint) or globally?
- What's the right balance between security and migration complexity?
- Are there existing libraries/frameworks we should leverage?
- How do we test authentication without disrupting current users?

Recommend 3-5 phases with clear pause points for review and adjustment.
```

**Why it works:**
- Provides context without over-constraining solution
- Requests reasoning about trade-offs and sequencing
- Invites identification of risks and open questions
- Allows model to apply experience and suggest alternatives

#### For Review (Reviewer Agent)

**❌ Too prescriptive:**
```
Review this code and check:
- Follows naming conventions
- Has unit tests
- No security vulnerabilities
```

**✅ Open-ended with focus areas:**
```
Perform a structured code review of the authentication implementation, assessing:

**Correctness:**
- Does the implementation meet the acceptance criteria?
- Are edge cases handled (empty inputs, expired tokens, concurrent sessions)?
- Is error handling comprehensive and user-friendly?

**Security:**
- Are passwords properly hashed with appropriate algorithms (bcrypt, Argon2)?
- Is session management secure (CSRF protection, secure cookies, timeout)?
- Are there any injection, authentication bypass, or privilege escalation risks?

**Maintainability:**
- Is the code structure clear and modular?
- Are abstractions appropriate for the problem domain?
- Would a new contributor understand the authentication flow?

**Testing:**
- Do tests cover positive/negative cases and edge conditions?
- Are security-critical paths well-tested?
- Would tests catch regressions in authentication logic?

For each finding:
- Tag severity (CRITICAL, HIGH, MEDIUM, LOW, INFO)
- Provide specific location and description
- Explain the risk or improvement opportunity
- Suggest remediation approach (fix, refactor, document, test)

Return status: APPROVED, NEEDS_REVISION, or FAILED.
```

**Why it works:**
- Structured framework ensures comprehensive review
- Open-ended within each category allows model to surface unexpected issues
- Requests severity tagging and remediation guidance
- Balances thoroughness with actionability

### Prompting Anti-Patterns (Planning/Review Tier)

**Avoid:**
- ❌ **Over-prescription** — "Do X, then Y, then Z" eliminates model's reasoning advantage
- ❌ **Single-path thinking** — "Implement feature F using approach A" misses better alternatives
- ❌ **Missing context** — Premium models need background to reason effectively
- ❌ **Ignoring uncertainty** — Premature certainty leads to brittle plans

**Instead:**
- ✅ Provide rich context and constraints
- ✅ Request multiple options with trade-off analysis
- ✅ Invite identification of risks and open questions
- ✅ Encourage synthesis and framework creation

## Execution Tier Prompting

### Principles

1. **Step-by-step instructions** — Cost-efficient models execute structured tasks well
2. **Clear acceptance criteria** — Remove ambiguity to prevent hallucinations
3. **Pattern reinforcement** — Reference existing code patterns for consistency
4. **Explicit validation steps** — Build quality checks into instructions

### Effective Patterns

#### For Implementation (Implementer Agent)

**❌ Too open-ended:**
```
Add user authentication to the application.
```

**✅ Structured with clear steps:**
```
Implement user authentication following this TDD workflow:

**Phase Objective:** Add login endpoint with password verification

**Step 1: Write failing tests**
- Create `tests/auth/login.test.js`
- Test cases:
  - Valid credentials return 200 + JWT token
  - Invalid password returns 401 + error message
  - Non-existent user returns 401 + error message
  - Missing email/password returns 400 + validation error
- Run: `npm test tests/auth/login.test.js`
- Expected: All tests fail (endpoint doesn't exist)

**Step 2: Implement minimal code to pass tests**
- Create `src/routes/auth.js`
- Add POST `/api/auth/login` endpoint
- Use `bcrypt.compare()` for password verification (see `src/utils/password.js` for pattern)
- Return JWT using existing `generateToken()` helper from `src/utils/jwt.js`
- Handle errors with consistent format (see `src/middleware/errorHandler.js`)

**Step 3: Verify tests pass**
- Run: `npm test tests/auth/login.test.js`
- Expected: All tests green
- If failures, debug and fix before proceeding

**Step 4: Run full test suite**
- Run: `npm test`
- Expected: No regressions in existing tests
- If failures, check for unintended side effects

**Step 5: Refactor if needed**
- Extract duplicated validation logic if present
- Ensure code follows existing patterns in `src/routes/`
- Keep tests green while refactoring

**Constraints:**
- Do not modify existing authentication logic in `src/utils/password.js`
- Reuse error handling patterns from other routes
- Follow existing naming conventions (camelCase, descriptive names)

**Acceptance Criteria:**
- All new tests pass
- No existing tests broken
- Code follows project patterns
- Error messages are user-friendly
```

**Why it works:**
- Explicit step-by-step workflow prevents ambiguity
- References existing patterns for consistency
- Built-in validation checkpoints
- Clear constraints prevent scope creep
- Execution-tier models excel at following structured instructions

#### For Test Writing (Implementer Agent)

**❌ Too vague:**
```
Write tests for the authentication module.
```

**✅ Structured with specific cases:**
```
Write unit tests for `src/auth/passwordValidator.js` following existing test patterns.

**Test file:** `tests/auth/passwordValidator.test.js`

**Reference:** See `tests/auth/userValidator.test.js` for test structure and assertion patterns

**Test cases to implement:**

1. **Password strength validation:**
   - ✅ Valid: "SecureP@ss123" → returns { valid: true }
   - ❌ Too short: "Short1!" → returns { valid: false, error: "Password must be at least 12 characters" }
   - ❌ No uppercase: "securepass123!" → returns { valid: false, error: "Password must contain uppercase letter" }
   - ❌ No number: "SecurePassword!" → returns { valid: false, error: "Password must contain number" }
   - ❌ No special char: "SecurePass123" → returns { valid: false, error: "Password must contain special character" }

2. **Edge cases:**
   - Empty string → returns { valid: false, error: "Password is required" }
   - Null/undefined → returns { valid: false, error: "Password is required" }
   - Very long password (>128 chars) → returns { valid: false, error: "Password too long" }

3. **Common password detection:**
   - "Password123!" → returns { valid: false, error: "Password too common" }
   - Use existing `commonPasswords.json` list

**Validation:**
- Run: `npm test tests/auth/passwordValidator.test.js`
- Expected: All tests pass
- Code coverage: 100% of passwordValidator.js
```

**Why it works:**
- Specific test cases with expected inputs/outputs
- References existing patterns to follow
- Clear validation steps
- Execution-tier models excel at systematic test generation

#### For Refactoring (Implementer Agent)

**❌ Too open-ended:**
```
Refactor the authentication code to be cleaner.
```

**✅ Structured with specific goals:**
```
Refactor `src/auth/login.js` to extract duplicated validation logic while keeping tests green.

**Current state:**
- File: `src/auth/login.js` (100 lines)
- Duplication: Email/password validation appears in 3 places
- Tests: `tests/auth/login.test.js` (all passing)

**Refactoring steps:**

1. **Run tests to establish baseline:**
   - Run: `npm test tests/auth/login.test.js`
   - Expected: All green

2. **Extract validation to helper:**
   - Create: `src/auth/validators/loginValidator.js`
   - Move email/password validation to `validateLoginInput()` function
   - Follow existing validator pattern in `src/auth/validators/userValidator.js`

3. **Update login.js to use new validator:**
   - Import: `import { validateLoginInput } from './validators/loginValidator.js'`
   - Replace duplicated validation logic with single call
   - Preserve existing error message format

4. **Verify tests still pass:**
   - Run: `npm test tests/auth/login.test.js`
   - Expected: All green (no behavior change)

5. **Add validator tests:**
   - Create: `tests/auth/validators/loginValidator.test.js`
   - Test valid/invalid email formats
   - Test valid/invalid password formats
   - Run: `npm test tests/auth/validators/loginValidator.test.js`

**Constraints:**
- Do not change behavior, only structure
- Keep all existing tests passing
- Follow existing validator patterns
- No new dependencies

**Validation:**
- All tests remain green
- Code coverage maintained or improved
- Duplication eliminated (verify with: `npm run lint -- --report-duplication`)
```

**Why it works:**
- Clear refactoring goal with measurable outcome
- Step-by-step process prevents breaking changes
- Validation checkpoints throughout
- References existing patterns
- Execution-tier models handle structured refactoring well

### Prompting Anti-Patterns (Execution Tier)

**Avoid:**
- ❌ **Ambiguity** — "Make it better" leaves too much room for interpretation
- ❌ **Missing validation** — No checkpoints leads to compounding errors
- ❌ **Vague acceptance criteria** — "Should work correctly" isn't measurable
- ❌ **Ignoring existing patterns** — Leads to inconsistent codebase

**Instead:**
- ✅ Provide explicit step-by-step instructions
- ✅ Include validation checkpoints after each step
- ✅ Reference existing code patterns to follow
- ✅ Define clear, measurable acceptance criteria

## Cross-Tier Collaboration

### When Execution Tier Encounters Ambiguity

If Implementer receives instructions with unclear requirements:

**Don't:**
- ❌ Guess at intent and implement best-guess solution
- ❌ Make architectural decisions beyond defined scope
- ❌ Introduce new abstractions without guidance

**Do:**
- ✅ Escalate to Conductor with specific questions
- ✅ Present 2-3 options with pros/cons (if obvious choices exist)
- ✅ Request clarification before proceeding

**Escalation template:**
```
## Escalation Required

**Trigger:** Tier 1 - Ambiguous requirements

**Context:** Implementing login endpoint per Phase 2 plan

**Ambiguity:** Plan states "secure session management" but doesn't specify:
- Should we use JWT tokens (stateless) or server-side sessions (stateful)?
- What session timeout is appropriate (30 min, 1 hour, 1 day)?
- Should sessions persist across browser restarts?

**Options considered:**
1. JWT with 1-hour expiration (stateless, simpler)
   - Pro: No database/cache needed for session storage
   - Con: Can't revoke tokens before expiration
2. Server-side sessions with Redis (stateful)
   - Pro: Can revoke sessions immediately
   - Con: Requires Redis dependency and state management

**Recommendation:** Request Planner guidance on session strategy before implementing login endpoint

**Artifacts:** Phase 2 plan excerpt, existing auth code samples
```

### When Planning Tier Provides Execution Instructions

If Planner/Researcher provides implementation details in response:

**Conductor should:**
- Extract clear, structured instructions for Implementer
- Convert open-ended recommendations into step-by-step workflow
- Add validation checkpoints and acceptance criteria
- Reference existing patterns in codebase

**Example transformation:**

**Planner output (premium tier):**
```
For authentication, consider using JWT tokens with:
- HS256 algorithm (or RS256 for distributed systems)
- Claims including user ID, role, expiration
- Refresh token mechanism for extended sessions
- Secure storage (httpOnly cookies or localStorage with XSS protection)
- Token validation middleware on protected routes
```

**Conductor transforms for Implementer (execution tier):**
```
Implement JWT authentication following this workflow:

**Step 1: Add JWT dependency**
- Run: `npm install jsonwebtoken`
- Verify: Check package.json for jsonwebtoken@^9.0.0

**Step 2: Create token generation utility**
- File: `src/utils/jwt.js`
- Function: `generateToken(userId, role)` returning signed JWT
- Use HS256 algorithm with secret from `process.env.JWT_SECRET`
- Set expiration to 1 hour
- Follow pattern in `src/utils/crypto.js` for secret handling

**Step 3: Write tests for token utility**
[...detailed test cases...]

**Step 4: Implement token validation middleware**
[...step-by-step implementation...]
```

## Model-Specific Nuances

### GPT-5 (Planning Tier)

**Strengths:**
- Strategic planning and architecture
- Clear, structured communication
- Good balance of creativity and pragmatism

**Prompting tips:**
- Request explicit trade-off analysis
- Ask for multiple phases with pause points
- Encourage identification of open questions

### Claude Sonnet 4.5 / Opus (Planning Tier)

**Strengths:**
- Code understanding and refactoring
- Nuanced requirement interpretation
- Security and compliance analysis

**Prompting tips:**
- Provide rich context and constraints
- Request detailed reasoning for recommendations
- Leverage for complex code reviews and threat modeling

### Gemini 2.5 Pro (Planning Tier)

**Strengths:**
- Massive context window (2M tokens)
- Research synthesis across many sources
- Multi-document analysis

**Prompting tips:**
- Use for research requiring broad context
- Request synthesis of diverse information
- Leverage for cross-repository analysis

### GPT-4.1 (Execution Tier)

**Strengths:**
- Code generation and completion
- Test writing
- Following structured instructions

**Prompting tips:**
- Provide step-by-step workflows
- Reference existing patterns explicitly
- Include validation checkpoints

### Claude Haiku 4.5 (Execution Tier)

**Strengths:**
- Documentation writing
- Structured refactoring
- Routine implementation tasks

**Prompting tips:**
- Clear acceptance criteria
- Template-based generation
- Consistency with existing docs/code

### GPT-5 Mini (Execution Tier)

**Strengths:**
- Cost efficiency
- Adequate for structured tasks
- Fast response times

**Prompting tips:**
- Very explicit instructions
- Minimal ambiguity
- Clear validation steps

## Continuous Improvement

### Prompt Effectiveness Tracking

In `docs/operations.md`, track:

1. **Escalation triggers by prompt pattern:**
   - Which prompt styles lead to more/fewer escalations?
   - Are execution-tier prompts structured enough?
   - Are planning-tier prompts too prescriptive?

2. **Review rejection by prompt quality:**
   - Do more structured prompts lead to fewer rejections?
   - Are ambiguous prompts correlated with review failures?

3. **Model-task fit:**
   - Which models perform best with which prompt styles?
   - Should we adjust default assignments based on prompt type?

### Prompt Library

Maintain reusable prompt templates in `.github/prompts/`:

- `planning/` — Open-ended, exploratory prompts for premium tier
- `implementation/` — Structured, step-by-step prompts for execution tier
- `review/` — Comprehensive review frameworks
- `research/` — Research synthesis templates

Tag prompts with:
- Tier (planning/execution)
- Model preference
- Task type
- Success metrics

## Summary

**Planning/Review Tier (Premium Models):**
- Open-ended, exploratory prompts
- Multi-perspective analysis
- Synthesis and framework creation
- Uncertainty acknowledgment

**Execution Tier (Cost-Efficient Models):**
- Step-by-step instructions
- Clear acceptance criteria
- Pattern reinforcement
- Explicit validation steps

**Key Principle:** Match prompt structure to model capabilities. Premium models reason about ambiguity; execution models execute structure.

## Related Documentation

- `instructions/workflows/escalation-patterns.instructions.md` — When to escalate from execution to planning tier
- `instructions/global/03_model-selection.instructions.md` — Model capabilities and fallback chains
- `docs/operations.md` — Metrics for tracking prompt effectiveness
- `.github/prompts/` — Reusable prompt templates by tier and task type
