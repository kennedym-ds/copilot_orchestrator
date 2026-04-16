---
title: "Operations & Continuous Improvement Plan"
version: "3.0.0"
lastUpdated: "2026-04-16"
status: active
---

# Operations Playbook

## Monitoring

- **Weekly** – Review conductor transcripts for adherence to pause points and instruction compliance.
- **Monthly** – Run validation scripts, prune unused prompts, refresh AGENTS.md.
- **Quarterly** – Host retrospectives to assess model allocations, cost usage, and workflow effectiveness.

### Token Budget Status

**Last Updated:** 2026-04-16
**Current Status:** ⚠️ 2 FILES OVER LIMIT

**Per-File Token Limit:** 10,000 tokens (primary enforcement)
**Rationale:** Agents load specific files per-context, not all files at once.

**Current Totals:**
```
Total:        ~213,000 tokens
Agents:        ~30,000 tokens (16 files)
Docs:          ~96,000 tokens
Instructions:  ~78,000 tokens
Prompts:       ~10,000 tokens
```

**Action Items:**
1. **Immediate:** Monitor 2 files exceeding 10k token limit (vscode-copilot-configuration.md, CHANGELOG.md)
2. **Short-term:** Enable Agent Skills pilot to evaluate on-demand loading benefits
3. **Medium-term:** Establish 8k token soft limit for new documentation
4. **Long-term:** Migrate heavy instruction content to skill modules

**Agent Skills Pilot Timeline:**
- Phase A (Week 1-2): Baseline measurement with always-on instructions
- Phase B (Week 3-4): Pilot with Agent Skills enabled
- Phase C (Week 5): Analysis and Go/No-Go decision
- See: `docs/guides/agent-skills-pilot.md`

---

## Metrics

### Workflow Effectiveness

- **Adoption rate** — Percentage of work executed via Conductor workflow vs. ad-hoc development.
- **Validation pass rate** — CI workflow success vs. failures.
- **Average phase duration** — Planning, implementation, review durations vs. baseline.
- **Incident count** — Policy/security issues per sprint.

### Multi-Tier Model Effectiveness

**Cost Efficiency Metrics:**
- **Premium vs. execution tier ratio** — Target: 15% premium / 75% execution / 10% fast. Track actual ratio weekly.
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

| Item | Owner | Status |
|------|-------|--------|
| Add JSON output mode to token report | Tooling | Planned |
| Implement escalation metrics tracking dashboard | Tooling | Planned |
| Pilot dynamic escalation in low-risk workflows | Platform Guild | Planned |
| Evaluate model re-evaluation cadence for new releases | Operations | Planned |
| Expand Context7 MCP coverage to additional libraries | MCP Guild | Planned |
| Wiki memory retention policy and search tooling | Platform Guild | Planned |
| Skills ecosystem integration testing | Skills Guild | Planned |

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
