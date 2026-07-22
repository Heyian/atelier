# Corporate memory protocol

Memory is a **distilled knowledge base, never a transcript of exchanges**. Two
regimes, one propagation rule.

## The two regimes

**Leadership decisions → dated log** (`{root}/docs/atelier/decisions.md`). Each
entry is **self-sufficient**: date, decision, and the reasoning in plain
language — readable in six months even if every other document has moved on. A
pointer to the deck, memo, or minutes is a bonus, never where the reasoning
lives. Entries are **immutable**: a revision is a **new entry** that references
the old one by its date. An entry is never edited or deleted.

**Durable knowledge → reconciled living state.** The Company Profile (including
its Vocabulary section), role memories, mentor progression, the role registry.
Writing means: read the file in full, integrate, deduplicate, rewrite distilled
— never accumulate raw. Reread the file one last time just before replacing it:
another session may have written in between, and a rewrite built on a stale
read erases their work without a trace.

## What goes where

| Item | Primary home | The same confirmed write must also |
|---|---|---|
| Settled leadership decision | entry in `decisions.md` | reconcile every living-state file the decision invalidates (profile, role memory, out-of-scope section of an active deck) |
| Stable company fact, preference, vocabulary | Company Profile | — |
| Role-specific business knowledge | that role's memory file | surfaces to the profile only the day a **second** role needs it |
| Adoption of an AI practice | `progression.md` (mentor) | — |

A decision is logged **and** its consequences reconciled in the same confirmed
write — never one without the other.

## Role memory

`{root}/docs/atelier/memory/<canonical-name>.md`, where `<canonical-name>` is
the skill's **French name**, regardless of the installed locale — so a locale
switch never orphans the memory. Created **lazily** on the first durable entry,
never pre-created empty. Read at skill startup, listed in the role registry.

Exception: a skill built with `atelier-forge` exists in one language only, so
its memory file simply keeps its own name, unchanged.

## When to write

**Triggers:** a decision is settled (the common case); durable knowledge
emerges; the executive says "note that down."

**Never persist:** an unresolved brainstorm, a throwaway exchange, anything
ephemeral, a duplicate. When in doubt, **leave it to the consolidation sweep**
at end of session.

**Propose before writing:** a short summary of what goes where, then wait for
agreement — except on an explicit "note that down." A declined item is dropped,
not proposed again later in the session. **This step holds even under time
pressure.**

**Consolidation sweep — a safety net, not the channel:** the relay runs it
before producing the handoff document, and proposes only what was **not
already** persisted during the session.

## Scope: Cowork-only writes

A Desktop session cannot read the living files, so it never rewrites them. A
decision made on Desktop is recorded in that session's deliverable (minutes,
memo, relay document), and the next Cowork session folds it into the log. Never
propose a regenerated `decisions.md` to replace by hand: that is exactly how a
stale download erases history.

The files are authoritative over anything Claude believes it recalls from
platform memory: that memory is a hint, never a source.
