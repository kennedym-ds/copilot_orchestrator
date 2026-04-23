---
description: "Documentation standards for docs/ — versioning, references, ADR discipline, and content rules."
applyTo: "docs/**"
version: "1.0.0"
lastUpdated: "2026-04-23"
---

# Documentation Standards

## Frontmatter Requirements

Every standards doc (`guides/`, `templates/`) must have YAML frontmatter:

```yaml
---
title: "Human-readable title"
version: "X.Y.Z"
lastUpdated: "YYYY-MM-DD"
status: "active" | "draft" | "deprecated"
reviewOwners:
  - "team or person responsible"
---
```

Version bump rules:
- **Patch** (`X.Y.Z+1`): typo fixes, link corrections, clarifications with no behavior change
- **Minor** (`X.Y+1.0`): new sections, new examples, expanded coverage
- **Major** (`X+1.0.0`): breaking changes to described behavior, removal of sections

## No Placeholders

- No `TODO:`, `FIXME:`, `TBD`, or `<!-- placeholder -->` in committed docs.
- If a section is not yet written, either write it or leave it out entirely.
- Exception: a `TODO(DEC-xxx):` with a decision ticket reference is acceptable if the decision is actively in progress.

## File References

Always use relative paths from the repo root. Never use absolute paths, `~/`, or machine-specific paths.

Good: `See \`scripts/validate-copilot-assets.ps1\``
Bad: `See C:\Users\User\Projects\validate.ps1`

## Runnable Commands

Guides that describe validation or setup must include runnable commands, not just descriptions:

```powershell
# Not just "run the validator" — give the actual command:
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
```

## ADR Discipline (`docs/adrs/` or `artifacts/decisions/`)

ADRs are **write-once**. Once committed:
- Do not edit an existing ADR retroactively.
- If a decision changes, create a new ADR that explicitly supersedes the old one: `Supersedes: DEC-old-slug.md`
- Set the old ADR's `status:` to `deprecated` and add a link to the new one.

ADR titles use the pattern: `DEC-{slug}.md` where slug is a short noun phrase (`scriptless-skills`, `hook-format-2026`).

## Table Standards

- Every table must have a header row.
- Align columns with `---` separators.
- Use `—` (em dash) for empty cells, not blank or `-`.
- Prefer compact tables (≤5 columns). Wide tables should be split or reformatted as definition lists.

## Changelog Entries

`docs/CHANGELOG.md` entries follow the format:

```markdown
## [Phase/Version] — YYYY-MM-DD
### Changed
- Brief description of what changed and why (not just "updated X")
### Added
- ...
### Fixed
- ...
```

Every PR that changes behavior (not just typos) must add a CHANGELOG entry.

## Links

- Internal: use relative links `[text](../guides/other.md)` — not absolute GitHub URLs.
- External: always include the URL even for well-known sites (docs rot).
- Verify links before committing — dead links in standards docs mislead future contributors.
