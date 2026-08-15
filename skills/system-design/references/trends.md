# Trends & Current Standards Reference

This file tracks fast-moving spaces where the "standard answer" changes year over year.
Check this before finalising recommendations in any of these domains.
Last meaningful content update: 2025/2026 cycle.

---

## How to Use This File

For each domain below, the pattern is:
- **What changed**: what the new standard is
- **What's outdated**: what to stop recommending
- **Signals to watch for**: phrases/tools that indicate the user is behind the curve

---

## 1. Observability & Monitoring

### What changed
OpenTelemetry (OTel) is now the industry standard for instrumentation. Vendor lock-in via proprietary
SDKs is the old way. You instrument once with OTel, route to any backend (Datadog, Grafana, Jaeger, etc.)

Logs + Metrics + Traces are converging. Modern stacks handle all three in one pipeline.

### Current standard stack (2025/2026)
- **Instrumentation**: OpenTelemetry SDK (language-native)
- **Traces**: Jaeger (self-hosted) or Datadog APM / Honeycomb (managed)
- **Metrics**: Prometheus + Grafana (self-hosted) or Datadog / Grafana Cloud
- **Logs**: Loki + Grafana (self-hosted) or Datadog Logs / Axiom
- **All-in-one managed**: Datadog, Grafana Cloud, Honeycomb

### What's outdated
- Proprietary vendor SDKs for instrumentation (lock-in, hard to migrate)
- Zipkin (superseded by Jaeger / OTel-native backends)
- ELK stack (Elasticsearch + Logstash + Kibana) for logs — operationally heavy; Loki is simpler
- Custom log parsing pipelines — OTel Collector handles this

### Signals to watch for
User mentions "we use Zipkin", "ELK stack", "custom logging agent", "no distributed tracing" →
flag OpenTelemetry as the migration path.

---

## 2. AI / LLM Infrastructure

### What changed
A new class of infrastructure problems emerged in 2023–2025 around LLM-powered features:
vector databases, RAG pipelines, LLM gateways, prompt management, and AI observability.

### Current standard patterns (2025/2026)

**Vector Databases** (for semantic search, RAG):
- **Managed / simple**: Pinecone, Weaviate Cloud, Qdrant Cloud
- **Self-hosted**: Qdrant, Weaviate, Milvus
- **Postgres-native**: pgvector (good for <10M vectors, avoids new infra)
- **Avoid**: building your own ANN index — solved problem

**RAG Pipeline**:
```
User query → embed query (OpenAI/Cohere) → vector search → retrieve top-K chunks
           → inject into prompt → LLM (GPT-4o / Claude / Llama) → response
```
- Chunking strategy matters: 512–1024 tokens with overlap is standard starting point
- Hybrid search (vector + BM25 keyword) beats pure vector search for most use cases
- Reranking (Cohere Rerank, cross-encoder) improves quality significantly

**LLM Gateway / Proxy**:
- LiteLLM (open source) — unified API across OpenAI, Anthropic, Cohere, local models
- Portkey, Helicone — managed gateways with caching, rate limiting, cost tracking
- Never hit LLM APIs directly from product code — add a gateway layer for retries, fallbacks, cost control

**LLM Observability**:
- Langsmith (LangChain), Langfuse (open source), Helicone — trace prompts, evals, costs
- Standard practice: log every prompt + completion + latency + cost in production

**Streaming responses**:
- Always stream LLM responses to frontend — users abandon non-streaming UIs
- Server-Sent Events (SSE) is the standard transport for streaming

### What's outdated
- Storing embeddings in Postgres without pgvector (just use pgvector or a real vector DB)
- Calling OpenAI directly with no retry/fallback logic
- Treating LLM calls like regular API calls (no observability, no cost tracking)

### Signals to watch for
User building LLM features without mentioning vector DB, RAG, or gateway → flag these gaps.

---

## 3. Frontend Architecture

