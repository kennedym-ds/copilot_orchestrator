# Background Agents with Git Worktrees

> **Feature:** VS Code 1.107+ | **Settings:** `github.copilot.chat.cli.customAgents.enabled`

## Overview

Git worktrees enable true parallel execution of multiple background agent tasks without file conflicts. When a background agent runs in a dedicated worktree, it operates in an isolated folder with its own working directory, allowing multiple phases or features to be implemented simultaneously.

## Why Use Worktrees?

**Without Worktrees:**

- Background agents modify files in your main workspace
- Risk of conflicts when running multiple agents
- Must wait for one agent to complete before starting another

**With Worktrees:**

- Each background agent gets its own isolated directory
- Multiple agents can run simultaneously without conflicts
- Changes are easily reviewed and merged back when ready
- Failed experiments don't pollute your main workspace

## Quick Start

### 1. Enable Background Agents with Custom Agents

Add to your VS Code settings:

```json
{
  "github.copilot.chat.cli.customAgents.enabled": true
}
```

### 2. Create a Background Agent Session

1. Open the Chat view
2. Select your custom agent (e.g., `implementer`, `planner`)
3. Click "Continue in Background"
4. Choose **"Run in Git Worktree"** from the dropdown

VS Code will:

- Create a new worktree at `../<repo-name>-worktree-<session-id>`
- Check out a new branch for the session
- Start the agent in the isolated environment

### 3. Monitor Progress

- View all background sessions in the Agent Sessions sidebar
- Check file changes in the worktree without affecting your main workspace
- See real-time progress as the agent works

### 4. Review and Merge

When the agent completes:

1. **Review Changes**: Click "Open Worktree" to inspect the changes
2. **Apply to Workspace**: Use "Apply Changes to Workspace" to copy files back
3. **Or Merge**: Use Git to merge the worktree branch into your main branch
4. **Clean Up**: VS Code automatically removes the worktree when you close the session

## Use Cases

### Parallel Phase Implementation

**Scenario**: Execute multiple plan phases simultaneously
text
Main Workspace          Worktree 1              Worktree 2
    │                       │                       │
    ├─ Phase 1-3 done       ├─ Phase 4: Auth        ├─ Phase 5: API
    │                       │   (implementer)       │   (implementer)
    │                       │                       │
    └─ Working on docs      └─ TDD in progress      └─ TDD in progress
```

**Setup**:

1. Complete Phases 1-3 in main workspace
2. Start background agent for Phase 4 in worktree-1
3. Start another background agent for Phase 5 in worktree-2
4. Continue working on documentation in main workspace

**Benefits**:

**Benefits**:
- Phases complete in parallel
- No file conflicts between phases
- Can prioritize merging critical phases first

### Experimental Features

**Scenario**: Test risky architectural changes without disrupting main work

```bash
# Main workspace continues normal development
# Worktree explores new approach

# If experiment succeeds → merge worktree branch
# If experiment fails → delete worktree, no cleanup needed
### Multi-Specialist Collaboration

**Scenario**: Security review + Performance optimization + Documentation

```textcenario**: Security review + Performance optimization + Documentation

```
Worktree 1: Security Agent
├─ Adding input validation
├─ Implementing rate limiting
└─ Adding security tests

Worktree 2: Performance Agent  
├─ Optimizing database queries
├─ Adding caching layer
└─ Profiling improvements

Main Workspace: Docs Agent
└─ Updating security docs
```

## Worktree Management Commands

### List Active Worktrees

```powershell
git worktree list
```

### Manual Worktree Creation (Advanced)

```powershell
# Create worktree for feature branch
git worktree add ../my-repo-feature-x feature-x

# Work in the worktree
cd ../my-repo-feature-x

# When done, return to main and remove
cd ../my-repo
git worktree remove ../my-repo-feature-x
```

### Clean Up Orphaned Worktrees

```powershell
# Prune worktree metadata
git worktree prune

# Force remove if needed
git worktree remove --force ../my-repo-worktree-123
```

## Best Practices

### 1. Name Branches Clearly

VS Code auto-generates branch names, but you can customize them:

```text
agent-session/<agent-name>/<phase-or-feature>
```

Examples:

- `agent-session/implementer/phase-4-auth`
- `agent-session/security/audit-api-endpoints`

### 2. Limit Concurrent Worktrees
**Recommended**: 2-3 concurrent background agents

- **Recommended**: 2-3 concurrent background agents
- Each worktree consumes disk space and system resources
- Too many can slow down Git operations

### 3. Review Before Merging

```powershell
# Compare worktree changes to main
git diff main..agent-session/implementer/phase-4-auth

# Review in VS Code
code ../my-repo-worktree-123
```

### 4. Handle Conflicts Early

If worktrees modify overlapping files:

1. Merge main into worktree branch frequently
2. Resolve conflicts in the worktree
3. Then merge back to main

```powershell
cd ../my-repo-worktree-123
git merge main
# Resolve conflicts
git push
```

## Integration with Conductor Workflow

### Planning Phase

When the **Planner** creates a multi-phase plan:

```markdown
## Phase Execution Strategy

- **Phase 1-3**: Sequential in main workspace (dependencies)
- **Phase 4-5**: Parallel in worktrees (independent)
- **Phase 6**: Main workspace (integration)
```

### Implementation Phase

The **Conductor** can delegate phases to background agents:

```markdown
## Phase Assignments

| Phase | Agent        | Mode       | Worktree | Status |
|-------|--------------|------------|----------|--------|
| 1     | implementer  | local      | No       | ✅ Done |
| 2     | implementer  | local      | No       | ✅ Done |
| 3     | implementer  | local      | No       | ✅ Done |
| 4     | implementer  | background | Yes      | 🔄 Running |
| 5     | implementer  | background | Yes      | 🔄 Running |
```

### Review Phase

The **Reviewer** can review worktree changes before merge:

```markdown
## Worktree Review Checklist

- [ ] Tests pass in worktree environment
- [ ] No conflicts with main branch
- [ ] Changes align with approved plan
- [ ] Security/compliance checks passed
- [ ] Performance impact acceptable
```

## Troubleshooting

### Issue: "Cannot create worktree: already exists"

**Solution**: Clean up the existing worktree

```powershell
git worktree remove ../my-repo-worktree-123
git worktree prune
```

### Issue: "Worktree locked"

**Solution**: Unlock and remove

```powershell
# Remove lock file
Remove-Item .git/worktrees/worktree-123/lock -Force

# Then remove worktree
git worktree remove ../my-repo-worktree-123
```

### Issue: "Cannot switch to branch (in use by worktree)"

**Solution**: Each branch can only be checked out in one worktree at a time

```powershell
# Either checkout a different branch in the worktree
cd ../my-repo-worktree-123
git checkout -b new-branch

# Or remove the worktree
cd ../my-repo
git worktree remove ../my-repo-worktree-123
```

## Resources

- [Git Worktrees Official Documentation](https://git-scm.com/docs/git-worktree)
- [VS Code Background Agents Guide](https://code.visualstudio.com/docs/copilot/agents/background-agents)
- [Copilot Orchestrator: AGENTS.md](../../AGENTS.md)

## Related Guides

- [Central Deployment](central-deployment.md) - Organization-level agent sharing
- [Session Analytics](session-analytics.md) - Track worktree session metrics
- [Onboarding](onboarding.md) - Getting started with the orchestrator

---

**Updated**: December 2025 (VS Code 1.107)  
**Maintainer**: Copilot Orchestrator Team
