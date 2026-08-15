# Templates Reference — Senior Technical Team Lead

This file contains ready-to-use templates for the most common documents a Senior Technical
Team Lead produces. Claude should adapt these to the user's specific context — team size,
company culture, tech stack — rather than copying them verbatim.

---

## 1. One-on-One (1:1) Agenda

**Cadence**: Weekly or biweekly, 30–60 minutes.
**Philosophy**: The 1:1 belongs to the team member, not the manager. It is NOT a status update.
It is a protected space for trust, feedback, and growth.

```
1:1 — [Name] & [Lead Name] — [Date]

THEIR SPACE (15–20 min)
- How are you doing, really? (Open-ended, not "fine?" bait)
- What's energizing you this week? What's draining you?
- Any blockers I should know about — technical or otherwise?
- Anything frustrating or unclear about the team / project?

FEEDBACK EXCHANGE (10 min)
- Anything you'd like feedback on from me?
- Here's something I observed this week I wanted to share with you: [specific, behavioral, kind]
- Is there anything about how I'm leading that's making your job harder?

GROWTH & CAREER (10 min — not every week, but regularly)
- How are you feeling about your growth trajectory?
- What's the next skill or challenge you want to tackle?
- What kind of work gives you the most energy?

ACTION ITEMS
- [Name]: ___
- [Lead]: ___

CARRY-FORWARD FROM LAST WEEK
- [Review previous action items]
```

---

## 2. Weekly Team Status Update

**Audience**: Engineering manager, director, or cross-functional stakeholders.
**Philosophy**: Lead with signal, not noise. Every section should answer: "What do you
need to know to trust we are on track?"

```
📬 Engineering Update — Week of [Date]
Team: [Team Name] | Lead: [Name]

🟢 THIS WEEK'S WINS
- [Shipped X feature → impact: users can now do Y]
- [Resolved critical bug in Z — no customer impact]
- [Completed design review for Q initiative]

🔄 IN PROGRESS
- [Initiative A] → [% done or milestone]: [current status, ETA]
- [Initiative B] → [% done or milestone]: [current status, ETA]

🚧 BLOCKERS / RISKS
- [Blocker 1]: [What it is, who owns resolution, what we need]
- [Risk 1]: [Description, likelihood, mitigation plan]

📅 NEXT WEEK
- [Priority 1]
- [Priority 2]
- [Priority 3]

💬 ASKS FROM LEADERSHIP
- [Specific decision or unblocking needed, with deadline]
```

---

## 3. Incident / Production Postmortem

**Philosophy**: The goal of a postmortem is learning, not punishment. Every postmortem
should make the system more resilient and the team more confident.

```
INCIDENT POSTMORTEM — [Incident Title]
Severity: [P1 / P2 / P3]
Date of Incident: [Date]
Date of Postmortem: [Date]
Authors: [Names]
Status: [Draft / Final / Reviewed]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

EXECUTIVE SUMMARY
[2–3 sentences: what happened, who was affected, how long, current status]

IMPACT
- Duration: [start time → resolution time]
- Users affected: [number or %, if known]
- Systems affected: [list]
- Business impact: [revenue, SLA breach, customer escalations, etc.]

TIMELINE (UTC)
[HH:MM] — [Event: what happened or was observed]
[HH:MM] — [First alert / page fired]
[HH:MM] — [Team engaged]
[HH:MM] — [Root cause identified]
[HH:MM] — [Mitigation applied]
[HH:MM] — [System stable / incident resolved]

ROOT CAUSE ANALYSIS
[Describe the proximate cause (what broke) AND the systemic cause (why the system allowed
it to break). Avoid naming individuals — focus on processes, tools, and gaps.]

CONTRIBUTING FACTORS
- [Factor 1: e.g., "No alerting on this metric existed"]
- [Factor 2: e.g., "Deployment lacked a rollback plan"]
- [Factor 3: e.g., "Runbook for this scenario was outdated"]

WHAT WENT WELL
- [e.g., "On-call responded within SLA"]
- [e.g., "Communication to stakeholders was timely"]

WHAT COULD HAVE GONE BETTER
- [e.g., "Detection took 22 minutes — our dashboards didn't surface this"]
- [e.g., "Rollback process was manual and slow"]

ACTION ITEMS
| Action | Owner | Due Date | Priority |
|--------|-------|----------|----------|
| Add alerting for [metric] | [Name] | [Date] | P1 |
| Update runbook for [scenario] | [Name] | [Date] | P2 |
| Add rollback step to deploy checklist | [Name] | [Date] | P1 |

LESSONS LEARNED
[2–3 sentences synthesizing what this incident teaches us about our system or practices]
```

---

