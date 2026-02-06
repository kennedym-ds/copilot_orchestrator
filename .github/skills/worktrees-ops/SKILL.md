---
name: worktrees-ops
description: "Git worktrees operations for parallel conductor workflows, enabling multiple agent sessions on different branches simultaneously. Use for creating, managing, and cleaning up worktrees with VS Code 1.109."
---

# Worktrees Operations

Provides Git worktrees operations for parallel conductor workflows, enabling multiple agent sessions to work on different branches simultaneously without context conflicts.

## Description

This skill teaches agents how to create, manage, and clean up Git worktrees using the enhanced Worktrees UI in VS Code 1.109. It covers worktree creation strategies, branch management, conductor workflow integration, and cleanup procedures for safe parallel execution.

## When to Use

This skill is relevant when:
- Running multiple conductor workflows in parallel
- Testing changes across multiple branches simultaneously
- Isolating experimental work from main development
- Reviewing PRs while continuing active development
- Running background agents on separate branches
- Cleaning up stale worktrees

## Entry Points

### Trigger Phrases
- "create worktree"
- "parallel conductor workflows"
- "switch to different branch"
- "clean up worktrees"
- "work on multiple branches"
- "isolate experimental changes"

### Context Patterns
- User mentions working on multiple features simultaneously
- Conductor needs to review PR while implementation continues
- Background agent tasks require branch isolation
- Multiple agent sessions active for different tasks
- Worktree directories accumulating in workspace

## Core Knowledge

### Worktree Basics

**What is a Git Worktree?**
A worktree is an additional working copy of your repository that can be checked out to a different branch. Each worktree operates independently with its own working directory and staging area.

**Benefits for Conductor Workflows:**
- No branch context switching disruption
- Parallel agent sessions on different features
- Review PRs without interrupting active work
- Background agents in isolated environments
- Clean separation of conductor phases

### VS Code 1.109 Worktrees UI

**Source Control Repositories View:**
- Enable with `scm.repositories.explorer: true`
- Worktrees node shows all linked directories
- Inline actions: Open in New Window, Remove
- Keyboard navigation: ↑/↓, Enter (open), Delete (remove)

**Worktree Selection:**
- `scm.repositories.selectionMode: "worktree"` (select worktree root)
- `scm.repositories.selectionMode: "repository"` (select repository root)

## Operations

### 1. Create Worktree

**Command:**
```powershell
# Create worktree for new branch
git worktree add ..\feature-branch -b feature-branch

# Create worktree from existing branch
git worktree add ..\bugfix-123 bugfix-123

# Create worktree with specific path
git worktree add C:\Worktrees\project-feature -b feature-name
```

**VS Code Integration:**
After creation, worktree appears in Source Control → Repositories → Worktrees node.

**Naming Convention:**
- `../<feature-name>` — Sibling directory for quick access
- `C:\Worktrees\<project>-<feature>` — Dedicated worktrees folder
- `~/worktrees/<project>/<feature>` — Cross-platform structure

### 2. List Worktrees

**Command:**
```powershell
git worktree list
```

**Output:**
```
C:/Projects/copilot_orchestrator        abc123d [main]
C:/Projects/feature-oauth               def456e [feature-oauth]
C:/Projects/bugfix-validation           789fgh1 [bugfix-validation]
```

**VS Code UI:**
View in Source Control → Repositories → Worktrees node

### 3. Switch Between Worktrees

**Option A: Open in Current Window**
```powershell
# Navigate to worktree directory
Set-Location ..\feature-branch
code .
```

**Option B: Open in New Window**
1. Source Control → Repositories → Worktrees
2. Right-click worktree → "Open in New Window"
3. Or: Inline action button → New Window icon

**Option C: Command Palette**
```
Ctrl+Shift+P → "Git: Switch Worktree"
```

### 4. Remove Worktree

**Clean Removal (recommended):**
```powershell
# Remove worktree and clean up
git worktree remove feature-branch

# Force removal if uncommitted changes
git worktree remove feature-branch --force
```

**Manual Cleanup:**
```powershell
# If directory already deleted
git worktree prune
```

**VS Code UI:**
1. Source Control → Repositories → Worktrees
2. Right-click worktree → "Remove"
3. Or: Inline action button → Remove icon
4. Or: Select worktree, press Delete

### 5. Prune Stale Worktrees

**Command:**
```powershell
# Remove metadata for deleted worktrees
git worktree prune

# See what would be pruned (dry run)
git worktree prune --dry-run --verbose
```

**When to Use:**
- After manually deleting worktree directories
- Cleaning up after failed worktree operations
- Regular maintenance (monthly)

## Conductor Workflow Integration

### Pattern 1: Parallel Features

**Scenario:** Working on two features simultaneously

**Setup:**
```powershell
# Main repository: Feature A
cd C:\Projects\copilot_orchestrator

# Create worktree for Feature B
git worktree add ..\copilot-orchestrator-feature-b -b feature-b

# Open in new VS Code window
code ..\copilot-orchestrator-feature-b
```

**Workflow:**
- Window 1 (main): Conductor working on Feature A, Phase 3
- Window 2 (worktree): Conductor working on Feature B, Phase 1
- No branch switching, no context conflicts
- Agent Sessions separate per window

### Pattern 2: Review During Development

**Scenario:** PR review needed while Feature C implementation continues

**Setup:**
```powershell
# Continue work in main
# Feature C implementation in progress

# Create worktree for PR review
git worktree add ..\pr-review-247 -b review/pr-247

# Open PR branch in new window
code ..\pr-review-247
```

