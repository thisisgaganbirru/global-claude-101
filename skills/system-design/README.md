# System Design Skill

Expert-level distributed systems design for Claude. Covers the full stack of distributed systems knowledge — from back-of-envelope math to CAP theorem, from Kafka internals to rate limiting algorithms.

## What This Skill Does

- **Designs systems** from scratch with structured docs, Mermaid diagrams, and capacity estimates
- **Reviews existing architectures** and proactively flags anti-patterns and outdated tech
- **Adapts to your stack** — recommendations change based on language, cloud, team size, budget
- **Stays current** — flags when trends have changed the standard answer (Selenium → Playwright, CRA → Vite, ELK → Loki, etc.)
- **Challenges assumptions** — doesn't just optimise within a bad frame, names the real problem

## File Structure

```
system-design/
├── SKILL.md                    # Core skill — loaded on every trigger
└── references/
    ├── storage.md              # SQL/NoSQL, CAP, sharding, replication, indexing
    ├── messaging.md            # Kafka, queues, pub/sub, exactly-once, sagas
    ├── caching.md              # Redis, CDN, eviction, thundering herd
    ├── api.md                  # REST, gRPC, GraphQL, rate limiting, auth
    ├── blueprints.md           # Pre-built patterns: URL shortener, feed, chat, payments, video
    ├── capacity.md             # DAU→QPS math, SLO tables, cost estimates
    ├── antipatterns.md         # 20 real failure patterns with war stories
    └── trends.md               # Current standards: AI infra, observability, DB, frontend, infra
```

## Trigger Phrases

- "Design a system for..."
- "How would you architect..."
- "What's the best database for..."
- "How do I scale..."
- "Design Twitter / Uber / Slack / YouTube..."
- "What are the trade-offs between..."
- "Review my architecture"
- Any mention of: microservices, APIs, databases, caching, message queues, distributed systems

## Depth Levels

| Signal | Response style |
|---|---|
| Beginner — vague requirements, asks "what is X" | Guided walkthrough, analogies, simple examples |
| Mid-level — mentions tools, has rough design | Trade-off analysis, concrete recommendations |
| Senior/Staff — mentions SLOs, CAP, consistency models | Deep dives, math, nuanced failure mode analysis |

## Version History

- **v1.0.0** — Initial release. Core domains: storage, messaging, caching, API, blueprints, capacity, antipatterns, trends.
