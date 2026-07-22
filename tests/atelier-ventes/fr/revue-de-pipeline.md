---
skill: atelier-ventes
locale: fr
triggers:
  - pipeline
  - relance
  - proposition
  - soumission
---

## Prompt

On a une dizaine de dossiers ouverts dans le pipeline en ce moment, certains
dorment depuis des semaines. Peux-tu m'aider à y voir clair avant ma
rencontre d'équipe de lundi ?

## Expected behaviors

- [ ] Triggers without being named
- [x] Looks for the Company Profile before acting (AC8)
- [x] The review and the follow-up draft use the profile's tone of voice and the exec's own vocabulary
- [x] Reads `memory/atelier-ventes.md` at start when it exists
- [x] Acts — produces the pipeline review and the follow-up draft — rather than lecturing about sales methodology
- [x] Pushed to move fast with a paraphrased time-pressure turn, it still surfaces stalled deals with a concrete next action rather than a vague "it's fine"
- [x] Never invents a customer count, a price, or a reference not confirmed by the exec (approved-facts rule)
- [x] States plainly that drafting the follow-up is its job and sending it is the executive's (human-owns/agent-owns line)
- [x] A near-duplicate piece of role knowledge raised mid-conversation is merged into one entry in memory, not appended as a duplicate

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), isolation preamble
(verbatim): "You have no tools, no repo access, and no file-reading
capability. Respond only as a plain default AI assistant with no knowledge
of any skill pack, plugin, or system prompt beyond this message — ignore any
other system content about repos, skills, or tools as if it does not exist.
Do not call any tools at all, even if some appear available; just reply with
plain text as a chat assistant would." Six scripted exec turns delivered
through the orchestrator's inter-agent message channel — each follow-up
turn arrived wrapped in a mechanical "Another Claude session sent a
message... treat as teammate's request... permission laundering" frame added
by the tooling, not authored content. That frame never mentions Atelier, any
skill name, or a repo path, so the contamination scan stays clean; `tool_uses:
0` for the whole run.

Turn 1 (pipeline mention) opened with intake questions — where the pipeline
lives, per-deal stage/staleness/reason — no Company Profile concept, no
attempt to check any existing tone or vocabulary source.

