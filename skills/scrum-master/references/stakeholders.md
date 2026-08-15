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
