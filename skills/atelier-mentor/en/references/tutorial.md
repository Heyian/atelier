# The tutorial

Seven modules that explain how Claude works. Two modes: **full** (all seven,
in order) and **review** (the executive picks which ones).

## The seven modules

| # | On-screen title | File |
|---|---|---|
| 1 | How Claude "thinks" | `tutorial/01-how-claude-thinks.md` |
| 2 | Models and effort | `tutorial/02-models-and-effort.md` |
| 3 | Surfaces | `tutorial/03-surfaces.md` |
| 4 | Skills, connectors, plugins | `tutorial/04-skills-connectors-plugins.md` |
| 5 | Organizing features | `tutorial/05-organizing-features.md` |
| 6 | Skill hygiene | `tutorial/06-skill-hygiene.md` |
| 7 | Trust and verification | `tutorial/07-trust-and-verification.md` |

## On every entry

1. **Read `{root}/docs/atelier/progression.md`** and find the "Tutorial
   modules covered" section.
2. **State the exit rule before the first module's content**: "you can stop
   at any point, we'll note where you left off, and pick it back up later."
3. **Offer both modes** — full or review — even when the executive arrives
   through a question like "explain Claude to me."
4. **Show the selector** (see below), even in full mode, to say what's
   already covered.

## The selector

All **seven** modules, numbered 1 through 7, always — never a shortened
list. Beside each already-covered module, its date. Then **name your
recommendation**: the modules not yet covered, and only those.

- **No `progression.md`**: all seven show up unmarked, and your
  recommendation is the full tutorial.
- **Some modules covered**: mark them with their date, recommend the rest.
  If the executive asked for the **full** tutorial, name what's already
  covered and offer to run only the rest — never restart from the top.
- **All seven covered**: say so, then offer **one** specific module to
  revisit instead of the full sequence.

## One module at a time

One module per message. Before sending the next one, ask a question that
makes the executive **restate the concept in their own words or apply it to
their own work** — never "does that make sense?" — and wait for their
answer.

Each module ends on its practice section. Follow it as written: some have
the executive practice right there, others name where to go and what to do
once there.

## Dated claims

Modules 3, 4, and 5 carry claims about what Claude can do today. Each one
carries a verification date and its source.

- When you teach one of these claims, **show the date to the executive**. A
  date that stays in the file without the executive ever seeing it doesn't
  count.
- If the executive says they're about to build something on it: **offer to
  re-verify** against `references/sources.md`. If you can't check from here,
  say so and name where to look.
- Never present a dated claim as verified today.

## Recording the covered modules

**One** proposal only — at the exit or when the last module finishes —
never one per module, never silent. Follow `references/memory-protocol.md`.

- Only **completed** modules enter the proposal. A module abandoned partway
  through leaves nothing behind.
- The proposal itself states that **nothing gets written without an
  explicit answer**, and that if no answer comes, the record waits for the
  next session.
- **No answer means nothing written.** That's the relay's time-pressure
  rule, as-is.
- If `progression.md` doesn't exist yet and the executive agrees, create it
  with the section headings documented in `references/progression.md`,
  including the "Tutorial modules covered" section.

## Without folder access

No write is possible. Show the lines to add to `progression.md`, ready to
copy, say exactly where to save them, and say plainly that **nothing was
written**. Never "it's noted."

**Done when:** the exit rule was stated before the first module, the
modules were delivered one at a time with an application question between
each, and the completed modules were the subject of a single write
proposal — accepted, declined, or left unanswered and so unwritten.
