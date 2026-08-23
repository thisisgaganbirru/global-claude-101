---
name: read-only
description: >
  Locks the current turn into analysis-only mode — investigate deeply, explain,
  and recommend, but change nothing. Use whenever the user asks you to analyze,
  review, investigate, trace, audit, explain, compare, or give an opinion on
  code without also asking for it to be fixed. Trigger on phrasings like "just
  analyze this", "what do you think about", "explain how X works", "why is this
  happening", "take a look at", "check whether", "don't change anything",
  "read-only", "look but don't touch", "what's your opinion", "is this
  approach right". Especially important when the session is running in
  auto-approve / accept-edits mode, because there is no permission prompt left
  to catch an edit the user never asked for. Do NOT use when the user has
  clearly asked for an implementation, fix, refactor, or commit.
---

# Read-Only Mode

For this turn, the deliverable is **information, not a modified repository.**

Investigate as deeply as the question deserves. Then report. Leave the working
tree exactly as you found it.

## Why this exists

There's a specific failure this prevents. You're asked to analyze something,
you dig in, you find the problem — and the fix looks obvious and cheap, so you
just apply it. That feels helpful. It usually isn't, for three reasons:

- **The user was building a mental model, not requesting a change.** They asked
  in order to decide something. An edit that lands before they've decided takes
  the decision away from them and desyncs their model of the code from reality.
- **In auto-approve mode nothing catches it.** The permission prompt that would
  normally surface "about to edit X" is gone. An unrequested edit is silent.
- **A fix written during analysis was never reviewed as a fix.** It rode in on
  the momentum of the investigation, without the scrutiny an intentional change
  would get.

So the rule isn't "be less useful." It's "put the fix in the report, and let
the human pull the trigger."

## What you may do

Read, `Grep`, `Glob`, `WebFetch`, `WebSearch`, and any Bash that only observes:
`git status`, `git log`, `git diff`, `git show`, `git blame`, `ls`, `wc`,
`rg`, test runners and linters **only in report mode** (no `--fix`, no
`--write`). Read-only subagents are fine.

Scratchpad files for your own intermediate notes are fine. The repo is not.

## What you may not do

`Write`, `Edit`, `NotebookEdit` on anything in the project. No Bash that
mutates state: no `rm`, `mv`, `cp`, `mkdir`, `>`, `>>`, `sed -i`, no
`git add/commit/push/checkout/restore/stash/reset`, no package installs, no
formatters or codegen that write files, no `gh pr create/merge`.

Don't publish anything outward either — no Artifact publish, no comment
posting, no message sending. Those are changes too, just to a different surface.

If you're unsure whether a command mutates, assume it does and skip it. Say in
the report what you would have run.

## Where the fix impulse goes

When you find the thing and you want to fix it — good, that instinct is
correct, it's just early. Write the fix into the report instead of the file.
Be concrete enough that applying it is trivial:

```
### Proposed fix (not applied)

`src/auth/session.ts:42` — the token expiry check uses `<` where it needs `<=`,
so a token expiring exactly on the boundary is treated as still valid.

- if (Date.now() < expiresAt) {
+ if (Date.now() <= expiresAt) {
```

A precise unapplied patch is more valuable than a silently applied one. The
user gets the fix *and* keeps the choice.

## Read-only is not low-effort

Restricting writes doesn't restrict thoroughness. Read every file the question
touches, follow the call chain, check the git history if it's relevant, verify
claims against the actual code rather than inferring from names. The user asked
a question because they wanted a real answer — shallow analysis fails them just
as badly as an unwanted edit.

## Report shape

Open with a one-line marker so the user can see the lock is on:

> 🔒 **Read-only** — analysis only, nothing modified.

Then answer the actual question first, in whatever structure fits it. Don't
force a template onto a question that just needs two sentences. For anything
substantial, these tend to earn their place:

- **What's happening** — the finding, with `file.ts:line` references
- **Why** — the mechanism, not just the symptom
- **Proposed changes (not applied)** — concrete diffs or steps
- **What I'd need to confirm** — anything you inferred but couldn't verify

Close by naming the exit: what you'd do next if they want it done.

## Edge cases

**The analysis reveals something urgent or broken.** Still don't fix it. Lead
with it, mark it clearly, and offer. Urgency is a reason to surface something
loudly, not a license to bypass the user's decision.

**The request is mixed — "look at the auth bug and fix it".** If this skill was
invoked explicitly, analysis wins for this turn; say plainly that you're
holding the fix and it's one word away. If it triggered on ambiguous phrasing
and the user clearly wanted the change, just ask which they meant rather than
stalling on a technicality.

**You genuinely cannot answer without running something that writes** (a
migration, a build that emits artifacts). Stop and say so, explain exactly what
needs to run and why, and let the user unlock it.

**Docs and memory hooks.** Nothing changed, so the `docs/` and `mem/` write
steps don't apply this turn. Note that in one short line rather than skipping
it silently.

## How the lock lifts

This binds the current turn only. The next message releases it — "go ahead",
"apply that", "yes do it", or any fresh request for a change. Don't carry
read-only into a turn where the user has clearly asked you to build something,
and don't make them re-invoke it to keep asking questions.
