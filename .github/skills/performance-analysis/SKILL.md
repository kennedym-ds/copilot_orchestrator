---
name: performance-analysis
description: "Performance analysis patterns for runtime complexity, memory usage, cost optimization, and scalability assessment. Use for Big O analysis, profiling, caching strategies, and cloud cost modeling."
---

# Performance Analysis & Optimization

Provides performance analysis patterns for runtime, memory, cost optimization, and scalability assessment across code changes and architecture decisions.

## Description

This skill teaches performance agents how to analyze code for runtime complexity, memory usage, scalability bottlenecks, and cost implications. It covers Big O analysis, profiling techniques, caching strategies, database optimization, and cloud cost modeling.

## When to Use

- Analyzing algorithm complexity and efficiency
- Reviewing database queries and indexes
- Evaluating caching strategies
- Assessing API response times and throughput
- Analyzing memory usage and leaks
- Estimating cloud infrastructure costs
- Planning for scale (10x, 100x traffic growth)

## Entry Points

**Trigger Phrases:** "performance review", "optimize this code", "check scalability", "analyze runtime", "memory usage", "cost estimate"

**Context Patterns:** Algorithm implementations, database queries, API endpoints with high traffic, batch processing jobs, resource-intensive operations

## Core Knowledge

### Big O Complexity Analysis

| Notation | Name | Example | Performance |
|----------|------|---------|-------------|
| O(1) | Constant | Hash table lookup | Excellent |
| O(log n) | Logarithmic | Binary search | Very good |
| O(n) | Linear | Array scan | Good |
| O(n log n) | Linearithmic | Merge sort | Acceptable |
| O(n²) | Quadratic | Nested loops | Poor |
| O(2ⁿ) | Exponential | Recursive Fibonacci | Very poor |

### Database Optimization

**Query Performance:**
```sql
-- ❌ BAD: N+1 queries (100 users = 101 queries)
SELECT * FROM users;
-- For each user: SELECT * FROM orders WHERE user_id = ?

-- ✅ GOOD: Single query with JOIN
SELECT users.*, orders.*
FROM users
LEFT JOIN orders ON users.id = orders.user_id;

-- ❌ BAD: Full table scan
SELECT * FROM orders WHERE status = 'shipped';

-- ✅ GOOD: Index on status column
CREATE INDEX idx_orders_status ON orders(status);
SELECT * FROM orders WHERE status = 'shipped';
```

**Indexing Strategy:**
- Primary key: Always indexed automatically
- Foreign keys: Index for JOIN performance
- WHERE clause columns: Index frequently queried fields
- Composite indexes: Order matters (most selective first)

### Caching Strategies

| Pattern | Use Case | TTL | Example |
|---------|----------|-----|---------|
| Cache-Aside | Read-heavy | Minutes-hours | User profiles |
| Write-Through | Write-heavy, strong consistency | N/A | Session data |
| Write-Behind | High write volume | Seconds | Analytics events |
| Refresh-Ahead | Predictable access | Before expiry | Product catalog |

### Memory Profiling

**Common Issues:**
- Memory leaks (unreleased resources, event listeners)
- Excessive allocations (unnecessary object creation)
- Large data structures (unbounded caches, result sets)
- Circular references (garbage collection prevention)

**Mitigation:**
```javascript
// ❌ BAD: Memory leak (event listener not removed)
class Component {
  constructor() {
    window.addEventListener('resize', this.handleResize);
  }
}

// ✅ GOOD: Cleanup in destructor
class Component {
  constructor() {
    window.addEventListener('resize', this.handleResize);
  }
  destroy() {
    window.removeEventListener('resize', this.handleResize);
  }
}

// ❌ BAD: Unbounded cache
const cache = {};
function get(key) {
  if (!cache[key]) cache[key] = expensiveOperation(key);
  return cache[key];
}

// ✅ GOOD: LRU cache with size limit
const cache = new LRU({ max: 100, maxAge: 60000 });
```

### Cost Optimization (Cloud)

**AWS Cost Drivers:**
- Compute: EC2, Lambda invocations
- Storage: S3, EBS volumes
- Data transfer: Outbound bandwidth
- Database: RDS, DynamoDB reads/writes

**Optimization Patterns:**
- Right-sizing: Match instance size to workload
- Reserved instances: 30-70% savings for predictable workloads
- Spot instances: 70-90% savings for fault-tolerant workloads
- S3 Intelligent-Tiering: Auto-move cold data to cheaper tiers
- CloudFront caching: Reduce origin load and bandwidth

### Performance Review Template

```markdown
## Performance Analysis: [Feature]

### Runtime Complexity
- **Current:** O(?) - [Description]
- **Bottleneck:** [Specific operation]
- **Improvement:** O(?) - [Proposed optimization]

### Database Impact
- **Query count:** N queries per request
- **Indexes:** Missing on [columns]
- **Recommendation:** [Add indexes, rewrite query, use caching]

### Memory Usage
- **Peak allocation:** XMB per request
- **Leak risk:** [None / Identified in Y]
- **Recommendation:** [Optimization strategy]

### Scalability Assessment
- **Current capacity:** X req/sec
- **10x traffic:** [Bottleneck analysis]
- **100x traffic:** [Architecture changes needed]

### Cost Impact
- **Monthly estimate:** $X (current) → $Y (after change)
- **Cost drivers:** [Compute, storage, bandwidth]
- **Optimization opportunities:** [List]

### Verdict
- [ ] APPROVED (no performance concerns)
- [ ] MINOR_CONCERNS (acceptable for MVP, optimize later)
- [ ] MAJOR_CONCERNS (blocks deployment, requires optimization)
```

## Examples

### Example: Inefficient Algorithm Review

**Code:**
```python
def find_duplicates(arr):
    duplicates = []
    for i in range(len(arr)):
        for j in range(i+1, len(arr)):
            if arr[i] == arr[j] and arr[i] not in duplicates:
                duplicates.append(arr[i])
    return duplicates
```

**Performance Analysis:**
```markdown
## Performance Analysis: find_duplicates

### Runtime Complexity
- **Current:** O(n²) - Nested loops scan entire array
- **Bottleneck:** Inner loop iterates (n-1) + (n-2) + ... + 1 ≈ n²/2 times
- **Improvement:** O(n) using hash set

### Scalability Impact
| Input Size | Current (O(n²)) | Optimized (O(n)) |
|------------|-----------------|------------------|
| 100 items | 10,000 ops | 100 ops |
| 1,000 items | 1,000,000 ops | 1,000 ops |
| 10,000 items | 100,000,000 ops | 10,000 ops |

**At 10K items:** 10,000x performance improvement

### Memory Usage
- **Current:** O(n) for duplicates list
- **Optimized:** O(n) for seen set + duplicates
- **Trade-off:** Slightly higher memory for massive speed gain

### Recommended Implementation

```python
def find_duplicates(arr):
    seen = set()
    duplicates = set()
    for item in arr:
        if item in seen:
            duplicates.add(item)
        else:
            seen.add(item)
    return list(duplicates)
```

**Complexity:** O(n) time, O(n) space

### Verdict
**MAJOR_CONCERNS** - O(n²) algorithm unsuitable for production data sizes. Optimized version recommended.
```

## References

- **Profiling Tools:** `scripts/performance-profile.ps1`, py-spy, clinic.js
- **Monitoring:** `docs/guides/observability.md`
- **Cost Analysis:** AWS Cost Explorer, GCP Pricing Calculator
