# Central Deployment Guide

This guide explains how to deploy the Copilot Orchestrator agents centrally at the organization level while having agents create local `artifacts/` folders in each consuming repository.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Organization Level                        │
│  .github-private repository (or .github)                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  agents/                                                │ │
│  │  ├── conductor.agent.md                                │ │
│  │  ├── planner.agent.md                                  │ │
│  │  ├── implementer.agent.md                              │ │
│  │  ├── reviewer.agent.md                                 │ │
│  │  └── ... (all 22+ agents)                              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Repo A        │  │   Repo B        │  │   Repo C        │
│  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │
│  │artifacts/ │  │  │  │artifacts/ │  │  │  │artifacts/ │  │
│  │├── plans/ │  │  │  │├── plans/ │  │  │  │├── plans/ │  │
│  │├── reviews│  │  │  │├── reviews│  │  │  │├── reviews│  │
│  │└── ...    │  │  │  │└── ...    │  │  │  │└── ...    │  │
│  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## Setup Instructions

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
└── agents/
    ├── conductor.agent.md
    ├── planner.agent.md
    ├── implementer.agent.md
    ├── reviewer.agent.md
    ├── researcher.agent.md
    ├── security.agent.md
    ├── performance.agent.md
    ├── maintainer.agent.md
    ├── visualizer.agent.md
    ├── accessibility.agent.md
    ├── data-analytics.agent.md
    ├── docs.agent.md
    ├── observability.agent.md
    ├── deployment.agent.md
    ├── red-team.agent.md
    ├── terraform.agent.md
    ├── bicep.agent.md
    ├── beast-mode.agent.md
    ├── test.agent.md
    ├── lint.agent.md
    └── github-ops.agent.md
```

### 3. Include the Init Script

Copy the artifacts initialization script:

```bash
mkdir -p scripts
cp scripts/init-artifacts.ps1 scripts/
```

### 4. Consuming Repository Setup

In each repository that will use the central agents, you have two options:

#### Option A: Automatic Initialization (Recommended)

The agents are configured to automatically create the `artifacts/` folder when they start working. No setup required in consuming repos.

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
   ├── plans/          # Planner, Implementer, Conductor
   ├── reviews/        # Reviewer
   ├── research/       # Researcher
   ├── security/       # Security
   ├── sessions/       # Conductor (session state)
   ├── performance/    # Performance
   ├── docs/           # Docs
   ├── releases/       # Maintainer
   ├── telemetry/      # Observability
   ├── deployments/    # Deployment
   ├── red-team/       # Red Team
   ├── accessibility/  # Accessibility
   ├── tests/          # Test
   ├── ux/             # Visualizer
   ├── README.md
   └── .gitignore
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
- Review verdicts
- Research briefs
- Security audits

This allows teams to:
- Track implementation history in version control
- Share knowledge across team members
- Maintain audit trails for compliance

## VS Code Configuration

Users consuming org-level agents should configure VS Code:

```json
{
    "chat.useAgentsMdFile": true,
    "chat.useNestedAgentsMdFiles": true,
    "github.copilot.chat.tools.memory.enabled": true
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
