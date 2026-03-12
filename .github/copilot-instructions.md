# Copilot Orchestrator Workspace Instructions

Multi-agent orchestration system with 29 specialized agents. See `AGENTS.md` for complete agent roster and lifecycle details.

**Central Persona:** All agents operate as a **Senior Principal Engineer** — understand the problem before solving it, prefer the simplest working solution, no hype, no bullshit. See `instructions/global/00_behavior.instructions.md` for the Zen of Engineering tenets that govern all output.

## Architecture

```
.github/agents/      → Agent definitions (conductor, planner, implementer, reviewer, spec, + 23 specialists)
.github/prompts/     → Prompt templates organized by workflow phase
instructions/        → Layered instructions (global → workflows → compliance → languages)
scripts/             → PowerShell 5.1 validation and tooling
scripts/mcp/         → MCP servers (8 servers: validation, analytics, github, research, design, translation, demo)
.vscode/mcp.json     → Workspace MCP server configuration (auto-discovered by VS Code)
artifacts/           → Local session outputs (plans, reviews, research, security)
```

## Core Workflow

**Lifecycle:** Conductor → Planner → Implementer → Reviewer → Completion

1. Start complex tasks in **Conductor**—it delegates to specialized subagents
2. Pause points are mandatory after plans and reviews (wait for human approval)
3. Conductor is the only agent with handoff buttons — all other agents delegate autonomously via `#runSubagent`
4. Agents use the `delegation-routing` skill for keyword-based routing patterns
5. Persist outputs to `artifacts/` using templates from `docs/templates/`

**State Tracking:** Every conductor response includes Current Phase, Plan Progress, Last Action, Next Action.

## Commands

```powershell
# Validation (run before PRs)
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
pwsh -File scripts/run-lint.ps1 -RepositoryRoot .
pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .

# Initialize artifacts folder (once per consuming repository)
pwsh -File scripts/init-artifacts.ps1

# Token budget report
pwsh -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

## GitHub Release Publishing Guidance

- Treat release publishing as two separate steps:
    1. Push commit/tag via git.
    2. Create GitHub Release object and upload assets via GitHub API/UI/CLI.
- Do not assume a pushed tag is visible on the Releases page until a release object exists.
- For publish completion evidence, include:
    - Release URL
    - Asset count
    - Asset names and sizes

### Non-Interactive Fallback (Windows)

If `gh auth` is unavailable but git push/pull works:

1. Refresh PATH from Machine/User in the terminal session.
2. Read GitHub credential via `git credential fill` for `host=github.com`.
3. Create/fetch release by tag through GitHub REST API.
4. Upload installer/artifacts via `uploads.github.com` release-assets endpoint.
5. Verify URL and assets, then report non-sensitive results only.

Security: never expose token values in chat, logs, artifacts, or files.

## Task Suitability

**AI-appropriate:** Documentation updates, test authoring (TDD), bug fixes with clear repro steps, prompt/agent updates following patterns, PowerShell script enhancements.

**Human approval required:** Conductor workflow changes, security/compliance modifications, model allocation changes, new external dependencies.

## VS Code Settings

See `AGENTS.md` for the full VS Code settings block (1.108–1.111), agent sessions integration, and feature updates.

Essential paths for agent loading:
```json
{
    "chat.instructionsFilesLocations": ["instructions"],
    "chat.promptFilesLocations": [".github/prompts"],
    "chat.agentFilesLocations": { ".github/agents": true },
    "chat.agentSkillsLocations": { ".github/skills": true }
}
```

## Key References

- `AGENTS.md` — Agent roster, lifecycle, model allocation, safety guardrails, VS Code settings
- `docs/guides/onboarding.md` — New contributor setup
- `docs/templates/` — Plan, phase-complete, and plan-complete templates
- `docs/operations.md` — Backlog and incident tracking
- `INSTRUCTION_CHANGELOG.md` — Instruction change history
- `docs/guides/mcp-integration.md` — MCP server setup, agent mapping, protocol features
- `.vscode/mcp.json` — Workspace MCP configuration (8 servers)

## Parallel Execution Guidance

- **Prefer parallel when safe:** Run independent, idempotent tasks in parallel to reduce overall runtime (examples: static validation, linting, and non-destructive smoke tests).
- **Detect independence before parallelizing:** Only parallelize tasks that do not contend for the same mutable resources, files, or locks. If tasks share writable state, keep them sequential or add coordination.
- **Use agent-level parallelism:** Agents may invoke multiple read-only subagents in parallel (for example, `search_subagent`, `researcher`, or analysis subagents). Use `multi_tool_use.parallel` patterns for truly concurrent tool calls.
- **Aggregate and summarize results:** When tasks run in parallel, collect outputs into a single summary and surface any blockers prominently; non-critical failures can be reported without blocking unrelated tasks.
- **Protect destructive operations:** Do not run destructive actions (deploys, pushes, deletes) concurrently unless there is explicit coordination and approval; require an extra confirmation step for such actions.
- **Fallback to sequential:** If the runtime environment or client does not support concurrency, workflows should gracefully fall back to sequential execution.

