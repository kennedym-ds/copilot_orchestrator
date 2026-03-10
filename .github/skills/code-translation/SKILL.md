---
name: code-translation
description: "Code translation patterns for cross-language repository transpilation including dependency ordering, pattern mapping, confidence scoring, and behavioral equivalence validation. Use for converting codebases between languages, transpilation tasks, and translation confidence assessment."
---

# Code Translation Patterns

Provides code translation patterns for cross-language repository transpilation including dependency ordering, pattern mapping, confidence scoring, and behavioral equivalence validation.

## Description

This skill teaches translation agents how to systematically convert source code from one programming language to another while maintaining functional equivalence. It covers dependency graph analysis, topological translation ordering, language-specific pattern mapping, confidence scoring, and the 6-layer validation stack. The skill supports the full translation lifecycle from discovery through validation and documentation.

## When to Use

This skill is relevant when:
- Translating source code from one language to another
- Analyzing a repository's dependency structure for translation
- Mapping language-specific patterns to target equivalents
- Validating translated code for correctness and equivalence
- Scoring confidence in translation quality
- Generating documentation for a translated codebase

## Entry Points

### Trigger Phrases
- "translate this code"
- "convert from X to Y"
- "transpile this repository"
- "migrate codebase to"
- "port this application"

### Context Patterns
- Cross-language migration projects
- Framework modernization (e.g., .NET Framework → .NET Core)
- Language upgrade (e.g., Java 8 → Kotlin)
- Polyglot services requiring standardization

## Core Knowledge

### Translation Unit Hierarchy

Translation should proceed at the appropriate unit granularity:

```
Repository          → Full orchestrated translation (translation-conductor)
├── Module/Package  → Module-level translation (translator)
│   ├── File        → Atomic translation unit
│   │   ├── Class   → Structural translation
│   │   ├── Function → Functional translation
│   │   └── Type    → Type system translation
│   └── Tests       → Parallel test translation
└── Configuration   → Build system & CI translation
```

### Dependency-Ordered Translation

**Why Order Matters:**
Translating a file before its dependencies are translated leads to:
- Unresolvable import references
- Unknown types that prevent type checking
- Cascading validation failures

**Protocol:**
```
1. Build dependency DAG from import analysis
2. Topological sort into layers
3. Translate Layer 0 first (leaf nodes: types, constants, configs)
4. Move to Layer 1 (depends only on Layer 0)
5. Continue ascending layers
6. Translate entry points last (Layer N)
7. Within each layer, files can be translated in parallel
```

**Handling Circular Dependencies:**
When cycles are detected:
1. Identify the minimal cycle set
2. Extract shared interfaces/types into a new shared module
3. Translate the shared module first
4. Translate cycle members with shared module as dependency
5. Document the restructuring in the translation decisions log

### Cross-Language Type Mapping Matrix

| Concept | Python | TypeScript | Rust | Go | Java | C# |
|---------|--------|-----------|------|-----|------|-----|
| String | `str` | `string` | `String` / `&str` | `string` | `String` | `string` |
| Integer | `int` | `number` | `i32`/`i64` | `int`/`int64` | `int`/`long` | `int`/`long` |
| Float | `float` | `number` | `f32`/`f64` | `float64` | `double` | `double` |
| Boolean | `bool` | `boolean` | `bool` | `bool` | `boolean` | `bool` |
| Null/None | `None` | `null`/`undefined` | `None` (Option) | `nil` | `null` | `null` |
| List/Array | `list[T]` | `T[]` | `Vec<T>` | `[]T` | `List<T>` | `List<T>` |
| Dict/Map | `dict[K,V]` | `Record<K,V>` | `HashMap<K,V>` | `map[K]V` | `Map<K,V>` | `Dictionary<K,V>` |
| Optional | `Optional[T]` | `T \| undefined` | `Option<T>` | `*T` | `Optional<T>` | `T?` |
| Result/Error | `raise`/`try` | `throw`/`try` | `Result<T,E>` | `error` return | `throws`/`try` | `throw`/`try` |
| Tuple | `tuple[A,B]` | `[A, B]` | `(A, B)` | struct | N/A | `(A, B)` |
| Enum | `enum.Enum` | `enum` | `enum` | `const` group | `enum` | `enum` |
| Interface | `Protocol`/`ABC` | `interface` | `trait` | `interface` | `interface` | `interface` |
| Generic | `Generic[T]` | `<T>` | `<T>` | `[T any]` | `<T>` | `<T>` |
| Async | `async/await` | `async/await` | `async/await` | goroutines | `CompletableFuture` | `async/await` |

### Framework Mapping Guide

| Category | Python | TypeScript/JS | Rust | Go | Java | C# |
|----------|--------|--------------|------|-----|------|-----|
| Web | FastAPI, Django, Flask | Express, NestJS, Fastify | Actix, Axum | Gin, Echo, Fiber | Spring Boot | ASP.NET Core |
| ORM | SQLAlchemy, Django ORM | TypeORM, Prisma, Drizzle | Diesel, SeaORM | GORM, Ent | Hibernate, JPA | Entity Framework |
| HTTP Client | requests, httpx | axios, fetch | reqwest | net/http | HttpClient, OkHttp | HttpClient |
| Testing | pytest, unittest | Jest, Vitest, Mocha | cargo test | testing + testify | JUnit, Mockito | xUnit, NUnit |
| Validation | Pydantic | class-validator, Zod | serde, validator | go-validator | Bean Validation | FluentValidation |
| Auth | python-jose, authlib | passport, jose | jsonwebtoken | golang-jwt | Spring Security | ASP.NET Identity |
| CLI | click, typer | commander, yargs | clap | cobra | picocli | System.CommandLine |
| Logging | logging, structlog | winston, pino | tracing, log | slog, zap | SLF4J, Log4j | Serilog, NLog |

