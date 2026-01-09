# Documentation Style & Standards

Provides documentation patterns for Markdown formatting, structure, voice/tone, and technical writing best practices across user guides, API docs, and code comments.

## Description

This skill teaches documentation agents how to create clear, consistent, well-structured documentation following industry best practices. It covers Markdown conventions, information architecture, writing style (active voice, concise sentences), code examples, and accessibility considerations for documentation.

## When to Use

- Writing user-facing documentation
- Creating API reference guides
- Documenting architecture decisions
- Writing README files
- Creating onboarding materials
- Updating changelogs

## Entry Points

**Trigger Phrases:** "write documentation", "create user guide", "document this API", "update README", "onboarding guide"

**Context Patterns:** New feature completion, API endpoint additions, architecture changes, refactoring tasks

## Core Knowledge

### Document Structure

**Standard Sections:**
1. **Title/Overview:** What is this? (1-2 sentences)
2. **Prerequisites:** What do you need first?
3. **Quick Start:** Fastest path to hello world (5 min)
4. **Usage:** Core functionality with examples
5. **Configuration:** Options and settings
6. **API Reference:** Detailed method/endpoint documentation
7. **Troubleshooting:** Common issues and solutions
8. **FAQs:** Frequently asked questions
9. **Resources:** Related links and references

### Markdown Conventions

```markdown
# H1: Document Title (one per file)

Brief overview paragraph explaining purpose.

## H2: Major Section

Content with **bold** for emphasis, *italic* for terms, `code` for technical elements.

### H3: Subsection

- Bullet lists for unordered items
- Keep items parallel in structure

1. Numbered lists for sequential steps
2. Start each item with action verb
3. Include expected outcomes

### Code Blocks

\`\`\`javascript
// Always specify language for syntax highlighting
const example = 'Use comments to explain why, not what';
\`\`\`

### Tables

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data | Data | Data |

### Links

[Descriptive link text](https://example.com) not "click here"

### Images

![Alt text describing image content](path/to/image.png)
```

### Writing Style Guidelines

**Do:**
- ✅ Use active voice: "The function returns..." (not "is returned by")
- ✅ Be concise: "Use X to do Y" (not "X can be used in order to accomplish Y")
- ✅ Start with action verbs: "Configure", "Install", "Run"
- ✅ Use second person: "You can configure..." (not "One can configure...")
- ✅ Define acronyms on first use: "API (Application Programming Interface)"

**Don't:**
- ❌ Use passive voice unnecessarily
- ❌ Write long, complex sentences (>25 words)
- ❌ Assume prior knowledge without linking context
- ❌ Use jargon without explanation
- ❌ Skip error handling in examples

### Code Example Best Practices

**Complete and Runnable:**
```python
# ✅ GOOD: Complete example with imports and context
import requests

def get_user(user_id):
    """Fetch user data from API."""
    response = requests.get(f'https://api.example.com/users/{user_id}')
    response.raise_for_status()  # Handle errors
    return response.json()

# Usage
user = get_user(123)
print(user['name'])
```

```python
# ❌ BAD: Incomplete snippet, unclear context
response = requests.get(url)
return response.json()
```

**Include Error Handling:**
```javascript
// ✅ GOOD: Shows both success and error paths
try {
  const user = await fetchUser(userId);
  console.log(user.name);
} catch (error) {
  if (error.response?.status === 404) {
    console.error('User not found');
  } else {
    console.error('Failed to fetch user:', error.message);
  }
}
```

### API Documentation Template

```markdown
## `functionName(param1, param2)`

Brief one-line description of what the function does.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `param1` | string | Yes | Description of param1 |
| `param2` | number | No | Description of param2 (default: 0) |

### Returns

`Promise<User>` - User object containing `id`, `name`, `email`.

### Throws

- `ValidationError` - If param1 is empty or invalid format
- `NotFoundError` - If user with specified ID doesn't exist

### Example

\`\`\`javascript
const user = await functionName('john@example.com', 10);
console.log(user.name); // 'John Doe'
\`\`\`

### See Also

- [Related function](#related-function)
- [Configuration guide](./configuration.md)
```

## Examples

### Example: API Endpoint Documentation

```markdown
# User Management API

RESTful API for managing user accounts and profiles.

**Base URL:** `https://api.example.com/v1`

**Authentication:** Bearer token in `Authorization` header

## Endpoints

### Create User

`POST /users`

Creates a new user account.

**Request Body:**

\`\`\`json
{
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user"
}
\`\`\`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Valid email address (unique) |
| name | string | Yes | Full name (2-100 characters) |
| role | string | No | User role: `user` or `admin` (default: `user`) |

**Success Response (201):**

\`\`\`json
{
  "user": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "user",
    "created_at": "2026-01-09T10:30:00Z"
  }
}
\`\`\`

**Error Responses:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | `invalid_email` | Email format invalid |
| 409 | `email_exists` | Email already registered |
| 401 | `unauthorized` | Missing or invalid auth token |

**Example Request:**

\`\`\`bash
curl -X POST https://api.example.com/v1/users \\
  -H "Authorization: Bearer YOUR_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{"email":"user@example.com","name":"John Doe"}'
\`\`\`

**Rate Limits:** 100 requests/hour per API key

**See Also:**
- [Authentication Guide](./authentication.md)
- [Rate Limiting](./rate-limits.md)
```

## References

- **Markdown Guide:** https://www.markdownguide.org/
- **Write the Docs:** https://www.writethedocs.org/guide/
- **Technical Writing Best Practices:** Google Developer Documentation Style Guide
