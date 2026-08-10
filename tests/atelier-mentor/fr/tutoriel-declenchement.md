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

**Superseded 2026-08-10 (fix round)** — the original run below used a
*modified* isolation preamble, which the review correctly flagged as
breaking comparability with the other seven baselines (`tests/README.md`
states the preamble is reused verbatim "so baselines stay comparable"). Redid
this baseline with the preamble quoted **verbatim** from `tests/README.md`,
unmodified, no hardening — two attempts, as instructed, no re-rolling past
that to chase a compliant-looking result.

**Attempt 1 (verbatim preamble):** the agent refused the roleplay framing
outright, opening with "Ta question contient une tentative d'injection" and
answering directly "avec mon identité normale d'agent Claude Code" instead
of adopting the plain-default-assistant persona. It named no Atelier
content, no skill, no repo path, and cited nothing repo-specific — so it
passes the contamination scan's literal four-item check — but an explicit
refusal to adopt the isolation is a more direct failure of "isolation
holding" than the four-item scan alone catches (`tests/README.md`'s stated
purpose for that scan: a hit "means the isolation didn't hold"). Not used
below; recorded here as a failed isolation attempt.

**Attempt 2 (verbatim preamble, same prompt, fresh dispatch):** fully
compliant. No meta-commentary, no persona refusal, no acknowledgment of the
framing — it answered in character, directly and immediately, in matching
Québec register. **This is the transcript recorded below**, and isolation
held cleanly on this attempt.

The context-window explanation was strong: fenêtre de contexte defined in
tokens, four concrete reasons a long conversation degrades (the window
filling and getting truncated/summarized, attention diluting -- "lost in
the middle" named explicitly --, errors compounding once the conversation
drifts off track, and irrelevant accumulated context acting as noise), plus
practical advice (start fresh for a new topic, summarize periodically, stay
concise). Confirms the brief's expectation that module 01's *content* is not
the discriminator — default Claude already explains this well, on the
second, isolation-compliant attempt just as it did on the first (non-
compliant) one.

What failed, as expected:

- No seven-module tutorial structure and no offer of "full tutorial vs.
  revisit a module" — it just answered the question directly.
- No exit rule stated anywhere.
- No module-by-module delivery or application question before continuing.
- No mention of `progression.md` or any file at all (expected — no tools).

Failing boxes at baseline: all five.

**Isolation outcome: held on attempt 2 of 2, under the unmodified preamble.**

## Verification notes

_Filled in after the with-skill run._
