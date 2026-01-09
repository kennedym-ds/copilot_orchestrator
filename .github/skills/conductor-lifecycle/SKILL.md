# Conductor Lifecycle Management

Provides conductor workflow patterns for multi-phase orchestration including planning, implementation, review cycles, pause points, and handoffs.

## Description

This skill teaches the conductor agent how to manage complex multi-phase workflows through structured lifecycle stages: Planning → Implementation → Review → Completion. It covers pause point enforcement, subagent delegation patterns, state tracking, artifact persistence, and handoff protocols that maintain context across the orchestration lifecycle.

The conductor coordinates specialized agents (planner, implementer, reviewer, researcher, support personas) while enforcing mandatory checkpoints for human approval after plans and reviews. This skill provides the operational patterns that transform user requests into systematic, auditable, phased execution.

## When to Use

This skill is relevant when:
- Starting a new multi-phase feature or integration task
- Coordinating between planning, implementation, and review stages
- Delegating work to specialized subagents (planner, implementer, researcher)
- Enforcing pause points for human approval
- Tracking progress across phases with state management
- Persisting artifacts to local `artifacts/` folder
- Managing handoffs between agents with context preservation
- Handling DS-Star data science workflows

## Entry Points

### Trigger Phrases
- "orchestrate this task"
- "start conductor workflow"
- "create implementation plan"
- "delegate to planner"
- "hand off to reviewer"
- "track phase progress"
- "pause for approval"

### Context Patterns
- User requests multi-step features or integrations
- Complex tasks requiring planning before implementation
- Tasks spanning multiple agent specializations
- Need for audit trail and rollback capability
- Data science queries requiring DS-Star workflow
- Requests explicitly mentioning "phases" or "plan"

## Core Knowledge

### Workflow Stages

#### 1. Planning Stage
**Objective:** Clarify scope, gather context, draft multi-phase plan

**Pattern:**
```markdown
1. Summarize user request and constraints
2. Identify unknowns requiring research
3. Delegate to `researcher` subagent if needed:
   #runSubagent researcher "Gather context on [technology/pattern/API]"
4. Delegate to `planner` subagent:
   #runSubagent planner "Create multi-phase plan for [objective]. Include risks, dependencies, rollback strategy."
5. Present plan using docs/templates/plan.md structure
6. **PAUSE POINT:** Wait for user approval before proceeding
```

**State Tracking:**
- Current Phase: Planning
- Plan Progress: 0 of N phases
- Last Action: Presented plan to user
- Next Action: Await approval or iterate on plan

#### 2. Implementation Cycles
**Objective:** Execute approved plan phase-by-phase with testing

**Pattern:**
```markdown
For each phase:
  1. Mark phase as "in-progress" in todo list
  2. Delegate to `implementer` subagent:
     #runSubagent implementer "Implement Phase N: [objective]. Files: [list]. Apply TDD: write tests first, then implementation. Validate with [scripts]."
  3. After implementation, delegate to `reviewer`:
     #runSubagent reviewer "Review Phase N changes. Check: correctness, test coverage, style compliance, security. Provide severity-tagged findings."
  4. If reviewer APPROVED → create phase-complete.md artifact
  5. If reviewer CHANGES_REQUIRED → iterate with implementer
  6. **PAUSE POINT:** User commits changes, confirms ready for next phase
```

**State Tracking:**
- Current Phase: Implementation (Phase N of M)
- Plan Progress: N of M phases
- Last Action: Completed Phase N, reviewer approved
- Next Action: Proceed to Phase N+1 or await commit confirmation

#### 3. Review Checkpoints
**Objective:** Quality gates with severity-tagged findings

**Pattern:**
```markdown
After each phase implementation:
  1. Collect changed files and diff summary
  2. Invoke reviewer with acceptance criteria:
     #runSubagent reviewer "Review [files] for [phase objective]. Acceptance: [criteria]. Tag findings: BLOCKER, MAJOR, MINOR, NIT."
  3. Parse verdict: APPROVED | CHANGES_REQUIRED | INSUFFICIENT_CONTEXT
  4. If BLOCKER/MAJOR findings → iterate with implementer
  5. If APPROVED → proceed to phase completion
```

