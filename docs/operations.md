---
title: "Operations & Continuous Improvement Plan"
version: "3.1.0"
lastUpdated: "2026-04-22"
status: active
---

# Operations Playbook

## Monitoring

- **Weekly** – Review conductor transcripts for adherence to pause points and instruction compliance.
- **Monthly** – Run validation scripts, prune unused prompts, refresh AGENTS.md.
- **Quarterly** – Host retrospectives to assess model allocations, cost usage, and workflow effectiveness.

### Token Budget Status

**Per-File Token Limit:** 10,000 tokens (primary enforcement)
**Rationale:** Agents load specific files per-context, not all files at once.

Run the token report before each release to check current status:

```powershell
pwsh -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

Files historically over the 10k limit: `vscode-copilot-configuration.md`, `CHANGELOG.md`. Monitor these after doc updates.

**Policy:**
1. New documentation: target 8k token soft limit
2. Files exceeding 10k: split or migrate heavy content to skill modules
3. Agent Skills provide on-demand loading — prefer skills over always-on instructions for reference material

---

## Metrics

### Workflow Effectiveness

- **Adoption rate** — Percentage of work executed via Conductor workflow vs. ad-hoc development.
- **Validation pass rate** — CI workflow success vs. failures.
- **Average phase duration** — Planning, implementation, review durations vs. baseline.
- **Incident count** — Policy/security issues per sprint.

### Multi-Tier Model Effectiveness

**Cost Efficiency Metrics:**
- **Premium vs. execution tier ratio** — Target: ~6% premium (Planner) / ~75% execution / ~19% fast. Track actual ratio weekly.
- **Cost per completed phase** — Total model costs divided by phases completed successfully.
- **Cost per agent type** — Break down costs by Conductor, Planner, Implementer, Reviewer, Researcher, Ops, Test, IaC, GUI Tester, Docs, UX.
- **Budget variance** — Actual spend vs. projected spend; alert when >10% over budget.

**Quality Metrics:**
- **Review rejection rate** — Percentage of phases rejected by Reviewer.
- **Pushback cycle count** — Average pushback cycles per phase (target: <2).
- **Confidence score trends** — Track confidence levels on review findings.
- **Evidence verification success** — Percentage of tests passing on first run.

**Model Availability:**
- **Primary model uptime** — Availability percentage by model type.
- **Fallback invocation frequency** — How often fallback models used vs. primary.
- **Fallback success rate** — Percentage of successful completions when using 1st, 2nd, 3rd fallback.

### Data-Driven Model Allocation

**Weekly Review:**
- Check tier distribution; adjust agent defaults if consistently off-target.
- Review pushback patterns; identify common failure modes.
- Monitor fallback usage; escalate reliability concerns.

**Monthly Review:**
- Analyze cost per phase trends; optimize prompts or model selection if costs rising.
- Compare before/after metrics for new features (pushback, risk classification, evidence verification).
- Evaluate new model releases for potential inclusion.

**Quarterly Review:**
- Assess model-task fit data; update default model assignments in agent definitions.
- Fine-tune cost-efficient models on successful patterns if data available.
- Adjust fallback chains based on empirical reliability and performance data.

---

## Incident Response

- Classify incidents (operational, policy, security).
- Escalate security breaches and open tracking tickets.
- Disable problematic agents/prompts via repo settings until resolved.
- Document post-incident reviews and remediation steps.


---

## Backlog

| Item | Owner | Status | Gap |
|------|-------|--------|-----|
| Agent-quality eval harness (SWE-bench-style fixture set) | Platform Guild | Deferred — see ADR-sota-2026-04-22-remaining-gaps.md | G58 |
| MCP Task Augmentation — async `tasks/result` for long-running tools | MCP Guild | Deferred — blocked on mcp SDK v1.x stable | G59 |
| Semantic firewall pre-tool pattern matching | Security Guild | Deferred — blocked on VS Code `chat.tools.preApprovalHook` API | G63 |
| Publish 12 Agent Skills to skills.sh catalogue | Operations | Deferred — needs OWNER decision on license/support scope | G65 |
| Community catalogue drift audit (obra/superpowers, skills.sh) | Researcher | Deferred — blocked on G65 | G66 |
| Add JSON output mode to token report | Tooling | Planned | — |
| Implement escalation metrics tracking dashboard | Tooling | Planned | — |
| Pilot dynamic escalation in low-risk workflows | Platform Guild | Planned | — |
| Expand Context7 MCP coverage to additional libraries | MCP Guild | Planned | — |
| Wiki memory retention policy and search tooling | Platform Guild | Planned | — |
| Next SOTA review | Operations | Target: 2026-07 | — |

---

## Tooling

- Validation scripts (PowerShell) under `scripts/`.
- MCP servers (Python) under `scripts/mcp/`.
- Token budget reporting integrated with CI.
- Session analytics via `analyze-sessions.ps1`.
- Pester-based regression tests under `tests/powershell/`.

---

## Instruction Hygiene

- Scope `applyTo` globs narrowly (e.g., `**/*.{md,ps1,yml,json}`) to avoid loading instructions for binary assets while keeping coverage for scripted and documentation artifacts.
- Maintain distinct overlays for behavior, security, and compliance to keep context modular; update the `description` fields when semantics change.
- Review instruction impact quarterly to ensure new file types are explicitly opted-in rather than inheriting global defaults.
- Introduce language-specific guardrails (e.g., `instructions/languages/python.instructions.md`) when languages enter the workspace so contextual guidance stays relevant and lightweight.

Update this document as workflows mature and automation lands.