### Confidence Scoring Deep Dive

#### Score Composition
```
File Confidence = Î£(layer_weight × layer_score) for each of 6 layers

Layer 1: Syntax    (0.15) × [0.0 or 1.0]     — binary pass/fail
Layer 2: Types     (0.15) × [0.0 to 1.0]     — error ratio
Layer 3: Lint      (0.10) × [0.0 to 1.0]     — warning ratio
Layer 4: Unit      (0.25) × [0.0 to 1.0]     — test pass ratio
Layer 5: Integ     (0.15) × [0.0 to 1.0]     — integration pass ratio
Layer 6: Equiv     (0.20) × [0.0 to 1.0]     — behavioral equivalence
```

#### Repo Confidence (LOC-Weighted)
```
Repo Score = Î£(LOC_i × Score_i) / Î£(LOC_i)
```

This weights larger, more complex files more heavily — a single failed 1000-line service file impacts the repo score more than a failed 10-line constants file.

#### Confidence Thresholds for Automation
| Score | Action |
|-------|--------|
| ≥ 0.95 | Auto-approve, no human review needed |
| 0.80–0.94 | Quick human review of flagged areas |
| 0.60–0.79 | Full human review required |
| < 0.60 | Re-translate or flag for manual rewrite |

### Error Handling Pattern Translation

Error handling is the most divergent area across languages. Follow this decision tree:

```
Source uses exceptions?
├── Target has exceptions? → Map exception types 1:1
│   └── Map hierarchies: BaseError → TypeError, ValueError
├── Target uses Result types? (Rust)
│   └── Convert try/except → match on Result<T, E>
│       └── Map exception types to error enum variants
├── Target uses error returns? (Go)
│   └── Convert try/except → if err != nil { return err }
│       └── Map exception types to sentinel errors or error types
└── Target uses Either/Option? (FP languages)
    └── Convert try/except → flatMap/bind chains
```

### Test Translation Protocol

1. **Map test framework:** pytest → Jest, unittest → JUnit, etc.
2. **Translate fixtures:** setUp/tearDown → beforeEach/afterEach
3. **Map assertions:** assertEqual → expect().toBe(), assert_raises → expect().toThrow()
4. **Translate mocks:** unittest.mock → jest.fn(), mockito → mockk
5. **Preserve test names:** Keep descriptive test names, update to target convention
6. **Maintain test data:** Copy test fixtures and expected outputs verbatim
7. **Verify coverage:** Same lines/branches covered in source and target

## Examples

### Example: Python to TypeScript Translation

**Source (Python):**
```python
from dataclasses import dataclass
from typing import Optional

@dataclass
class User:
    id: int
    name: str
    email: str
    role: str = "user"

    def is_admin(self) -> bool:
        return self.role == "admin"

    def display_name(self) -> str:
        return f"{self.name} ({self.email})"

def find_user(users: list[User], user_id: int) -> Optional[User]:
    return next((u for u in users if u.id == user_id), None)
```

**Target (TypeScript):**
```typescript
export interface User {
  id: number;
  name: string;
  email: string;
  role: string;
}

export function createUser(
  id: number,
  name: string,
  email: string,
  role: string = "user"
): User {
  return { id, name, email, role };
}

export function isAdmin(user: User): boolean {
  return user.role === "admin";
}

export function displayName(user: User): string {
  return `${user.name} (${user.email})`;
}

export function findUser(users: User[], userId: number): User | undefined {
  return users.find(u => u.id === userId);
}
```

**Translation Decisions:**
- `@dataclass` → interface + factory function (more idiomatic TS)
- `Optional[User]` → `User | undefined` (TS convention over null)
- Methods on dataclass → standalone functions (idiomatic for simple data types)
- f-string → template literal

## Anti-Patterns

### ❌ DO NOT: Transliterate Line-by-Line
```typescript
// BAD: Python-style in TypeScript
function findUser(users: User[], userId: number): User | null {
    for (let i = 0; i < users.length; i++) {
        if (users[i].id === userId) {
            return users[i];
        }
    }
    return null;
}
```

### ❌ DO NOT: Ignore Target Language Error Conventions
```go
// BAD: Exception-style in Go
func GetUser(id int) *User {
    user := db.Find(id)
    if user == nil {
        panic("user not found")  // Go uses error returns, not panics
    }
    return user
}
```

### ❌ DO NOT: Keep Source Language Naming Conventions
```typescript
// BAD: Python naming in TypeScript
function get_user_by_id(user_id: number): User | undefined {
    return users.find(u => u.id === user_id);
}
```
## Bundled References

- [Language Equivalence Tables](references/language-equivalence-tables.md) — Python↔TypeScript and PowerShell↔Bash mapping tables