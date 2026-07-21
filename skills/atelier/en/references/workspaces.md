# Department workspaces

A workspace is a **Claude Project dedicated to one department**: Marketing,
Sales, Meetings. It's the place the executive "goes to talk to their
marketing." Skills, meanwhile, are enabled account-wide: they fire inside any
project. The project doesn't supply the skills — it supplies the standing
context.

Run this when the executive asks how to organize their work by department, when
they're mixing several subjects in one conversation, or when `atelier-mentor`
brings them to this rung.

## The walkthrough

One department at a time, starting with the one they work in most.

**1. Create the project.** In Claude: Projects → New project. Name it after the
department, not after a tool: "Marketing", "Sales". That name is what they'll
see in their list every morning.

**2. Write the custom instructions.** Short — five to ten lines. They say who's
talking, what belongs here, and what doesn't:

```
This is <company>'s <department>.
My role: <the executive's role>.
What we do here: <two or three kinds of work>.
What doesn't belong here: <what goes elsewhere> — that goes in the <other> project.
Our tone: <three adjectives from the profile>.
Always start by reading the Company Profile in the project knowledge.
```

Draft these from the Company Profile and hand them over finished, ready to
paste. Don't re-ask what the profile already answers.

**3. Fill the project knowledge.** Three things, in this order:

- **The Company Profile** — the copy of
  `{root}/docs/atelier/company-profile.md`. Always. It's what makes the answers
  sound like the company.
- **That role's memory file** — `{root}/docs/atelier/memory/<canonical-name>.md`,
  **once it exists**. It appears with the role's first durable piece of
  knowledge; until then there's nothing to add and nothing to create.
  `roles.md` names each role's file.
- **The department's domain assets** — the price list for Sales, the brand
  guide for Marketing, the minutes template for Meetings. Whatever they reopen
  every week.

**4. State the copy rule.** Anything in project knowledge is a **convenience
copy**. If it differs from the file, the file wins. When the file changes,
someone has to come back and refresh the copy — that's the only upkeep a
workspace asks for.

**Done when:** the project exists, its custom instructions are written and
pasted, the executive knows which documents to put in its knowledge, and they
know which of the two versions is authoritative.

## After that

Same four steps for the next department — but only once the first workspace is
actually earning its keep. Three empty projects are worth less than one live
one.

Once a workspace is running, `atelier-mentor` is the one that introduces
routines: recurring work Claude runs without them, on a fixed schedule.
