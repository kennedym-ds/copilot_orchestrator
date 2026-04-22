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
| Conductor | `conductor.agent.md` | Execution | Lifecycle orchestration, delegation, pause points |
| Planner | `planner.agent.md` | Premium | Multi-phase planning, risk analysis |
| Reviewer | `reviewer.agent.md` | Execution | Multi-mode review (security mode pins Opus) |
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

All agents use fallback arrays and a `thinkingEffort:` hint. VS Code picks the first available model in the array.

| Tier | Primary -> Fallback chain | Agents | Typical effort |
|------|---------------------------|--------|----------------|
| **Premium** | Claude Opus 4.6 -> Claude Opus 4.7 -> Claude Sonnet 4.6 | Planner | high |
| **Execution** | Claude Sonnet 4.6 -> GPT-5.4 -> GPT-5.3-Codex | Conductor, Reviewer, Implementer, Researcher, Ops, Test, IaC, GUI Tester, Translation Conductor, Translator, Translation Analyzer, Translation Validator | low / medium / high |
| **Fast** | Claude Haiku 4.5 -> GPT-5.4 mini -> GPT-5 mini | Docs, UX, Translation Styler | low / medium |

Security-mode review promotes Claude Opus 4.7 to the top of the fallback chain via a prompt-level override (see `.github/prompts/support/security-review.prompt.md`).

Never pin a single model. Models deprecate monthly.

---

## Permission & Complexity Tier Matrix

Maps the conductor's complexity tiers to Copilot CLI permission modes and per-agent Autopilot safety. Closes gaps G2 and G33.

| Complexity tier | Conductor path | Copilot CLI permission | Autopilot allowed? | Notes |
|-----------------|----------------|------------------------|--------------------|-------|
| INSTANT         | Implementer direct | Bypass Approvals    | Yes (free/pro branches only) | Single-file reads/edits; no multi-phase ceremony |
| STANDARD        | Implementer + inline plan | Default      | No                 | Human confirms destructive actions |
| DEEP            | Planner -> Implementer -> Reviewer | Default | No              | Mandatory pause points |
| ULTRADEEP       | Full cycle + trilateral review | Default     | No                 | Explicit human ratification at every gate |
| Security review | Reviewer --security | Default               | No                 | Autopilot explicitly disallowed regardless of tier |

### Per-agent Autopilot safety

| Agent class | Agents | Autopilot safe? | Rationale |
|-------------|--------|-----------------|-----------|
| Read-only   | researcher, docs, ux, translation-analyzer, translation-styler | Yes | No filesystem mutation in normal operation |
| Edit-bounded | test, iac, translator, translation-validator | Case-by-case | Safe for trivial test authoring; never for infra apply |
| State-changing | implementer, ops, translation-conductor, gui-tester | No | Destructive CLI calls, deploys, browser automation |
| Judgement-critical | conductor, planner, reviewer | No | Autopilot removes the approval step that defines these roles |

### Branch policy

| Branch | Autopilot policy |
|--------|------------------|
| free / pro | Autopilot permitted for INSTANT tier only |
| pro-plus | Autopilot permitted for INSTANT and read-only STANDARD |
| enterprise | Autopilot disallowed; all mutations human-confirmed |

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

# Agents, instructions, and skills are discovered from workspace paths. MCP servers load from `.vscode/mcp.json`. For permission-tier guidance see the Permission & Complexity Tier Matrix above
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
