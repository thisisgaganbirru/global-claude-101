# git-commit agent

## What it does
User-global custom subagent (`~/.claude/agents/git-commit.md`, `name: git-commit`) that performs git mechanics only: organizes a working tree into logical commits, raises PRs, monitors CI, and merges across a `feature → dev → main` flow. Dispatched by an orchestrator via `Agent(subagent_type: "git-commit", ...)` with an explicit **target**. It never edits source, never fixes CI, never resolves conflicts — findings go back to the orchestrator.

## Files touched
- `agents/git-commit.md` — the agent definition (frontmatter + system prompt body).
- `hooks/merge_guard.py` — `PreToolUse` gate on `gh pr merge`; the enforcement behind "merge only when clean and mergeable".
- `settings.json` — registers the guard under `hooks.PreToolUse` (matcher `Bash|PowerShell`, `if: "Bash(gh pr merge*)"`) and allows `Bash(gh pr merge:*)`.
- `skills/code-review-workflow/SKILL.md` — the rulebook, preloaded into the agent via frontmatter `skills:`. Single source of truth for commit/PR/merge/semver discipline; the agent body holds only agent-specific concerns.

## Behavior

Pinned to `model: opus`. Preloads `code-review-workflow` via frontmatter `skills:` (full SKILL.md content injected at startup, not just the description).

### The target gate — what replaces checkpoints

A dispatched subagent runs to completion and returns a report; it **cannot** pause mid-run to ask for approval. Rather than pretend the skill's two checkpoints work in an agent, the gate moves earlier: the orchestrator authorizes a scope by choosing a target at dispatch time, and the agent may not exceed it.

| Dispatch | Runs | Writes? |
|---|---|---|
| *(no target)* | nothing — reports `Target: none` | **no** |
| `commit` | preflight → branch → 2–6 commits → push | branch + commits |
| `dev` | + PR → `dev`, monitor CI, merge, pull `dev` | + PR, merge |
| `main` | verify source is `dev` and ahead of `main` → semver label → PR `dev`→`main`, monitor, merge, pull, confirm tag | + PR, merge, tag |

Two load-bearing properties:
- **The default is inert.** An absent, misspelled, or ambiguous target is not "assume `commit`" — it is do nothing, zero writes. Ambiguity can never cause a write.
- **Targets do not cascade backwards.** `main` does not silently perform the `dev` leg. If `dev` isn't ahead of `main`, it reports and stops.

### CI gating — three gates, not one

The core loop. At each gate: **green → proceed. Not green → stop and report.** The agent never opens a PR, merges, or reports done on a CI state it hasn't observed.

| Gate | Fires when | Passes only if | Blocks |
|---|---|---|---|
| **1** | pushing the working branch (`on: push:` matching that branch) | runs green, or none fired | opening the PR |
| **2** | the PR (`on: pull_request: branches:` matching its target) | checks green **and** mergeable | the merge |
| **3** | **the merge itself — merging is a push** (`on: push: branches: [<target>]`) | — report only | reporting done |

**Gate 2 is two conditions.** Checks green and mergeable are different questions — all checks green with `mergeStateStatus: BLOCKED` still can't merge, because a ruleset may require a review no amount of green CI satisfies. Read via `gh pr view --json mergeable,mergeStateStatus,reviewDecision`: `CLEAN` merges; `UNKNOWN` means still computing (poll, don't treat as an answer); `DIRTY`/`BLOCKED`/`BEHIND`/`UNSTABLE` all abort with the specific blocker named. Never force-merges or admin-overrides — that's the orchestrator's call.

**No workflows in the repo** is common and valid, not a failure: Gate 1 has nothing to fire so it goes straight to the PR, Gate 2 collapses to mergeability alone, Gate 3 has nothing to report. Two rules bind harder here — the report must say *"no CI configured — mergeability only"* so the orchestrator can distinguish *validated and passed* from *nothing validated it*, and the agent must **not** run tests or linters locally to manufacture a signal the repo doesn't produce. An invented green reads like validation that never happened.

Gate 3 is the one most easily skipped and often the one that matters. It can't prevent a bad merge — by then it's happened — but it's how the orchestrator learns immediately rather than later. **"Merged successfully" while post-merge CI is failing is a false report.** The report's gate lines may read `green` only for runs actually observed reaching a terminal successful state; "no runs fired" and "none apply" are honest answers.

