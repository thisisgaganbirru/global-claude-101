---
name: code-review-workflow
description: >
  Branch, commit, PR, and merge discipline for git repositories using a
  feature → dev → main promotion flow. Use whenever work needs to be turned
  into commits and shipped: organizing a dirty working tree into logical
  commits, creating a feature branch, raising a pull request, monitoring CI
  on a PR, merging to dev, promoting dev to main, or applying release
  (semver) labels. Also use when the user says "commit this", "raise a PR",
  "merge to dev", "promote to main", "ship this", "cut a release", or asks
  why a PR is blocked from merging. Covers both interactive use (a human
  approving at checkpoints) and autonomous use (the `git-commit` agent, gated
  by an explicit target instead of checkpoints). Does NOT review code for
  correctness — that is `/code-review`.
---

# Code Review & Merge Workflow

Discipline for turning a working tree into commits, a PR, and a merge, across
a `feature → dev → main` promotion flow.

This file is the **rulebook**. It is consumed two ways:

- **Interactive mode** — a human invokes `/code-review-workflow` and approves
  at checkpoints.
- **Autonomous mode** — the `git-commit` agent preloads this file via its
  `skills:` frontmatter and executes it without checkpoints.

Read [Modes](#modes) before anything else. Several rules below differ by mode,
and applying the wrong one is the main way this workflow goes wrong.

## Modes

| | Interactive | Autonomous |
|---|---|---|
| Invoked by | a human typing `/code-review-workflow` | an orchestrator dispatching `git-commit` |
| Scope authorized by | checkpoints, mid-run | the **target** argument, at dispatch time |
| On ambiguity | ask the user | stop and report to the orchestrator |
| Can fix code / CI failures | yes, if the user asks | **never** — report only |

**Why autonomous mode has no checkpoints.** A dispatched subagent runs to
completion and returns a report; it cannot pause and ask for approval
mid-run. Rather than pretend otherwise, the gate moves earlier: the
orchestrator authorizes a scope by choosing a target, and the agent may not
exceed it. A dispatch with no target does nothing at all.

**Precedence.** In autonomous mode, the target model below replaces the
Checkpoints section entirely. Where the two conflict, the target model wins,
and the agent must say so in its report rather than silently picking one.

## Targets (autonomous mode)

| Target | Runs | Stops after |
|---|---|---|
| *(none given)* | **nothing** — reports "no target specified", makes zero writes | immediately |
| `commit` | preflight → branch → 2–6 logical commits → push → **Gate 1** | branch CI reported |
| `dev` | the above, then PR → `dev` → **Gate 2** → merge → **Gate 3** → pull `dev` | post-merge CI reported |
| `main` | verify source is `dev` and ahead of `main` → semver label → PR `dev` → `main` → **Gate 2** → merge → **Gate 3** → pull, confirm tag | post-merge CI reported |

Two properties are load-bearing:

- **The default is inert.** An absent, misspelled, or ambiguous target is not
  "assume `commit`". It is do nothing. Ambiguity must never cause a write.
- **Targets do not cascade backwards.** `main` does not silently perform the
  `dev` leg if it was never done. It checks, finds `dev` is not ahead of
  `main`, reports, and stops.

## Phase 1 — Analyze & organize

1. Run preflight (see [Repository capability detection](#repository-capability-detection)).
2. Analyze `git status` and the diff; group related changes.
3. Create a feature branch with a descriptive name.
4. Organize into **2–6 logical commits**.
5. Push to remote.
6. **Gate 1** — if the push started any workflow, wait for it. Green →
   continue. Red → stop and report. See [CI monitoring](#ci-monitoring).

### Commit rules

- 2–6 commits per PR, each one coherent on its own. Examples:
  "Add feature X types and API", "Implement feature X logic",
  "Update UI for feature X", "Add tests for feature X".
- Short, clear, imperative subjects.
- **No `Co-Authored-By` trailer.** This is deliberate and overrides any
  harness default that appends one. If a tool or default behavior adds the
  trailer, remove it before committing.
- If the working tree contains several unrelated concerns, that is a scope
  problem, not a commit-organization problem. Interactive mode: ask whether
  to split into separate PRs. Autonomous mode: report the grouping you would
  use and stop — the orchestrator owns scope.

## Phase 2 — Checkpoint 1 (interactive mode only)

⛔ Review commits before a PR exists. The user may:
Proceed · Review (show diffs) · Adjust · Abort.

**Adjust, and the force-push rule.** Before the branch is pushed, amend and
reorder freely. **After** it is pushed, changes are new commits — never a
force-push, never a rewrite of pushed history. This workflow never squashes
and never deletes branches precisely so that history stays a reliable base
for cherry-picks; rewriting it after push defeats that. If a change genuinely
requires rewriting pushed history, stop and hand it to the user.

## Phase 3 — Dev merge

1. Create PR from feature branch → `dev` (only if Gate 1 was green).
2. **Gate 2** — monitor the checks that actually apply to this PR. Do not wait
   on a check that will never run for this target branch.
3. Merge only when they are all green.
4. **Gate 3** — the merge is a push to `dev`; wait for the workflows it
   started and report their outcome.
5. Pull to local `dev`.

## Phase 4 — Checkpoint 2 (interactive mode only)

⛔ Review everything on `dev` before promoting. Approve · Skip main · Review · Abort.

In autonomous mode this gate does not exist; promotion happens only because
the orchestrator dispatched `target: main`, which is the same authorization
expressed earlier.

## Phase 5 — Main merge

1. Verify `dev` is the source and is ahead of `main`.
2. Create PR from `dev` → `main`.
3. Apply exactly one `semver:*` label **if the repository uses them** — see
   [Release labeling](#release-labeling).
4. **Gate 2** — monitor applicable checks; merge only when green.
5. Merge, pull to local `main`.
6. **Gate 3** — the merge is a push to `main`. Wait for what it started
   (post-merge tests, tagging, image builds, deploys) and report each outcome.
7. Confirm any release tag was cut.

⚠️ **Merging to `main` can deploy production.** Preflight detects workflows
triggered by `push` to `main`. If any exist, say so explicitly **before**
merging, not after — and then report the actual result at Gate 3 rather than
assuming it succeeded. See
[Repository capability detection](#repository-capability-detection).

## Repository capability detection

This workflow makes **no assumptions** about what infrastructure a repository
has. Two repositories using it can look nothing alike. Detect, then adapt.

Run these before any write:

```
git status --porcelain            git branch -a
git branch --show-current         git remote -v
git log --oneline <base>..HEAD    gh auth status
ls .github/workflows/             gh label list
gh api repos/:owner/:repo/rulesets
```

Build a profile from the results:

| Field | How to determine it | What it changes |
|---|---|---|
| `dev` / `main` exist | `git branch -a` | whether a target is even runnable |
| checks applying to this PR | each workflow's `on: pull_request: branches:` | what to wait on at Gate 2 |
| workflows fired by a branch push | `on: push:` matching the working branch | what to wait on at Gate 1 |
| workflows fired by a merge | `on: push: branches: [<merge target>]` | what to wait on at Gate 3 |
| `semver:*` labels exist | `gh label list` | whether Phase 5 step 3 applies at all |
| required status checks | `gh api …/rulesets` | what will block the merge |
| merging deploys anything | push-triggered workflows that deploy or watch a deploy | what to warn about before merging |

A repository that cannot be classified is an abort condition, not a guess.

### Reading workflow triggers

Every repository wires CI differently. Never assume; read each workflow's
`on:` block and classify it:

| Trigger | Fires when | Consequence |
|---|---|---|
| `pull_request: branches: [X]` | a PR **targeting X** opens or updates | only applies if this PR targets X |
| `push: branches: [Y]` | any commit lands on Y — **including a merge** | fires *after* you merge into Y |
| `push: branches: ['**']` | every branch push | fires when the working branch is pushed, before any PR |
| `push: tags: [...]` | a tag is pushed | fires after a release tag is cut |
| `schedule` / `workflow_dispatch` | on a timer / manually | never wait on these |

Two consequences that are easy to get wrong:

- A workflow scoped to PRs into `main` will **never** run on a PR into `dev`.
  Waiting for it there hangs forever.
- Merging is a push. Anything under `push: branches: [<target>]` starts
  **after** the merge, not before it. A merge is not the end of CI.

A repository with no workflows at all is a valid, common outcome. Detect it,
say so, and skip every CI wait — do not treat absence as failure.

## CI monitoring

**The rule: never advance past CI you haven't seen the result of.** Green →
proceed to the next action. Not green → stop and report. This applies at
every point where CI can run, not just on the pull request.

There are **three** such points. Missing any of them means acting on an
unknown state.

### Gate 1 — after pushing the working branch, before raising the PR

Pushing the branch may itself start workflows (anything matching
`push: branches: ['**']` or the branch's name). If any run starts for the
pushed SHA, wait for it. Do not open the PR while branch CI is still running,
and do not open it at all if branch CI failed.

If nothing fires for that SHA, there is nothing to wait for — proceed.

### Gate 2 — on the pull request, before merging

Two conditions, both required. They are different things and passing one says
nothing about the other:

1. **Checks green** — the checks that actually apply to this PR's target
   branch, derived from workflow triggers.
2. **Mergeable** — GitHub itself considers the PR ready to merge.

```
gh pr view <n> --json mergeable,mergeStateStatus,reviewDecision
```

| `mergeStateStatus` | Meaning | Action |
|---|---|---|
| `CLEAN` | mergeable, nothing blocking | merge |
| `UNKNOWN` | GitHub still computing | poll — not yet an answer |
| `DIRTY` | merge conflict | abort, report |
| `BLOCKED` | required review or required check missing | abort, report **what** is blocking |
| `BEHIND` | branch is behind the target | abort, report |
| `UNSTABLE` | mergeable but checks failing | abort, report |

All checks green with `BLOCKED` still cannot merge — a ruleset may require a
review that no amount of green CI satisfies. Never force or admin-override a
blocked merge; that is the orchestrator's decision, not this workflow's.

### Gate 3 — after merging, before reporting done

**A merge is a push.** Merging into a branch starts every workflow under
`push: branches: [<that branch>]` — post-merge tests, image builds, release
tagging, deploys. These run *after* the merge and are frequently where a
problem actually surfaces.

Wait for the runs triggered by the merge commit, and report their outcome.
"Merged successfully" while post-merge CI is failing is a false report.

Gate 3 cannot prevent a bad merge — by then it has happened. Its purpose is
that the orchestrator learns the truth immediately, in the same report,
instead of discovering it later.

### When the repository has no workflows

Common and entirely valid. No CI exists to wait for, so:

- Gate 1 has nothing to fire — push and proceed straight to the PR.
- Gate 2 collapses to **mergeability alone** — the table above is the whole
  gate. `CLEAN` merges; anything else aborts.
- Gate 3 has nothing to report.

Two rules for this case:

- **Say it explicitly in the report.** "Merged — no CI configured in this
  repository, mergeability only." The orchestrator must be able to tell the
  difference between *validated and passed* and *nothing validated it*.
  Silence here reads as the former.
- **Do not compensate.** Never run tests, linters, or builds locally to
  manufacture a signal the repository does not produce. That is outside this
  workflow's boundary, and a locally-invented green reads in the report like
  validation that never happened.

### Mechanics

Repository-agnostic; these work anywhere `gh` is authenticated:

```
gh run list --commit <sha> --json databaseId,name,status,conclusion
gh run watch <run-id> --exit-status
gh pr checks <pr> --watch --fail-fast
gh pr view <pr> --json mergeable,mergeStateStatus,reviewDecision
gh run view <run-id> --log-failed
```

- Poll for runs to *appear* before concluding none exist — a run can take a
  few seconds to register after a push. Only after a short grace period is
  "no runs" a real answer.
- Every wait needs a timeout. A check that never reaches a terminal state
  within it is an abort condition — report it, do not merge.
- On failure, capture the failing workflow, the job name, and a log excerpt.
- Interactive mode may offer to fix. **Autonomous mode reports and stops — it
  never fixes code, never re-runs a red pipeline, never merges anyway.**

## Release labeling

Applies to `dev` → `main` PRs, in repositories that define `semver:*` labels.

Commits here are never squashed, so there is no single clean commit or PR
title to parse release intent from the way squash-merge workflows do — the
label *is* the signal, and the only place release intent lives. `dev` itself
carries no version semantics (nightly staging, not a release).

- `semver:major` — breaks an existing consumer (removed/renamed endpoint,
  incompatible response shape, auth behavior change)
- `semver:minor` — new backwards-compatible functionality (new endpoint, new
  optional field, new feature)
- `semver:patch` — bug fix or internal change, no interface change

Judge by the PR's actual diff into `main`, not by how many files it touched or
how long it took to build — size is not the criterion, compatibility is.

**When the bump is unclear:** interactive mode asks the user. Autonomous mode
has nobody to ask mid-run, so it reports both candidate bumps with reasoning
and stops. It never guesses.

Where a ruleset requires the label, applying it is not optional and not
something to retrofit after the merge is already blocked — apply it when the
PR is created.

## Invariants

These hold in every mode and every repository:

- Commits are **never squashed** — preserves history for precise cherry-picks.
- Branches are **never deleted** — safe for recovery.
- Merges are fresh commits — no fast-forward-only.
- Pushed history is **never rewritten** — no force-push, no amend after push.
- No `Co-Authored-By` trailer.

## Parameters

| Flag | Effect | Default |
|---|---|---|
| `--branch-name` | Custom branch name | auto-generated |

Interactive mode only. Autonomous mode takes a **target** (`commit`, `dev`,
`main`), not flags — the target is the authorization.

`--skip-main`, `--dev-only`, and `--force-merge` were removed. The first two
are expressed by choosing a target. `--force-merge` existed to skip
checkpoints; in autonomous mode there are none to skip, and in interactive
mode "skip the human gates" is what invoking the workflow without them
already means.

## Abort conditions

Stop and report. Do not work around any of these:

- No target given (autonomous mode) — do nothing at all
- Working tree contains files outside the stated scope
- `dev` or `main` missing when the target requires it
- No remote, or `gh` not authenticated
- CI red **at any of the three gates** — report failing workflow, job, and log
  excerpt; never re-run, never merge anyway
- A workflow that never reaches a terminal state within the timeout
- PR not mergeable — `DIRTY`, `BLOCKED`, `BEHIND`, or `UNSTABLE`. Report which,
  and what is blocking. Never force or admin-override.
- Merge conflict
- `main` requested but `dev` is not the source, or is not ahead of `main`
- An expected check never appears within the timeout
- The change would require a force-push
- `main` requested, repository requires a semver label, and the diff does not
  clearly indicate the bump

## Limitations

- Requires `git` and the `gh` CLI.
- Cannot resolve merge conflicts.
- Cannot override ruleset or required-check policy — that needs repo admin.
- Cannot modify pushed commits (would require force-push, which is barred).
