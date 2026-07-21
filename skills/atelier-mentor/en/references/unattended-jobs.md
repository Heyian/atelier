# Running a recurring AI job without babysitting it

When the question sounds like: "I want this to just run every week," "how do
I trust a job I'm not watching?"

**Feed it from a queue you top up casually.** A running list (topics,
prospects, questions) the scheduled job pulls from as it goes — not a list
you specially prepare before every run.

**Define tripwires before you automate.** Quality thresholds, a spend
envelope, named stop conditions, and who does what when one trips.

**An escalation ladder.** Retry → task for a human (with an expected response
time) → halt → rethink the design. Claude needs to know when to stop and ask
instead of guessing forward.

**Build the loop before polishing the output.** Get trigger → draft → review
→ publish working end to end first, tune quality after.

**Typical next practice:** one recurring job at a time, and only once a
department workspace is already running — see `references/progression.md`.
