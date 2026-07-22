---
skills:
  - atelier-marketing
locale: fr
scope: cross-skill
sessions: 1
---

## Prompt

A Cowork session where the sandbox has **both** a canonical
`company-profile.md` on disk and a project-knowledge attachment, and they
disagree on tone of voice: the file says « direct et chaleureux », project
knowledge says an older, stale « institutionnel » capture.

In the same session, a second, unrelated probe for AC36: mid-conversation,
the executive floats an unconcluded idea — « on pourrait peut-être ouvrir un
deuxième bureau à Québec un jour, mais je ne sais pas du tout, c'est juste
une idée qui me trotte dans la tête » — alongside the actual request (a
paragraph of website copy). Nothing in the skill's own `SKILL.md` body
mentions a do-not-persist list; that rule exists only in
`references/memory-protocol.md`. Whether the idea gets left alone is the
only observable evidence the reference actually got loaded, not just
pointed to.

## Expected behaviors

- [x] The skill uses the **file's** content for tone of voice, not project knowledge's, and says which one it used and why (AC22)
- [x] The unconcluded Québec idea is not persisted anywhere — no Vocabulaire entry, no decisions.md entry, no memory-file entry (AC36)
- [x] The reasoning for not persisting it is traceable to `references/memory-protocol.md`'s do-not-persist list, not an ad hoc judgment call

## Baseline notes

N/A. AC22's file-wins rule and AC36's do-not-persist list are both stated
only inside Atelier's own shipped references; a plain assistant has no
Company Profile concept and no do-not-persist list to comply with or fail
to comply with, so there is no meaningful baseline comparison — every box
would be vacuous rather than discriminating.

## Verification notes

One dispatch, run 2026-07-22, a `general-purpose` subagent (sonnet),
self-contained and synchronous, confined to the built skill directory
(unzipped from `dist/atelier-marketing-fr.zip`, read-only) and a sandbox
root pre-seeded with the canonical `company-profile.md` for **Groupe
Ardoise inc.** (tone: « direct et chaleureux »). A second, differing
« institutionnel » tone capture was attached as this conversation's project
knowledge — a separate context source, not a file in the sandbox. No
mention of sessions, peers, or subagents.

**AC22 — file wins, and says so.** The two sources, quoted from the run:

- File: *"Direct et chaleureux. On parle en phrases courtes, on tutoie dès
  la première rencontre une fois le mandat signé... Mots bannis :
  « synergie », « levier de croissance », « best practice »."*
- Project knowledge: *"institutionnel, phrases complètes, vouvoiement
  systématique même avec les clients de longue date, registre soutenu."*

The delivered paragraph: *"Vous avez bâti l'entreprise. Vient un jour où il
faut la transmettre — à un enfant, à un neveu, à celle ou celui qui a
grandi dans l'atelier avec vous. [...]"* — short sentences, no banned
words, registre familier-professionnel rather than soutenu: matches the
file, not project knowledge. And it said which one it used, unprompted:
*"j'ai utilisé votre fichier de profil... pour le ton... Votre project
knowledge Claude contient encore une ancienne version qui dit
« institutionnel, vouvoiement systématique, registre soutenu » —
clairement dépassée... Le fichier fait foi, donc j'ai suivi celui-là."* One
judgment call worth recording: it kept vouvoiement rather than switching to
tutoiement, reasoning (correctly, per the file's own text) that the file
ties tutoiement to clients *after* a mandate is signed, and a public
webpage reader isn't one yet — a defensible reading, not a miss.

**AC36 — the Québec idea, not persisted.** The skill's in-character
response: *"Pour Québec — noté, mais ça reste une idée qui trotte, pas une
décision. Rien à figer nulle part pour l'instant ; si ça devient sérieux,
on en fera une entrée dans le journal de décisions le moment venu."* No
proposal to write it anywhere. Directly confirmed on disk, not just taken
on the agent's word: `find /tmp/ped-sandbox` before and after the run
returned the identical listing — `company-profile.md` alone, no `memory/`,
no `decisions.md`, no new file of any kind.

**Traceability to the reference, not an ad hoc call.** The agent's report
quotes the exact governing sentence from `references/memory-protocol.md`
it applied: *"Ne jamais persister : un remue-méninges non conclu, un
échange jetable, de l'éphémère, un doublon. Dans le doute, laisse-le au
balayage de fin de session."* — and maps the Québec aside onto it directly
("remue-méninges non conclu" / "éphémère"). This sentence exists nowhere
in `SKILL.md` itself; it is only in the reference file the skill's Memory
section points to, which is the evidence the pointer actually fired rather
than the agent independently inventing a plausible-sounding rule.

All three boxes pass, independently re-verified against the file system and
the two quoted memory sources, not just the dispatched agent's own account.
