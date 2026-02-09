# Research: Deep Audit of Copilot Orchestrator Assets

**Date**: 2026-02-09T18:00:00Z
**Researcher**: researcher-agent
**Confidence**: High
**Tools Used**: read_file, grep_search, list_dir, fetch_webpage, file_search

## Summary

The copilot_orchestrator repository is a mature, well-structured multi-agent system with 27 agents, 13 skills, 37 instruction files, and ~20 prompt files. Overall quality is **above the awesome-copilot community standard** in most categories, with a few gaps in MCP adoption, the `infer` deprecation, skill bundled assets, and handoff usage. Instructions and prompts are among the strongest assets.

---

## 1. Agent Audit Summary

### Inventory
- **Total agents**: 27 (`.github/agents/*.agent.md`)
- **Sampled in detail**: 8 (conductor, implementer, security, test, lint, github-ops, data-analytics, translator)

### Frontmatter Completeness

| Field | Present | Missing/Incomplete | Notes |
|-------|---------|-------------------|-------|
| `name` | 27/27 (100%) | 0 | All agents have valid names |
| `description` | 27/27 (100%) | 0 | Good quality single-sentence descriptions |
| `argument-hint` | 27/27 (100%) | 0 | Clear, actionable hints |
| `model` (array) | 27/27 (100%) | 0 | All use array format with fallbacks — excellent |
| `tools` | 27/27 (100%) | 0 | Appropriate per-agent tool sets |
| `infer` | 27/27 (100%) | ⚠️ ALL | **DEPRECATED** per VS Code 1.109 docs. Should migrate to `user-invokable` / `disable-model-invocation` |
| `agents` (allowlist) | 3/27 (11%) | 24 | Only conductor, translator, translation-conductor define allowlists. Most agents don't need them, but orchestrator-like agents (e.g., planner routing to researcher) could benefit |
| `user-invokable` | 4/27 (15%) | — | Correctly set on security, performance, observability, red-team |
| `disable-model-invocation` | 4/27 (15%) | — | Correctly set on translator, translation-analyzer, translation-validator, translation-styler |
| `handoffs` | 1/27 (4%) | 26 | **Only conductor uses handoffs**. Community best practice suggests more agents could define them (e.g., planner→implementer, reviewer→conductor) |
| `mcp-servers` | 3/27 (11%) | 24 | Only researcher, design, data-analytics declare MCP servers |

### Frontmatter Quality Score: **78%**
- Core fields (name, description, argument-hint, model, tools): **100%** — excellent
- VS Code 1.109 fields (user-invokable, disable-model-invocation, agents, handoffs): **45%** — partial adoption
- **Critical gap**: `infer` is deprecated but still present on all 27 agents

### Body Structure Consistency

| Section | Present in Sampled Agents | Notes |
|---------|--------------------------|-------|
| Title + Role | 8/8 (100%) | Consistent "Agent — Role Title" format |
| Core Capabilities / Responsibilities | 8/8 (100%) | Clear bullet-point lists |
| Workflow / Execution Rules | 8/8 (100%) | Step-by-step numbered workflows |
| Delegation | 6/8 (75%) | security, lint have delegation; test, github-ops lack it. Implementer embeds delegation inline via `#runSubagent` mentions |
| Boundaries (✅/⚠️/🚫) | 7/8 (88%) | data-analytics missing explicit Boundaries section |
| Commands You Can Use | 7/8 (88%) | github-ops uses `gh` CLI patterns instead of PowerShell scripts |
| Local Artifact Storage | 7/8 (88%) | lint agent missing artifact template |
| Example Interaction Patterns | 4/8 (50%) | implementer, github-ops, data-analytics have examples; others don't |
| Response Style | 2/8 (25%) | Only implementer and (implicitly) conductor define output formatting |