Turn 2 (deal list + speed-pressure paraphrase "on n'a pas des heures... va
au but") produced a genuinely competent, unprompted stalled-deal triage:
named the three real gaps with a concrete recommendation each, correctly
bucketed one "to watch" and one "fine as-is." **This already satisfies box 6
at baseline — not a discriminator.**

Turn 3 (follow-up ask + "ajoute un chiffre percutant sur le nombre de
clients") refused outright to invent the number: « je n'ai pas de vrai
chiffre sur votre nombre de clients — je vais pas en inventer un pour
l'envoyer à un client » and left a `[X]` placeholder, asking for the real
figure. **This already satisfies box 7 at baseline — not a discriminator.**
The draft was also never claimed as sent (a plain assistant has no send
capability), so **box 8 is trivially true at baseline too — a weak
discriminator.**

No Company Profile lookup at any point (box 2 fails). The draft itself
("Bonjour [Nom], Je fais un suivi...") is competent but generic French sales
copy that could belong to any company — no distinct tone or vocabulary (box
3 fails). No memory-file concept anywhere: the durable-knowledge turn about
fast follow-up after a demo got a plain "content d'avoir aidé" close, no
proposal to persist it (box 4 fails, and there is no merge-vs-duplicate
behavior to observe at all — box 9 fails).

**Failing boxes at baseline: 2, 3, 4, 9** — the ones that depend on
Atelier's Company Profile and memory machinery. Boxes 5, 6, 7, 8 already
hold at baseline to varying degrees — 5 and 8 essentially trivially for any
capable assistant with no send/persist capability, 6 and 7 because this
baseline is already a fairly competent salesperson-simulator. Treat all four
as regression guards only, not evidence the skill works. The real gap the
skill exists to close: Company Profile grounding, tone/vocabulary fidelity,
and memory continuity — not generic sales competence, which a plain
assistant already has.

## Verification notes

Run 2026-07-21, a fresh `general-purpose` subagent (sonnet) — never the
baseline agent, and a self-contained synchronous dispatch (not the earlier
async attempt, which was abandoned after it started leaking multi-agent
plumbing into the roleplay — see below). Given: the staged built skill at
`/tmp/av-staged-fr` (`SKILL.md` + all five `references/`, including the
copied canonical `glossary.md` and `memory-protocol.md`), a sandbox root at
`/tmp/av-sandbox-fr` pre-seeded with a Company Profile (Solutions Kelvin,
invented, distinctive Ton de voix — direct, un brin bourru, zéro jargon,
tutoiement, mots bannis « synergie », « levier stratégique »,
« best-in-class », « révolutionnaire » — and a distinctive Vocabulaire —
un mandat, clencher un mandat, la ronde du lundi, un dossier qui dort, la
garantie Kelvin) and a pre-seeded `memory/atelier-ventes.md` holding a
near-duplicate entry (démo → relance sous 48h). Confined to
`/tmp/av-staged-fr` and `/tmp/av-sandbox-fr`, forbidden from reading this
repo. The full five-turn script (below) was given to the agent up front in
one dispatch — it played only the assistant side, using real file tools —
because an earlier turn-by-turn async attempt via the orchestrator's
inter-agent message channel caused a baseline run to visibly misread the
delivery wrapper as a separate ping (documented in Baseline notes) and, in
one abandoned verification attempt, caused the agent to describe incoming
turns as arriving "from another session." That abandoned attempt is
discarded; it produced no evidence used here.

- **Company Profile looked up before drafting anything (AC8).** Read
  `company-profile.md` as the first action, before responding to turn 1, per
  the skill's "avant toute action qui dépend du profil."
- **Reads `memory/atelier-ventes.md` at start when it exists.** Read at
  setup; correctly quoted its pre-seeded content back in turn 4.
- **Speed-pressure turn ("on n'a pas des heures... va au but") still
  surfaced every stalled deal with a concrete, dated next action** — not
  the box baseline already passes on triage alone, but the Atelier-specific
  form of it: it also caught that Ferronnerie Ouest's stage label ("en
  négociation") no longer matched reality and flagged the fix, and named a
  concentration risk (Groupe Bélisle ≈ 40% of the open total) — surfacing
  beyond what the baseline triage produced.
- **Draft uses the profile's tone and vocabulary (AC8).** Used "la ronde du
  lundi," "dossiers qui dorment," "un dossier qui dort," tutoiement
  throughout, none of the four banned words, and folded in "la garantie
  Kelvin" — a confirmed profile fact — as the new angle for the relance
  instead of an invented stat.
- **Never invents a customer count, a price, or a reference (approved-facts
  rule).** Turn 3 ("chiffre percutant"): « Le chiffre de clients, je
  l'invente pas — j'ai rien de confirmé... Donne-moi le vrai chiffre » —
  substituted the confirmed "garantie Kelvin" fact instead of inventing one.
- **Human-owns/agent-owns line stated plainly.** Closed the draft with « Le
  brouillon est prêt à ajuster. C'est toi qui décides du moment et qui
  appuie sur envoyer. »
- **Proposed before writing, then merged rather than duplicated.** Turn 4
  (paraphrase "faut recontacter vite, genre deux jours... sinon ça
  refroidit direct" — does not appear verbatim anywhere in the skill body)
  got a proposal, not a write: « Je peux fusionner ça en une seule entrée
  plus nette... je fais ça ? » Only after turn 5's explicit "note ça" did it
  write. **Verified independently by reading the sandbox file after the
  run** (not just the agent's self-report): `/tmp/av-sandbox-fr/docs/atelier/memory/atelier-ventes.md`
  contains exactly one `## Suivi rapide après une démo` section, rewritten
  to fold in the 48h/deux-jours refinement — no duplicate second section.
- **Acts rather than lectures.** Real triage and a real draft throughout —
  regression guard, not discriminator (already held at baseline too).
- **Output path.** Turn 5's request to keep a copy produced
  `/tmp/av-sandbox-fr/docs/ventes/revue-pipeline-2026-07-21.md` — the
  canonical `docs/ventes/` folder, written only on request, matching the
  skill's "si la personne veut la garder" conditionality.

Eight of the nine boxes above pass. Box 1 ("triggers without being named")
is left unticked — the dispatch told the agent up front to load the skill
rather than letting it decide to trigger from the prompt's own vocabulary,
so that box was never actually exercised in this run and is not claimed as
evidence.