**Severity Levels:**
- BLOCKER: Prevents production deployment, must fix
- MAJOR: Significant issue, should fix before next phase
- MINOR: Improvement opportunity, can defer
- NIT: Style/preference, optional

#### 4. Completion Stage
**Objective:** Consolidate results, surface follow-up tasks

**Pattern:**
```markdown
When all phases complete:
  1. Compile plan-complete.md using docs/templates/plan-complete.md
  2. Invoke support personas for final reviews:
     - Security review: #runSubagent security "Review [changes] for security posture"
     - Performance review: #runSubagent performance "Analyze [changes] for runtime/memory impact"
     - Documentation: #runSubagent docs "Generate user-facing docs for [feature]"
  3. Surface follow-up tasks, risks, recommendations
  4. Provide rollback instructions if needed
```

**State Tracking:**
- Current Phase: Complete
- Plan Progress: M of M phases (100%)
- Last Action: Created plan-complete.md, obtained final reviews
- Next Action: User deploys or schedules follow-up tasks

### DS-Star Data Science Workflow

**Objective:** Iterative data analysis with round-based progress

**Trigger Detection:**
- "analyze data", "what factors drive", "correlation between"
- "predict", "forecast", "model performance"
- Explicit data file references (.csv, .xlsx, .parquet)

**Pattern:**
```markdown
1. Detect DS-Star query → immediate handoff:
   #runSubagent data-analytics "Analyze [data question]. Dataset: [path]. Success criteria: [business objective]."
2. Monitor round progress (max 10 rounds, 30-min timeout)
3. Track verdict per round: INSUFFICIENT | PARTIAL | SUFFICIENT
4. On SUFFICIENT → documentation handoff:
   #runSubagent docs "Create data analysis report from pipeline_state.json"
5. Surface methodology, findings, recommendations
```

**State Tracking:**
- Current Phase: DS-Star Analysis
- Plan Progress: Round N/10
- Last Verdict: PARTIAL | SUFFICIENT
- Next Action: Continue analysis or finalize documentation

### Pause Point Enforcement

**Mandatory Pause Points:**
1. **After planning** — User must approve plan before implementation starts
2. **After each review** — User commits changes and confirms readiness
3. **Before scope expansion** — New phases require explicit approval

**Pause Point Pattern:**
```markdown
**🛑 PAUSE POINT**

I've completed [stage]. Before proceeding, please:
1. [Action 1: e.g., review plan.md]
2. [Action 2: e.g., commit Phase N changes]
3. Reply "proceed" to continue or provide feedback

**Current State:**
- Phase: [current]
- Progress: [N of M]
- Artifacts: [list of created files]
```

### Artifact Persistence

**Local Artifacts Folder:**
```
artifacts/
├── plans/{feature-name}/
│   ├── plan.md
│   ├── phase-1-complete.md
│   ├── phase-N-complete.md
│   └── plan-complete.md
├── reviews/{date}-{feature}.md
├── research/{topic}.md
├── security/{date}-{scope}.md
└── sessions/{session-id}.json
```

**Artifact Naming:**
- Plans: `artifacts/plans/{feature-slug}/plan.md`
- Reviews: `artifacts/reviews/{YYYY-MM-DD}-{feature-slug}.md`
- Sessions: `artifacts/sessions/{session-id}.json`

**Template Usage:**
- Plan: `docs/templates/plan.md`
- Phase Complete: `docs/templates/phase-complete.md`
- Plan Complete: `docs/templates/plan-complete.md`

### State Tracking Block

**Include in every conductor response:**
```markdown
### State Tracking

**Current Phase:** Planning | Implementation | Review | Complete | DS-Star
**Plan Progress:** {completed} of {total} phases
**Last Action:** {summary of most recent step}
**Next Action:** {immediate recommended step or pause point}
```

### Subagent Delegation

**Delegation Pattern:**
```markdown
1. Summarize context before delegation (preserve continuity)
2. Invoke subagent: #runSubagent {agent-name} "{detailed prompt}"
3. Parse subagent response, extract key information
4. Update state tracking based on outcome
5. Determine next action (continue, pause, escalate)
```

**Context Preservation:**
- Include relevant file paths, line numbers, acceptance criteria
- Reference prior decisions: "As planned in Phase 1..."
- Carry forward constraints: "Within budget of $X, timeline of Y weeks"

