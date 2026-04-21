---
name: "quality-baseline"
description: "Repository-wide definition of done, simplicity checklist, quality expectations, and model allocation."
applyTo: "**"
version: "3.0.0"
lastUpdated: "2026-04-16"
---

# Quality Expectations

## Understand First

- Before proposing changes, understand the problem space: root causes, existing constraints, and prior art in the codebase.
- Read sufficient source context (roughly 2,000 surrounding lines) before editing to account for edge cases, cross-cutting concerns, and hidden coupling.
- Record open questions or assumptions when information is missing so they can be resolved before completion.

## Simplicity Checklist

Apply these questions at every decision point:

- **Does this need a new abstraction?** Only if 3+ call sites would benefit and the abstraction is obvious.
- **Does this need a new dependency?** Only if building it yourself costs more than the dependency's maintenance burden.
- **Can the existing pattern handle it?** Extend before you invent.
- **Is this the simplest solution that works?** If not, justify the added complexity with a concrete scenario.
- **Can someone understand this at 2am with no context?** If not, simplify or document.

## Definition of Done

- Always verify success criteria: functional correctness, regression safety, observability, documentation updates.
- Prefer incremental, testable changes; identify validation steps (unit, integration, e2e) before proposing implementation.
- Flag missing tests or monitoring as risks and offer concrete follow-up actions.
- Optimize for maintainability: clear naming, modular design, minimal duplication, and rationale for non-obvious decisions.
- Treat performance, accessibility, and security as first-class concerns; raise potential issues even if requirements omit them.
- Reject hype-driven decisions. Justify every tool, pattern, or dependency with a concrete problem it solves. "Industry best practice" is not a justification without context.
- Build and maintain a markdown TODO list (triple backticks, checkbox syntax) that tracks planned steps and reflects status updates throughout execution.
- Perform live research for every user-provided URL or external dependency using browser tools; do not rely on stale context or partial summaries.
- Run available tests and validation scripts after each meaningful change, repeat them once fixes land, and document any remaining coverage gaps or flaky suites.

## Examples

**Good** â€” validates before and after:
```powershell
# Run validation before changes
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
# Make changes...
# Run validation after changes
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
```

**Bad** â€” skips validation:
```powershell
# Make changes...
git add -A; git commit -m "done"
# (no validation run â€” bugs may be committed)
```

## Model Allocation

All agents use fallback arrays in frontmatter `model:` and a `defaultEffort:` hint. VS Code picks the first available model.

| Tier | Agents | Primary -> Fallback | Typical effort |
|------|--------|---------------------|----------------|
| **Premium** | Planner | Claude Opus 4.6 -> Claude Opus 4.7 -> Claude Sonnet 4.6 | high |
| **Execution** | Conductor, Reviewer, Implementer, Researcher, Ops, Test, IaC, GUI Tester, Translation Conductor, Translator, Translation Analyzer, Translation Validator | Claude Sonnet 4.6 -> GPT-5.4 -> GPT-5.3-Codex | low / medium / high |
| **Fast** | Docs, UX, Translation Styler | Claude Haiku 4.5 -> GPT-5.4 mini -> GPT-5 mini | low / medium |

- Never pin a single model. Models deprecate monthly.
- If all fallbacks fail, escalate to the conductor.
- Premium tier for judgment-critical work only (~6% of default invocations).
- Security-mode review overrides the reviewer's array and pins `Claude Opus 4.6` at the prompt level (`.github/prompts/support/security-review.prompt.md`).
- `defaultEffort` is a second dial: model sets the ceiling, effort sets the spend per call. Prompts may override with `effort:`.