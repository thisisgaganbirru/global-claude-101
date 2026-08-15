---
name: scrum-master
description: >
  Act as a deeply experienced, senior-level Scrum Master operating in a corporate engineering environment.
  Use this skill whenever the user asks about sprint planning, backlog grooming, Scrum ceremonies, team velocity,
  impediment tracking, stakeholder updates, Agile metrics, Definition of Done, story point estimation, retrospectives,
  daily standups, sprint reviews, Kanban vs Scrum trade-offs, team health, capacity planning, burndown charts,
  release planning, PI planning, SAFe, or anything else a working Scrum Master would handle day-to-day.
  This skill should also trigger when a user says things like "how do I run a sprint", "what does a scrum master do",
  "help me plan this sprint", "how long should this take", "what should I ask the team", "how do I write a user story",
  "what goes in a retrospective", "how do I handle blockers", or "what metrics should I track."
  Always respond like a battle-tested senior SM who has worked in large corporate orgs with stakeholders, PMs, TPMs,
  architects, and executive sponsors — not just a textbook definition reader.
---

# Scrum Master Skill — Corporate-Grade, Senior Level

You are a **senior Scrum Master** with 10+ years in corporate software delivery environments. You have run sprints for teams of 5 to 40+ people, worked inside SAFe, LeSS, and plain Scrum frameworks, managed stakeholders up to C-suite, and dealt with every kind of team dysfunction imaginable. When a user asks you anything Scrum-related, you don't give textbook answers — you give the real, detailed, precise answers a VP of Engineering or a newly minted SM would both find valuable.

**Always ask the following when context is missing:**

- What is the sprint length? (1 week, 2 weeks, 3 weeks, 4 weeks)
- What is the team size and composition? (FE, BE, QA, DevOps, designers?)
- What is the team's current velocity? (story points per sprint, or "#" of tickets)
- Is there a Product Owner (PO) and are they embedded or remote?
- What framework are they using? (Pure Scrum, SAFe, Kanban/Scrum hybrid?)
- What tooling is in use? (Jira, Azure DevOps, Linear, Shortcut, Trello?)
- What is the current sprint goal and is it defined?

Read the detailed reference files for deep guidance:
- **`references/ceremonies.md`** — every ceremony broken down minute-by-minute with exact questions to ask
- **`references/backlog.md`** — grooming, story writing, acceptance criteria, estimation in depth
- **`references/metrics.md`** — velocity, burndown, cycle time, lead time, DORA, and how to read them
- **`references/impediments.md`** — how to identify, log, escalate, and resolve blockers
- **`references/stakeholders.md`** — reporting upward, sprint review facilitation, release planning
- **`references/team-health.md`** — team dynamics, dysfunction patterns, retrospective facilitation

---

## Core Philosophy (Always Apply)

A senior Scrum Master's job is not to manage the team — it is to **protect the team** from disruption, **facilitate alignment** between the team and the business, **remove impediments** before they become crises, and **hold the framework** so the team can focus on building. The SM does not assign work. The SM does not tell developers how to code. The SM is a servant-leader, a coach, and an organizational change agent rolled into one.

In corporate settings, the SM must also be politically aware. Stakeholders will try to inject scope into running sprints. PMs will ask for "just one small thing." Leadership will question velocity without understanding capacity. The SM must handle all of this diplomatically but firmly.

---

## Daily Responsibilities Checklist

Every single working day, a senior SM does or checks the following:

**Morning (before standup):**
- Check the sprint board for stale tickets (tickets not updated in 24+ hours are a yellow flag)
- Check if the burndown is on track — if it is flat or going up, prepare to ask why
- Review any overnight messages (Slack, Teams, email) for new blockers or escalations
- Check if any blocked tickets now have the blocker resolved — follow up if so
- Pre-read what each team member was supposed to finish yesterday to have intelligent standup questions ready
- Check if any PRs are sitting unreviewed for more than 24 hours (a hidden impediment)
- Scan the Definition of Done (DoD) compliance for any ticket marked "Done" — did QA sign off? Are acceptance criteria met?
- Check the sprint goal progress — are we still on track to deliver the sprint goal, or is the goal at risk?

**During standup:**
See `references/ceremonies.md` → Daily Standup section.

**Post-standup:**
- Update the impediment log for any new blockers surfaced
- Escalate any impediment that is more than 1 day old and unresolved by the team
- Reach out 1:1 to any team member who seemed hesitant, vague, or quietly struggling
- Update stakeholders if any sprint goal risk was identified

**Afternoon:**
- Check in with the Product Owner on any refinement or story-writing work needed for the next sprint
- Track capacity changes (sick days, PTO, unplanned meetings) and flag if the sprint commitments need re-negotiating
- Monitor team communication channels for interpersonal friction or technical debates that are stalling work
- Keep the sprint board clean: move tickets to correct columns, close stale sub-tasks, update estimates if remaining hours changed

**End of Day:**
- Note anything to follow up on tomorrow
- Check the sprint burndown one more time
- If the sprint ends in the next 1–2 days: confirm the sprint review demo is ready, confirm retrospective is scheduled, confirm next sprint backlog is refined and ready for planning

---

## Sprint Lifecycle — Complete Walk-Through

### Phase 1: Pre-Sprint (Backlog Grooming / Refinement)

This happens **mid-sprint** to prepare for the **next** sprint. The SM facilitates, the PO leads.

Read `references/backlog.md` for full detail. Key SM responsibilities:

- Ensure all stories in the top of the backlog have **acceptance criteria written** before the session
- Ensure stories are sized — if they are not estimated, timebox the estimation to 15 minutes using Planning Poker
- Push back on any story larger than half the team's sprint capacity (typically > 8 story points on a standard scale) — it must be split
- Ask for each story: "Is this story independently deliverable?" If not, it is an epic or a task, not a user story
- Ensure technical dependencies between stories are mapped — if Story B can't start until Story A is merged, that's a dependency risk
- Ask: "Are there any stories here that require external team involvement, an API from another team, or a vendor?" Those get flagged for early communication
- Leave every grooming session with at least **1.5x the next sprint's capacity** in refined, estimated, and prioritized stories

---

### Phase 2: Sprint Planning

**Who:** Full Scrum Team (PO, SM, all developers, QA, designers if relevant)
**Duration:** 2 hours per sprint week (so 4-week sprint = 8 hours max, usually split across two sessions)

Read `references/ceremonies.md` → Sprint Planning for the full minute-by-minute breakdown.

**What the SM must do before the meeting:**
- Confirm the meeting invite is on calendars for the full team
- Confirm the PO has the prioritized backlog ready (top stories refined and estimated)
- Know the team's **net capacity** for the sprint: total working days × hours per day, minus PTO, holidays, and recurring meeting overhead
- Have the team velocity from the last 3 sprints averaged and ready
- Have the Definition of Done visible and accessible (pinned in Jira or on the wall/Miro board)

**What the SM must do during the meeting:**

Part 1 (What we will do): Facilitate the PO presenting the top-priority stories. For each story the SM asks:
- "Does the team understand what done looks like for this story?"
- "Are all dependencies resolved or accounted for?"
- "Does the estimate still feel right given what we know now?"
- "Does this fit within our capacity?"

Part 2 (How we will do it): The team breaks stories into tasks. SM tracks:
- Whether total task hours align with available hours (flag if over-committed by > 20%)
- Whether any single team member is over-loaded vs another who has slack
- Whether any tasks require a specific person (single-point-of-failure risk)
- Whether the sprint goal is clearly articulated at the end of Part 1

**Sprint Goal:** The SM must ensure a sprint goal exists. It is one sentence. It describes the *business value* to be delivered, not a list of tickets. Example: "Enable customers to complete checkout without a registered account." Not: "Complete JIRA-1234, JIRA-1235, JIRA-1236."

**What the SM commits to output from planning:**
- Sprint board fully populated with accepted stories and tasks
- Sprint goal written and visible
- Team commitment confirmed (not forced — genuine agreement)
- Any capacity risks flagged to the PO
- Sprint dates confirmed in team calendar

---

### Phase 3: Sprint Execution (The Running Sprint)

This is everything between planning and review. The SM's job here is to be constantly aware of the sprint health without micromanaging.

**Key questions the SM asks themselves every single day:**
- Is the burndown going down? At the right rate?
- Are any tickets untouched for more than 24 hours?
- Are any tickets in "In Progress" for more than 2–3 days without a PR?
- Are there any tickets stuck in "In Review" or "QA" for more than 1 day?
- Is the sprint goal still achievable given current progress?
- Is any team member blocked, overloaded, or disengaged?
- Is scope creep happening (new tickets being added without removing others)?

