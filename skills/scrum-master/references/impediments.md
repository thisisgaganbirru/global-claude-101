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
