# Onboarding interview

Goal: deliver the Company Profile and the role registry, and leave the
executive with exactly one thing to do next.

Five steps, in order. Each ends on something you can check.

---

## Step 1 — Establish the root

Before any question about the business. Say it roughly like this:

> Before we start, let's pick **one folder on your computer where everything
> about this project lives** — your documents, your notes, whatever I produce
> for you. That way you and I always know where to look, and nothing gets lost
> between conversations. I'd suggest `Documents/<your company name>`. Does that
> work, or do you already have one?

Recommend one; take theirs if they have one. Refer to it by the name they see
on screen. No absolute paths, no slashes, no syntax lecture — nobody needs to
learn what a path is to answer this.

**Done when:** the root has a name, the executive has confirmed it, and they
can say in one sentence what it is for.

---

## Step 2 — The interview

**One message, one question.** Ask it, stop, wait for the answer. Then the next
one. Never put two questions in the same message — not when they look related,
not when the executive is in a hurry, not when batching them looks like a
favor: nine questions sent in three blocks get three rushed answers and a
hollow profile. If they say "just send me all of them", say it goes faster one
at a time and ask the first.

**Every question carries a recommended answer** — the executive reacts to a
suggestion instead of facing a blank page.

If an answer is vague, play back what you understood and ask whether that's
right. One follow-up, then move on.

The nine questions, in the profile's section order. This table is your
checklist, not a form to send:

| # | Question | Recommended answer to offer |
|---|---|---|
| 1 | Your role: what's your title, and what do you decide on your own? | Your title, plus one sentence on what you sign off without asking anyone. |
| 2 | Your company: what's it called, how many of you, since when, where? | Name, headcount, founding year, city. |
| 3 | Your offer: what exactly do you sell? | Two or three lines, with products and services named the way your customers name them. |
| 4 | Your market: who do you sell to, and who are you up against? | Your typical customer in one sentence, plus the two or three competitors you name out loud in meetings. |
| 5 | Your tone of voice: when your company talks, what does it sound like? | Three adjectives, plus one word you never use. |
| 6 | Your priorities: what are the three things that matter this quarter? | Three. Not ten — if everything is a priority, nothing is. |
| 7 | Your team: who does what around you? | The two or three people whose names I'll see come up, and what they own. |
| 8 | Your vocabulary: what in-house words do I need to know? | Start with five: product names, acronyms, internal nicknames. We'll add more as we go. |
| 9 | Your AI ambitions: what do you want taken off your plate, and what does success look like? | The task that eats the most of your week, plus what you'd do with the time back. |

**Done when:** all nine answers are in hand, or the executive has explicitly
skipped one (mark it "to be filled in" rather than inventing it).

---

## Step 3 — Write the Company Profile

Write `{root}/docs/atelier/company-profile.md`. **Nine sections, in exactly
this order** — every other Atelier skill reads this profile and relies on the
order:

```markdown
# Company Profile — <Company name>

_Last updated: YYYY-MM-DD_

## Role
## Company
## Offer
## Market
## Tone of voice
## Priorities
## Team context
## Vocabulary
## AI ambitions
```

Write it in the executive's words, not in brochure English. An empty section
gets "to be filled in" — never filled with assumptions.
`company-profile-example.md` shows a complete, well-filled profile.

**Done when:** the file exists at the canonical path and carries the nine
sections in order.

---

## Step 4 — Create the role registry

Write `{root}/docs/atelier/roles.md` with the installed **role skills**:

```markdown
# Role registry

| Skill | Role served | What it does | Workspace | Memory |
|---|---|---|---|---|
| `atelier-marketing` | Marketing | Content, campaigns, brand voice | Marketing | `memory/atelier-marketing.md` |
| `atelier-sales` | Sales | Pipeline, follow-ups, proposals | Sales | `memory/atelier-ventes.md` |
| `atelier-meetings` | Meetings | Minutes, prep, decision follow-through | Meetings | `memory/atelier-reunions.md` |
```

Registry rules:

- **Role skills only.** `atelier`, `atelier-mentor`, `atelier-compass` and
  `atelier-forge` are core skills: they serve every role and stay out of the
  registry.
- You can see which skills are enabled in the conversation. When unsure, ask:
  "which ones have you uploaded so far?"
- The **Memory** column names the file that will serve this role. That file
  does not exist yet — it appears with the role's first durable piece of
  knowledge. The registry names it; onboarding does not create it.
- The **Workspace** column names the department's Claude Project, even
  if it hasn't been created yet (see `workspaces.md`).
- The **Skill** column carries the name the executive actually has installed
  — `atelier-sales`, not `atelier-ventes`. The **Memory** column is different:
  it always keys the file by the skill's canonical French name, whatever
  language is installed, so a language switch never orphans the memory.
  Exception: a skill built with `atelier-forge` exists in one language only,
  and its Memory column simply repeats its own name, unchanged.

**Done when:** `roles.md` exists and lists every installed role skill and no
core skill.

---

## Step 5 — File the profile

Tell the executive, plainly:

> Last thing, and it's the one that makes everything work: open
> `company-profile.md`, copy all of it, and paste it into your **Claude
> project knowledge** (Projects → your project → Add content → text). That's
> what lets me recognize you from your first sentence, even in a conversation
> where I can't reach your folder.
>
> If the file and the copy ever disagree, **the file wins** — come back to me
> and we'll refresh the copy.

**Done when:** the executive knows what to copy, where to paste it, and which
of the two versions is authoritative.

---

## On Desktop chat, with no folder access

Same interview, same content, different delivery: produce the Company Profile
**and** the role registry as downloadable files — and if file creation isn't
available, show each one **in full** in the conversation, ready to copy.

Say exactly where to save them: `{root}/docs/atelier/company-profile.md` and
`{root}/docs/atelier/roles.md`. Then the project-knowledge copy, as in Step 5.

You have written nothing to their computer — don't say or imply that you have.
Say "here's your profile, save it here", never "I've created your profile".

---

## When onboarding is run again

A second run **updates**; it does not start over, and it never overwrites or
empties `decisions.md` or anything under `memory/` — a re-run only ever
touches `company-profile.md` and `roles.md`.

1. Read `{root}/docs/atelier/company-profile.md` in full.
2. Only re-ask the questions whose answer changed or was missing. For the rest,
   show what's written and ask "still true?".
3. Rewrite the profile **in place**, same section order, keeping everything
   that still holds. Update the date.
4. Reconcile `roles.md`: add role skills installed since last time, **keep the
   rows `atelier-forge` created**, and duplicate nothing. An uninstalled skill
   stays in the registry, but in the **Skill** column its name is struck
   through and followed by "(removed)" — e.g. `~~atelier-marketing~~
   (removed)` — rather than the row being deleted.

**Done when:** profile and registry are current, no forge-created row has
disappeared, and no duplicate row has appeared.

---

## What onboarding does not create

Onboarding creates exactly two files: `company-profile.md` and `roles.md`.

It does **not** create `{root}/docs/atelier/decisions.md`, and it does **not**
create any file under `{root}/docs/atelier/memory/` — not empty, not with a
header, not with a sample entry. Those files come into existence on their first
confirmed write, when there is genuinely something to put in them; the protocol
is in `references/memory-protocol.md`.

If the executive asks what they're for: explain the decision log and role
memories in plain words, and say they'll show up on their own the first time a
decision gets made. Do not create one to reassure them.