Mechanics are repository-agnostic — `gh run list --commit <sha>`, `gh run watch --exit-status`, `gh pr checks --watch --fail-fast`, `gh run view --log-failed`. Runs take seconds to register after a push, so the agent polls through a grace period before concluding none exist. Every wait has a timeout; a non-terminal run is an abort, not an assumed pass.

### Preflight — the safety mechanism that replaces the checkpoints

With no checkpoints, everything that could go wrong must be caught before the first write. The agent runs the rulebook's fixed command list (`git status --porcelain`, `git branch -a`, `ls .github/workflows/`, `gh label list`, `gh api repos/:owner/:repo/rulesets`, …), reads every workflow's `on:` block, and sorts each into Gate 1 / 2 / 3 (or "never wait" for `schedule` and `workflow_dispatch`). It also determines whether `semver:*` labels exist — applying one where they don't fails, skipping one where a ruleset requires it blocks the merge — and whether any push-triggered workflow deploys, which is reported *before* merging and whose real outcome lands at Gate 3.

Nothing here is repo-specific. A repo with no workflows is normal: every gate is skipped and the report says so. A repo that can't be classified is an abort, not a guess.

### Boundary

Mechanic, not decision-maker. Vocabulary: check branches, organize commits, push, raise PR, monitor PR, merge PR. It does not fix code, fix CI, resolve conflicts, decide scope, split work across PRs, or retry a red pipeline. Everything else goes to the orchestrator on the `FOR ORCHESTRATOR` report line, and the agent stops. **A finding it reports is a success; a finding it quietly worked around is a failure, even if the result looked fine.**

Notable abort: when the semver bump isn't clearly determinable from the diff, the agent reports **both** candidate bumps with reasoning and stops. The skill previously said "if unsure, ask the user" — incoherent for an autonomous agent with nobody to ask mid-run.

### Commit message override
The agent explicitly does **not** append a `Co-Authored-By` trailer. The skill bars it; that's a deliberate user instruction overriding the harness default that would otherwise add one. Called out in both files because a default that reasserts itself silently is the kind of thing nobody notices for twenty commits.

### The merge guard — enforcement, not instruction

The agent is told to merge only when the PR is clean and mergeable. That instruction alone is not a control, and **a permission rule cannot supply one** — permission rules match the command string, not PR state, so `Bash(gh pr merge:*)` would allow the merge unconditionally.

`hooks/merge_guard.py` is the actual gate. It runs as `PreToolUse` on any `gh pr merge`, queries `gh pr view --json number,state,mergeStateStatus,mergeable,title`, and returns `permissionDecision: "deny"` unless the PR is `OPEN` **and** `CLEAN`. Properties:

- **Fails closed** — `gh` missing, subprocess error, non-zero exit, or unparseable JSON all deny. An unverifiable state is never treated as mergeable.
- **`--admin` is refused outright** — it exists to bypass precisely what the gate enforces.
- **Only ever subtracts** — on a clean PR it prints a confirmation and exits 0, letting the normal permission flow decide. It never grants permission.
- **Denial reasons are specific** — `DIRTY` → conflict, `BLOCKED` → missing required review/check, `BEHIND` → stale branch, `UNSTABLE` → failing check, `UNKNOWN` → mergeability still computing.

The agent is instructed that a denial is the system working: report it verbatim and stop, never retry or re-route through another shell. Verified by pipe-test against four cases (non-merge passthrough, live CLEAN PR, `--admin`, nonexistent PR).

**Enforcement mechanism**: every dispatch must end with a required "git-commit report" block (fixed lines, including one per gate) filled in truthfully — including the no-op case. Same reasoning as the `frontend` agent's Pipeline report: a rule with nothing checking it is not a rule, and with no human watching mid-run, a required structured report is the only thing forcing honest self-accounting. "Skipped" is not an allowed value on any line.

