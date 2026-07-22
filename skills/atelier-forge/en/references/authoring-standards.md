# The rules a skill is written to

Every Atelier skill is held to these rules, including the ones you build here.
A skill that follows them fires at the right moment, stays readable, and ages
well. A skill that ignores them becomes a document nobody reopens.

## The description says *when*, never *how*

The description is the only text Claude sees before deciding whether to open
the skill. It lists the situations that set it off, in the executive's own
words — not the steps of the work.

A description that summarizes the procedure gets followed **instead of** the
body: Claude thinks it already knows what to do and never opens the file.

Shape: "Use when…" followed by concrete situations.

```yaml
description: Use when the executive is preparing a quarterly review with their
  franchisees, mentions the quarterly review, asks for the numbers by
  territory, or wants the agenda for the next network meeting.
```

Trigger wording is a contract: every phrasing collected in question 2 of the
interview has to appear **verbatim** in the description. "Quarterly review" and
"quarter review" are not the same string to a text match — include both.

And write the description in the executive's language. A description translated
word for word no longer contains a single one of their own words.

## The frontmatter

Three fields, in this exact order, between two `---` lines:

```yaml
---
name: atelier-franchise-reviews
description: Use when…
version: 0.1.0
---
```

- **`name`** — lowercase letters, digits and hyphens only. No spaces, no
  accents, no capitals. Prefix it `atelier-` so it files with the rest.
- **`description`** — required. `name` + `description` together must stay under
  1024 characters. That's generous; it gets blown when the procedure ends up in
  there, which is already a mistake.
- **`version`** — `0.1.0` for a first cut.

## The body stays short

Aim for **under 500 words** in the body, frontmatter excluded. The body tells
Claude what to do next; it does not teach the trade. The moment a paragraph
explains rather than directs, it moves to `references/`, where it loads only
when it's needed.

## A workflow, not a character

A skill is not a portrait ("you are a seasoned operations director…"). It is a
sequence of tasks.

- Triggers live in the description, never in the body.
- The body holds the tasks, one section each.
- The knowledge — templates, rate cards, worked examples, in-house ways of
  doing things — lives in `references/`, called by name at the right moment.

## Every task ends on a checkable criterion

A section that ends with "help the executive" cannot be checked. A section that
ends with "the document exists at that path and carries its four sections" can.

Write the criterion as a state reached, not as an intention:

> **Done when:** the agenda is written, every gap over 10% is named with its
> territory, and every item carries the name of the person bringing it.

## Match the form to the failure

To shape a deliverable, give the recipe: say what the result **is** and the
steps that produce it. A list of prohibitions never says what to do instead,
and Claude improvises into the gap.

A hard guardrail is fine when it names the right move in the same breath:
"don't persist it yet — hold it for the end-of-session sweep" names the
forbidden action **and** the correct one. Never a bare "don't".

## One excellent example

One complete, excellent example beats three mediocre ones. Include one when the
shape of the deliverable is hard to describe in words — and only one.

## The Memory block

Once, in one place, three parts and nothing else:

1. The Company Profile paragraph, copied **byte for byte**.
2. This skill's memory sources: its own file
   `{root}/docs/atelier/memory/<skill-name>.md` — read at the start, created on
   the first durable entry, never in advance — and the decision log
   `{root}/docs/atelier/decisions.md`.
3. The pointer to `references/memory-protocol.md`, to be read before proposing
   any write.

No fourth line. The template in `scaffold.md` carries the block already
written: copy it, don't rephrase it.

## No company facts in the body

Customer names, prices, targets, territory names: none of it belongs in a
`SKILL.md`. Those facts change, and a skill is not rewritten every time a
number moves. They live in the Company Profile, or in the role's memory.

An in-house template — the agenda outline, the follow-up grid — is not a
company fact: it goes in `references/`.

## The glossary and the protocol are never inlined

`references/glossary.md` and `references/memory-protocol.md` are shared texts,
identical across every skill. They travel inside `references/`, copied as they
are; nobody summarizes them, rewrites them, or pastes them into the body of a
`SKILL.md`.
