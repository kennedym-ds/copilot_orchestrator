---
name: code-topology
description: "Structured protocol for understanding codebase architecture through dependency mapping, call-chain tracing, data-flow analysis, and impact assessment. Use for planning, implementation, review, and any task requiring structural code understanding."
---

# Code Topology — Structural Code Understanding

Provides a structured 5-phase protocol for agents to build and reason about the architectural structure of a codebase using existing tools (`usages`, `search`, `read`, directory listing).

## Description

This skill teaches agents how to systematically map and understand the structure of a codebase before making changes. Instead of the ad hoc "read files and hope" approach, agents follow a repeatable protocol that builds from landscape-level understanding down to function-level impact assessment.

The protocol is inspired by **code topology** — the mathematical study of structural relationships within software systems — and adapts concepts from dependency graphs, call graphs, and data-flow analysis into actionable steps that work with the tools agents already have.

**Key insight**: Agents don't need a full AST parser or specialized tooling to reason about code structure. The `usages` tool, `search`, `read`, and directory listings provide sufficient primitives — what's been missing is a *protocol* for combining them systematically.

## When to Use

This skill is relevant when:
- Planning implementation of a feature that touches multiple files or modules
- Assessing the blast radius of a proposed change
- Debugging a problem that spans multiple components
- Reviewing code changes for structural impact
- Generating a codebase overview for onboarding or documentation
- Investigating security paths (user input → sensitive operations)
- Analyzing test coverage gaps relative to critical paths
- Translating or refactoring code that has cross-cutting dependencies

**Complexity threshold**: Use this skill when the task involves **more than one file** or when the change target has **unknown downstream consumers**. For single-function, single-file edits with no callers, this protocol is overkill.

### When NOT to Use

- Do not use for single-function, single-file edits with no callers — the full 5-phase protocol is overkill for those.
- Do not use for documentation-only changes that have no code dependencies.

## Entry Points

### Trigger Phrases
- "understand this codebase"
- "map the architecture"
- "what's the blast radius"
- "impact analysis"
- "dependency map"
- "how does data flow"
- "trace the call chain"
- "what calls this function"
- "codebase overview"
- "structural analysis"

### Context Patterns
- Agent is about to implement a multi-file change
- Reviewer needs to assess whether a diff has hidden downstream effects
- Planner is scoping a feature that touches unfamiliar code
- Researcher is building a picture of how a system works
- Security agent is tracing data from input to sensitive operations
- Test agent is identifying untested critical paths

## Core Knowledge

### The 5-Phase Protocol

#### Phase 1 — Landscape Survey (Components)

**Goal**: Understand the high-level structure — what modules exist, what they do, where the boundaries are.

**Steps**:
1. **List the directory tree** to identify module boundaries:
   ```
   list_dir at repo root → identify top-level modules
   list_dir for each major module → understand internal structure
   ```

2. **Classify modules** by role:
   | Role | Indicators | Examples |
   |------|-----------|----------|
   | **Core logic** | Business rules, domain models, algorithms | `src/`, `lib/`, `core/` |
   | **Infrastructure** | Database, APIs, external services, messaging | `infra/`, `services/`, `adapters/` |
   | **Configuration** | Build, deploy, environment settings | `config/`, `*.json`, `*.yaml` |
   | **Entry points** | Main files, route handlers, CLI commands, exports | `main.*`, `index.*`, `app.*`, `cli.*` |
   | **Tests** | Test code, fixtures, mocks | `tests/`, `__tests__/`, `*_test.*` |
   | **Utilities** | Shared helpers, common types, constants | `utils/`, `shared/`, `common/` |
   | **Documentation** | Docs, examples, guides | `docs/`, `examples/`, `*.md` |

3. **Identify entry points** — these are where execution begins:
   - Web: route handlers, middleware entry
   - CLI: main function, command parsers
   - Library: exported public API surface
   - Event-driven: event handlers, message consumers

4. **Record the landscape** as a brief summary:
   ```
   Landscape: {N} modules, entry via {X}, core logic in {Y},
   data layer in {Z}, {T} test directories
   ```

**Tools**: `list_dir`, `search` (for `main`, `export`, `app.`, route patterns), `read` (for package manifests)

