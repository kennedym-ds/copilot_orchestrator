---
description: "SQL implementation guardrails for safe and efficient database operations."
applyTo: "**/*.sql"
---

## Guiding Principles

- Write clear, readable SQL that expresses intent and is easy to maintain.
- Optimize for correctness first, then performance.
- Use parameterized queries to prevent SQL injection vulnerabilities.
- Follow consistent naming conventions across database objects.
- Design normalized schemas to reduce redundancy and ensure data integrity.

## Style and Formatting

- Use UPPERCASE for SQL keywords: `SELECT`, `FROM`, `WHERE`, `INSERT`, `UPDATE`.
- Use lowercase or snake_case for identifiers: table and column names.
- Use consistent indentation (2 or 4 spaces) for readability.
- Break long queries into multiple lines with logical grouping.
- Align related clauses vertically when it improves readability.
- Use consistent formatting tools (sqlformat, pg_format) when available.
- Add comments for complex logic: `--` for single-line, `/* */` for multi-line.

## Naming Conventions

- Use descriptive, meaningful names for tables and columns.
- Use singular nouns for table names: `user` not `users` (or follow project
  convention).
- Use snake_case for multi-word identifiers: `first_name`, `order_date`.
- Prefix tables with module or domain names in large databases: `shop_order`,
  `user_profile`.
- Use `id` or `table_name_id` for primary keys consistently.
- Use `_at` suffix for timestamps: `created_at`, `updated_at`.
- Use `is_` or `has_` prefix for boolean columns: `is_active`, `has_children`.
- Avoid reserved words as identifiers; quote them if necessary.

## Schema Design

- Normalize data to at least 3NF (Third Normal Form) to reduce redundancy.
- Use appropriate primary keys: surrogate keys (auto-increment IDs) or
  natural keys.
- Define foreign keys to enforce referential integrity.
- Add NOT NULL constraints where columns should always have values.
- Use UNIQUE constraints for columns with unique values.
- Use CHECK constraints to validate data at the database level.
- Add DEFAULT values for columns when appropriate.
- Use appropriate data types; don't oversize columns unnecessarily.

## Indexes

- Create indexes on columns used in WHERE, JOIN, and ORDER BY clauses.
- Index foreign keys for better join performance.
- Create composite indexes for queries filtering on multiple columns.
- Avoid over-indexing; indexes slow down writes and consume space.
- Use UNIQUE indexes for uniqueness constraints with performance benefits.
- Monitor index usage and remove unused indexes.
- Consider covering indexes that include all columns needed for a query.
- Use index hints sparingly; let the optimizer decide in most cases.

## Queries - SELECT

- Select only the columns you need; avoid `SELECT *` in production code.
- Use explicit column lists for clarity and to prevent breaking changes.
- Use table aliases for readability, especially with joins:
  ```sql
  SELECT u.name, o.total
  FROM users u
  JOIN orders o ON u.id = o.user_id
  ```
- Use meaningful alias names that clarify the query intent.
- Filter early with WHERE clauses to reduce the dataset processed.
- Use LIMIT/TOP to restrict result sets in development and testing.
- Sort results with ORDER BY when order matters; specify ASC or DESC explicitly.

## Joins

- Use explicit JOIN syntax (INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN)
  instead of implicit joins in WHERE.
- Specify join conditions clearly with ON clauses.
- Use INNER JOIN when you need matching rows from both tables.
- Use LEFT JOIN when you need all rows from the left table with optional matches.
- Be cautious with Cartesian products; ensure join conditions are correct.
- Join on indexed columns for better performance.
- Keep join conditions simple; complex expressions may prevent index usage.

## Aggregations and Grouping

- Use aggregate functions appropriately: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.
- Group results with GROUP BY when using aggregates on subsets.
- Use HAVING to filter groups after aggregation.
- Include all non-aggregated columns in GROUP BY clause.
- Use COUNT(*) to count rows, COUNT(column) to count non-null values.
- Be aware of how NULL values affect aggregations.

## Subqueries and CTEs

- Use Common Table Expressions (CTEs) with WITH for complex queries:
  ```sql
  WITH active_users AS (
      SELECT * FROM users WHERE is_active = true
  )
  SELECT * FROM active_users WHERE created_at > '2024-01-01'
  ```
- Use CTEs to break complex queries into logical, readable steps.
- Use subqueries in FROM, WHERE, or SELECT when appropriate.
- Use EXISTS instead of IN for better performance with large datasets.
- Use IN for small, static lists of values.
- Consider using JOINs instead of subqueries for better optimization in
  some cases.

## Data Modification - INSERT, UPDATE, DELETE

- Use explicit column lists in INSERT statements:
  ```sql
  INSERT INTO users (name, email) VALUES ('John', 'john@example.com')
  ```
- Use parameterized queries for all user input to prevent SQL injection.
- Use UPDATE with WHERE clause; avoid updating entire tables unintentionally.
- Use DELETE with WHERE clause; never run DELETE without WHERE in production.
- Use transactions for operations that must succeed or fail together.
- Test UPDATE and DELETE statements with SELECT first to verify affected rows.
- Use RETURNING clause (PostgreSQL) or OUTPUT (SQL Server) to get modified
  rows.

## Transactions

- Use transactions (BEGIN/COMMIT/ROLLBACK) for operations requiring atomicity.
- Keep transactions as short as possible to minimize locking.
- Handle transaction failures with appropriate error handling.
- Use appropriate isolation levels (READ COMMITTED, REPEATABLE READ,
  SERIALIZABLE).
