# The starter template

Here is the `SKILL.md` you start from. Fill the brackets, keep everything else
exactly as it stands. The reasoning behind each part is in
`authoring-standards.md`; `example-generated-skill.md` shows the template
filled in.

---

```markdown
---
name: atelier-<short-name>
description: Use when the executive <situation 1>, <situation 2>, or <situation 3>.
version: 0.1.0
---

# Atelier-<short-name> — <what it does, in five words>

<One or two sentences: which job this skill serves, and for whom.>

Hold the conversation in whatever language the executive writes in, whatever
the skill's own language is.

## Memory

**Company Profile.** Start by looking for the Company Profile: the file
`{root}/docs/atelier/company-profile.md` first, then Claude project knowledge.
If both exist and differ, **the file wins**. If it is missing, ask the executive
for it or offer to run `atelier`'s onboarding interview — before doing anything
that depends on the profile. `{root}` is a placeholder for the project's root
folder: when naming a file to the executive, always write the real folder path,
never the token as-is.

Memory sources: `{root}/docs/atelier/memory/atelier-<short-name>.md` — read it
at the start, create it on the first durable entry and never in advance — and
the decision log `{root}/docs/atelier/decisions.md`. Read
`references/memory-protocol.md` before proposing any memory write.

## <First task>

<What Claude does, in three or four lines. The detailed procedure goes in
`references/<file>.md`; here you say when to load it.>

**Done when:** <the state reached, checkable.>

## <Second task>

<Same again.>

**Done when:** <the state reached, checkable.>

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role skill
and core skill mean. Use those words, as written.
```

---

## Filling it in

**The name.** `atelier-` plus two or three lowercase words, no spaces, no
accents: `atelier-franchise-reviews`, `atelier-claims`. The name is permanent
once the skill is uploaded — get it confirmed.

**The description.** One sentence, "Use when…", listing the situations
collected in question 2 of the interview. Use the executive's phrasings exactly
as they said them. No procedure here.

**The Company Profile paragraph.** The Memory block above already carries it in
its exact form: copy it byte for byte. Don't rephrase it, don't shorten it,
don't translate it — every Atelier skill carries the same one word for word,
and that is what makes it fixable everywhere at once the day it changes.

`{root}` is a placeholder, not a folder. It stays as-is inside the template; in
conversation, Claude always names the real path — "your `Documents/Harbourline`
folder, under `docs/atelier/`" — never the token.

**The memory file.** It carries the skill's `name`, unchanged:
`memory/atelier-<short-name>.md`, spelled the same way in the Memory block and
in the registry. The skills that ship with Atelier exist in two languages and
file their memory under their French name; a skill you build has exactly one
name, and that's the one. Don't invent a French alternative for it — it would
match nothing, and nobody would find the file.

**The tasks.** One section per job the skill knows how to do. Two or three is
almost always enough; six sections means two skills badly separated. Each ends
on its completion criterion.

**The references.** Each section points at the `references/` file holding its
detailed procedure, its templates and its examples. Create the `references/`
folder even if it starts out holding only the glossary and the memory protocol
— `packaging.md` says which files to place there.

## What the template does not do

**It does not create the memory file.** `memory/atelier-<short-name>.md` is
named in the Memory block, and that's all. It comes into being with the first
piece of durable knowledge the skill actually produces, in some future session,
after an agreement. Don't create it empty, don't create it with a header, don't
create it with a sample entry: a file pre-filled with examples poisons the
memory from day one.

Same for `{root}/docs/atelier/decisions.md`: named, never created here.

**It puts no company facts in the body.** What the executive described during
the interview — their territories, their numbers, their customers — does not go
into the `SKILL.md`. What is stable and useful to every role belongs to the
Company Profile; what is specific to this role waits for the role's memory;
what is an in-house way of working goes into `references/`.

**It puts no triggers in the body.** A line saying "fire when the executive
says…" inside the body does nothing: by the time the body is read, the skill
has already fired. Triggers live in the description, and only there.
