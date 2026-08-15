# Capacity Planning & SLO Reference

## The Planning Process

Always do this before designing anything:
1. Establish user/traffic assumptions
2. Derive QPS (reads + writes separately)
3. Estimate storage (current + 5-year growth)
4. Estimate bandwidth
5. Identify the bottleneck component
6. Design to that bottleneck

---

## Step 1: Traffic Estimation

### DAU → QPS Conversion
```
Formula:
  Average QPS = (DAU × actions_per_user_per_day) / 86,400

Peak QPS ≈ Average QPS × 3   (conservative)
Peak QPS ≈ Average QPS × 5   (spiky apps like news, sports)

Examples:
  10M DAU, 20 actions/day → avg 2,314 QPS → peak ~7,000 QPS
  100M DAU, 5 actions/day → avg 5,787 QPS → peak ~17,000 QPS
  1B DAU, 2 actions/day   → avg 23,148 QPS → peak ~70,000 QPS
```

### Read/Write Split
Always separate — they have different scaling solutions:
```
Social app:      90% reads, 10% writes
E-commerce:      80% reads, 20% writes  
Analytics ingest: 10% reads, 90% writes
Chat:            50% reads, 50% writes
```

---

## Step 2: Storage Estimation

### Data Size Reference
```
User record (name, email, metadata):     ~1 KB
Tweet / short post:                      ~280 bytes → round to 1 KB
Profile photo (compressed):              ~200 KB
High-res photo:                          ~3 MB
1-min video (720p compressed):           ~50 MB
Audio message (1 min):                   ~1 MB

Rule of thumb: when unsure, round up to next order of magnitude
```

### Growth Projection
```
Formula: Total Storage = daily_new_data × 365 × years × replication_factor

Example (photo sharing app):
  10M new photos/day × 200KB avg = 2TB/day
  × 365 days                     = 730TB/year
  × 3 (replication)              = 2.2PB/year
  × 5 years                      = 11PB total
```

### Database Row Size Estimation
```
PostgreSQL overhead per row: ~23 bytes
Integer (4 bytes), BigInt (8 bytes), UUID (16 bytes)
VARCHAR(255): up to 255 bytes + 2 byte header
TIMESTAMP: 8 bytes
BOOLEAN: 1 byte

Example user row:
  id (bigint):        8 bytes
  email (varchar):   ~50 bytes avg
  name (varchar):    ~30 bytes avg
  created_at:         8 bytes
  overhead:          23 bytes
  Total: ~120 bytes → round to 200 bytes with indexes
```

---

## Step 3: Bandwidth Estimation

```
Formula: Bandwidth = QPS × avg_response_size

Read bandwidth:
  100k QPS × 10KB response = 1GB/s = 8 Gbps

Write bandwidth:
  10k QPS × 1KB payload = 10MB/s = 80 Mbps

CDN egress (video):
  1M concurrent viewers × 5 Mbps (720p) = 5 Tbps
  → This is why CDNs exist
```

---

## Step 4: Component Capacity Limits

Use these as planning benchmarks (order-of-magnitude estimates):

### Database (PostgreSQL / MySQL)
```
Single primary, good indexes:
  Read QPS:    ~10,000–50,000 (simple queries)
  Write QPS:   ~5,000–10,000
  Connections: ~500 (use connection pooler like PgBouncer)
  Storage:     Practical limit ~10TB on single node

With read replicas:
  Read QPS:    scales linearly with replicas
  Write QPS:   still limited to primary

With sharding:
  Scales horizontally — each shard handles above limits
```

### Redis
```
Single node:
  QPS:        ~100,000–1,000,000 (simple get/set)
  Memory:     Up to ~100GB practical (more = slow AOF rewrite)
  Latency:    <1ms (same region)

Redis Cluster:
  Scales horizontally across nodes
  Rebalances automatically on node add/remove
```

### Kafka
```
Single broker:
  Write throughput:  ~100MB/s–500MB/s (sequential disk I/O)
  Read throughput:   ~200MB/s–1GB/s (multiple consumers)

Typical cluster (3–10 brokers):
  Millions of messages/second total
  Retention:  Days to forever (disk-bound)
```

