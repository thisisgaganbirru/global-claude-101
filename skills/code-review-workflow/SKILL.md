# Code Review & Merge Workflow Skill

## Description
Automated hybrid workflow for organizing code changes, creating branches, managing PRs, and merging to dev/main with checkpoints for review and approval.

## Usage

```
/code-review-workflow
```

Optionally with parameters:
```
/code-review-workflow --skip-main
/code-review-workflow --dev-only
```

## Workflow Overview

### Phase 1: Analyze & Organize (Automated)
1. Check git status and analyze changes
2. Understand scope and logical grouping
3. Create feature branch with descriptive name
4. Organize changes into 2-6 focused commits
5. Push to remote

### Phase 2: Review Checkpoint (Manual Approval)
- ⛔ CHECKPOINT 1: Review commits before creating PR
- User approves or requests changes

### Phase 3: Dev Merge (Automated)
1. Create PR from feature branch → dev
2. Monitor CI tests (Backend, Frontend, Security)
3. Merge when all tests pass
4. Pull changes to local dev

### Phase 4: Review Checkpoint (Manual Approval)
- ⛔ CHECKPOINT 2: Review dev changes before main PR
- User approves or skips main merge

### Phase 5: Main Merge (Automated)
1. Create PR from dev → main
2. Apply a `semver:major` / `semver:minor` / `semver:patch` label to the PR (required — see Release Labeling below)
3. Monitor CI tests
4. Merge when all tests pass
5. Pull changes to local main

## Execution Details

### Commit Organization Logic
- Analyze diffs to group related changes
- Create 2-6 logical commits per PR
- Examples:
  - "Add feature X types and API"
  - "Implement feature X logic"
  - "Update UI for feature X"
  - "Add tests for feature X"
- NO Co-Authored-By in messages
- Short, clear commit messages

### PR Creation
- Meaningful title (what was done)
- Detailed body (why, what changed, testing)
- Reference related features/issues
- For dev → main PRs only: apply exactly one `semver:major|minor|patch` label (see Release Labeling)

### Release Labeling (dev → main PRs only)
Commits here are never squashed, so there is no single clean commit/PR-title
to parse for release intent the way squash-merge workflows do — the label
*is* the signal, and it's the only place release intent lives. `dev` itself
carries no version semantics (nightly staging, not a release).
- `semver:major` — breaks an existing consumer (removed/renamed endpoint,
  incompatible response shape change, auth behavior change)
- `semver:minor` — new backwards-compatible functionality (new endpoint,
  new optional field, new feature)
- `semver:patch` — bug fix or internal change, no interface change
- Judge by the PR's actual diff into main, not by how many files it touched
  or how long it took to build — size isn't the criterion, compatibility is.
- If unsure, ask the user rather than guessing.
- **This is enforced, not optional** (as of 2026-08-09): `main` has a
  repository ruleset requiring a PR (no direct pushes) and a required
  `semver-label-check.yml` status check that fails without exactly one
  `semver:*` label. Phase 5 will not be able to merge without it — apply
  the label before attempting merge, not after it's already blocked.
  On merge, `release-tag.yml` auto-computes and pushes the `vX.Y.Z` tag.

### CI Monitoring
- Check all status checks
- Wait for completion
- Show failures with context
- Offer retry/fix options

### Error Handling
- Test failures: Show logs and suggest fixes
- Merge conflicts: Report and suggest manual resolution
- Network issues: Retry logic with backoff
- Invalid state: Clear error messages

## Parameters

| Flag | Effect | Default |
|------|--------|---------|
| `--skip-main` | Stop after dev merge | false |
| `--dev-only` | Skip to dev PR creation | false |
| `--force-merge` | Skip checkpoints (dangerous) | false |
| `--branch-name` | Custom branch name | auto-generated |

## Checkpoint Approvals

At each checkpoint, user can:
- ✅ **Proceed** - Continue to next phase
- 🔄 **Review** - Show diffs again
- ✏️ **Adjust** - Recommend changes (I modify and wait)
- ⏸️ **Abort** - Stop workflow

## Success Criteria

Workflow completes successfully when:
- ✅ All commits organized and pushed
- ✅ Feature branch → dev PR merged
- ✅ Dev → main PR merged, with a `semver:*` label applied
- ✅ Both local branches synced
- ✅ No failing tests or conflicts

## Limitations

- Requires: git, gh CLI, clean working directory
- Cannot: Handle complex merge conflicts (manual required)
- Cannot: Override CI policy blocks (need approval/admin)
- Cannot: Modify commits after push (would need force push)

## Examples

### Standard Full Workflow
```
/code-review-workflow
→ Analyze changes
→ Create branch & organize commits
⛔ CHECKPOINT 1: Review?
→ Create PR to dev
→ Merge to dev
⛔ CHECKPOINT 2: Ready for main?
→ Create PR to main
→ Merge to main
✅ Done
```

### Dev Only
```
/code-review-workflow --dev-only
→ Skip to dev PR creation
→ Create PR to dev
→ Merge to dev
✅ Done
```

### Fast Mode (No Checkpoints)
```
/code-review-workflow --force-merge
⚠️ WARNING: Skips all approvals
→ Full workflow without checkpoints
⚠️ Use only for trusted changes
```

## Integration with Projects

Works with:
- resume-agent
- Any other project with git + gh CLI
- GitHub-based repositories
- Standard node/python/go projects

No project-specific setup needed. Just run `/code-review-workflow` in any project.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No changes detected" | Make sure you have modified files |
| "Branch already exists" | Delete old branch or use `--branch-name` |
| "Tests failing" | Fix issues locally, push new commit, retry |
| "Merge conflict" | Manual resolution required, then retry |
| "CI blocked" | May need approvals in GitHub settings |

## Workflow Diagram

```
START
  ↓
[Analyze Changes] ✅ Auto
  ↓
[Create Branch & Commits] ✅ Auto
  ↓
[Push to Remote] ✅ Auto
  ↓
⛔ CHECKPOINT 1: Review?
  ├→ Approve → Continue
  ├→ Review → Show diffs
  ├→ Adjust → Modify & wait
  └→ Abort → Stop
  ↓
[Create PR to Dev] ✅ Auto
  ↓
[Wait for CI] ✅ Auto
  ↓
[Merge to Dev] ✅ Auto
  ↓
⛔ CHECKPOINT 2: Ready for Main?
  ├→ Approve → Continue
  ├→ Skip → End
  ├→ Review → Show changes
  └→ Abort → Stop
  ↓
[Create PR to Main] ✅ Auto
  ↓
[Wait for CI] ✅ Auto
  ↓
[Merge to Main] ✅ Auto
  ↓
END ✅ Complete
```

## Notes

- Checkpoint 1 lets you review commits before they become a PR
- Checkpoint 2 lets you review all dev changes before main merge
- All CI waiting is automated (no manual monitoring needed)
- Commits are NEVER squashed (preserves history, needed for precise cherry-picks)
- Branches are NEVER deleted (safe for recovery)
- Each merge is a fresh commit (no fast-forward only)
- dev → main PRs carry release intent as a `semver:*` label, not a commit-message
  convention — see Release Labeling under Phase 5

## Support

If workflow fails:
1. Check error message for context
2. Fix the underlying issue
3. Retry with same command
4. Or manual intervention if needed
