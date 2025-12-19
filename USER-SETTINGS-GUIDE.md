# User Settings for VS Code 1.107+ Copilot Features

Copy these settings to your **User Settings** (`Ctrl+,` → search "settings.json" → click "Edit in settings.json"):

```json
{
  // VS Code 1.107+ Copilot Features
  "chat.customAgentInSubagent.enabled": true,
  "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
  "github.copilot.chat.cli.customAgents.enabled": true,
  "chat.useClaudeSkills": true,
  
  // UI Improvements
  "chat.agent.thinkingStyle": "collapsed",
  "chat.agent.thinking.collapsedTools": true,
  "chat.viewSessions.enabled": true,
  "chat.viewSessions.orientation": "auto",
  
  // Tool Auto-Approval (Balanced Security)
  "chat.tools.eligibleForAutoApproval": [
    "readFile",
    "search",
    "semanticSearch",
    "codeSearch",
    "fileSearch",
    "listFiles",
    "getWorkspaceInfo"
  ],
  
  // Git Worktrees for Background Agents
  "git.enableWorktrees": true,
  "git.worktree.openAfterCreate": "always"
}
```

## What Each Setting Does

### Automatic Agent Routing
- **`chat.customAgentInSubagent.enabled`**: Allows agents to automatically invoke other agents (e.g., Conductor → Planner)
- **`github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents`**: Shows organization-level agents in the dropdown

### Background Agents & CLI
- **`github.copilot.chat.cli.customAgents.enabled`**: Enables custom agents in GitHub CLI (`gh copilot`)
- **`git.enableWorktrees`**: Enables Git worktrees for parallel background agent sessions
- **`git.worktree.openAfterCreate`**: Automatically opens worktree in new window after creation

### Claude Skills
- **`chat.useClaudeSkills`**: Allows agents to load Claude Code skills from `.claude/skills/` folders

### UI Improvements
- **`chat.agent.thinkingStyle: "collapsed"`**: Shows thinking process collapsed by default (cleaner UI)
- **`chat.agent.thinking.collapsedTools: true`**: Tool invocations also collapsed
- **`chat.viewSessions.enabled`**: Shows Agent Sessions sidebar for monitoring background tasks
- **`chat.viewSessions.orientation: "auto"`**: Auto-layout for session view

### Security
- **`chat.tools.eligibleForAutoApproval`**: Read-only tools auto-approved, write/execute require confirmation
  - See [instructions/compliance/tool-approval-policy.instructions.md](../instructions/compliance/tool-approval-policy.instructions.md) for details

## After Updating

1. **Restart VS Code** to apply all settings
2. **Test automatic routing**: Ask Conductor to delegate to another agent
3. **Try background agents**: Create a worktree session for parallel work
4. **Verify in UI**: Check that Agent Sessions sidebar appears in the Activity Bar

## Optional: Maximum Productivity (Less Secure)

If you're working in a trusted/sandboxed environment and want agents to auto-approve file edits:

```json
{
  "chat.tools.eligibleForAutoApproval": [
    "readFile",
    "search",
    "semanticSearch",
    "codeSearch",
    "fileSearch",
    "listFiles",
    "getWorkspaceInfo",
    "createFile",
    "editFile"
  ]
}
```

⚠️ **Warning**: Only use this in local development, never in production or with sensitive data.

---

**Updated**: December 19, 2025  
**VS Code Version Required**: 1.107+