---

#### Phase 2 — Dependency Mapping (Data/Access)

**Goal**: Understand which modules depend on which others — the "wiring" of the system.

**Steps**:
1. **Find import statements** in the target area:
   ```
   search for: import|require|using|from .+ import|include
   Scope: the module(s) you're investigating
   ```

2. **Build a mental adjacency list**:
   ```
   Module A → depends on [B, C]
   Module B → depends on [D]
   Module C → depends on [D, E]
   Module D → depends on [] (leaf)
   ```

3. **Identify dependency direction**:
   - **Leaves** (no dependencies): types, constants, configs, utility functions
   - **Mid-tier** (some deps): business logic, service classes
   - **Hubs** (many deps): orchestrators, controllers, entry points
   - **Highly-coupled** (many consumers AND dependencies): refactoring risk

4. **Flag structural risks**:
   - **Circular dependencies**: A → B → C → A (search for mutual imports)
   - **God modules**: One file imported by >10 others (high blast radius)
   - **Tight coupling**: Two modules that always change together
   - **Hidden dependencies**: Runtime reflection, dynamic imports, configuration-driven wiring

5. **Record the dependency map** as a brief summary:
   ```
   Dependencies: {N} leaf modules, {M} mid-tier, {K} hubs
   Key hub: {file} (imported by {X} files)
   Risk: {circular dep | god module | none detected}
   ```

**Tools**: `search` (import/require patterns), `read` (disambiguate dynamic imports), `usages` (verify who imports a module)

---

#### Phase 3 — Function-Level Understanding (Functions/Blocks)

**Goal**: For the specific area being changed, understand the call chain from entry point to implementation detail.

**Steps**:
1. **Identify the target symbol(s)** — the function, class, or module being changed.

2. **Trace callers (who calls this?)**:
   ```
   usages on target function → list all call sites
   For each caller: is it an entry point, middleware, business logic, or utility?
   ```

3. **Trace callees (what does this call?)**:
   ```
   read the target function → identify all outgoing calls
   usages on each callee → understand their scope
   ```

4. **Map the call chain**:
   ```
   Entry point → Router → Controller → Service → Repository → Database
                                      ↘ Validator → Types
   ```

5. **Identify key abstractions**:
   - Interfaces / abstract classes that decouple layers
   - Shared base classes that propagate changes
   - Utility functions used across many call sites
   - Configuration objects that affect behavior at runtime

6. **Assess complexity indicators**:
   | Indicator | Low Risk | High Risk |
   |-----------|----------|-----------|
   | Callers | 0-3 | >10 |
   | Callees | 0-5 | >15 |
   | Parameters | 0-3 | >6 |
   | Function length | <50 lines | >200 lines |
   | Nesting depth | 1-2 | >4 |
   | Branching | 1-3 paths | >8 paths |

**Tools**: `usages` (primary), `read` (call chain tracing), `search` (find implementations of interfaces)

---

#### Phase 4 — Data Flow Tracing (Data/Events)

**Goal**: Understand how data moves through the system — especially important for debugging, security, and feature work.

**Steps**:
1. **Identify the data of interest**:
   - For bugs: the variable or state that has an unexpected value
   - For features: the user input or data entity being processed
   - For security: untrusted input (HTTP params, file uploads, env vars)

2. **Trace forward (source → sink)**:
   ```
   Where is this data created/received?
   → What functions transform it?
   → Where is it stored/sent/rendered?
   ```

3. **Trace backward (sink → source)**:
   ```
   Where is this value used?
   → What assigned it?
   → Where did that value come from?
   ```

4. **Identify event-driven flows**:
   - Pub/sub patterns: search for `emit`, `publish`, `dispatch`, `trigger`
   - Callbacks and hooks: search for `on`, `addEventListener`, `subscribe`
   - Middleware chains: search for `use`, `pipe`, `middleware`
   - Scheduled tasks: search for `cron`, `schedule`, `interval`

5. **Map error propagation**:
   ```
   Where can exceptions originate in this flow?
   → Where are they caught (try/catch, error middleware)?
   → What happens to uncaught exceptions (crash? silent fail? logging?)?
   ```

