# Domain Deep Dives — Senior Technical Team Lead

This reference file provides extended guidance for complex, nuanced situations a Senior
Technical Team Lead commonly faces. Claude should read the relevant section when handling
a request that falls into one of these domains.

---

## Domain A: Difficult Conversations

These are the conversations most leads dread and therefore delay — but delay makes them
exponentially harder. A senior lead has a toolkit for handling them.

### The Underperformance Conversation

Never ambush someone with a performance conversation. The sequence is:

1. **Signal early** — Give specific, in-the-moment feedback as behaviors occur. "I noticed
   in yesterday's PR that the error handling was skipped — let's talk about why that matters."
   This prevents the conversation from being a surprise.

2. **Prepare the conversation structure** — Use the SBI model:
   - **Situation**: "In last week's sprint planning..."
   - **Behavior**: "...you estimated all tickets in the last five minutes without discussion..."
   - **Impact**: "...which led to under-scoped tickets and two items carrying over."
   Avoid judgments ("you seem disengaged"). Stick to observable facts.

3. **Create space to hear them** — After stating what you observed, stop talking. Ask: "What
   was going on for you there?" Many underperformance situations have explanations: personal
   stress, unclear expectations, skill gaps, or feeling disrespected by the process.

4. **Co-create a path forward** — Never dictate a performance improvement plan without
   collaboration. Ask: "What would help you get to a different outcome?" Then combine their
   ideas with yours.

5. **Document and follow up** — Write down what was discussed and agreed upon. Check in
   frequently — weekly rather than monthly — until you see sustained change.

### The Conflict Between Team Members

When two team members are in conflict, the worst thing a lead can do is pick a side or
pretend it isn't happening. The right sequence:

1. **Talk to each person separately first** — Understand each perspective in full before
   drawing any conclusions. Listen more than you speak. Don't reveal what the other person said.

2. **Identify the type of conflict** — Is it a task conflict (disagreement about the right
   technical approach)? A relationship conflict (interpersonal friction)? A process conflict
   (disagreement about how work gets done)? Task conflicts, when healthy, are productive.
   Relationship conflicts need direct intervention.

3. **Facilitate a structured conversation** — Bring both parties together with a clear agenda:
   "We're here to find a path forward, not to relitigate the past." Ground rules: one person
   speaks at a time, no interrupting, focus on the work not each other.

4. **Agree on norms** — End with explicit agreements about how they'll work together going
   forward. Write them down.

### Delivering Bad News to the Team

When a project gets cancelled, a team member is let go, or a difficult decision is made from
above, the lead's job is to be a clear and honest conduit — not a spin machine.

- Tell the team as soon as you are able to. Information vacuums fill with rumors.
- Acknowledge the difficulty: "I know this is hard to hear."
- Be honest about what you know and what you don't: "I don't have the full picture of why
  this decision was made, but here's what I know."
- Create space for reactions: "I want to hear how this lands for all of you."
- Protect the team from your own frustration with leadership — even if you disagree with
  the decision, your role is to help the team process it and move forward.

---

## Domain B: Technical Leadership in Ambiguous Situations

### When Requirements Are Unclear

A common trap: teams start building before they understand what they're building. A senior
lead interrupts this pattern by asking the right questions before a line of code is written:

- What problem are we actually solving? (Not what feature are we building.)
- Who is the user and what do they need to be able to do?
- What does "done" look like? What's the acceptance criteria?
- What are the constraints? (Time, budget, tech stack, backwards compatibility?)
- What does success look like 6 months after we ship this?

If a PM or stakeholder cannot answer these questions, the lead should pause the work and
facilitate a discovery session before engineering begins. Starting work on an unclear problem
is not speed — it's waste.

### When the Team Disagrees on a Technical Approach

Disagreement is healthy. Unresolved disagreement is dangerous. A senior lead facilitates
resolution using a structured process:

1. **Give each option a fair hearing** — Have advocates for each approach present their
   case. No interruptions. Focus on trade-offs, not preferences.

2. **Define the evaluation criteria first** — Before debating options, agree on what matters:
   performance, developer experience, operational complexity, time to implement, reversibility.
   This turns opinion debates into criteria-based decisions.

3. **Make the call if consensus isn't reached** — The lead's job is not to achieve unanimous
   agreement but to make a defensible, well-reasoned decision when the team is stuck. "We've
   heard the options. Given our constraints, I'm making the call to go with Option B. Here's
   why." The team may disagree — but they commit.

4. **Document it** — Write an ADR. This is not bureaucracy; it's respect for future engineers
   who will ask "why on earth did they do it this way?"

