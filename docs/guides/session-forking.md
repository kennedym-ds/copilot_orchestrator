---
version: 1.0.0
lastUpdated: 2026-04-22
---

# Session Forking

Copilot supports forking a chat session to explore alternatives without losing context. This is distinct from forking a repository branch.

## Concept

| Forking concept | Scope | Persistence | Use case |
|-----------------|-------|-------------|----------|
| **Repository branch** | Git refs | Committed history | Long-lived feature work, releases |
| **Session fork** | Chat state | In-memory + `artifacts/sessions/` | Explore "what if" during implementation |

## When to fork a session

- Partway through a plan, you want to try an alternative approach without abandoning the main thread
- A reviewer finding suggests two possible mitigations — fork once per candidate, compare outcomes
- Debugging: fork before running a risky tool invocation so you can revert cleanly

## How (VS Code Chat)

1. Right-click the session in the Chat sidebar -> Fork Session
2. VS Code duplicates the transcript and gives the fork a new ID
3. Changes in the fork do not affect the parent session

## How (Copilot CLI)

Cross-session memory (February 2026) lets you reference a prior session by ID:

```bash
copilot chat --agent conductor --resume <session-id>
```

To fork: resume with `--fork`:

```bash
copilot chat --agent conductor --resume <session-id> --fork
```

## Interaction with orchestrator artifacts

- Each session's `artifacts/sessions/<id>.json` remains canonical for that branch of reasoning
- The conductor writes `activeContext.md` on pause; fork children inherit the parent snapshot
- When a fork produces the "winning" approach, the user may choose to merge notable findings back into the parent session's `activeContext.md` manually

## Related

- [copilot-cli-usage.md](copilot-cli-usage.md)
- [../../artifacts/memory/activeContext.md](../../artifacts/memory/activeContext.md)

Closes gap G8 from the SOTA gap analysis.