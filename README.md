# global-claude-101

Personal global config for [Claude Code](https://claude.com/claude-code) — `CLAUDE.md`, custom
skills-lock, hooks, and agent-routing rules, version-controlled so they survive machine
changes and can't silently disappear.

## Why this repo exists

Global Claude Code config living only on local disk (`~/.claude/`) is a single point of
failure: it doesn't survive a machine switch, a reinstall, or a stray `rm`. This repo is
the fix — the source of truth is git, not a laptop.

Case in point: `AGENT-DISPATCH.md` (the agent-routing/complexity-scoring guide below) was
accidentally deleted mid-session with no backup anywhere on disk, and had to be
reconstructed from a README that only described it secondhand. That shouldn't be possible
again — every file here now has history, every change is a reviewable diff, and nothing
gets permanently lost to one bad command.

## What's in here

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Root global instructions loaded into every Claude Code session |
| `AGENT-DISPATCH.md` | Task-routing / complexity-scoring guide for when to go direct vs. subagent vs. Codex subprocess |
| `rules/memory.md` | Session-memory convention (`/mem/YYYYMMDD-{task-slug}.md` logs) |
| `hooks/` | Docs-workflow and memory-workflow automation scripts, wired via `hooks.json` |
| `hooks.json` | Hook wiring — which scripts run on which Claude Code lifecycle events |
| `settings.json` | Global settings: enabled plugins, marketplaces, Codex subprocess config, routing thresholds |
| `keybindings.json` | Custom keyboard shortcuts |
| `skills-lock.json` | Lockfile for externally-sourced skills |
| `statusline-command.sh` / `statusline-debug.sh` | Status line scripts |

## What's deliberately excluded

`.credentials.json`, session history (`history.jsonl`, `sessions/`, `projects/`), caches
(`paste-cache/`, `image-cache/`, `cache/`, `plugins/cache/`), `mem/` (per-task session logs
— useful locally, not meant to travel), and any machine-specific or secret state. This repo
is portable config, not a full backup of runtime state.

`skills/` is also excluded — it's largely third-party plugin content (e.g. `hallmark`,
`ui-ux-pro-max`) that reinstalls automatically from `settings.json`'s `enabledPlugins` list
on a new machine, so duplicating it here would just be dead weight.

## Setup on a new machine

1. Install Claude Code, let it create `~/.claude/`.
2. Clone this repo's tracked files into `~/.claude/` (or symlink individual files in).
3. Plugins listed in `settings.json` → `enabledPlugins` reinstall on next launch.
