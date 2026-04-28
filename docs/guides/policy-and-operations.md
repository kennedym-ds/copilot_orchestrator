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

**1.116 update**: `github.copilot.chat.agentDebugLog.fileLogging.enabled` now persists historical session logs on disk. `/troubleshoot` can reference any past session (not just the current one), so cross-session root-cause work no longer requires replaying. The PowerShell script remains the CI path because JSON under `artifacts/sessions/` is version-controlled metadata, orthogonal to per-user debug logs.

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

**Billing note (June 1, 2026)**: GitHub's automated PR code review ("Request Copilot review" button) now consumes **both AI Credits and GitHub Actions minutes**. The Reviewer agent invoked via chat uses only AI Credits. If your org uses both surfaces, account for the Actions minute spend separately from the AI credit budget.

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

**1.116 update**: Copilot CLI sessions gained the model-picker thinking-effort control (parity with 1.113 local sessions). The 3-cap applies to subagent fan-out only; thinking effort is orthogonal - per-turn reasoning depth, not parallelism. See [copilot-cli-usage.md](copilot-cli-usage.md#thinking-effort-1116).

---

## 6. LTS vs preview model policy (G19)

Copilot's model matrix includes models at different lifecycle stages (GA, preview, deprecated). We do not currently annotate this in agent `model:` fallback arrays.

**Policy**
- **Enterprise branch**: first model in each fallback array must be **GA** (generally available, not in preview). Preview models may be second or later.
- **Pro branch**: preview models may appear first, provided a GA fallback exists.
- **Security review**: always GA, per the prompt-level override in `.github/prompts/support/security-review.prompt.md`.

Annotation is informal (comment in the YAML when a model is in preview). Formal LTS marking awaits `chatLanguageModels.json` adoption — see [ADR-chatLanguageModels](../../artifacts/decisions/ADR-chatLanguageModels.md).

---

## 7. Agent firewall guidance (Enterprise) (G20, refreshed for 1.116)

Two layers of egress control now apply:

1. **Coding-agent firewall** (org-level, pre-existing) - allowlist applied to the Copilot Coding Agent.
2. **VS Code 1.116 agent network filter** (group policy) - allow/deny domain lists enforced on the `fetch` tool, integrated browser, and (when `chat.agent.sandbox.enabled` is on) the terminal sandbox.

**Group policy keys** (1.116):

| Key | Setting | Purpose |
|---|---|---|
| `ChatAgentNetworkFilter` | `chat.agent.networkFilter` | Enable the filter |
| `ChatAgentAllowedNetworkDomains` | `chat.agent.allowedNetworkDomains` | Allowlist (wildcards `*.example.com`) |
| `ChatAgentDeniedNetworkDomains` | `chat.agent.deniedNetworkDomains` | Blocklist (precedence over allow) |

When the filter is enabled and both lists are empty, **all domains are blocked**.

**Recommended default allowlist** (applies to both layers):
- `api.githubcopilot.com` - hosted MCP server
- `api.github.com`, `*.github.com` - PR / issue / raw content APIs
- `registry.npmjs.org`, `pypi.org`, `*.pythonhosted.org` - dependency fetches during implementer sessions
- `raw.githubusercontent.com` - research agent fetches of vscode-docs release notes
- Provider endpoints for configured LLMs (routed via Copilot's own managed endpoints)

**Blocked by default**: everything else. Research agent uses `ddgs` via the research MCP - that flow is proxied and does not need explicit allowlisting.

**Operational note**: firewall config lives in org settings / group policy, not in this repo. This section documents **recommended defaults**, not the enforcement mechanism.

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

## 9. Pooled org-wide AI Credits (Business/Enterprise, June 1, 2026)

As of June 1, included AI Credits are **pooled across the organization** — unused credits from one member's allocation are available to others in the same org. This eliminates the previous problem of isolated per-seat credits going to waste.

**Impact on org-level deployment:**
- The total org credit budget is `seats × per-seat included amount` (e.g., 10-seat Enterprise = 10 × $39 = $390/month pooled).
- Heavy orchestrator users (planner + reviewer cycles) now draw from the shared pool rather than their own seat allocation. High-volume users can exhaust org credits faster than with isolated buckets.
- Monitor aggregate org credit consumption in GitHub org settings → Copilot → Usage, not just individual seat usage.

**Policy**: flag in the rollout plan (§8 step 4 "Soak on one team first") that soak-period usage is pooled, so a single power-user team can silently affect the budget of the wider org.

---

## 10. GitHub-native budget controls (Business/Enterprise)

GitHub now provides platform-level budget controls at three scopes:
- **Enterprise level** — aggregate cap across all orgs in the enterprise
- **Cost center level** — budget per team or department
- **User level** — per-seat spending cap

**Relationship to the budget-gatekeeper skill:**

| Layer | Scope | Enforcement | Configured in |
|-------|-------|-------------|---------------|
| GitHub platform controls | Org/enterprise billing | Hard stop or overage charge | GitHub org settings → Copilot |
| Budget-gatekeeper skill | Session / conductor workflow | Soft/hard limits on delegations and tokens | `budget-gatekeeper/SKILL.md` |

Configure platform controls **before** the June 1 transition. The gatekeeper is a development-time guardrail; platform controls are the billing authority. Both should be set.

**Policy**: enterprise admins must explicitly decide whether to allow overage billing (usage continues at published per-token rates after included credits are exhausted) or cap spending (usage blocked). Default is block. Set this in org Copilot settings.

---

**Related docs**
- [onboarding.md](onboarding.md) — contributor setup
- [central-deployment.md](central-deployment.md) — workspace-level symlink / parent-folder discovery
- [copilot-cli-usage.md](copilot-cli-usage.md) — CLI session mechanics
- [model-tiers.md](model-tiers.md) — model fallback arrays

**Change policy**: update this file when any of the 8 referenced gaps need a policy revision. Keep sections short — escalate to a dedicated guide if a section grows past ~40 lines.
