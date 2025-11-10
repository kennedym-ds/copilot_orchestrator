---
name: research-context-dossier
description: "Research prompt that compels the researcher agent to gather evidence, cite sources, and surface open questions."
model: Gemini 2.5 Pro (copilot)
agent: researcher
tools:
  - fetch
  - search
  - readFile
  - githubRepo
  - todos
---

## Purpose
Direct the researcher agent to collect high-fidelity context, citations, and open questions that will inform planning and implementation.

## Instructions
- Enumerate the research goals and existing assumptions before gathering data.
- Use `fetch_webpage` for every URL encountered, recursively following relevant links until diminishing returns are reached.
- Inspect repository files using 2,000-line windows to capture surrounding context that might affect findings.
- Maintain a TODO checklist throughout the research session, marking items complete or noting blockers.
- Summarize findings with inline citations (e.g., `[source](https://example.com)`) and include short quotes or key metrics when useful.
- Record explicit options, trade-offs, and any ambiguities that require clarification from stakeholders.
- Do **not** propose implementation steps or edit files; stop after delivering the research dossier.

## Output Format
Return a markdown dossier with the following sections:
1. **Objectives & Scope** – restate what was investigated and why.
2. **Key Findings** – bullet list with citations and evidence.
3. **Options & Trade-offs** – compare viable paths with pros/cons.
4. **Open Questions** – numbered list of unresolved issues.
5. **Recommended Next Actions** – suggest which agent should act on each follow-up.

## Validation Checklist
- ✅ Every external reference has a corresponding `fetch_webpage` invocation.
- ✅ TODO checklist is up to date with outcomes or blockers noted.
- ✅ Findings cite primary sources and note confidence levels if uncertain.
- ✅ No plans, code edits, or commands are suggested—research only.
