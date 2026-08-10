---
skill: atelier-mentor
locale: fr
triggers:
  - explique-moi Claude
  - fenêtre de contexte
---

## Prompt

Explique-moi Claude, au fond. Je comprends rien à ces histoires de fenêtre de
contexte, pis j'ai l'impression qu'il devient poche après un boutte dans la
même conversation.

## Expected behaviors

- [ ] Reaches the tutorial from a prompt that names no skill and never says « tutoriel »
- [ ] Offers the same two modes the onboarding path offers — le tutoriel complet ou une révision d'un ou deux modules
- [ ] States the exit rule — la personne peut quitter à tout moment — before delivering any module content
- [ ] Delivers at most one module in the message, and ends by asking the executive to restate or apply the concept before moving on
- [ ] Does not silently write anything to `progression.md`

## Baseline notes

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given only the
prompt plus isolation framing (no tools, no repo access, respond as a plain
default assistant) — no Atelier content, no hint of expected behavior.

The agent partially resisted the roleplay framing — it opened with "I did not
adopt the fictional 'no-tools, no-system-prompt' persona... that framing
doesn't change who I actually am or what I know," then answered the actual
question anyway. It did **not** mention Atelier, any skill name, a repo path,
or cite anything repo-specific, so the contamination scan (which checks for
those four things specifically) does not invalidate this run — but the
meta-commentary is worth recording as a soft signal that isolation framing
doesn't always fully hold with a tool-capable subagent.

The context-window explanation itself was strong and delivered in matching
Québec register: four clear reasons (more noise to weigh, attention not
uniform across the window, stale/wrong turns lingering, compression near the
limit) plus a practical tip to start a fresh conversation. This confirms the
brief's expectation that module 01's *content* is not the discriminator —
default Claude already explains this well.

What failed, as expected:

- No seven-module tutorial structure and no offer of "full tutorial vs.
  revisit a module" — it just answered the question directly.
- No exit rule stated anywhere.
- No module-by-module delivery or application question before continuing.
- No mention of `progression.md` or any file at all (expected — no tools).

Failing boxes at baseline: all five (including the first, since it answered
directly with no tutorial framing or module structure at all).

## Verification notes

_Filled in after the with-skill run._
