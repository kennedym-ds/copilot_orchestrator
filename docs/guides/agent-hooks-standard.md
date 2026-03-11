---
title: "Agent hooks standard"
version: "1.0.0"
lastUpdated: "2026-03-10"
status: "active"
reviewOwners:
  - "Copilot Orchestrator maintainers"
aiAssistance: "Drafted with GitHub Copilot and intended for review with Pester plus validate-copilot-assets.ps1."
---

# Agent hooks standard

Agent-scoped hooks let a `.agent.md` file attach deterministic pre/post-processing behavior through a `hooks` section in frontmatter. This guide defines the safe rollout pattern for VS Code 1.111 hook support so hooks improve consistency without becoming a sneaky side-channel for hidden behavior.

## Enablement

- Hooks require VS Code support for agent-scoped hooks.
- The setting `chat.useCustomAgentHooks` must be enabled.
- Hook usage must be documented in the owning agent file; no undocumented magic tricks.

## Frontmatter syntax

```yaml
hooks:
  preResponse:
    - path: ".github/hooks/{agent-name}/pre-response.md"
  postToolCall:
    - path: ".github/hooks/{agent-name}/post-tool.md"
```

## Allowed triggers

| Trigger | Intended use |
|---------|--------------|
| `preResponse` | Inject stable context, reminders, or response scaffolding before the agent answers |
| `postToolCall` | Standardize follow-up notes after a tool completes |
| `preHandoff` | Add required delegation metadata before routing to another agent |
| `postValidation` | Remind the agent to capture evidence, risks, or next-step summaries after validation |

## Hard safety rules

1. Hooks **MUST NOT** bypass user approval flows.
2. Hooks **MUST NOT** perform destructive operations silently.
3. Hooks **MUST NOT** carry secret payloads or credentials.
4. Hooks **MUST** be documented in the owning agent's file.
5. Hooks **MUST** be idempotent — safe to re-run without changing meaning or state unexpectedly.

## Initial rollout scope

Limit initial hook adoption to these agents only:

- `conductor`
- `planner`
- `implementer`
- `reviewer`

Any expansion beyond this set belongs in a later phase after the first hook-bearing agents are validated in the editor.

## Good use cases

- Context injection for active artifact paths, phase IDs, or decision IDs
- Handoff payload standardization so required fields are not forgotten
- Validation reminders that nudge the agent to record commands, results, and residual risks

## Bad use cases

- Auto-approving edits, commands, or handoffs
- Silently deleting files, mutating configuration, or running destructive actions
- Injecting undocumented behavior that reviewers cannot discover by reading the owning agent file

## Verification

After adding or updating hooks:

1. Open the owning agent in VS Code.
2. Check the **Agent Debug Panel** to confirm the hook configuration is loaded.
3. Verify the hook path exists and the behavior is documented in the agent body.
4. Re-run repository validation so hook-bearing agent files remain parseable and reviewable.

## Related references

- [Agent standard template](../templates/agent-standard.md)
- [Agent & Skill Quality Review spec](../../artifacts/specs/agent-skill-quality-review/spec.md)
- [Action plan Phase 1](../../artifacts/plans/2026-agent-skill-quality-action-plan/plan.md)
- [VS Code custom agents documentation](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
