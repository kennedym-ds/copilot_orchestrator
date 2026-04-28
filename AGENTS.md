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
| Planner | `planner.agent.md` | Execution | Multi-phase planning, risk analysis |
| Reviewer | `reviewer.agent.md` | Execution | Multi-mode review (security mode pins Opus) |
| Implementer | `implementer.agent.md` | Execution | TDD execution, validation |
| Researcher | `researcher.agent.md` | Execution | Evidence gathering, citation |
| Ops | `ops.agent.md` | Execution | Issues, PRs, CI/CD, releases, telemetry |
| Test | `test.agent.md` | Execution | Test authoring, coverage analysis |
| IaC | `iac.agent.md` | Execution | Terraform, Bicep, Pulumi |
| GUI Tester | `gui-tester.agent.md` | Fast | Browser automation, visual regression |
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
| **Premium (security-only)** | Claude Opus 4.7 -> Claude Opus 4.6 | Reviewer (security-mode prompt override only) | high |
| **Execution** | Claude Sonnet 4.6 -> GPT-5.4 -> GPT-5.3-Codex | Conductor, Reviewer, Implementer, Planner, Researcher, Ops, Test, IaC, Translation Conductor, Translator, Translation Analyzer, Translation Validator | low / medium / high |
| **Fast** | Claude Haiku 4.5 -> GPT-5.4 mini | GUI Tester, Docs, UX, Translation Styler | low |

Security-mode review pins `Claude Opus 4.7` at the prompt level (see `.github/prompts/support/security-review.prompt.md`).

Never pin a single model. Models deprecate monthly. **BYOK (VS Code 1.117+):** Business/Enterprise users can connect their own API keys (OpenRouter, Ollama, Google, OpenAI, and more) via `Settings > Language Models`. BYOK models are additive — insert them into agent fallback chains by adding them to each agent's `model:` frontmatter array.

---

## Permission & Complexity Tier Matrix

Maps the conductor's complexity tiers to Copilot CLI permission modes and per-agent Autopilot safety. Closes gaps G2 and G33.

| Complexity tier | Conductor path | Copilot CLI permission | Autopilot allowed? | Notes |
|-----------------|----------------|------------------------|--------------------|-------|
| INSTANT         | Implementer direct | Bypass Approvals    | Yes (pro/pro-plus/enterprise only) | Single-file reads/edits; no multi-phase ceremony |
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
| pro | Autopilot permitted for INSTANT tier only |
| pro-plus | Autopilot permitted for INSTANT and read-only STANDARD |
| enterprise | Autopilot permitted (ratified 2026-04-22); security review remains human-confirmed |

---

## Nested Subagent Allow-List

Per [ADR](artifacts/plans/close-all-gaps/phase-2-nested-subagents.md) — the `chat.subagents.allowInvocationsFromSubagents` setting (VS Code March 2026) is enabled for these edges only, with depth capped at 2:

| Parent -> Child | Rationale |
|-----------------|-----------|
| implementer -> test | Implementer authors code; test agent adds coverage |
| implementer -> researcher | Mid-task library question without full conductor relay |
| reviewer -> researcher | Evidence gathering for a finding |
| reviewer -> reviewer[security] | Standard review escalates to security mode |
| planner -> researcher | One more piece of evidence to finalize a phase |
| translation-conductor -> translator | Per-file dispatch |
| translation-conductor -> translation-analyzer | Mid-translation dependency analysis |

All other edges relay through the conductor. Explicitly denied: `implementer -> reviewer`, `implementer -> implementer`, `* -> conductor`, `reviewer -> implementer`, `ops -> *`, `gui-tester -> *`. Depth > 2 forces conductor relay. Every nested invocation emits `artifacts/sessions/hooks/nested-call.jsonl` with `{parent, child, depth, purpose, ts}`.

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
| Pester tests (fast) | `Invoke-Pester -Path tests -ExcludeTag Slow -Output Detailed` |
| Pester tests (full, CI) | `Invoke-Pester -Path tests -Output Detailed` |

**Shell**: Windows PowerShell 5.1. Use `;` when chaining commands.

---

## Using with Copilot CLI

Agents load automatically in Copilot CLI sessions (VS Code 1.113+). MCP servers configured in `.vscode/mcp.json` bridge to CLI sessions.

```bash
# Start a CLI session with agent context
copilot chat --agent conductor

```

### CLI Command Affinity

Agents declare `cli-affinity:` in frontmatter listing Copilot CLI slash commands they prefer when available. Falls back to internal orchestration when the command is absent (pre-1.113 VS Code, non-CLI surfaces).

