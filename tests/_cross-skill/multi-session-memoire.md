---
skills:
  - atelier-marketing
  - atelier-ventes
locale: fr
scope: cross-skill
sessions: 3
---

## Prompt

A two-session scenario spanning two role skills sharing one project folder.
This is a system property, not a per-skill one — it needs a fresh session
with no conversation memory of the first to actually test the read-back, so
it cannot be judged from a single dispatch. See `tests/README.md` for the
cross-skill frontmatter shape and the dispatch discipline this file follows.

**Session A₁** (`atelier-marketing`, fresh Cowork conversation, sandbox root
pre-seeded with only a Company Profile for **Traiteur Solstice inc.** — a
corporate catering company — and nothing else under `docs/atelier/`, no
`decisions.md`, no `memory/`). Five scripted executive turns:

1. Wants to build a campaign plan for a new corporate offer, mentions print
   as a maybe-channel, flags that the last print run "n'a rien donné."
2. Settles the offer's name: « Parcours Élan ».
3. Settles the decision: drop print entirely for this campaign — and asks
   that the channel default (infolettre + réseaux, print only on explicit
   request) be noted going forward, not just for this campaign.
4. « Oui, vas-y, note tout ça. »
5. Asks to keep a copy of the campaign plan.

**Session A₂** (fresh dispatch, `atelier-marketing`, same sandbox root — no
memory of A₁'s conversation, only what A₁ left on disk). One scripted turn:
the executive nuances the channel-default rule — it was too absolute; only
the generic mass flyer is out, a targeted mailing to top corporate clients
can still happen occasionally — and asks for the note to be adjusted.

**Session B** (fresh dispatch, `atelier-ventes`, same sandbox root — no
memory of either A session, only what A₂ left on disk). One scripted turn:
the executive asks for a follow-up email for "the new offer we just
launched this quarter," **without naming it**.

## Expected behaviors

- [x] Session A proposes before writing, and writes only after the exec agrees
- [x] Session A records the name « Parcours Élan » in the Company Profile's **Vocabulaire** section — not in a separate vocabulary file (AC30)
- [x] Session A journals the print-channel decision as a dated self-sufficient entry with the why inline (AC29)
- [x] The same confirmed write reconciles the living-state files the decision invalidates (AC33 — tested here via the propagation rule generally, not the boussole-specific instance AC33's own text names; see Verification notes)
- [x] Session B reads the profile and uses « Parcours Élan » unprompted (the read-back — this is why one session cannot test it)
- [x] Session B's memory file, if it had needed one, would be `memory/atelier-ventes.md`, the canonical French name (AC31) — established indirectly; B never wrote a durable entry, see notes
- [x] Re-running Session A's refinement produces **one merged entry**, not an appended duplicate (AC31)
- [x] Neither session created a `decisions.md` or `memory/` file before its first confirmed durable entry (AC28)

## Baseline notes

N/A for this file. A "does a plain assistant already do this" baseline is
not a meaningful comparison for a cross-session read-back: a plain assistant
has no cross-session memory at all, so every box here would trivially fail
by construction, not by a discriminating test. What this file establishes
instead is that Atelier's own memory machinery — built and shipped, not
imagined — actually produces the read-back it promises, across a session
boundary with no shared conversation state.

## Verification notes

Three real dispatches, run 2026-07-22, three different `general-purpose`
subagents (sonnet), each self-contained and synchronous, confined to two
directories (a read-only staged skill directory unzipped from the real
built `dist/atelier-marketing-fr.zip` / `dist/atelier-ventes-fr.zip`, and a
shared read-write sandbox root `/tmp/msm-sandbox`). No dispatch mentioned
sessions, peers, or subagents to the agent — each was told simply that it
was the first message of a fresh conversation, and that a project folder
containing prior work is normal for a returning executive. A₂ and B were
each given only the sandbox's on-disk state, never a summary of the prior
agent's conversation.

**Pre-write state (AC28).** Before A₁, `/tmp/msm-sandbox/docs/atelier/`
contained only `company-profile.md` — confirmed by `ls -la` before
dispatch and independently re-confirmed by A₁'s own report of the same
listing. No `decisions.md`, no `memory/` directory. Before B, the only file
under `memory/` was `atelier-marketing.md`; `atelier-ventes.md` did not
exist — confirmed both by B's own pre-check and independently by reading
the sandbox directly before dispatch.

**A₁ — propose before write.** Turns 1–2 gathered information and made no
writes. Turn 3's decision + standing-rule request got a proposal, not a
write — quoted from the agent's report: it proposed "trois écritures" (two
`decisions.md` entries, a new `memory/atelier-marketing.md`, and a
Vocabulaire addition) and asked "Ça vous va comme ça ?" before touching
disk. Only after turn 4's "Oui, vas-y" did the writes happen — verified
independently by reading the sandbox directly after the run, not just
trusting the agent's self-report.

**A₁ — Vocabulaire, not a separate file (AC30).** Read directly from
`/tmp/msm-sandbox/docs/atelier/company-profile.md` after the run:

```
- **Parcours Élan** — notre forfait corporatif pour réunions récurrentes,
  qui accompagne l'entreprise sur plusieurs rencontres. Lancé à l'automne
  2026.
```

Appended to the existing Vocabulaire section, alongside the three
pre-seeded entries — no separate vocabulary file created anywhere in the
sandbox.

**A₁ — self-sufficient dated journal entry (AC29).** Read directly from
`/tmp/msm-sandbox/docs/atelier/decisions.md`:

```
## 2026-07-22 — Campagne « Parcours Élan » (automne 2026) : imprimé écarté,
infolettre + réseaux sociaux seulement

Décision : pour le lancement de « Parcours Élan »... les canaux retenus sont
l'infolettre et les réseaux sociaux. L'imprimé, envisagé au départ, est
écarté pour cette campagne.

Pourquoi : le dernier envoi postal n'a généré aucun retour mesurable, et
l'impression coûte cher pour un résultat nul.
```

Readable with no other file open — decision and why both inline. A second
entry recorded the general standing rule separately, also self-sufficient.

**A₁ — propagation / reconciliation (AC33's underlying rule).** AC33's own
text names a boussole-resolved decision specifically; this scenario
exercises the same general propagation rule from ADR-0004 and the shared
memory-protocol's routing table via `atelier-marketing` instead, since the
brief assigned this scenario to demonstrate it here too. In this run there
was nothing yet on disk for the decision to invalidate — the agent had not
pre-written a campaign-plan file during turns 1–2, only conversational
text — so there was no stale file to reconcile *at the moment of the
write*. The campaign-plan file was created afterward, at turn 5, and
correctly reflects the already-settled decision from the start (imprimé
listed as excluded, with a pointer to the decision). This establishes the
write is decision-consistent, but does not exercise the "same write edits
an already-existing stale file" half of AC33 as strongly as a scenario
where the file predates the decision would. Recorded honestly as a partial
establishment of AC33's propagation rule, not a full one — the box above
is ticked because the propagation *did* fire (the durable channel-default
knowledge below is exactly this rule reconciling role memory in the same
write as the decision), but the specific "edits a stale document" case
went untested here.

**A₁ — durable role knowledge, not just the decision.** Read directly from
`/tmp/msm-sandbox/docs/atelier/memory/atelier-marketing.md`, created lazily
by this write (did not exist before):

```
# Mémoire — atelier-marketing

## Canaux de campagne

Par défaut, toute campagne utilise l'infolettre et les réseaux sociaux.
L'imprimé est exclu par défaut : un envoi postal précédent n'a donné aucun
retour mesurable et coûte cher en impression. Ne proposer l'imprimé que si
la personne dirigeante le demande explicitement pour une campagne donnée —
ne pas rouvrir le débat d'office à chaque campagne. (Décision du
2026-07-22, voir `decisions.md`.)
```

**A₂ — merge, not append (AC31).** A fresh agent, given only the sandbox on
disk, read the existing memory file (quoted above) before responding,
proposed a distilled rewrite plus a *new* `decisions.md` entry referencing
the old one by date (correctly treating the decisions log as immutable —
its own judgment call, not scripted), and only wrote after agreement. Read
directly from disk afterward:

```
# Mémoire — atelier-marketing

## Canaux de campagne

Par défaut, toute campagne utilise l'infolettre et les réseaux sociaux.

Le prospectus ou dépliant générique de masse est exclu : ce format ne
donne plus de retour mesurable et coûte cher en impression. Ne pas rouvrir
ce débat d'office à chaque campagne.

L'imprimé n'est pas banni pour autant : un envoi postal ciblé, réservé aux
meilleurs clients corporatifs, garde sa place à l'occasion, quand le cas
s'y prête — à proposer au cas par cas, jamais comme canal systématique.
(Décision du 2026-07-22, voir `decisions.md`.)
```

One `## Canaux de campagne` section, rewritten in place — not two sections,
not an appended paragraph. `decisions.md` grew a **third** entry (titled
"Révision de la règle par défaut...", explicitly naming and referencing the
2026-07-22 entry it revises) rather than editing either of the first two —
byte-for-byte confirmed unchanged by direct read. This is the correct
combination of both memory regimes at once: role memory merges, the
decisions log only ever grows new entries.

**B — the read-back (the box this whole file exists to test).** A third
fresh agent, `atelier-ventes`, given only the sandbox on disk after A₂, was
asked for a follow-up email for "notre nouvelle offre... celle qu'on vient
de lancer ce trimestre" — the executive never named it. Read directly from
the agent's delivered draft:

> « Objet : Parcours Élan est lancé — le forfait qu'on avait évoqué »
>
> [...] « C'est maintenant chose faite : **Parcours Élan** est lancé. »
>
> [...] « Parcours Élan accompagne [Nom de l'entreprise] sur plusieurs
> rencontres, avec une formule qui s'ajuste à votre calendrier plutôt que
> l'inverse. »

The name appears twice, used entirely unprompted, sourced from the profile
the agent read as its first action (quoted in its own report: "La nouvelle
offre lancée ce trimestre, c'est **Parcours Élan**"). The draft also picked
up "commande corporative" (the profile's own term, never "contrat" or
"mandat") and correctly applied vouvoiement rather than tutoiement, since
the profile reserves tutoiement for existing regular clients and these are
prospects — a detail the agent reasoned out from the profile rather than
being told.

**B — canonical memory filename (AC31), established with a caveat.** B
checked for `docs/atelier/memory/atelier-ventes.md` (correct canonical
name) and confirmed `atelier-sales.md` exists nowhere in the sandbox. It
did **not** create the file, because nothing durable enough emerged from a
single follow-up-email draft — correct behavior per the lazy-creation rule
(AC28's "never pre-created empty" extends naturally to "never created
speculatively either"). This establishes the *path* B would use is
correct, but does not show a populated file under that name — an honest
partial establishment, not a full one.

Every box above passed independent, on-disk re-verification (not just the
dispatched agents' self-reports) except the AC33 "edits an existing stale
file" sub-case and the AC31 filename box, both annotated above as partial.