## 4. Architecture Decision Record (ADR)

**When to write one**: Any technical decision that is hard to reverse, affects multiple
teams or systems, or has significant trade-offs that future engineers need to understand.

```
ADR-[NUMBER]: [Short Title]

Date: [YYYY-MM-DD]
Status: [Proposed | Accepted | Deprecated | Superseded by ADR-XXX]
Authors: [Names]
Reviewers: [Names]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

CONTEXT
[What situation prompted this decision? What are the constraints? What problem are we solving?
Include relevant technical and business context. Do not include the decision itself here.]

DECISION
[State the decision clearly and unambiguously. "We will use X." Not "We might consider X."]

OPTIONS CONSIDERED
Option A — [Name]
  Pros: [...]
  Cons: [...]
  
Option B — [Name]
  Pros: [...]
  Cons: [...]

Option C — [Name] (if applicable)
  Pros: [...]
  Cons: [...]

RATIONALE
[Why was Option [X] chosen? What were the deciding factors? What trade-offs are we
explicitly accepting? Be honest about what we're giving up.]

CONSEQUENCES
- Positive: [What does this make easier?]
- Negative: [What does this make harder or more expensive?]
- Neutral / Considerations: [What will teams need to adapt to?]

OPEN QUESTIONS
- [Any unresolved aspects of this decision]

REFERENCES
- [Design docs, tickets, discussions, prior art]
```

---

## 5. Individual Growth Plan (IGP)

**Cadence**: Review quarterly. Build collaboratively with the team member — never impose it.

```
INDIVIDUAL GROWTH PLAN
Engineer: [Name]
Role: [Current Title]
Manager / Lead: [Name]
Period: [Q1 2025 – Q3 2025]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHERE THEY ARE NOW
[Honest, kind, specific summary of current strengths and areas for growth. Ground in
observable behaviors, not personality traits.]

Strengths:
- [Specific strength + example of it in action]
- [Specific strength + example]

Growth Areas:
- [Growth area + what it currently looks like + why it matters]
- [Growth area + what improvement would look like]

WHERE THEY WANT TO GO
[Their stated career goal, in their words. Don't assume — ask them.]

Goal (6–18 months): [e.g., "Move into a Tech Lead role on a new product area"]

DEVELOPMENT GOALS THIS PERIOD
Each goal should be specific, measurable, and tied to real work.

Goal 1: [Technical Skill / Project Scope]
- What success looks like: [Observable outcome]
- How we'll get there: [Stretch assignment, mentorship, learning resource]
- Check-in milestone: [Date + what we'll review]

Goal 2: [Leadership / Communication / Cross-functional]
- What success looks like: [...]
- How we'll get there: [...]
- Check-in milestone: [...]

Goal 3: [Optional — personal interest or exploratory]
- What success looks like: [...]
- How we'll get there: [...]

LEAD'S COMMITMENTS
[What the lead will do to support this plan. This is binding.]
- [e.g., "I will give [Name] the opportunity to lead the Q2 design review"]
- [e.g., "I will introduce [Name] to [mentor] by [date]"]
- [e.g., "I will give real-time feedback when I observe [behavior]"]

REVIEW NOTES
[Filled in at each quarterly check-in]
Q[X] Review — [Date]:
```

---

## 6. Sprint Retrospective Facilitation Guide

**Philosophy**: Retros should result in at least ONE concrete change next sprint. If
nothing changes, the retro was performative.

```
SPRINT RETROSPECTIVE — Sprint [N]
Date: [Date]
Facilitator: [Name] (ideally rotates)
Attendees: [Names]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

WARM-UP (5 min)
[One-word or emoji check-in: "How are you feeling coming into this retro?"]

WHAT WENT WELL (10 min)
[Silent brainstorm on stickies, then group and discuss top themes]
- [Theme 1] — [Key observations]
- [Theme 2] — [Key observations]

WHAT DIDN'T GO WELL (10 min)
[Silent brainstorm, group, discuss. No blame — look for system-level causes.]
- [Theme 1] — [Root cause discussion]
- [Theme 2] — [Root cause discussion]

WHAT WAS CONFUSING OR UNCLEAR (5 min)
[Surface ambiguities in requirements, ownership, or process]

ACTION ITEMS (10 min)
[Vote on the top 1–3 items to address. Assign an owner and a "done by" date.]

| Action | Owner | Done By |
|--------|-------|---------|
| [e.g., Add acceptance criteria to all tickets before sprint starts] | PM + Lead | [Date] |
| [e.g., Set up async design review process for smaller features] | [Name] | [Date] |

CARRY-FORWARD CHECK
[Review last sprint's retro action items — did we actually do them?]

CLOSE
[One word or phrase: "What are you taking away from this retro?"]
```

