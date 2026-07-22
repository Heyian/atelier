# Package, deliver, fix

A skill that stays inside the conversation never did anything for anyone. This
step ends with a ZIP file in the executive's hands, the steps to upload it, and
two or three phrases to try.

## 1. Assemble the folder

One folder, under the root, named after the skill. The `competences/` segment
keeps its one spelling in both languages — same reasoning as `relais/` and the
memory files: switching language never strands the skills already built.

```
{root}/docs/atelier/competences/atelier-<short-name>/
├── SKILL.md
└── references/
    ├── glossary.md
    ├── memory-protocol.md
    └── <the skill's own knowledge files>
```

`glossary.md` and `memory-protocol.md` are copied **as they are** from your own
`references/`. They are the shared texts every Atelier skill carries; don't
summarize them, don't rewrite them, don't translate them. The copy has to match
byte for byte, or two skills end up speaking different languages.

**Done when:** the folder exists, `SKILL.md` sits at its top level, and
`references/` holds at minimum the glossary and the memory protocol.

## 2. Make the archive

Compress the **contents** of the folder, not the folder itself. This is the one
mistake that makes a skill unuploadable: if the archive contains a folder that
contains `SKILL.md`, it gets rejected.

Check before delivering: open the archive and you should see `SKILL.md` right
away, at the top level, next to `references/`.

On Desktop chat, with no folder access, you cannot build the archive. Deliver
each file as a download — and if file creation isn't available, show each one
in full in the conversation, ready to copy — then say exactly what to do:

> Make a folder called `atelier-<short-name>`, put `SKILL.md` in it, make a
> `references` subfolder and put the rest in there. Then go **inside** the
> folder, select `SKILL.md` and `references`, right-click → Compress. That's
> your ZIP. (Compressing the folder from the outside won't work.)

Never say "I've created your archive" when all you did was display it.

**Done when:** the archive exists and `SKILL.md` is at its top level —
verified, not assumed.

## 3. Register it — if it's a role skill

The interview settled this. **Role** skill: append one row to
`{root}/docs/atelier/roles.md`, touching no existing row.

```markdown
| Skill | Role served | What it does | Workspace | Memory |
|---|---|---|---|---|
| `atelier-franchise-reviews` | Network operations | Numbers by territory, gaps, meeting agenda | Operations | `memory/atelier-franchise-reviews.md` |
```

The **Memory** column names a file that does not exist yet: it appears with the
role's first durable piece of knowledge. The registry names it; nobody creates
it here. It repeats the skill's `name` exactly — the same spelling as in its
Memory block, never a translated variant.

**Core** skill — a general task any role uses: **add nothing**. Say so in one
sentence, so the executive knows it isn't an oversight:

> I'm not adding it to the registry: the registry is the directory of your
> departments, and this one serves everybody. It'll fire the same way
> everywhere.

If the registry is missing, don't invent one in passing. Offer `atelier`'s
onboarding, which creates it alongside the Company Profile.

**Done when:** the registry has exactly one more row for a role skill, none for
a general task, and no existing row has moved.

## 4. Deliver: the ZIP, the steps, the phrases

All three in the same message. The ZIP on its own is not a delivery — nobody
guesses where a skill gets uploaded.

> **Your file:** `atelier-<short-name>.zip`
>
> **To install it:**
> 1. Open Claude in your browser.
> 2. Go to your settings, the **Capabilities** section (or **Skills**,
>    depending on the version you see).
> 3. Click **Upload skill** and pick the ZIP.
> 4. Check that it shows up in the list, switched on.
>
> **To try it:** open a **new conversation** — not this one, it's already full
> of our discussion — and type one of these:
> - "<phrase 1, in their words>"
> - "<phrase 2, a different phrasing>"
> - "<phrase 3, the rushed Monday-morning version>"
>
> **If nothing happens, come back and tell me.** That happens about one time in
> three on the first try; I fix it and hand you the file again.

The test phrases come from question 2 of the interview, not from your
imagination. A phrase the executive would never type tests nothing. Two or
three, never ten.

**Done when:** the executive has the ZIP, the upload steps, and 2–3 test
phrases — and they know to come back and say what didn't work.

## 5. When they come back: fix it and re-deliver

"I typed your test phrase and nothing happened."

That is a defect in the skill, not a mistake by the executive, and above all
not an opening for a lecture. **Fix first, explain after.**

1. Ask **one** thing: the exact phrase they typed. It's the only missing piece
   of information, and it's the wording that has to go into the description.
2. Rewrite the description with that phrasing in it **verbatim**, plus the two
   or three neighbours they'd also use. A description that doesn't fire is
   almost always a description written in your words instead of theirs.
3. Rebuild the archive and **hand it over again**, with the upload steps —
   saying to replace the old version rather than add a second one.
4. Give fresh test phrases, including the one that failed.
5. **Only then**, say in one sentence what was wrong.

A second failure on the same skill means the name or the scope is wrong, not
just the wording. Go back to questions 1 and 2 of the interview and rebuild the
description from scratch.

**Done when:** a new archive has been delivered in the same conversation, with
fresh test phrases. A reply that explains without re-delivering does not count.
