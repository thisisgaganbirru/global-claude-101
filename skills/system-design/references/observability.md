# Observability Reference

Observability is not optional. Every system design is incomplete without answering:
"How will we know when this breaks, why it broke, and where?"

The three pillars: **Metrics** (what's happening), **Logs** (what happened), **Traces** (where it happened).

---

## The Golden Signals (Google SRE)

Design alerting around these four, nothing else to start:

```
1. Latency    — how long requests take (p50, p95, p99 — never just average)
2. Traffic    — how much demand (QPS, active connections)
3. Errors     — rate of failed requests (5xx, timeouts, business logic errors)
4. Saturation — how "full" the service is (CPU, memory, queue depth, DB connections)
```

If all four golden signals are healthy, the system is healthy. Alert on these first before building anything more complex.

---

## OpenTelemetry (OTel) — Current Standard

OTel is the industry standard for instrumentation as of 2024–2025.
Instrument once → route to any backend (Datadog, Jaeger, Grafana, Honeycomb).

### Why OTel matters architecturally
- Vendor lock-in via proprietary SDKs is the old way — switching backends required full re-instrumentation
- OTel separates instrumentation from backend — change your observability vendor without touching app code
- All major languages have stable OTel SDKs: Python, Go, Java, Node.js, .NET

### OTel Collector Pattern
```
App (OTel SDK) → OTel Collector → [Jaeger for traces]
                               → [Prometheus for metrics]
                               → [Loki for logs]
```
Collector handles batching, retry, format translation. Apps don't talk to backends directly.

---

## Metrics

### Prometheus + Grafana (self-hosted standard)
- Prometheus scrapes metrics endpoints (`/metrics`) on a pull model
- Grafana visualises, alerts
- Good for: teams that want control, on-prem, cost-sensitive

### Managed alternatives
- **Datadog**: Full-stack, expensive, best UX
- **Grafana Cloud**: Managed Prometheus + Loki + Tempo stack
- **CloudWatch** (AWS), **Cloud Monitoring** (GCP): Good if already deep in that cloud

### Metric Types
```
Counter:   Monotonically increasing (requests_total, errors_total)
Gauge:     Point-in-time value (active_connections, memory_usage_bytes)
Histogram: Distribution of values (request_duration_seconds — gives you p50/p95/p99)
Summary:   Pre-calculated quantiles (less flexible than histogram, avoid for new systems)
```

### Cardinality Warning
High-cardinality labels destroy Prometheus performance:
```
// BAD — user_id has millions of values
http_requests_total{user_id="12345", endpoint="/api/orders"}

// GOOD — low-cardinality labels only
http_requests_total{endpoint="/api/orders", status="200"}
```
Rule: labels should have < 100 distinct values. Never use user IDs, request IDs, or timestamps as labels.

---

## Logging

### Structured Logging (mandatory)
Always emit JSON logs. Never plain text in production.
```json
{
  "timestamp": "2025-03-13T10:00:00Z",
  "level": "ERROR",
  "service": "payment-service",
  "trace_id": "abc123",
  "user_id": "u_456",
  "message": "Payment processing failed",
  "error": "insufficient_funds",
  "amount": 99.99,
  "duration_ms": 234
}
```
Plain text logs are unsearchable at scale. JSON is queryable.

### Log Levels — Use Correctly
```
ERROR:   Something broke, needs attention (alert on sustained error rate)
WARN:    Unexpected but handled (retry succeeded, fallback used)
INFO:    Normal business events (order placed, user logged in)
DEBUG:   Development only — never in production at normal volume
```

### Log Aggregation Stack
- **Loki + Grafana** (self-hosted, lightweight): Indexes labels only, not full text — cheap storage
- **Datadog Logs** (managed): Full-text search, expensive at volume
- **Axiom** (managed): Cost-effective, good for high-volume logs
- **ELK** (Elasticsearch + Logstash + Kibana): Powerful but operationally heavy — avoid unless you need full-text search at massive scale

### What to Log
```
Always log:
  - Every external API call (request + response status + duration)
  - Every state change (order → paid, user → suspended)
  - Every error with full context
  - Auth events (login, logout, failed attempt)

Never log:
  - Passwords, tokens, credit card numbers, PII
  - Every DB query (too noisy — use slow query log instead)
  - Health check endpoints (creates noise)
```

---

## Distributed Tracing

Critical for microservices. Without traces, debugging cross-service failures is guesswork.

### How it works
```
User request → Service A → Service B → DB
                        → Service C → External API

Each hop gets a span. All spans share a trace_id.
Result: full request timeline across all services.
```

### Trace Propagation
Pass `trace_id` in headers between services:
```
W3C TraceContext header (standard):
  traceparent: 00-{trace_id}-{span_id}-{flags}
```
OTel handles propagation automatically if you use the SDK.

### Backends
- **Jaeger** (self-hosted, open source): Standard for self-managed tracing
- **Tempo** (Grafana): Pairs with Grafana stack
- **Datadog APM** (managed): Best UX, expensive
- **Honeycomb** (managed): Excellent for high-cardinality event data

### Sampling Strategy
Don't trace 100% of requests in production — storage cost explodes.
```
Head-based sampling:  Decision made at trace start (simple, loses interesting traces)
Tail-based sampling:  Decision made at trace end — keep slow/errored traces (better, more complex)

Recommended rates:
  Normal traffic:  1–5% sampled
  Errors/slow:     100% sampled (tail-based)
  Critical paths:  10–20% sampled
```

---

## Alerting

### Alert Design Principles
```
1. Alert on symptoms, not causes
   BAD:  "CPU > 80%"  (cause — may not affect users)
   GOOD: "p99 latency > 500ms" (symptom — users are affected)

2. Every alert must be actionable
   If you can't do anything about it right now, it's not an alert — it's a dashboard

3. Alert fatigue kills on-call
   Start with golden signals only
   Every false positive costs trust
   Review and prune monthly
```

### SLO-Based Alerting (recommended approach)
Alert when your error budget is burning too fast, not on raw thresholds.
```
SLO: 99.9% success rate over 30 days = 43.2 min downtime budget

Burn rate alert:
  If burning at 14.4× normal rate → budget gone in 2 hours → PAGE immediately
  If burning at 6× normal rate   → budget gone in 5 hours → ticket, investigate soon
```
This approach dramatically reduces noise vs threshold-based alerting.

### Runbooks
Every alert must have a runbook:
```
Alert: PaymentServiceHighErrorRate
Runbook:
  1. Check Stripe status page (stripe.com/status)
  2. Check payment-service error logs for specific error codes
  3. If Stripe outage: enable payment retry queue, notify customers
  4. If DB issue: check connection pool exhaustion, check replica lag
  5. Escalate to: payments-oncall@company.com
```
No runbook = alert is not ready for production.

---

## Observability by Team Size

| Team | Recommended Stack |
|---|---|
| 1–5 engineers | Datadog or Grafana Cloud (managed everything, zero ops) |
| 5–20 engineers | Grafana Cloud or self-hosted Prometheus + Loki + Tempo |
| 20+ engineers | Self-hosted full OTel stack with dedicated platform team |

**Rule**: Don't self-host observability infra until you have someone whose job it is to maintain it.
A broken observability stack during an incident is worse than a simple one that works.
