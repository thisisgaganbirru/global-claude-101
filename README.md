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

`skills/` is tracked (these are curated/authored skills), **except** two external ones
that aren't ours to version-control — see "External skills" below.

### External skills (not in this repo — reinstall after cloning)

| Skill | Source | How to get it |
|---|---|---|
| `hallmark` | Plugin: `hallmark@claude-code-skills` (`skills-lock.json` pins it to `nutlope/hallmark`) | Reinstalls automatically — it's listed in `settings.json` → `enabledPlugins`, and the marketplace is registered under `extraKnownMarketplaces`. Nothing manual needed once this repo's `settings.json` is in place. |
| `llm-council` | Standalone repo: `tenfoldmarc/llm-council-skill` | Not a registered plugin — clone it directly into place: `git clone https://github.com/tenfoldmarc/llm-council-skill.git skills/llm-council` |

Everything else under `skills/` (e.g. `claude-md`, `code-review-workflow`, `docs-audit`,
`readme-writer`, `use-railway`, `ui-ux-pro-max`, `system-design`, `scrum-master`,
`senior-tech-lead`, `content-strategist`) is tracked in full.

## Setup on a new machine

1. Install Claude Code, let it create `~/.claude/`.
2. Clone this repo's tracked files into `~/.claude/` (or symlink individual files in).
3. Plugins listed in `settings.json` → `enabledPlugins` reinstall on next launch.
4. Clone `llm-council` manually (see "External skills" above — it's not a plugin, so it
   won't reinstall itself): `git clone https://github.com/tenfoldmarc/llm-council-skill.git skills/llm-council`
