---
version: 1.0.0
description: "LLM-specific prompt formatting preferences for Claude (XML), OpenAI (JSON), and Gemini (conversational)."
effectiveDate: 2025-11-13
applyTo: "**/*.{md,agent.md}"
priority: 100
---

# LLM-Specific Format Preferences

Different language models have varying strengths and preferences for prompt structures. This guide helps agents format their prompts and responses optimally for each LLM provider.

## Model-Specific Formatting Guidelines

### Claude (Anthropic)

**Preferred Format:** XML-structured prompts and responses

**Strengths:**
- Excellent at parsing and generating XML
- Maintains clear semantic boundaries with tags
- Strong at following nested structure hierarchies

**Best Practices:**

```xml
<task>
  <objective>Primary goal of the task</objective>
  <context>
    <background>Relevant background information</background>
    <constraints>Any limitations or requirements</constraints>
  </context>
  <instructions>
    <step priority="1">First action to take</step>
    <step priority="2">Second action to take</step>
  </instructions>
  <output_format>
    <type>Expected output structure</type>
    <requirements>Quality criteria</requirements>
  </output_format>
</task>
```

**Response Format:**
```xml
<response>
  <analysis>Understanding of the task</analysis>
  <approach>Strategy for completion</approach>
  <implementation>
    <code language="python">
      # Code implementation
    </code>
  </implementation>
  <validation>Test results and verification</validation>
  <next_steps>Recommendations for follow-up</next_steps>
</response>
```

**When to Use:**
- Security reviews (structured threat analysis)
- Code refactoring (clear before/after sections)
- Documentation generation (semantic markup)
- Multi-phase planning (hierarchical breakdowns)

### OpenAI (GPT Models)

**Preferred Format:** JSON-structured prompts and responses

**Strengths:**
- Native JSON generation and parsing
- Function calling with structured schemas
- Consistent key-value pair handling
- Strong at maintaining data structure integrity

**Best Practices:**

```json
{
  "task": {
    "type": "code_generation",
    "objective": "Create a REST API endpoint",
    "requirements": {
      "language": "Python",
      "framework": "FastAPI",
      "authentication": "JWT",
      "testing": "pytest"
    },
    "constraints": {
      "max_lines": 100,
      "follow_style": "PEP8"
    }
  },
  "context": {
    "existing_code": "path/to/file.py",
    "related_files": ["auth.py", "models.py"],
    "dependencies": ["fastapi", "pydantic"]
  },
  "expected_output": {
    "format": "code_with_tests",
    "include": ["docstrings", "type_hints", "error_handling"]
  }
}
```

**Response Format:**
```json
{
  "status": "success",
  "implementation": {
    "file": "api/endpoints.py",
    "code": "...",
    "tests": "...",
    "documentation": "..."
  },
  "analysis": {
    "approach": "RESTful design with dependency injection",
    "trade_offs": ["Performance vs readability"],
    "alternatives_considered": ["GraphQL", "gRPC"]
  },
  "validation": {
    "tests_passed": true,
    "coverage": "95%",
    "lint_score": "10/10"
  },
  "next_steps": [
    "Add integration tests",
    "Update API documentation",
    "Review security implications"
  ]
}
```

**When to Use:**
- API design and implementation
- Data transformation tasks
- Structured code generation
- Test case creation
- Configuration management

### Gemini (Google)

**Preferred Format:** Conversational-style prompts with natural dialogue flow

**Strengths:**
- Excellent at multi-turn conversations
- Strong contextual understanding across exchanges
- Natural language reasoning
- Effective at clarifying ambiguities through dialogue

**Best Practices:**

```
Human: I need to implement a caching layer for our application. Here's what we're working with:

- Current setup: Python FastAPI backend
- Database: PostgreSQL with SQLAlchemy ORM
- Traffic pattern: Read-heavy (80% reads, 20% writes)
- Current bottleneck: Repeated database queries for user profiles

What approach would you recommend, and why?

Agent: Based on your requirements, I'd recommend Redis as a caching layer. Let me explain the reasoning:

**Why Redis:**
1. Performance: In-memory storage gives microsecond latency
2. Persistence options: Can survive restarts if needed
3. TTL support: Automatic cache invalidation
4. Python integration: Excellent libraries (redis-py, aioredis)

**Implementation Strategy:**

Step 1: Cache frequently accessed user profiles
- Cache key pattern: `user:profile:{user_id}`
- TTL: 3600 seconds (1 hour)
- Invalidate on profile updates

Step 2: Implement cache-aside pattern
- Check Redis first
- On miss, query PostgreSQL
- Store result in Redis for next request

Step 3: Handle write operations
- Update database first
- Invalidate or update cache
- Ensures data consistency

Would you like me to show you a concrete implementation, or do you have concerns about this approach?
```

