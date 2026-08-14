# Local Session Memory System

> **`mem/` is local-only and gitignored** — a per-machine working memory,
> not a shared git artifact. This file covers the naming, frontmatter, and
> search conventions. For the separate `docs/` documentation-first hook
> (`docs_workflow.py`), see [`DOCS_WORKFLOW_README.md`](DOCS_WORKFLOW_README.md).
> For the enforcement layer — a global Claude Code hook (`mem_workflow.py`)
> that auto-creates `mem/`, reminds you each turn, and blocks finishing if
> source changed with no session-log entry — see
> [`MEM_WORKFLOW_README.md`](MEM_WORKFLOW_README.md).

Pure filesystem-based memory system. No external APIs, no dependencies, no tokens, zero cost.

**Everything is searchable Markdown files. Local to this machine.**

## Files

| File | Purpose | What It Does |
|------|---------|--------------|
| `SessionEnd.ps1` | Create daily session summary | Appends task to `/mem/YYYYMMDD-session.md` |
| `MemSearch.ps1` | Search all memory files | `MemSearch.ps1 'oauth'` finds all matching entries |
| `SetupGitHook.ps1` | Install pre-commit hook | One-time setup per project |
| `README.md` | This file | Reference guide |

## Setup (One-time Per Project)

**Note:** you likely don't need to run anything below. If the global
`mem_workflow.py` hook is installed (see `MEM_WORKFLOW_README.md`), `mem/`
enforcement already runs automatically in every Claude Code session — no
per-project setup required. The git hook below is only a cross-tool
backstop for commits made by *other* tools (Codex, Gemini CLI, a human).

```powershell
cd C:\path\to\your\project
pwsh $env:USERPROFILE\.claude\hooks\SetupGitHook.ps1
```

This will:
- ✓ Create `.git/hooks/pre-commit.bat` (Windows batch format)
- ✓ Add `/mem/` to `.gitignore`
- ✓ Warn (but not block) commits without /mem/ entries

**Known issue:** confirmed by direct test that Git for Windows never
executes a hook literally named `pre-commit.bat` — only an extensionless
`pre-commit` file. This script's check has therefore likely never actually
fired on any project it was run against. Use
`pwsh $env:USERPROFILE\.claude\hooks\SetupMemGitHook.ps1` instead — it
writes the correct extensionless hook and has been verified to run (see
`MEM_WORKFLOW_README.md`). `.gitignore`-ing `/mem/` is also arguably wrong
given the rest of this doc's own workflow assumes `/mem/` is committed
alongside code ("Files live in git alongside code" below) — `SetupMemGitHook.ps1`
deliberately does not touch `.gitignore`.

## Workflow

### 1. At End of Each Task

Create `/mem/YYYYMMDD-{task-slug}.md`:

```markdown
# Task Name - 2025-06-01

## The Ask
What was requested?

## Changes Made
Files modified, functions added, configs changed

## Decisions & Rationale
Why this way, trade-offs, alternatives

## Current Architecture
System state after change
```

**Template location:** `$env:USERPROFILE\.claude\mem\template.md`

### 2. Search Memory

Find related work using PowerShell:

```powershell
# Basic search
pwsh $env:USERPROFILE\.claude\hooks\MemSearch.ps1 "oauth"

# Show context (surrounding lines)
pwsh $env:USERPROFILE\.claude\hooks\MemSearch.ps1 "token" -ShowContext

# Multiple lines of context
pwsh $env:USERPROFILE\.claude\hooks\MemSearch.ps1 "database" -ContextLines 5
```

Or use native PowerShell:
```powershell
grep -r "oauth" ./mem --include="*.md"
grep -r "token" ./mem --include="*.md" -A 2 -B 2
```

### 3. Commit Code

Pre-commit hook will warn if code changed without a /mem/ entry:

```
!! WARNING: Code changed but no /mem/ entry for today (20250601).

Before committing code changes, document your work:

  1. Create: mem/20250601-task-name.md
  2. Include: The Ask, Changes Made, Decisions, Architecture
  3. Then commit again

To bypass: git commit --no-verify
```

**It warns but doesn't block.** Use `--no-verify` if truly urgent.

## Examples

### Example 1: OAuth Implementation

**File:** `./mem/20250601-oauth-setup.md`

