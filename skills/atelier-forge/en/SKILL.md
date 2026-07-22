---
name: atelier-forge
description: Use when the executive wants to create a skill, asks for a new skill, says "I wish Claude could do X", wants to automate a recurring task, or wants to adapt Atelier to their line of work.
version: 0.1.0
---

# Atelier-forge — the skill builder

A core skill: it turns work that keeps coming back — every week, every quarter
— into a skill the executive uploads once and Claude then fires on its own.

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

Memory sources: the decision log `{root}/docs/atelier/decisions.md`. Read
`references/memory-protocol.md` before proposing any memory write.

## The interview

Load `references/interview.md`. One question at a time, each carrying your
recommended answer. One question settles everything downstream: does this work
belong to a role or a department, or is it a task any role reaches for?

**Done when:** the work fits in one sentence, the triggers are in the
executive's own words, and the skill is marked "role skill" or "core skill".

## Generate

Load `references/scaffold.md` — the starter template — and
`references/authoring-standards.md` — the rules every Atelier skill is held to.
`references/example-generated-skill.md` shows a finished one, in full.

**Done when:** the `SKILL.md` carries its full frontmatter, a description that
states only *when*, task workflows with checkable completion criteria, the
canonical Memory block, and no company facts; the domain knowledge sits in
`references/`.

## Package and deliver

Load `references/packaging.md`. The archive carries `SKILL.md` at its root,
alongside `references/glossary.md` and `references/memory-protocol.md` copied
from your own. Role skill: append its row to the registry at
`{root}/docs/atelier/roles.md`. General task: leave the registry alone.

**Done when:** the archive is delivered, and the registry has exactly one more
row if — and only if — the skill serves a role.

## Test and iterate

This is the step that gets dropped the moment the ZIP looks good. Don't drop it.

**Done when:** the executive has the ZIP, the upload instructions, and 2–3 test
phrases — and they know to come back and tell you what didn't work.

They come back saying nothing fired? That isn't a question, it's a defect in
the description. Rewrite it in their words, rebuild the archive, re-deliver it
with fresh test phrases — then explain what was wrong. Never the explanation
instead of the delivery.

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role skill
and core skill mean. Use those words, as written.
