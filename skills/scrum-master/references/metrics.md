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