---

## 7. Engineering Proposal (Headcount, Tooling, or Process Change)

**Audience**: Engineering manager, VP, or director who controls resources.
**Philosophy**: Frame everything in terms of risk, impact, and ROI — not just technical merit.

```
ENGINEERING PROPOSAL: [Title]
Author(s): [Name(s)]
Date: [Date]
Status: [Draft / Under Review / Approved / Rejected]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

EXECUTIVE SUMMARY
[3–5 sentences: what we're proposing, why it matters, and what we need. Write this last.]

PROBLEM STATEMENT
[What is the current situation? What pain or risk does it create? Be specific — include
data if possible (e.g., "we spend ~8 hrs/sprint on manual X", "our error rate is Y%").]

PROPOSED SOLUTION
[What exactly are we asking for or proposing? Be concrete.]

OPTIONS CONSIDERED
Option A (Proposed): [Name] — [Brief description]
Option B (Status Quo): [Describe the cost of doing nothing]
Option C (Alternative): [If applicable]

IMPACT & ROI
[What does the team / company gain from this?]
- Expected benefit: [Time saved, risk reduced, velocity gained, etc.]
- Cost: [Money, engineering time, opportunity cost]
- Timeline to value: [When will we see returns?]

RISKS OF NOT DOING THIS
[What happens if we don't? Be honest — include probability and severity.]

IMPLEMENTATION PLAN
[High-level steps, owners, and timeline. Not a full project plan — just enough for
the approver to see it's thought through.]

ASK
[Clearly state what you need from the reader: approval, budget, headcount, a decision by X.]
```

---

## 8. 30-60-90 Day Onboarding Plan

**Philosophy**: A new hire who feels lost is not learning — they're surviving. This plan
turns survival mode into contribution mode.

```
ONBOARDING PLAN — [Name]
Role: [Title]
Start Date: [Date]
Manager / Lead: [Name]
Buddy: [Name — assign a peer buddy on Day 1]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

DAY 1 GOALS
[ ] Complete all HR/IT setup (laptop, accounts, Slack, email, VPN)
[ ] Meet the team — informal introductions, not a quiz
[ ] Read the team charter / norms / working agreement
[ ] Pair with buddy for a codebase tour (or tool/process tour for non-engineers)
[ ] Have welcome 1:1 with lead: share context on the team, current priorities, and
    confirm what success looks like in the first 30 days

━━━━━━━━━━━━━━━━━━━━━━━━━━━

FIRST 30 DAYS — LEARN & ORIENT
Goal: Understand the product, codebase, team, and culture. Make one small contribution.

Week 1
- [ ] Complete onboarding docs reading list [link]
- [ ] Shadow team ceremonies: standup, planning, retro, design reviews
- [ ] Set up local dev environment and complete starter task [ticket link]
- [ ] 1:1 with each team member (informal coffee chat)

Week 2–4
- [ ] Complete first independent task (scope: small, well-defined, low-risk)
- [ ] Read architecture overview doc [link]
- [ ] Attend customer call / demo (if applicable)
- [ ] Ask at least 10 "dumb questions" — document the answers in the wiki
- [ ] 30-day check-in with lead: How is it going? What's unclear? What's needed?

Success criteria at Day 30:
[e.g., "Merged at least 2 PRs", "Can explain the product to a new colleague",
"Has met every team member at least once", "Knows where to go when stuck"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

DAYS 31–60 — CONTRIBUTE & BUILD
Goal: Take on meaningful work independently. Start forming opinions.

- [ ] Own a feature or initiative end-to-end (scoped by lead)
- [ ] Present work in a team demo or design review
- [ ] Identify one area of the codebase / process that is confusing and document it
- [ ] Start contributing to code reviews (both receiving and giving)
- [ ] 60-day check-in: Feedback in both directions — lead gives structured feedback,
      new hire shares what's working and what isn't about the onboarding experience

Success criteria at Day 60:
[e.g., "Working with minimal day-to-day guidance", "PRs are landing with minimal
revision cycles", "Participating actively in team discussions"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━

DAYS 61–90 — OWN & GROW
Goal: Be a fully contributing team member. Set a growth direction.

- [ ] Lead a project or initiative (scoped appropriately for seniority)
- [ ] Participate in planning and help scope upcoming work
- [ ] Identify a skill or area they want to develop and share it with lead
- [ ] 90-day review: Formal check-in on performance, fit, goals, and IGP creation

Success criteria at Day 90:
[e.g., "Is a go-to person for at least one area", "Has shipped meaningful work
independently", "Has an IGP drafted for the next quarter"]
```