**Use cases**:
- **Debugging**: Trace the variable from its assignment backwards to find where corruption occurs
- **Security review**: Trace user input forward to find if it reaches SQL queries, file operations, or eval without sanitization
- **Feature design**: Map the data lifecycle to find the right insertion point for new logic

**Tools**: `search` (event patterns, assignments), `usages` (reference tracing), `read` (function body inspection)

---

#### Phase 5 — Impact Assessment (Synthesis)

**Goal**: Given a proposed change, determine what will be affected and rate the risk.

**Steps**:
1. **List affected symbols** using `usages`:
   ```
   For each changed function/class/type:
     usages → count call sites
     For each call site in a different module: flag as cross-module impact
   ```

2. **Classify impact scope**:
   | Scope | Definition | Risk Level |
   |-------|-----------|------------|
   | **Local** | Single file, no external callers | LOW |
   | **Module** | Multiple files in same directory/package | MEDIUM |
   | **Cross-module** | Files across different packages/modules | HIGH |
   | **Public API** | Changes exported interfaces or public contracts | CRITICAL |

3. **Identify test coverage**:
   ```
   search for: test files that import the changed modules
   For each affected module: does a corresponding test file exist?
   Flag untested modules in the impact zone
   ```

4. **Rate overall confidence**:
   | Confidence | Conditions |
   |-----------|------------|
   | **HIGH** | Local scope, all affected paths have tests, no dynamic dispatch |
   | **MEDIUM** | Module scope, most paths tested, clear interfaces |
   | **LOW** | Cross-module scope, gaps in test coverage, dynamic behavior |
   | **VERY LOW** | Public API change, minimal tests, reflection/metaprogramming |

5. **Produce the impact summary**:
   ```markdown
   ## Impact Assessment
   - **Change**: {what is being changed}
   - **Scope**: {Local | Module | Cross-module | Public API}
   - **Affected files**: {count} ({list key ones})
   - **Test coverage**: {X of Y affected modules have tests}
   - **Confidence**: {HIGH | MEDIUM | LOW | VERY LOW}
   - **Risks**: {specific risks identified}
   - **Recommendation**: {proceed | proceed with caution | needs more testing | needs design review}
   ```

**Tools**: `usages` (impact radius), `search` (test file discovery), `read` (verify test coverage of specific paths)

---

### Quick Reference: Which Phases to Use

Not every task needs all 5 phases. Use the minimum necessary:

| Task Type | Phases | Why |
|-----------|--------|-----|
| **New feature (unfamiliar area)** | 1 → 2 → 3 → 5 | Need full landscape before touching unfamiliar code |
| **Bug fix (known area)** | 3 → 4 → 5 | Skip landscape, trace the specific call chain and data flow |
| **Refactoring** | 2 → 3 → 5 | Focus on dependency impact and blast radius |
| **Security review** | 1 → 4 → 5 | Landscape for attack surface, then trace data flows |
| **Code review (diff)** | 3 → 5 | Trace what the changed functions affect |
| **Onboarding/documentation** | 1 → 2 | Landscape and dependency overview |
| **Test gap analysis** | 1 → 3 → 5 | Find critical paths, then check coverage |
| **Performance analysis** | 3 → 4 | Map hot paths via call chains and data flow |

---

### Integration with Existing Patterns

#### With the `usages` Tool
The `usages` tool is the workhorse of Phases 3 and 5. Best practices:
- **Start with the target symbol**, not the file — `usages` on a function name, not a file path
- **Follow chains**: usages on A reveals B calls A; usages on B reveals C calls B → you've traced the chain
- **Count consumers**: if `usages` returns >10 call sites across multiple modules, flag as high blast radius
- **Check both directions**: callers (who depends on me?) AND callees (what do I depend on?)

#### With the "Read 2,000 Lines" Heuristic
The existing heuristic from `01_quality.instructions.md` remains valid but should be **targeted by topology**:
- **Before**: Read 2,000 lines around the change point (brute force)
- **After**: Use Phase 2-3 to identify the relevant files, THEN read the important sections of those files (directed)
- The topology protocol tells you *which* 2,000 lines matter most

