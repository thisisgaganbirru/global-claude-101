# Migration Patterns Reference

Most real problems are not greenfield — they are:
"We have this mess. How do we get to something better without breaking production?"

This file covers safe migration patterns. The core principle across all of them:
**Never do a big bang rewrite. Always migrate incrementally with a rollback path.**

---

## The Migration Mindset

Before any migration plan, establish:
```
1. What is the blast radius if this goes wrong?
2. What is the rollback plan at every step?
3. Can we run old and new in parallel during migration?
4. How do we validate correctness at each step?
5. What's the minimum viable migration? (Often less than you think)
```

**The biggest migration anti-pattern**: Stopping feature development to do a full rewrite.
This takes 2–3× longer than estimated, the old system keeps changing under you, and you
end up with a new system that has the same design decisions as the old one.

---

## Pattern 1: Strangler Fig

**Use when**: Replacing a monolith with services, or replacing one system with another gradually.

Named after the strangler fig tree that grows around a host tree and eventually replaces it.

```
Phase 1: Route new traffic to new system, old handles everything else
         [Load Balancer] → new requests → [New Service]
                        → old requests  → [Monolith]

Phase 2: Migrate one feature at a time
         [Load Balancer] → /payments    → [Payment Service]  ← migrated
                        → /orders      → [Monolith]          ← not yet
                        → /users       → [Monolith]          ← not yet

Phase 3: Monolith shrinks until nothing is left
```

### Implementation
- Use a routing layer (API Gateway, feature flags, or proxy) to control traffic split
- Migrate by feature/domain, not by technical layer
- The monolith remains fully functional throughout — never broken
- Rollback = flip the route back

### When it works best
- Clear domain boundaries exist (even if not implemented as services yet)
- Team can route traffic by URL path or feature flag
- Monolith is not actively being heavily modified during migration

---

## Pattern 2: Expand-Contract (for DB schema changes)

**Use when**: Changing DB schema on a live system without downtime.
Also called: parallel change, blue-green schema migration.

```
Step 1 — EXPAND: Add new column/table alongside old one
  ALTER TABLE users ADD COLUMN email_new VARCHAR(255);
  -- Both old and new column exist. App still uses old.

Step 2 — MIGRATE: Backfill data, write to both
  UPDATE users SET email_new = email WHERE email_new IS NULL;
  -- App now writes to BOTH old and new columns

Step 3 — CUTOVER: Switch reads to new column
  -- App now reads from new column, writes to both
  -- Verify correctness in production

Step 4 — CONTRACT: Remove old column
  ALTER TABLE users DROP COLUMN email;
  -- Old column gone. Migration complete.
```

### Why this matters
Direct `ALTER TABLE` on a table with 500M rows = table lock = production outage.
Expand-contract = zero downtime at any scale.

### Tools
- **pt-online-schema-change** (MySQL): Copies table while live, swaps at end
- **pg_repack** (PostgreSQL): Reorganises tables without locking
- **pglogical** (PostgreSQL): Logical replication for complex migrations

### Rule
Always test migration duration on a production-sized dataset before running in prod.
A migration that takes 10 minutes on staging may take 8 hours on prod.

---

## Pattern 3: Feature Flags for Infrastructure

**Use when**: Switching databases, caches, or services with ability to instantly rollback.

```python
# Instead of:
result = old_database.query(...)

# Do this:
if feature_flag("use_new_database", user_id):
    result = new_database.query(...)
else:
    result = old_database.query(...)
```

### Rollout strategy
```
1% of traffic → new system   (catch obvious bugs)
10% of traffic               (validate at real load)
50% of traffic               (A/B correctness check)
100% of traffic              (full cutover)
Remove flag                  (cleanup)
```

### Flag tools
- **LaunchDarkly** (managed, best UX)
- **Unleash** (self-hosted open source)
- **Flagsmith** (open source, managed option)
- **Simple**: Redis key or DB row (fine for small teams)

### Critical: Correctness validation
During dual-write phase, run shadow reads:
```python
new_result = new_database.query(...)
old_result = old_database.query(...)
if new_result != old_result:
    log_discrepancy(new_result, old_result)
    return old_result  # Always trust old until validated
```

