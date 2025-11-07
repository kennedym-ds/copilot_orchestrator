---
title: "Agent Instruction Gap Analysis & Enhancement Plan"
version: "0.1.0"
lastUpdated: "2025-11-08"
status: draft
owner: "Copilot Guild"
---

# Agent Instruction Gap Analysis & Enhancement Plan

## Summary
This document compares the current Copilot Orchestrator workspace with the latest multi-agent guidance from the GitHub Copilot Orchestra pattern and the VS Code customization platform. The analysis surfaces alignment gaps and proposes a phased roadmap to deliver a comprehensive instruction stack, agent lineup, and onboarding experience for conductor-led development.

## External Guidance Highlights
- **Layered instruction mesh** – [VS Code custom instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions) describe combining `AGENTS.md`, `.github/copilot-instructions.md`, and scoped `*.instructions.md` with optional nested variants via `chat.useNestedAgentsMdFiles`.
- **Chat modes with handoffs** – [VS Code custom chat modes](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes#_handoffs) emphasize sequential workflows with explicit handoff buttons, optional auto-send prompts, and per-mode tool constraints.
- **Prompt tooling priority** – [VS Code prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files#_tool-list-priority) clarify tool precedence (prompt > referenced mode > default mode) and recommend linking to instruction files instead of duplicating rules.
- **Orchestration blueprint** – The [GitHub Copilot Orchestra](https://github.com/ShepAlderson/copilot-orchestra) reference outlines the conductor-led lifecycle, phase artifacts, mandatory pause points, and deep subagent delegation.

## Alignment Snapshot
| Theme | External expectation | Current repository state | Gap & risk |
| --- | --- | --- | --- |
| Instruction layering | `.github/copilot-instructions.md` should summarize workflow and link to instruction mesh; nested `AGENTS.md` optional but documented. | Workspace charter now documents required VS Code settings, validation scripts, and instruction mesh pointers. | ✅ Addressed — continue to update when new automation lands. |
| Chat mode coverage | Dedicated personas with clear handoffs advancing the lifecycle. | Planner, researcher, implementer, reviewer, and support specialists expose reciprocal handoffs via their agent definitions; conductor now links to all subagents. | ✅ Addressed — monitor for future schema changes (chat modes vs. agents). |
| Handoff choreography | Planner → Implementer → Reviewer → Support → Conductor buttons reflect cadence. | Handoffs are wired across lifecycle and support personas; Agent Sessions shows state telemetry and next actions. | ✅ Addressed — ensure snapshots remain accurate after instruction updates. |
| Prompt-library alignment | Prompt front matter references personas and respects tool priority. | Prompts target agent definitions directly (per VS Code 1.105 update) and reinforce tool usage, TODO lists, and handoffs. | ⚠️ Continue to audit when new prompts are added; tooling schema still evolving. |
| Documentation & onboarding | Setup docs capture VS Code settings (Agent Sessions, nested AGENTS), audit trails, and validation routines. | Onboarding guide now includes configuration snippet, Agent Sessions walkthrough, and support-persona usage guidance. | ✅ Addressed — add screenshots and troubleshooting FAQ in a future docs refresh. |
| Support personas | Orchestration plan includes optional specialty agents with lightweight toolsets. | Security, performance, and documentation agents/prompts are available with limited tools and conductor handoffs. | ✅ Addressed — extend to accessibility or other specialties as needs emerge. |

## Priority Gaps
- [x] Replace the placeholder `.github/copilot-instructions.md` with a concise workspace charter that points to `AGENTS.md`, validation scripts, and required VS Code settings.
- [x] Deliver lifecycle personas with reciprocal handoffs (planner, researcher, implementer, reviewer, support specialists) aligned to VS Code agent schema.
- [x] Update prompt files to reinforce agent usage, tool expectations, and support-persona collaboration.
- [x] Expand documentation to cover nested `AGENTS.md` enablement, Agent Sessions handoffs, and troubleshooting tips.
- [x] Add support persona assets (security, performance, docs) and track follow-ups in the operations backlog.

## Recommended Plan
1. **Phase 0 – Instruction Hardening (Complete)**
   - Workspace charter and onboarding docs now highlight settings, validation commands, and instruction mesh structure.
2. **Phase 1 – Persona Expansion (Complete)**
   - Lifecycle agents expose reciprocal handoffs and conductor integration; support specialists are defined with minimal toolsets.
3. **Phase 2 – Prompt & Documentation Alignment (Complete)**
   - Prompts reinforce agent expectations, TODO usage, and support escalation; onboarding guide covers Agent Sessions configuration.
4. **Phase 3 – Automation Growth (Ongoing)**
   - Pester test suite added for validation scripts. Future work: markdown linting, scheduled smoke tests, accessibility persona.

## Dependencies & Risks
- VS Code Insiders features (handoffs, nested `AGENTS.md`) remain in preview and may change; track updates via release notes.
- Prompt/tool schema still experimental; validation scripts should be updated once official schema stabilizes.
- Additional personas increase maintenance overhead; maintain ownership assignments in `docs/operations.md`.
- Premium models (GPT-5, Claude Sonnet 4.5) require budget confirmation before widescale adoption.

## Immediate Next Actions
- Keep `docs/operations.md` backlog in sync with new automation and persona follow-ups.
- Review support persona coverage quarterly to determine if accessibility, observability, or deployment specialists are required.
