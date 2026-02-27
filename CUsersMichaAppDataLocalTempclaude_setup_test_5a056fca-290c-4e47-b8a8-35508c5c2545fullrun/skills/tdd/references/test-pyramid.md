# Test Pyramid Reference

## Levels

| Level | Speed | Scope | Count | Purpose |
|-------|-------|-------|-------|---------|
| **Unit** | Fast (< 1s) | Single function/class | Many (70-80%) | Logic correctness, edge cases |
| **Integration** | Medium (1-10s) | Module interactions | Some (15-20%) | API contracts, data flow |
| **E2E / System** | Slow (10s+) | Full workflow | Few (5-10%) | Critical user paths |

## When to Use Each Level

### Unit Tests
- Pure logic (calculations, transformations, validations)
- Error handling branches
- Boundary conditions (empty, null, max values)
- String parsing and formatting

### Integration Tests
- Database queries and transactions
- File system operations
- HTTP client/server interactions
- Cross-module data flow

### E2E Tests
- Login → action → verify workflows
- CI/CD pipeline smoke tests
- Critical business processes

## Coverage Targets

| Category | Minimum | Recommended |
|----------|---------|-------------|
| New code | 80% | 90%+ |
| Critical paths | 95% | 100% |
| Error handlers | 70% | 85%+ |
| Overall project | 60% | 80%+ |

## Anti-Patterns

- **Ice cream cone**: Too many E2E, too few unit tests
- **Testing implementation**: Asserting on internal state instead of behavior
- **Flaky tests**: Tests that pass/fail non-deterministically
- **Test duplication**: Same assertion at multiple levels