### Application Servers
```
Stateless HTTP server (Node.js / Go / Python):
  Go/Node:    ~10,000–50,000 req/sec per instance
  Python:     ~1,000–5,000 req/sec per instance (GIL)
  Java:       ~10,000–30,000 req/sec per instance

Scale horizontally — add instances behind load balancer
Auto-scaling trigger: CPU > 60% or latency p99 > SLO
```

### Load Balancer
```
Nginx / HAProxy:   ~100,000 req/sec per instance
AWS ALB:           ~100,000 req/sec (auto-scales managed)
Cloudflare:        Virtually unlimited (global edge)
```

---

## Step 5: SLO Definition

### Availability SLOs
```
99%      → 3.65 days downtime/year    (unacceptable for most)
99.9%    → 8.76 hours downtime/year   (small apps)
99.95%   → 4.38 hours downtime/year   (most web apps)
99.99%   → 52.6 minutes downtime/year (important services)
99.999%  → 5.26 minutes downtime/year (critical infrastructure)
```

**How to achieve 99.99%**:
- No single points of failure (everything redundant)
- Multi-AZ deployment
- Automated failover < 30 seconds
- Chaos engineering / regular DR drills
- Graceful degradation (partial functionality > full outage)

### Latency SLOs
Always define at multiple percentiles:
```
p50 (median):  most users' experience
p95:           typical "slow" experience
p99:           worst common case
p999:          rare edge cases (often ignored in SLO, tracked separately)

Example SLO:
  p50 < 50ms, p95 < 200ms, p99 < 500ms
  
Rule: p99 is usually 5–10× p50 for web services
```

**Latency budget breakdown**:
```
Total budget: 200ms p95

  Network (client → server):  20ms
  Load balancer:               2ms
  Application logic:          50ms
  Cache lookup (Redis):        2ms
  Database query:             50ms
  Response serialization:     10ms
  Network (server → client):  20ms
  Buffer:                     46ms
                           --------
  Total:                     200ms
```

### Error Rate SLOs
```
Typical targets:
  < 0.1%  error rate  (99.9% success)
  < 0.01% for payment/critical paths

Track separately:
  5xx errors (server errors — your fault)
  4xx errors (client errors — don't count against SLO)
  Timeout rate (often missed but matters)
```

---

## Step 6: Cost Estimation Framework

### Cloud Cost Reference (AWS, ballpark 2024)
```
Compute (EC2):
  t3.medium (2 vCPU, 4GB):  ~$30/month
  c5.xlarge (4 vCPU, 8GB):  ~$120/month
  Auto-scaling group:        pay per actual usage

Storage:
  S3:                        ~$23/TB/month
  EBS SSD (gp3):             ~$80/TB/month
  RDS PostgreSQL (db.r5.xlarge): ~$400/month + storage

Data Transfer:
  S3 → Internet:             ~$90/TB
  CloudFront (CDN):          ~$85/TB (first 10TB)
  Inter-AZ:                  ~$10/TB (often forgotten!)

Managed Services:
  ElastiCache Redis (r6g.large): ~$100/month
  MSK Kafka (kafka.m5.large, 3 brokers): ~$600/month
  RDS Multi-AZ:              2× single-AZ price
```

### Cost Scaling Pattern
```
Startup (0–100k users):       $500–2k/month    → managed services, single region
Growth (100k–1M users):       $2k–20k/month    → start optimizing, reserved instances
Scale (1M–10M users):         $20k–200k/month  → data transfer costs dominate
Hyperscale (10M+ users):      negotiate enterprise deals, multi-cloud, custom hardware
```

---

## Quick Reference: Back-of-Envelope Cheat Sheet

```
Time:
  1 year ≈ 31.5M seconds ≈ 10^7.5
  1 day  = 86,400 seconds ≈ 10^5

Storage:
  1 KB = 10^3 bytes
  1 MB = 10^6 bytes
  1 GB = 10^9 bytes
  1 TB = 10^12 bytes
  1 PB = 10^15 bytes

Latency (approximate):
  L1 cache:            0.5 ns
  L2 cache:            7 ns
  RAM access:          100 ns
  SSD random read:     150 µs
  HDD seek:            10 ms
  Network same DC:     0.5 ms
  Network cross-AZ:    1–2 ms
  Network cross-region: 50–150 ms

Throughput (approximate):
  Memory bandwidth:    10 GB/s
  SSD read:            500 MB/s
  Network (10GbE):     1 GB/s
  HDD read:            100 MB/s
```