### What changed
React Server Components (RSC) and Next.js App Router changed the default rendering model.
The line between frontend and backend blurred. Edge rendering is now mainstream.

### Current standard (2025/2026)
- **Default framework**: Next.js 14+ (App Router) for new React projects
- **Rendering**: RSC for data-fetching components, client components for interactivity
- **API layer**: Route Handlers in Next.js or tRPC for type-safe internal APIs
- **State management**: Zustand or Jotai for client state; React Query / SWR for server state
- **Styling**: Tailwind CSS is dominant; CSS Modules still valid
- **Auth**: NextAuth.js / Auth.js, Clerk (managed)
- **Deployment**: Vercel (easiest), Cloudflare Pages, or self-hosted on Node

### What's outdated / challenged
- Create React App (CRA) — deprecated, dead. Use Vite or Next.js
- Redux for all state — overkill for most apps; use Zustand + React Query
- REST API from separate Express server for same-org frontend — use Next.js Route Handlers or tRPC
- Class components — functional + hooks is the standard

### Signals to watch for
User mentions CRA, Redux for everything, separate Express backend for SPA → flag updates.

---

## 4. Database Landscape Shifts

### What changed
Several new databases gained real production adoption. The "just use Postgres" answer is still
often correct, but the landscape has meaningful additions.

### Current options worth knowing (2025/2026)

**OLTP (transactional)**:
- **PostgreSQL**: Still the default. pgvector, JSONB, full-text search built in.
- **PlanetScale**: MySQL-compatible, branching workflow, serverless pricing (but dropped free tier 2024)
- **Neon**: Serverless Postgres, branch-per-PR workflow, good for dev/staging
- **Turso**: SQLite-based, edge-distributed, good for read-heavy global apps
- **Supabase**: Postgres + Auth + Storage + Realtime in one — good for startups

**OLAP (analytical)**:
- **ClickHouse**: Columnar, extremely fast for analytics queries, open source
- **DuckDB**: In-process analytical DB (like SQLite for analytics), great for local/embedded analytics
- **BigQuery / Redshift / Snowflake**: Managed cloud data warehouses — standard for large-scale analytics

**NewSQL / Distributed**:
- **CockroachDB**: Distributed Postgres-compatible, global consistency
- **Spanner (GCP)**: Globally distributed, strong consistency — expensive but battle-tested
- **TiDB**: MySQL-compatible distributed DB, good for write-heavy horizontal scale

### What's outdated thinking
- "Use MongoDB for everything flexible" — Postgres JSONB covers most use cases without schema sacrifice
- "We need a separate analytics DB from day one" — start with Postgres, add ClickHouse when queries get slow
- "DynamoDB for all NoSQL" — only if you're deep AWS and access patterns are truly key-value

### Signals to watch for
User on MongoDB for relational workload → Postgres. User running analytics on operational DB → ClickHouse or BigQuery.

---

## 5. Infrastructure & Deployment

### What changed
Serverless matured. Edge computing went mainstream. Container orchestration simplified.

### Current standard (2025/2026)

**Deployment options by team size**:
```
1–5 engineers:   Railway, Render, Fly.io — no DevOps needed
5–20 engineers:  ECS (AWS) or Cloud Run (GCP) — containers without k8s complexity  
20+ engineers:   EKS/GKE/AKS — k8s with managed control plane
Serverless:      Lambda / Cloud Functions / Vercel Edge for stateless, bursty workloads
```

**Serverless is now viable for**:
- API endpoints with bursty traffic (Lambda cold start improved: ~100ms with provisioned concurrency)
- Background jobs and event handlers
- Edge middleware (auth, redirects, A/B testing at CDN edge)

**Serverless is NOT good for**:
- Long-running tasks (>15 min Lambda limit)
- Stateful workloads
- High-frequency, sustained throughput (cost >> container)
- WebSocket connections

