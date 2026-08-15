# Messaging & Event Streaming Reference

## Core Concepts: Queue vs Stream vs Pub/Sub

| | Message Queue | Event Stream | Pub/Sub |
|---|---|---|---|
| Examples | SQS, RabbitMQ | Kafka, Kinesis | SNS, Google Pub/Sub |
| Retention | Until consumed | Time-based (configurable) | Until delivered |
| Consumers | One consumer per message | Multiple, independent | All subscribers |
| Replay | ❌ | ✅ | ❌ |
| Ordering | Per-queue (FIFO optional) | Per-partition | No guarantee |
| Use case | Task queues, work distribution | Event sourcing, analytics pipelines | Fan-out notifications |

**Decision guide**:
- Need task distribution to workers? → **Queue** (SQS)
- Need replay, audit log, or multiple independent consumers? → **Stream** (Kafka)
- Need to fan out one event to many services? → **Pub/Sub** (SNS → SQS pattern)

---

## Kafka Deep Dive

### Architecture
```
Producer → [Topic: Partitions 0,1,2] → Consumer Group A
                                     → Consumer Group B (independent offset)
```

- **Topic**: Logical channel for events
- **Partition**: Ordered, immutable log; unit of parallelism
- **Offset**: Position of a message within a partition
- **Consumer Group**: Set of consumers sharing partitions (each partition → one consumer)
- **Broker**: Kafka server; a cluster has multiple brokers
- **Replication factor**: Each partition replicated across N brokers (typically 3)

### Ordering Guarantees
- **Within a partition**: Strict ordering guaranteed
- **Across partitions**: No ordering guarantee
- **Key-based routing**: Same key always → same partition (use for user-level ordering)

```
// Ensure all events for user_123 are ordered:
producer.send(topic, key="user_123", value=event)
```

### Delivery Semantics

| Semantic | How | Risk |
|---|---|---|
| At-most-once | Don't retry on failure | Message loss |
| At-least-once | Retry + idempotent consumer | Duplicate processing |
| Exactly-once | Kafka transactions + idempotent producer | Complexity, latency cost |

**In practice**: Design consumers to be **idempotent** and use at-least-once. Exactly-once is rarely worth the complexity except for financial systems.

### Consumer Lag & Backpressure
- **Consumer lag** = latest offset − consumer offset
- High lag = consumers can't keep up with producers
- Solutions: scale out consumers (add partitions first), optimize consumer processing, use batch processing

### Kafka vs Alternatives

| | Kafka | Kinesis | RabbitMQ | SQS |
|---|---|---|---|---|
| Throughput | Very high (millions/sec) | High | Moderate | Moderate |
| Retention | Days–forever | 7–365 days | Until consumed | 14 days |
| Ordering | Per-partition | Per-shard | Per-queue | FIFO queue only |
| Managed | Self-hosted or Confluent | AWS managed | Self-hosted or CloudAMQP | AWS managed |
| Best for | High-volume pipelines, event sourcing | AWS-native, simpler ops | Complex routing, RPC | Simple task queues |

---

## Message Ordering Patterns

### Global Ordering (avoid if possible)
- Single partition = single consumer = not scalable
- Only use for truly global sequences (e.g., ledger entries)

### Per-Entity Ordering (recommended)
- Partition by entity key (user_id, order_id)
- Parallelism across entities, ordering within each

### Causal Ordering
- Include vector clocks or sequence numbers in messages
- Consumer enforces ordering by buffering out-of-order events

---

## Exactly-Once Processing Patterns

### Idempotency Key Pattern
```
// Producer generates unique ID
message = { id: uuid(), event_type: "ORDER_PLACED", ... }

// Consumer checks before processing
if not already_processed(message.id):
    process(message)
    mark_processed(message.id)
```
Store processed IDs in Redis (with TTL) or dedupe table in DB.

### Transactional Outbox Pattern
Problem: Writing to DB and publishing event atomically.
```
// In same DB transaction:
INSERT INTO orders (id, ...) VALUES (...)
INSERT INTO outbox (event_type, payload, published=false) VALUES (...)

// Separate outbox worker:
SELECT * FROM outbox WHERE published = false
publish_to_kafka(events)
UPDATE outbox SET published = true WHERE id IN (...)
```
Guarantees event is published exactly once if DB transaction commits.

---

## Backpressure & Flow Control

**Problem**: Fast producer, slow consumer → unbounded queue growth → OOM / latency spike

**Solutions**:
1. **Consumer scaling**: Add more consumers (requires more partitions in Kafka)
2. **Rate limiting producers**: Slow down at source
3. **Dead letter queue (DLQ)**: Route failed/slow messages to DLQ for later retry
4. **Circuit breaker**: Stop consuming if downstream is unhealthy

---

## Event-Driven Architecture Patterns

### Saga Pattern (distributed transactions)
Replaces 2PC for multi-service transactions.

**Choreography**: Each service listens for events and reacts
```
OrderService → ORDER_CREATED event
PaymentService listens → processes payment → PAYMENT_COMPLETED event
InventoryService listens → reserves stock → STOCK_RESERVED event
```
- ✅ Loose coupling
- ❌ Hard to track overall transaction state

**Orchestration**: Central saga orchestrator directs services
```
SagaOrchestrator → calls PaymentService
                 → calls InventoryService
                 → handles failures with compensating txns
```
- ✅ Clear transaction flow
- ❌ Orchestrator becomes a bottleneck / coupling point

### CQRS (Command Query Responsibility Segregation)
Separate write model (commands) from read model (queries).
```
Write path: API → Command → Event → Write DB
Read path:  Event → Projection → Read DB (optimized for queries)
```
Use when read and write patterns are fundamentally different (e.g., write normalized, read denormalized).

### Event Sourcing
Store all state changes as events, not current state.
```
events = [
  { type: ACCOUNT_CREATED, balance: 0 },
  { type: DEPOSIT, amount: 100 },
  { type: WITHDRAWAL, amount: 30 },
]
current_state = replay(events)  // balance = 70
```
- ✅ Full audit log, time-travel debugging, replayable
- ❌ Complex queries, snapshot needed for long histories
