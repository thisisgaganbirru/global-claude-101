# Anti-Patterns & War Stories Reference

Real failure patterns seen at scale. Use this during design reviews to proactively catch issues.

---

## Database Anti-Patterns

### 1. The God Table
**What it looks like**: One table with 80+ columns, nullable fields everywhere, used for 6 different entity types via a `type` column.
**Why it happens**: "We'll clean it up later."
**What goes wrong**: Indexes become useless, migrations take hours, developers are afraid to touch it.
**Fix**: Decompose into separate tables. Use table inheritance or polymorphic associations properly.

### 2. N+1 Query Problem
**What it looks like**:
```python
posts = db.query("SELECT * FROM posts LIMIT 100")
for post in posts:
    author = db.query(f"SELECT * FROM users WHERE id = {post.author_id}")
    # 100 posts = 101 queries
```
**Why it happens**: ORM lazy loading, iterative thinking in code.
**What goes wrong**: 100 posts = 101 DB round trips. At scale, this kills your DB.
**Fix**: Eager loading / JOIN, or batch fetch all author IDs in one query.

### 3. Missing Indexes on Foreign Keys
**What it looks like**: `orders.user_id` references `users.id` but has no index.
**Why it happens**: Developers think primary key index covers it.
**What goes wrong**: `SELECT * FROM orders WHERE user_id = 123` does a full table scan. At 100M rows, this is catastrophic.
**Fix**: Index every foreign key column. Check with `EXPLAIN ANALYZE`.

### 4. Storing Everything in One Database
**What it looks like**: User data, analytics events, logs, media metadata, sessions — all in one Postgres instance.
**Why it happens**: Simple at first.
**What goes wrong**: Analytical queries (aggregations over billions of rows) starve transactional queries. One bad query brings down prod.
**Fix**: Separate operational DB from analytical. Use a data warehouse (BigQuery, Redshift) for analytics. Use Redis for sessions.

### 5. Using DB as a Message Queue
**What it looks like**: `SELECT * FROM jobs WHERE status='pending' FOR UPDATE SKIP LOCKED`
**Why it happens**: "We already have a DB, why add Kafka?"
**What goes wrong**: Polling creates constant load. At scale, the jobs table becomes a hotspot. No backpressure, no consumer groups, no replay.
**Fix**: Fine at low scale (<1k jobs/min). Above that, use a real queue (SQS, Kafka, RabbitMQ).

---

## Caching Anti-Patterns

### 6. Cache Stampede (Thundering Herd)
**What it looks like**: Popular cache key expires → 10,000 requests simultaneously hit DB.
**Why it happens**: No thought given to what happens on cache miss at scale.
**What goes wrong**: DB gets overwhelmed, latency spikes, cascading failures.
**Fix**: Mutex locks, probabilistic early expiration, stale-while-revalidate, jitter on TTL.

### 7. Caching Mutable Data Without Invalidation
**What it looks like**: Cache user profile for 24 hours. User updates their email. They still see old email everywhere.
**Why it happens**: Forgetting that cached data can become stale.
**What goes wrong**: Users see wrong data. Support tickets pile up. Trust erodes.
**Fix**: Event-driven invalidation on write + TTL as fallback. Or shorter TTLs for mutable data.

### 8. Caching at the Wrong Layer
**What it looks like**: Caching raw DB rows instead of computed API responses.
**Why it happens**: Caching added as afterthought, closest to DB.
**What goes wrong**: Cache hit still requires expensive computation (joins, business logic). Minimal latency improvement.
**Fix**: Cache the final response closest to the client. Cache the expensive computation result, not the inputs.

---

## API & Service Anti-Patterns

### 9. Synchronous Chain of Death
**What it looks like**:
```
API → Service A → Service B → Service C → Service D
```
Each hop adds latency. If D is slow, everything backs up.
**Why it happens**: Microservices decomposition without thinking about call chains.
**What goes wrong**: One slow service at the end of a chain creates cascading timeouts. p99 latency = sum of all p99s.
**Fix**: Break synchronous chains. Use async where result isn't needed immediately. Apply circuit breakers at each hop.

### 10. No Idempotency on Mutations
**What it looks like**: `POST /payments` with no idempotency key.
**Why it happens**: "We'll handle retries on the client."
**What goes wrong**: Network hiccup → client retries → user charged twice. This is a legal and financial disaster.
**Fix**: Every state-changing API must accept an idempotency key. Store processed keys in Redis/DB, return same response on replay.

