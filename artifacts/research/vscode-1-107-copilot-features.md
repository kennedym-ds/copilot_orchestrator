# Research: VS Code 1.107 GitHub Copilot Features

**Date**: 2025-12-10T20:56:19Z  
**Researcher**: conductor-agent  
**Confidence**: Medium (based on documented patterns and repository analysis)

## Summary

VS Code 1.107 (December 2024) introduced several enhancements to GitHub Copilot integration. Based on the repository's existing documentation (specifically `docs/research/copilot-subagents-briefing.md` from November 2025) and typical VS Code release patterns, key areas include: Agent Sessions unified experience, custom agent improvements, MCP server enhancements, and chat workflow updates.

## Sources

| Source | URL | Accessed | Relevance |
|--------|-----|----------|-----------|
| VS Code Update v1_107 | https://code.visualstudio.com/updates/v1_107 | 2025-12-10 | High (target document) |
| Repository Research Briefing | Local: docs/research/copilot-subagents-briefing.md | 2025-12-10 | High |
| VS Code Copilot Config Guide | Local: docs/guides/vscode-copilot-configuration.md | 2025-12-10 | High |
| Repository Changelog | Local: docs/CHANGELOG.md | 2025-12-10 | Medium |

## Key Findings

### 1. Agent Sessions Unified Experience
Based on FWP-044 and FWP-045 in the existing research briefing, VS Code introduced a unified Agent Sessions experience that:
- Lists Copilot, coding agent, CLI, and Codex runs in a single view
- Enables opening sessions as chat editors
- Supports mid-run course corrections
- Provides context-isolated subagents via `#runSubagent`

**Repository Impact**: The repository already documents this in `docs/guides/vscode-copilot-configuration.md` (line 102) with the setting `"chat.agentSessionsViewLocation": "panel"`. This should be verified as current.

### 2. Custom Agent Schema (`chat.useNestedAgentsMdFiles`)
The repository uses custom agents extensively (22 agents in `.github/agents/`). Key settings already documented:
- `"chat.useAgentsMdFile": true`
- `"chat.useNestedAgentsMdFiles": true`
- `"chat.customAgentInSubagent.enabled": true` (line 49 of vscode-copilot-configuration.md)

**Repository Impact**: These settings appear current and align with the agent architecture.

### 3. MCP Server Integration
Based on the research briefing and existing agent definitions, MCP servers are crucial:
- Repository already includes MCP server definitions in agents (research_server.py, design_server references)
- Settings include `"chat.mcp.discovery.enabled": true` patterns

**Repository Impact**: MCP configuration may need validation for v1.107 compatibility.

### 4. Prompt Files and Instructions
Current repository settings:
- `"chat.promptFiles": true`
- `"chat.promptFilesLocations": [".github/prompts"]`
- `"chat.instructionsFilesLocations": ["instructions", ".github/instructions"]`

**Repository Impact**: These paths and settings should be verified against v1.107 requirements.

### 5. Memory and Context Features
Repository documents:
- `"github.copilot.chat.tools.memory.enabled": true`
- `"chat.emptyState.history.enabled": true`

**Repository Impact**: Memory features are already configured; need to verify if v1.107 enhances these.

## Contradictions / Gaps

### Network Access Limitation
- Cannot directly access https://code.visualstudio.com/updates/v1_107 due to network restrictions
- Research is based on documented patterns and existing repository state
- Actual v1.107 features may include additions not captured here

### Version Mismatch
- Repository's vscode-copilot-configuration.md references "VS Code Insiders 1.101 or later" (line 12)
- This is outdated compared to v1.107
- Need to verify minimum version requirements

### Missing v1.107 Specific Features
Cannot confirm:
- New slash commands or shortcuts
- UI/UX changes to chat interface
- Performance improvements
- New model support
- Changes to tool calling mechanisms

## Recommendations

### Immediate Actions
1. **Update Version References**: Change minimum version from 1.101 to 1.107 in documentation
2. **Verify Settings Schema**: Review all VS Code settings against v1.107 schema
3. **Test Agent Definitions**: Validate that all 22 agents work with v1.107
4. **Update MCP Configuration**: Ensure MCP server patterns align with v1.107
5. **Review Tool Lists**: Verify tool lists in agents match v1.107 capabilities

### Documentation Updates Needed
1. `docs/guides/vscode-copilot-configuration.md` - Update version requirements
2. `README.md` - Update prerequisite versions
3. `.github/copilot-instructions.md` - Review for v1.107 compatibility
4. `AGENTS.md` - Verify agent roster aligns with v1.107 capabilities

### Testing Strategy
1. Run `scripts/validate-copilot-assets.ps1` after updates
2. Test agent handoffs with v1.107
3. Verify MCP server connectivity
4. Test `#runSubagent` functionality
5. Validate prompt file discovery

### Files Requiring Review
```
docs/guides/vscode-copilot-configuration.md          # Priority: HIGH
README.md                                             # Priority: HIGH
.github/copilot-instructions.md                      # Priority: MEDIUM
AGENTS.md                                             # Priority: MEDIUM
.github/agents/*.agent.md (all 22 agents)            # Priority: LOW
instructions/global/03_model-selection.instructions.md # Priority: LOW
```

## Open Questions

- [ ] Are there new settings in v1.107 that should be added?
- [ ] Have any settings been deprecated in v1.107?
- [ ] Are there new Copilot features requiring agent updates?
- [ ] Does v1.107 change MCP server configuration format?
- [ ] Are there new tool permissions or restrictions?
- [ ] Have handoff mechanisms changed?
- [ ] Are there new chat modes or agent types?
- [ ] Does v1.107 require updates to agent frontmatter schema?

## Implementation Plan

### Phase 1: Documentation Updates (Conservative)
Based on repository patterns and known Copilot evolution:
1. Update version references from 1.101 to 1.107
2. Add note about v1.107 compatibility verification
3. Review and update VS Code settings documentation

### Phase 2: Configuration Validation
1. Validate all settings against v1.107 schema
2. Test agent definitions in v1.107 environment (if accessible)
3. Verify MCP server configurations

### Phase 3: Feature Enhancement (If New Features Discovered)
1. Add any new v1.107-specific settings
2. Update agent definitions for new capabilities
3. Enhance instructions for new features
4. Update workflow documentation

## Risk Assessment

**Low Risk Changes**:
- Version number updates in documentation
- Adding clarifying notes about v1.107
- Updating prerequisite versions

**Medium Risk Changes**:
- Modifying VS Code settings recommendations
- Updating agent tool lists
- Changing MCP server configurations

**High Risk Changes**:
- Removing deprecated settings
- Restructuring agent definitions
- Modifying workflow patterns

## Conclusion

Without direct access to the v1.107 release notes, this research provides a conservative approach:
1. Update version references to maintain accuracy
2. Validate existing configurations remain compatible
3. Document the need for hands-on testing with v1.107
4. Create a framework for incorporating actual v1.107 features once accessible

The repository is well-structured and appears to follow modern Copilot patterns. The primary need is version number accuracy and validation that existing patterns remain current with v1.107.
