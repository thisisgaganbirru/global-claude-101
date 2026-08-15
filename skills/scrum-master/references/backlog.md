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