**Response Format:**
- Natural, conversational tone
- Progressive disclosure of information
- Questions to clarify requirements
- Step-by-step explanations
- Interactive refinement of solutions

**When to Use:**
- Research and exploration tasks
- Requirements gathering
- Complex problem decomposition
- Architectural discussions
- Learning and onboarding scenarios
- Multi-perspective analysis

## Format Selection Matrix

### By Task Type

| Task Type | Recommended Format | Primary Model | Rationale |
|-----------|-------------------|---------------|-----------|
| Security Review | XML (Claude) | Claude Sonnet 4.5 | Structured threat taxonomy, clear severity levels |
| API Design | JSON (OpenAI) | GPT-5 | Native schema support, function definitions |
| Research | Conversational (Gemini) | Gemini 2.5 Pro | Multi-turn exploration, large context windows |
| Code Refactoring | XML (Claude) | Claude Sonnet 4.5 | Clear before/after sections, semantic markup |
| Test Generation | JSON (OpenAI) | GPT-4.1 | Structured test cases, assertions |
| Planning | Conversational (Gemini) | Gemini 2.5 Pro | Interactive refinement, stakeholder alignment |
| Documentation | XML (Claude) | Claude Haiku 4.5 | Semantic structure, consistent formatting |
| Data Transformation | JSON (OpenAI) | GPT-5 Mini | Schema validation, type safety |
| Performance Analysis | JSON (OpenAI) | GPT-5 | Metrics, benchmarks, structured results |
| Compliance Review | XML (Claude) | Claude Sonnet 4.5 | Regulatory requirements, audit trails |

### By Agent Role

| Agent | Primary Format | Secondary Format | Notes |
|-------|----------------|------------------|-------|
| Conductor | Conversational | XML | Dialogue for planning, XML for state tracking |
| Planner | Conversational | JSON | Interactive refinement, structured deliverables |
| Implementer | JSON | XML | Code generation (JSON), refactoring (XML) |
| Reviewer | XML | JSON | Structured findings (XML), metrics (JSON) |
| Researcher | Conversational | XML | Multi-turn exploration, structured synthesis |
| Security | XML | JSON | Threat models (XML), vulnerability reports (JSON) |
| Performance | JSON | Conversational | Metrics/benchmarks (JSON), analysis (conversational) |
| Docs | XML | Conversational | Semantic structure (XML), guides (conversational) |

## Hybrid Approaches

Some complex tasks benefit from combining formats:

### Example: Multi-Phase Implementation

**Phase 1 - Planning (Conversational with Gemini):**
```
Human: We need to migrate our monolith to microservices. What's your recommended approach?

Agent: Let's break this down step by step. First, I need to understand a few things:
1. What are the main bounded contexts in your current monolith?
2. Which teams will own the new services?
3. What's your timeline and risk tolerance?

[Interactive dialogue continues...]
```

**Phase 2 - Design Specification (JSON with OpenAI):**
```json
{
  "architecture": {
    "services": [
      {
        "name": "user-service",
        "bounded_context": "user_management",
        "apis": [...],
        "dependencies": [...]
      }
    ],
    "migration_strategy": "strangler_pattern",
    "phases": [...]
  }
}
```

**Phase 3 - Implementation Review (XML with Claude):**
```xml
<review>
  <service name="user-service">
    <findings>
      <finding severity="major">
        <issue>Missing circuit breaker for downstream calls</issue>
        <recommendation>Add Resilience4j circuit breaker</recommendation>
      </finding>
    </findings>
  </service>
</review>
```

## Agent Configuration

Agents should specify their format preferences in their `.agent.md` front matter:

```yaml
---
name: security
model: Claude Sonnet 4.5 (copilot)
preferred_formats:
  primary: xml
  secondary: json
  use_cases:
    - "Threat modeling with <threat> tags"
    - "Compliance checklists with <requirement> structure"
    - "Security review findings with severity attributes"
---
```

## Prompt Engineering by Format

### XML Prompts (Claude)

**Structure:**
- Use semantic tags that reflect domain concepts
- Leverage attributes for metadata (severity, priority, status)
- Nest hierarchically to show relationships
- Use CDATA for code blocks to avoid escaping issues