**Common Delegations:**
| Agent | When to Delegate | Prompt Pattern |
|-------|------------------|----------------|
| `planner` | Need multi-phase plan | "Create phased plan for [objective]. Include risks, dependencies, rollback." |
| `implementer` | Execute plan phase | "Implement Phase N: [objective]. Files: [list]. TDD approach. Validate with [scripts]." |
| `reviewer` | After implementation | "Review [files] for [phase]. Acceptance: [criteria]. Tag findings by severity." |
| `researcher` | Gather context | "Research [technology/pattern]. Find: API docs, best practices, examples." |
| `security` | Security review | "Review [changes] for threat model, compliance impacts." |
| `performance` | Performance analysis | "Analyze [changes] for runtime, memory, cost implications." |
| `docs` | Documentation | "Generate user guide for [feature]. Include: setup, usage, troubleshooting." |
| `data-analytics` | Data science query | "Analyze [data question]. Dataset: [path]. Iterative DS-Star workflow." |

## Examples

### Example 1: Feature Request Orchestration

**User Request:** "Add OAuth2 authentication to our API"

**Conductor Response:**
```markdown
I'll orchestrate OAuth2 integration through a multi-phase plan.

### State Tracking
**Current Phase:** Planning
**Plan Progress:** 0 of ? phases
**Last Action:** Received feature request
**Next Action:** Delegate to planner for multi-phase plan

Let me engage the planner to create a structured implementation plan.

#runSubagent planner "Create multi-phase implementation plan for adding OAuth2 authentication to API. Include: 1) Research OAuth2 providers (Auth0, Okta, Cognito), 2) Design token flow (authorization code + PKCE), 3) Implement auth middleware, 4) Add token validation, 5) Update API endpoints with auth checks, 6) Create integration tests. Consider: security best practices, existing session management, backward compatibility. Identify risks and rollback strategy."

[After planner responds...]

I've created a 5-phase implementation plan (see artifacts/plans/oauth2-integration/plan.md):

**Phase 1:** Research & Provider Selection (1 day)
**Phase 2:** Auth Middleware Implementation (2 days)
**Phase 3:** Endpoint Protection (2 days)
**Phase 4:** Testing & Validation (1 day)
**Phase 5:** Documentation & Rollout (1 day)

**🛑 PAUSE POINT**

Please review the plan at artifacts/plans/oauth2-integration/plan.md. Reply "proceed" to start Phase 1 or provide feedback for adjustments.

### State Tracking
**Current Phase:** Planning (awaiting approval)
**Plan Progress:** 0 of 5 phases
**Last Action:** Presented OAuth2 integration plan
**Next Action:** Await user approval to proceed with Phase 1
```

### Example 2: Implementation Cycle with Review

**User Reply:** "Proceed with Phase 1"

**Conductor Response:**
```markdown
Starting Phase 1: Research & Provider Selection

### State Tracking
**Current Phase:** Implementation (Phase 1 of 5)
**Plan Progress:** 1 of 5 phases
**Last Action:** User approved plan
**Next Action:** Delegate to researcher for OAuth2 provider analysis

#runSubagent researcher "Research OAuth2 providers for API integration. Compare: Auth0, Okta, AWS Cognito. Evaluate: pricing, developer experience, token flow support (authorization code + PKCE), SDK quality, rate limits, enterprise features. Provide recommendation with rationale."

[After researcher responds...]

Research complete. Recommendation: Auth0 (best DX, generous free tier, excellent Node.js SDK).

Now implementing Phase 1 deliverables:

#runSubagent implementer "Implement Phase 1: OAuth2 Provider Selection. Create docs/architecture/oauth2-design.md documenting: 1) Provider choice (Auth0) with rationale, 2) Token flow diagram (authorization code + PKCE), 3) Integration points with existing API. Apply TDD: create test plan before implementation."

[After implementer responds...]

Phase 1 implementation complete. Requesting review:

#runSubagent reviewer "Review Phase 1 deliverables: docs/architecture/oauth2-design.md. Acceptance criteria: 1) Provider choice justified, 2) Token flow clearly documented, 3) Integration points identified, 4) Security considerations addressed. Tag findings by severity (BLOCKER, MAJOR, MINOR, NIT)."

[After reviewer responds with APPROVED verdict...]

**Phase 1 Complete** ✓

Created artifacts/plans/oauth2-integration/phase-1-complete.md with:
- Deliverables: oauth2-design.md (architecture document)
- Review: APPROVED with 0 blockers, 1 minor suggestion (document token expiry strategy)
- Validation: Design reviewed by security perspective

**🛑 PAUSE POINT**

Please commit Phase 1 changes and reply "proceed to phase 2" when ready.

### State Tracking
**Current Phase:** Implementation (Phase 1 complete, awaiting commit)
**Plan Progress:** 1 of 5 phases (20%)
**Last Action:** Completed Phase 1, reviewer approved
**Next Action:** Await user commit confirmation, then proceed to Phase 2
```

