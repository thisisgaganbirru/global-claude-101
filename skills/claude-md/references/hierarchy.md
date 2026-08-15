# CLAUDE.md Hierarchy Patterns

For large codebases, a single root CLAUDE.md becomes unwieldy. The hierarchical pattern
uses multiple CLAUDE.md files — one at the root, and additional files in subdirectories
that load contextually as the agent navigates.

---

## When to Use Hierarchy

Use a single root CLAUDE.md when:
- The codebase is a single service or application
- The agent typically works across the whole project
- The file is under 400 lines with meaningful content in every section

Use a hierarchical structure when:
- The codebase contains multiple services, packages, or domains
- Different parts of the codebase have significantly different conventions
- The root CLAUDE.md is growing beyond 400 lines, and meaningful sections exist that
  only apply to one area of the codebase

---

## How Claude Code Loads CLAUDE.md Files

Claude Code loads CLAUDE.md files in a specific order:

1. The root CLAUDE.md is always loaded at session start
2. When Claude navigates into a subdirectory, it checks for a CLAUDE.md there and loads it
3. The subdirectory CLAUDE.md supplements (not replaces) the root — both are in context

This means:
- Root CLAUDE.md = project-wide truths that apply everywhere
- Subdirectory CLAUDE.md = domain-specific truths for that area

Don't repeat root-level content in subdirectory files. Cross-reference instead:
"See root CLAUDE.md for project-wide conventions — this file covers service-specific
patterns only."

---

## Standard Hierarchy Pattern

For a monorepo or multi-service project:

```
/
├── CLAUDE.md                     ← Project overview, global conventions, root-level scope
├── services/
│   ├── api/
│   │   └── CLAUDE.md             ← API service specifics: routes, auth patterns, versioning
│   ├── worker/
│   │   └── CLAUDE.md             ← Worker specifics: queue patterns, retry logic, idempotency
│   └── frontend/
│       └── CLAUDE.md             ← Frontend specifics: component patterns, state management
├── packages/
│   ├── shared-types/
│   │   └── CLAUDE.md             ← Type library: versioning rules, breaking change policy
│   └── utils/
│       └── CLAUDE.md             ← Utilities: what's here, what's intentionally not here
└── infra/
    └── CLAUDE.md                 ← Infrastructure: what the agent can and cannot touch here
```

---

## Root CLAUDE.md Responsibilities in a Hierarchy

The root file should cover:
- Project-level orientation (what is this whole system, what matters most)
- Global tech stack and version constraints
- Universal conventions that apply everywhere (commit format, PR process, etc.)
- Cross-service concerns (how services communicate, shared auth patterns)
- The overall directory structure and what lives where
- Global scope and safety constraints

The root file should NOT cover:
- Service-specific commands (`cd services/api && npm test` belongs in `services/api/CLAUDE.md`)
- Domain-specific patterns (auth token handling belongs in the auth service's CLAUDE.md)
- Subsystem-specific warnings (database schema gotchas belong near the DB layer)

---

## Subdirectory CLAUDE.md Responsibilities

Each subdirectory file should cover:
- The purpose and scope of this area (what problem does this service/package solve)
- Local setup and test commands
- Domain-specific conventions and patterns
- Domain-specific warnings and gotchas
- Local scope — what the agent can/cannot touch within this directory

Always start a subdirectory CLAUDE.md with a header that names the service/package and
states where the root CLAUDE.md is:

```markdown
# [Service Name] — Service-Specific Context

> This file covers [service name] only. See root `/CLAUDE.md` for project-wide context.

[2-sentence summary of what this service does within the larger system]
```

---

## Depth Limit

Do not go deeper than two levels of CLAUDE.md nesting (root + one subdirectory level)
unless the codebase is genuinely complex enough to warrant it. Three levels is almost
always a sign that the content needs to be reorganized, not deepened.

---

## Hierarchy Anti-patterns

**The orphaned subdirectory file:** A subdirectory CLAUDE.md that restates everything
from the root, making it impossible to tell which version of a constraint is authoritative.
Fix: make root the single source, subdirectory files additive only.

**The over-split flat project:** Splitting a 200-line root CLAUDE.md into a hierarchy of
five subdirectory files when the project is a simple monolith. This is premature
organization that adds navigation overhead without benefit.

**The inconsistent depth:** Some services have CLAUDE.md files, some don't. This creates
uncertainty about whether a missing file means "same as root" or "someone forgot." Either
all major services have one, or none do. Pick a policy.

**Conflicting constraints:** Root says "use tabs" and a subdirectory file says "use spaces
for this service." Pick one global truth. If a genuine exception exists, state it explicitly:
"Exception to root convention: this service uses 2-space indent because it was originally a
separate project and the legacy parser requires it."
