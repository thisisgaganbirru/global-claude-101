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