```markdown
# OAuth2 Implementation - 2025-06-01

## The Ask
Add OAuth2 login to dashboard. Must integrate with existing user table.

## Changes Made
- `src/auth/oauth.py` — OAuthProvider class
- `config/env.example` — OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET
- `src/routes/login.py` — integrated OAuth flow

## Decisions & Rationale
Chose authlib over oauthlib (handles token refresh automatically).
Added 5s timeout for slow OAuth servers.

## Current Architecture
LoginPage → OAuthFlow → OAuthProvider → authlib.OAuthClient
Token stored in session, User model updated.
```

**Search it:**
```powershell
MemSearch.ps1 "oauth"
MemSearch.ps1 "authlib" -ShowContext
grep -r "OAuthProvider" ./mem
```

### Example 2: Daily Session Log

**File:** `./mem/20250601-session.md`

```markdown
# Session Log - 2025-06-01

### 09:00 - OAuth Setup
Status: Completed
Changes: Added OAuthProvider class, integrated with LoginPage
Next: Add token refresh tests

### 14:30 - PDF Merger
Status: In progress
Changes: Refactoring form field handler
Issues: iText7 compatibility issue with encrypted PDFs
```

## Naming Convention

```
YYYYMMDD-{task-slug}.md
```

Examples:
- `20250601-oauth-setup.md`
- `20250601-pdf-merger.md`
- `20250602-database-migration.md`
- `20250602-session.md` (daily journal)

**Rules:**
- One file per task per day
- If task continues next day: create new file with next day's date
- Slug: lowercase, hyphens only

## Architecture Decisions Log

Keep a master log of major decisions:

**File:** `./mem/DECISIONS.md`

```markdown
# Architecture Decisions

### OAuth2 over session-based auth
- **Date:** 2025-06-01
- **Rationale:** Async scales better, authlib handles refresh
- **Status:** ✅ Implemented
- **Trade-off:** More complex setup, but scales to 1000+ users

### iText7 for PDF forms (not PDFKit)
- **Date:** 2025-06-01
- **Rationale:** Full form field support needed
- **Status:** ✅ Implemented
- **Trade-off:** Larger dependency, much better form handling
```

**Search it:**
```powershell
MemSearch.ps1 "OAuth2"
grep -r "decision" ./mem --include="*.md"
```

## Session Logging

Run at end of workday to create daily journal:

```powershell
pwsh $env:USERPROFILE\.claude\hooks\SessionEnd.ps1 -MemDir ./mem
```

Creates/appends to `./mem/YYYYMMDD-session.md` with time and task placeholder.

Edit it with your actual work:

```markdown
### 09:00 - OAuth Setup
Status: Completed
Changes: ...
```

## Troubleshooting

### Hook not running
1. Check `.git/hooks/pre-commit` exists
2. Try running manually: `& .git\hooks\pre-commit`
3. Re-run `SetupGitHook.ps1`

### Search not finding results
```powershell
# Check memory files exist
ls ./mem

# Check file content
cat ./mem/20250601-*.md

# Verify grep syntax
grep -r "term" ./mem --include="*.md"
```

### Hook blocking when I don't want it
Bypass with:
```powershell
git commit --no-verify
```

## Key Principles

✅ **Pure Markdown** — All memory is `.md` files, human-readable, version-controllable  
✅ **Local Only** — Everything on your filesystem, no cloud, no APIs  
✅ **Searchable** — grep or MemSearch.ps1 finds anything instantly  
✅ **Zero Cost** — No tokens, no API calls, completely free  
✅ **No Dependencies** — Just PowerShell and git (already installed)  
✅ **Self-Contained** — Single /mem/ directory per project  

## Quick Start

1. Run setup in your project:
   ```powershell
   pwsh $env:USERPROFILE\.claude\hooks\SetupGitHook.ps1
   ```

2. Create a task entry:
   ```powershell
   # Use template
   cat $env:USERPROFILE\.claude\mem\template.md > ./mem/$(Get-Date -Format 'yyyyMMdd')-task.md
   # Edit in your editor
   ```

3. Search your memory:
   ```powershell
   pwsh $env:USERPROFILE\.claude\hooks\MemSearch.ps1 "oauth"
   ```

4. Commit:
   ```powershell
   git add .
   git commit -m "message"
   ```

---

**All memory is local. All searches are instant. Zero external calls. Zero cost.**
