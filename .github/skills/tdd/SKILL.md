---
name: tdd
description: "TDD patterns for Red-Green-Refactor cycles, unit/integration testing, test doubles, and coverage analysis. Use for writing tests before implementation and validating code changes."
---

# Test-Driven Development (TDD)

Provides TDD patterns for writing tests before implementation, following Red-Green-Refactor cycle, and achieving comprehensive test coverage.

## Description

This skill teaches implementer and test agents how to apply Test-Driven Development principles: write failing tests first (Red), implement minimal code to pass (Green), then refactor for quality (Refactor). It covers unit testing, integration testing, test doubles (mocks/stubs), and coverage analysis.

## When to Use

- Implementing new features or functions
- Fixing bugs with reproducible test cases
- Refactoring existing code with safety net
- Establishing baseline test coverage
- Validating edge cases and error handling

## Entry Points

**Trigger Phrases:** "write tests first", "TDD approach", "test coverage", "unit tests", "integration tests", "test this function"

**Context Patterns:** New feature implementation, bug fixes, refactoring tasks, code review with missing tests

## Core Knowledge

### Red-Green-Refactor Cycle

**1. Red (Write Failing Test)**
```python
# test_calculator.py
def test_add_positive_numbers():
    calc = Calculator()
    result = calc.add(2, 3)
    assert result == 5  # FAILS: Calculator not implemented

def test_add_negative_numbers():
    calc = Calculator()
    result = calc.add(-2, -3)
    assert result == -5  # FAILS
```

**2. Green (Minimal Implementation)**
```python
# calculator.py
class Calculator:
    def add(self, a, b):
        return a + b  # Simplest code that passes tests
```

**3. Refactor (Improve Code Quality)**
```python
# calculator.py
class Calculator:
    """Performs basic arithmetic operations."""

    def add(self, a: float, b: float) -> float:
        """Add two numbers and return result."""
        return a + b  # No refactoring needed (already simple)
```

### Test Pyramid

```
         /\
        /  \  E2E Tests (Few, Slow, High Value)
       /____\
      /      \
     / Integration Tests (Some, Medium Speed)
    /________\
   /          \
  / Unit Tests (Many, Fast, Focused)
 /______________\
```

**Unit Tests (70%):** Test individual functions/methods in isolation
**Integration Tests (20%):** Test component interactions (DB, API, services)
**E2E Tests (10%):** Test complete user workflows through UI

### Test Doubles

| Type | Purpose | Example |
|------|---------|---------|
| **Stub** | Returns fixed data | `getUserStub()` returns `{ id: 1, name: 'Test' }` |
| **Mock** | Verifies interactions | Assert `sendEmail()` called once with correct args |
| **Spy** | Records invocations | Track how many times `logger.info()` called |
| **Fake** | Simplified implementation | In-memory database for tests |

### Coverage Metrics

**Line Coverage:** % of code lines executed during tests
**Branch Coverage:** % of if/else branches exercised
**Function Coverage:** % of functions called
**Target:** â‰¥80% line coverage, â‰¥70% branch coverage for new code

### TDD Patterns

#### Pattern 1: Arrange-Act-Assert (AAA)
```javascript
test('user registration creates account', async () => {
  // Arrange: Set up test data and preconditions
  const userData = { email: 'test@example.com', password: 'secret123' };

  // Act: Execute the code under test
  const user = await registerUser(userData);

  // Assert: Verify expected outcomes
  expect(user.id).toBeDefined();
  expect(user.email).toBe('test@example.com');
  expect(user.password).not.toBe('secret123'); // Should be hashed
});
```

#### Pattern 2: Test Edge Cases
```python
def test_divide():
    # Happy path
    assert divide(10, 2) == 5

    # Edge cases
    assert divide(0, 5) == 0  # Zero numerator
    assert divide(7, 3) == 2.333  # Float result

    # Error cases
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)  # Division by zero
```

#### Pattern 3: Parameterized Tests
```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("WORLD", "WORLD"),
    ("", ""),
    ("123", "123"),
])
def test_to_uppercase(input, expected):
    assert to_uppercase(input) == expected
```

## Examples

### Example: TDD for API Endpoint

**Phase 1: Red (Failing Tests)**
```javascript
// tests/api/users.test.js
describe('POST /api/users', () => {
  it('creates new user with valid data', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'john@test.com' });

    expect(res.status).toBe(201);
    expect(res.body.user.name).toBe('John');
    expect(res.body.user.id).toBeDefined();
  });

  it('returns 400 for missing email', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ name: 'John' });

    expect(res.status).toBe(400);
    expect(res.body.error).toContain('email');
  });
});

// âŒ Tests FAIL: /api/users endpoint doesn't exist
```

**Phase 2: Green (Minimal Implementation)**
```javascript
// routes/users.js
app.post('/api/users', async (req, res) => {
  const { name, email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'email is required' });
  }

  const user = await db.users.create({ name, email });
  res.status(201).json({ user });
});

// âœ… Tests PASS
```

**Phase 3: Refactor (Improve Quality)**
```javascript
// routes/users.js
const { body, validationResult } = require('express-validator');

app.post('/api/users',
  // Validation middleware
  body('email').isEmail().normalizeEmail(),
  body('name').trim().isLength({ min: 1, max: 100 }),

  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, email } = req.body;

    try {
      const user = await db.users.create({ name, email });
      res.status(201).json({ user: sanitizeUser(user) });
    } catch (err) {
      if (err.code === 'UNIQUE_VIOLATION') {
        return res.status(409).json({ error: 'Email already exists' });
      }
      throw err;
    }
  }
);

// âœ… Tests still PASS, code quality improved
```

## Bundled References

- [Test Pyramid](references/test-pyramid.md) — Unit/integration/E2E ratios, coverage targets, decision matrix
- [Coverage Config Examples](references/coverage-config-examples.md) — Jest, pytest, Pester coverage configuration

## References

- **Testing Frameworks:** Jest, Pytest, Mocha, RSpec
- **Coverage Tools:** nyc, coverage.py, SimpleCov
- **Test Agent:** `.github/agents/test.agent.md`
