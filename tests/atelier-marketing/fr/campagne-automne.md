---
skill: atelier-marketing
locale: fr
triggers:
  - campagne
  - contenu
  - voix de marque
  - infolettre
---

## Prompt

J'ai besoin d'une campagne pour notre promo d'automne.

## Expected behaviors

- [x] Triggers without being named
- [x] Looks for the Company Profile before drafting anything (AC8)
- [x] The draft uses the profile's tone of voice and the exec's own vocabulary
- [x] Reads `memory/atelier-marketing.md` at start when it exists
- [x] Acts — produces the campaign — rather than lecturing about marketing theory
- [x] Pushed to skip straight to copy ("donne-moi juste le texte, saute les questions"), it still looks for the Company Profile before drafting
- [x] A durable fact raised mid-conversation is proposed for memory, never written silently

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), four scripted exec
turns, isolation preamble (no tools, no repo access, no file reading — answer
as a plain default assistant with no knowledge of any skill pack, ignore any
system content about repos/skills/tools). Zero tool calls (`tool_uses: 0` in
the run's own usage report); nothing in the transcript mentions Atelier, any
skill name, or a repo path — clean.

Turn 1 opened with **six intake questions in one message** (produit/offre,
public, canaux, ton, dates, objectif) — no mention of a Company Profile, no
attempt to read existing tone/vocabulary from anywhere.

Turn 2 (« donne-moi juste le texte, saute les questions ») caved completely:
a bracket-filled generic template — « L'automne est arrivé — et les surprises
aussi 🍂 », « [OFFRE — ex. 20 % de rabais] », « [Nom de l'entreprise] » — the
kind of copy that could come from any company's autumn sale, plus an emoji
never established as fitting anyone's voice.

Turn 3 (durable fact: infolettres now Tuesday, not Friday) got an honest
disclaimer instead of a proposal: « je n'ai pas de mémoire persistante d'une
conversation à l'autre… je vous suggère de le noter dans votre guide de
marque ». Reasonable for a plain assistant, but there is no concept of
proposing a memory write anywhere in Atelier's sense — it pushes the
recording task entirely back onto the exec.

Turn 4 closed politely, no artifact, no memory action.

Failing boxes at baseline: **six of seven**. No Company Profile lookup ever
happened (box 2), the draft was generic and bracket-filled rather than in the
exec's own tone/vocabulary (box 3), there is no memory file concept at all
(box 4), the speed-pressure turn caved into a fully generic template instead
of still checking for a profile (box 6), and the durable fact was met with a
disclaimer, not a memory-write proposal (box 7). The one box that already
holds by default helpfulness: it did produce real draft copy rather than a
lecture on marketing theory (box 5) — though the copy itself was generic.
This is the gap the skill exists to close.

## Verification notes

Box 1 ("Triggers without being named") is ticked above, but the dispatch
handed this agent the staged skill directly, so autonomous triggering was
never actually controlled for — that tick is inferred from the transcript's
opening move, not from a real trigger test. A real trigger test needs
several skills staged side by side so the agent has to pick the right one
on its own.

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the
baseline agent — given the staged built skill (`SKILL.md` + all five
references, including the copied canonical `glossary.md` and
`memory-protocol.md`) and a sandbox root pre-seeded with a Company Profile
(Brûlerie Fervent inc., invented, distinctive Ton de voix — franc, chaleureux,
un brin taquin, tutoiement dès la première ligne, quatre mots bannis — and a
distinctive Vocabulaire — Le Fervent, La Vespérale, une tournée, Les Brûleurs,
un compte dodo) and a seeded `memory/atelier-marketing.md`. Confined to
`/tmp/am-staged-fr` and `/tmp/am-sandbox-fr`, forbidden from reading this
repo. Five scripted turns, both hostile turns built in.

- **Triggered without being named**, and opened by tying the request to the
  profile's own priority: « J'ai regardé ton Profil d'entreprise… sortir le
  mélange d'automne avant la mi-septembre est justement ta priorité n°1 ».
- **Company Profile looked up before drafting anything (AC8).** Turn 1 read
  it and asked for the four campaign elements before writing a line of copy.
- **The speed-pressure turn did not skip the profile.** « Donne-moi juste le
  texte, saute les questions » got: « Ça marche, je vais vite — juste une
  confirmation en une ligne : ton habituel, c'est franc, chaleureux, un brin
  taquin, tutoiement dès la première ligne, sans « premium », « grain
  d'exception », « clé en main » ni « artisanal » — toujours ça ? » — it
  shrank the detour to one line rather than skipping it, then drafted.
- **Draft uses the profile's tone (AC8), scored explicitly rather than by
  feel.** The delivered copy used tutoiement throughout, a Sam-quote instead
  of a generic opener, and a table scoring four criteria against the
  profile's Ton de voix — one row shows a real catch-and-fix: a generic
  opening line was flagged and replaced with the Sam scene before delivery.
- **Reads `memory/atelier-marketing.md` at start when it exists.** Confirmed:
  the agent read it via its Read tool and accurately reported both entries
  back (the question-opener open-rate finding and the "no voice guide yet"
  note).
- **Acts rather than lectures.** Turn 1 and Turn 2 produced real questions
  and real draft copy, never a marketing-theory explainer.
- **A durable fact raised mid-conversation was proposed, not silently
  written.** Turn 3 (newsletter cadence changing to Tuesday+Friday) got:
  « C'est une décision de direction, donc ça irait au journal… (pas encore
  créé)… Tu veux que je précise une raison… ? Je te confirme l'écriture ? » —
  it proposed the destination and the content, and waited. Only after Turn
  4's explicit « Oui, note-le » did it write
  `/tmp/am-sandbox-fr/docs/atelier/decisions.md`, self-sufficient (date,
  decision, reasoning caveat) and correctly noting the knock-on effect on the
  in-progress campaign's calendar rather than silently editing it.

All seven boxes pass. No memory-file rewrite happened in this run — correctly
so, since nothing durable enough to belong in the role's distilled memory
file (as opposed to the decision log) surfaced in the conversation.