**Infrastructure as Code**:
- **Terraform**: Still standard for multi-cloud
- **Pulumi**: Terraform but in real programming languages — gaining adoption
- **CDK (AWS)**: Good for AWS-only teams
- **Avoid**: clicking in the console for anything that matters

### What's outdated
- Self-managed k8s for teams without a platform team
- Heroku (pricing changed, lost momentum — use Railway/Render/Fly)
- Jenkins for CI/CD (use GitHub Actions, GitLab CI, or Buildkite)
- Ansible for container deployments (k8s / ECS replaced this use case)

### Signals to watch for
User on Heroku → suggest Railway/Render migration. User running Jenkins → GitHub Actions.
User self-managing k8s with <20 engineers → flag the ops cost, suggest ECS or managed k8s.

---

## 6. API & Integration Trends

### What changed
- **tRPC** became standard for TypeScript full-stack apps (end-to-end type safety, no code gen)
- **OpenAPI** tooling matured — Zod + OpenAPI generation is common now
- **Webhooks** standardised around Svix for delivery, retries, and observability
- **gRPC** remains dominant for internal microservices; **Connect** (Buf) is the modern gRPC alternative with HTTP/JSON support

### Current standard (2025/2026)
- TypeScript full-stack → tRPC or OpenAPI with auto-generated types
- Internal services → gRPC or Connect (Buf)
- Public APIs → REST with OpenAPI spec + SDK generation
- Webhooks at scale → Svix (managed webhook delivery) rather than hand-rolling

### What's outdated
- Hand-writing API clients from documentation
- SOAP (still exists in enterprise, but never recommend for new systems)
- Custom webhook delivery without retry/observability

---

## 7. Security Trends

### What changed
- **Supply chain attacks** are now a primary threat vector — dependency auditing is mandatory
- **Zero Trust** architecture replaced perimeter security as the default model
- **Secrets management** has clear tooling standards now

### Current standards (2025/2026)

**Secrets management**:
- HashiCorp Vault (self-hosted) or AWS Secrets Manager / GCP Secret Manager
- Never: `.env` files in repos, secrets in environment variables baked into images, secrets in code

**Auth**:
- Passkeys (WebAuthn) are the emerging standard for user auth — passwordless
- OAuth2 + OIDC still standard for federated identity
- JWTs: RS256 (asymmetric) over HS256 (symmetric) — can verify without sharing secret

**Zero Trust**:
- Every service call authenticated, even internal
- mTLS between services (service mesh handles this) or JWT service tokens
- No implicit trust based on network location

### Signals to watch for
User storing secrets in `.env` in git, using HS256 JWTs, no secrets rotation → flag each.

---

## 8. Data Engineering Trends

### What changed
The "modern data stack" solidified around a clear set of tools.
dbt became the standard transformation layer. Medallion architecture is the default pattern.

### Current standard (2025/2026)

**Modern Data Stack**:
```
Ingestion:      Fivetran / Airbyte (managed connectors)
Storage:        Snowflake / BigQuery / Databricks / ClickHouse
Transformation: dbt (SQL-based, version-controlled, testable)
Orchestration:  Airflow / Prefect / Dagster
BI / Reporting: Metabase / Looker / Superset
```

**Medallion Architecture** (standard data lake pattern):
```
Bronze: raw ingested data (never modified)
Silver: cleaned, validated, deduplicated
Gold:   business-level aggregates, ready for BI
```

**Streaming data**:
- Kafka → Flink (stateful streaming) or Spark Structured Streaming
- Simpler option: Kafka → ksqlDB for stream processing without JVM complexity

### What's outdated
- Custom ETL scripts instead of dbt
- Hadoop/MapReduce (replaced by Spark, Flink, and cloud-native solutions)
- Storing raw data only in operational DB for analytics

### Signals to watch for
User writing custom Python ETL scripts for data transformation → suggest dbt.
User running analytics on operational Postgres → suggest ClickHouse or BigQuery.