### 11. Missing Rate Limiting on Public APIs
**What it looks like**: Open API endpoint, no throttling.
**Why it happens**: "We'll add it when we need it."
**What goes wrong**: One bad actor (or a bug in a client) sends 100k requests/second and takes down your service for everyone.
**Fix**: Add rate limiting from day one. Token bucket per API key + IP. Return 429 with Retry-After header.

### 12. Fat Synchronous Webhooks
**What it looks like**: Webhook arrives → do DB writes + send emails + call 3rd party APIs → respond 200 after all of it.
**Why it happens**: Straightforward implementation.
**What goes wrong**: Webhook provider times out (usually 5–10s limit). Retries flood in. Duplicate processing.
**Fix**: Receive webhook → validate → write to queue → respond 200 immediately. Process async.

---

## Scaling Anti-Patterns

### 13. Vertical Scaling as Default Strategy
**What it looks like**: DB getting slow → upgrade to bigger instance → repeat.
**Why it happens**: Quick fix, no architecture changes needed.
**What goes wrong**: Eventually you hit the biggest available instance. Cost scales non-linearly. Single point of failure.
**Fix**: Design for horizontal scaling from the start. Stateless services + read replicas + sharding strategy ready to activate.

### 14. Session State in Application Servers
**What it looks like**: User session stored in memory of app server instance.
**Why it happens**: Easy with frameworks like Express sessions, Flask sessions.
**What goes wrong**: Can't scale to multiple instances (sticky sessions help but create uneven load). Instance restart = all users logged out.
**Fix**: Externalize session state to Redis. Stateless app servers.

### 15. Ignoring the Fan-Out Problem
**What it looks like**: Celebrity posts → system tries to write to 10M followers' feeds in real-time.
**Why it happens**: Fan-out on write works fine for regular users, applied to everyone.
**What goes wrong**: One post generates 10M DB writes. Entire system slows down or crashes.
**Fix**: Hybrid fan-out. High-follower accounts use fan-out on read. See blueprints.md.

---

## Operational Anti-Patterns

### 16. No Circuit Breakers
**What it looks like**: Service A calls Service B directly. B goes down. A keeps retrying. Thread pool exhausts. A goes down too.
**Why it happens**: Happy path thinking.
**What goes wrong**: Cascading failure takes down entire system when one service fails.
**Fix**: Circuit breakers on every external call. Fail fast. Return degraded response or cached data.

### 17. Unbounded Queues
**What it looks like**: Message queue with no max size or consumer monitoring.
**Why it happens**: "Queues handle backpressure automatically."
**What goes wrong**: Queue grows to millions of messages. Memory exhausts. Recovery takes hours. Messages processed hours late.
**Fix**: Set max queue depth. Alert on consumer lag. Define SLO for message processing time. Have runbook for queue overflow.

### 18. Missing Distributed Tracing
**What it looks like**: Microservices with only local logging. Request fails somewhere in the chain. No way to tell where.
**Why it happens**: Logging added per-service, not end-to-end.
**What goes wrong**: Debugging prod issues takes hours. Correlation between logs is manual and error-prone.
**Fix**: Propagate trace IDs (OpenTelemetry). Use Jaeger, Zipkin, or Datadog APM. Correlate all logs by trace ID.

### 19. Schema Migrations Without Feature Flags
**What it looks like**: Add NOT NULL column to table with 500M rows. Run migration. Table locks. Prod down for 2 hours.
**Why it happens**: Works fine in dev/staging, no plan for prod scale.
**What goes wrong**: ALTER TABLE acquires exclusive lock on large tables. All reads/writes block.
**Fix**: Expand-contract pattern: add column as nullable → backfill → add constraint → clean up. Use pt-online-schema-change or pg_repack. Always test migration time on prod-sized data.

### 20. No Graceful Degradation
**What it looks like**: Recommendation service down → entire homepage fails to load.
**Why it happens**: Tight coupling, no fallback logic.
**What goes wrong**: One non-critical service outage takes down the user-facing product.
**Fix**: Design every feature with a degraded mode. Recommendations down? Show popular items. Search slow? Show cached results. Every dependency should have a fallback.
