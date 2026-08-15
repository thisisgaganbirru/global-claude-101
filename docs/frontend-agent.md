# frontend agent

## What it does
User-global custom subagent (`~/.claude/agents/frontend.md`, `name: frontend`) for building new UI/components and reviewing/auditing existing frontend code for design quality. Invoked via `Agent(subagent_type: "frontend", ...)`.

## Files touched
- `agents/frontend.md` — the agent definition (frontmatter + system prompt body).

## Behavior
Pinned to `model: opus`. Preloads `hallmark` and `ui-ux-pro-max` skills via frontmatter `skills:` (full content injected at startup, not just descriptions).

Every task — Build or Review — runs through a fixed Stage A-E pipeline, in order:

- **Stage A (hallmark)** — establish (Build) or audit against (Review) the anti-AI-slop taste/structure direction. Does **not** run `frontend-design` as a separate pass — hallmark's own SKILL.md already lists it as an internal source, so a third pass would be a near-duplicate check. `frontend-design` is only invoked ad hoc via the `Skill` tool as a secondary typography opinion if hallmark's output still feels templated.
- **Stage B (ui-ux-pro-max)** — style/palette/font-pairing/stack, using its shadcn/ui MCP integration to search real components. If its suggested direction conflicts with hallmark's restraint rules from Stage A, hallmark wins, and the agent must say explicitly that it overrode the tool. Uses `--persist -p "<project name>"` only for multi-touch work on the same app; skips it for one-off components, stating which was chosen and why.
- **Stage C (dataviz, conditional)** — only when the task involves charts/graphs/dashboards/stat tiles; not preloaded, called via `Skill` tool. Disambiguates by description if more than one skill named `dataviz` is present.
- **Stage D (shadcn/ui setup check, Build mode)** — checks for `components.json` before implementing. Present → uses configured components/aliases, prefers `npx shadcn add`. Absent on a real project → asks before running `npx shadcn init` rather than assuming. Absent on a standalone/static file with no build step → hand-builds a shadcn-styled approximation and says explicitly that's what it is, not real shadcn/ui.
- **Stage E (verification gate)** — never declares done on "the code looks right." Re-reads the output file, runs build/lint if the project has one, renders/screenshots if browser tooling is available, and states explicitly when no such tooling exists rather than skipping silently.

In Review mode, Stages A-C run as an audit checklist against existing code (report findings, then fix), with Stage D/E applying to whatever changes.

**Enforcement mechanism**: every task must end with a required "Pipeline report" checklist (5 fixed lines, one per stage) filled in truthfully — not free-form prose. This exists because a "mandatory" step backed by nothing is not actually mandatory; a required structured closing output is the cheapest thing that actually forces the check to happen, versus a heavier hook-based mechanism. If any line would honestly read "skipped," the agent must not report done — it goes back and does that stage, or explains why it genuinely can't right now.

## Known issues / status
- Verified via three smoke tests (pricing-card component, Build mode):
  - v1/v2 confirmed skill order, shadcn fallback + disclosure, and honest "no verification tooling available" reporting.
  - v3 (after the Stage A-E + required-checklist rewrite) confirmed the checklist mechanism actually gets emitted and filled in truthfully, and — because headless-Chrome tooling was available that run — exercised the real render/screenshot branch for the first time (4 viewports, including a true 320px via a custom iframe harness), including a self-caught false-positive overflow claim corrected via instrumented measurement rather than trusting the screenshot at face value.
- Render/screenshot tooling availability is not deterministic across environments/runs — v1/v2 got "unavailable," v3 got real headless Chrome. Stage E's checklist is designed to surface either outcome honestly rather than assume one.
- Review mode (auditing existing code, not building new) has not been smoke-tested directly through the agent itself — the closest evidence is a manual Review-mode cleanup pass done outside the agent (on `satellite-home.html`), not a dispatched `frontend` subagent run.
- Reviewed via `/llm-council` — unanimous finding was that the old "mandatory... no hard enforcement" verification step was prose wearing a control's name; the Stage A-E pipeline + required Pipeline report checklist is the direct fix for that finding.
