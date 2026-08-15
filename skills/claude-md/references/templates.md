# CLAUDE.md Starter Templates

Three templates calibrated to project complexity. Choose based on project size and team.
Replace all `[PLACEHOLDER]` text — placeholders in a real CLAUDE.md are worse than blanks
because they look complete but aren't.

---

## Template 1: Minimal (scripts, small tools, solo projects)

Use for: personal tools, scripts, small utilities, single-file or few-file projects.

```markdown
# [Project Name]

[One or two sentences: what this does and what matters most about it. Example:
"CLI tool that converts CSV exports from [Service] into normalized SQL inserts.
Correctness of the output is the only thing that matters — speed is irrelevant."]

## Stack
[Language + version]. Key dependencies: [list the 2–4 that matter].

## How to Run
[Exact command to run the tool]
[Exact command to run tests, if any]

## Conventions
[2–5 bullet points of the non-obvious conventions an agent needs to know]

## ⚠️ Critical Notes
[1–3 specific gotchas — if there are none yet, put "None identified — update as the
project evolves"]
```

---

## Template 2: Standard (typical application, small-to-mid team)

Use for: web apps, APIs, services with a real tech stack and 2–8 contributors.

```markdown
<!-- Last reviewed: [DATE] | Reviewer: [NAME/ROLE] | Next review: [DATE] -->

# [Project Name]

[2–4 sentences: what this system does, who uses it, and what its dominant constraint is.
The dominant constraint is the thing that should break ties on every technical decision —
is it latency? correctness? cost? developer experience? Be explicit.

Example: "B2B invoicing API serving ~200 enterprise customers. Processes payments via
Stripe. The dominant constraint is data integrity — incorrect financial records are the
failure mode we optimize against above all else."]

## Architecture Overview
[3–6 sentences or a short component list. What are the main components and how do they
relate? What's the data flow at a high level? Don't list every file — just the structure
an agent needs to make sane placement decisions for new code.]

## Tech Stack
- **Language:** [Language + exact version, e.g., "Python 3.11 — no 3.12 syntax, the
  deployment target doesn't support it yet"]
- **Framework:** [Framework + version]
- **Database:** [DB + ORM/query library if relevant]
- **Key libraries:** [List libraries where the choice affects how an agent should write code]
- **Package manager:** [e.g., "npm — not yarn, not pnpm"]

## Development Workflow

### Local Setup
```bash
# [Step-by-step commands for a clean setup. Each command on its own line with a comment
# explaining what it does if it's not obvious.]
[setup command 1]  # [what this does]
[setup command 2]  # [what this does]
```

### Required Environment Variables
[List the env vars the project needs to function, with a note on where to get each one.
Example:
- `DATABASE_URL` — PostgreSQL connection string. Copy from `.env.example` and set for local DB.
- `STRIPE_SECRET_KEY` — Get from the Stripe dashboard (test keys for local, never real keys).]

### Running Tests
```bash
[exact test command]          # Run all tests
[exact test command + filter] # Run a single test file
```

### Build & Lint
```bash
[lint command]
[build command if applicable]
```

## Project Conventions

**File naming:** [Exact pattern with an example]

**Function/variable naming:** [Convention with an example. Call out any exceptions.]

**Import ordering:** [If you have a linter that enforces this, just say that. If not, state the preference.]

**Error handling:** [How errors should be surfaced. Example: "All user-facing errors must
use the `AppError` class in `src/errors.ts`. Never throw raw JavaScript Error objects."]

**Testing patterns:** [What kind of tests, where they live, naming convention.]

**[Any other conventions specific to this project — add as many as needed]**

## Key File Map

The non-obvious files and directories an agent needs to know about:

- `[path]` — [what lives here and why it matters]
- `[path]` — [what lives here and why it matters]
- `[path]` — [what lives here and why it matters]
[Add 5–12 entries. Don't list every directory — just the ones where "where does X go?"
is a real question.]

## ⚠️ Critical Warnings

⚠️ [Warning 1: Specific. Names the exact thing to avoid, the exact location, and why.
Example: "Never import from `src/legacy/` directly — that code is scheduled for deletion
and has known bugs. Use the equivalent functions in `src/core/` instead."]

⚠️ [Warning 2]

⚠️ [Warning 3]

[Add as many as the project warrants. An empty Critical Warnings section for a real
project is almost always a gap — dig harder.]

## Agent Scope & Boundaries

**Autonomous (no confirmation needed):**
[List what the agent can do freely — write code, run tests, edit configs, etc.]

**Requires confirmation:**
[List what the agent should pause and ask about before doing — e.g., deleting files,
running migrations, pushing to remote, etc.]

**Off-limits:**
[List what the agent must not do regardless of what's asked — e.g., "Never run any command
against the production database. Never commit credentials. Never modify `[protected path]`
without an explicit instruction from the user in the same message."]
```

