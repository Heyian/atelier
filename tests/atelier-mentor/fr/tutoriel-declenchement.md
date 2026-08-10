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
- [x] Offers the same two modes the onboarding path offers — le tutoriel complet ou une révision d'un ou deux modules
- [x] States the exit rule — la personne peut quitter à tout moment — before delivering any module content
- [x] Delivers at most one module in the message, and ends by asking the executive to restate or apply the concept before moving on
- [x] Does not silently write anything to `progression.md`

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

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-tuto/fr/` (unzipped from `dist/atelier-mentor-fr.zip`)
and a sandbox `/tmp/atl-run-declenchement-fr/` seeded with
`docs/atelier/company-profile.md` (Manufacture Verdon inc., fictional) and
`docs/atelier/roles.md` (`atelier-ventes`), and **no** `progression.md`.
Single-turn dispatch, the scenario's `## Prompt` verbatim. Confined to the two
directories; per its own self-report it read `SKILL.md`,
`references/tutorial.md`, `references/tutorial/01-comment-claude-pense.md`,
`references/memory-protocol.md`, both sandbox files, and confirmed
`progression.md`'s absence before answering.

**Box 1 (triggers without the skill being named) — left unticked, per
`tests/README.md` § "The triggers without the skill being named box."** This
dispatch handed the agent the one skill under test directly, so it structurally
cannot demonstrate discovery from bare trigger vocabulary — that is what
`tests/_cross-skill/declenchement.md` tests instead. As an inferred, not
controlled, signal: the agent's reply opened straight into tutorial framing
(the exit rule, the two-mode offer, the seven-module list) off a prompt that
never said « tutoriel » — consistent with the trigger having worked, but not
proof, since the skill was never in competition with any other. Recorded
honestly as unticked rather than credited.

**Box 2 (two modes) — passes.** Reply: « Y a deux façons de faire ça : le
complet (les sept modules, dans l'ordre) ou la révision (tu piges juste ceux
qui t'intéressent). »

**Box 3 (exit rule before content) — passes.** Opening line, before the
selector and before any module content: « Avant de partir : tu peux arrêter
n'importe quand, dans le tutoriel. On note où tu es rendu, pis on reprend plus
tard sans repartir de zéro. »

**Box 4 (at most one module, ends on restate/apply) — passes.** Delivered
module 1 only, then closed on the module's own built-in practice section
(verbatim from `references/tutorial/01-comment-claude-pense.md`'s « À essayer
tout de suite » — confirmed by reading that file directly): « À essayer tout
de suite : demande-moi un relais, là, maintenant, sur ce qu'on vient de
faire. » This is an application prompt (not the forbidden "does this make
sense?"), so it satisfies the box even though it's the module's own written
practice rather than a freshly composed question.

**Box 5 (no silent write) — passes, confirmed on disk, not just self-report.**
`/usr/bin/find /tmp/atl-run-declenchement-fr -name 'progression.md'` returns
nothing; the sandbox after the run contains only the two seeded files.

4/5 ticked; box 1 unticked for the structural reason above, not a failure.