## Known issues / status
- **Smoke-tested once** (2026-08-15, `target: dev`, two dispatches). Completed end to end: 7 commits, PR #1 merged as `e0ebd7c`, local `dev` synced, branch kept, no squash/force-push/`--admin`. Scope adherence, commit hygiene, and the `UNKNOWN`-mergeability polling path all verified independently afterwards.
- **A red gate has never run.** The only check ever observed is a GitHub App check that passed. No failing-CI abort, no `DIRTY`/`BLOCKED` PR, no merge-conflict path has been exercised — the abort logic is unproven where it matters most.
- **Gate 1 and Gate 3 against real workflow runs are still untested** — this repo has no workflows, so `gh run list` has only ever returned empty. Only the App-check path has been exercised.
- **Untested branches**: the `main` target has never been exercised, so the semver-label path, the tag-confirmation step, and the deploy warning are unproven in practice.
- **First dispatch (2026-08-15, target `dev`) surfaced a real detection bug.** This repo has no `.github/` directory at all, so workflow-file inspection classified it as "no CI configured" — but the PR received a live `GitGuardian Security Checks` run from a GitHub App. App checks are invisible to workflow-file inspection, so the agent was one step from reporting *"no CI configured — mergeability only"* on a PR that did have a blocking-capable check: exactly the false report the design exists to prevent. Fixed by making check discovery empirical (`gh pr checks`, `gh api .../check-runs`) with workflow reading demoted to a prediction that observation overrides. Gate 2's checks half was therefore genuinely exercised on the first run; Gate 1 and Gate 3 still reported no runs and remain unproven.
- **Gate 3 stopping point is unbounded.** In a repo whose post-merge chain fans out (tests → tag → build → deploy), the agent waits for the runs the merge commit started. Chained runs triggered by a *later* event (e.g. a tag push that the merge indirectly caused) are outside the commit-scoped query and won't be waited on. Whether that's the right boundary hasn't been tested against a real multi-stage release chain.
- **The guard's registration is not committed yet.** `hooks/merge_guard.py` is in the repo but its `settings.json` wiring is not: that file's pending diff also registers `SubagentStart`/`SubagentStop` hooks pointing at `hooks/agent_watch.py`, an unrelated and still-uncommitted concern. Committing it would put hook registrations for a file the repo doesn't have. The guard is therefore **live locally but absent for a fresh clone** until the `agent_watch` change set lands. Harmless in the meantime — an unregistered script does nothing — but it means the enforcement is machine-local, not repo-wide.
- **Orchestrator contract is convention, not enforcement.** Nothing prevents an orchestrator from dispatching without a target and ignoring the resulting no-op report, or from treating `FOR ORCHESTRATOR` as noise. The inert default limits the damage but does not make misuse impossible.
- Derived from a review of the pre-fix skill, which had eight defects — no YAML frontmatter (so `skills:` could not resolve it, and its registry description was just its H1), hardcoded `resume-agent` infrastructure behind a false "works in any project" claim, a wrong static CI check list, no mention that merging `main` deploys production, four documented-but-unimplemented flags, and a contradiction between the Adjust checkpoint option and the "cannot modify pushed commits" limitation.

## Changelog
- 2026-08-15 · Run completed — PR #1 merged to `dev` (`e0ebd7c`). The empirical-discovery fix was validated on its first live run: `gh run list` returned empty and there is no `.github/`, but the check-runs API found a real GitGuardian check. Prediction and observation disagreed; observation won. `merge_guard` denial path confirmed separately against the merged PR. Added a `Pull:` line to the report template — the pull was being performed but had no line accounting for it.
- 2026-08-15 · First dispatch (target `dev`). Found the App-check detection bug (below) and two authoring errors. Added `hooks/merge_guard.py` as real enforcement for "clean and mergeable", made check discovery empirical, fixed a section cross-reference off-by-one in the agent body.
- 2026-08-15 · initial version — agent created, `code-review-workflow` skill rewritten with frontmatter, Modes, target model, capability detection, and abort conditions.
- 2026-08-15 · Gate 2 split into two conditions — checks green **and** mergeable (`mergeStateStatus`), since green CI on a `BLOCKED` PR still can't merge. Added the no-workflows case: gates collapse to mergeability, report must say so, no locally-manufactured test signal.
- 2026-08-15 · CI monitoring widened from PR-checks-only to three gates (branch push, PR, post-merge). Post-merge was the real gap: the merge is itself a push, so it starts another round of workflows the agent previously never waited for. Repo-specific examples removed from the skill and doc — the agent is project-independent.