**Workflow:**
- Window 1 (main): Continue Feature C implementation
- Window 2 (worktree): Review PR #247 with Reviewer agent
- No interruption to active conductor workflow
- Clean separation of review context

### Pattern 3: Background Agent Isolation

**Scenario:** Long-running background task (data analysis, code generation)

**Setup:**
```powershell
# Create worktree for background task
git worktree add ..\background-analysis -b analysis/ds-star

# Launch background agent in isolated environment
code ..\background-analysis
```

**Workflow:**
- Main window: Continue active development
- Worktree window: Data Analytics agent runs DS-Star workflow
- No resource contention
- Background results committed to separate branch

### Pattern 4: Experimental Changes

**Scenario:** Testing risky refactoring without affecting main work

**Setup:**
```powershell
# Create experimental worktree
git worktree add ..\experiment-new-architecture -b experiment/architecture-v2

# Try experimental changes
code ..\experiment-new-architecture
```

**Workflow:**
- Main window: Continue stable development
- Worktree window: Aggressive refactoring, multiple iterations
- Easy to discard if experiment fails
- No risk to main workflow

## Best Practices

### Worktree Lifecycle
1. **Create:** `git worktree add` with descriptive branch name
2. **Work:** Open in new VS Code window, run conductor workflow
3. **Commit:** Finish work, commit changes
4. **Merge:** Merge to main (if successful)
5. **Remove:** `git worktree remove` immediately after merge
6. **Prune:** Monthly cleanup with `git worktree prune`

### Directory Organization
```
C:\Projects\
├── copilot_orchestrator\          # Main repository
├── copilot-orchestrator-feat-a\   # Worktree: Feature A
├── copilot-orchestrator-feat-b\   # Worktree: Feature B
└── copilot-orchestrator-pr-123\   # Worktree: PR review
```

### Naming Conventions
- **Features:** `<repo>-feature-<name>` or `feat-<name>`
- **Bugfixes:** `<repo>-bugfix-<issue>` or `fix-<issue>`
- **Reviews:** `<repo>-pr-<number>` or `review-pr-<number>`
- **Experiments:** `<repo>-experiment-<name>` or `exp-<name>`

### Cleanup Schedule
- **Daily:** Review active worktrees, remove completed ones
- **Weekly:** Run `git worktree prune` to clean metadata
- **Monthly:** Audit all worktrees, remove abandoned experiments

## Troubleshooting

### Issue: Worktree creation fails with "already exists"

**Solution:**
```powershell
# Check existing worktrees
git worktree list

# Remove conflicting worktree
git worktree remove <name>

# Or prune stale metadata
git worktree prune
```

### Issue: Can't remove worktree with uncommitted changes

**Solution:**
```powershell
# Option 1: Commit changes
git add .
git commit -m "WIP: Save work before removing worktree"

# Option 2: Force remove (loses changes)
git worktree remove <name> --force
```

### Issue: Worktree not showing in VS Code UI

**Solution:**
1. Verify setting: `"scm.repositories.explorer": true`
2. Reload VS Code window (Ctrl+Shift+P → "Reload Window")
3. Check Git version: `git --version` (requires Git 2.5+)
4. Ensure worktree is in valid Git repository

### Issue: Branch conflicts between worktrees

**Solution:**
```powershell
# Each worktree must be on different branch
git worktree list  # Check current branches

# Create new branch for worktree
git worktree add ..\new-work -b new-branch
```

### Issue: Lost track of worktree directories

**Solution:**
```powershell
# List all worktrees with paths
git worktree list

# Prune missing worktrees
git worktree prune --verbose
```

## Examples

### Example 1: Create Worktree for Phase 6 Pilot
```powershell
# In main repository
cd C:\Projects\copilot_orchestrator

# Create worktree for Agent Skills pilot
git worktree add ..\copilot-orchestrator-skills -b feature/agent-skills-pilot

# Open in new window
code ..\copilot-orchestrator-skills

# Work on Phase 6 in isolation
# Main window continues on Phase 5
```

### Example 2: Review PR While Implementing
```powershell
# Active work on VS Code 1.109 integration
cd C:\Projects\copilot_orchestrator

# PR arrives for urgent review
git worktree add ..\copilot-orchestrator-pr-521 pr-521

# Open PR in new window
code ..\copilot-orchestrator-pr-521

# Review with Reviewer agent in worktree window
# Continue implementation in main window
```

### Example 3: Parallel Conductor Workflows
```powershell
# Main: Working on documentation updates
cd C:\Projects\copilot_orchestrator

# Create worktree for security audit
git worktree add ..\security-audit -b security/q1-2026-audit

# Create worktree for performance optimization
git worktree add ..\perf-optimization -b perf/conductor-metrics

# Open both in new windows
code ..\security-audit
code ..\perf-optimization

# Now 3 conductor workflows active:
# 1. Main: Documentation updates
# 2. Worktree 1: Security audit (Security agent)
# 3. Worktree 2: Performance optimization (Performance agent)
```

### Example 4: Cleanup After Sprint
```powershell
# List all worktrees
git worktree list

# Remove completed feature worktrees
git worktree remove ..\feat-oauth
git worktree remove ..\feat-agent-skills

# Prune any stale metadata
git worktree prune --verbose

# Verify cleanup
git worktree list
```

## References

- Worktrees guide: [docs/guides/background-agents-worktrees.md](../../../docs/guides/background-agents-worktrees.md)
- VS Code 1.109 Worktrees UI: [docs/guides/vscode-copilot-configuration.md](../../../docs/guides/vscode-copilot-configuration.md)
- Git worktrees documentation: https://git-scm.com/docs/git-worktree