**Example:**
```xml
<code_review file="auth.py" language="python">
  <focus_areas>
    <area>Input validation</area>
    <area>Error handling</area>
    <area>Security vulnerabilities</area>
  </focus_areas>
  <code><![CDATA[
def authenticate_user(username, password):
    # code here
  ]]></code>
</code_review>
```

### JSON Prompts (OpenAI)

**Structure:**
- Follow JSON Schema conventions
- Use consistent key naming (snake_case recommended)
- Include type information inline
- Provide examples in schema

**Example:**
```json
{
  "task": "code_review",
  "input": {
    "file": "auth.py",
    "language": "python",
    "focus_areas": ["input_validation", "error_handling", "security"]
  },
  "schema": {
    "findings": {
      "type": "array",
      "items": {
        "severity": "string",
        "line": "number",
        "description": "string",
        "recommendation": "string"
      }
    }
  }
}
```

### Conversational Prompts (Gemini)

**Structure:**
- Start with clear context and objectives
- Ask clarifying questions upfront
- Build on previous exchanges
- Use natural language, avoid overly formal structure
- Encourage iterative refinement

**Example:**
```
I'm reviewing our authentication system and noticed some potential issues. 
Let me share the relevant code first, then I'd like your thoughts on:

1. Are we handling password storage securely?
2. Is our session management approach sound?
3. What edge cases might we be missing?

Here's the code:
[paste code]

What stands out to you?
```

## Format Conversion Guidelines

When an agent needs to convert between formats (e.g., Planner creates conversational plan, Implementer needs JSON spec):

### Conversational → JSON
```python
# Extract structured data from conversational context
# Focus on actionable items, requirements, constraints
# Map to JSON schema
```

### Conversational → XML  
```python
# Identify semantic relationships
# Map concepts to domain-specific tags
# Preserve hierarchy and context
```

### XML → JSON
```python
# Flatten nested structures where appropriate
# Convert attributes to key-value pairs
# Maintain semantic meaning
```

### JSON → XML
```python
# Expand flat structures into hierarchical tags
# Move metadata to attributes
# Add semantic wrapper elements
```

## Quality Assurance

When formatting prompts:

✅ **Do:**
- Match format to model strengths
- Provide clear examples
- Use consistent naming conventions
- Include metadata (version, date, author)
- Validate structure before sending

❌ **Don't:**
- Force incompatible formats (e.g., complex XML to GPT when JSON would work better)
- Mix formats within a single prompt without clear delimiters
- Assume model will convert formats automatically
- Omit schema definitions for structured data
- Use formats that obscure the core question

## Performance Considerations

### Token Efficiency by Format

| Format | Overhead | Best For | Token Multiplier |
|--------|----------|----------|------------------|
| JSON | Low | Structured data | 1.0x |
| XML | Medium | Semantic markup | 1.3x - 1.5x |
| Conversational | Variable | Natural dialogue | 1.2x - 2.0x |

**Optimization Tips:**
- Use abbreviated tag names in XML (e.g., `<req>` vs `<requirement>`)
- Minimize nesting depth when possible
- Compress repeated structures with references
- Use conversational format only when interactivity adds value

## Model-Specific Quirks

### Claude
- Prefers `<thinking>` tags for reasoning
- Strong at maintaining XML consistency across long contexts
- Benefits from explicit closing tags even when optional

### GPT Models
- Excellent at inferring JSON schema from examples
- Can handle partial JSON with `...` ellipsis
- Supports function calling for guaranteed JSON structure

### Gemini
- Excels at maintaining conversational context over many turns
- Can track multiple parallel conversation threads
- Benefits from explicit turn markers (Human:, Agent:)

## Migration Strategy

For existing prompts using generic formats:

1. **Audit current prompts:**
   - Identify task types and current formats
   - Map to recommended formats from matrix above

2. **Test with representative samples:**
   - Compare output quality between formats
   - Measure token usage and cost
   - Evaluate developer experience

3. **Gradual rollout:**
   - Start with new prompts using recommended formats
   - Migrate high-value existing prompts
   - Document lessons learned

4. **Monitor and iterate:**
   - Track quality metrics by format
   - Gather agent feedback
   - Refine guidelines based on results

## Related Documentation

- `instructions/global/03_model-selection.instructions.md` — Model allocation strategy
- `instructions/workflows/prompt-engineering.instructions.md` — General prompting best practices
- `docs/guides/agent-development.md` — Creating new agents with format preferences
- `AGENTS.md` — Overall architecture and agent responsibilities

---

**Revision History:**
- v1.0.0 (2025-11-13): Initial version with Claude XML, OpenAI JSON, Gemini conversational formats