- Understand isolation level trade-offs between consistency and concurrency.
- Avoid long-running transactions that hold locks.
- Commit or rollback transactions explicitly; don't leave them open.

## Security Considerations

- Always use parameterized queries or prepared statements to prevent SQL
  injection.
- Never concatenate user input directly into SQL queries.
- Validate and sanitize inputs at the application layer as well.
- Use least privilege: grant minimum necessary permissions to database users.
- Separate read-only and read-write database accounts when appropriate.
- Encrypt sensitive data at rest and in transit.
- Hash passwords using appropriate algorithms (bcrypt, Argon2) before storing.
- Audit database access and changes for sensitive data.
- Keep database systems updated with security patches.

## Performance Optimization

- Use EXPLAIN or EXPLAIN ANALYZE to understand query execution plans.
- Identify slow queries with query logs or performance monitoring tools.
- Index columns used in WHERE, JOIN, ORDER BY clauses.
- Avoid functions on indexed columns in WHERE clauses; they prevent index usage.
- Use appropriate data types; smaller types are faster and use less space.
- Partition large tables for better query performance and maintenance.
- Use connection pooling to reduce connection overhead.
- Cache frequently accessed data at the application layer when appropriate.
- Denormalize strategically for read-heavy workloads (with caution).

## Database-Specific Features

### PostgreSQL
- Use array types, JSON/JSONB for semi-structured data.
- Use full-text search capabilities for text search.
- Use window functions for advanced analytics.
- Use EXPLAIN (ANALYZE, BUFFERS) for detailed query analysis.
- Use pg_stat_statements for query performance monitoring.

### MySQL/MariaDB
- Use appropriate storage engines (InnoDB for transactions).
- Use EXPLAIN to analyze query plans.
- Use SHOW PROFILE for detailed query execution analysis.
- Monitor slow query log for performance issues.

### SQL Server
- Use execution plans (Ctrl+L in SSMS) for query analysis.
- Use SQL Server Profiler or Extended Events for monitoring.
- Use indexed views for materialized aggregations.
- Use tempdb effectively for temporary data.

### SQLite
- Use PRAGMA statements for configuration and optimization.
- Use EXPLAIN QUERY PLAN for query analysis.
- Understand journal modes and their trade-offs.
- Use appropriate synchronous settings for durability vs. performance.

## Views and Stored Procedures

- Use views to simplify complex queries and encapsulate logic.
- Use materialized views (where supported) for expensive, frequently accessed
  queries.
- Keep views focused and avoid nesting views too deeply.
- Use stored procedures for complex business logic executed in the database.
- Document stored procedure parameters, behavior, and side effects.
- Keep stored procedures simple; prefer application logic for complexity.
- Version and test stored procedures like application code.

## Data Types

- Use appropriate numeric types: INT, BIGINT, DECIMAL, FLOAT based on needs.
- Use DECIMAL for monetary values to avoid floating-point precision issues.
- Use VARCHAR with appropriate length limits; avoid unnecessary large sizes.
- Use TEXT or CLOB for large text data without fixed limits.
- Use DATE, TIME, TIMESTAMP, or TIMESTAMPTZ for temporal data.
- Use BOOLEAN for true/false values where supported.
- Use ENUM or CHECK constraints for limited sets of values.
- Consider JSON/JSONB types for semi-structured data (PostgreSQL).

## NULL Handling

- Understand NULL semantics: NULL is not equal to anything, including NULL.
- Use IS NULL or IS NOT NULL to check for NULL values, not = or !=.
- Use COALESCE to provide default values for NULL: `COALESCE(column, 'default')`.
- Use NULLIF to convert specific values to NULL.
- Be aware of NULL behavior in aggregations and comparisons.
- Consider using NOT NULL constraints to prevent NULL values where appropriate.

## Migrations and Schema Changes

- Use migration tools (Flyway, Liquibase, Alembic) for version-controlled
  schema changes.
- Test migrations on a copy of production data before applying to production.
- Make schema changes backward compatible when possible.
- Add columns as nullable first, populate them, then add NOT NULL if needed.
- Create indexes CONCURRENTLY (PostgreSQL) to avoid locking tables.
- Batch large data migrations to avoid long-running transactions.
- Keep migration scripts idempotent when possible.

## Testing

- Write tests for complex queries and stored procedures.
- Test edge cases: empty results, NULL values, boundary conditions.
- Test performance with realistic data volumes.
- Use transactions to rollback test data in integration tests.
- Validate constraints and foreign keys work as expected.
- Test migration scripts with representative data.

## Documentation

- Document schema design decisions and trade-offs.
- Comment complex queries explaining the business logic.
- Document stored procedures with parameter descriptions and examples.
- Keep data dictionaries up-to-date with table and column descriptions.
- Use database comments feature to document objects (where supported).
- Document performance expectations and known bottlenecks.

## Best Practices

- Follow the project or organization's SQL style guide.
- Review query execution plans for performance-critical queries.
- Monitor query performance in production.
- Use transactions appropriately for data consistency.
- Keep queries readable and maintainable.
- Avoid premature optimization; measure before optimizing.
- Use database constraints to enforce data integrity.
- Regular database maintenance: VACUUM, ANALYZE, index rebuilds.
- Backup databases regularly and test restore procedures.
- Keep database software and drivers updated.
