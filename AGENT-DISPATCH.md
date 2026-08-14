# Agent Dispatch — Universal Routing Logic

> Reconstructed from `README.md`'s description after the original file was
> accidentally deleted. This is a best-effort rebuild of the structure and
> intent README.md pointed at — not a byte-for-byte recovery of the original
> wording or examples. Edit freely to correct anything that doesn't match
> what you actually had.

This file defines how I (Claude Code) decide whether to implement a task
directly, hand it to a subagent, or route it to the Codex subprocess. It
applies across all your projects — reference it from a project's CLAUDE.md
rather than duplicating routing logic per-project.

---

## How to Ask for Agents

Copy-paste templates:

```
"Use agents to [task description]"
"Use Plan agent to design [feature]"
"Use agents in parallel to: 1) 2) 3)"
"Use Explore agent to investigate [problem]"
```

If you don't specify, I score the task's complexity and route it myself
(see below), then tell you how I scored it.

---

## Universal Complexity Scoring

Score every task 1-25 across five dimensions before deciding how to route it:

| Dimension | 1 (low) | 5 (high) |
|---|---|---|
| Files touched | 1 file | 6+ files, multiple modules |
| Cross-module impact | Isolated | Touches shared/core logic |
| Sequencing | Single step | Multi-step, order-dependent |
| Ambiguity | Fully specified | Requires design decisions |
| Risk | Reversible, low blast radius | Hard to reverse / shared state |

Sum the five dimension scores (1-5 each) for a total of 5-25.

---

## Universal Decision Tree

```
Score 5-10   → Direct implementation (no agent needed)
Score 11-15  → Subagent (Plan, Explore, or code-reviewer as fits)
Score 16+    → Codex subprocess (if available) OR subagent-driven-development
```

- **5-10, direct:** small, well-scoped, low-risk changes — just do it.
- **11-15, subagent:** enough ambiguity or cross-file surface that a
  dedicated Plan or Explore pass first pays for itself.
- **16+, heavy:** either dispatch to the Codex subprocess (separate token
  budget, see `settings.json` → `codex_subprocess`) or use
  subagent-driven-development for parallel, independently-verifiable work.

---

## Available Agent Types

Summary (see the live listing surfaced in-session for the authoritative,
up-to-date set — this list drifts as plugins are added/removed):

- **Explore** — fast, read-only search/investigation
- **Plan** — architecture and implementation planning, no edits
- **system-design** — distributed-systems / architecture-heavy design work
- **code-reviewer** — bug/quality review of a diff or PR
- **brainstorming** — requirements and design exploration before building
- **test-driven-development** — write-test-first implementation flow
- **subagent-driven-development** — parallel independent-task execution
- **Codex subprocess** — heavy tasks (16+ complexity), separate quota,
  gated by `forbidden_operations` / `require_manual_approval` in
  `settings.json`

---

## Task Patterns (examples)

**Simple feature:**
```
You: "Use agents to add email notifications for new H1B jobs"
Me:  "Complexity score: 12/25 (3-4 files, cross-module, sequential)
      → Routing to subagent (Plan agent first, then implement)"
```

**Refactoring:**
```
You: "Use agents to refactor the crawler fetch cascade for better error handling"
Me:  "Complexity score: 17/25 (crawler.py, monitor.py, tests, multi-layer impact)
      → Routing to subagent-driven-development (heavy task, parallel optimization)"
```

**Investigation:**
```
You: "Use Explore agent to map the database schema evolution"
Me:  "Using Explore agent to understand schema changes and relationships"
```

---

## FAQ

**"I said 'use agents' but they weren't used."**
Complexity likely scored ≤10 — simple enough for direct implementation.
I'll show my scoring; tell me if I got it wrong.

**"I wanted parallel work but it ran sequentially."**
Say explicitly: `"Use agents in parallel to: 1) 2) 3)"`, or I'll ask first.

**"My project isn't covered by the task patterns above."**
The patterns are examples, not an exhaustive list — describe the task and
I'll score and route it the same way.

**"Codex subprocess isn't working."**
Check `codex --version` runs, and that `codex_subprocess.enabled: true` is
set in `settings.json` (it currently is).

---

## Using This in Your Projects

Reference this file from each project's own CLAUDE.md instead of
duplicating routing logic:

```markdown
## Agent & Subprocess Routing

See `~/.claude/AGENT-DISPATCH.md` for universal routing logic.

### Project-Specific Notes

- Heavy tasks for this project: [list examples]
- Direct implementation tasks: [list examples]
- Preferred patterns: [list agent types you prefer]
```

---

## Version

| Date | Change |
|------|--------|
| 2026-08-14 | Reconstructed after accidental deletion — see note at top |
