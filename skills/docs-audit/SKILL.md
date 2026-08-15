---
name: docs-audit
description: >
  Audits an existing docs/ folder against the actual codebase to find coverage
  gaps and drift — features/components with no matching doc, docs that
  reference files which no longer exist, and docs that look stale relative to
  how recently their code area last changed. Activates on requests like
  "audit the docs", "check doc coverage", "find gaps in our documentation",
  "are the docs up to date", or "which features aren't documented yet". Does
  NOT apply when a project has no docs/ folder at all — that's handled by the
  global documentation-first hook (~/.claude/hooks/docs_workflow.py), which
  offers to create one and optionally backfill it. This skill is for auditing
  an existing docs/ folder that may have quietly gone stale or incomplete
  since it was set up — something the per-session hook has no way to detect,
  since it only tracks drift within a single session. Read-only: produces a
  report and asks before writing or fixing anything.
---

# docs-audit

Checks whether a project's `docs/` folder still matches its codebase. This is
an on-demand, occasionally-run investigation — not something to run every
session, since it requires actually reading the codebase and forming
judgments about coverage, not a mechanical check.

## Scope reminder

`docs/` holds quick per-feature/component reference docs — what a feature
does, what files it touches, known issues — so it can be understood without
reading all the source. It is not `README.md` / `ARCHITECTURE.md` /
`DESIGN.md` / `PUBLISH.md`, which cover onboarding, architecture, and release
process. This audit is scoped to that specific kind of doc only.

## Steps

1. **Confirm `docs/` exists.** If it doesn't, stop and say so — this skill
   doesn't apply; the documentation-first hook already handles the
   no-`docs/`-at-all case (including offering a background backfill agent for
   established codebases). Don't duplicate that flow here.

2. **Read the existing docs.** Recursively list `docs/**/*.md`. Read
   `docs/README.md` first if present (it's usually the index). For each doc,
   note: what feature/component it claims to cover, and any file paths it
   references (e.g. a "Files touched" section, if the project follows that
   convention — check for a `docs/documentation-standards.md`-style file that
   defines the project's own doc conventions, and honor its specific
   checklist if one exists; otherwise judge completeness against the generic
   docs/ purpose above).

3. **Enumerate the real feature/component surface.** This is judgment, not a
   fixed algorithm — adapt to the project's actual structure. Look for things
   like: frontend route/page directories, backend route/handler/controller
   modules, distinct top-level services or packages. Don't force a
   frontend/backend split if the project isn't organized that way.

4. **Cross-reference.** For each real feature/component found, check whether
   any doc under `docs/` actually addresses it — by topical match, not just
   filename match (a doc can legitimately cover something without an exact
   path reference). Flag anything with no matching doc as **undocumented**.

5. **Check for stale references.** For each doc, verify the files/paths it
   explicitly references still exist. If a doc names a file that's been
   deleted or moved, flag it as **stale reference**.

6. **Check for staleness by recency (best-effort).** For each doc, compare
   `git log -1 --format=%ad -- <docfile>` against the most recent commit date
   touching the source files it's supposed to cover. If the code moved
   significantly after the doc's last update, flag as **possibly stale** —
   this is a signal to double check, not a certainty (docs don't need to
   change on every commit).

7. **Report, don't act.** Produce a structured list: undocumented
   features/components, stale references, possibly-stale docs. Do not edit
   any files yet.

8. **Ask before doing anything about it**, mirroring the same consent pattern
   used for the initial-backfill case in `docs_workflow.py`:
   - Offer to save the report somewhere durable (e.g. append to `ISSUES.md`
     if that convention exists in the project, or a new file) if the user
     wants a persistent record.
   - Ask whether they want a background Agent dispatched to close some or
     all of the gaps. If yes, use `isolation: "worktree"` for the same reason
     the initial-backfill case does — a sweep across many files running
     alongside whatever else is happening in the working tree needs its own
     branch, not just its own directory.
   - If the user just wanted the report, stop there. Don't proactively start
     fixing things nobody asked you to fix yet.
