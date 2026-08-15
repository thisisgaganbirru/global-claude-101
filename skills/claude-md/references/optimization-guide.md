# CLAUDE.md Optimization Guide

Optimization is the process of making an existing CLAUDE.md better along four dimensions:
completeness, precision, token efficiency, and freshness. This guide covers all four.

---

## The Optimization Mental Model

Think of CLAUDE.md optimization as finding the **minimum sufficient set** of context.

Every token in CLAUDE.md has a cost (it consumes context window space on every session)
and a benefit (it shapes agent behavior). Optimization is about maximizing the
benefit-to-cost ratio across the whole file.

Content falls into four categories:

| Category | Benefit | Cost | Action |
|----------|---------|------|--------|
| Critical context | High | Any | Keep, make more precise |
| Nice-to-have background | Low | Medium+ | Cut |
| Duplicated constraints | Already counted | Double | Consolidate |
| Stale/wrong information | Negative | Medium | Fix or remove |

The goal is a file where every sentence falls into the first category.

---

## Pass 1: Completeness Check

Before optimizing for efficiency, check for gaps. An incomplete CLAUDE.md that's token-
efficient is just a small useless file.

Run through the Five Jobs test:

**Orient:** Read the first paragraph. Could an agent understand what kind of project this
is and what its dominant constraint is? If not, the orientation needs expansion, not
trimming.

**Constrain:** List every constraint implied by the codebase (language version, banned
patterns, required libraries, forbidden operations). Cross-reference with what's documented.
Every uncovered constraint is a gap.

**Direct:** Try to imagine an agent doing common tasks (add a feature, write a test, fix a
bug, set up locally). What questions would it need to ask? Each unanswerable question is
a workflow gap.

**Warn:** Think about every non-obvious failure mode in this project. Are they documented?
If a new developer would need to be warned about it in onboarding, it should be in
Critical Warnings.

**Scope:** Is there an explicit answer to: "Can the agent autonomously do X?" for the
three or four most consequential operations in the project? If not, scope is under-defined.

Document gaps as completeness issues before moving to efficiency work.

---

## Pass 2: Precision Upgrade

After ensuring completeness, upgrade precision. This is usually higher value than cutting —
a precise 400-token file is better than a vague 200-token one.

**Precision upgrade patterns:**

*Vague naming → Specific naming*
Before: "Use the standard naming convention for files."
After: "Name files in kebab-case (e.g., `user-profile-service.ts`). Test files mirror the
source file name with `.test.ts` suffix."

*Implicit commands → Explicit commands*
Before: "Run the linter before committing."
After: `npm run lint -- --fix && npm run typecheck`

*Vague warnings → Specific warnings*
Before: "Be careful with the auth module."
After: "⚠️ Never call `validateToken()` directly — always use `requireAuth()` middleware
which wraps it with rate limiting. Direct calls bypass the rate limiter."

*General constraints → Scoped constraints*
Before: "Don't modify the database schema."
After: "⚠️ Never edit files in `db/migrations/` directly. Schema changes require a new
migration file via `npm run db:migrate:create -- --name <description>`."

---

## Pass 3: Token Efficiency

Now trim. This is where you cut content that doesn't change agent behavior.

**Cut patterns:**

*Obvious derivable information:* If the agent can read `package.json` and learn the Node
version, don't state the Node version in CLAUDE.md. State only what isn't obvious from
the project files.

*Decorative prose:* "This is a modern, scalable microservices architecture designed to
handle millions of requests." Cut everything except the noun: "Microservices architecture."

*Full directory trees:* Replace with key-file callouts. Instead of listing 40 files,
list 8–10 that are non-obvious or especially important, with a one-line annotation each.

*Repeated constraints:* Find all cases where the same constraint is stated in multiple
sections. Pick the one in the most relevant section, add a cross-reference note in the
other if needed, and remove the duplicate.

*Historical context without current relevance:* "We migrated from MongoDB to PostgreSQL
in 2022" — does this affect any decision the agent makes today? If not, cut it.

*Aspirational or future-state content:* "We plan to add GraphQL support in Q3." This
is noise until it's real. Cut it.

**Trimming heuristic:** For each sentence, ask: "If this sentence weren't here, would the
agent behave differently on any common task?" If the answer is no, the sentence is a
candidate for removal.

---

## Pass 4: Freshness Check

Stale CLAUDE.md content is worse than no content — it actively misleads the agent.

**Check each of the following:**

Commands: Run every setup and test command mentally. If there's any reason to doubt it
still works (tooling version bump, build system change, environment restructure), verify
it. Flag unverified commands with `# NOTE: verify still current`.

Version references: Any explicitly stated version number for a language, framework, or
tool should match what's in the project's dependency files. If they don't match, fix the
CLAUDE.md or add a note.

Team/personnel references: "Ask @alice about the payment module" — if Alice left, this is
worse than nothing. Remove or replace with role-based references.

External service references: Named external services (staging URLs, third-party APIs,
internal tools) should still exist and be correctly described.

Temporary warnings: Any warning with a "until X" date that has passed should be reviewed.
Either the situation resolved (remove the warning) or it became permanent (remove the date).

---

## Optimization Output Format

When delivering an optimization pass to a user, structure the output as:

**Completeness gaps found:** [N issues]
[Bulleted list of gaps with recommended additions]

**Precision upgrades recommended:** [N items]
[Before/after pairs for the most impactful rewrites]

**Token efficiency savings:** [Estimated token reduction]
[What to cut and why]

**Freshness issues:** [N items]
[What appears stale and what verification or fix is needed]

**Net change recommendation:** [Expand / Trim / Balance]
[Brief rationale — is the file currently too thin, too thick, or about right?]

Then provide the rewritten sections or the full rewritten file depending on how extensive
the changes are.

---

## Optimization Targets by File Size

**Under 150 lines:** Usually too thin. Focus on completeness — what's missing?

**150–350 lines:** Sweet spot for most projects. Focus on precision and freshness.

**350–500 lines:** Getting heavy. Start trimming aggressively — what doesn't change
agent behavior?

**Over 500 lines:** Almost certainly contains significant noise. Run a full efficiency pass
before anything else. Consider whether the file should be split into a root CLAUDE.md and
subdirectory CLAUDE.md files (see `hierarchy.md`).

---

## The Maintenance Cadence Recommendation

Suggest this maintenance schedule to users:

**After major milestones:** Review architecture, tech stack, and key file map sections.

**Monthly (active projects):** Check Critical Warnings — have any resolved or emerged?
Verify commands still work.

**Quarterly:** Full freshness pass. Re-score against the audit checklist.

**On team changes:** Review scope and team-specific references.

Add a comment block at the top of CLAUDE.md to track this:

```markdown
<!-- Last reviewed: [DATE] | Reviewer: [NAME/ROLE] | Next review: [DATE] -->
```
