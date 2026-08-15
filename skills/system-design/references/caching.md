# Caching Reference

## When to Cache

Cache when:
- Read-to-write ratio is high (10:1 or higher)
- Data is expensive to compute or fetch
- Latency SLO can't be met without it
- Same data is requested by many users

Don't cache when:
- Data changes frequently and staleness is unacceptable
- Data is user-specific and non-shareable (low cache hit rate)
- System is write-heavy (cache invalidation overhead dominates)

---

## Cache Placement

### Client-Side Cache
- Browser cache, mobile app cache
- ✅ Zero network cost
- ❌ No server control, stale data risk
- Use: static assets, user preferences

### CDN (Content Delivery Network)
- Edge nodes globally distributed (Cloudflare, CloudFront, Fastly)
- ✅ Low latency worldwide, offloads origin
- ❌ Cache invalidation is slow/costly
- Use: static assets, public API responses, HTML pages

### Application-Level Cache (In-Process)
- Cache inside the service process (e.g., Python dict, Guava cache)
- ✅ Zero network latency
- ❌ Not shared across instances, lost on restart
- Use: small, frequently accessed config/reference data

### Distributed Cache (Redis, Memcached)
- Shared across all service instances
- ✅ Consistent view, survives instance restart
- ❌ Network hop (~1ms), operational complexity
- Use: sessions, rate limiting, shared computed results

### Database Query Cache
- Avoid in most cases — DB query caches are often disabled (MySQL deprecated it)
- Use proper indexing + application-level caching instead

---

## Redis Deep Dive

### Data Structures
| Type | Use Case |
|---|---|
| String | Simple key-value, counters, serialized JSON |
| Hash | User objects, partial updates without full serialize |
| List | Queues, activity feeds (LPUSH/RPOP) |
| Set | Unique items, tags, membership checks |
| Sorted Set | Leaderboards, rate limiting windows, time-based queries |
| HyperLogLog | Approximate cardinality (unique visitor count) |
| Bitmap | Feature flags per user (memory efficient) |
| Stream | Lightweight Kafka alternative, append-only log |

### Redis Persistence Options
| Mode | Description | Trade-off |
|---|---|---|
| RDB (snapshot) | Periodic dump to disk | Fast restart, may lose last N minutes |
| AOF (append-only file) | Log every write | Durable, slower restart |
| RDB + AOF | Both | Best durability, most disk I/O |
| No persistence | Pure cache | Fastest, lose all data on restart |

### Redis Cluster vs Sentinel
- **Sentinel**: Monitors primary, promotes replica on failure. No sharding. Use for HA without horizontal scale.
- **Cluster**: Shards data across nodes (16,384 hash slots). Use when dataset exceeds single-node memory.

---

## Cache Write Strategies

### Cache-Aside (Lazy Loading) — Most common
```
read(key):
  val = cache.get(key)
  if val is None:
    val = db.get(key)
    cache.set(key, val, ttl=300)
  return val
```
- ✅ Only caches what's actually read
- ❌ Cache miss = 3 operations (read cache, read DB, write cache)
- ❌ First request after TTL expires always hits DB

### Write-Through
```
write(key, val):
  db.set(key, val)
  cache.set(key, val)  # always kept in sync
```
- ✅ Cache always fresh
- ❌ Write latency = DB + cache
- ❌ Caches data that may never be read

### Write-Behind (Write-Back)
```
write(key, val):
  cache.set(key, val)
  async: db.set(key, val)  # batched flush later
```
- ✅ Very fast writes
- ❌ Data loss risk if cache crashes before flush
- Use: high-write scenarios where durability is less critical (view counts, analytics)

### Read-Through
Cache sits in front of DB; cache handles DB reads on miss.
Typically managed by caching library (not hand-rolled).

---

## Cache Eviction Policies

| Policy | Description | Best For |
|---|---|---|
| LRU | Evict least recently used | General purpose |
| LFU | Evict least frequently used | Skewed access patterns |
| FIFO | Evict oldest regardless of access | Simple, but rarely optimal |
| TTL-based | Expire after fixed time | Time-sensitive data |
| Random | Evict random key | Simple, low overhead |

Redis default: **allkeys-lru** for cache-only use cases (no persistence needed).

---

## Cache Invalidation Strategies

"There are only two hard things in CS: cache invalidation and naming things." — Phil Karlton

### TTL-based Expiry
Simplest approach. Set expiry based on acceptable staleness.
```
cache.set("user:123", data, ttl=300)  # 5 min TTL
```

### Event-Driven Invalidation
On write, emit event → cache layer subscribes and deletes affected keys.
```
user_updated(user_id=123) → cache.delete("user:123")
```
- ✅ Near-real-time freshness
- ❌ Event delivery not guaranteed → add TTL as fallback

### Cache Tags / Surrogate Keys
Tag cache entries with logical groupings; invalidate entire tag at once.
```
cache.set("product:456", data, tags=["category:electronics"])
# On category update:
cache.invalidate_tag("category:electronics")
```
Supported by Varnish, some CDNs.

### Versioned Keys
Instead of invalidating, change the key version.
```
cache_key = f"user:{user_id}:v{user.version}"
# Old version naturally expires by TTL
```

---

## Thundering Herd Problem

**Problem**: Cache key expires → thousands of requests simultaneously hit DB.

**Solutions**:

1. **Cache locking / mutex**:
```
if cache.set_nx("lock:user:123", 1, ttl=5):  # Only one winner
    val = db.get(...)
    cache.set("user:123", val)
    cache.delete("lock:user:123")
else:
    sleep(0.1); retry()  # Others wait
```

2. **Probabilistic early expiration** (XFetch algorithm):
Start refreshing before TTL expires with increasing probability as expiry approaches. Prevents synchronized expiry.

3. **Stale-while-revalidate**: Return stale value immediately, refresh async in background.

4. **Jitter on TTL**: Add random offset to TTL to spread expiry.
```
ttl = 300 + random.randint(-30, 30)  # 270–330s
```

---

## CDN Caching

### Cache-Control Headers
```
Cache-Control: public, max-age=86400         # Cache for 1 day
Cache-Control: private, max-age=0            # Don't cache (user-specific)
Cache-Control: stale-while-revalidate=60     # Serve stale for 60s while refreshing
Surrogate-Control: max-age=3600             # CDN-specific TTL
```

### Cache Invalidation at CDN
- **Path-based purge**: Invalidate specific URLs
- **Tag-based purge**: Cloudflare Cache Tags, Fastly surrogate keys
- **Versioned URLs**: `/static/app.v3.js` — never need to invalidate

### Edge Computing (Cloudflare Workers, Lambda@Edge)
Run logic at CDN edge node: personalization, A/B testing, auth checks.
Reduces latency vs. round-trip to origin.