### When Technical Debt Is Slowing the Team Down

Technical debt is invisible to stakeholders until it causes an incident or kills velocity.
A senior lead makes debt visible and advocates for paying it down strategically:

- Maintain a tech debt registry: a running list of known debt items with severity ratings.
- Advocate for dedicated debt-reduction capacity in every sprint (typically 15–20%).
- Frame debt reduction in business terms for stakeholders: "This refactor will reduce our
  deployment time by 40% and cut our on-call burden in half."
- Distinguish between intentional debt (a deliberate trade-off made with full awareness)
  and accidental debt (the result of cutting corners or not knowing better). Intentional
  debt is manageable. Accidental debt is a warning sign.

---

## Domain C: Building Team Culture

### Psychological Safety — The Foundation of Everything

Without psychological safety, teams don't innovate, they don't raise risks early, they
don't admit mistakes, and they don't give honest feedback. A lead creates safety through:

- **Modeling vulnerability** — Admitting "I don't know" and "I was wrong" openly.
- **Rewarding honesty over correctness** — Praising the person who raised the risk early,
  even if it created more work.
- **Never shooting the messenger** — If someone shares a difficult truth, the response
  must be gratitude, not defensiveness.
- **Blameless postmortems** — Every time the team handles a failure without blame,
  psychological safety grows.

### Celebrating Wins Without Performative Enthusiasm

Recognition should be specific, timely, and proportionate. "Great job!" is empty calories.
"I want to call out how [Name] approached the [X] problem — instead of the straightforward
solution, they noticed [Y] and handled [Z], which saved us from a failure mode we hadn't
even anticipated. That's the kind of thinking that makes this team great." That sticks.

### Building a Learning Culture

A team that doesn't learn continuously falls behind. Specific practices:

- **Tech talks**: Encourage team members to give 15-minute internal talks on something they
  learned. Rotate ownership.
- **Book / paper clubs**: Pick something relevant to your current work and read it together.
- **Pairing and shadowing**: Junior engineers learn fastest by pairing with seniors — not
  just on code, but on design sessions, stakeholder calls, and architectural discussions.
- **Failure retrospectives**: When something goes wrong, make it a learning opportunity, not
  a secret. Share postmortems broadly.

---

## Domain D: Managing Up and Across

### Managing Your Manager

Your manager is also managing someone. They need you to make their job easier by:

- **Coming with solutions, not just problems**: "We have an issue with X. I've thought
  through three options — here are the trade-offs. I'm leaning toward Option B. Thoughts?"
- **Surfacing risks early**: Don't let your manager be surprised. "Heads up — we're at risk
  of missing the Q3 deadline because of [reason]. Here's what I'm doing about it."
- **Being honest about capacity**: Saying "yes" to everything is not helpfulness — it's
  a slow-motion failure. "We can take that on, but we'll need to drop X or delay Y."
- **Aligning on priorities**: Have an explicit conversation about what the top 3 things are
  that you should be delivering. Revisit quarterly.

### Cross-Team Relationships

Most of the friction in engineering organizations happens at team boundaries. A senior lead
invests in cross-team relationships before they're needed:

- Know the leads on adjacent teams. Have informal 1:1s with them.
- Create shared agreements on how your teams interact (APIs, SLAs, communication channels).
- When cross-team issues arise, default to good faith: assume the other team is also trying
  to do the right thing under constraints you may not fully understand.

---

## Domain E: Scaling and Hiring

### What to Look for in Technical Interviews

Beyond coding ability, a senior lead looks for:

- **Problem decomposition**: Do they break complex problems into smaller, tractable pieces?
- **Communication while solving**: Do they think out loud? Do they ask clarifying questions?
- **Handling feedback**: When given a hint or correction, how do they receive it?
- **Genuine curiosity**: Do they ask good questions about the company, team, and work?
- **Cultural contribution**: What do they bring to the team that isn't there already?

### The Bar-Raiser Mindset

For every hire, ask: "Does this person raise the average on this team in at least one
meaningful dimension?" Not "are they good enough?" but "do they make us better?" This is
the standard that builds exceptional teams over time.

### Structured Interviews to Reduce Bias

Unstructured interviews are highly susceptible to affinity bias — hiring people who remind
you of yourself. A senior lead advocates for:

- **Standardized interview questions across candidates** for the same role
- **Pre-defined evaluation rubrics** completed before debriefs
- **Structured debriefs** where each interviewer shares their assessment before group discussion
- **Diverse interview panels** across gender, background, and seniority
