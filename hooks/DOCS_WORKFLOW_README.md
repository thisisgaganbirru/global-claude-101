# Documentation-first workflow (global)

Separate system from the `/mem/` session-log tooling documented in `README.md`
in this same folder — that one is about session logs, this one is about a
`docs/` folder for feature reference docs. Don't confuse the two.

## What this is

A global Claude Code hook, wired into `~/.claude/settings.json`, that applies
to every project you open — not just one repo. It enforces (and where
possible, mechanically creates) a `docs/` folder convention: quick
per-feature/component reference docs, written so a feature can be understood
without reading all its source. Explicitly **not** a replacement for
`README.md` / `ARCHITECTURE.md` / `DESIGN.md` / `PUBLISH.md`.

## Files involved

| File | What it is |
|---|---|
| `docs_workflow.py` | The hook script itself. All logic lives here. |
| `SetupDocsGitHook.ps1` | Optional, opt-in per-project installer for a git pre-commit backstop. **Not installed in any project as of writing** — you have to run it yourself against a repo for it to do anything. |
| `~/.claude/skills/docs-audit/SKILL.md` | A separate, on-demand skill (not a hook) — audits an *existing* `docs/` folder for coverage gaps against the current codebase. Only runs when explicitly invoked. |
| `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md` | Global instruction files for Codex and Gemini CLI, populated with the same policy in prose form. Advisory only — those tools have no hook system, nothing mechanically enforces it. |

## How `docs_workflow.py` is wired (in `~/.claude/settings.json`)

| Hook event | Matcher | Mode arg | Fires |
|---|---|---|---|
| `UserPromptSubmit` | (all) | `prompt` | every message |
| `PreToolUse` | `Edit\|Write` | `pretool` | before any file edit |
| `PostToolUse` | `Edit\|Write` | `posttool` | after any file edit |
| `PostToolUse` | `Bash` | `test` | after any shell command |
| `Stop` | (all) | `stop` | when Claude finishes a turn |

A sixth mode, `precommit`, is **not** wired into Claude Code's hooks at all —
it's invoked directly by a real git pre-commit hook (see
`SetupDocsGitHook.ps1`), independent of Claude Code entirely.

## What each mode does

- **`prompt`** — injects a standing reminder every turn (what `docs/` is
  for, and that it's scoped to whatever's being touched this session, never
  a retroactive sweep of the whole codebase). Once per session, in an actual
  git repo, it also:
  - Checks the `docs/` folder convention (see below) and can auto-create an
    empty `docs/` + seed `docs/README.md` if none exists.
  - Checks for other AI tools' own instruction files at the project root or
    in known rule directories (`AGENTS.md`, `GEMINI.md`, `.cursorrules`,
    `.windsurfrules`, `.clinerules` as file or folder,
    `.github/copilot-instructions.md`, `.cursor/rules/`, `.windsurf/rules/`)
    and appends the same policy into them if it's evidence-based (i.e. the
    file/folder already existed) — never invents these files from nothing,
    only patches what's already there. Marker-guarded
    (`<!-- docs-first-hook:v1 -->`) so it never duplicates, and only ever
    appends/adds a new file — never overwrites existing content.
- **`pretool`** — once per session, nudges before the first real source edit
  to check `docs/` first.
- **`posttool`** / **`test`** — silently record (session-scoped marker files
  under the OS temp dir) that source changed / tests ran.
- **`stop`** — if source changed (or tests ran) this session with no
  corresponding `docs/` change in the working tree, blocks the turn from
  ending once, with instructions to document what was actually built (not
  the whole codebase). A second consecutive trigger for the same unresolved
  state is let through, so a deliberate "no doc needed" call doesn't loop
  forever.
- **`precommit`** — same idea as `stop`, but tool-agnostic: checks the
  actual staged git diff, regardless of which tool (or human) made the
  change. Warn-only, never blocks the commit. Only active in a project if
  `SetupDocsGitHook.ps1` has been run there.

## The `docs/` folder convention check (inside `prompt` mode)

Runs once per session, only inside an actual git repo (never touches
non-project directories):

1. **`docs/` already exists** → nothing happens.
2. **No `docs/`, nothing that looks like one** → creates an empty `docs/`
   with a seeded `docs/README.md` explaining its purpose. If the codebase
   already looks established (real commit history / file count — see
   `is_established_codebase`), also instructs Claude to ask the user
   whether a background Agent should backfill docs for the *existing* code,
   isolated in its own git worktree if so. Never proactively backfills
   without asking.
3. **No `docs/`, but one alternate-named folder exists**
   (`documentation/`, `doc/`, `wiki/`, `handbook/`, `guides/`, `manual/`) →
   instructs Claude to check its actual content before renaming (it might
   not be the same kind of thing), then rename + fix repo-wide references
   if it matches.
4. **No `docs/`, multiple alternate candidates** → instructs Claude to ask
   the user which one is canonical rather than guessing.

## Opting out

A `.nodocshook` file at a project's root disables the entire hook for that
project — no reminders, no folder creation, no blocking.

## Known limitations (deliberately not solved here)

- **Codex/Gemini/Cursor enforcement is advisory only.** Nothing forces those
  tools to actually follow `AGENTS.md`/`GEMINI.md`/rule files the way
  Claude Code's `stop` hook can block a turn. The project-level file-syncing
  narrows this gap (the policy is physically present where each tool looks)
  but can't force compliance.
- **Doesn't detect drift in an already-existing `docs/`.** If `docs/`
  already exists and a feature gets built later without anyone adding its
  doc, none of this catches it — that's what the separate `docs-audit`
  skill is for, and it only runs when explicitly asked.
- **The git pre-commit backstop is opt-in per project**, not automatically
  installed anywhere. Run `SetupDocsGitHook.ps1 -ProjectRoot <path>` against
  a repo to turn it on there.
