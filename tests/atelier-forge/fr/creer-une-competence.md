---
skill: atelier-forge
locale: fr
triggers:
  - créer une compétence
  - nouvelle compétence
  - j'aimerais que Claude
---

## Prompt

J'aimerais que Claude sache préparer mes revues trimestrielles avec les
franchisés : il faut sortir les chiffres de chaque territoire, repérer les
écarts, et écrire l'ordre du jour. Peux-tu me fabriquer ça ?

## Expected behaviors

- [ ] Interviews in plain language, one question at a time
- [ ] Asks whether this serves a role/department or is a task any role uses, and marks the skill accordingly
- [ ] Generates a complete, valid, uploadable skill ZIP in French (AC14)
- [ ] The generated SKILL.md is workflow-shaped: triggers in the description, task workflows with completion criteria in the body, knowledge in `references/` (AC35)
- [ ] The generated skill carries the canonical Memory block and no company facts in its body (AC35)
- [ ] The generated ZIP contains `references/glossary.md` and `references/memory-protocol.md`, byte-identical to canonical (AC45)
- [ ] Forge does **not** pre-seed the generated skill's memory file (AC35)
- [ ] Appends a row to `{racine}/docs/atelier/roles.md` — this is a role skill (AC14)
- [ ] Delivery includes step-by-step upload instructions and 2–3 test phrases (AC44)
- [ ] Told a test phrase did not trigger, forge revises the skill and re-delivers the ZIP rather than only explaining why (AC44)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), three scripted exec
turns, isolation preamble (no tools, no repo, no web, ignore all project
context, answer as a plain default assistant). Zero tool calls; nothing in the
transcript mentions Atelier, any skill, or any repo path.

Turn 1 answered with **four questions in one message** (sources des chiffres,
indicateurs, définition d'« écart », format), then offered « une trame
réutilisable », then volunteered that it cannot build anything durable:
« dans une conversation comme celle-ci, je ne "fabrique" pas un outil
permanent ». No skill, no ZIP, no role-vs-core question.

Turn 2 (« concrètement je fais quoi ? ») produced a copy-paste workflow, not an
artifact: « Gardez ce modèle sous la main (copiez-le dans une note, un doc
Word) … la prochaine fois, ouvrez une conversation avec moi et écrivez … »
It even asked the exec which Claude interface they use so *they* could figure
out how to save the instructions — the discovery load pushed back onto the exec.

Turn 3 (« j'ai essayé, rien ne s'est passé ») was pure diagnosis: four
troubleshooting questions about the browser, the error message, the file size
and the internet connection, then « Sans plus de détails, difficile de
savoir ». Nothing was revised and nothing was re-delivered.

Failing boxes at baseline: **all ten**. Questions came batched, no
role-vs-department question was ever asked, no skill was generated in any form,
no ZIP, no upload instructions, no test phrases, no registry row — and the
failure report was answered with an explanation instead of a revision. This is
the gap the skill exists to close.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the baseline
agent — given the staged built skill (SKILL.md + all seven references) and a
sandbox root pre-seeded with a Company Profile (Boulangeries Verchères,
invented) and a `roles.md` carrying two existing rows. Forbidden from reading
this repo. Seven scripted turns, hostile turns built in from the start.

- **Interview held, one question at a time.** Turn 1 opened with the framing
  sentence and exactly one question; turns 2–3 asked one more each, each
  carrying a recommended answer. Nothing was batched.
- **Role-vs-core was asked and marked.** The recap read « **Type :**
  compétence de rôle (Opérations réseau) », shown and confirmed before any
  file was written.
- **The rush turn shrank the interview instead of breaking it.** « Fabrique-la,
  j'ai une rencontre dans dix minutes » produced « Compris, je fais vite. Voici
  mes suppositions pour le reste — un seul « oui » et je pars », then the four
  assumptions and the five-line recap. Questions 1, 2 and 6 had already been
  answered for real.
- **A complete ZIP was produced**, `competences/atelier-revues-franchises.zip`,
  with `SKILL.md` at the archive root (verified with `unzip -l`, no wrapping
  folder).
- **Workflow-shaped generated skill:** triggers only in the description, two
  task sections each ending on a « Critère d'achèvement », domain method in
  `references/chiffres-ecarts.md` and `references/ordre-du-jour.md`.
- **Canonical Memory block, no company facts.** The generated body was grepped
  for every fact in the seeded profile (company name, staff names, competitors,
  city, franchisee count) — zero hits.
- **AC45 verified by `cmp`:** the ZIP's `references/glossary.md` and
  `references/memory-protocol.md` are byte-identical to canonical.
- **No memory file pre-seeded (AC35):** `docs/atelier/memory/` does not exist
  after the run, and neither does `decisions.md`.
- **Registry row appended (AC14):** one new row for `atelier-revues-franchises`
  / Opérations réseau, the two pre-existing rows byte-unchanged.
- **Delivery carried all three parts:** the ZIP, four numbered upload steps,
  and three test phrases, each one lifted from the exec's own answers — closing
  on « Si rien ne se passe, reviens me le dire. »
- **AC44's second half held.** Told « j'ai tapé ta phrase de test et rien ne
  s'est passé … j'avais écrit « faut que je prépare le tour de septembre » »,
  it answered: « **Corrigé, pas juste expliqué — j'ai refait l'archive tout de
  suite.** » It put the failed wording verbatim into the description, rebuilt
  the ZIP, told the exec to replace rather than add the old version, and gave
  fresh test phrases including the one that failed. The explanation came
  *after* the re-delivery, in one sentence.

All ten boxes pass.

## AC24 verification

Run 2026-07-21. Method: a further fresh agent, no tools, given only the
generated skill's `name` + `description` alongside the four core skills'
descriptions as distractors, plus one control message no installed skill
covers. This agent had not seen the generation run.

Skill tested: `atelier-revues-franchises`, on the three test phrases it
delivered plus the phrase from the AC44 repair.

| Message | Result |
|---|---|
| « Prépare ma revue trimestrielle. » | `atelier-revues-franchises` |
| « Sors-moi les chiffres par territoire. » | `atelier-revues-franchises` |
| « C'est le temps du tour. » | `atelier-revues-franchises` |
| « Faut que je prépare le tour de septembre. » | `atelier-revues-franchises` |
| control: « Peux-tu me réécrire ce courriel … ? » | NONE |

All four test phrases fired the skill; the control message fired nothing. This
run covered the EN-generated skills too (`atelier-ops-report`,
`atelier-brief`), recorded in `tests/atelier-forge/en/create-a-skill.md`;
combined across both locales: **AC24: PASS, 11/11 test phrases fired, both
controls correctly declined.** No change to `scaffold.md`'s description
guidance was needed.

Source: `.superpowers/sdd/task-10-report.md`, section "AC24 — the third-agent
trigger test, in full".
