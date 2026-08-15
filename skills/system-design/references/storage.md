# Storage & Databases Reference

## SQL vs NoSQL Decision Framework

### Choose SQL (PostgreSQL, MySQL) when:
- Data is relational with complex joins
- Strong ACID guarantees required (financial txns, inventory)
- Schema is stable and well-defined
- Need complex queries / aggregations
- Team is more familiar with relational model

### Choose NoSQL when:
- Need horizontal write scalability beyond one machine
- Schema is flexible / evolving rapidly
- Access patterns are simple and known upfront (key-value, document lookup)
- Need very high write throughput (Cassandra: 100k+ writes/sec per node)

### NoSQL Sub-Types

| Type | Examples | Best For |
|---|---|---|
| Document | MongoDB, Firestore | User profiles, product catalogs |
| Key-Value | DynamoDB, Redis | Sessions, caching, simple lookups |
| Wide-Column | Cassandra, HBase | Time-series, high-write workloads |
| Graph | Neo4j, Amazon Neptune | Social graphs, recommendation engines |
| Time-Series | InfluxDB, TimescaleDB | Metrics, IoT, analytics |

---

## ACID vs BASE

**ACID** (SQL default):
- **Atomicity**: All or nothing
- **Consistency**: Data always valid per schema/constraints
- **Isolation**: Concurrent txns don't interfere
- **Durability**: Committed data survives crashes

**BASE** (NoSQL typical):
- **Basically Available**: System stays available, may return stale data
- **Soft state**: State may change over time without input
- **Eventual consistency**: System will *eventually* converge to consistent state

---

## CAP Theorem (Deep)

In a distributed system, you can only guarantee **2 of 3**:
- **C**onsistency: Every read returns the most recent write
- **A**vailability: Every request gets a response (not necessarily latest)
- **P**artition Tolerance: System works despite network partitions

**Network partitions always happen** → you're really choosing between C and A during a partition.

| System | CAP Choice | Why |
|---|---|---|
| PostgreSQL (single node) | CA | No partitions in single node |
| Cassandra | AP | Availability + eventual consistency |
| HBase | CP | Consistency favored over availability |
| DynamoDB | AP (default) / CP (strong reads) | Configurable per read |
| Zookeeper | CP | Used for coordination, must be correct |

**PACELC Extension** (more nuanced):
- During partitions: choose P→A or P→C
- Else (normal): choose E→L (latency) or E→C (consistency)
- Most real systems tune latency vs consistency in normal operation

---

## Consistency Models (Spectrum)

Strongest → Weakest:

1. **Strict Linearizability**: Operations appear instantaneous, globally ordered
2. **Linearizability**: Each op appears at some point between start/end
3. **Sequential Consistency**: All nodes see same order, not necessarily real-time
4. **Causal Consistency**: Causally related ops seen in order
5. **Read-Your-Writes**: You always see your own writes
6. **Monotonic Reads**: Won't read older data after reading newer
7. **Eventual Consistency**: Will converge, no timing guarantee

**Rule of thumb**: Choose the weakest model that satisfies your SLO. Stronger = more coordination = higher latency.

---

## Sharding Strategies

### Horizontal Sharding (Partitioning)

**Hash-based sharding**:
```
shard_id = hash(user_id) % num_shards
```
- ✅ Even distribution
- ❌ Range queries across shards are expensive
- ❌ Resharding is painful (consistent hashing helps)

**Range-based sharding**:
```
Shard 1: user_id 0–999,999
Shard 2: user_id 1M–1,999,999
```
- ✅ Range queries efficient
- ❌ Hotspots if data isn't uniformly distributed

**Directory-based sharding**: Lookup table maps keys to shards
- ✅ Flexible, easy resharding
- ❌ Lookup table is a bottleneck / SPOF

### Consistent Hashing
Place nodes on a ring. Keys map to next clockwise node. Adding/removing a node only rebalances ~1/N of keys.
Use virtual nodes (vnodes) to improve distribution (each physical node = 100–200 virtual positions).

---

## Replication

### Primary-Replica (Master-Slave)
- Primary handles all writes
- Replicas handle reads
- Replication lag: eventual consistency between primary and replicas
- **Failover**: promote replica on primary failure (manual or auto via orchestrator)

### Multi-Primary (Multi-Master)
- Multiple nodes accept writes
- Conflict resolution required (last-write-wins, CRDTs, application logic)
- Use for: geo-distributed writes, high write availability

### Quorum Reads/Writes (Cassandra model)
```
N = total replicas
W = nodes that must ack a write
R = nodes that must respond to a read

Strong consistency: R + W > N  (e.g., N=3, W=2, R=2)
High availability:  W=1, R=1  (eventual consistency)
```

---

## Indexing Deep Dive

### B-Tree Index (default in PostgreSQL, MySQL)
- Balanced tree, O(log n) reads/writes
- Great for: equality, range queries, ORDER BY
- Poor for: full-text search, geospatial

### LSM Tree (RocksDB, Cassandra, LevelDB)
- Writes go to in-memory memtable → flushed to SSTable on disk
- Compaction merges SSTables periodically
- ✅ Very fast writes (sequential I/O)
- ❌ Reads may need to check multiple SSTables (use bloom filters to avoid)
- Best for: write-heavy workloads

### Other Index Types
| Type | DB | Use Case |
|---|---|---|
| Hash Index | Redis, some DBs | Exact equality only |
| GIN/GiST | PostgreSQL | Full-text, arrays, JSONB |
| Partial Index | PostgreSQL | Index subset of rows (e.g., active=true) |
| Composite Index | All | Multi-column queries — column order matters |
| Covering Index | All | All query columns in index = no table lookup |

**Composite index rule**: Index columns in order of selectivity. For `WHERE a=? AND b=?`, put higher-cardinality column first.

---

## Storage Patterns

### Object Storage (S3, GCS)
- For: images, videos, documents, backups, data lake
- Never store large blobs in relational DB — use S3 + store URL reference in DB
- Presigned URLs for secure, temporary client access

### Data Tiering
```
Hot:  In-memory (Redis)          — microseconds, expensive
Warm: SSD-backed DB (Postgres)   — milliseconds, moderate cost  
Cold: Object storage (S3)        — 10s-100s ms, cheap
Archive: S3 Glacier              — hours retrieval, very cheap
```

Move data down tiers based on access frequency + age (TTL policies).