---

## Pattern 4: Dark Launch (Shadow Traffic)

**Use when**: Testing a new service or database under real production load before switching.

```
Production request → Old Service → user gets response
                  ↓ (async copy)
                  → New Service → response discarded, but logged
```

New service processes real traffic but results are thrown away. You observe:
- Does it handle the load?
- Does it produce correct results?
- Does it have unexpected errors?

No user impact. Full production validation.

### Implementation
```python
def handle_request(request):
    result = old_service.process(request)
    
    # Fire and forget to new service (async, never blocks)
    asyncio.create_task(
        shadow_call(new_service.process, request, expected=result)
    )
    
    return result  # User always gets old result

async def shadow_call(fn, request, expected):
    try:
        result = await fn(request)
        if result != expected:
            metrics.increment("shadow.mismatch")
            log.warn("Shadow mismatch", new=result, old=expected)
        else:
            metrics.increment("shadow.match")
    except Exception as e:
        metrics.increment("shadow.error")
```

---

## Pattern 5: Database Migration Strategy

**Use when**: Moving from one database technology to another (e.g., MySQL → PostgreSQL, 
MongoDB → PostgreSQL, self-hosted → managed).

```
Phase 1: Dual-write
  App writes to BOTH old DB and new DB
  App reads from OLD DB only
  Validate: new DB data matches old DB

Phase 2: Read migration
  App writes to BOTH
  App reads from NEW DB for X% of requests (shadow reads first)
  Monitor for discrepancies

Phase 3: Write cutover
  App writes to NEW DB only
  Old DB becomes read-only backup
  Keep for 30 days as rollback option

Phase 4: Cleanup
  Remove old DB
  Remove dual-write code
```

### Data sync tools
- **AWS DMS** (Database Migration Service): Managed, handles ongoing replication
- **Debezium**: CDC (change data capture) via Kafka — streams DB changes as events
- **pgloader**: PostgreSQL bulk loader from MySQL/SQLite/CSV

### The hardest part: sequences and IDs
If migrating to a new DB, ID sequences must not overlap:
```
Old DB: auto-increment, currently at ID 1,000,000
New DB: start sequence at 2,000,000 (safe gap)
During dual-write: use new DB IDs, backfill old DB
```

---

## Pattern 6: Monolith → Services (When and How)

**When NOT to split a monolith:**
- Team < 10 engineers (coordination cost exceeds benefit)
- No clear domain boundaries
- Doing it because "microservices are modern"
- Under time pressure

**When to split:**
- A specific component has independent scaling needs
- A team owns a clear domain and is blocked by others
- Deploy frequency of one component is killing others
- Specific compliance/security boundary required

**How to find the right split:**
```
1. Identify bounded contexts (DDD): where does the data model fundamentally change?
2. Find seams by change frequency: what changes together should stay together
3. Look at team ownership: Conway's Law — system architecture mirrors org structure
4. Start with the least connected component — easiest to extract
```

**Extraction order matters:**
```
Extract: Auth service       (clear boundary, well-defined API)
Then:    Notification service (async, minimal coupling)
Then:    Payment service    (clear domain, compliance boundary)
Last:    Core business logic (highest coupling, highest risk)
```

Never extract the core business logic first. Always start at the edges.

---

## Migration Anti-Patterns

### The Big Bang Rewrite
"We'll rewrite everything in 6 months and it'll be clean."
Reality: takes 18 months, new system has same problems, old system kept changing.
Fix: Strangler fig. Always.

### Migration Without Feature Flags
Deploying migration code with no way to turn it off.
Fix: Every migration step behind a flag. Rollback = flag off.

### Testing Only on Staging Data
"The migration worked fine in staging."
Fix: Test migration duration on production-sized data. Shadow traffic before cutover.

### No Rollback Plan
"If it goes wrong we'll figure it out."
Fix: Define rollback procedure before migration starts. Test the rollback.

### Migrating During High Traffic
Doing a DB migration on a Friday before a product launch.
Fix: Migrate during lowest traffic window. Have an abort criteria defined upfront.
