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