| Agent | Key commands | Purpose |
|-------|--------------|---------|
| conductor | `/fleet`, `/tasks`, `/delegate`, `/compact`, `/model`, `/context`, `/usage`, `/remote` | Native parallel subagents, task surfacing, budget metrics, long-run sessions |
| planner | `/plan`, `/research`, `/context` | Authoring surface for multi-phase plans |
| researcher | `/research`, `/ask`, `/share` | First-pass investigation, side-questions, gist publishing |
| reviewer | `/review`, `/diff`, `/pr` | Baseline findings layered with confidence scoring and security mode |
| ops | `/pr`, `/diff`, `/delegate`, `/share` | PR workflow; `gh` CLI remains the fallback |
| implementer | `/ide`, `/diff`, `/rewind`, `/undo`, `/ask` | IDE bridge, safe TDD revert, side-questions |

`/fleet` coexists with our `team-state.json` telemetry: the native command drives execution, hook JSONL feeds analytics. Validator warns on unknown `cli-affinity` entries (warn-only — CLI surface evolves).

**Terminal tool scope (VS Code 1.116+):** `send_to_terminal` and `get_terminal_output` now work with any **foreground terminal** visible in the terminal panel — not just agent-spawned background terminals. This means agents can read from and write to running REPLs, interactive scripts, and SSH sessions without having launched them. Useful for `implementer` and `ops` workflows involving pre-existing terminals.


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

## Copilot Memory

VS Code Copilot Memory (GA 1.111) lets agents and instructions persist knowledge across sessions. Enabled via `"github.copilot.chat.copilotMemory.enabled": true` in `.vscode/settings.json`.

### What to store

- Naming conventions and shell idioms specific to this repo
- Verified build/test invocation patterns and quirks
- Architectural constraints or decisions that affect everyday coding
- Model tier allocation decisions with rationale

### What to skip

- Current branch, today's error count, in-flight session context
- Anything already documented in `AGENTS.md` or instruction files
- Secrets, tokens, or PII

### Memory scopes

| Scope | Path | Loaded automatically? | Purpose |
|-------|------|-----------------------|---------|
| User | `/memories/` | Yes (first 200 lines) | Cross-workspace preferences, patterns |
| Session | `/memories/session/` | No (read on demand) | In-progress notes, task context |
| Repository | `/memories/repo/` | No (read on demand) | Codebase-specific facts via Copilot Memory API |

---

## Skills Ecosystem

Our SKILL.md files follow the [agentskills.io specification](https://agentskills.io/specification) (`name` + `description` frontmatter — both required). This makes them compatible with the cross-agent skills ecosystem (GitHub Copilot, Claude Code, Cursor, Codex, Gemini CLI).

> **Publishing status:** Our 12 skills are **not yet published** to a marketplace. See `artifacts/decisions/ADR-sota-2026-04-22-remaining-gaps.md` §G65 for the deferred publishing decision. The commands below apply once we publish or for installing *other* community skills.

### Managing Skills with GitHub CLI

GitHub CLI v2.90.0+ (April 2026) provides `gh skill` as the canonical interface. Install or update `gh` CLI before using these commands.

```bash
# Discover skills in a repository
gh skill search mcp-apps

# Install a community skill interactively
gh skill install github/awesome-copilot

# Install a specific skill (and pin to a release tag for supply chain integrity)
gh skill install github/awesome-copilot documentation-writer --pin v1.2.0

# Target a specific agent host
gh skill install github/awesome-copilot documentation-writer --agent claude-code

# Check for and apply updates
gh skill update --all

# Validate and publish (for skill authors)
gh skill publish --fix
```

Community skills install to `.github/skills/` and are auto-discovered by agents. Run `gh skill preview <skill>` to inspect content before installation — skills can contain executable instructions.

**Supply chain guarantees:** `gh skill` records tree SHA provenance in `SKILL.md` frontmatter and supports version pinning (`--pin`). Use pinned installs in production to prevent silent upstream changes.

**Supported agent hosts:** `--agent copilot` (default), `--agent claude-code`, `--agent cursor`, `--agent codex`, `--agent gemini`.

### Context7 Integration

Agents with the Context7 MCP server (`implementer`, `researcher`) can fetch up-to-date library documentation directly into prompts. Use `resolve-library-id` → `query-docs` or add `use context7` to prompts.

---

## Contribution Protocol

1. Update docs alongside code/instruction changes
2. Run `validate-copilot-assets.ps1` before committing
3. Capture changes in `docs/CHANGELOG.md`
4. For agent changes, include sample session exports
