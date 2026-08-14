# Session-memory-first workflow (global)

Separate system from the docs-first tooling documented in
`DOCS_WORKFLOW_README.md` in this same folder — that one is about a `docs/`
folder for feature reference docs, this one is about a `mem/` folder for
per-task session logs. Don't confuse the two, and see this folder's own
`README.md` for the underlying `/mem/` conventions themselves (naming,
frontmatter, search) — this file documents the *enforcement* layer only.

## What this is

A global Claude Code hook, wired into `~/.claude/settings.json`, that applies
to every project you open. It enforces (and where possible, mechanically
creates) a `mem/` folder convention: one `mem/YYYYMMDD-{task-slug}.md` file
per task, capturing The Ask, Changes Made, Decisions & Rationale, and
Current Architecture — so a future session (yours or another AI tool's) can
recover why something was built a certain way without re-deriving it from
source or git blame.

## Files involved

| File | What it is |
|---|---|
| `mem_workflow.py` | The hook script itself. All logic lives here. Independent of `docs_workflow.py` — no shared imports, own state directory (`claude-mem-hook`), own marker (`<!-- mem-first-hook:v1 -->`). |
| `SetupMemGitHook.ps1` | Optional, opt-in per-project installer for a git pre-commit backstop. Safe to run alongside `SetupDocsGitHook.ps1` — both append to the same `pre-commit` file. |
| `SetupGitHook.ps1` | The **original** `/mem/` installer (pre-dates this hook system). Its `pre-commit.bat` never actually runs — confirmed by direct test that Git for Windows only executes a hook literally named `pre-commit` (no extension), not `pre-commit.bat`. Left in place (still adds `/mem/` to `.gitignore`, still documented in `README.md`) but its enforcement check has likely never fired on any project. Use `SetupMemGitHook.ps1` instead for a working backstop. |
| `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md` | Global instruction files for Codex and Gemini CLI — the mem-first policy is appended below the existing docs-first policy in both. Advisory only. |

## How `mem_workflow.py` is wired (in `~/.claude/settings.json`)

| Hook event | Matcher | Mode arg | Fires |
|---|---|---|---|
| `UserPromptSubmit` | (all) | `prompt` | every message |
| `PreToolUse` | `Read\|Grep` | `pretool` | before the first read/search each session |
| `PostToolUse` | `Edit\|Write` | `posttool` | after any file edit |
| `PostToolUse` | `Bash` | `test` | after any shell command |
| `Stop` | (all) | `stop` | when Claude finishes a turn |

Runs alongside the equivalent `docs_workflow.py` entries in the same hook
arrays — both fire independently on the same events.

A sixth mode, `precommit`, is **not** wired into Claude Code's hooks — it's
invoked directly by a real git pre-commit hook (see `SetupMemGitHook.ps1`).

## What each mode does

- **`prompt`** — injects a standing reminder every turn (search `mem/` first
  before reconstructing context; log a session entry before finishing if
  source changed). Once per session, in an actual git repo, it also:
  - Checks the `mem/` folder convention and auto-creates an empty `mem/` +
    seeded `mem/README.md` if none exists.
  - Syncs the same policy into any other AI tool's own instruction file
    already present in the project (same file/dir list as the docs hook —
    `AGENTS.md`, `GEMINI.md`, `.cursorrules`, `.clinerules`, etc.), marker-
    guarded so it never duplicates.
- **`pretool`** — once per session, on the first `Read` or `Grep` call (not
  gated on file path — the point is "search mem/ before reading anything to
  reconstruct context," not which file), nudges to grep `mem/` first if the
  project has one. Silent if the project has no `mem/` yet.
- **`posttool`** / **`test`** — silently record (session-scoped marker files
  under the OS temp dir) that source changed / tests ran.
- **`stop`** — if source changed (or tests ran) this session with no real
  `mem/` change in the working tree, blocks the turn from ending once, with
  instructions to log what was actually done. A second consecutive trigger
  is let through, so a deliberate "no entry needed" call doesn't loop.
- **`precommit`** — tool-agnostic: checks the actual staged git diff,
  regardless of which tool (or human) made the change. Warn-only, never
  blocks. Only active if `SetupMemGitHook.ps1` has been run in that project.

## Deliberate differences from the docs-first hook

**No backfill offer for `mem/`.** `docs_workflow.py`, when it creates
`docs/` from nothing in an established codebase, offers to dispatch a
background Agent to backfill docs for existing features (in a git worktree,
only if the user agrees). This hook does **not** have an equivalent offer
for `mem/`. Docs can be backfilled honestly — you can read existing code and
describe what it does today. Session logs can't: they're a record of a
decision-making process nobody captured at the time, and reconstructing
"why" after the fact from source alone would be fabrication, not memory. So
a missing `mem/` just gets created empty, and logging starts from whatever
task is current.

**`mem/` is local-only and gitignored.** Unlike `docs/` (which is tracked in
git), `mem/` folder is intentionally `.gitignore`d — it's a per-machine,
per-session working memory, not a shared artifact. The Stop hook checks for
local session-log file creation (untracked mem files in the working tree),
not staged git changes. You don't push mem/ — it's yours for the current
session, so a future session can reconstruct context with `grep -ril` before
reading source.

## Opting out

A `.nomemhook` file at a project's root disables the entire hook for that
project — no reminders, no folder creation, no blocking. Independent of
`.nodocshook` (each hook has its own opt-out).

## Known limitations (deliberately not solved here)

- **Codex/Gemini/Cursor enforcement is advisory only** — same caveat as the
  docs hook.
- **No drift detection.** If `mem/` exists but a task gets done later
  without a corresponding entry, this only catches it within the *same*
  session it happened in (via the `stop` block) — it has no memory across
  sessions of what *should* have been logged.
- **The git pre-commit backstop is opt-in per project.** Run
  `SetupMemGitHook.ps1 -ProjectRoot <path>` against a repo to turn it on.
