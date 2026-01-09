# Observability & Telemetry

Provides observability patterns for metrics, logging, tracing, monitoring, and platform integrations (OpenTelemetry, Prometheus, Grafana, Datadog).

## Description

This skill teaches observability agents how to instrument code for monitoring, define meaningful metrics, implement structured logging, configure distributed tracing, and integrate with observability platforms. It covers the three pillars of observability (metrics, logs, traces) and alerting strategies.

## When to Use

- Instrumenting new features with metrics
- Implementing structured logging
- Setting up distributed tracing
- Creating dashboards and alerts
- Analyzing performance bottlenecks
- Troubleshooting production issues
- Integrating observability platforms

## Entry Points

**Trigger Phrases:** "add metrics", "logging strategy", "distributed tracing", "monitoring dashboard", "observability", "instrumentation"

**Context Patterns:** New service deployment, performance issues, production incidents, SLO/SLA monitoring

## Core Knowledge

### Three Pillars of Observability

#### 1. Metrics (What is happening?)
**Types:**
- **Counter:** Monotonically increasing (requests, errors)
- **Gauge:** Point-in-time value (memory usage, queue depth)
- **Histogram:** Distribution (request duration, payload size)
- **Summary:** Percentiles (p50, p95, p99 latency)

**Key Metrics (RED Method):**
- **Rate:** Requests per second
- **Errors:** Error rate or count
- **Duration:** Response time distribution

**Example (Prometheus):**
```javascript
const promClient = require('prom-client');

// Counter
const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status']
});

// Histogram
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

// Middleware
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  
  res.on('finish', () => {
    httpRequestsTotal.inc({
      method: req.method,
      route: req.route?.path || 'unknown',
      status: res.statusCode
    });
    
    end({
      method: req.method,
      route: req.route?.path || 'unknown'
    });
  });
  
  next();
});
```

#### 2. Logs (Why is it happening?)
**Structured Logging:**
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'app.log' })
  ]
});

// ❌ BAD: Unstructured string
logger.info('User login: john@example.com');

// ✅ GOOD: Structured with context
logger.info('User login successful', {
  user_id: '123',
  email: 'john@example.com',
  ip_address: req.ip,
  user_agent: req.get('user-agent'),
  duration_ms: 45
});
```

**Log Levels:**
- **TRACE:** Very detailed (function entry/exit)
- **DEBUG:** Diagnostic info (variable values)
- **INFO:** General events (user actions, job completion)
- **WARN:** Unexpected but handled (retry succeeded, fallback used)
- **ERROR:** Errors requiring attention (exceptions, failures)
- **FATAL:** System crash (unrecoverable errors)

#### 3. Traces (How are components interacting?)
**Distributed Tracing with OpenTelemetry:**
```javascript
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { registerInstrumentations } = require('@opentelemetry/instrumentation');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');

// Initialize tracing
const provider = new NodeTracerProvider();
provider.register();

registerInstrumentations({
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation()
  ]
});

// Custom span
const tracer = provider.getTracer('user-service');

app.post('/api/users', async (req, res) => {
  const span = tracer.startSpan('create_user');
  
  try {
    span.setAttribute('user.email', req.body.email);
    
    const user = await db.users.create(req.body);
    span.setAttribute('user.id', user.id);
    span.setStatus({ code: 0 }); // OK
    
    res.json({ user });
  } catch (error) {
    span.recordException(error);
    span.setStatus({ code: 2, message: error.message }); // ERROR
    throw error;
  } finally {
    span.end();
  }
});
```

### Service Level Objectives (SLOs)

**SLO Components:**
- **SLI (Indicator):** Metric you measure (e.g., request success rate)
- **SLO (Objective):** Target for SLI (e.g., 99.9% success rate)
- **SLA (Agreement):** Contractual consequence (e.g., refund if <99.5%)

**Example SLOs:**
| Service | SLI | SLO | Measurement Period |
|---------|-----|-----|-------------------|
| API | Success rate | 99.9% | 30 days |
| API | p95 latency | <500ms | 30 days |
| Database | Availability | 99.95% | 30 days |

**Error Budget:**
```
SLO: 99.9% = 0.1% error budget
30 days = 43,200 minutes
Error budget = 43.2 minutes downtime allowed
```

### Alerting Best Practices

**Alert Types:**
1. **Pages:** Immediate action required (user-facing outage)
2. **Tickets:** Action required within SLA (error rate elevated)
3. **Dashboards:** Informational (slow queries detected)

**Alert Template:**
```yaml
alert: HighErrorRate
expr: |
  (
    sum(rate(http_requests_total{status=~"5.."}[5m]))
    /
    sum(rate(http_requests_total[5m]))
  ) > 0.05
for: 5m
labels:
  severity: page
annotations:
  summary: High error rate detected
  description: |
    Error rate is {{ $value | humanizePercentage }} (threshold: 5%)
    Dashboard: https://grafana.example.com/d/api-errors
```

**Alert Fatigue Prevention:**
- Set meaningful thresholds (not too sensitive)
- Use `for:` duration to avoid transient alerts
- Group related alerts
- Include actionable runbooks in annotations
- Review and adjust alert rules regularly

### Platform Integrations

#### Prometheus + Grafana
```javascript
// Expose metrics endpoint
const register = promClient.register;
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Scrape config (prometheus.yml)
/*
scrape_configs:
  - job_name: 'user-service'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
    scrape_interval: 15s
*/
```

#### Datadog
```javascript
const tracer = require('dd-trace').init({
  service: 'user-service',
  env: 'production'
});

// Custom metric
const StatsD = require('node-dogstatsd').StatsD;
const dogstatsd = new StatsD();

dogstatsd.increment('user.created', 1, ['env:prod', 'region:us-east']);
dogstatsd.histogram('payment.amount', 49.99, ['currency:usd']);
```

## Examples

### Example: Complete Observability Setup

```javascript
// 1. Metrics (Prometheus)
const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status']
});

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5]
});

// 2. Structured Logging
const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  )
});

// 3. Distributed Tracing (OpenTelemetry)
const tracer = provider.getTracer('api-service');

// Middleware combining all three
app.use((req, res, next) => {
  const span = tracer.startSpan(`${req.method} ${req.path}`);
  const start = Date.now();
  
  // Add trace context to logs
  req.logger = logger.child({
    trace_id: span.spanContext().traceId,
    span_id: span.spanContext().spanId
  });
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    
    // Metrics
    httpRequestsTotal.inc({
      method: req.method,
      route: req.route?.path || 'unknown',
      status: res.statusCode
    });
    
    httpRequestDuration.observe({
      method: req.method,
      route: req.route?.path || 'unknown'
    }, duration);
    
    // Logging
    req.logger.info('Request completed', {
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration_ms: duration * 1000
    });
    
    // Tracing
    span.setAttribute('http.method', req.method);
    span.setAttribute('http.status_code', res.statusCode);
    span.end();
  });
  
  next();
});
```

## References

- **OpenTelemetry:** https://opentelemetry.io/
- **Prometheus:** https://prometheus.io/docs/practices/naming/
- **Grafana:** https://grafana.com/docs/
- **Datadog:** https://docs.datadoghq.com/
- **SRE Book:** https://sre.google/books/
