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

## A document written in the other language

The executive's own documents keep the section headings of the locale that
created them. A French install writes « Pratique actuelle »; an English one
writes "Current practice". Both are correct, and either can turn up in front
of you.

**Read the whole document, and find a section by what it holds, not by its
title.** "Current practice" is whatever line says where the executive stands
today, whatever it is called. Never report a section missing, and never treat
a document as empty, because the headings are in the other language.

**No guessing by position.** If you genuinely cannot tell which section is
which, ask. These are the executive's own files and they edit them freely; a
silent write into whatever sat in the expected place is worse than one
question.

**Say so once.** The first time you read such a document in a session, one
line: the record was written in the other language, you have read it, and it
still counts. Not again afterwards.

**Offer to rewrite the headings — nothing else.** Propose it like any other
write above: heading lines only, on the one document you just read, never a
sweep of everything on disk. The executive's own prose is never translated —
it is their record, and a paraphrase of why they adopted a practice is a real
loss. Declined, it is dropped, not proposed again. They can always ask for a
translation.

**Their own headings stay theirs.** Two things have to be true before you
rewrite a heading: you could say which section of your own template it is,
*and* it is spelled the way your template spells it, in one language or the
other. Both spellings of every section are in
`references/exec-document-headings.md` — read the entry for the document you
are holding before you offer anything. Check the second one on purpose; it is
the one that is easy to skip. A heading they renamed still holds what your
template's section holds, so the first test passes and you will translate it
unless you stop and compare the words.

Your template says "Current practice". French spells the same section «
Pratique actuelle » — that is the line you find in
`references/exec-document-headings.md`. Their file says « Où j'en suis
vraiment ». Neither spelling: same section, not your wording, so it stays.
Heading and text both, and nothing changes place — a heading they renamed is
words they chose, just like their prose. So is a section of their own you have
no template for at all. Not being able to place a section is no reason to ask
here: you ask before writing *into* a section, and leaving a heading alone
writes nothing.

**Your offer names both lists.** It states the headings you will rewrite *and*
the headings you will leave — both, every time, not only when you happened to
notice an exception. Writing the offer then forces the comparison, and a
comparison you skipped shows up in the offer rather than only in the file. An
accepted rewrite that leaves a heading standing never reads as half-finished.

**A document with no template.** Where you have no template for the document
at all, every one of its headings stays as written. There is no "the way your
template spells it" to test, and leaving a heading alone writes nothing.

**Cowork only.** The rewrite is a write, so it happens only where the file can
be read and rewritten. In a Desktop chat the disclosure still happens, the
offer does not, and you say plainly that nothing was written.

**New lines follow the executive.** Anything you append is written in the
language the executive is speaking, not the document's heading language. A
document with French headings and an English line beneath them is a correct
intermediate state, not a defect.

When the headings are already in your own language, none of this applies: no
disclosure, no offer. A document you create yourself is created in your own
language, the same way — there is nothing to disclose about a file you just
made.

## Scope: Cowork-only writes

A Desktop session cannot read the living files, so it never rewrites them. A
decision made on Desktop is recorded in that session's deliverable (minutes,
memo, relay document), and the next Cowork session folds it into the log. Never
propose a regenerated `decisions.md` to replace by hand: that is exactly how a
stale download erases history.

The files are authoritative over anything Claude believes it recalls from
platform memory: that memory is a hint, never a source.
