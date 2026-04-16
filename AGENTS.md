# Copilot Orchestrator — Agent Playbook

Multi-agent orchestration for GitHub Copilot. Works in VS Code Chat, Copilot CLI, and the VS Code Agents app.

> **Persona:** Every agent operates as a **Senior Principal Engineer** — pragmatic, no-hype. Understand the problem before solving it. Simple is maintainable.

---

## Architecture

```
.github/agents/      → Agent definitions (11 core + 5 translation)
.github/prompts/     → Prompt templates by workflow phase
.github/skills/      → Reusable skill modules (12 skills)
instructions/        → Layered instructions (global → workflows → compliance)
scripts/             → PowerShell validation and tooling
scripts/mcp/         → MCP servers (validation, analytics, research, translation)
artifacts/           → Local session outputs (plans, reviews, research, decisions)
```

**Lifecycle:** Conductor → Planner → Implementer → Reviewer → Completion

Complexity scales the ceremony:
- **Instant** → Implementer directly (no plan, no review)
- **Standard** → Implementer with inline plan, optional review
- **Deep** → Planner → Implementer → Reviewer cycle
- **Ultra** → Planner → Implementer → Reviewer (multi-mode) → pause

---

## Agent Roster (11 Core + 5 Translation)

### Core Agents

| Agent | File | Tier | Purpose |
|-------|------|------|---------|
| Conductor | `conductor.agent.md` | Premium | Lifecycle orchestration, delegation, pause points |
| Planner | `planner.agent.md` | Premium | Multi-phase planning, risk analysis |
| Reviewer | `reviewer.agent.md` | Premium | Multi-mode review: standard, security, adversarial, performance |
| Implementer | `implementer.agent.md` | Execution | TDD execution, validation |
| Researcher | `researcher.agent.md` | Execution | Evidence gathering, citation |
| Ops | `ops.agent.md` | Execution | Issues, PRs, CI/CD, releases, telemetry |
| Test | `test.agent.md` | Execution | Test authoring, coverage analysis |
| IaC | `iac.agent.md` | Execution | Terraform, Bicep, Pulumi |
| GUI Tester | `gui-tester.agent.md` | Execution | Browser automation, visual regression |
| Docs | `docs.agent.md` | Fast | Documentation, onboarding |
| UX | `ux.agent.md` | Fast | UX review, WCAG accessibility, diagrams |

### Translation Agents

| Agent | File | Purpose |
|-------|------|---------|
| Translation Conductor | `translation-conductor.agent.md` | Full-repo translation orchestration |
| Translator | `translator.agent.md` | File-level code translation |
| Translation Analyzer | `translation-analyzer.agent.md` | Dependency graph, complexity assessment |
| Translation Validator | `translation-validator.agent.md` | Validation stack, confidence scoring |
| Translation Styler | `translation-styler.agent.md` | Target language idioms |

---

## Model Allocation

All agents use fallback arrays. VS Code picks the first available model.

| Tier | Primary → Fallback | Target |
|------|--------------------|--------|
| **Premium** | Claude Opus 4.6 → GPT-5.4 → GPT-4.1 | ~15% of invocations |
| **Execution** | Claude Sonnet 4.6 → GPT-5.4 → GPT-4.1 | ~75% of invocations |
| **Fast** | Claude Haiku 4.5 → GPT-5 mini → Claude Sonnet 4.6 | ~10% of invocations |

Never pin a single model. Models deprecate monthly.

---

## Development Commands

| Task | Command |
|------|---------|
| Validate assets | `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` |
| Check prompt metadata | `pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly` |
| Run linting | `pwsh -File scripts/run-lint.ps1 -RepositoryRoot .` |
| Run smoke tests | `pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .` |
| Token budget report | `pwsh -File scripts/token-report.ps1 -Path .` |
| Session analytics | `pwsh -File scripts/analyze-sessions.ps1` |
| Initialize artifacts | `pwsh -File scripts/init-artifacts.ps1` |
| Pester tests | `Invoke-Pester -Path tests -Output Detailed` |

**Shell**: Windows PowerShell 5.1. Use `;` when chaining commands.

---

## Using with Copilot CLI

Agents load automatically in Copilot CLI sessions (VS Code 1.113+). MCP servers configured in `.vscode/mcp.json` bridge to CLI sessions.

```bash
# Start a CLI session with agent context
copilot chat --agent conductor

# Agents, instructions, and skills are discovered from workspace paths
```

---

## Artifact Storage

Agents persist outputs to a local `artifacts/` folder:

```
artifacts/
├── plans/       # Plans and phase records
├── reviews/     # Review findings
├── research/    # Research briefs
├── decisions/   # ADRs (permanent, git-tracked)
├── sessions/    # Session state JSON
└── memory/      # activeContext.md
```

Initialize with: `pwsh -File scripts/init-artifacts.ps1`

**Retention:** Decisions are permanent. Everything else: 30-day TTL or manual cleanup.

---

## Safety & Compliance

- Follow security baseline in `instructions/global/02_security.instructions.md`
- Never include secrets or tokens in transcripts
- Flag compliance checkpoints in plans and phase summaries
- Run validation scripts before PRs

---

## Skills Ecosystem

Our SKILL.md files follow the [vercel-labs/skills](https://github.com/vercel-labs/skills) standard (`name` + `description` frontmatter). This makes them compatible with the cross-agent skills ecosystem.

### Installing Community Skills

```bash
# Browse available skills
npx skills find <query>

# Install a community skill
npx skills add owner/repo

# List installed skills
npx skills list
```

Community skills install to `.github/skills/` and are auto-discovered by agents. Review security audits before installing — `npx skills find` shows trust scores.

### Context7 Integration

Agents with the Context7 MCP server (`implementer`, `researcher`) can fetch up-to-date library documentation directly into prompts. Use `resolve-library-id` → `query-docs` or add `use context7` to prompts.

---

## Contribution Protocol

1. Update docs alongside code/instruction changes
2. Run `validate-copilot-assets.ps1` before committing
3. Capture changes in `docs/CHANGELOG.md`
4. For agent changes, include sample session exports
