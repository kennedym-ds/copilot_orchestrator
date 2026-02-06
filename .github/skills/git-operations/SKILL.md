---
name: git-operations
description: "Git workflow patterns for conventional commits, branching strategies, PR workflows, merge strategies, and conflict resolution. Use for version control operations and repository management."
---

# Git Operations & Best Practices

Provides Git workflow patterns for commit messages, branching strategies, pull request workflows, and repository management best practices.

## Description

This skill teaches agents how to follow Git best practices for version control including conventional commit messages, branching strategies (Git Flow, GitHub Flow), pull request workflows, merge strategies, and conflict resolution patterns.

## When to Use

- Writing commit messages
- Creating or reviewing pull requests
- Planning branching strategy
- Resolving merge conflicts
- Managing release workflows
- Repository maintenance (cleanup, history rewriting)

## Entry Points

**Trigger Phrases:** "commit message", "create PR", "branching strategy", "merge conflict", "git workflow", "release branch"

**Context Patterns:** Code changes ready for commit, feature completion, hotfix deployment, release preparation

## Core Knowledge

### Conventional Commits

**Format:** `<type>(<scope>): <subject>`

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons (no code change)
- `refactor`: Code change that neither fixes bug nor adds feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Tooling, configuration, dependencies

**Examples:**
```
feat(auth): add OAuth2 authentication with Auth0
fix(api): prevent null pointer exception in getUserById
docs(readme): update installation instructions for v2.0
refactor(database): extract query builder into separate class
test(user): add integration tests for registration flow
```

**Body (optional):** Explain *why*, not *what*
```
feat(api): add rate limiting to public endpoints

Implement token bucket algorithm to prevent API abuse. Default: 100 req/hour per IP.
Configurable via RATE_LIMIT_MAX and RATE_LIMIT_WINDOW env vars.

Closes #456
```

### Branching Strategies

#### GitHub Flow (Simple, Continuous Deployment)
```
main (production)
  ├─ feature/oauth-login
  ├─ fix/null-pointer-bug
  └─ docs/api-guide
```

**Workflow:**
1. Branch from `main` for each task
2. Name: `type/short-description`
3. Open PR when ready for review
4. Merge to `main` → auto-deploy
5. Delete feature branch

#### Git Flow (Complex, Scheduled Releases)
```
main (production releases)
develop (integration)
  ├─ feature/oauth-login
  ├─ feature/user-profile
  └─ release/v2.0
hotfix/critical-bug → main + develop
```

**Workflow:**
1. `develop` = integration branch
2. Features branch from `develop`
3. `release/vX.Y` branch for release prep
4. Merge `release` → `main` (tag) + `develop`
5. Hotfixes branch from `main` → merge to both

### Pull Request Best Practices

**PR Title:** Same format as commit message
```
feat(auth): add OAuth2 authentication
```

**PR Description Template:**
```markdown
## Summary
Brief description of what this PR does.

## Changes
- Added OAuth2 middleware
- Updated user model with provider field
- Created integration tests

## Testing
- [ ] Unit tests passing (pytest)
- [ ] Integration tests added
- [ ] Manual testing completed

## Screenshots (if UI changes)
![Before/After comparison]

## Related Issues
Closes #123
Relates to #456

## Checklist
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Reviewed own code
```

**Review Process:**
1. Self-review: Check diff before requesting review
2. Request reviewers: At least 1 for small changes, 2+ for critical
3. Address feedback: Respond to every comment
4. Squash commits: Clean up history before merge (if needed)

### Merge Strategies

| Strategy | Use Case | History |
|----------|----------|---------|
| **Merge commit** | Preserve full history | All commits + merge commit |
| **Squash merge** | Clean history | Single commit per PR |
| **Rebase merge** | Linear history | No merge commits |

**Recommendation:** Squash merge for feature branches (cleaner history)

### Conflict Resolution

**Steps:**
1. Update your branch: `git fetch origin main && git merge origin/main`
2. Identify conflicts: `git status` shows conflicted files
3. Resolve conflicts: Edit files, remove markers (`<<<<<<<`, `=======`, `>>>>>>>`)
4. Test after resolution: Run tests to ensure functionality
5. Commit resolution: `git add . && git commit -m "resolve merge conflicts"`

**Conflict Markers:**
```
<<<<<<< HEAD (your changes)
const apiUrl = 'https://api.staging.example.com';
=======
const apiUrl = 'https://api.example.com';
>>>>>>> main (their changes)
```

**Resolution:**
```javascript
// Keep both, make configurable
const apiUrl = process.env.API_URL || 'https://api.example.com';
```

## Examples

### Example: Feature Branch Workflow

```bash
# 1. Create feature branch
git checkout main
git pull origin main
git checkout -b feat/user-notifications

# 2. Make changes and commit
git add src/notifications.js tests/notifications.test.js
git commit -m "feat(notifications): add email notification system

Implement SendGrid integration for transactional emails.
Supports: welcome emails, password resets, account alerts.

Closes #789"

# 3. Push and create PR
git push origin feat/user-notifications
# Open PR on GitHub

# 4. Address review feedback
git add src/notifications.js
git commit -m "refactor: extract email templates into separate files"
git push origin feat/user-notifications

# 5. After approval, squash merge via GitHub UI

# 6. Clean up local branch
git checkout main
git pull origin main
git branch -d feat/user-notifications
```

### Example: Hotfix Workflow (Git Flow)

```bash
# 1. Critical bug in production
git checkout main
git pull origin main
git checkout -b hotfix/payment-processing

# 2. Fix bug
git add src/payments/processor.js
git commit -m "fix(payments): prevent duplicate charge on retry

Add idempotency key to Stripe API calls to prevent double-charging
when payment webhook retries due to network issues.

Critical: affects billing, immediate deployment required."

# 3. Merge to main (production)
git checkout main
git merge --no-ff hotfix/payment-processing
git tag -a v1.2.3 -m "Hotfix: payment duplicate charge"
git push origin main --tags

# 4. Merge back to develop
git checkout develop
git merge --no-ff hotfix/payment-processing
git push origin develop

# 5. Clean up
git branch -d hotfix/payment-processing
```

## References

- **Conventional Commits:** https://www.conventionalcommits.org/
- **Git Flow:** https://nvie.com/posts/a-successful-git-branching-model/
- **GitHub Flow:** https://docs.github.com/en/get-started/quickstart/github-flow