### Example 3: DS-Star Data Science Query

**User Request:** "Analyze customer churn data to identify retention factors"

**Conductor Response:**
```markdown
Detected data science query. Delegating to DS-Star workflow.

### State Tracking
**Current Phase:** DS-Star Analysis
**Plan Progress:** Round 0/10
**Last Action:** Identified data analysis request
**Next Action:** Delegate to data-analytics agent

#runSubagent data-analytics "Analyze customer churn factors using DS-Star iterative workflow. Objective: Identify key drivers of customer retention and provide actionable recommendations. Dataset: data/customers.csv. Success criteria: Statistical significance p<0.05, actionable insights for retention team, model accuracy >75% if predictive modeling used."

[Data-analytics agent executes rounds 1-5, verdict progression: INSUFFICIENT → PARTIAL → PARTIAL → SUFFICIENT]

DS-Star analysis complete after 4 rounds (verdict: SUFFICIENT).

Key findings from pipeline_state.json:
- Top retention factors: engagement score (p<0.001), support response time (p<0.003), feature adoption rate (p<0.008)
- Churn risk model: 82% accuracy, 0.79 AUC-ROC
- Recommendations: Prioritize engagement campaigns, improve support SLA, enhance onboarding for low-adoption users

Creating final documentation:

#runSubagent docs "Generate data analysis report from artifacts/sessions/pipeline_state.json. Include: executive summary, methodology, findings (with visualizations), recommendations, limitations. Audience: retention team and product leadership."

[After docs agent completes...]

**Analysis Complete**

Deliverables:
- artifacts/research/customer-churn-analysis.md (full report)
- artifacts/sessions/pipeline_state.json (methodology and raw results)

### State Tracking
**Current Phase:** Complete
**Plan Progress:** DS-Star workflow finished (4 rounds)
**Last Action:** Created final analysis report
**Next Action:** User reviews findings and implements retention strategies
```

### Example 4: Pause Point Enforcement

**User Request:** "Can we add Phase 6 for A/B testing?"

**Conductor Response:**
```markdown
This is a **scope expansion** request requiring approval.

**Current Plan:** 5 phases (OAuth2 implementation)
**Proposed Addition:** Phase 6 (A/B testing framework)

**Impact Analysis:**
- Timeline: +2 days (estimated)
- Risk: Introduces external dependency (A/B testing service)
- Benefit: Gradual rollout with metrics

**🛑 PAUSE POINT**

Before expanding scope, I need explicit approval:
1. Review current plan: artifacts/plans/oauth2-integration/plan.md
2. Confirm: Do you want to add Phase 6 (A/B testing) to this plan?
3. Alternative: Complete current 5 phases, then create separate A/B testing task

**Options:**
A. Approve scope expansion → I'll engage planner to add Phase 6
B. Defer A/B testing → Complete original 5 phases first
C. Modify → Adjust the new phase requirements

Please choose A, B, or C.

### State Tracking
**Current Phase:** Implementation (Phase 3 of 5)
**Plan Progress:** 3 of 5 phases (60%)
**Last Action:** User requested scope expansion
**Next Action:** Await approval decision on Phase 6 addition
```

## References

- **Conductor Instructions:** `instructions/workflows/conductor.instructions.md`
- **Templates:** `docs/templates/plan.md`, `docs/templates/phase-complete.md`, `docs/templates/plan-complete.md`
- **Agent Roster:** `AGENTS.md`
- **DS-Star Workflow:** `docs/workflows/ds-star-integration.md`
- **Artifact Structure:** `artifacts/README.md`
- **State Management:** `docs/guides/session-analytics.md`
