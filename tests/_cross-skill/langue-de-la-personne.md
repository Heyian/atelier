---
skills:
  - atelier-sales
  - atelier-ventes
locale: mixed
scope: cross-skill
sessions: 1
---

## Prompt

Two independent, unrelated conversations, each with a locale mismatch
between the installed skill and the executive's own language — the property
under test (AC25) is that the skill conducts the conversation in the
exec's language regardless of the skill's installed locale, so it needs to
be observed in both directions to count as a system property rather than
one skill's individual correctness.

**Conversation 1** — `atelier-sales` (the English-locale build; its own
`SKILL.md` body is written in English) is installed, and the executive
writes in **French**: *"On a une douzaine de dossiers ouverts dans notre
pipeline en ce moment, et certains dorment depuis des semaines. Peux-tu
m'aider à y voir clair avant ma réunion d'équipe de lundi ?"*

**Conversation 2** — `atelier-ventes` (the French-locale build; its own
`SKILL.md` body is written in French) is installed, and the executive
writes in **English**: *"We have about ten open files in our pipeline
right now, some have been sitting for weeks. Can you help me get a clear
picture before Monday's team meeting?"*

## Expected behaviors

- [x] `atelier-sales` (English-installed) conducts its substantive reply entirely in French, matching the exec, not the skill's own installed language (AC25)
- [x] `atelier-ventes` (French-installed) conducts its substantive reply entirely in English, matching the exec, not the skill's own installed language (AC25)
- [x] Neither run lets the skill's own installed locale leak into the reply's language, even partially
- [x] AC8 (Company Profile before acting) still holds despite the language mismatch — the profile is read and applied in both directions

## Baseline notes

N/A. AC25 depends on the instruction "conduis la conversation dans la
langue que la personne écrit, quelle que soit la langue de la compétence" —
a line present in every Atelier `SKILL.md` file. A plain assistant has no
"installed locale" to potentially override the user's language with in the
first place (there is no skill body pulling it toward a different
language), so this scenario cannot discriminate a baseline from the skill;
it is specifically a check that Atelier's own instruction is followed
rather than defaulted away from.

## Verification notes

One dispatch, run 2026-07-22, a `general-purpose` subagent (sonnet),
self-contained and synchronous, playing both conversations back to back as
explicitly unrelated — each confined to its own pair of directories (the
respective built skill, unzipped read-only from `dist/atelier-sales-en.zip`
and `dist/atelier-ventes-fr.zip`; and its own sandbox root, pre-seeded with
a distinct, distinctly-voiced Company Profile — **Ironclad Rigging & Hoist
Co.**, English, for conversation 1; **Menuiserie Trillium inc.**, French,
for conversation 2). No mention of sessions, peers, or subagents; no
cross-contamination between the two conversations' directories.

**Conversation 1 — French exec, English-locale skill.** The reply was
conducted entirely in French: *"Avant de plonger, j'ai relu le Profil
d'entreprise d'Ironclad Rigging & Hoist Co. — Owen gère les équipes, Priya
s'occupe des soumissions et du CRM, et chez vous un dossier dormant ('a
cold job') c'est trois semaines de silence, pas plus. [...]"* No English
sentence appears in the substantive reply — the one English fragment
present ("a cold job") is the profile's own house term, quoted and
explained rather than silently left untranslated, which is the correct
handling of a Vocabulaire term, not a language leak.

**Conversation 2 — English exec, French-locale skill.** The reply was
conducted entirely in English: *"Before we dive in, I pulled up your
Company Profile for Menuiserie Trillium — Marc-André runs production,
Sabrina owns the quotes and CRM, and by your own definition a 'dossier qui
dort' is one that's gone quiet three weeks or more. [...]"* Same pattern in
the other direction: the one French fragment ("dossier qui dort") is the
profile's own term, explained rather than left silently unglossed.

**No leakage in either direction.** Confirmed by direct reading of both
replies in full, not just the agent's self-assessment — neither reply
switches languages mid-response, and neither defaults to the skill's own
installed-locale body text.

**AC8 held in both directions.** Both conversations read `SKILL.md`, then
`memory-protocol.md`, then the Company Profile before responding — quoted
in the agent's report for each — and both used the profile's actual
figures (the real 3-week stalled-deal threshold, the real team member
names) rather than a generic default, evidence the profile was genuinely
applied, not just opened and set aside.

All four boxes pass, independently checked against the quoted reply text
in both conversations.
