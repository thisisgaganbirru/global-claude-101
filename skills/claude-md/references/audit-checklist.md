# CLAUDE.md Audit Checklist

Use this framework when auditing an existing CLAUDE.md. Score each dimension, identify
issues by severity, and produce a structured report.

---

## Audit Report Structure

Produce your audit in this format:

```
## CLAUDE.md Audit Report

### Overall Score: [X/100]

### Critical Issues (must fix — agent will make bad decisions without these)
- [Issue description + recommended fix]

### Major Issues (should fix — agent effectiveness is meaningfully reduced)
- [Issue description + recommended fix]

### Minor Issues (nice to fix — polish and maintainability)
- [Issue description + recommended fix]

### Missing Sections
- [What's absent and why it matters]

### What's Working Well
- [Genuine strengths to preserve]

### Recommended Rewrites
[Specific before/after rewrites for the worst offenders]
```

---

## Dimension 1: Orientation Quality (20 points)

The opening paragraph is the highest-leverage content in the file. Evaluate it hard.

**Full credit (18–20):** The orientation is 2–4 sentences. It tells the agent what the
project does, what matters most (the dominant constraint), and what kind of decisions the
agent will be making. Reading it alone would meaningfully shape the agent's behavior.

**Partial credit (10–17):** Orientation exists but is generic ("a web app that handles
data"), too long (becomes a background essay), or mixes orientation with setup
instructions.

**No credit (0–9):** No clear orientation, or orientation is a copy of a README
introduction that doesn't help the agent at all.

**Common issues to flag:**
- Missing dominant constraint (what matters most — speed, correctness, safety, cost)
- No mention of the deployment context that affects decisions
- Orientation buried after setup instructions rather than leading
- "This project..." boilerplate that could describe any project

---

## Dimension 2: Constraint Coverage (20 points)

Evaluate how well the file tells the agent what it must and must not do.

**Full credit (18–20):** Clear forbidden patterns, required libraries/tools, off-limits
files or directories, and behavioral constraints (e.g., "always confirm before deleting
records"). An agent could operate confidently within these constraints.

**Partial credit (10–17):** Some constraints exist but with gaps — either important
prohibitions are missing, or constraints are stated vaguely without enough specificity
to be reliably followed.

**No credit (0–9):** No constraints section, or constraints are so vague as to be
useless ("be careful with production").

**Common issues to flag:**
- No mention of what files/directories the agent should not touch
- No explicit list of banned or required dependencies
- Constraints buried in prose rather than clearly marked
- Missing the "requires human confirmation" category

---

## Dimension 3: Workflow Completeness (20 points)

Evaluate whether the agent has enough operational information to work independently.

**Full credit (18–20):** Exact commands for running tests, building, linting, and local
setup. Dev environment setup that would work for a new team member with no prior knowledge.
CI/CD integration points noted if they affect what the agent should do.

**Partial credit (10–17):** Some commands present but incomplete — e.g., how to run tests
but not how to run a single test file, or setup instructions that assume prior knowledge.

**No credit (0–9):** No operational commands, or commands that appear stale/broken.

**Common issues to flag:**
- "Run the tests" without the actual command
- Local setup instructions with missing steps (DB setup, env vars, etc.)
- No mention of env var requirements
- Commands that reference tools that aren't in the project (wrong package manager, etc.)

---

## Dimension 4: Warning Quality (20 points)

The Critical Warnings section is often the highest-value content because it captures
institutional knowledge that isn't in the code. Evaluate it rigorously.

**Full credit (18–20):** At least 3–5 specific, actionable warnings about real gotchas in
this specific codebase. Each warning explains what to watch out for AND why it matters.

**Partial credit (10–17):** Some warnings present but generic ("be careful with the
database"), or warnings exist but lack the specificity needed to prevent the failure they're
warning about.

**No credit (0–9):** No warnings section, or a section that exists but contains only
obvious advice that doesn't reflect project-specific knowledge.

**Common issues to flag:**
- Empty or missing Critical Warnings section
- Warnings without actionable specifics (what exact thing to avoid, where)
- No mention of deprecated patterns visible in old code
- Missing warnings about environment-specific behaviors

---

## Dimension 5: Scope Clarity (10 points)

**Full credit (9–10):** Explicit definition of what the agent can do autonomously, what
requires confirmation, and what is off-limits. External services with real consequences are
named explicitly.

**Partial credit (5–8):** Partial scope definition — either the autonomous scope is clear
but limits aren't stated, or the limits are stated but the autonomous scope isn't.

**No credit (0–4):** No scope definition at all.

---

## Dimension 6: Precision and Specificity (10 points)

This is a cross-cutting quality dimension — how precise is the language throughout?

**Full credit (9–10):** Instructions are specific and unambiguous. Naming patterns include
examples. Commands include flags. Warnings name exact files, functions, or env vars.

**Partial credit (5–8):** Mix of specific and vague content. Some sections are precise,
others are written at a level where the agent would have to guess at what's meant.

**No credit (0–4):** Predominantly vague language. An agent following this file would
need to make constant interpretive decisions.

---

## Scoring Key

| Score | Assessment |
|-------|------------|
| 90–100 | Production-ready. Maintain and review quarterly. |
| 75–89 | Good foundation. Address Major issues before heavy agent use. |
| 60–74 | Functional but incomplete. Critical issues require immediate attention. |
| 40–59 | Significant gaps. Agent will make avoidable mistakes. |
| Below 40 | Needs a rewrite, not a patch. Start from the template. |

---

## Issue Severity Definitions

**Critical** — The agent will make a materially wrong or dangerous decision without this
information. Examples: missing constraint on a destructive operation, missing warning about
a breaking gotcha, orientation so vague the agent misunderstands the project type.

**Major** — The agent's effectiveness is significantly reduced. It will ask questions it
shouldn't need to ask, make decisions that are technically correct but contextually wrong,
or produce work that requires significant human correction.

**Minor** — Polish and maintainability. The agent can function correctly but the file has
duplication, stale content, poor organization, or missing metadata that will cause
maintenance issues.

---

## Freshness Audit

Additionally, check these time-sensitivity indicators:

- Does the file have a last-reviewed date or similar maintenance marker?
- Are there any commands that reference versions that may have changed?
- Are there any warnings marked as temporary (with dates) that may now be expired?
- Does the tech stack described match what's visible in the actual project files?
- Are there references to team members, external services, or tooling that no longer exist?

Flag any of these as Minor issues unless the staleness is causing active misleading
(e.g., commands that don't work) in which case flag as Major.
