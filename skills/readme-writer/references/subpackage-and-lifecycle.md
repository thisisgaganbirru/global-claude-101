# Sub-package READMEs, Project Lifecycle & AI Agent Files

Covers three areas not in other reference files:
1. Sub-package README templates for monorepos
2. Project lifecycle status conventions (active → archived → deprecated)
3. AGENTS.md / CLAUDE.md / AI agent instruction file generation

---

## Table of Contents

1. [Sub-package README Templates](#1-sub-package-readme-templates)
2. [Project Lifecycle & Status Conventions](#2-project-lifecycle--status-conventions)
3. [AGENTS.md / CLAUDE.md Generation](#3-agentsmd--claudemd-generation)

---

## 1. Sub-package README Templates

Every package in a monorepo needs its own README. These are shorter and more focused
than root READMEs — they answer: what is this package, who uses it, and how.

### When to Generate Sub-package READMEs

Generate a sub-package README when:
- A `packages/` or `apps/` directory contains a `package.json`/`pyproject.toml` without a README
- The monorepo root README has a packages index table but individual packages have no docs
- A package is published to npm/PyPI (externally consumed packages ALWAYS need their own README)

### Sub-package README Structure

Sub-package READMEs are deliberately shorter than root READMEs. Target: 50–150 lines.

```
[Badge row — scoped to this package only]
# @scope/package-name
> One-line description of what THIS package does

## Overview
What this package is, who uses it (other internal packages? external consumers?), and
what problem it solves within the monorepo context.

## Installation
(Only if externally published. Skip for internal-only packages.)

## Usage
Minimal example showing how to consume this package.
Focus on the most common usage pattern. Link to Storybook/docs for full API.

## API Reference
Table or list of primary exports with brief descriptions.
For large APIs, link to generated docs (typedoc, storybook, etc.)

## Development
Commands specific to this package:
- How to run tests for just this package
- How to run in watch mode
- How to build

## Maintainers / Ownership
Team or individual responsible. Link to CODEOWNERS if applicable.
```

### Template: Internal Shared Library (`packages/ui`, `packages/utils`)

```markdown
# @acme/ui

> Shared React component library for all Acme products.

Part of the [acme monorepo](../../README.md). Used by `apps/web` and `apps/admin`.

## Overview

Design-system-aligned components built on Radix UI primitives with Tailwind CSS.
Not published to npm — consumed via workspace dependency (`@acme/ui: workspace:*`).

## Usage

\```tsx
import { Button, Card, Input } from '@acme/ui'

export function LoginForm() {
  return (
    <Card>
      <Input placeholder="Email" type="email" />
      <Button variant="primary">Sign in</Button>
    </Card>
  )
}
\```

## Component Reference

| Component | Description | Props |
|---|---|---|
| `Button` | Primary action element | [Button props](./src/Button/Button.tsx) |
| `Card` | Container with shadow + radius | [Card props](./src/Card/Card.tsx) |
| `Input` | Controlled text input | [Input props](./src/Input/Input.tsx) |
| `Modal` | Accessible dialog overlay | [Modal props](./src/Modal/Modal.tsx) |

Full component library: [Storybook](https://ui.acme.internal)

## Development

\```bash
# From monorepo root:
pnpm --filter @acme/ui dev        # start Storybook
pnpm --filter @acme/ui test       # run tests
pnpm --filter @acme/ui build      # build dist/

# Or from this directory:
cd packages/ui
pnpm dev
\```

## Maintainers

Design Systems team — [#team-design-systems](slack://channel?id=...) · [@acme/design-systems](../../.github/CODEOWNERS)
```

### Template: Published npm/PyPI Package

```markdown
[![npm](https://img.shields.io/npm/v/@scope/package?style=flat&logo=npm)](https://npmjs.com/package/@scope/package)
[![Build](https://github.com/ORG/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/ORG/REPO/actions/workflows/ci.yml)
[![License](https://img.shields.io/npm/l/@scope/package?style=flat)](../../LICENSE)

# @scope/package-name

> One-line description. What it does and for whom.

Part of the [monorepo](../../README.md).

## Installation

\```bash
npm install @scope/package-name
\```

## Usage

\```typescript
import { doThing } from '@scope/package-name'

const result = doThing({ option: 'value' })
// → { success: true, data: ... }
\```

## API

### `doThing(options)`

| Parameter | Type | Required | Description |
|---|---|---|---|
| `options.option` | `string` | ✅ | Controls the thing |
| `options.timeout` | `number` | ❌ | Timeout in ms (default: `5000`) |

**Returns:** `Promise<Result>`

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history.
```

### Template: Backend Service / App (`apps/api`)

```markdown
# API Service

> Core REST API for the Acme platform. Handles authentication, business logic, and
> data persistence.

Part of the [acme monorepo](../../README.md).

## Overview

- **Framework**: Express 4 + TypeScript
- **Database**: PostgreSQL via Prisma
- **Auth**: JWT (access) + refresh token rotation
- **Runs on**: Port 4000 in development

## Running Locally

\```bash
# From monorepo root (recommended — starts all dependencies):
pnpm dev

# Standalone (requires postgres + redis running separately):
cd apps/api
pnpm dev
\```

API available at: http://localhost:4000
Swagger docs: http://localhost:4000/docs

## Environment Variables

See [`.env.example`](./.env.example) for the full list with descriptions.
Required: `DATABASE_URL`, `JWT_SECRET`, `REDIS_URL`

## Commands

| Command | Description |
|---|---|
| `pnpm dev` | Start in watch mode |
| `pnpm build` | Compile TypeScript |
| `pnpm test` | Run unit + integration tests |
| `pnpm test:e2e` | Run end-to-end API tests |
| `pnpm db:migrate` | Run pending migrations |

## Architecture

See [architecture diagram](../../docs/architecture.md) for system context.

## Maintainers

Platform team — [#team-platform](slack://...) · [@acme/platform](../../.github/CODEOWNERS)
```

---

## 2. Project Lifecycle & Status Conventions

### The Project Status Shield

Always add a project status badge when the maintenance state is non-obvious. Place it
**below the badge row** but above the description — it's the first thing a user needs to know.

```markdown
<!-- Active and maintained -->
[![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat)]()

<!-- Feature complete, bugs only -->
[![Status: Maintenance](https://img.shields.io/badge/Status-Maintenance%20Only-yellow?style=flat)]()

<!-- No longer maintained but usable -->
[![Status: Unsupported](https://img.shields.io/badge/Status-Unsupported-orange?style=flat)]()

<!-- No longer maintained, use alternative -->
[![Status: Deprecated](https://img.shields.io/badge/Status-Deprecated-red?style=flat)]()

<!-- Frozen intentionally -->
[![Status: Archived](https://img.shields.io/badge/Status-Archived-lightgrey?style=flat)]()
```

### Archived Project Banner

Use a prominent GitHub Alert at the very top of the README, before everything including
the badge row. This ensures it's visible even when the repo is archived on GitHub:

```markdown
> [!CAUTION]
> **This repository is archived and no longer maintained.**
> It was last updated in [MONTH YEAR] and is kept public for reference only.
> It will not receive bug fixes, security patches, or new features.
>
> **Consider these alternatives:**
> - [new-library](https://github.com/org/new-library) — actively maintained successor
> - [other-option](https://github.com/org/other-option) — similar scope
```

Then add the archived status shield and keep the rest of the README readable but clearly
dated. Add a `## ⚠️ Archive Notice` section early in the document repeating this information
for readers who land mid-page.

### Deprecated Package (Still Installable)

For packages still on npm/PyPI but superseded:

```markdown
> [!WARNING]
> **`@scope/old-package` is deprecated.** Install `@scope/new-package` instead.
>
> \```bash
> npm uninstall @scope/old-package
> npm install @scope/new-package
> \```
>
> Migration guide: [docs/migrating-from-v1.md](./docs/migrating-from-v1.md)
> `@scope/old-package` will be unpublished on [DATE].
```

### "Looking for Maintainer" Notice

```markdown
> [!IMPORTANT]
> **This project is looking for a new maintainer.**
> The current maintainer no longer has bandwidth to review PRs or triage issues.
> If you're interested in taking over, open an issue titled "Maintainer request" or
> reach out at [email/link].
>
> The project still works but may not receive timely updates.
```

### Pre-release / Experimental Status

For alpha/beta projects or API-unstable early releases:

```markdown
> [!WARNING]
> **This project is in early development (v0.x).** The public API is unstable and
> may change in breaking ways in minor releases until v1.0.
> Pin to exact versions: `npm install package@0.4.2`

[![Status: Beta](https://img.shields.io/badge/Status-Beta-blue?style=flat)]()
```

### Versioning + Breaking Change Notices

When a README covers a multi-version project, add a version selector notice:

```markdown
> [!NOTE]
> **You are reading docs for v3.x (latest).**
> Docs for older versions: [v2.x](https://github.com/org/repo/tree/v2/README.md) ·
> [v1.x](https://github.com/org/repo/tree/v1/README.md)
>
> **Upgrading from v2?** See the [migration guide](./docs/migrating-v2-to-v3.md).
```

---

## 3. AGENTS.md / CLAUDE.md Generation

This is the emerging frontier of project documentation (2024–2025). Cutting-edge repos
(Transformers, LangChain, Nx, Cal.com) are shipping instruction files for AI coding agents
alongside their README. A README writer skill should generate these files too.

### When to Generate an AI Agent File

Generate an `AGENTS.md` or `CLAUDE.md` when:
- The project has a complex local setup (multiple services, non-obvious commands)
- The codebase has strong conventions that an AI agent would violate without guidance
- There are non-obvious test/build commands that differ from defaults
- The project uses a monorepo with per-package commands
- There are API keys, secrets, or env vars an agent must never touch
- The project has custom lint/format tooling with opinionated rules

### File Naming Conventions

Different AI tools look for different filenames:

| File | Tool | Location |
|---|---|---|
| `CLAUDE.md` | Claude Code (primary) | Repo root or `.claude/` |
| `AGENTS.md` | OpenAI Codex, general agents | Repo root |
| `.cursor/rules` | Cursor IDE | `.cursor/` directory |
| `.gemini/guidelines.md` | Gemini CLI | `.gemini/` directory |
| `.github/copilot-instructions.md` | GitHub Copilot | `.github/` directory |

**Recommendation**: Generate `CLAUDE.md` for Claude Code projects. If the project is
open-source and multi-tool, generate `AGENTS.md` as the canonical file and symlink or
copy to `CLAUDE.md`.

### CLAUDE.md Structure & Template

```markdown
# CLAUDE.md

This file provides guidance for Claude Code (claude.ai/code) when working in this repository.

## Project Overview

[2–3 sentences: what the project is, what tech stack, what the primary purpose is.
This gives the agent immediate context without reading the whole README.]

## Repository Structure

\```
[paste the directory tree from the README, or generate a focused version]
\```

## Development Setup

### Prerequisites
- [exact tool versions required]

### Getting Started
\```bash
[the exact commands to get from zero to running dev environment]
\```

## Common Commands

| Task | Command |
|---|---|
| Start dev server | `pnpm dev` |
| Run all tests | `pnpm test` |
| Run tests (watch) | `pnpm test:watch` |
| Lint | `pnpm lint` |
| Format | `pnpm format` |
| Type check | `pnpm typecheck` |
| Build | `pnpm build` |
| Database migrations | `pnpm db:migrate` |

## Code Conventions

### [Language/Framework]-specific rules
[3–8 bullet points of real conventions observed in the codebase — naming patterns,
file organization, import style, component patterns, etc. Extract these by reading
the actual source files, not by inventing them.]

### Testing
- Test framework: [jest/vitest/pytest/etc.]
- Test files live in: [location pattern — e.g., `__tests__/` or `*.test.ts` co-located]
- Run a single test: `[command]`
- Coverage threshold: [if configured in package.json/pyproject.toml]

### Git Conventions
- Commit format: [conventional commits / custom / none]
- Branch naming: [feature/, fix/, chore/ etc. if observable from .git or CI]
- PR process: [squash merge / merge commits / rebase]

## Architecture Notes

[2–5 bullet points of non-obvious architectural decisions the agent should know.
Things that would cause incorrect code if not known:
- "All database queries go through the repository pattern in `src/db/`"
- "Never import from `@acme/ui` directly in API code — it's browser-only"
- "State management uses Zustand, not Redux or Context"
- "All API routes must be validated with Zod schemas before business logic"]

## Security & Secrets

> [!CAUTION]
> - Never commit `.env` files or any files containing real secrets
> - API keys and tokens are in `.env.local` (gitignored) — never read or log their values
> - [list any specific env vars that are especially sensitive]

## What NOT to Do

[List the most dangerous or common mistakes an AI agent could make in this repo:
- "Do not modify `packages/database/migrations/` — use `pnpm db:migration:create`"
- "Do not change `tsconfig.json` — it is shared across all packages"
- "Do not add `console.log` to production code — use the Logger utility at `src/lib/logger`"
- "Do not update lock files manually — always run `pnpm install`"]

## Known Gotchas

[Non-obvious things that trip up even human engineers:
- Environment quirks
- Platform-specific behaviors
- Things that look broken but are intentional
- Flaky tests and their known causes]
```

### How to Extract Content for CLAUDE.md

The agent should derive CLAUDE.md content from the codebase, not invent it:

**For "Code Conventions":**
- Read 5–10 files in `src/` or `lib/` to observe actual naming patterns
- Check `.eslintrc`, `biome.json`, `ruff.toml`, `.editorconfig` for explicit rules
- Read existing test files to understand test patterns

**For "Architecture Notes":**
- Read `src/index.ts` or main entry point
- Look for `README.md` files in subdirectories
- Check for `docs/architecture.md` or ADR files
- Read `src/db/`, `src/services/`, `src/lib/` to understand layering

**For "What NOT to Do":**
- Check `CONTRIBUTING.md` for explicit rules
- Look at CI pipeline for automated checks that would catch violations
- Check `package.json` scripts to understand the intended workflow

**For "Common Commands":**
- Extract from `package.json` scripts, `Makefile`, or `justfile`
- Prefer commands defined in config over raw commands

### AGENTS.md Variant (Open Source / Multi-tool)

For public OSS projects, use `AGENTS.md` at the root. Keep it shorter and more
universal — don't reference Claude-specific features:

```markdown
# AGENTS.md

Instructions for AI coding assistants working in this repository.

## Quick Context

[Project name] is a [brief description]. Stack: [tech stack]. Primary language: [lang].

## Setup

\```bash
[minimal commands to get running]
\```

## Commands Reference

\```bash
npm test          # run test suite
npm run lint      # lint + format check
npm run build     # production build
npm run typecheck # type check only
\```

## Conventions

- [bullet point conventions observed in codebase]
- [naming patterns]
- [file organization rules]

## Do Not

- [list of things agents commonly get wrong in this codebase]
- Never modify [specific files/directories]

## Testing

- Framework: [name]
- Location: [pattern]
- To run a single test: `[command]`
```

### When NOT to Generate an AI Agent File

Skip AGENTS.md / CLAUDE.md when:
- The project is a simple library with standard conventions (install → use → done)
- There are no non-obvious commands or setup steps
- The project has an excellent README that already covers everything an agent needs
- The project is archived / read-only

In these cases, note in the README audit output that no agent file was generated and why.