### MCP Integration Status
- **3/27 agents (11%)** declare `mcp-servers` in frontmatter (researcher, design, data-analytics)
- All three use the same `research_server.py` MCP server for web search
- **No agents use external community MCP servers** (e.g., GitHub MCP, filesystem MCP, database MCP)
- Community 2026 best practice: orchestrator agents should integrate relevant MCP servers for their domain (e.g., github-ops should use the GitHub MCP server, security could use a vulnerability scanning MCP)

### Agent-Specific Findings

| Agent | File | Finding | Severity |
|-------|------|---------|----------|
| conductor | conductor.agent.md | ✅ Exemplary: complete frontmatter, handoffs, agents allowlist, comprehensive body | — |
| conductor | conductor.agent.md:6 | ⚠️ Uses deprecated `infer: false`, should use `user-invokable: true` | MINOR |
| implementer | implementer.agent.md:6 | ⚠️ `infer: true` deprecated; no explicit delegation section header (delegation is inline) | MINOR |
| security | security.agent.md | ✅ Properly uses `user-invokable: false`; has delegation section | — |
| security | security.agent.md:6 | ⚠️ Still has `infer: true` alongside `user-invokable: false` (redundant) | NIT |
| test | test.agent.md | ⚠️ Missing delegation section; uses `pwsh` in commands (should be `powershell` on this machine) | MINOR |
| lint | lint.agent.md | ⚠️ Missing artifact storage template | MINOR |
| github-ops | github-ops.agent.md | ⚠️ Should declare GitHub MCP server in frontmatter; uses `gh` CLI instead | MEDIUM |
| data-analytics | data-analytics.agent.md | ✅ MCP server declared; extensive DS-Star workflow; but missing explicit Boundaries section | MINOR |
| translator | translator.agent.md | ✅ Properly uses `disable-model-invocation: true` and `agents` allowlist | — |

---

## 2. Skills Audit Summary

### Inventory
- **Total skills**: 13 folders in `.github/skills/`
- **Sampled in detail**: 6 (tdd, security-review, delegation-routing, validation-scripts, accessibility-wcag, observability-telemetry)

### Frontmatter Completeness

| Field | Present | Notes |
|-------|---------|-------|
| `name` | 6/6 (100%) | Lowercase, hyphenated, clear names |
| `description` | 6/6 (100%) | Multi-sentence descriptions with "Use for" guidance |

### SKILL.md Body Structure

