# Session Memory Rules

## Project Memory Standards (Local Filesystem Only)

### Directory Structure
- Never create CLAUDE.md files in subdirectories
- Keep all session logs isolated inside `/mem` directory
- `/mem` lives at project root (same level as .git, src/, etc.)
- All memory files are plain Markdown — queryable via grep, searchable locally
- No external APIs, no cloud storage, no dependencies

### Per-Session Capture
At the end of every task, capture these sections in `/mem/YYYYMMDD-{task-slug}.md`:

1. **The Ask** - What was requested, verbatim or paraphrased
2. **Changes Made** - Files modified, functions added, configs changed
3. **Decisions & Rationale** - Why implemented this way, trade-offs considered
4. **Current Architecture** - Updated system state, new modules, dependency changes

Format:
```markdown
# {Task Name} - {Date}

## The Ask
[What was requested]

## Changes Made
[Files modified, functions added, configs changed]

## Decisions & Rationale
[Why implemented this way, trade-offs, alternatives]

## Current Architecture
[Updated system state, module graph, dependencies]
```

### Memory Search (Local Only)
Search using PowerShell grep (no external calls):
```powershell
grep -r "oauth" ./mem --include="*.md"
```

This returns file paths instantly. No API. No tokens.

### Naming Convention
- Filename: `YYYYMMDD-{task-slug}.md`
- Examples: `20250601-pdf-merger.md`, `20250601-auth-debug.md`
- One file per task per day
- If same task continues next day, create new file with next day's date
- Slug: lowercase, hyphens only, no underscores or spaces

### Optional Metadata (YAML Frontmatter)
```yaml
---
date: 2025-06-01
task_slug: pdf-merger
status: completed
tags: [parsing, file-handling]
---
```

### Hook Integration (Local Only)
- **SessionStart**: Optional — just a reminder to log
- **PostToolUse**: Creates daily session markdown file
- Both hooks are local filesystem writes only
- No external calls, no authentication needed

### Architecture Decisions (Master Log)
Create `/mem/DECISIONS.md` for major architecture choices:
```markdown
### OAuth2 over session-based auth
- **Date:** 2025-06-01
- **Rationale:** Async scales better
- **Status:** ✅ Implemented
- **Trade-off:** More complex setup
```

Search it:
```powershell
grep -r "OAuth2" ./mem
```

### Session Log (Daily)
Create `/mem/YYYYMMDD-session.md` for daily journal:
```markdown
# Session Log - 2025-06-01

### 09:00 - OAuth Setup
- Task: Implement OAuth2 flow
- Status: In progress
- Next: Add token refresh

### 14:30 - PDF Merger
- Task: Fix form field handling
- Status: Completed
- Issues: Found CORS bug in config
```

### Key Principle: Searchable Markdown
- All memory is plain `.md` files
- Search via PowerShell `grep -r`
- No database, no external tools needed
- Files live in git alongside code
- Grep is always available

---

## Filesystem-Only Workflow

1. **Work on task** → modify code
2. **At task end** → create `/mem/YYYYMMDD-{slug}.md`
3. **Fill template** → Ask, Changes, Decisions, Architecture
4. **Search memory** → `grep -r "topic" ./mem`
5. **Commit** → optional pre-commit hook (warns, doesn't block)

That's it. Everything is markdown. Everything is local. Everything is searchable.

---

## No External Dependencies

- ❌ No API keys needed
- ❌ No cloud storage
- ❌ No external services
- ❌ No LLM calls
- ✅ Just markdown files
- ✅ Just grep queries
- ✅ Just git commits

## Zero Cost

- No token usage
- No API billing
- No rate limits
- No authentication
- Completely free and private
