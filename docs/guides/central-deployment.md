# Central Deployment Guide

> **Updated for VS Code 1.109**: Now supports native organization-level agent sharing without manual repository setup.

This guide explains how to deploy the Copilot Orchestrator agents centrally at the organization level while having agents create local `artifacts/` folders in each consuming repository.

## Architecture Overview

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    Organization Level                        â”‚
â”‚  .github-private repository (or .github)                    â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚  â”‚  agents/                                                â”‚ â”‚
â”‚  â”‚  â”œâ”€â”€ conductor.agent.md                                â”‚ â”‚
â”‚  â”‚  â”œâ”€â”€ planner.agent.md                                  â”‚ â”‚
â”‚  â”‚  â”œâ”€â”€ implementer.agent.md                              â”‚ â”‚
â”‚  â”‚  â”œâ”€â”€ reviewer.agent.md                                 â”‚ â”‚
â”‚  â”‚  â””â”€â”€ ... (all 27 agents)                              â”‚ â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                              â”‚
              â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
              â–¼               â–¼               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   Repo A        â”‚  â”‚   Repo B        â”‚  â”‚   Repo C        â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚artifacts/ â”‚  â”‚  â”‚  â”‚artifacts/ â”‚  â”‚  â”‚  â”‚artifacts/ â”‚  â”‚
â”‚  â”‚â”œâ”€â”€ plans/ â”‚  â”‚  â”‚  â”‚â”œâ”€â”€ plans/ â”‚  â”‚  â”‚  â”‚â”œâ”€â”€ plans/ â”‚  â”‚
â”‚  â”‚â”œâ”€â”€ reviewsâ”‚  â”‚  â”‚  â”‚â”œâ”€â”€ reviewsâ”‚  â”‚  â”‚  â”‚â”œâ”€â”€ reviewsâ”‚  â”‚
â”‚  â”‚â””â”€â”€ ...    â”‚  â”‚  â”‚  â”‚â””â”€â”€ ...    â”‚  â”‚  â”‚  â”‚â””â”€â”€ ...    â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## Deployment Methods

VS Code 1.109+ offers **two deployment methods**:

### Method 1: Native Organization Sharing (Recommended - VS Code 1.109+)

**Pros:**
- Zero configuration in consuming repositories
- Agents automatically available to all org members
- Updates propagate instantly
- No manual synchronization needed

**Cons:**
- Requires VS Code 1.107 or later
- Currently experimental (will be GA soon)
- Requires GitHub organization Copilot subscription

