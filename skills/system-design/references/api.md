# API Design & Service Communication Reference

## REST vs gRPC vs GraphQL

| | REST | gRPC | GraphQL |
|---|---|---|---|
| Protocol | HTTP/1.1 or HTTP/2 | HTTP/2 | HTTP/1.1 or HTTP/2 |
| Format | JSON (typically) | Protocol Buffers (binary) | JSON |
| Schema | OpenAPI (optional) | .proto (required) | Schema (required) |
| Typing | Loose | Strict | Strict |
| Streaming | ❌ (SSE/WebSocket separate) | ✅ bi-directional | ❌ (subscriptions via WS) |
| Browser support | ✅ Native | ⚠️ Needs grpc-web | ✅ Native |
| Payload size | Larger (text JSON) | Smaller (binary, ~5–10x) | Variable |
| Best for | Public APIs, CRUD | Internal microservices, high-throughput | Client-driven queries, BFF pattern |

### REST
Use when:
- Building public-facing APIs (broad tooling, easy to consume)
- Simple CRUD operations
- Cacheability is important (GET requests are cacheable)
- Team/clients prefer JSON + OpenAPI tooling

### gRPC
Use when:
- Internal service-to-service communication
- Strict contracts between services (proto schema = contract)
- Performance matters (binary protocol, multiplexed HTTP/2)
- Need streaming (server streaming, client streaming, bidirectional)

```protobuf
service UserService {
  rpc GetUser (GetUserRequest) returns (User);
  rpc StreamEvents (StreamRequest) returns (stream Event);
}
```

### GraphQL
Use when:
- Frontend needs flexible queries (avoid over/under-fetching)
- Multiple clients with different data needs (mobile vs web)
- BFF (Backend for Frontend) pattern
- Rapid product iteration

Avoid when:
- Simple, stable data access patterns (REST is simpler)
- High-performance requirements (introspection + resolver overhead)
- Aggressive caching needed (dynamic queries are harder to cache)

---

## REST API Design Best Practices

### URL Structure
```
GET    /users/{id}              # Get resource
POST   /users                   # Create resource
PUT    /users/{id}              # Full replace
PATCH  /users/{id}              # Partial update
DELETE /users/{id}              # Delete resource

GET    /users/{id}/orders       # Nested resource
GET    /orders?user_id={id}     # Alternative: filter via query param
```

### HTTP Status Codes (Use Correctly)
```
200 OK              — Success, body contains response
201 Created         — Resource created, include Location header
204 No Content      — Success, no body (DELETE, some PATCHes)
400 Bad Request     — Client error, malformed request
401 Unauthorized    — Not authenticated
403 Forbidden       — Authenticated but not authorized
404 Not Found       — Resource doesn't exist
409 Conflict        — State conflict (duplicate, optimistic lock)
422 Unprocessable   — Valid format, invalid business logic
429 Too Many Reqs   — Rate limited
500 Internal Error  — Server error (don't leak internals)
503 Unavailable     — Overloaded, retry-able
```

### Versioning Strategies

| Approach | Example | Trade-off |
|---|---|---|
| URL versioning | `/v1/users` | ✅ Obvious, easy to route; ❌ URL changes |
| Header versioning | `API-Version: 2024-01-01` | ✅ Clean URLs; ❌ Less visible |
| Content negotiation | `Accept: application/vnd.api.v2+json` | ✅ REST purist; ❌ Complex |

**Recommendation**: URL versioning for public APIs (most tooling supports it), header versioning for internal APIs.

---

## Rate Limiting

### Algorithms

**Fixed Window Counter**:
```
window = floor(now / 60)  # 1-minute windows
key = f"rate:{user_id}:{window}"
count = redis.incr(key)
redis.expire(key, 60)
if count > LIMIT: reject()
```
- ❌ Burst at window boundary (2x limit possible)

**Sliding Window Log**:
```
redis.zremrangebyscore(key, 0, now - 60000)  # Remove old entries
redis.zadd(key, {request_id: now})
if redis.zcard(key) > LIMIT: reject()
```
- ✅ Accurate, no boundary burst
- ❌ Memory: stores every request timestamp