#### With Translation System Patterns
The translation system's dependency DAG protocol (in `code-translation` skill) is the most mature implementation of these ideas. Key reusable patterns:
- Import regex → adjacency list → topological sort (Layer 0 leaves first)
- Per-file complexity scoring (LOC, cyclomatic, external deps)
- Framework/pattern catalog (web, ORM, auth, testing, build)

---

## Worked Examples

### Example 1: Planning a New API Endpoint

```
Task: Add a /users/{id}/preferences endpoint to an Express.js API

Phase 1 (Landscape):
  src/routes/     → existing route handlers (users.ts, auth.ts, admin.ts)
  src/services/   → business logic (userService.ts, preferencesService.ts)
  src/models/     → data models (User.ts, Preferences.ts)
  src/middleware/  → auth.ts, validation.ts
  Entry: src/app.ts → mounts all route files

Phase 2 (Dependencies):
  routes/users.ts → imports userService
  services/userService.ts → imports User model, database client
  models/User.ts → leaf (no deps), already has preferences relation
  Existing preferencesService.ts → imports Preferences model

Phase 3 (Functions):
  userService.getById() → 8 callers (well-established pattern)
  preferencesService.getByUserId() → 2 callers (less used)
  Follow the existing GET /users/{id} route as a template

Phase 5 (Impact):
  New files: routes/preferences.ts, test for it
  Modified: app.ts (mount new route)
  Scope: Module (routes + services)
  Confidence: HIGH — follows existing patterns, well-tested area
```

### Example 2: Debugging an Intermittent 500 Error

```
Task: Users report 500 errors on POST /orders

Phase 3 (Call Chain):
  routes/orders.ts → orderController.create()
  → orderService.createOrder()
    → inventoryService.checkStock() → external API call (!)
    → paymentService.charge() → external API call (!)
    → orderRepository.save()

Phase 4 (Data Flow):
  Request body → validated by middleware → passed to orderService
  inventoryService returns { available: boolean, quantity: number }
  When available=false, orderService throws → but where is it caught?
  → orderController has try/catch → but only handles OrderError
  → inventoryService can throw NetworkError → NOT CAUGHT → 500!

Phase 5 (Impact):
  Root cause: missing error handling for NetworkError from inventoryService
  Fix scope: Local (orderController.ts)
  Confidence: HIGH — clear cause, straightforward fix
  Recommendation: Add catch for NetworkError, return 503 Service Unavailable
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|-------------|---------|----------------|
| **Read everything** | Context overflow, slow, no focus | Use Phase 1-2 to identify what's relevant, then read selectively |
| **Skip straight to coding** | Changes break unknown consumers | Run Phase 5 impact assessment before any edit |
| **Trust the file name** | `utils.ts` might be a god module with 50 consumers | Use `usages` to verify actual dependency weight |
| **Ignore test coverage** | Changes land in untested paths | Phase 5 explicitly checks which affected paths have tests |
| **Assume linear flow** | Miss event-driven, async, or callback patterns | Phase 4 specifically searches for event/callback patterns |
| **Map the whole repo** | Waste tokens mapping irrelevant areas | Use the Quick Reference table — only run phases you need |

---

## Limitations

- **No AST-level analysis**: This protocol uses `search` and `usages` (text-based), not an actual code parser. It may miss dynamic dispatch, reflection, or metaprogramming patterns.
- **No runtime data flow**: Data-flow tracing (Phase 4) is static — it follows the code paths visible in source. Runtime behaviors (dynamic routing, configuration-driven wiring) require additional investigation.
- **Language-dependent regex**: Import pattern detection works well for common languages (Python, TypeScript, Java, C#, Go, Rust) but may need adaptation for less common ones.
- **Token cost**: The full 5-phase protocol consumes significant context. Use the Quick Reference table to select only the phases needed for the task.
- **Confidence is heuristic**: Impact assessment confidence ratings are human-calibrated guidelines, not mathematical proofs. When in doubt, rate lower.

## References

- `instructions/global/00_behavior.instructions.md` — repository rule to understand the problem before solving it
- `.github/agents/planner.agent.md` — planning workflows that benefit from topology analysis
- `.github/agents/reviewer.agent.md` — review workflows that assess blast radius and hidden impacts
- `.github/agents/researcher.agent.md` — research workflows that map unfamiliar code structure
