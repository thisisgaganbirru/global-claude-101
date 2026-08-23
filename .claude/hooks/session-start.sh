#!/bin/bash
# SessionStart hook: installs this repo's custom skills/ and agents/ into
# ~/.claude/ for the current session, since remote sessions run in a fresh
# ephemeral container each time and don't inherit a previous session's
# ~/.claude/ changes.
#
# Only runs in Claude Code on the web (remote) sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

REPO_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"

# --- Skills that aren't already provided by the account-level sync ---
# (content-strategist, senior-tech-lead, system-design are synced separately
# under ~/.claude/skills/synced/ — skip them here to avoid duplicate names.)
for skill in claude-md docs-audit git-commit-workflow readme-writer scrum-master ui-ux-pro-max; do
  if [ -d "$REPO_DIR/skills/$skill" ]; then
    rm -rf "$CLAUDE_DIR/skills/$skill"
    cp -r "$REPO_DIR/skills/$skill" "$CLAUDE_DIR/skills/$skill"
  fi
done

# --- Agents ---
for agent in frontend.md git-commit.md scrum-master.md senior-tech-lead.md system-design.md; do
  if [ -f "$REPO_DIR/agents/$agent" ]; then
    cp "$REPO_DIR/agents/$agent" "$CLAUDE_DIR/agents/$agent"
  fi
done

# --- Fix agent references to the skill file they read ---
# The original agent defs hardcode the source machine's Windows path
# (C:\Users\birru\.claude\skills\<name>.md). Repoint each at wherever the
# matching skill actually landed on this Linux container: the account-level
# sync location if present, otherwise the copy installed above.
patch_agent_path() {
  local agent_file="$1" skill_name="$2"
  local target="$CLAUDE_DIR/skills/$skill_name/SKILL.md"
  if [ -f "$CLAUDE_DIR/skills/synced/$skill_name/SKILL.md" ]; then
    target="$CLAUDE_DIR/skills/synced/$skill_name/SKILL.md"
  elif [ ! -f "$target" ] && [ -d "$REPO_DIR/skills/$skill_name" ]; then
    rm -rf "$CLAUDE_DIR/skills/$skill_name"
    cp -r "$REPO_DIR/skills/$skill_name" "$CLAUDE_DIR/skills/$skill_name"
  fi
  if [ -f "$CLAUDE_DIR/agents/$agent_file" ]; then
    sed -i "s#C:\\\\Users\\\\birru\\\\.claude\\\\skills\\\\${skill_name}\\.md#${target}#" "$CLAUDE_DIR/agents/$agent_file"
  fi
}

patch_agent_path scrum-master.md scrum-master
patch_agent_path senior-tech-lead.md senior-tech-lead
patch_agent_path system-design.md system-design

echo "Installed skills and agents from $REPO_DIR into $CLAUDE_DIR" >&2
