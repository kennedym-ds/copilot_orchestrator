---
name: trilateral-review
description: "Multi-agent consensus review that runs the same artifact through Reviewer, Red Team, and Security agents in parallel, then synthesizes a consensus score. Use for high-stakes plans, architecture decisions, and ULTRADEEP complexity tasks."
argument-hint: "Provide the artifact (plan, architecture, or implementation) to review from three independent perspectives"
model: GPT-5 mini (copilot)
agent: conductor
tools: [agent, todo, changes, search, read, fileSearch, problems]
---

## Purpose

Execute a multi-perspective review of a high-stakes artifact by running three independent assessments in parallel: standard quality review, adversarial red-team challenge, and security/compliance audit. Synthesize the results into a consensus score with confidence level.

## When to Invoke

Use trilateral review when:
- Complexity tier is **ULTRADEEP** (full-repo changes, compliance overhaul, production impact)
- The artifact involves **ruin-risk operations** (PII, auth, infrastructure, destructive changes)
- Multiple prior review iterations have produced conflicting findings
- User explicitly requests comprehensive validation ("thorough review", "validate from all angles")
- Plan affects 3+ systems or crosses compliance boundaries

## Instructions

### Phase 1: Parallel Assessment (3 Independent Tracks)

Launch three subagent reviews independently. Each agent reviews the same artifact without knowledge of the others' findings.

**Track A — Quality Review (Reviewer)**
```
#runSubagent reviewer "
TRILATERAL REVIEW — Track A: Quality Assessment

Artifact to review:
{paste or reference the artifact}

Review independently for:
1. Correctness — logic errors, edge cases, off-by-one errors
2. Completeness — missing requirements, unaddressed constraints
3. Test coverage — are acceptance criteria testable and tested?
4. Style compliance — repo conventions, naming, structure
5. Documentation — are changes documented, migration notes included?

Tag findings: BLOCKER, MAJOR, MINOR, NIT
Provide a quality score: 0-100
State your confidence level: LOW, MEDIUM, HIGH
"
```

**Track B — Adversarial Challenge (Red Team)**
```
#runSubagent red-team "
TRILATERAL REVIEW — Track B: Adversarial Assessment

Artifact to review:
{paste or reference the artifact}

Challenge this artifact through adversarial lenses:
1. The Skeptic — What relies on survivorship bias or small sample size? Show the graveyard.
2. The Victim — Who is harmed by this? What negative externalities exist?
3. The Historian — Does this assume current conditions continue forever? What about mean reversion?
4. The Cynic — What hidden incentives or ego-driven decisions are embedded?
5. The Entropy — What will rot first? (Incentive rot, complexity rot, tech obsolescence)

For each lens, provide one concrete objection with evidence.
Identify the single most dangerous flaw (The Kill Shot).
Define the Kill Switch: specific condition where we must abandon this approach.
Provide a robustness score: 0-100
State your confidence level: LOW, MEDIUM, HIGH
"
```

**Track C — Security & Compliance (Security)**
```
#runSubagent security "
TRILATERAL REVIEW — Track C: Security & Compliance Assessment

Artifact to review:
{paste or reference the artifact}

Evaluate for:
1. STRIDE threat model — Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation
2. Credential/secret handling — any hardcoded values, insecure storage, weak auth
3. Input validation — injection vectors, boundary conditions
4. Compliance gates — privacy review needed? Deployment approval required?
5. Supply chain — new dependencies, known CVEs, trust boundaries

Tag findings: BLOCKER, MAJOR, MINOR, NIT
Provide a security score: 0-100
State your confidence level: LOW, MEDIUM, HIGH
"
```

### Phase 2: Consensus Synthesis

After all three tracks complete, the conductor synthesizes results:

#### Consensus Scoring

| Agreement Level | Interpretation | Action |
|-----------------|---------------|--------|
| **3/3 Agree** on a finding | High-confidence blind spot confirmed | Address before proceeding — this is real |
| **2/3 Agree** on a finding | Moderate confidence | Investigate further, may be real |
| **1/3 Flags** a unique finding | Low confidence (possible false positive) | Note but do not block on it |
| **3/3 No Issues** | High confidence the artifact is sound | Proceed with standard approval |

#### Composite Score

Calculate the composite score as a weighted average:
- Quality Score (Track A): **40%** weight
- Robustness Score (Track B): **30%** weight
- Security Score (Track C): **30%** weight

**Confidence cap:** If any track reports LOW confidence, the composite score is capped at 60/100 regardless of individual scores.

## Output Format

```markdown
## Trilateral Review — Consensus Report

**Artifact:** {name/path of reviewed artifact}
**Date:** {YYYY-MM-DD}

### Composite Score: {XX}/100 (Confidence: {LOW|MEDIUM|HIGH})

| Track | Agent | Score | Confidence | Key Finding |
|-------|-------|-------|-----------|-------------|
| A — Quality | Reviewer | {XX}/100 | {level} | {one-line summary} |
| B — Adversarial | Red Team | {XX}/100 | {level} | {one-line summary} |
| C — Security | Security | {XX}/100 | {level} | {one-line summary} |

### Consensus Findings (2/3+ Agreement)
{List findings where 2 or more tracks independently identified the same issue}

### Track-Specific Findings
{Unique findings from each track, noted but not blocking}

### The Kill Shot
{The single most dangerous flaw identified across all tracks}

### Kill Switch
{Specific condition that should trigger abandoning this approach}

### Verdict: {APPROVED | CHANGES_REQUIRED | REJECTED}

### Recommended Actions
1. {Highest priority action}
2. {Second priority}
3. {Third priority}
```

## Validation Checklist

- ✅ All three tracks were run independently (not sequentially informed by each other)
- ✅ Each track includes severity-tagged findings and a numerical score
- ✅ Consensus findings identify agreements across 2+ tracks
- ✅ Composite score applies the 40/30/30 weighting correctly
- ✅ Confidence cap is applied if any track reported LOW confidence
- ✅ Kill Shot and Kill Switch are explicitly stated
- ✅ Verdict is clear and actionable
- ✅ Report is saved to `artifacts/reviews/{date}-{feature}-trilateral.md`