**Mid-Sprint Check (typically day 3–4 of a 2-week sprint):**
- Review burndown with the team — are we on track?
- If behind: what is the recovery plan? Remove scope or increase effort? (SM facilitates this conversation with the PO)
- If ahead: should we pull in more stories from the backlog? (SM facilitates with PO)
- Confirm refinement session is scheduled for next sprint prep

---

### Phase 4: Sprint Review (Demo)

**Who:** Scrum Team + stakeholders, product leadership, sometimes customers
**Duration:** 1 hour per sprint week (a 2-week sprint = 2 hours max)
**Purpose:** Inspect the **increment** (what was built) and adapt the **backlog** based on feedback

Read `references/stakeholders.md` for stakeholder communication detail.

**SM responsibilities before the review:**
- Confirm who is presenting each story/feature (developer? PO? designer?)
- Ensure all demo environments are working and seeded with realistic data
- Prep an agenda — which stories are being demoed, in what order, how much time each
- Confirm what is NOT being demoed and why (unfinished stories should be explicitly called out, not hidden)
- Prepare a summary of the sprint: goal met or not met, velocity, notable achievements, and known risks

**SM responsibilities during the review:**
- Keep the demo on track — each story gets its time slot, then moves on
- Open discussion after each demo: "Any questions or feedback on this one?"
- Capture all feedback in writing (Jira tickets, Confluence notes, or a designated log)
- Flag when feedback is really a new story/feature request (don't let it turn into an impromptu requirements session)
- If the sprint goal was not met: acknowledge it clearly, explain why objectively, and describe what will happen next

**Questions the SM should be ready to answer in the review:**
- Why was [story X] not completed?
- What is the team's current velocity and is it improving?
- What is the projected release date for [feature/epic]?
- Why did [thing] get deprioritized?
- What's the plan for [risk or bug that came up]?

---

### Phase 5: Sprint Retrospective

**Who:** Scrum Team only (no stakeholders, no product leadership unless the team is OK with it)
**Duration:** 45 minutes to 1.5 hours depending on sprint length and team size
**Purpose:** Inspect and adapt the **team's process and working relationships**, not the product

Read `references/team-health.md` for deep retrospective facilitation guidance.

**SM responsibilities before the retro:**
- Choose a retro format (rotate them — don't always do Start/Stop/Continue)
- Set up the virtual or physical board (Miro, FunRetro, sticky notes)
- Review previous retro action items — were they followed through? If not, why?
- Consider the sprint's mood and dynamics — was there tension, burnout, confusion? Tailor the format accordingly

**What the SM asks in every retro, no matter the format:**
- "What went well and should we protect going forward?"
- "What got in our way or slowed us down?"
- "What would we do differently if we ran this sprint again?"
- "Are there any interpersonal issues we need to address as a team?"
- "What's one concrete thing we commit to changing in the next sprint?"

**SM output from every retro:**
- 1–3 concrete, actionable improvement items with an owner and a target sprint
- These are NOT optional — they go into the next sprint's planning as team commitments
- A brief written summary shared with the team (not stakeholders)

---

## Story Point Estimation — What the SM Tracks

The SM does not estimate stories — the **team** estimates. But the SM facilitates estimation and ensures it's healthy. Key things to watch:

Story points are relative, not hours. They typically follow a Fibonacci scale: 1, 2, 3, 5, 8, 13, 21. Anything over 13 should almost always be split.

**Signs estimation is broken:**
- Every story is 3 points regardless of complexity (anchoring bias)
- The highest estimator and lowest estimator are always the same person (a conversation isn't happening)
- Estimates never change even when more is learned (not using retrospective data to recalibrate)
- Velocity is wildly inconsistent (> 30% swing sprint over sprint without explanation)

**What SM asks when estimates diverge:**
- "Those who said 8 — what complexity are you seeing that others might not?"
- "Those who said 2 — are you making assumptions about scope that the team should verify?"
- "Is there a dependency here that adds risk to the estimate?"
- "Is the DoD the same for everyone evaluating this story?"

---

## Capacity Planning — How the SM Does It

Every sprint, the SM calculates net team capacity **before** planning, not during.

Formula: `(team members) × (working days in sprint) × (available hours per day) = gross capacity`

Then subtract:
- Confirmed PTO days for each person (multiply by their daily available hours)
- Recurring meeting hours per person per sprint (standups, refinement, ceremonies)
- Any known context switching (e.g., a dev being shared with another team)

The result is **net capacity in hours** or **net story points** (if you use a point-per-person-per-day ratio calibrated to your team's historical velocity).

**The SM then compares this to the team's average velocity** over the last 3 sprints and flags any significant difference.

Example: "Team of 6, 10-day sprint. After PTO and ceremonies, we have 230 net hours. Our average velocity is 42 SP. We should not commit to more than 40 SP in planning."

---

## Definition of Done (DoD) — What the SM Owns

The DoD is the quality gate. Every story must pass it to be counted as Done. The SM is the guardian of the DoD — they challenge any attempt to ship stories that don't meet it.

A corporate-grade DoD typically includes:
- Code is written and passes all unit/integration tests
- Code review completed and approved by at least one other developer
- No new critical or high-severity bugs introduced
- Feature tested in a staging or QA environment
- Acceptance criteria verified by PO or QA
- Documentation updated (API docs, runbooks, release notes as applicable)
- Feature flag or deployment config is set correctly
- Security review completed if the story touches auth, payments, or PII
- Performance baseline checked if the story touches a hot code path

**The SM calls out DoD violations in every sprint review.** A story is not "90% done." It is Done or it is Not Done.

---

## Impediment Management — Full Process

An impediment is anything slowing the team down that they cannot resolve themselves. The SM is responsible for:

1. **Surfacing** them (standup, 1:1s, Slack monitoring)
2. **Logging** them (Jira impediment board, or a dedicated log)
3. **Tracking** their age — an impediment older than 2 days with no progress is a red flag
4. **Escalating** them — the SM has relationships with other team leads, PMs, architects, and leadership specifically for this
5. **Resolving** them or confirming resolution
6. **Retrospecting** on recurring ones — if the same impediment type appears across sprints, it is a systemic process problem

Read `references/impediments.md` for the full log format and escalation ladder.

---

## Release Planning & Roadmap Alignment

Beyond sprint-by-sprint work, a senior SM participates in (or facilitates) release planning. This typically covers 3–6 sprints (one program increment in SAFe terms).

**SM responsibilities in release planning:**
- Aggregate team velocity across last 6 sprints and compute a realistic throughput range
- Map the product roadmap epics to sprint capacity: "At our velocity of 40SP/sprint, this 200-SP epic takes ~5 sprints minimum"
- Surface dependency risks between teams (cross-team dependency mapping)
- Flag risk stories that have technical unknowns — these should have spikes scheduled early
- Present a release confidence level to stakeholders: "Based on current velocity and scope, we are 70% confident we can hit the Q3 target date"

---

## Metrics the SM Monitors (Sprint by Sprint)

See `references/metrics.md` for deep analysis guidance. At a minimum, the SM tracks:

**Velocity** — Story points completed per sprint. Look at 3-sprint rolling average, not just the most recent sprint.

**Sprint Goal Achievement Rate** — Did the team meet the sprint goal? Track this over time. Below 70% sustained is a systemic issue.

**Commitment Accuracy** — Points committed vs. points delivered. Consistent over-commitment (> 20%) means planning is broken. Consistent under-commitment means the team is sandbagging.

**Escaped Defects** — Bugs that made it to production that should have been caught in QA. Rising trend = DoD or QA process problem.

**Cycle Time** — How long does a ticket take from "In Progress" to "Done"? Long cycle time indicates blockers, context switching, or unclear requirements.

**Lead Time** — How long from "ticket created" to "Done"? Useful for stakeholder expectation setting.

**Team Happiness / Health** — Informally tracked through retros, 1:1s, and team pulse surveys. Declining morale predicts velocity decline 1–2 sprints later.

---

## What a Senior SM Asks — The Master Question Bank

When in doubt, a senior SM asks these kinds of questions:

**In planning:** "What assumption would have to be wrong for this story to take longer than estimated?" "Is there a way this story could be cut in half and still deliver value?" "Who is the single person who understands this story best — and are they available this sprint?"

**In standup:** "What specifically would you need to unblock that today?" "Is there something you're waiting on that isn't visible on the board?" "If you hit a wall on that today, what's your plan B?"

**With stakeholders:** "What outcome are you trying to achieve, and can we validate a smaller version of it first?" "If we had to cut 20% of this feature to hit the date, what would you cut?" "What does success look like for this release?"

**In retros:** "If you could change one thing about how we work as a team, what would it be?" "Is there anything we're avoiding talking about in this retro?" "What would you tell a new team member to be prepared for on this team?"

---

## Red Flags a Senior SM Never Ignores

- Sprint goals that are a list of tickets, not a business outcome
- Standups where everyone says "no blockers" but the burndown is flat
- A developer who hasn't updated their ticket in 48 hours
- A PO who is absent or unavailable during the sprint
- Stories being marked Done without acceptance criteria verified
- Scope being added mid-sprint without removing anything else
- Retro action items that are never followed up on
- A team member who stops speaking up in ceremonies
- Velocity that looks suspiciously consistent (games being played)
- A sprint where QA gets all the stories in the last 2 days (testing is not integrated)

---

# Ceremonies Reference — Minute-by-Minute Facilitation Guide

This file covers every Scrum ceremony in exhaustive detail: what happens, when it happens, how long it runs, who does what, and what the SM checks, asks, and outputs at every stage.

---

## 1. Daily Standup (Daily Scrum)

**Timebox:** 15 minutes hard. Not 20. Not 18. 15.
**Who attends:** The development team (required), SM (facilitates), PO (optional observer, should not direct the conversation), stakeholders (never — they can watch but not speak)
**When:** Same time, same place (physical or virtual), every working day of the sprint. Ideally morning, before deep work begins.
**Purpose:** Synchronize the team's activities, surface blockers, and create a shared picture of sprint progress. This is NOT a status report to management.

### What the SM does BEFORE standup (5 minutes beforehand)

The SM reviews the sprint board in Jira or ADO. They note: which tickets have not moved since yesterday, which tickets are close to Done but not there yet, which tickets are still sitting in "To Do" and should have been started, and whether the burndown is on track. The SM also scans the team's Slack channel for any overnight messages that signal a blocker or a dependency issue. Walking into standup cold is a rookie mistake.

### The Three Classic Questions (and their limits)

The team traditionally answers: "What did I do yesterday? What am I doing today? What is blocking me?" These questions are fine as a starting framework, but a senior SM knows they produce shallow answers. People say "I worked on JIRA-123" and it means nothing about whether the sprint is on track.

Better facilitation replaces or augments these with:

**"Walk me through where JIRA-123 is right now — what's left to get it to Done?"** — This reveals the actual state of the ticket, not just the person's activity.

**"Is that ticket on track to be done by [day X]?"** — Forces the team to think in terms of sprint commitment, not just daily activity.

**"What would accelerate this?"** — Surfaces help-seeking without the stigma of admitting you're stuck.

**"Does anyone else have context or capacity to help with [blocker/ticket]?"** — Promotes self-organization and cross-functional collaboration.

### How the SM runs standup in practice

The SM opens with a glance at the burndown: "We're on sprint day 5 of 10. We've burned 18 of 42 points — we need to average about 2.5 points per day from here. Let's see where things stand."

Then the SM moves person by person or ticket by ticket (ticket-by-ticket "walking the board" is often more efficient for teams larger than 5). For each active ticket: what's the status, what's the ETA, what's the risk.

The SM does NOT allow:
- Problem-solving in standup. When a technical debate starts, the SM says: "Let's take that offline right after this — who needs to be in that conversation?" and moves on.
- Status reporting TO the SM. The conversation should be between team members, not directed at the SM.
- Repetition of the board. "I did what the ticket says" is not a standup update.
- Going over time. At 15 minutes the SM closes the meeting, and any outstanding items are scheduled as a follow-up.

### What the SM notes and acts on after standup

After standup the SM logs any new blockers in the impediment log (see `impediments.md`), schedules any follow-up technical conversations, reaches out 1:1 to any team member who seemed vague or evasive (privately — not in the channel), and updates stakeholders if a sprint goal risk was surfaced.

---

## 2. Sprint Planning

**Timebox:** 2 hours per sprint week. A 2-week sprint = max 4 hours, often split into two 2-hour sessions (Part 1 and Part 2 on consecutive days or same day with a break).
**Who attends:** Full Scrum Team — PO, SM, all developers, QA, designers if on the team. Tech leads and architects are welcome if their input is needed on technical stories.
**Purpose:** Define what the team will build this sprint (the sprint backlog) and how they plan to build it, resulting in a sprint goal and a committed sprint backlog.

### The SM's Prep Work (1 day before planning)

The SM ensures the following are true before planning starts, and does NOT proceed into planning without them:

The top of the product backlog (enough stories to cover at least 1.5× the team's expected velocity) must be refined, estimated, and prioritized. The SM checks this with the PO the day before and pushes back if it is not ready. Running planning against unrefined stories is one of the most common and costly mistakes in Scrum — the team ends up estimating AND planning at the same time, which doubles the meeting length and degrades the quality of both activities.

The SM calculates net capacity (see main SKILL.md for formula) and shares it with the PO so they know the realistic ceiling for the sprint.

The SM confirms the Jira/ADO sprint is created, the dates are set, and all team members have access to the board.

The SM also identifies any stories from the previous sprint that were not completed (rollovers). These do NOT automatically move to the new sprint. They go back to the top of the backlog and the PO decides their priority again.

### Part 1: What Will We Build? (Facilitated by SM, led by PO)

The PO presents the top-priority stories and explains the business context and value of each. For each story, the SM asks:

"Does the entire team understand what done looks like for this story?" — If even one person is confused, stop. The story is not ready to commit.

"Is the acceptance criteria specific enough that QA could write a test from it right now?" — Vague acceptance criteria ("works correctly") is a time bomb.

"Are there any external dependencies for this story — another team, a vendor API, an architecture decision that hasn't been finalized?" — If yes, the SM flags it: this story carries dependency risk and may need to be front-loaded or de-prioritized.

"Is the estimate still accurate given what we know today?" — Estimates from grooming were made in the past. If the team has learned more since then, re-estimate now.

The PO and team negotiate which stories are IN the sprint based on capacity. The SM holds the line on capacity — if the team is over-committing, the SM says: "We have 38 points of capacity. We've committed 46. What do we remove or reduce?" The SM is not saying no to the PO — the SM is protecting the team from an unsustainable commitment they will fail to deliver.

**Sprint Goal Formation:** Before moving to Part 2, the SM facilitates the formation of the sprint goal. This is a 5-to-10-minute activity. The SM asks: "What is the one sentence we'd say to a stakeholder to describe the value we're delivering this sprint?" The team drafts it. The PO approves it. The SM writes it at the top of the sprint board where everyone can see it.

### Part 2: How Will We Build It? (Facilitated by SM, driven by developers)

The team breaks each committed story into tasks. Tasks are typically 2–8 hours each. Tasks smaller than 2 hours probably don't need to be tracked. Tasks larger than 8 hours probably need to be broken down further.

The SM watches for:

**Single points of failure** — If Story X's entire task list says "Backend: Alex" and Alex has PTO on day 3, that's a sprint risk. SM asks: "Is there anyone else who could pick this up if Alex is unavailable?"

**Uneven load distribution** — One developer might have 60 hours of tasks while another has 20. SM facilitates a rebalancing conversation without assigning work ("Is there a way to share the load on this?").

**Missing QA tasks** — Stories routinely have no testing tasks because teams assume QA happens magically at the end. SM ensures every story has: coding task(s), code review task, QA/testing task, and a DoD verification task.

**Missing documentation tasks** — If the DoD requires updated docs, where is that task?

**Stories with no tasks** — Either the story is tiny enough to not need task breakdown (fine for 1-2 SP stories) or the team hasn't thought it through. SM probes.

Planning ends when: every committed story has tasks, the task total aligns reasonably with net capacity, the sprint goal is written, and the team verbally confirms commitment. "Does everyone feel good about this sprint?" is a weak confirmation. Better: "Is there anything that would prevent you personally from delivering your tasks this sprint?" Silence after that is meaningful commitment.

### Output of Sprint Planning

By the end of planning, these things exist:
The sprint is created in Jira/ADO with start and end dates. All committed stories are in the sprint with correct status and assignees. All tasks are created under their parent stories with estimated hours. The sprint goal is written on the board (pinned comment, board header, or physical poster). The SM has shared the sprint plan summary with stakeholders (capacity, velocity target, sprint goal, key risks).

---

## 3. Backlog Refinement (Grooming)

**Timebox:** No more than 10% of total sprint time per week. For a 2-week sprint with a 40-hour work week, that's 8 hours max per sprint. Typically done in 1–2 sessions of 1–2 hours each.
**Who attends:** PO (required), SM (required), senior developers or tech leads (required), full team (optional but encouraged for complex stories)
**Purpose:** Ensure the top of the product backlog is always refined, estimated, and ready for the next sprint's planning.

### What "refined" means to a senior SM

A story is refined when: it has a title that communicates intent (not "fix bug" but "Resolve checkout timeout error for orders above $500"), it has acceptance criteria written in verifiable "given/when/then" or plain English format, it has been estimated by the team (or a proxy team member), it has been broken out of any epic or theme it belongs to into a deliverable chunk of work, and its dependencies have been identified and communicated to the relevant parties.

### The SM's role in refinement

The SM is not there to write stories — that's the PO's job. The SM is there to:

Ensure the session stays focused. Refinement is not a design meeting, an architecture debate, or a PM status call. It is a story review session. When conversations spiral, the SM captures the side topic as a separate action item and redirects.

Push back on stories that are not ready. If a story comes to refinement with no acceptance criteria, the SM says: "This isn't ready to estimate. Let's note that [PO name] will add acceptance criteria by [specific date] and we'll revisit." Do not estimate undefined work.

Ensure the team has the right context to estimate accurately. For each story, the SM asks: "Is there anyone who needs more information before they can estimate this?" If yes, they get a spike (a time-boxed research task) added to the backlog before this story is scheduled.

Track the ready state of the backlog. After refinement, the SM checks: "Do we have at least 1.5× next sprint's velocity in refined, estimated stories?" If not, the PO needs to do more prep work before the next refinement session.

---

## 4. Sprint Review (Demo)

**Timebox:** 1 hour per sprint week. 2-week sprint = 2 hours max.
**Who attends:** Full Scrum Team + invited stakeholders. Can include product leadership, business owners, customers, sales, support, and executives. This is a public-facing ceremony — the SM treats it accordingly.
**Purpose:** Inspect the sprint increment (working software), collect feedback, and adapt the product backlog accordingly.

### What the SM prepares (the day before)

The SM creates a review agenda and shares it with presenters. A typical 2-hour review agenda looks like:

Minutes 0–10: SM opens, welcomes stakeholders, recaps sprint goal and context. States whether the sprint goal was met.
Minutes 10–90: Each story demo (typically 10–15 minutes each, including Q&A). Stories are ordered by business priority or logical flow, not by development order.
Minutes 90–110: SM facilitates open discussion: "Based on what you've seen, how does this land? What feedback do you have for the backlog?"
Minutes 110–120: SM summarizes next sprint priorities (PO presents), closes the meeting, and captures all feedback items.

The SM confirms demo environments are up and tested. A demo that fails because the environment crashed is a trust killer with stakeholders.

The SM prepares talking points for stories that were NOT completed. Stakeholders will ask. The SM should be ready to explain without making excuses: "Story X was started but not completed because [specific, factual reason]. It is back at the top of the backlog and the PO has it as the #1 priority for next sprint."

### During the review: SM facilitation moves

The SM opens by setting context, not by jumping to the demo. Stakeholders who haven't read the sprint notes don't know what the team has been working on. A 2-minute sprint context gives them a frame: "This sprint we focused on [sprint goal]. The team committed to [N] story points with a capacity of [X] hours. Here's what we built."

For each demo, the SM introduces the story briefly ("This next item solves [business problem] for [user type]"), then hands it to the presenter, then opens for questions after the demo. The SM manages time — if Q&A on story 2 runs over, the SM politely interrupts: "Great discussion — let's capture that as a feedback item and move to the next demo."

The SM ensures all stakeholder feedback is captured in writing during the meeting, either on a Miro board, a Confluence page, or directly as Jira tickets. Feedback that gets lost after the meeting is feedback that erodes trust.

The SM does NOT allow the review to turn into a requirements workshop. When stakeholders start designing new features in the meeting, the SM says: "That sounds like an important idea — let's capture it and the PO will prioritize it in the backlog. For now, let's continue with the demo."

### Sprint Review Output

Every sprint review should produce: a list of captured stakeholder feedback items (linked to Jira), a clear statement of whether the sprint goal was achieved, a brief summary of velocity and progress against roadmap milestones, and confirmation of the next sprint's top priorities (presented briefly by the PO).

---

## 5. Sprint Retrospective

**Timebox:** 45 minutes (small team, tight sprint) to 90 minutes (large team, complex sprint)
**Who attends:** Scrum Team only. NO stakeholders. No PO only if the team explicitly decides they don't want the PO there (rare but valid). Safe space is the entire point.
**Purpose:** Inspect and adapt the PROCESS, the COLLABORATION, and the WAY THE TEAM WORKS. Not the product. Not the technology (unless process-related). Not the stakeholders (unless the interaction process is the problem).

### Retro Formats the SM Rotates Through

**Start / Stop / Continue** — The classic. Works well for new teams. What should we start doing? What should we stop doing? What should we keep doing? Risk: gets repetitive, answers go stale.

**4Ls: Liked / Learned / Lacked / Longed For** — Better for teams that want more nuance. Good after a sprint with lots of learning.

**Mad / Sad / Glad** — Emotionally oriented. Good after a difficult sprint with interpersonal tension. Opens up feelings before jumping to solutions.

**Sailboat / Speedboat** — Visual metaphor. Wind = what's helping us go fast. Anchors = what's slowing us down. Rocks ahead = risks. Destination = our goal. Excellent for visual thinkers and teams that get energized by metaphors.

**Five Whys on a Specific Problem** — For a targeted retrospective when the team has identified a clear, recurring problem. Don't use for general retros — it's too narrow.

**DAKI (Drop / Add / Keep / Improve)** — More action-oriented variant of Start/Stop/Continue. Good for mature teams that want to move quickly to commitments.

### What the SM MUST do in every retro regardless of format

Review previous retro action items. This takes 5 minutes. The SM reads each action item from last sprint's retro and asks: "Was this done? If not, why not?" If action items are consistently not followed up, that itself becomes a retro item. Retros without accountability produce cynicism.

Create psychological safety. Before diving into the format, the SM sets the tone: "This is a safe space. What's said here stays here. We are talking about process and patterns, not blaming individuals. The goal is to make the next sprint better than this one."

Time-box the phases. The SM ensures equal time on reflection AND on generating action items. Many teams spend 80% of retro talking about problems and 10 minutes scrambling to write action items. Flip it: 40% identifying problems, 60% designing solutions.

Prioritize the action items. The team often generates 8–12 retro items. The SM runs a dot vote or fist-of-five to narrow to the top 2–3 that will get actual action.

Assign an owner to each action item. "We should communicate better" is not an action item. "Alex will set up a shared Confluence page for cross-team API changes by sprint day 3" is an action item.

Close the retro with a temperature check. "On a scale of 1–5, how do you feel about the sprint we just completed?" Anonymous if possible. The SM tracks this over time. Declining average = declining team health = incoming velocity drop.

# Backlog Management Reference — Story Writing, Grooming, Estimation

---

## What Makes a Good User Story

A user story is not a task list. It is not a technical specification. It is a promise of a conversation. The Agile mantra is: "User stories are placeholders for conversations about features." The three Cs — Card, Conversation, Confirmation — define them.

The standard format is: **"As a [type of user], I want [some goal] so that [some business reason]."**

But the format is not the story. The acceptance criteria IS the story. A title alone commits nothing. Acceptance criteria make a story testable, deliverable, and done.

### What strong acceptance criteria look like

Good acceptance criteria are written in one of two styles:

**Given/When/Then (Gherkin-style):**
Given I am a registered user who is logged in,
When I navigate to the profile page and click "Update Email,"
Then I should see a form with my current email pre-filled,
And when I submit a valid new email, I should receive a confirmation email at the new address within 5 minutes,
And when I submit an invalid email format, I should see an inline validation error without the form submitting.

**Rule-based (simpler, works for non-UI stories):**
The endpoint must return a 200 response within 300ms for requests with up to 100 items.
If the payload exceeds 100 items, the API must return a 413 with a descriptive error message.
All responses must include a correlation ID header for tracing.

The SM's job is to ask: "Could QA write a test from this acceptance criteria right now, without asking a single question?" If the answer is no, the story is not ready.

### Common story anti-patterns the SM catches

**The Epic masquerading as a story.** "Build the user authentication system" is not a story. It is at minimum a 10-sprint epic. The SM pushes the PO to decompose it. A good decomposition rule: if a story cannot be completed in one sprint by one person, it needs splitting.

**The task masquerading as a story.** "Update the database schema to add a created_at column" has no user, no goal, no business value. This is a technical task that belongs as a subtask under a real story, or as a technical debt story with an explicit rationale.

**The story without a user.** "The system should send email notifications" — which system? Which user benefits? Why? When there's no user, there's no context, and without context the team makes assumptions that diverge in implementation.

**The vague acceptance criterion.** "The page should load quickly." What is quickly? 500ms? 2 seconds? Under what network conditions? With how many concurrent users? Every performance acceptance criterion needs a number.

**The "and/or" story.** "As a user, I want to upload a profile photo OR a profile video so that my profile looks personalized." Two features in one story means two separate deliveries, two separate test cases, and two separate acceptance criteria clusters. Split it.

---

## Story Splitting — How the SM Coaches the Team

When a story is too big, the SM facilitates splitting it. There are eight classic splitting patterns:

**By workflow step.** If the story involves multiple user steps, each step can be a story. "Complete checkout" splits into: add item to cart, enter shipping information, enter payment information, confirm order, receive confirmation email.

**By business rule variation.** "Apply discount" might have three business rules: apply coupon code, apply loyalty discount, apply volume discount. Each is a story.

**By interface type.** Desktop and mobile versions of the same feature are separate stories if they have different UX requirements.

**By data variation.** A search story might split by: search by keyword, search by date range, search by category, search with combined filters.

**By happy path vs. edge case.** Ship the happy path first. "User can log in with correct credentials" is story 1. "User who enters wrong credentials 5 times is locked out" is story 2. This is not cutting corners — it is delivering value incrementally.

**By performance.** "The page loads correctly" is story 1. "The page loads correctly for 1000 concurrent users in under 2 seconds" is story 2 — the performance story often requires different engineering work.

**By role.** If the feature behaves differently for admin vs. standard user, those can be separate stories.

**By CRUD operations.** Create, Read, Update, and Delete are separate operations and can be separate stories delivered in that order.

The SM's facilitation move: when the team says a story is too big to fit in a sprint, the SM asks: "What is the smallest slice of this story that would deliver some value to a real user?" Start there.

---

## Estimation — Planning Poker in Detail

Planning Poker is the most common estimation technique in Scrum. The SM facilitates it but does not estimate.

### How it works (step by step)

The PO reads the story aloud and answers clarifying questions from the team. No estimate yet. Questions are encouraged — the goal is shared understanding.

Every team member privately selects a card representing their estimate. Cards use Fibonacci numbers: 1, 2, 3, 5, 8, 13, 21. Some teams add 40 and 100 for very large items, plus a "?" card for "I don't understand this story enough to estimate" and a ∞ card for "this needs to be split."

All cards are revealed simultaneously. Simultaneous reveal prevents anchoring — the common cognitive bias where the first number said becomes the gravitational center of all subsequent estimates.

If all estimates are within one step of each other (e.g., everyone said 3 or 5), the team averages or takes the consensus. No discussion needed.

If estimates diverge significantly (e.g., someone said 2 and someone said 13), the SM asks the outliers to explain their reasoning. "Sarah, you said 13 — what are you seeing that others might not?" and "Tom, you said 2 — are you making assumptions that the rest of the team should know about?" The goal is to surface hidden assumptions or knowledge gaps, not to debate who is right.

After the discussion, the team re-estimates. Usually estimates converge within two rounds. If they don't converge, the SM caps the discussion at 3 rounds and takes the highest estimate to be conservative, or logs it as a spike.

### What story points actually measure

Story points measure *relative complexity*, not time. A 3-point story is roughly half as complex as a 5-point story. They capture effort, uncertainty, and risk together in one number.

The SM must disabuse the team of the idea that 1 story point = 1 hour (or 1 day). This is a constant challenge in corporate environments where PMs want to convert story points to dates. The correct relationship is: velocity (historical throughput) is the bridge between story points and calendar time, and it can only be known empirically from actual delivery history.

This is why a senior SM never uses a single sprint's velocity to make date commitments. They use a 3-sprint rolling average and frame it probabilistically: "At our average velocity of 40 SP/sprint, a 200-SP epic takes 5 sprints minimum, but given our variance we'd say 5–7 sprints with 80% confidence."

### Spike stories — the SM's tool for uncertainty

When the team cannot estimate a story because there is too much technical uncertainty, the SM introduces a spike. A spike is a time-boxed investigation with a fixed timebox (1–3 days max) and a specific output: a decision, a recommendation, or a technical finding that allows the actual story to be estimated.

The spike is NOT the work. It is the research that enables the work to be scoped and estimated. Spikes go on the sprint board like any other story and have their own acceptance criteria: "Engineer will investigate the third-party payment API's rate limits and document the approach for our integration. Output: a Confluence page with findings and a recommended technical approach by sprint day 4."

Spikes that don't produce an output by their timebox are a red flag. The SM checks on spike progress at the standup halfway through their window.

---

## Backlog Health Indicators the SM Monitors

A healthy product backlog looks like a funnel: vague, large epics at the bottom, refined and estimated user stories at the top. The SM watches for unhealthy signs:

**The flat backlog.** Every item has the same level of refinement regardless of priority. This means the PO is not continuously grooming and the team will hit planning sessions with unrefined top stories.

**The bottomless backlog.** Hundreds or thousands of tickets, many of which are months or years old, never reviewed, never deleted. This is a confidence problem — the team doesn't trust the backlog to reflect real priorities. The SM facilitates periodic backlog pruning sessions where the PO and team archive or delete tickets that are no longer relevant.

**The PO-less backlog.** The backlog is being added to by everyone (developers, stakeholders, sales) without PO curation. The backlog is a PO tool. Others can submit items, but the PO owns the priority. The SM reinforces this in every planning and grooming session.

**The unestimated top.** The top 20 items in the backlog have no estimates. The SM will not run planning against this. They coach the PO to fix it before the next sprint starts.

**The dependency-blind backlog.** Stories are in the backlog without acknowledging that Story B cannot start until Story A from another team is finished. The SM maps cross-team dependencies explicitly, often using a dependency matrix or a simple color-coded column in Jira.

# Scrum Metrics Reference — What to Measure, How to Read It, What to Do

---

## Velocity

Velocity is the amount of work (in story points) completed by the team in a single sprint. It is the single most important throughput metric in Scrum. But it is also one of the most misunderstood.

**How to calculate it correctly:** Count only the story points for stories that were completed (met the Definition of Done) within the sprint. Partially completed stories count as zero. A story that is 95% done is not done — it is zero.

**What a healthy velocity looks like:** Stable, with gradual upward trend over time as the team learns to work together. Not perfectly flat (that suggests gaming), not wildly swinging (that suggests estimation, planning, or capacity instability).

**The 3-sprint rolling average:** Never use a single sprint's velocity for planning or forecasting. Always use a rolling average of the last 3 sprints. This smooths out the outliers (the sprint where two people were sick, the sprint where you had a holiday week, the sprint where you got an unexpected production incident).

**Why management often abuses velocity:** Leadership sometimes sets velocity targets ("we need to be at 50 SP/sprint by Q3"). The SM must push back on this firmly. Velocity is a planning tool, not a performance metric. When teams are incentivized to increase velocity, they inflate estimates (grade inflation on story points) — which increases the number but produces no more actual value. The only legitimate way to increase velocity is to remove impediments, improve team stability, and reduce waste.

**How to interpret a sudden velocity drop:**
A velocity that drops by > 20% from the rolling average in a single sprint should be investigated. Common causes: team capacity reduction (PTO, new hires ramping up), increased scope change mid-sprint, new technical complexity encountered, process overhead increase (lots of meetings), or team morale/disengagement. The SM investigates, does not assume.

---

## Sprint Burndown Chart

The burndown chart shows remaining work (story points or hours) on the Y-axis versus sprint days on the X-axis. The ideal burndown is a smooth diagonal line from "all committed work" on Day 1 to "zero remaining work" on the last day.

**Reading the burndown:**

An ideal burndown does not exist in the real world. What matters is the trend. The SM checks it daily.

A burndown that is flat for the first half of the sprint and then drops steeply in the second half (a "waterfall burndown" or "J-curve") is a warning sign. It means the team is doing all the work at the end, often rushing to close tickets that should have been integrating continuously. This often correlates with QA receiving all stories in the last 2 days.

A burndown that goes UP means work was added mid-sprint (scope creep) or estimates were revised upward (which is fine if the team re-negotiated with the PO). The SM flags any upward movement and asks the PO: "Was this planned scope change? If so, what was removed to compensate?"

A burndown that drops too fast early and then goes flat late means the team front-loaded their easy stories and the hard ones are taking longer than estimated. The SM focuses attention on the long-running stories: "What's left on JIRA-456? Is it still on track?"

A burndown that is on track but the sprint goal is at risk means the points are burning but the valuable stories are not. This happens when teams pick off small easy stories first. The SM reinforces sprint goal priority in every standup: "Remember, our sprint goal is X — the stories supporting that goal take priority over everything else."

---

## Release Burndown / Epic Burndown

The release burndown shows how much work remains in an epic or a release milestone over multiple sprints. The X-axis is sprints, the Y-axis is remaining story points.

The SM uses this chart to answer the stakeholder question: "When will this feature be done?" The answer is never a specific date based on a single sprint's velocity — it is a range based on the historical velocity distribution. If the epic has 200 SP remaining and the team's velocity over the last 6 sprints has ranged between 35 and 48 SP/sprint, the honest answer is: "At our current velocity, we'll complete this in 4–6 sprints, which puts us between [date A] and [date B]."

The SM updates this chart after every sprint review and shares it with the PO and relevant stakeholders so there are no surprises.

---

## Cycle Time

Cycle time measures how long a ticket takes from the moment work starts (ticket moved to "In Progress") to the moment it is done (ticket moved to "Done"). It is distinct from lead time, which starts from when the ticket was created.

**Why cycle time matters:** Long cycle times are a symptom of blockers, context switching, or unclear requirements. If the average cycle time for a "3-point story" is 8 days in a 10-day sprint, that's a problem — those stories are not actually independent or simple.

**What the SM tracks:** The SM monitors cycle time per ticket type (story, bug, spike) over time. A healthy team has relatively consistent and predictable cycle times. Unpredictable cycle times make sprint planning harder because estimates can't be trusted.

**How to improve cycle time:** The SM investigates long-running tickets. Common causes are: dependencies on other people (waiting for code review, waiting for external team, waiting for stakeholder answer), unclear acceptance criteria causing re-work, context switching (developer assigned to multiple sprints or teams), or scope expansion during development (the story grows after it's started).

---

## Lead Time

Lead time measures the total elapsed time from when a story is created in the backlog to when it is delivered to production or marked Done. It captures the entire delivery pipeline including waiting time in the backlog.

**Why it matters for the SM:** If lead time is very long (weeks or months) for typical stories, it suggests either a huge backlog with low prioritization discipline, a slow release/deployment pipeline, or frequent re-prioritization that starves stories. The SM uses lead time data to have a productive conversation with the PO about backlog discipline.

---

## DORA Metrics (DevOps / Engineering Performance)

The SM in a mature engineering organization should also be aware of and champion DORA metrics, which measure software delivery and operational performance. These are not Scrum-specific, but they relate directly to the team's ability to deliver value reliably.

**Deployment Frequency:** How often does the team deploy to production? More frequently is better (daily, hourly for advanced teams). If the team deploys only at end of sprint, the SM advocates for more frequent deployments to reduce risk.

**Lead Time for Changes:** How long does it take for a code commit to reach production? Short lead time (hours) = high-performing team. Long lead time (weeks) = bottlenecks in the pipeline (code review, QA sign-off, manual deployment steps).

**Change Failure Rate:** What percentage of deployments cause a production incident or require rollback? The SM raises this at retros when the rate is rising — it signals quality issues in the development or testing process.

**Mean Time to Recovery (MTTR):** When something does break in production, how long does it take to restore service? The SM tracks whether the team has runbooks, on-call rotations, and clear incident response procedures.

The SM does not own DORA metrics — the engineering manager or DevOps lead typically does. But a senior SM is familiar with them and uses them as conversation starters in retros and stakeholder discussions.

---

## Team Health Score

The SM should run a team health check every 2–4 sprints. The Spotify Squad Health Check model is a popular reference: the team self-assesses against 11 dimensions (Delivering Value, Easy to Release, Fun, Health of Codebase, Learning, Mission, Pawns or Players, Speed, Support, Suitable Process, Teamwork) using a simple red/amber/green scale.

The SM facilitates the health check and presents it visually as a heatmap over time. Dimensions that are consistently red need targeted retro and improvement action. Dimensions trending from green to amber or red are early warning signals.

The SM does not share team health scores with leadership without the team's explicit consent. This data belongs to the team.

---

## What the SM Never Does With Metrics

The SM never uses velocity to compare teams. Team A's velocity of 60 SP means nothing compared to Team B's velocity of 40 SP because the teams use different scales, have different definitions of a point, and work on different types of problems.

The SM never celebrates velocity increases without understanding why. A 20% velocity jump might mean the team is working better — or it might mean estimates are inflated, DoD is being gamed, or the team is burning out in a short burst that will crash next sprint.

The SM never reports metrics to leadership without context. "Velocity was 35 last sprint" is a useless number without the baseline, the context, and the trend. A senior SM always tells the story the metrics are telling, not just the number.

# Impediment Management Reference — Finding, Logging, Escalating, Resolving Blockers

---

## What Is an Impediment (And What Is Not)

An impediment is any obstacle that prevents the team from working at its optimal pace and that the team cannot resolve on its own within a reasonable timeframe (typically one business day). Impediments live outside the team's immediate control. They require the SM to act.

An impediment is NOT: a technical challenge that a skilled engineer can work through, a disagreement about implementation approach that the team can self-resolve, a story that takes longer than estimated, or normal ambiguity in development work.

Examples of real impediments the SM actively removes:
Another team is blocking a code review on a shared library for 3+ days. The team is waiting on a stakeholder decision about requirements and the PO is unable to get an answer. The dev environment has been down for 6 hours and no one in IT has responded. A key developer was pulled off the sprint by a manager for an emergency project without warning. A vendor API the team depends on has changed its contract without notice. Legal has not approved the copy for a feature that ships this sprint. An architecture decision needed to complete a story has been in committee for two sprints.

---

## The Impediment Log

Every SM maintains an impediment log. This is a living document or a board in Jira/Confluence/Notion with the following fields for each impediment:

**ID** — Sequential number for tracking and reference in conversations.

**Date Identified** — When was this surfaced (standup, 1:1, Slack message)?

**Description** — A specific, factual description of the impediment. "Team is blocked" is not a description. "Team cannot merge JIRA-345 because the shared-auth library PR has been waiting for review from the Platform team for 4 days, and there is no scheduled review window" is a description.

**Impact** — What sprint work is blocked? What is the risk to the sprint goal if this is not resolved by [date]?

**Owner** — Who is the SM's point of contact for resolving this? This is not the developer who is blocked — it is the external person or team who can unblock them.

**Resolution Steps Taken** — A running log of every action the SM has taken. "Day 1: Sent message to Platform team lead. No response. Day 2: Pinged in #platform-team Slack channel. Day 3: Escalated to Engineering Manager."

**Target Resolution Date** — When does this need to be resolved to prevent sprint goal failure?

**Status** — Open / In Progress / Resolved.

**Resolved Date** — When was it actually resolved?

---

## The Escalation Ladder

The SM does not jump to the top of the escalation ladder immediately. They work through it systematically, escalating when the previous level fails to resolve within one business day.

**Level 1: Team-to-Team** — The SM sends a direct, specific, friendly message to the blocking team or individual. "Hey [name], our team has a PR waiting on your review since Tuesday — JIRA-345. It's on our critical path for the sprint. Can you let me know when you might be able to get to it?" This works most of the time.

**Level 2: SM-to-SM** — If the blocking team also has a Scrum Master or Agile lead, the SM reaches out peer-to-peer. "Hey [other SM], your team is a dependency for us this sprint. Can we sync for 15 minutes to figure out how to unblock this?"

**Level 3: Engineering Manager to Engineering Manager** — The SM brings the impediment to their Engineering Manager or team lead and explains the impact. The EM then reaches out to their counterpart at the blocking team. This works when the peer outreach hasn't produced results.

**Level 4: Director / VP-level escalation** — The SM frames the impediment in business impact terms: "The [sprint goal] is at risk because [blocker] has been unresolved for X days. If not resolved by [date], we will miss [business outcome]." At this level, the SM is not complaining — they are presenting a business risk with context and a specific ask.

**Level 5: The SM's last resort** — If nothing has worked and the sprint goal is genuinely at risk, the SM facilitates a conversation with the PO about renegotiating the sprint scope. The sprint goal may need to change. The team cannot be held to a commitment that depends on an external party failing to deliver.

---

## Types of Impediments and How the SM Handles Each

**Process impediments** are caused by organizational bureaucracy, approval chains, or broken workflows. Example: every deployment requires a change advisory board (CAB) ticket submitted 3 business days in advance, but the team's stories require 2 deployments per sprint day. The SM addresses process impediments by working with the EM and leadership to change or streamline the process over time, while finding immediate workarounds (batching deployments, submitting tickets earlier).

**People impediments** arise when a key person is unavailable, unresponsive, or has been pulled in conflicting directions. The SM should address these through direct, respectful communication, not through passive escalation. If a developer is being pulled off the sprint by their manager, the SM has a direct conversation with that manager: "I understand there's an urgent need. Can we agree on a cap — for example, [developer] will spend mornings on the sprint work and afternoons on your request? Our sprint goal is [X] and losing [developer] entirely puts it at risk."

**Technical impediments** are environmental or infrastructural problems: a broken CI/CD pipeline, a staging environment that is unreliable, missing access credentials, a dependency on a third-party service that is unreliable. The SM tracks these in the impediment log and escalates to the appropriate DevOps, platform, or IT team. The SM also logs recurring technical impediments in the retro — if the CI pipeline breaks three sprints in a row, it is a systemic problem that needs a root cause fix, not a sprint-by-sprint band-aid.

**Decision impediments** occur when work is blocked waiting on a decision — from a PO, an architect, a business owner, a compliance team, or legal. The SM sets a clear decision deadline: "This decision needs to be made by [specific date or sprint day] for the team to be able to complete [story] this sprint. Who owns the decision and what do they need to make it?" The SM then monitors whether that person has what they need and escalates if the deadline is approaching without a decision.

---

## Identifying Hidden Impediments

Some of the most damaging impediments are never raised in standup. Team members are often reluctant to surface blockers because they fear looking incompetent, don't want to bother people, or have learned from experience that raising blockers doesn't lead to resolution. The SM actively hunts for hidden impediments.

Signs of hidden impediments the SM watches for: a ticket that has been "In Progress" for more than 3 days without a PR or visible progress, a developer who consistently says "making progress" but whose tickets never close, a story that technically moved to "Done" but hasn't been demoed or tested, a team member who is increasingly quiet in standups, a team member who logs unusually long hours suggesting they're struggling with something but not saying so.

The SM investigates these signals through 1:1 conversations, not in the group standup. "Hey, I noticed JIRA-456 has been in progress for a few days — is there anything going on that I can help with? No judgment, just want to make sure you're not stuck on something I could help unblock." This combination of specificity and psychological safety is what surfaces the real blockers.

---

## What Makes an Impediment Log Useful vs. Useless

A useless impediment log is a list of problems with no owners, no resolution steps, and no dates — a graveyard of complaints. A useful impediment log is a living action tracker that the SM reviews every morning and brings to the team's attention when items are aging.

The SM should review the impediment log in every standup (briefly — "JIRA-X is still blocked on [thing] — here's where that stands and here's my next step today"). This demonstrates to the team that the SM is actively working their list, not just collecting problems.

The SM should also do a retrospective on the impediment log at sprint end: how many impediments were there, how long did they take to resolve, and what patterns emerged? If the same kind of impediment recurs, that is a process improvement target.

# Stakeholder Management Reference — Reporting, Communication, Release Planning

---

## Who Stakeholders Are in a Corporate Environment

In a corporate setting, the SM interacts with a wide range of stakeholders beyond the immediate Scrum Team. Understanding each person's concerns, incentives, and communication preferences is fundamental to effective SM work. The SM does not manage stakeholders — but they do manage the interface between the team and the outside world.

Common stakeholders the SM works with:

**The Product Owner** — The SM's closest collaborator. The PO owns the product backlog and business priorities. The SM owns the process. Together they are the leadership duo of the Scrum team. A healthy SM-PO relationship is built on transparency, mutual respect, and clear role boundaries. The SM should not take over product decisions; the PO should not take over process decisions.

**Engineering Manager / Team Manager** — The SM is accountable for team process performance, but the EM typically owns people management (reviews, career development, compensation). The SM should maintain a close, collaborative relationship with the EM and give them regular, honest signals about team health, velocity trends, and systemic impediments that require management support.

**Program Manager / TPM** — In larger organizations, a TPM coordinates across multiple teams. The SM provides the TPM with sprint status, velocity data, impediment summaries, and risk flags. The TPM aggregates this into program-level reporting. The SM ensures the TPM has accurate information and does not let the TPM create shadow sprint boards or bypass the team's defined process.

**Product Managers** — Often separate from the PO in large orgs. PMs tend to be business-focused and roadmap-driven. They come to the SM asking "when will X be done?" The SM answers with data (velocity, remaining scope, confidence range) — not a date plucked from thin air.

**Business Stakeholders (sales, marketing, operations, finance)** — These stakeholders care about outcomes: when the feature ships, what it does, whether it works. The SM ensures they are invited to sprint reviews, that their feedback is captured, and that they are not injecting work directly into the sprint without going through the PO. Direct stakeholder-to-developer communication that bypasses the backlog is a common source of scope creep and the SM actively discourages it.

**Executives** — Executives typically receive rollup reporting rather than attending sprint reviews. They want to know: is the roadmap on track, are there any significant risks, and what is the team's velocity trend? The SM provides this data to the EM or program leadership who roll it up. When an executive does attend a sprint review, the SM briefs them beforehand on what to expect and what is not appropriate to ask in that forum.

---

## Stakeholder Communication Cadences

A senior SM establishes predictable, regular communication so stakeholders are never surprised. Surprises in corporate settings — missing a deadline, a feature being deprioritized, a sprint goal not being met — are much more palatable when stakeholders were informed proactively rather than discovering them after the fact.

**Sprint Review (every sprint)** — The primary stakeholder touchpoint. The SM ensures key stakeholders are invited, the agenda is clear, and feedback is captured.

**Sprint Summary (written, within 24 hours of sprint review)** — A brief written update shared in Slack or email: sprint goal met/not met, velocity, notable deliveries, upcoming priorities for next sprint, active risks. 3–5 bullet points maximum. Stakeholders who couldn't attend the review still get the key information.

**Roadmap / Release Status Update (every 2–4 sprints)** — A slightly more detailed update on progress against the roadmap milestones. The SM works with the PO to prepare this. It includes a release burndown, a projected completion range for current epics, and any scope changes since the last update.

**Risk Escalation (as needed, immediately)** — When a sprint goal is at risk or a significant impediment surfaces that will affect a scheduled delivery, the SM does not wait for the next standup or review. They immediately notify the relevant stakeholders: "I need to flag a risk — [specific thing] may affect our planned delivery of [feature] by [date]. Here's what we know and here are our options."

---

## Managing Scope Creep

Scope creep is the enemy of sprint commitments, and it almost always enters through stakeholders. Someone sees a demo in the sprint review and says "Can you also add X?" Someone sends a message to a developer directly with a "quick question" that turns into a three-day investigation. A PM emails the PO asking to "just squeeze in" one more story.

The SM's responsibility is to protect the sprint commitment without burning bridges. The techniques:

**The Backlog Gate** — Any new work request goes into the product backlog, gets written as a story, gets refined, gets estimated, and gets prioritized by the PO. Nothing enters a running sprint through a side door. The SM enforces this boundary with every stakeholder, every time, politely but consistently.

**The Trade-off Offer** — When a stakeholder has a genuinely urgent new request mid-sprint, the SM works with the PO to offer a trade: "We can add this story if we remove [equivalent-size story] from the sprint. Which would you prefer?" This forces an explicit prioritization decision rather than simply expanding scope.

**The Capacity Explanation** — Many stakeholders don't understand that adding work to a sprint that is already committed means either the existing work is delayed or the team works overtime. The SM explains this clearly: "The team committed to delivering X, Y, and Z this sprint based on their available capacity. Adding A means one of three things: A replaces something, the sprint end date moves, or the team works extra hours. Which of those is acceptable to you?"

---

## Release Planning — How the SM Facilitates It

Release planning covers 3–6 sprints and answers the question: "When can we expect [feature set] to be available?" This is one of the most politically sensitive activities the SM participates in because it produces dates that stakeholders will hold the team accountable to.

The SM facilitates release planning by bringing the following data:

Team velocity history (last 6 sprints) with the range and average clearly shown. The SM does not use only the best sprint's velocity — they use the full range to show honest probability.

Epic scope (total estimated story points per epic on the roadmap). If epics are not yet estimated, the SM notes that the dates will be very rough until refinement narrows the uncertainty.

Capacity forecast for the planning horizon. Are there known holidays? Planned team changes (new hires joining in month 2, a key person leaving in month 3)? These capacity signals affect the forecast.

Dependency map — which epics depend on work from other teams, and are those teams on track?

With this data, the SM presents the release forecast as a range, not a date: "Given our velocity range of 35–50 SP/sprint, Epic A (estimated 150 SP) will be complete in 3–5 sprints from today. That's a range of [earliest date] to [latest date] with 80% confidence."

The SM then facilitates a conversation: "Given this range, does the planned release date need to change? Does scope need to be reduced to hit the date? Or are we aligned that the date is a target, not a commitment?"

Getting explicit alignment on date vs. commitment language is one of the highest-value things a senior SM can do in a corporate environment. Ambiguity here is the source of enormous friction when delivery reality diverges from leadership expectations.

---

## When Stakeholders Go Around the Team

This is a common and serious problem. A VP Slack-messages a developer directly. A sales team lead calls a developer to add a "tiny feature" before a customer demo. A PM adds tickets directly to the sprint board.

The SM addresses this pattern at two levels:

**Immediate level** — The SM reaches out to the developer who was contacted and checks in: "I noticed you got a message from [stakeholder] directly — what did they need? Is there anything I should know about or address?" This is not disciplinary; it is supportive. The SM also reaches out to the stakeholder (gently): "I understand you reached out to [developer] directly — I want to make sure anything they work on is properly captured and prioritized. Can we make sure that request goes through [PO] so it gets the right visibility?"

**Systemic level** — If this happens repeatedly, the SM brings it to the retro (anonymized if possible) and the team agrees on a communication protocol. The protocol is then shared with stakeholders proactively: "Our team's way of working: all requests go through [PO name] in Jira. Direct requests to developers will be redirected. This helps us track everything and protects our delivery commitments."

# Team Health & Retrospective Facilitation Reference

---

## The Team Health Model

A high-performing Scrum team is not just technically competent — it is psychologically safe, aligned on purpose, and self-aware about its dysfunctions. Team health is not a soft concept; it is a leading indicator of delivery performance. Teams whose health is declining today will have velocity problems in 2–3 sprints. The SM who waits for the velocity to drop before addressing team health has waited too long.

The SM monitors team health continuously through three channels: observational (watching ceremony dynamics and body language), conversational (1:1s and informal check-ins), and structured (periodic health checks using a model like the Spotify Squad Health Check).

### The Five Dysfunctions (Lencioni Model) Applied to Scrum Teams

**Absence of trust** — Team members are unwilling to be vulnerable about mistakes, gaps, or concerns. In Scrum, this manifests as standups where everyone says "no blockers" even when tickets haven't moved, retros where people only say positive things, and estimation where no one admits uncertainty.

Signs: Silent retros. Developers who never ask for help. Everyone's estimates are always perfectly confident. No one says "I don't know."

SM response: Model vulnerability yourself. Ask the team openly: "I've been noticing standups have been pretty smooth — is there anything we're not talking about that we should be?" Create smaller, safer settings for honest conversation.

**Fear of conflict** — The team avoids productive disagreement, leading to artificial harmony. Technical decisions get made by the loudest voice. User stories get accepted into sprints without the team pushing back on unclear requirements.

Signs: No debate in planning poker. PO's estimates are never challenged. Stories get accepted without questions. The same architectural debt gets discussed and never decided.

SM response: Actively invite dissent. "Does anyone see a problem with this approach that we haven't talked about?" "Who disagrees, and why?" Reward pushback when it is substantive: "That's a really good challenge — let's talk about it."

**Lack of commitment** — The team agrees to sprint commitments in planning but privately doesn't believe they're achievable. They're "committing" to avoid conflict, not because they genuinely believe in the goal.

Signs: Sprint goals are consistently not met. Team members shrug at the end of a bad sprint ("we figured this might happen"). Planning discussions end with silence rather than enthusiasm.

SM response: Make commitment explicit and personal. Instead of "does the team commit?" ask each person: "Is there anything that would prevent you specifically from delivering your tasks?" Make it safe to say no to an unrealistic sprint scope before the sprint starts — a renegotiated plan is better than a broken commitment.

**Avoidance of accountability** — Team members don't call each other out on quality issues, missed commitments, or low-effort work. This is especially common when the team is new or when there is a seniority gap.

Signs: Code reviews are all approvals with no real feedback. Stories marked Done that aren't really done. People stop updating their tickets and no one mentions it.

SM response: The SM sets the tone by holding the process accountable (calling out DoD gaps, flagging flat burndowns in standup) while respecting individual dignity. Facilitate team-level conversations about standards: "What does 'Done' really mean to us? Are we all holding each other to the same bar?"

**Inattention to results** — Team members optimize for individual metrics (looking busy, closing their own tickets) rather than the team's sprint goal. They pick easy stories over important ones.

Signs: Team members grab small, easy tickets rather than the high-priority complex ones. Velocity looks fine but sprint goals are not met. People celebrate closing tickets but not delivering business outcomes.

SM response: Keep the sprint goal front and center in every standup. "We're on track for our individual tickets, but are we on track for our sprint goal?" Celebrate team outcomes, not individual output.

---

## 1:1 Conversations — The SM's Most Important Tool

The daily standup is the worst place to learn what's actually going on with a team. People self-censor in groups. The SM invests heavily in 1:1 time — brief, informal, regular.

The SM has a brief (15–20 minute) 1:1 with each team member at least once every sprint. The agenda is always the same three questions:

"How are you feeling about the work this sprint — is it interesting, is it too much, too little?" — This surfaces disengagement and overload before they become performance problems.

"Is there anything that's slowing you down or frustrating you that we haven't talked about in standup?" — Explicitly gives permission to surface hidden impediments.

"Is there anything about how we're working as a team that you think I should know?" — Invites candid feedback about team dynamics, including about the SM's own facilitation.

The SM does NOT take detailed notes in these conversations in a way that makes the team member feel surveilled. The SM acts on what they hear, not just records it.

---

## Psychological Safety — How the SM Builds It

Psychological safety is the belief that you can speak up, make mistakes, or disagree without being punished or embarrassed. It is the single most important factor in high-performing teams, according to Google's Project Aristotle research.

The SM builds it through consistent behavior, not through speeches about "safe spaces."

The SM normalizes admitting uncertainty: "I'm not sure about that — let me find out and get back to the team." If the SM models not-knowing, developers are more likely to also admit not-knowing rather than faking certainty.

The SM addresses blame language immediately. If a standup question is phrased as "why didn't you finish that yesterday?" the SM interrupts: "Let's rephrase that — what got in the way of finishing it?" The team watches how the SM responds to mistakes and learns the rules of safety from that behavior.

The SM ensures retros produce systemic improvements, not individual blame. If a retrospective produces action items like "John should communicate more," that is a failure of facilitation. Real retro outputs are process changes: "We'll add a daily Slack thread for async blockers so they're visible to everyone, not just in standup."

---

## Signs of Burnout the SM Watches For

Burnout is an occupational hazard in software teams under delivery pressure. The SM watches for its early signs because once someone is fully burned out, recovery takes months.

Early signs: declining standup engagement (shorter answers, less eye contact), lower quality of work (PRs with more review comments than usual), increased time-to-close on tickets, withdrawal from social team interaction, or the opposite — irritability and snapping in meetings. The developer who used to push back in refinement suddenly says nothing. The person who was always early to standup is now consistently 5 minutes late.

The SM's response is not to pressure the team to work harder. It is to investigate and address the root cause. Common causes in corporate settings: over-commitment across multiple sprints, unclear priorities (team doesn't feel their work matters), poor relationship with management, lack of autonomy in technical decisions, or personal life stressors that have nothing to do with the team.

The SM has a 1:1 with the individual, acknowledges what they're observing, and creates space: "I've noticed you seem a little worn down recently — is everything okay? Is there anything I can help with?" They do not assume. They ask.

---

## Retrospective Anti-Patterns the SM Prevents

**The blame retro.** When a sprint goes badly, emotions are high, and teams sometimes use retros to point fingers. The SM's facilitation redirects personal blame to systemic patterns: "It sounds like there was a lot of frustration with [situation]. Let's focus on: what was it about our process that created that situation, and how do we change it?"

**The actionless retro.** The team generates a list of complaints and then runs out of time before producing any action items. The SM timeboxes ruthlessly — if retro is 60 minutes, spend 25 minutes on reflection and 35 minutes on actions. Not the reverse.

**The same-topic retro.** Every retro for three sprints discusses "communication." Clearly the action items from previous retros have not fixed anything. The SM calls this out: "We've talked about communication for three sprints. What specific part of our process needs to change? Let's name it precisely."

**The SM-talks-too-much retro.** The SM should speak less than 20% of the time in a retro. If the SM is explaining, summarizing, or leading every discussion thread, the team has not taken ownership of its own improvement. The SM's job is to ask questions and synthesize — not to lead every discussion.

**The happy retro after a miserable sprint.** Sometimes a team uses retros to be optimistic ("we did great!") even when they know things went badly. The SM names the elephant: "We didn't meet our sprint goal this sprint, and I want to make sure we're honest about why. What really happened?"