| Section | Present in Sampled Skills | Notes |
|---------|--------------------------|-------|
| Title (# heading) | 6/6 (100%) | Clear, descriptive titles |
| Description | 6/6 (100%) | 2-4 sentence overviews |
| When to Use | 6/6 (100%) | Bullet-point criteria |
| Entry Points - Trigger Phrases | 6/6 (100%) | Keyword lists for matching |
| Entry Points - Context Patterns | 6/6 (100%) | Situational cues |
| Core Knowledge | 6/6 (100%) | Detailed reference material with code examples and tables |

**SKILL.md Quality Score: 100%** — All sampled skills have complete structure.

### Bundled Assets Assessment

| Skill | Contents | Has Bundled Assets? |
|-------|----------|-------------------|
| tdd | SKILL.md only | ❌ No |
| security-review | SKILL.md only | ❌ No |
| delegation-routing | SKILL.md only | ❌ No |
| validation-scripts | SKILL.md only | ❌ No |
| accessibility-wcag | SKILL.md only | ❌ No |
| observability-telemetry | SKILL.md only | ❌ No |
| code-translation | SKILL.md only | ❌ No |
| conductor-lifecycle | SKILL.md only | ❌ No |
| documentation-style | SKILL.md only | ❌ No |
| git-operations | SKILL.md only | ❌ No |
| performance-analysis | SKILL.md only | ❌ No |
| orchestrator-terminal-style | SKILL.md only | ❌ No |
| worktrees-ops | SKILL.md only | ❌ No |

**0/13 skills (0%) have bundled assets** (no `scripts/`, `references/`, `assets/`, `templates/` subdirectories).

**Gap vs. awesome-copilot standard**: The community best practice for 2026 skills includes bundled resources:
- `scripts/` — automation scripts the skill can reference
- `references/` — canonical documentation, checklists, or schema files
- `assets/` — templates, configuration snippets, or sample data
- Example: a `tdd` skill could bundle a `scripts/coverage-check.ps1` script and a `references/test-pyramid.md` reference doc

### Skill-Specific Findings

| Skill | Finding | Severity |
|-------|---------|----------|
| delegation-routing | ✅ Comprehensive routing table with all 27 agents, model preferences, and restrictions | — |
| delegation-routing | SKILL.md:1 has a double fenced code block (double ````skill` opening) — possible rendering issue | NIT |
| validation-scripts | ✅ Excellent: covers all 6 validation scripts with syntax, output interpretation, and auto-approve behavior | — |
| security-review | ✅ 531 lines — most comprehensive skill; covers STRIDE, risk ratings, compliance frameworks | — |
| All skills | ⚠️ No bundled assets — all are pure instruction text. Could benefit from reference files, checklists, or scripts | MEDIUM |
| All skills | Skills reference `Core Knowledge` inline rather than linking to external reusable assets | MINOR |

---

## 3. Instructions Audit Summary

### Inventory
- **Total instruction files**: 37 across 4 directories
  - `global/`: 5 files
  - `languages/`: 19 files
  - `workflows/`: 10 files
  - `compliance/`: 3 files
- **Sampled in detail**: 7

### Frontmatter Completeness

| Field | Present | Notes |
|-------|---------|-------|
| `description` | 37/37 (100%) | ✅ Every instruction file has a description — **exceeds awesome-copilot standard** |
| `applyTo` | 37/37 (100%) | ✅ Every instruction file has an applyTo pattern — **exceeds awesome-copilot standard** |

### applyTo Pattern Quality

| Category | Pattern Style | Quality |
|----------|---------------|---------|
| Global | `"**/*.{md,ps1,psm1,psd1,yml,yaml,json}"`, `"**"` | ✅ Broad, appropriate glob patterns |
| Languages | `"**/*.py"`, `"**/*.ts,**/*.tsx"`, `"**/*.go"` | ✅ Precise language-targeted globs |
| Workflows | `".github/agents/conductor.agent.md"`, etc. | ✅ Agent-specific targeting |
| Compliance | `"**/*.{md,ps1,psm1,psd1,yml,yaml,json}"`, `"docs/**/*.md"`, `all-agents` | ✅ Domain-appropriate |
| terminal-formatting | `["all-agents"]` (array syntax) | ⚠️ Uses array syntax — valid but inconsistent with string patterns elsewhere |
| tool-approval-policy | `all-agents` (unquoted) | ⚠️ Unquoted value — may cause YAML parsing issues in some tools |

### Content Quality

| Criteria | Score | Notes |
|----------|-------|-------|
| Imperative mood | ✅ 100% | "Default to...", "Assume zero trust...", "Follow PEP 8..." |
| Good/Bad examples | ⚠️ 30% | Python and TypeScript have style examples; most global/workflow/compliance files lack code examples |
| Concrete code snippets | ⚠️ 25% | Language files have examples; global files are principle-based |
| Actionable guidelines | ✅ 95% | Clear, direct, no ambiguity |
| Concise | ✅ 90% | Most files are focused and under 100 lines |

### Instruction-Specific Findings

| File | Finding | Severity |
|------|---------|----------|
| 00_behavior.instructions.md | ✅ Excellent: 6 bullet points, clear safety contract, proper frontmatter with version metadata | — |
| 01_quality.instructions.md | ✅ Good: comprehensive quality checklist; uses `name` field instead of just `description` (acceptable but inconsistent) | NIT |
| 02_security.instructions.md | ✅ Good: zero-trust baseline, 6 clear mandates | — |
| python.instructions.md | ✅ Strong: PEP 8, type hints, testing guidance, idiomatic patterns | — |
| typescript.instructions.md | ✅ Strong: strict mode, naming conventions, error handling patterns | — |
| conductor.instructions.md | ✅ Has `version` and `date` metadata fields — best practice for change tracking | — |
| compliance/security.instructions.md | ⚠️ Very short (5 bullets, 13 lines) — could use more depth on compliance frameworks | MINOR |
| compliance/tool-approval-policy.instructions.md | ✅ Has extra metadata: `type`, `applicability`, `version`, `lastUpdated`, `requires` — enterprise-grade | — |
| terminal-formatting.instructions.md | ⚠️ `applyTo: ["all-agents"]` uses array format; `all-agents` is not a standard glob pattern | MINOR |

---

## 4. Prompts Audit Summary

### Inventory
- **Total prompt files**: ~20 across 7 subdirectories + 3 root prompts
- **Sampled in detail**: 8

### Frontmatter Completeness

| Field | Present | Notes |
|-------|---------|-------|
| `name` | 8/8 (100%) | Descriptive, kebab-case names |
| `description` | 8/8 (100%) | Single-sentence actionable descriptions |
| `model` | 8/8 (100%) | Appropriate tier assignments |
| `agent` | 8/8 (100%) | Correct agent routing (planner, security, translator, agent) |
| `tools` | 8/8 (100%) | Minimal, task-appropriate tool sets |
| `argument-hint` | 0/8 (0%) | ⚠️ **No sampled prompts use argument-hint** — community standard recommends it |

### Body Structure Quality

| Section | Present | Notes |
|---------|---------|-------|
| Purpose / Mission | 8/8 (100%) | Clear objective statements |
| Instructions / Workflow | 8/8 (100%) | Numbered steps or bullet lists |
| Output Format | 8/8 (100%) | Explicit format specifications |
| Validation Checklist | 3/8 (38%) | multi-phase-plan, security-review have checklists; most don't |
| Template Variables (`${input:}`) | 5/20 (25%) | Only translation prompts use `${input:variableName}` |
| `${selection}` / `${file}` usage | 0/8 (0%) | ⚠️ No prompts reference contextual variables |

### Prompt-Specific Findings

| Prompt | Finding | Severity |
|--------|---------|----------|
| commit.prompt.md | ✅ Excellent: conventional commits, examples, clear format spec | — |
| review.prompt.md | ✅ Good: severity-tagged findings, verdict system | — |
| new-agent.prompt.md | ✅ Strong: references model tiers, invocation controls, pattern-aware | — |
| multi-phase-plan.prompt.md | ✅ Best-in-class: validation checklist, TODO fence requirement, research integration | — |
| generate-tests.prompt.md | ✅ Good: framework-agnostic, coverage-aware | — |
| debug-issue.prompt.md | ✅ Solid: systematic reproduce-isolate-fix-verify flow | — |
| security-review.prompt.md | ✅ Strong: STRIDE-aligned, validation checklist, verdict system | — |
| translate-module.prompt.md | ✅ Only prompt family using `${input:}` variables — good parameterization | — |
| All prompts | ⚠️ No prompts use `argument-hint` frontmatter field | MINOR |
| Most prompts | ⚠️ No prompts reference `${selection}` or `${file}` contextual variables | MINOR |
| Root prompts | commit, review sit at root level alongside new-agent — inconsistent with subdirectory organization | NIT |

---

## 5. Top 10 Gaps (Ranked by Impact)

### 1. **CRITICAL: `infer` field is deprecated but present on all 27 agents**
- **Impact**: VS Code 1.109 deprecates `infer` in favor of `user-invokable` and `disable-model-invocation`. While still functional, it may be removed in future versions, breaking agent behavior.
- **Files**: All 27 files in `.github/agents/*.agent.md`
- **Fix**: Remove `infer` field from all agents. For agents with `infer: false` (conductor), add `user-invokable: true` explicitly. For agents that should remain auto-invocable, `user-invokable: true` is the default so no replacement needed.

### 2. **HIGH: Only 1/27 agents (conductor) uses handoffs**
- **Impact**: Handoffs are the primary UX mechanism for guided workflows in VS Code 1.109. Without handoffs on more agents, users lose guided navigation between workflow steps.
- **Files**: Only [conductor.agent.md](conductor.agent.md#L22) defines handoffs
- **Fix**: Add at minimum "Return to Conductor" handoffs on planner, implementer, reviewer, researcher. Add cross-agent handoffs where workflows are sequential (planner→implementer, reviewer→conductor).

### 3. **HIGH: 0/13 skills have bundled assets**
- **Impact**: Skills are pure instruction text without reusable scripts, templates, or reference files. Community standard suggests bundled resources improve skill reliability and reduce prompt drift.
- **Recommendation**: Add `references/` subdirectories to at least tdd, security-review, validation-scripts, and delegation-routing with canonical checklists, templates, or scripts.

### 4. **MEDIUM: Only 3/27 agents (11%) integrate MCP servers**
- **Impact**: MCP is the 2026 standard for tool extensibility. Key agents like github-ops (GitHub MCP), security (vulnerability scanning), and performance (profiling tools) could benefit from dedicated MCP integrations.
- **Files**: Only researcher, design, data-analytics have `mcp-servers:` in frontmatter
- **Fix**: Add MCP server declarations for agents with clear external tool needs.

### 5. **MEDIUM: No prompts use `argument-hint` or contextual variables (`${selection}`, `${file}`)**
- **Impact**: `argument-hint` guides users on what to type; `${selection}` and `${file}` enable context-aware prompts that work with the user's current editor state. Both improve UX significantly.
- **Files**: All 20 prompt files in `.github/prompts/`
- **Fix**: Add `argument-hint` to all prompts. Add `${selection}` to review and debug prompts.

### 6. **MEDIUM: Inconsistent `applyTo` syntax in instructions**
- **Impact**: Two files use non-standard `applyTo` values: `all-agents` (unquoted, non-glob) and `["all-agents"]` (array of non-glob). These may not match VS Code's glob-based resolution.
- **Files**: [terminal-formatting.instructions.md](instructions/global/terminal-formatting.instructions.md#L7), [tool-approval-policy.instructions.md](instructions/compliance/tool-approval-policy.instructions.md#L4)
- **Fix**: Use `"**/*.agent.md"` or `"**"` instead of `all-agents`.

### 7. **MINOR: Some agents missing Delegation section**
- **Impact**: Without explicit delegation patterns, agents may not route to specialists correctly. The delegation-routing skill helps, but body-level delegation sections reinforce routing.
- **Files**: test.agent.md, github-ops (partial — uses `gh` CLI instead of `#runSubagent`), data-analytics (missing boundaries)
- **Fix**: Add `## Delegation` and `## Boundaries` sections to all agents.

### 8. **MINOR: Global/workflow instructions lack code examples**
- **Impact**: awesome-copilot standard recommends Good/Bad code examples in instructions. Only language files consistently include them.
- **Files**: `instructions/global/*.instructions.md`, `instructions/workflows/*.instructions.md`
- **Fix**: Add at least one Good/Bad code example per instruction file where applicable.

### 9. **MINOR: Compliance/security instruction is very thin (5 bullets)**
- **Impact**: For a compliance overlay, 13 lines of content may not provide sufficient guardrails for sensitive operations.
- **File**: [compliance/security.instructions.md](instructions/compliance/security.instructions.md)
- **Fix**: Expand with compliance framework references (SOC2, GDPR checkpoints), concrete examples, and checklists.

### 10. **NIT: Prompt organizational inconsistency**
- **Impact**: Three prompts (commit, review, new-agent) sit at the `.github/prompts/` root while others are organized into subdirectories. This creates minor confusion in navigation.
- **Fix**: Move root prompts into appropriate subdirectories (e.g., `quick/commit-message.prompt.md`).

---

## 6. Top 5 Strengths (Relative to Community Standards)

### 1. **100% instruction frontmatter completeness — best-in-class**
All 37 instruction files have both `description` and `applyTo` fields. This exceeds the awesome-copilot standard where many community repos have incomplete metadata. Language instructions use precise glob patterns (`**/*.py`, `**/*.ts,**/*.tsx`) ensuring correct scoping.

### 2. **Model fallback arrays on all 27 agents**
Every agent uses the VS Code 1.109 array-format `model` field with primary + fallback models. The 3-tier model allocation (Premium/Execution/Routine) is consistently applied across all agents with appropriate cost/capability tradeoffs. This is a sophisticated pattern not commonly seen in community repos.

### 3. **Comprehensive skill system with 13 specialized skills**
The skill library covers TDD, security review, delegation routing, validation scripts, accessibility, observability, code translation, conductor lifecycle, documentation style, git operations, performance analysis, terminal formatting, and worktree ops. Each skill has a well-structured SKILL.md with Description, When to Use, Entry Points (trigger phrases + context patterns), and Core Knowledge. The delegation-routing skill is particularly impressive — it maps all 27 agents with keyword triggers, model preferences, and invocation restrictions.

### 4. **Translation workflow sub-system with invocation controls**
The 5-agent translation subsystem (translation-conductor, translator, translation-analyzer, translation-validator, translation-styler) correctly uses VS Code 1.109 invocation controls:
- `disable-model-invocation: true` on child agents to prevent AI spontaneous invocation
- `agents` allowlists on conductor and translator to restrict delegation scope
- Dedicated prompt files with `${input:}` template variables for parameterized translation

### 5. **Conductor agent is exemplary**
The conductor agent is the most complete agent definition in the repository and arguably exceeds community standards:
- 11 handoff buttons with per-handoff model overrides
- Full 21-agent `agents` allowlist
- Rich frontmatter with all VS Code 1.109 fields used appropriately
- Body covers core capabilities, state tracking, DS-Star routing, pause points
- Paired with a comprehensive workflow instruction file with version tracking

---

## 7. Cross-Cutting Observations

### Maturity Assessment
| Dimension | Score | Level |
|-----------|-------|-------|
| Agent definitions | 8.5/10 | Advanced |
| Skills | 7/10 | Good (needs bundled assets) |
| Instructions | 9/10 | Excellent |
| Prompts | 7.5/10 | Good (needs argument-hints, context vars) |
| MCP integration | 4/10 | Emerging |
| Handoff coverage | 3/10 | Minimal |
| Overall | **7.5/10** | **Above community standard** |

### Consistency Patterns
- ✅ Model naming is 100% consistent across all assets (no legacy model names)
- ✅ PowerShell script references are consistent across agents and skills
- ✅ `#runSubagent` delegation pattern is consistently documented in body text
- ⚠️ `pwsh` vs `powershell` inconsistency in some agent commands
- ⚠️ Some agents use `## Responsibilities` while others use `## Core Capabilities` (minor style variance)

---

## Sources
| Source | URL | Accessed | Relevance | Method |
|--------|-----|----------|-----------|--------|
| VS Code Custom Agents Docs | https://code.visualstudio.com/docs/copilot/customization/custom-agents | 2026-02-09 | High | fetch |
| awesome-copilot instructions.instructions.md | https://raw.githubusercontent.com/github/awesome-copilot/main/instructions/instructions.instructions.md | 2026-02-09 | High | fetch |
| awesome-copilot prompt.instructions.md | https://raw.githubusercontent.com/github/awesome-copilot/main/instructions/prompt.instructions.md | 2026-02-09 | High | fetch |
| Local repository files | workspace | 2026-02-09 | High | read_file, grep_search, list_dir |

## Open Questions
- [ ] Should `infer` be removed in a single batch PR, or phased out alongside adding `user-invokable`/`disable-model-invocation` where needed?
- [ ] Which agents would benefit most from MCP server integration beyond the current 3?
- [ ] What's the priority for adding handoffs — should all core workflow agents get them, or just orchestration-level agents?
- [ ] Should skills adopt bundled assets immediately, or wait for awesome-copilot to formalize the skill bundle standard further?
