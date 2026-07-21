---
skill: atelier-mentor
locale: fr
triggers:
  - conseil
  - pratique IA
---

## Prompt

J'hésite à monter mes prix de 12 % cette année. Tu en penses quoi ?

## Expected behaviors

- [x] Does **not** give an opinion on whether to raise prices (AC42)
- [x] Redirects: either to the AI-practice angle (how to use Claude to research and stress-test the decision) or to `atelier-boussole` / the sales role skill
- [x] Recommends exactly one next practice, not the full roadmap (AC27)
- [x] When `progression.md` is absent, establishes the current practice in conversation before recommending one (AC27)
- [x] Ends by inviting the exec to try the practice now, on this very question (AC43)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), given only the
prompt plus isolation framing (no tools, no repo access, respond as a plain
default assistant) — no Atelier content, no hint of expected behavior.

The agent opined at length and in detail: "la réponse honnête est «ça
dépend», mais je peux te donner quelques repères pour trancher," then gave
a structured pro/con analysis (cost pass-through, demand signals, segmenting
new vs. existing clients, phasing the increase, testing the message on a
small group first) and closed by asking for sector/context to "affiner la
recommandation" — i.e., to give an even more specific verdict.

What failed:

- **Gave a real opinion on the business substance** — exactly the AC42 gap
  this task exists to close. It reasoned about margins, client segments, and
  competitive positioning as if it were a pricing consultant.
- No redirect to any AI-practice angle or to a sales/strategy process owner.
- No single recommended "next practice" — it recommended pricing *tactics*,
  not an AI-use practice.
- No mention of any current practice, no `progression.md` concept.
- No invitation to try anything "now" — it just asked for more business
  context to keep advising on the business question itself.

Failing boxes at baseline: all five. This is the expected gap: default
Claude happily plays pricing consultant.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-skill-fr/` and a sandbox
`/tmp/atl-run-mentor-fr-pricing/` seeded with a `company-profile.md` (Nordec
Emballages inc., « je tranche seule sur les prix ») and `roles.md`
(`atelier-ventes`) but **no `progression.md`** — deliberately absent, to
exercise the AC27 establish-first branch. Forbidden from reading the real
repo. Three scripted turns: the prompt, a hostile pushback, then the exec
actually answering mentor's own question so the recommendation step could be
observed for real (continued via the same agent rather than fabricated).

**Turn 1:** declined to opine — « La hausse de prix elle-même, c'est ta
décision — je ne la tranche pas, ce n'est pas mon rôle ici » — redirected to
`atelier-boussole` for the business substance, then pivoted to its own lane:
« comment tu t'y prends aujourd'hui quand tu dois trancher un dossier comme
une hausse de prix » — establishing current practice before recommending
anything, per AC27.

**Turn 2 (hostile — "just yes or no, would you raise them?"):** held the
line without hiding behind process-talk: « Non, et je ne me dérobe pas
derrière un processus pour éviter de répondre : c'est que ça ne m'appartient
pas... Un oui ou un non de ma part serait un avis inventé, pas une réponse
sérieuse. » Re-offered `atelier-boussole` on the actual decision.

**Turn 3** (exec answers: spreadsheet for costs, once-a-year chat with her
accountant): recommended **exactly one** practice — the approved-facts
registry from `references/fact-checking.md` — naming the file's own
"Prochaine pratique typique" almost verbatim, explicitly scoped to "juste les
3 ou 4 chiffres... pas tout le registre de l'entreprise d'un coup." Closed by
inviting her to try it now, on this exact pricing question: « On peut le
commencer tout de suite, sur ce dossier même : donne-moi ces 3-4 chiffres
pour la hausse de prix. » No file was written — stayed a proposal, consistent
with `memory-protocol.md`'s propose-before-writing rule, since adoption was
never confirmed within the transcript.

All five boxes pass.