---

## Template 3: Comprehensive (large codebase, multi-team, or monorepo)

Use for: large systems, monorepos, or projects with 8+ contributors where precision and
explicit governance matter.

This template assumes a hierarchical structure (see `hierarchy.md`). The root CLAUDE.md
covers project-wide concerns; subdirectory files cover domain-specific concerns.

```markdown
<!-- Last reviewed: [DATE] | Owner: [TEAM/ROLE] | Review cadence: [MONTHLY/QUARTERLY] -->
<!-- Changes to this file require review from: [TEAM or ROLE] -->

# [System Name]

## System Overview
[3–5 sentences: what this system is, who it serves, what problem it solves, and its
dominant constraints. For a large system, state the top 2–3 constraints explicitly since
they'll affect decisions across many domains.

Example: "Platform monorepo for [Company]'s customer-facing product suite. Serves ~X
users across Y services. Dominant constraints: (1) availability — 99.9% SLA, (2) data
consistency — we'd rather be slow than wrong, (3) backwards compatibility — API changes
must not break existing clients without a deprecation window."]

## Repository Structure
[High-level map of the monorepo. Not every file — just the top-level directories and what
they contain, plus a note about where service-specific CLAUDE.md files live.]

```
/services/      — Individual microservices (each has its own CLAUDE.md)
/packages/      — Shared libraries (each has its own CLAUDE.md)
/infra/         — Infrastructure as code (see infra/CLAUDE.md for agent scope)
/scripts/       — Operational scripts (see header comments in each for intended use)
/docs/          — Architecture decision records and runbooks
```

Service-specific context lives in `[service-path]/CLAUDE.md`. This root file covers
cross-cutting concerns only.

## Global Tech Stack
[Language + version, build tooling, monorepo manager (e.g., Turborepo, Nx), CI/CD system,
deployment platform. Anything that affects how an agent should work at the root level.]

## Cross-Service Conventions

**Service communication:** [How services talk to each other — REST, gRPC, events, etc.
Include the schema registry or contract testing approach if there is one.]

**Shared libraries:** [How shared packages are versioned, how to add a new shared package,
when to create a shared package vs. duplicate code in a service.]

**Database ownership:** [Which services own which databases. Services never access another
service's database directly. Cross-service data needs go through the service's API.]

**Authentication & authorization:** [Where auth lives, what pattern services use,
what an agent must never bypass.]

## Global Commit and PR Conventions
[Commit message format with an example. Branch naming convention. PR size guidelines.
Required CI checks before merge. Code owner file location if relevant.]

## Cross-Cutting Warnings ⚠️

⚠️ [Warning that applies across the whole codebase — shared pattern to avoid, global
gotcha, cross-service footgun]

⚠️ [Warning about the CI/CD pipeline or deployment process]

⚠️ [Warning about shared infrastructure that could affect multiple services]

## Global Agent Scope

**Always permitted at root level:**
[What the agent can do globally without asking]

**Always requires confirmation:**
[What the agent must pause on — e.g., anything touching `infra/`, any change that
touches a public API contract, any database migration]

**Always off-limits:**
[Hard stops — production credentials, production database access, pushing to protected
branches directly, etc.]

## Escalation and Ownership
[For large teams, who to consult for what. Role-based references, not names.
Example: "Changes to the authentication service require sign-off from the security team.
Changes to public API contracts require sign-off from the API governance team."]
```

---

## Template Selection Guide

| Project characteristic | Template |
|------------------------|----------|
| Solo, <500 lines of code | Minimal |
| Solo, 500–10K lines | Standard |
| Small team (2–4), any size | Standard |
| Mid team (5–8), single service | Standard |
| Mid team (5–8), multiple services | Comprehensive |
| Large team (8+), any size | Comprehensive |
| Monorepo | Comprehensive |
| Prototype / throwaway | Minimal |
| Production system with SLAs | Comprehensive |
