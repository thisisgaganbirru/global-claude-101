# read-only skill

## What it does
User-global skill (`~/.claude/skills/read-only/SKILL.md`, `name: read-only`) that locks a single turn into analysis-only mode. Claude investigates, explains, and proposes concrete fixes — but writes nothing to the repo. Invoked explicitly as `/read-only`, or auto-triggered by analysis-shaped phrasing ("just analyze", "what do you think", "explain how X works", "don't change anything").

Exists to prevent one specific failure: mid-session, in auto-approve/accept-edits mode, the user asks a question, Claude finds the problem during analysis, and applies the fix nobody asked for. The permission prompt that would normally catch that is gone in auto-approve, so the edit lands silently.

## Files touched
- `skills/read-only/SKILL.md` (NEW) — the skill definition. Self-contained; no scripts, references, or assets.

No changes to `settings.json`, no hooks, no agent definitions. Skills in `~/.claude/skills/` are auto-discovered — the skill registered live in the creating session without a restart.

## Behavior

### The contract
Deliverable for the turn is information, not a modified repository. Working tree must be identical before and after.

| Allowed | Blocked |
|---|---|
| `Read`, `Grep`, `Glob`, `WebFetch`, `WebSearch` | `Write`, `Edit`, `NotebookEdit` |
| Observing Bash: `git status/log/diff/show/blame`, `ls`, `wc`, `rg` | Mutating Bash: `rm`, `mv`, `cp`, `mkdir`, `>`, `>>`, `sed -i` |
| Linters/tests in **report mode** | `git add/commit/push/checkout/restore/stash/reset`, `--fix`, `--write` |
| Read-only subagents | Package installs, codegen, formatters that write |
| Scratchpad files (own notes) | Artifact publish, comment posting, message sending |
| | `gh pr create/merge` |

Unknown command → assume it mutates, skip it, report what would have been run.

### The redirect, not a prohibition
The load-bearing design choice: the skill does not tell the model to suppress the urge to fix. It gives that urge a destination — a **"Proposed fix (not applied)"** section carrying a concrete diff with `file:line`. Framed as "that instinct is correct, it's just early." A named destination for the impulse holds better than a bare "don't", and the user still gets the fix — plus the choice.

Paired guard: an explicit "read-only is not low-effort" section, so restricting writes doesn't quietly license shallow analysis.

### Report shape
Opens with `🔒 **Read-only** — analysis only, nothing modified.` so the lock is visible. Then answers the question directly. For substantial findings: what's happening (with `file.ts:line`) → why (mechanism, not symptom) → proposed changes (not applied) → what couldn't be verified. Closes by naming the exit.

### Scope
Binds the current turn only. Released by the next message — "go ahead", "apply that", or any fresh change request. Explicitly instructed not to bleed into a turn where the user clearly asked to build something, and not to require re-invocation to keep asking questions.

### Edge cases covered
- **Urgent finding** — still no fix; lead with it, mark it, offer. Urgency justifies volume, not bypassing the user's decision.
- **Mixed request** ("look at the auth bug and fix it") — explicit invocation → analysis wins, say the fix is one word away. Auto-triggered + user clearly wanted the change → ask instead of stalling on a technicality.
- **Can't answer without writing** (migration, build emitting artifacts) — stop, explain what needs to run, let the user unlock.
- **docs/ + mem/ hooks** — nothing changed, so those write steps don't apply; note it in one line rather than skipping silently.

## Known limitations
- **Soft enforcement.** A skill is instruction, not a gate. `Write`/`Edit` remain in the toolset; the model is asked not to reach for them. Compliance is high but not guaranteed.
- Hard alternatives, if the soft layer ever proves insufficient:
  - `PreToolUse` hook denying `Write|Edit|NotebookEdit` when a sentinel is set — the only option that is both conditional and absolute. Same mechanism as `hooks/merge_guard.py`.
  - `permissions.deny` in `settings.json` — absolute but session-wide, not per-turn.
  - A read-only subagent (`tools:` whitelist genuinely restricts) — but it starts on a fresh context, which defeats "what's your opinion on the thing we've been discussing."
- No evals were run against this skill. Skill-creator's benchmark loop needs subagents, which were out of scope for the session that created it.

## Related
- `mem/20260823-read-only-skill.md` — build session, decisions, rejected alternatives.
- `docs/git-commit-agent.md` — the `merge_guard.py` pattern referenced above as the hard-enforcement template.