**Token Bucket** (recommended):
- Bucket fills at rate R tokens/sec, max capacity B
- Each request consumes 1 token
- ✅ Allows bursting up to B, smooth long-term rate
- Implemented in: Nginx, AWS API Gateway

**Leaky Bucket**:
- Requests queue up, processed at fixed rate
- ✅ Smooth output rate
- ❌ Doesn't allow bursting, requests can wait

### Rate Limit Headers
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1640000000
Retry-After: 30
```

### Tiered Rate Limiting
```
Free tier:    100 req/min
Pro tier:    1000 req/min
Enterprise: 10000 req/min
```
Store tier in JWT or API key metadata; look up on each request.

---

## API Gateway Pattern

Sits in front of all services, handles:
- Authentication / Authorization
- Rate limiting
- SSL termination
- Request routing
- Response transformation
- Logging / tracing

```
Client → API Gateway → Auth Service (validate token)
                     → Service A
                     → Service B
```

**Options**: Kong, AWS API Gateway, Nginx, Envoy, Traefik

---

## Service-to-Service Communication

### Synchronous (Request/Response)
- REST or gRPC
- Use when: caller needs result immediately to continue
- Problem: caller availability coupled to callee availability

### Asynchronous (Message-Passing)
- Kafka, SQS, RabbitMQ
- Use when: result not needed immediately, or for fan-out
- ✅ Decoupled, resilient to downstream failures

### Service Mesh
For large microservice deployments: Istio, Linkerd
- Handles: mutual TLS, circuit breaking, retries, observability
- Sidecars intercept all traffic (no app code changes)
- Adds latency (~1ms), operational complexity

---

## Resilience Patterns

### Circuit Breaker
```
CLOSED (normal) → on failures > threshold → OPEN (fail fast)
OPEN → after timeout → HALF-OPEN (test one request)
HALF-OPEN → success → CLOSED; failure → OPEN
```
Prevents cascading failures when downstream is slow/down.
Libraries: Resilience4j (Java), hystrix (deprecated), polly (.NET)

### Retry with Exponential Backoff + Jitter
```
delay = min(base * 2^attempt, max_delay) + random_jitter
```
- Jitter prevents synchronized retry storms
- Only retry idempotent operations (GET, PUT, DELETE)
- Don't retry: 400, 401, 403, 422 (client errors won't succeed on retry)

### Timeout Strategy
Every external call must have a timeout. Without it, slow downstream causes thread exhaustion.
```
Timeout hierarchy:
  Client timeout > Gateway timeout > Service timeout > DB timeout
  e.g., 30s       > 25s             > 20s             > 15s
```

### Bulkhead Pattern
Isolate resources for different operations to prevent cascading failure.
```
Thread pool A: handles critical payment calls (20 threads)
Thread pool B: handles non-critical analytics calls (5 threads)
// Thread pool B exhaustion doesn't impact A
```

---

## API Security

### Authentication
- **API Keys**: Simple, for server-to-server. Not suitable for user auth.
- **JWT**: Stateless, self-contained. Verify signature, check expiry, validate claims.
- **OAuth2 + OIDC**: Delegated auth. Use for user-facing APIs.

### JWT Best Practices
```
Header:  { alg: "RS256", typ: "JWT" }  // Use RS256 (asymmetric), not HS256
Payload: { sub: "user_123", exp: ..., iat: ..., scope: "read:orders" }
// Verify: signature, expiry, issuer, audience
// Short TTL (15min access token) + refresh token rotation
```

### Common Vulnerabilities
- **Mass Assignment**: Never accept raw JSON body into ORM. Whitelist fields explicitly.
- **IDOR** (Insecure Direct Object Reference): Always verify ownership. `/orders/456` → check user owns order 456.
- **Injection**: Parameterized queries always. ORM doesn't guarantee safety if raw SQL used.
- **Rate limit bypass**: Limit by user ID *and* IP (harder to spoof both simultaneously).
