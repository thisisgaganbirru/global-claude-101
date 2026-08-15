# Mermaid Diagram Patterns

Concrete, working Mermaid syntax patterns for READMEs. All patterns are validated for
GitHub rendering (Mermaid v11.4.1 as of 2025). Read this during Phase 4.

---

## Table of Contents

1. [Rendering Rules & Hard Constraints](#1-rendering-rules--hard-constraints)
2. [Flowchart — Architecture & Data Flow](#2-flowchart--architecture--data-flow)
3. [Sequence Diagram — API & Auth Flows](#3-sequence-diagram--api--auth-flows)
4. [ER Diagram — Data Models](#4-er-diagram--data-models)
5. [Class Diagram — SDK & Library Structure](#5-class-diagram--sdk--library-structure)
6. [Git Graph — Branching Models](#6-git-graph--branching-models)
7. [C4 Diagrams — System Context & Containers](#7-c4-diagrams--system-context--containers)
8. [Pipeline / Data Flow — ML & ETL](#8-pipeline--data-flow--ml--etl)
9. [Monorepo Dependency Graph](#9-monorepo-dependency-graph)
10. [Anti-Patterns to Avoid](#10-anti-patterns-to-avoid)

---

## 1. Rendering Rules & Hard Constraints

### What renders on GitHub (rock-solid)
- `flowchart` (TD, LR, BT, RL)
- `sequenceDiagram`
- `erDiagram`
- `classDiagram`
- `gitGraph`
- `stateDiagram-v2`
- `pie`, `mindmap`, `timeline`, `quadrantChart`
- `C4Context`, `C4Container`, `C4Component` (native, marked experimental)

### What does NOT render on GitHub
- `architecture-beta` — requires icon pack registration, not available in GitHub sandbox
- `kanban` — too new
- `packet` — too new
- Any diagram using Font Awesome icons
- Click events, tooltips, hyperlinks within diagram nodes

### Hard rules — violating these breaks diagrams

1. **NEVER set a `theme` directive.** This overrides GitHub's auto dark/light theming:
   ```
   %%{init: {"theme": "dark"}}%%   ← BREAKS dark mode, do not use
   ```
   Use `themeVariables` for color customization if needed, but leave `theme` unset.

2. **Max 20 nodes per diagram.** GitHub renders in fixed-width containers. Beyond 20 nodes,
   readability collapses. Split complex systems into multiple focused diagrams.

3. **Always add title and accessibility metadata:**
   ```
   ---
   title: My Diagram Title
   ---
   accDescr: Brief description of what this diagram shows
   flowchart TD
       ...
   ```

4. **Use `flowchart`, not deprecated `graph`:**
   ```
   flowchart TD    ← correct
   graph TD        ← deprecated, still works but avoid
   ```

5. **Escape special characters in node labels.** Parentheses, quotes, and angle brackets
   break rendering:
   ```
   A["Process (item)"]     ← quotes around label for parens
   B["Filter &lt;data&gt;"] ← HTML escape for < >
   ```

6. **Embed in code fences with `mermaid` language hint:**
   ````markdown
   ```mermaid
   flowchart TD
       ...
   ```
   ````

---

## 2. Flowchart — Architecture & Data Flow

### Node Shapes

| Syntax | Shape | Use for |
|---|---|---|
| `A[text]` | Rectangle | Generic process/service |
| `A[(text)]` | Cylinder | Database, storage |
| `A([text])` | Stadium | External service, API |
| `A{text}` | Diamond | Decision point |
| `A>text]` | Asymmetric | Event, message |
| `A((text))` | Circle | Start/end |
| `A[[text]]` | Subroutine | Subprocess |

### Link Types

| Syntax | Renders as | Use for |
|---|---|---|
| `A --> B` | Arrow | Synchronous call |
| `A -.-> B` | Dotted arrow | Async, optional, event |
| `A ==> B` | Thick arrow | Primary/critical path |
| `A --- B` | Line (no arrow) | Association |
| `A -->|label| B` | Labeled arrow | Named relationships |

### Three-Tier SaaS Architecture Example

```mermaid
---
title: System Architecture
---
accDescr: Three-tier architecture showing client, API gateway, services, and data stores
flowchart TD
    subgraph Client["Client Layer"]
        WEB([Web App])
        MOB([Mobile App])
    end

    subgraph API["API Layer"]
        GW[API Gateway]
        AUTH[Auth Service]
    end

    subgraph Services["Service Layer"]
        US[User Service]
        PS[Payment Service]
        NS[Notification Service]
    end

    subgraph Data["Data Layer"]
        DB[(PostgreSQL)]
        CACHE[(Redis)]
        QUEUE[(Message Queue)]
    end

    WEB --> GW
    MOB --> GW
    GW --> AUTH
    GW --> US
    GW --> PS
    PS -.-> QUEUE
    QUEUE -.-> NS
    US --> DB
    US --> CACHE
    PS --> DB
```

### Simple Two-Component Example (for small projects)

```mermaid
---
title: Request Flow
---
flowchart LR
    CLI([CLI Input]) --> Parser[Argument Parser]
    Parser --> Validator{Valid?}
    Validator -->|Yes| Processor[Core Processor]
    Validator -->|No| Err[Error Output]
    Processor --> Output([Result Output])
```

---

## 3. Sequence Diagram — API & Auth Flows

### Core Syntax

```
sequenceDiagram
    actor User           ← human actor (stick figure icon)
    participant App      ← service (rectangle)
    participant Auth as Auth Service   ← alias

    User ->> App: HTTP POST /login
    App ->> Auth: Validate credentials
    Auth -->> App: JWT token
    App -->> User: 200 OK + Set-Cookie
```

Arrow types:
- `->>` solid arrow (synchronous call)
- `-->>` dashed arrow (response/return)
- `-x` solid with X (failed/error)
- `--x` dashed with X (failed response)

### OAuth 2.0 / PKCE Flow Example

```mermaid
---
title: OAuth 2.0 Authorization Code + PKCE Flow
---
sequenceDiagram
    autonumber
    actor User
    participant App as Client App
    participant Auth as Auth Server
    participant API as Resource API

    User ->> App: Click "Sign in with Provider"
    App ->> App: Generate code_verifier + code_challenge
    App ->> Auth: GET /authorize?code_challenge=...
    Auth ->> User: Show login & consent screen
    User ->> Auth: Enter credentials + approve
    Auth -->> App: Redirect with authorization_code
    App ->> Auth: POST /token (code + code_verifier)
    Auth -->> App: access_token + refresh_token
    App ->> API: GET /resource (Bearer token)
    API -->> App: Protected resource data
```

### REST API Request Lifecycle Example

```mermaid
---
title: API Request Lifecycle
---
sequenceDiagram
    participant Client
    participant Gateway as API Gateway
    participant Auth as Auth Middleware
    participant Handler as Route Handler
    participant DB as Database

    Client ->> Gateway: POST /api/v1/items
    Gateway ->> Auth: Validate JWT
    alt Token invalid
        Auth -->> Client: 401 Unauthorized
    else Token valid
        Auth -->> Gateway: User context
        Gateway ->> Handler: Request + user context
        Handler ->> DB: INSERT item
        DB -->> Handler: New item record
        Handler -->> Client: 201 Created + item JSON
    end
```

---

## 4. ER Diagram — Data Models

### Cardinality Notation

| Notation | Meaning |
|---|---|
| `\|\|` | Exactly one |
| `o\|` | Zero or one |
| `\|\{` | One or many |
| `o\{` | Zero or many (most common for "has many") |

### Full Example — SaaS Data Model

```mermaid
---
title: Core Data Model
---
erDiagram
    USER {
        uuid id PK
        string email UK
        string name
        timestamp created_at
        timestamp updated_at
    }

    ORGANIZATION {
        uuid id PK
        string name
        string slug UK
        string plan
        timestamp created_at
    }

    MEMBERSHIP {
        uuid id PK
        uuid user_id FK
        uuid org_id FK
        string role
    }

    PROJECT {
        uuid id PK
        uuid org_id FK
        string name
        string status
        timestamp created_at
    }

    USER ||--o{ MEMBERSHIP : "belongs to"
    ORGANIZATION ||--o{ MEMBERSHIP : "has"
    ORGANIZATION ||--o{ PROJECT : "owns"
```

---

## 5. Class Diagram — SDK & Library Structure

### Core Syntax

```
classDiagram
    class ClassName {
        +publicField: Type
        -privateField: Type
        #protectedField: Type
        +publicMethod(arg: Type) ReturnType
        -privateMethod() void
    }
    ClassName <|-- SubClass      ← inheritance
    ClassName *-- Component      ← composition
    ClassName o-- Associated     ← aggregation
    ClassName --> Dependency     ← dependency
    ClassName ..|> Interface     ← realization
```

### SDK Client Example

```mermaid
---
title: SDK Class Structure
---
classDiagram
    class Client {
        -config: ClientConfig
        -httpClient: HttpClient
        +constructor(apiKey: string, options?: ClientOptions)
        +users: UserResource
        +projects: ProjectResource
    }

    class BaseResource {
        #client: Client
        #basePath: string
        +list(params?: ListParams) Promise~Page~
        +get(id: string) Promise~T~
        +create(data: CreateParams) Promise~T~
        +delete(id: string) Promise~void~
    }

    class UserResource {
        +me() Promise~User~
        +updateProfile(data: UpdateUserParams) Promise~User~
    }

    class ProjectResource {
        +deploy(id: string) Promise~Deployment~
    }

    Client *-- UserResource : users
    Client *-- ProjectResource : projects
    BaseResource <|-- UserResource
    BaseResource <|-- ProjectResource
```

---

## 6. Git Graph — Branching Models

### Core Syntax

```
gitGraph
    commit
    branch feature/my-feature
    checkout feature/my-feature
    commit id: "Add feature"
    commit id: "Add tests"
    checkout main
    merge feature/my-feature
    commit id: "v1.2.0" tag: "v1.2.0"
```

### Trunk-Based Development Example

```mermaid
---
title: Git Branching Model
---
gitGraph LR
    commit id: "Initial commit"
    commit id: "v1.0.0" tag: "v1.0.0"

    branch feat/auth
    checkout feat/auth
    commit id: "Add OAuth"
    commit id: "Add tests"

    checkout main
    branch fix/critical-bug
    checkout fix/critical-bug
    commit id: "Fix null ptr" type: HIGHLIGHT

    checkout main
    merge fix/critical-bug id: "Hotfix merge"
    commit id: "v1.0.1" tag: "v1.0.1"

    merge feat/auth id: "Feature merge"
    commit id: "v1.1.0" tag: "v1.1.0"
```

---

## 7. C4 Diagrams — System Context & Containers

C4 diagrams are natively built into Mermaid. Marked experimental on GitHub but render
reliably for Context and Container levels. Use for complex SaaS or platform products.

### C4 Context (Level 1 — System in its environment)

```mermaid
---
title: System Context
---
C4Context
    title System Context for MyApp

    Person(user, "End User", "A user of the application")
    Person(admin, "Admin", "Internal operator")

    System(myapp, "MyApp", "Core application platform")

    System_Ext(stripe, "Stripe", "Payment processing")
    System_Ext(sendgrid, "SendGrid", "Transactional email")
    System_Ext(auth0, "Auth0", "Identity provider")

    Rel(user, myapp, "Uses", "HTTPS")
    Rel(admin, myapp, "Administers", "HTTPS")
    Rel(myapp, stripe, "Processes payments", "REST API")
    Rel(myapp, sendgrid, "Sends emails", "REST API")
    Rel(myapp, auth0, "Authenticates users", "OIDC")
```

### C4 Container (Level 2 — Internal components)

```mermaid
---
title: Container Diagram
---
C4Container
    title Container Diagram for MyApp

    Person(user, "End User")

    Container_Boundary(app, "MyApp") {
        Container(web, "Web App", "Next.js", "Serves the UI")
        Container(api, "API", "Express", "Handles business logic")
        Container(worker, "Worker", "BullMQ", "Background jobs")
        ContainerDb(db, "Database", "PostgreSQL", "Primary data store")
        ContainerDb(cache, "Cache", "Redis", "Session + job queue")
    }

    Rel(user, web, "Uses", "HTTPS")
    Rel(web, api, "API calls", "REST/JSON")
    Rel(api, db, "Reads/writes", "SQL")
    Rel(api, cache, "Reads/writes", "Redis protocol")
    Rel(worker, db, "Reads/writes", "SQL")
    Rel(api, worker, "Enqueues jobs", "BullMQ")
```

---

## 8. Pipeline / Data Flow — ML & ETL

Use `flowchart LR` (left-to-right) for pipelines — it naturally shows stages flowing forward.

### ML Training Pipeline

```mermaid
---
title: Training Pipeline
---
flowchart LR
    subgraph Ingestion
        RAW[(Raw Data)] --> VALID[Validation]
        VALID --> CLEAN[Cleaning]
    end

    subgraph Features["Feature Engineering"]
        CLEAN --> TOK[Tokenization]
        TOK --> EMB[Embedding]
        EMB --> NORM[Normalization]
    end

    subgraph Training
        NORM --> SPLIT{Train/Val Split}
        SPLIT -->|80%| TRAIN[Model Training]
        SPLIT -->|20%| EVAL[Evaluation]
        TRAIN --> CKPT[(Checkpoint)]
        CKPT --> EVAL
    end

    subgraph Deploy
        EVAL -->|Metric threshold met| EXPORT[ONNX Export]
        EXPORT --> SERVE([Model Server])
    end
```

### ETL Pipeline

```mermaid
---
title: ETL Data Pipeline
---
flowchart LR
    SRC1([Postgres DB]) --> EXT[Extractor]
    SRC2([REST API]) --> EXT
    SRC3([S3 Files]) --> EXT
    EXT --> TRANS[Transformer]
    TRANS --> VALID{Valid?}
    VALID -->|Yes| LOAD[Loader]
    VALID -->|No| DLQ[(Dead Letter Queue)]
    LOAD --> DW[(Data Warehouse)]
    LOAD --> CACHE[(Redis Cache)]
```

---

## 9. Monorepo Dependency Graph

```mermaid
---
title: Package Dependency Graph
---
flowchart TD
    subgraph Apps
        WEB[apps/web]
        API[apps/api]
        ADMIN[apps/admin]
    end

    subgraph Packages
        UI[packages/ui]
        DB[packages/database]
        UTILS[packages/utils]
        CONFIG[packages/config]
    end

    WEB --> UI
    WEB --> UTILS
    WEB --> CONFIG
    API --> DB
    API --> UTILS
    API --> CONFIG
    ADMIN --> UI
    ADMIN --> DB
    ADMIN --> UTILS
    UI --> CONFIG
    DB --> CONFIG
```

---

## 10. Anti-Patterns to Avoid

### ❌ Do not use `theme` directives
```
%%{init: {"theme": "dark"}}%%   ← breaks GitHub dark mode
%%{init: {"theme": "forest"}}%% ← overrides auto-theme
```

### ❌ Do not use `architecture-beta`
```
architecture-beta               ← will NOT render on GitHub
    service db(database)[DB]
    ...
```

### ❌ Do not exceed 20 nodes
```
flowchart TD
    A --> B --> C --> D --> E --> F --> G --> H --> I --> J
    J --> K --> L --> M --> N --> O --> P --> Q --> R --> S --> T
    ← 20+ nodes: unreadable in GitHub fixed-width container
```
Solution: split into multiple diagrams (Context → Container → Component, C4 style).

### ❌ Do not use special characters unescaped in labels
```
A[Process (item)]    ← may break
B[Check: valid?]     ← may break
```
Correct:
```
A["Process (item)"]  ← quote the label
B["Check: valid?"]   ← quote the label
```

### ❌ Do not use `graph` (deprecated)
```
graph TD    ← deprecated
flowchart TD ← use this instead
```

### ✅ Always use title frontmatter + accDescr
```mermaid
---
title: Authentication Flow
---
accDescr: Sequence showing user login via OAuth 2.0 PKCE
sequenceDiagram
    ...
```
