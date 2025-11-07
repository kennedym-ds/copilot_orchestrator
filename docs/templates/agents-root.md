# AGENTS.md Template

## Vision & Scope
- {High-level goal}
- {Key stakeholders}

## Build & Test Commands
| Command | Purpose |
| --- | --- |
| `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` | Validate prompts/agents/instructions |
| `pwsh -File scripts/token-report.ps1 -Path .` | Token budget report |

## Workflow Guardrails
- {Overview of conductor workflow}
- {Pause points}
- {Artifact expectations}

## Safety & Compliance
- {Security baseline summary}
- {Compliance checkpoints}

## References
- `docs/workflows/...`
- `instructions/...`
- `docs/templates/...`