**Setup:** See [Method 1 Instructions](#method-1-native-organization-sharing) below.

### Method 2: GitHub Repository Sharing (Legacy)

**Pros:**
- Works with all VS Code versions
- More control over distribution
- Can version agents separately

**Cons:**
- Requires manual repository setup
- Users must clone/sync agent files
- Updates require repository pulls

**Setup:** See [Method 2 Instructions](#method-2-github-repository-sharing) below.

---

## Method 1: Native Organization Sharing

> **Requirements:** VS Code 1.109+, GitHub organization with Copilot

### 1. Enable Organization Agent Sharing

Organization administrators configure this at the GitHub organization level:

1. Navigate to `https://github.com/organizations/YOUR_ORG/settings/copilot`
2. Enable **"Custom Agents"** feature
3. Upload your agent definitions to the organization

**GitHub CLI method:**

```bash
# Upload agents to your org (requires org admin access)
gh api /orgs/YOUR_ORG/copilot/agents \
  -F name=conductor \
  -F description="Orchestrates multi-phase workflows" \
  -F definition=@.github/agents/conductor.agent.md

# Repeat for all 27 agents
```

### 2. Users Enable Organization Agents

Each developer adds to their VS Code `settings.json`:

```json
{
  "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
  "chat.customAgentInSubagent.enabled": true
}
```

### 3. Agents Automatically Available

- All 27 agents appear in the Agents dropdown
- No repository-specific setup required
- Updates pushed at org level propagate instantly
- Users can still define personal agents locally

### 4. Initialize Artifacts (Per Repository)

Agents will auto-create `artifacts/` folders, but you can pre-initialize:

```powershell
# Option A: Download and run init script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_ORG/.github-private/main/scripts/init-artifacts.ps1" -OutFile "init-artifacts.ps1"
pwsh -File init-artifacts.ps1

# Option B: Use this repository's script directly
pwsh -File path/to/copilot_orchestrator/scripts/init-artifacts.ps1
```

---

## Method 2: GitHub Repository Sharing

### 1. Create Organization-Level Agent Repository

GitHub Copilot looks for org-level agents in a special `.github-private` repository (for private agents) or `.github` repository (for public agents).

```bash
# Create the org-level repo
gh repo create YOUR_ORG/.github-private --private

# Clone and set up
git clone https://github.com/YOUR_ORG/.github-private
cd .github-private
```

### 2. Copy Agents to Organization Repository

Copy the agents directory to the org-level repo:

```bash
# From your copilot_orchestrator checkout
mkdir -p agents
cp -r .github/agents/* agents/
```

The structure should be:
```
.github-private/
â””â”€â”€ agents/
    â”œâ”€â”€ conductor.agent.md
    â”œâ”€â”€ planner.agent.md
    â”œâ”€â”€ implementer.agent.md
    â”œâ”€â”€ reviewer.agent.md
    â”œâ”€â”€ researcher.agent.md
    â”œâ”€â”€ security.agent.md
    â”œâ”€â”€ performance.agent.md
    â”œâ”€â”€ maintainer.agent.md
    â”œâ”€â”€ visualizer.agent.md
    â”œâ”€â”€ accessibility.agent.md
    â”œâ”€â”€ data-analytics.agent.md
    â”œâ”€â”€ docs.agent.md
    â”œâ”€â”€ observability.agent.md
    â”œâ”€â”€ deployment.agent.md
    â”œâ”€â”€ red-team.agent.md
    â”œâ”€â”€ terraform.agent.md
    â”œâ”€â”€ bicep.agent.md
    â”œâ”€â”€ beast-mode.agent.md
    â”œâ”€â”€ test.agent.md
    â”œâ”€â”€ lint.agent.md
    â””â”€â”€ github-ops.agent.md
```

### 3. Include the Init Script

Copy the artifacts initialization script:

```bash
mkdir -p scripts
cp scripts/init-artifacts.ps1 scripts/
```

### For Method 1 (Native Organization Sharing)

```json
{
  "chat.useAgentsMdFile": true,
  "chat.useNestedAgentsMdFiles": true,
  "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
  "chat.customAgentInSubagent.enabled": true,
  "github.copilot.chat.cli.customAgents.enabled": true,
  "chat.useClaudeSkills": true,
  "chat.thinking.style": "collapsed",
  "chat.agent.thinking.collapsedTools": true,
  "chat.viewSessions.enabled": true,
  "chat.viewSessions.orientation": "sideBySide",
  "github.copilot.chat.copilotMemory.enabled": true
}
```

### For Method 2 (GitHub Repository Sharing)

```json
{
  "chat.useAgentsMdFile": true,
  "chat.useNestedAgentsMdFiles": true,
  "github.copilot.chat.copilotMemory.enabled": true,
  "chat.customAgentInSubagent.enabled": true,
  "chat.thinking.style": "collapsed",
  "chat.agent.thinking.collapsedToolseate the `artifacts/` folder when they start working. No setup required in consuming repos.

#### Option B: Pre-Initialize

Run the initialization script manually:

```powershell
# From the consuming repository root
pwsh -File path/to/init-artifacts.ps1
```

Or add to your repo's setup:

```powershell
# In your repo's setup script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_ORG/.github-private/main/scripts/init-artifacts.ps1" -OutFile "init-artifacts.ps1"
pwsh -File init-artifacts.ps1
Remove-Item init-artifacts.ps1
```

## How It Works

### Agent Behavior

When an agent (conductor, planner, reviewer, etc.) is invoked in any repository:

1. **Detection**: Agent checks if `artifacts/` folder exists
2. **Initialization**: If missing, creates the standard structure:
   ```
   artifacts/
   â”œâ”€â”€ plans/          # Planner, Implementer, Conductor
   â”œâ”€â”€ reviews/        # Reviewer
   â”œâ”€â”€ research/       # Researcher
   â”œâ”€â”€ security/       # Security
   â”œâ”€â”€ sessions/       # Conductor (session state)
   â”œâ”€â”€ performance/    # Performance
   â”œâ”€â”€ docs/           # Docs
   â”œâ”€â”€ releases/       # Maintainer
   â”œâ”€â”€ telemetry/      # Observability
   â”œâ”€â”€ deployments/    # Deployment
   â”œâ”€â”€ red-team/       # Red Team
   â”œâ”€â”€ accessibility/  # Accessibility
   â”œâ”€â”€ tests/          # Test
   â”œâ”€â”€ ux/             # Visualizer
   â”œâ”€â”€ README.md
   â””â”€â”€ .gitignore
   ```
3. **Persistence**: All session outputs are written to the local artifacts folder
4. **Continuity**: Session state in `sessions/` enables resume after interruption

### Artifact Types

| Agent | Artifact Location | Content |
|-------|------------------|---------|
| Conductor | `artifacts/sessions/` | Session state, phase tracking |
| Planner | `artifacts/plans/{feature}/` | Plans, phase completions |
| Implementer | `artifacts/plans/{feature}/` | Phase completion records |
| Reviewer | `artifacts/reviews/` | Review verdicts, findings |
| Researcher | `artifacts/research/` | Research briefs, citations |
| Security | `artifacts/security/` | Audit reports, threat assessments |
| Performance | `artifacts/performance/` | Performance analysis reports |
| Docs | `artifacts/docs/` | Documentation drafts |
| Maintainer | `artifacts/releases/` | Release notes, triage reports |
| Observability | `artifacts/telemetry/` | Metrics and telemetry analysis |
| Deployment | `artifacts/deployments/` | Deployment plans |
| Red Team | `artifacts/red-team/` | Adversarial analysis |
| Accessibility | `artifacts/accessibility/` | WCAG audits |
| Test | `artifacts/tests/` | Test reports, coverage |
| Visualizer | `artifacts/ux/` | UX reviews, design artifacts |

### Git Integration

The `.gitignore` in `artifacts/` excludes session state files (which may contain sensitive context) but preserves:

- Plans and phase completions
- RComparison Matrix

| Feature | Method 1 (Native) | Method 2 (GitHub Repo) |
|---------|-------------------|------------------------|
| **VS Code Version** | 1.109+ required | Any version |
| **Setup Complexity** | Low (org admin only) | Medium (per-repo) |
| **User Configuration** | 1 setting | Manual clone/sync |
| **Update Propagation** | Instant | Manual pull required |
| **Access Control** | Org-level | Repository-based |
| **Offline Support** | No | Yes (if cloned) |
| **Custom Per-Repo** | Yes (local overrides) | Yes |
| **Background Agents** | âœ… Supported | âš ï¸ Requires extra setup |
| **Claude Skills** | âœ… Supported | âŒ Not available |

## Troubleshooting

### Method 1: Organization Agents Not Appearing

1. Verify VS Code version is 1.109+
2. Check `github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents` is `true`
3. Confirm your GitHub user is in the organization
4. Verify organization has Copilot subscription
5. Restart VS Code after enabling the setting

### Method 2:ecurity audits

This allows tPaths

### From Local to Method 1 (Native Organization)

1. **Organization Admin**: Upload agents to org-level Copilot settings
2. **Developers**: Enable `showOrganizationAndEnterpriseAgents` in VS Code
3. **Cleanup**: Optionally remove local `.github/agents/` folder
4. **Preserve**: Keep `artifacts/` local (session data stays in repositories)

### From Local to Method 2 (GitHub Repository)

1. Move definitions to org-level `.github-private/agents/`
2. Delete local `.github/agents/` folder
3. Keep `artifacts/` local (don't centralize session data)
4. Update any repo-specific instructions as needed

### From Method 2 to Method 1

1. **Organization Admin**: Upload agents from `.github-private/agents/` to org Copilot settings
2. **Developers**: Enable `showOrganizationAndEnterpriseAgents` setting
3. **Deprecate**: Archive `.github-private` repository (keep for reference)
4. **Verify**: Confirm all agents appear in dropdown before removing local copies

## Best Practices

### Agent Versioning

- **Method 1**: Track changes in a version control system before uploading to org
- **Method 2**: Use Git tags and releases in `.github-private` repository
- Both: Document breaking changes in agent instruction updates

### Hybrid Deployment

You can combine both methods:

- **Organization Agents (Method 1)**: Core 22-agent roster for all teams
- **Repository Agents (Local)**: Project-specific customizations

Local agents take precedence, allowing teams to:
- Override organization agents for specific projects
- Test agent updates before org-wide rollout
- Customize descriptions for domain-specific terminology

### Rollout Strategy

For large organizations migrating to Method 1:

1. **Pilot** (Week 1-2): Test with 5-10 early adopters
2. **Feedback** (Week 3): Gather insights, refine agent descriptions
3. **Staged** (Week 4-6): Roll out by team/department
4. **General** (Week 7+): Enable for all organization members
5. **Monitor**: Track usage metrics via `docs/guides/session-analytics.md`

## Resources

- [VS Code 1.109 Release Notes](https://code.visualstudio.com/updates/v1_109)
- [Background Agents with Worktrees](background-agents-worktrees.md)
- [Session Analytics Guide](session-analytics.md)
- [Onboarding Guide](onboarding.md)

---

**Updated**: January 2026 (VS Code 1.109)
**Method 1 Status**: Experimental (GA expected Q1 2026)VS Code:

```json
{
    "chat.useAgentsMdFile": true,
    "chat.useNestedAgentsMdFiles": true,
    "github.copilot.chat.copilotMemory.enabled": true
}
```

## Troubleshooting

### Agents Not Available

1. Verify `.github-private/agents/` structure is correct
2. Check repo visibility matches agent definitions
3. Restart VS Code to reload agent definitions

### Artifacts Not Created

1. Verify agent has `runCommands` or `edit` tool access
2. Check write permissions in the repository
3. Run `init-artifacts.ps1` manually as fallback

### Session Resume Not Working

1. Check `artifacts/sessions/` for `.json` files
2. Verify session ID matches between runs
3. Session state may be excluded by `.gitignore`

## Security Considerations

- **Session State**: Contains conversation context; excluded from git by default
- **Review Findings**: May reference vulnerabilities; review before committing
- **Credentials**: Never stored in artifacts; agents follow security instructions

## Migration from Local to Central

If you have agents defined locally in `.github/agents/`:

1. Move definitions to org-level `.github-private/agents/`
2. Delete local `.github/agents/` folder
3. Keep `artifacts/` local (don't centralize session data)
4. Update any repo-specific instructions as needed
