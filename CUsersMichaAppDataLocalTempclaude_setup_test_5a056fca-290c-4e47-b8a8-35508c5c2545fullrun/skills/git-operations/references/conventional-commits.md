# Conventional Commits Reference

Standard commit format used across the copilot orchestrator repository.

## Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

## Type Prefixes

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature or capability | `feat(agents): add red-team agent` |
| `fix` | Bug fix | `fix(conductor): correct phase counter overflow` |
| `docs` | Documentation only | `docs(guides): update onboarding steps` |
| `style` | Formatting, whitespace (no logic change) | `style(prompts): normalize frontmatter spacing` |
| `refactor` | Code restructuring (no behavior change) | `refactor(scripts): extract validation helpers` |
| `test` | Adding or updating tests | `test(pester): add token-report threshold tests` |
| `chore` | Maintenance, tooling, config | `chore(deps): update requirements.txt` |
| `ci` | CI/CD pipeline changes | `ci(workflows): add agent validation step` |
| `perf` | Performance improvement | `perf(token-report): cache file reads` |
| `build` | Build system or dependencies | `build(scripts): add PowerShell module manifest` |
| `revert` | Reverts a previous commit | `revert: revert "feat(agents): add red-team agent"` |

## Scopes (Project-Specific)

| Scope | Applies To |
|-------|-----------|
| `agents` | `.github/agents/` — agent definition files |
| `prompts` | `.github/prompts/` — prompt templates |
| `skills` | `.github/skills/` — skill definitions and references |
| `instructions` | `instructions/` — global, workflow, compliance, language instructions |
| `scripts` | `scripts/` — PowerShell validation and tooling |
| `docs` | `docs/` — guides, templates, changelogs |
| `conductor` | Changes to `conductor.agent.md` specifically |
| `plans` | `plans/` or `artifacts/plans/` — plan artifacts |
| `tests` | `tests/` — Pester and other test files |
| `mcp` | MCP server configuration and tools |
| `deps` | Dependency changes (requirements.txt, modules) |

## Breaking Changes

Use `!` after the type/scope, and add a `BREAKING CHANGE:` footer:

```
feat(agents)!: remove deprecated infer field from all agents

BREAKING CHANGE: Agents no longer support the `infer` frontmatter field.
Use `user-invokable` and `disable-model-invocation` instead.
```

## Multi-Line Body

Wrap at 72 characters. Explain *what* and *why*, not *how*:

```
fix(reviewer): prevent duplicate finding entries

The reviewer agent was appending findings to the artifact file
without checking for existing entries with the same hash. This
caused duplicate entries when review was re-run after revisions.

Closes #142
```

## Footer Tokens

| Token | Purpose | Example |
|-------|---------|---------|
| `Closes` | Auto-close GitHub issue | `Closes #42` |
| `Fixes` | Auto-close (alternative) | `Fixes #42` |
| `Refs` | Reference without closing | `Refs #42, #43` |
| `BREAKING CHANGE` | Breaking change description | `BREAKING CHANGE: removed X` |
| `Co-authored-by` | Credit co-authors | `Co-authored-by: Name <email>` |
| `Reviewed-by` | Credit reviewers | `Reviewed-by: Name <email>` |

## Quick Examples

```bash
# Simple feature
git commit -m "feat(skills): add bundled reference assets to 6 skills"

# Fix with issue reference
git commit -m "fix(conductor): resolve state tracking reset on phase retry

Closes #87"

# Docs update
git commit -m "docs(changelog): add v2.1.0 release notes"

# Multi-scope (use most relevant scope)
git commit -m "refactor(agents): standardize handoff definitions across core agents"
```
