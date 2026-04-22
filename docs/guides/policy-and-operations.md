# Policy & Operations Reference

Consolidated reference for policy decisions and operational conventions that don't warrant their own guide. Each section closes one gap from the 2026-04-22 SOTA gap analysis.

**Audience**: Contributors working on conductor, reviewer, ops, and enterprise-branch deployments.
**Status**: Living document — update when the underlying platform or convention changes.

---

## 1. `/troubleshoot` vs `analyze-sessions.ps1` (G7)

Both analyse agent debug output. They are **not** redundant — they serve different surfaces.

| Surface | Tool | When to use |
|---------|------|-------------|
| Interactive chat (VS Code) | `/troubleshoot` | Day-to-day debugging during a live session. Reads the current session's debug log. |
| CI / batch | `scripts/analyze-sessions.ps1` | Scheduled or PR-time aggregation across `artifacts/sessions/*.json`. Emits JSON for downstream tooling. |

**Policy**: `/troubleshoot` is the primary UX. The PowerShell script stays for CI and for offline analysis (where the chat session is no longer available). Neither tool is deprecated.

---

## 2. Copilot Spaces adoption (G11)

Copilot Spaces (collaborative shared-knowledge surface) could host cross-repo conventions. Decision: **filesystem remains single source of truth for code-adjacent artefacts** (ADRs, plans, reviews).

**Rationale**
- `artifacts/decisions/` is audit-grade and git-tracked. A Space cannot replace git history.
- Cross-repo discovery is better served by `AGENTS.md` + `llms.txt` + the monorepo parent-folder walker.
- A Space *may* be adopted later for **pre-ADR discussion** (brainstorming that doesn't need commits). Not in scope today.

**Revisit trigger**: three or more sibling repos adopt the same ADR conventions.

---

## 3. Standalone code-review repo rule vs Reviewer agent (G15)

Two review surfaces exist:

| Surface | Scope | Artefact |
|---------|-------|----------|
| Reviewer agent (`reviewer.agent.md`) | Chat-level; severity-tagged findings | `artifacts/reviews/*.md` |
| Standalone code-review repo rule | CI gate; blocks merge | PR check |

**Policy**: they do **not** conflict. The repo rule can consume Reviewer artefacts — a PR description that links to `artifacts/reviews/<date>-<slug>.md` satisfies the reviewer-evidence requirement. Security-mode review (Opus pinned) always runs regardless of the CI gate.

**Operational note**: CI runs in `.github/workflows/ci/validate.yml`. The standalone repo rule (if enabled at the org level) is complementary, not duplicative.

---

## 4. Skills ecosystem audit (G16)

Our 12 skill modules under `.github/skills/` claim vercel-labs/skills compatibility. Status as of 2026-04-22:

- **Format**: compatible — `SKILL.md` frontmatter (`name`, `description`) matches the standard.
- **Discovery**: Compatible via `npx skills find` (community catalog).
- **Gaps**: we have not published our skills to the community catalog — intentional; several reference repo-specific scripts.
- **Catalog drift**: community catalog at `claudeskills.info` has moved faster than our inventory. No action — we adopt selectively, not wholesale.

**Policy**: do not auto-install community skills. Review each for repo-script dependencies and security posture before adding.

---

## 5. Parallel task execution limits (G18)

Budget gatekeeper caps concurrent subagent invocations at **3**. Origin and rationale:

- Copilot CLI supports arbitrary parallel subagent fan-out.
- The cap of 3 is convention-driven, not measured — based on the typical heavy-tier token cost of spinning 4+ agents on a single plan.
- Teams (review-team, research-team, implement-team) are opt-in and explicitly exempt from the 3-cap when `ORCH_TEAMS_ENABLED=true` — see `AGENTS.md` team section.

**Policy**: keep the 3-cap for default subagent delegation. If telemetry shows the cap throttling legitimate workflows, raise by increments of 1 with a CHANGELOG entry.

---

## 6. LTS vs preview model policy (G19)

Copilot's model matrix includes models at different lifecycle stages (GA, preview, deprecated). We do not currently annotate this in agent `model:` fallback arrays.

**Policy**
- **Enterprise branch**: first model in each fallback array must be **GA** (generally available, not in preview). Preview models may be second or later.
- **Pro / Free branches**: preview models may appear first, provided a GA fallback exists.
- **Security review**: always GA, per the prompt-level override in `.github/prompts/support/security-review.prompt.md`.

Annotation is informal (comment in the YAML when a model is in preview). Formal LTS marking awaits `chatLanguageModels.json` adoption — see [ADR-chatLanguageModels](../../artifacts/decisions/ADR-chatLanguageModels.md).

---

## 7. Agent firewall guidance (Enterprise) (G20)

Copilot Coding Agent supports a customizable firewall (egress allowlist). For the `enterprise` branch:

**Recommended default allowlist**
- `api.githubcopilot.com` — hosted MCP server (when adopted)
- `api.github.com` — PR / issue APIs used by `github-pr` / `github-issue` integration agents
- `registry.npmjs.org`, `pypi.org` — dependency fetches during implementer sessions
- Provider endpoints for any configured LLMs (Anthropic, OpenAI) — via Copilot's own managed endpoints

**Blocked by default**
- Arbitrary web hosts. Research agent uses `ddgs` through the research MCP — that flow is proxied.
- Any host not on the allowlist above.

**Operational note**: firewall config lives in the org settings, not this repo. This section documents the **recommended defaults**, not the enforcement mechanism.

---

## 8. Org-level agent deployment runbook (G30)

Distributing this orchestrator across an organisation via `organizationInstructions`:

**Prerequisites**
- Org admin access to GitHub Copilot settings.
- A "golden" repo in the org (typically `.github` or a dedicated `copilot-config` repo) where `organizationInstructions` references live.

**Steps**
1. **Audit**: run `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` — must be green.
2. **Copy the canonical set** to the golden repo:
   - `.github/agents/*.agent.md`
   - `.github/skills/**`
   - `instructions/global/*` (do not copy workflow-specific overlays)
   - `AGENTS.md`
3. **Point `organizationInstructions`** at the golden repo in org Copilot settings.
4. **Soak on one team first** (the `enterprise` branch's source repo is the reference). Watch for 48h.
5. **Roll out** across teams. New repos inherit automatically.

**Rollback**: clear `organizationInstructions` in org settings. Workspace-level `.github/` files in individual repos remain authoritative.

**Do not** distribute `.github/prompts/` or `.vscode/mcp.json` at the org level — those are workspace-specific.

---

**Related docs**
- [onboarding.md](onboarding.md) — contributor setup
- [central-deployment.md](central-deployment.md) — workspace-level symlink / parent-folder discovery
- [copilot-cli-usage.md](copilot-cli-usage.md) — CLI session mechanics
- [model-tiers.md](model-tiers.md) — model fallback arrays

**Change policy**: update this file when any of the 8 referenced gaps need a policy revision. Keep sections short — escalate to a dedicated guide if a section grows past ~40 lines.