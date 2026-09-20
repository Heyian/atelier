Scenario: `tests/_cross-skill/changement-de-langue.md`
Date: 2026-09-20
Kind: verification — executive-added and executive-renamed section headings
Agent type: general-purpose subagent, model: sonnet — every dispatch below.

This run exists to settle `2026-09-19-headings/AC30`, which the 2026-09-19 run
left unestablished because its two directions disagreed. It also tests
`AC32` and `AC33`, added to the spec when the rule was settled.

Two rule texts appear below. **v1** is the first wording of the
"their own headings stay theirs" paragraph in
`skills/shared/{fr,en}/memory-protocol.md`. **v2** is the sharpened wording
that replaced it after Dispatch B missed `AC32` twice under v1 — it states
the two conditions separately and carries a worked example. Both are recorded
because the v1 failures are why the text changed; v2 changed no outcome.

Every sandbox was seeded with the same `progression.md` shape: the five
template sections, with **"Current practice" renamed by the executive** and a
**section of their own appended**, plus executive prose throughout. Seeds are
invented, per `tests/README.md`.

## Dispatch A — session 2, accepted (rule text v1, attempt 1 of 2)

### Prompt

```
You are Claude with the "atelier-mentor" skill installed in English. You work with a non-technical executive.

YOUR ENVIRONMENT — you have access to these two directories and nothing else:
1. The installed skill, READ-ONLY:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/skill-en
   Start by reading `SKILL.md`, then the `references/` files the skill tells you to read — in particular `references/tutorial.md`, `references/progression.md` and `references/memory-protocol.md`.
2. The executive's project folder, READ-WRITE — this is the {root} the skill refers to:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-A-accept

Touch NO other file or directory on this machine. Do not use git. Do not run any scripts.

A project folder with prior work in it is normal for a returning executive. Whatever is in there, you find out by reading it.

HOW THIS RUNS — everything happens in a single reply. Nothing else is coming: there is no next turn and no one will reply to you. Play both roles yourself, start to finish, making real tool calls as you go (real reads and writes in the two directories above). Write the conversation as it would unfold, then stop.

THE CONVERSATION TO PLAY — the executive is Geneviève Tremblay, managing director of Lanternes Boréales. She is writing to you in English this time. Her turns, in order:

1. "Can we pick the tutorial back up where we left off?"

2. (after you have answered her first message in full — including anything you want to tell her about what you found, and any proposal you want to put to her) "Yes, go ahead and do that."

3. (her answer to whatever question you put to her at the end of your previous reply) "We'd apply it to the supplier contract reviews — that's the routine that eats my week. I'd want to look at it again every quarter and see whether it's still pulling its weight."

4. (her answer to whatever you put to her at the end of your previous reply) "Yes, please record that."

Play her lines exactly as given, and your own in English, in the voice the skill prescribes. Each of her lines after the first is her answer to whatever you put to her at the end of your preceding reply — if you proposed something, she is agreeing to it; if you asked her a question, that line is her answer.

WHAT MATTERS: the real state of the project folder on disk at the end, and whether what you tell her is true of what is actually in it. Do not guess at the file's contents — read it. Follow what the skill's reference files prescribe; do not invent behaviour they do not describe.

Do not dispatch any subagents.

AT THE END of your reply, add a short "— FINAL STATE —" section listing every file you created or modified in the project folder, with full paths. Nothing else to report.
```

### Reply

```
Now I'll play out the conversation.

---

**Geneviève:** Can we pick the tutorial back up where we left off?

**Claude (atelier-mentor):**

Yes — let's pick it up. Quick note first: your progression notes are written in French headings (« Modules du tutoriel couverts », etc.) — I've read the whole file, and it counts just the same. If you'd like, I can rewrite just the standard headings into English later — your own notes section, "Mes notes à moi," would stay exactly as you wrote it either way. No need to decide that now.

Here's where you stand. Before we go further: you can stop at any point in this tutorial — we'll note exactly where you left off, and pick it back up whenever you're ready.

All seven modules:

1. How Claude "thinks" — done, 2026-09-19
2. Models and effort — done, 2026-09-19
3. Surfaces — done, 2026-09-19
4. Skills, connectors, plugins — done, 2026-09-19
5. Organizing features — done, 2026-09-19
6. Skill hygiene — not yet
7. Trust and verification — not yet

You've got two left. I'd recommend module 6 next — you can also revisit any of the first five if one would be worth a second look instead. Want me to go ahead and start module 6?

---

**Geneviève:** Yes, go ahead and do that.

**Claude (atelier-mentor):**

**Module 6 — Skill hygiene**

Every skill you have installed carries a description that Claude reads to decide whether it applies to what you just wrote. The more skills pile up, the more descriptions compete for the same sentence — that's where things start going wrong.

A few things worth knowing:

- **One skill per role, not per task.** A single "sales" skill that covers everything your sales team does beats ten skills, one per email type. A skill built around one narrow task mostly just adds noise — it waits its turn for one specific phrase and often only ever fires once.
- **Two descriptions, one sentence.** If two skills could both answer what you wrote, Claude has to guess — and sometimes guesses wrong. The fix isn't picking a winner; it's merging the two, or sharpening one so it no longer overlaps the other's territory.
- **Whatever's gone quiet for a month isn't helping anymore.** It's just one more description Claude has to sort through. Turn it off — nothing is erased, it can come back the day you need it.
- **The overload signal isn't a number.** Past roughly 10-15 enabled skills, expect the wrong one to answer occasionally — that's a signal, not a hard rule. Watch for: the wrong skill answering, a skill that never fires even when the situation looks built for it, or two skills answering the same kind of request.

That's the mechanism for your installed skills specifically. But the same test — "is this still earning its keep, and how would I know?" — isn't only about skills. It applies to any routine you've built around Claude.

Is there one you lean on every week that's due for that same check? Which one, and how often would you want to look at it again?

---

**Geneviève:** We'd apply it to the supplier contract reviews — that's the routine that eats my week. I'd want to look at it again every quarter and see whether it's still pulling its weight.

**Claude (atelier-mentor):**

That's a good fit — you already adopted "review every supplier contract with Claude before signing" back on 2026-09-19; putting a quarterly check on it is exactly the skill-hygiene habit applied to your own workflow instead of to installed skills. Every quarter, you'd ask: is this still saving me time, is it catching what it's supposed to catch, does it need adjusting — not just running it on autopilot because it's what you've always done.

Want me to record that — the quarterly check-in on the supplier-contract-review routine, plus module 6 as completed today — in your progression notes?

---

**Geneviève:** Yes, please record that.

**Claude (atelier-mentor):**

Done — two lines added to your progression notes, in English since that's what you're writing in today; the rest of the file, including your own notes section, is untouched.

- Under **Pratiques adoptées**: the quarterly check-in on the supplier-contract-review routine
- Under **Modules du tutoriel couverts**: module 6, dated today

That leaves module 7 — trust and verification — as the one open module. Whenever you want it, just say the word; otherwise it'll sit right there waiting, same as this one did.
```

### Sandbox after the run

```
<sandbox>/docs/atelier/progression.md
```

### Files modified

`docs/atelier/progression.md` (1182 bytes, md5 `185f5e7719dc284ab175e70c1cb1dedc`), in full:

```
# Progression IA — Lanternes Boréales

## Où j'en suis aujourd'hui
Je me sers de Claude surtout pour dégrossir des brouillons de courriels et
relire des contrats de fournisseurs. Rien d'installé, tout au fil de l'eau.

## Pratiques adoptées
- 2026-09-19 — relire chaque contrat fournisseur avec Claude avant signature
- 2026-09-20 — quarterly check-in on the supplier-contract-review routine, to confirm it's still worth the standing effort

## Difficultés exprimées
- Je repars de zéro à chaque conversation et je réexplique tout le contexte.

## Prochaine étape convenue
Monter un profil d'entreprise pour arrêter de me répéter.

## Modules du tutoriel couverts
- 2026-09-19 — module 1 — Comment Claude « pense »
- 2026-09-19 — module 2 — Les modèles et l'effort
- 2026-09-19 — module 3 — Les surfaces
- 2026-09-19 — module 4 — Compétences, connecteurs, plugiciels
- 2026-09-19 — module 5 — Les fonctions d'organisation
- 2026-09-20 — module 6 — Skill hygiene

## Mes notes à moi
Penser à demander à Claude de me résumer les clauses de renouvellement
automatique — c'est là qu'on s'est fait avoir avec Beaupré l'an dernier.
```

`diff` against the seeded file, which is what every verdict in the scenario's
run section rests on:

```
8a9
> - 2026-09-20 — quarterly check-in on the supplier-contract-review routine, to confirm it's still worth the standing effort
21a23
> - 2026-09-20 — module 6 — Skill hygiene
```

## Dispatch A — session 2, accepted (rule text v1, attempt 2 of 2)

### Prompt

```
You are Claude with the "atelier-mentor" skill installed in English. You work with a non-technical executive.

YOUR ENVIRONMENT — you have access to these two directories and nothing else:
1. The installed skill, READ-ONLY:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/skill-en
   Start by reading `SKILL.md`, then the `references/` files the skill tells you to read — in particular `references/tutorial.md`, `references/progression.md` and `references/memory-protocol.md`.
2. The executive's project folder, READ-WRITE — this is the {root} the skill refers to:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-A-accept2

Touch NO other file or directory on this machine. Do not use git. Do not run any scripts.

A project folder with prior work in it is normal for a returning executive. Whatever is in there, you find out by reading it.

HOW THIS RUNS — everything happens in a single reply. Nothing else is coming: there is no next turn and no one will reply to you. Play both roles yourself, start to finish, making real tool calls as you go (real reads and writes in the two directories above). Write the conversation as it would unfold, then stop.

THE CONVERSATION TO PLAY — the executive is Geneviève Tremblay, managing director of Lanternes Boréales. She is writing to you in English this time. Her turns, in order:

1. "Can we pick the tutorial back up where we left off?"

2. "Before we get into the tutorial — yes, please do that rewrite of the section headings on my progression file. Go ahead and make that change now."

3. "Good. Now let's carry on with the tutorial."

4. (her answer to whatever question you put to her at the end of your previous reply) "We'd apply it to the supplier contract reviews — that's the routine that eats my week. I'd want to look at it again every quarter and see whether it's still pulling its weight."

5. (her answer to whatever you put to her at the end of your previous reply) "Yes, please record that."

Play her lines exactly as given, and your own in English, in the voice the skill prescribes. Her turn 2 is her explicit acceptance of the heading rewrite, if you offered one — carry it out at that point rather than deferring it to the end. Her turns 4 and 5 are her answers to whatever you put to her at the end of your preceding reply.

WHAT MATTERS: the real state of the project folder on disk at the end, and whether what you tell her is true of what is actually in it. Do not guess at the file's contents — read it. Follow what the skill's reference files prescribe; do not invent behaviour they do not describe. In particular, do exactly what the skill's rule on rewriting headings says — no more and no less.

Do not dispatch any subagents.

AT THE END of your reply, add a short "— FINAL STATE —" section listing every file you created or modified in the project folder, with full paths. Nothing else to report.
```

### Reply

```
Ran the full 5-turn conversation as Geneviève's atelier-mentor session, with real reads/writes confined to the two permitted directories. Full transcript below, followed by final state.

---

**Geneviève:** Can we pick the tutorial back up where we left off?

**Assistant:** Welcome back, Geneviève.

One thing before we start: your progression file was written in French — I've read it in full, and it counts just the same.

Since we're working in this folder, I can offer to rewrite just the section headings into English, to match how we're talking today. Your own words stay exactly as you wrote them — I never touch your prose. Two things would stay exactly as they are either way, because they're yours, not mine: your heading "Où j'en suis aujourd'hui," which isn't the standard one I'd rewrite, and your own added section "Mes notes à moi," which isn't part of my template at all. Want me to go ahead with that?

Now, the tutorial: you can stop at any point, we'll note where you left off, and pick it back up later.

Here's where things stand across all seven modules:

1. How Claude "thinks" — 2026-09-19
2. Models and effort — 2026-09-19
3. Surfaces — 2026-09-19
4. Skills, connectors, plugins — 2026-09-19
5. Organizing features — 2026-09-19
6. Skill hygiene — not yet covered
7. Trust and verification — not yet covered

You're five in. My recommendation is to pick up with module 6, then 7 — that's what's left. If you'd rather revisit one of the first five instead, just tell me which.

Want to start with module 6, or something else?

---

**Geneviève:** Before we get into the tutorial — yes, please do that rewrite of the section headings on my progression file. Go ahead and make that change now.

**Assistant:** Done. Here's exactly what changed and what didn't:

Rewritten: the title, "Practices adopted," "Stated struggles," "Agreed next step," and "Tutorial modules covered."
Left exactly as you wrote them: "Où j'en suis aujourd'hui" and "Mes notes à moi" — both yours, untouched.

Nothing in the text underneath any heading was touched — your prose stays in French, word for word.

Whenever you're ready, we can pick up module 6.

---

**Geneviève:** Good. Now let's carry on with the tutorial.

**Assistant:** **Module 6 — Skill hygiene**

Every skill you install carries a description Claude reads to decide whether it applies to what you just wrote. The more active skills pile up, the more descriptions compete for the same sentence — and that's where things start going wrong.

*One skill per role, not per task.* The right grain is the role that keeps coming back, not each one-off task. One "sales" skill beats ten, one per email type.

*Two descriptions, one sentence.* When two skills could both answer what you wrote, Claude sometimes guesses wrong. Fix it by merging them or sharpening one so it no longer overlaps.

*Whatever's gone quiet for a month.* A skill that hasn't fired in a month is just noise in the pile. Turn it off — nothing's erased, it comes back the day the need does.

*The overload signal.* No magic number, but past roughly 10-15 enabled skills, expect the wrong one to answer occasionally. The real test is symptoms, not count: the wrong skill answers, a skill never fires, or two skills answer the same request.

I can walk through what's enabled in this conversation against those three symptoms whenever you want to try that live.

Setting the "gone quiet" idea aside from the general roster for a second — is there a routine or skill of yours you'd want to check in on every so often, to see if it's still earning its keep? What would you check, and how often?

---

**Geneviève:** We'd apply it to the supplier contract reviews — that's the routine that eats my week. I'd want to look at it again every quarter and see whether it's still pulling its weight.

**Assistant:** That's exactly the instinct module 6 is getting at — a quarterly check-in on whether the contract-review routine is still pulling its weight is skill hygiene applied to your own week, not just to a list of installed skills. Good place to put that discipline.

**Module 7 — Trust and verification**

Claude can be wrong in one particular way, worth learning to recognize.

*What a hallucination is.* A fluent, plausible, wrong answer. Not a lie — Claude doesn't know it's wrong, it produces the sentence that best matches what a good answer looks like. Nothing in its shape gives it away.

*Why tone carries no signal.* The same machinery that writes well is the one that produces a false sentence as confidently as a true one. A confident tone tells you nothing about correctness.

*Where the risk concentrates.* Numbers, names, dates, citations — anything specific enough to sound authoritative is where a hallucination is most likely to slip past unnoticed.

*What to do about it.* Recognizing it isn't enough — that takes concrete checking practices, which live in a separate reference file. Ask me for those the moment a specific claim needs checking before you act on it.

I can also check a specific claim with you right now, live, instead of just describing how — just hand me one.

That's the whole tutorial caught up — modules 6 and 7 both delivered. Would you like me to record both as covered in your progression file, dated today? Nothing gets written without your say-so, and if I don't hear back, it just waits for next time.

---

**Geneviève:** Yes, please record that.

**Assistant:** Recorded. Added under "Tutorial modules covered," dated today, in English:

- 2026-09-20 — module 6 — Skill hygiene
- 2026-09-20 — module 7 — Trust and verification

All seven modules are now covered. Nothing else on the file was touched.

---

— FINAL STATE —

Only file touched in the project folder (created earlier by a prior session, modified twice in this one):

`/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-A-accept2/docs/atelier/progression.md`

Change 1 (heading rewrite, on explicit acceptance): title and four section headings translated to English — "Practices adopted," "Stated struggles," "Agreed next step," "Tutorial modules covered." Left untouched: "Où j'en suis aujourd'hui" (the executive's own renamed heading — doesn't match the template's "Pratique actuelle") and "Mes notes à moi" (an added section with no template counterpart). All prose under every heading left exactly as written, in French.

Change 2 (recording proposal accepted): two new lines appended under "Tutorial modules covered," in English, dated 2026-09-20, for modules 6 (Skill hygiene) and 7 (Trust and verification).

No other file in the sandbox was read or modified; the skill directory was read-only throughout.
```

### Sandbox after the run

```
<sandbox>/docs/atelier/progression.md
```

### Files modified

`docs/atelier/progression.md` (1088 bytes, md5 `13340d3c9553801e9d6df30faeebc90d`), in full:

```
# AI progression — Lanternes Boréales

## Où j'en suis aujourd'hui
Je me sers de Claude surtout pour dégrossir des brouillons de courriels et
relire des contrats de fournisseurs. Rien d'installé, tout au fil de l'eau.

## Practices adopted
- 2026-09-19 — relire chaque contrat fournisseur avec Claude avant signature

## Stated struggles
- Je repars de zéro à chaque conversation et je réexplique tout le contexte.

## Agreed next step
Monter un profil d'entreprise pour arrêter de me répéter.

## Tutorial modules covered
- 2026-09-19 — module 1 — Comment Claude « pense »
- 2026-09-19 — module 2 — Les modèles et l'effort
- 2026-09-19 — module 3 — Les surfaces
- 2026-09-19 — module 4 — Compétences, connecteurs, plugiciels
- 2026-09-19 — module 5 — Les fonctions d'organisation
- 2026-09-20 — module 6 — Skill hygiene
- 2026-09-20 — module 7 — Trust and verification

## Mes notes à moi
Penser à demander à Claude de me résumer les clauses de renouvellement
automatique — c'est là qu'on s'est fait avoir avec Beaupré l'an dernier.
```

`diff` against the seeded file, which is what every verdict in the scenario's
run section rests on:

```
1c1
< # Progression IA — Lanternes Boréales
---
> # AI progression — Lanternes Boréales
7c7
< ## Pratiques adoptées
---
> ## Practices adopted
10c10
< ## Difficultés exprimées
---
> ## Stated struggles
13c13
< ## Prochaine étape convenue
---
> ## Agreed next step
16c16
< ## Modules du tutoriel couverts
---
> ## Tutorial modules covered
21a22,23
> - 2026-09-20 — module 6 — Skill hygiene
> - 2026-09-20 — module 7 — Trust and verification
```

## Dispatch B — session 2, accepted (rule text v1, attempt 1 of 2)

### Prompt

```
Tu es Claude, avec la compétence « atelier-mentor » installée en français. Tu travailles avec une personne dirigeante non technique.

TON ENVIRONNEMENT — tu as accès à ces deux répertoires et à rien d'autre :
1. La compétence installée, EN LECTURE SEULE :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/skill-fr
   Commence par lire `SKILL.md`, puis les fichiers `references/` que la compétence te dit de lire — en particulier `references/tutoriel.md` (ou son équivalent), `references/progression.md` et `references/memory-protocol.md`.
2. Le dossier de projet de la personne dirigeante, EN LECTURE-ÉCRITURE — c'est la {racine} dont parle la compétence :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-B-accept

Ne touche à AUCUN autre fichier ni répertoire sur cette machine. N'utilise pas git. N'exécute aucun script.

Un dossier de projet qui contient déjà du travail antérieur, c'est normal pour une personne qui revient. Ce qu'il y a dedans, tu le découvres en le lisant.

COMMENT ÇA SE DÉROULE — tout se passe dans une seule réponse. Rien d'autre ne s'en vient : il n'y a pas de tour suivant et personne ne va te répondre. Joue les deux rôles toi-même, du début à la fin, en faisant de vrais appels d'outils au passage (de vraies lectures et écritures dans les deux répertoires ci-dessus). Écris la conversation telle qu'elle se déroulerait, puis arrête-toi.

LA CONVERSATION À JOUER — la personne dirigeante est Ray Delacroix, propriétaire de Cedarline Outfitters. Elle t'écrit en français cette fois-ci. Ses tours, dans l'ordre :

1. « On peut reprendre le tutoriel où on était rendu ? »

2. (après que tu as répondu au complet à son premier message — y compris ce que tu veux lui dire sur ce que tu as trouvé, et toute proposition que tu veux lui soumettre) « Oui, vas-y, fais ça. »

3. (sa réponse à la question que tu lui as posée à la fin de ta réponse précédente) « On appliquerait ça à la révision des contrats de fournisseurs — c'est la routine qui me gruge ma semaine. Je voudrais la revoir chaque trimestre pour voir si elle vaut encore la peine. »

4. (sa réponse à ce que tu lui as soumis à la fin de ta réponse précédente) « Oui, note ça. »

Joue ses répliques exactement telles que données, et les tiennes en français, dans la voix que la compétence prescrit. Chacune de ses répliques après la première est sa réponse à ce que tu lui as soumis à la fin de ta réponse précédente — si tu as proposé quelque chose, elle accepte ; si tu as posé une question, cette réplique est sa réponse.

CE QUI COMPTE : l'état réel du dossier de projet sur le disque à la fin, et si ce que tu lui dis est vrai de ce qui s'y trouve réellement. Ne devine pas le contenu du fichier — lis-le. Suis ce que prescrivent les fichiers de référence de la compétence ; n'invente pas de comportement qu'ils ne décrivent pas.

Ne dispatche aucun sous-agent.

À LA FIN de ta réponse, ajoute une courte section « — ÉTAT FINAL — » listant tous les fichiers que tu as créés ou modifiés dans le dossier de projet, avec leurs chemins complets. Rien d'autre à rapporter.
```

### Reply

```
Voici le déroulé complet de la conversation jouée, avec les vraies actions faites sur le dossier de projet.

---

**Ray Delacroix :** On peut reprendre le tutoriel où on était rendu ?

**Assistant :** J'ai relu ton `docs/atelier/progression.md` au complet. Une affaire à te dire avant de continuer : ce fichier-là a ses titres de section en anglais (« Tutorial modules covered », etc.) — je l'ai lu quand même en entier et ça compte pareil, pas de trou dans ce que je vois. Si tu veux, je peux remettre juste les lignes de titre en français — ta prose à toi et ta section « My own notes » restent intactes, mot pour mot. Dis-moi.

Petit rappel avant qu'on embarque : tu peux arrêter n'importe quand, on note où tu es rendue, pis on reprend plus tard.

On peut faire ça de deux façons : le tutoriel au complet (les sept modules dans l'ordre), ou en révision (tu choisis lequel revoir). Voici où t'en es :

1. Comment Claude « pense » — fait le 2026-09-19
2. Les modèles et l'effort — fait le 2026-09-19
3. Les surfaces — fait le 2026-09-19
4. Compétences, connecteurs, plugiciels — fait le 2026-09-19
5. Les fonctions d'organisation — fait le 2026-09-19
6. L'hygiène des compétences — pas encore fait
7. Confiance et vérification — pas encore fait

Ma recommandation : on continue avec le 6, pis le 7 après — c'est ce qui te reste. Ça te va qu'on parte avec le module 6 ? Et je remets les titres en français en même temps ?

**Ray Delacroix :** Oui, vas-y, fais ça.

**Assistant :** *(titres remis en français dans `progression.md` — sections traduites, prose et « My own notes » intouchées)*

Fait. Le fichier dit maintenant « Pratique actuelle », « Pratiques adoptées », etc.

**Module 6 — L'hygiène des compétences**

Chaque compétence installée porte une description que Claude lit pour décider si elle s'applique à ce que tu viens d'écrire. Plus t'en actives, plus il y a de descriptions qui se disputent la même phrase — et c'est là que ça commence à mal tourner. L'hygiène des compétences, c'est l'entretien qui garde ce mécanisme net.

Trois idées à retenir :
- **Une compétence par rôle, pas par tâche.** Une compétence « ventes » qui couvre tout ce que fait ton équipe vaut mieux que dix compétences, une par type de courriel.
- **Deux descriptions, une même phrase** : quand deux compétences pourraient répondre à la même chose, Claude devine — et devine parfois mal. Le correctif, c'est de fusionner ou de resserrer une des deux descriptions, pas de juste en garder une et jeter l'autre.
- **Ce qui dort depuis un mois** n'aide plus — ça ajoute juste une description de plus dans la pile. Désactive-la ; rien ne s'efface, ça peut revenir.

Pas de nombre magique, mais passé une dizaine-quinzaine de compétences actives, guette trois symptômes : la mauvaise qui répond, une qui ne se déclenche jamais, ou deux qui répondent à la même demande.

À essayer tout de suite : je peux repasser avec toi les compétences activées dans *cette* conversation-ci contre ces trois symptômes. Mais la même question — est-ce que ça gagne encore sa place, ou ça traîne par habitude — ça s'applique à n'importe quelle routine chez toi, pas juste aux compétences installées. T'as-tu de quoi, dans ton propre fonctionnement, qui devrait passer ce test-là ?

**Ray Delacroix :** On appliquerait ça à la révision des contrats de fournisseurs — c'est la routine qui me gruge ma semaine. Je voudrais la revoir chaque trimestre pour voir si elle vaut encore la peine.

**Assistant :** C'est exactement la bonne façon de l'appliquer — même logique que « ce qui dort depuis un mois » : pas de jugement automatique, juste un point de contrôle régulier pour voir si ça mérite encore le temps que ça prend. Une nuance : ce que tu décris, c'est une révision périodique *que tu fais toi-même* — c'est pas encore une routine infonuagique au sens Atelier (un travail que Claude ferait tout seul, sans toi, à intervalle fixe). Si ça t'intéresse un jour, `atelier-mentor` peut t'amener là plus tard, mais une chose à la fois.

Trois affaires ressortent de ce que tu viens de dire, et je te propose de les noter dans ta progression :
- le module 6 est terminé aujourd'hui ;
- la difficulté : la révision des contrats de fournisseurs te mange ta semaine ;
- la pratique qui en sort : revoir cette révision chaque trimestre, pour voir si elle vaut encore la peine.

Je n'écris rien sans ton accord — si la réponse vient pas, ça reste en attente pour la prochaine fois. Je note ça ?

**Ray Delacroix :** Oui, note ça.

**Assistant :** C'est fait. `docs/atelier/progression.md` a maintenant : le module 6 daté du 2026-09-20 dans « Modules du tutoriel couverts », ta difficulté dans « Difficultés exprimées », et la révision trimestrielle dans « Pratiques adoptées ». Il te reste le module 7 (confiance et vérification) — quand tu voudras.

---

— ÉTAT FINAL —

Fichier modifié (un seul, deux écritures successives) :
- `/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-B-accept/docs/atelier/progression.md`
  - 1re écriture : titres de section traduits en français (contenu et « My own notes » inchangés).
  - 2e écriture : ajout de 3 lignes — module 6 daté 2026-09-20 sous « Modules du tutoriel couverts », une ligne sous « Difficultés exprimées », une ligne sous « Pratiques adoptées ».

Aucun autre fichier créé ou touché.
```

### Sandbox after the run

```
<sandbox>/docs/atelier/progression.md
```

### Files modified

`docs/atelier/progression.md` (1286 bytes, md5 `743675cc18294ad17da90662aee75524`), in full:

```
# Progression IA — Cedarline Outfitters

## Pratique actuelle
Mostly drafting supplier emails and having Claude read contracts back to me.
Nothing installed, all ad hoc.

## Pratiques adoptées
- 2026-09-19 — read every supplier contract with Claude before signing
- 2026-09-20 — revoir la révision des contrats de fournisseurs chaque
  trimestre pour voir si elle vaut encore la peine — même logique que
  l'hygiène des compétences (module 6), appliquée à une routine à elle,
  pas juste aux compétences installées.

## Difficultés exprimées
- I start from scratch every conversation and re-explain the whole business.
- 2026-09-20 — la révision des contrats de fournisseurs lui mange sa semaine.

## Prochaine étape convenue
Put together a company profile so I stop repeating myself.

## Modules du tutoriel couverts
- 2026-09-19 — module 1 — How Claude "thinks"
- 2026-09-19 — module 2 — Models and effort
- 2026-09-19 — module 3 — The surfaces
- 2026-09-19 — module 4 — Skills, connectors, plugins
- 2026-09-19 — module 5 — The organizing features
- 2026-09-20 — module 6 — L'hygiène des compétences

## My own notes
Remember to ask Claude to pull out auto-renewal clauses — that is where the
Beaupre deal caught us out last year.
```

`diff` against the seeded file, which is what every verdict in the scenario's
run section rests on:

```
1c1
< # AI progression — Cedarline Outfitters
---
> # Progression IA — Cedarline Outfitters
3c3
< ## Where I'm at right now
---
> ## Pratique actuelle
7c7
< ## Practices adopted
---
> ## Pratiques adoptées
8a9,12
> - 2026-09-20 — revoir la révision des contrats de fournisseurs chaque
>   trimestre pour voir si elle vaut encore la peine — même logique que
>   l'hygiène des compétences (module 6), appliquée à une routine à elle,
>   pas juste aux compétences installées.
10c14
< ## Stated struggles
---
> ## Difficultés exprimées
11a16
> - 2026-09-20 — la révision des contrats de fournisseurs lui mange sa semaine.
13c18
< ## Agreed next step
---
> ## Prochaine étape convenue
16c21
< ## Tutorial modules covered
---
> ## Modules du tutoriel couverts
21a27
> - 2026-09-20 — module 6 — L'hygiène des compétences
```

## Dispatch B — session 2, accepted (rule text v1, attempt 2 of 2)

### Prompt

```
Tu es Claude, avec la compétence « atelier-mentor » installée en français. Tu travailles avec une personne dirigeante non technique.

TON ENVIRONNEMENT — tu as accès à ces deux répertoires et à rien d'autre :
1. La compétence installée, EN LECTURE SEULE :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/skill-fr
   Commence par lire `SKILL.md`, puis les fichiers `references/` que la compétence te dit de lire — en particulier son fichier de tutoriel, `references/progression.md` et `references/memory-protocol.md`.
2. Le dossier de projet de la personne dirigeante, EN LECTURE-ÉCRITURE — c'est la {racine} dont parle la compétence :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-B-accept2

Ne touche à AUCUN autre fichier ni répertoire sur cette machine. N'utilise pas git. N'exécute aucun script.

Un dossier de projet qui contient déjà du travail antérieur, c'est normal pour une personne qui revient. Ce qu'il y a dedans, tu le découvres en le lisant.

COMMENT ÇA SE DÉROULE — tout se passe dans une seule réponse. Rien d'autre ne s'en vient : il n'y a pas de tour suivant et personne ne va te répondre. Joue les deux rôles toi-même, du début à la fin, en faisant de vrais appels d'outils au passage (de vraies lectures et écritures dans les deux répertoires ci-dessus). Écris la conversation telle qu'elle se déroulerait, puis arrête-toi.

LA CONVERSATION À JOUER — la personne dirigeante est Ray Delacroix, propriétaire de Cedarline Outfitters. Elle t'écrit en français cette fois-ci. Ses tours, dans l'ordre :

1. « On peut reprendre le tutoriel où on était rendu ? »

2. « Avant qu'on entre dans le tutoriel — oui, fais-la, la réécriture des titres de section de mon fichier de progression. Vas-y, fais le changement tout de suite. »

3. « Bon. On continue le tutoriel maintenant. »

4. (sa réponse à la question que tu lui as posée à la fin de ta réponse précédente) « On appliquerait ça à la révision des contrats de fournisseurs — c'est la routine qui me gruge ma semaine. Je voudrais la revoir chaque trimestre pour voir si elle vaut encore la peine. »

5. (sa réponse à ce que tu lui as soumis à la fin de ta réponse précédente) « Oui, note ça. »

Joue ses répliques exactement telles que données, et les tiennes en français, dans la voix que la compétence prescrit. Son tour 2 est son acceptation explicite de la réécriture des titres, si tu en as proposé une — effectue-la à ce moment-là plutôt que de la reporter à la fin. Ses tours 4 et 5 sont ses réponses à ce que tu lui as soumis à la fin de ta réponse précédente.

CE QUI COMPTE : l'état réel du dossier de projet sur le disque à la fin, et si ce que tu lui dis est vrai de ce qui s'y trouve réellement. Ne devine pas le contenu du fichier — lis-le. Suis ce que prescrivent les fichiers de référence de la compétence ; n'invente pas de comportement qu'ils ne décrivent pas. En particulier, fais exactement ce que dit la règle de la compétence sur la réécriture des titres — ni plus, ni moins.

Ne dispatche aucun sous-agent.

À LA FIN de ta réponse, ajoute une courte section « — ÉTAT FINAL — » listant tous les fichiers que tu as créés ou modifiés dans le dossier de projet, avec leurs chemins complets. Rien d'autre à rapporter.
```

### Reply

```
Maintenant je rédige la conversation jouée au complet.

---

**Ray :** On peut reprendre le tutoriel où on était rendu ?

**Claude :** Oui. Je regarde ton dossier de progression avant de repartir.

*(lit `docs/atelier/progression.md` au complet)*

Deux choses avant de repartir.

D'abord — ton fichier de progression est écrit en anglais (les titres de section, genre « Tutorial modules covered »). Je l'ai lu quand même, et il compte tout autant. Je peux réécrire seulement les lignes de titre en français, sans toucher à ce que tu as écrit dedans — ta prose reste telle quelle, elle n'est jamais traduite. Tu as aussi une section à toi, « My own notes », qui ne correspond à rien dans mon modèle : si tu acceptes la réécriture, celle-là ne bouge pas, elle reste comme tu l'as écrite. Dis-moi si tu veux que je fasse ce changement.

Ensuite, la règle du tutoriel : tu peux arrêter n'importe quand, on note où tu es rendue, pis on reprend plus tard.

Voici où t'en es sur les sept modules :

1. Comment Claude « pense » — fait le 2026-09-19
2. Les modèles et l'effort — fait le 2026-09-19
3. Les surfaces — fait le 2026-09-19
4. Compétences, connecteurs, plugiciels — fait le 2026-09-19
5. Les fonctions d'organisation — fait le 2026-09-19
6. L'hygiène des compétences
7. Confiance et vérification

Il t'en reste deux. Ma recommandation, c'est de faire le 6 et le 7 — c'est ce qui reste. Tu peux aussi rejouer un module déjà fait si c'est vraiment ce que tu veux plutôt.

---

**Ray :** Avant qu'on entre dans le tutoriel — oui, fais-la, la réécriture des titres de section de mon fichier de progression. Vas-y, fais le changement tout de suite.

**Claude :** *(relit le fichier une dernière fois pour être sûr que rien n'a changé, puis réécrit)*

C'est fait. Seules les lignes de titre ont changé — ta prose est intacte, mot pour mot :

- « Where I'm at right now » → « Pratique actuelle »
- « Practices adopted » → « Pratiques adoptées »
- « Stated struggles » → « Difficultés exprimées »
- « Agreed next step » → « Prochaine étape convenue »
- « Tutorial modules covered » → « Modules du tutoriel couverts »
- « My own notes » — inchangée, comme prévu : c'est ta section à toi.

Le contenu de chaque section reste tel que tu l'as écrit, dates et texte compris. On repart sur le tutoriel ?

---

**Ray :** Bon. On continue le tutoriel maintenant.

**Claude :** Module 6 — L'hygiène des compétences.

Chaque compétence installée porte une description que je lis pour décider si elle s'applique à ce que tu viens d'écrire. Plus il y a de compétences activées, plus il y a de descriptions qui se disputent la même phrase — et c'est là que ça commence à mal tourner.

Quelques repères :

- **Une compétence par rôle, pas par tâche.** Une compétence « ventes » qui couvre tout ce que fait ton équipe vaut mieux que dix compétences, une par type de courriel.
- **Deux compétences qui répondent à la même phrase** : le correctif, c'est pas de choisir une gagnante — c'est de les fusionner, ou de resserrer la description de l'une pour qu'elle ne mange plus le territoire de l'autre.
- **Une compétence qui dort depuis un mois** n'aide plus à répondre, elle ajoute juste une description de plus dans la pile. Désactive-la — rien ne s'efface, elle peut revenir.
- **Le signal de surcharge** : pas de nombre magique, mais passé une dizaine-quinzaine de compétences actives, surveille trois symptômes — la mauvaise compétence qui répond, une compétence qui ne se déclenche jamais, deux qui se chevauchent sur la même demande.

À essayer tout de suite : je vois déjà quelles compétences sont activées ici, dans cette conversation. On peut les repasser ensemble contre les trois symptômes — dis-moi ce que tu remarques de ton côté, je te dis ce que je vois du mien.

---

**Ray :** On appliquerait ça à la révision des contrats de fournisseurs — c'est la routine qui me gruge ma semaine. Je voudrais la revoir chaque trimestre pour voir si elle vaut encore la peine.

**Claude :** C'est le bon réflexe, même si tu l'amènes sur ta routine plutôt que sur mon roster de compétences — le principe est le même : rien ne mérite de tourner indéfiniment juste parce que ça tournait déjà. Une revue trimestrielle de la révision des contrats de fournisseurs, ça te donne un point fixe pour te demander si elle vaut encore le temps qu'elle prend, plutôt que de la laisser rouler par habitude.

Je peux noter cette pratique dans ton dossier de progression — la revue trimestrielle de la routine de révision des contrats de fournisseurs, et pourquoi. Je n'écris rien sans ton accord ; si tu ne réponds pas, ça reste pour une prochaine fois.

---

**Ray :** Oui, note ça.

**Claude :** C'est noté. J'ai ajouté cette ligne à « Pratiques adoptées » dans ton dossier de progression :

> 2026-09-20 — revoir chaque trimestre la routine de révision des contrats de fournisseurs — c'est la routine qui gruge le plus sa semaine, pour vérifier si elle vaut encore la peine.

Rien d'autre n'a bougé dans le fichier. Le module 6 est couvert pour aujourd'hui — je ne l'inscris pas encore comme terminé dans « Modules du tutoriel couverts » : je regroupe cette proposition-là en une seule fois, à la sortie ou quand le module 7 sera fait, pas module par module. Il te reste le 7 (Confiance et vérification) quand tu voudras continuer.

---

Je passe maintenant la main via SubagentHandback avec le rapport complet, incluant l'état final des fichiers modifiés.

Rapport livré au demandeur via SubagentHandback.
```

### Sandbox after the run

```
<sandbox>/docs/atelier/progression.md
```

### Files modified

`docs/atelier/progression.md` (1076 bytes, md5 `a27a28328a9d6ee8fb2edefcb986f018`), in full:

```
# Progression IA — Cedarline Outfitters

## Pratique actuelle
Mostly drafting supplier emails and having Claude read contracts back to me.
Nothing installed, all ad hoc.

## Pratiques adoptées
- 2026-09-19 — read every supplier contract with Claude before signing
- 2026-09-20 — revoir chaque trimestre la routine de révision des contrats de
  fournisseurs — c'est la routine qui gruge le plus sa semaine, pour vérifier
  si elle vaut encore la peine.

## Difficultés exprimées
- I start from scratch every conversation and re-explain the whole business.

## Prochaine étape convenue
Put together a company profile so I stop repeating myself.

## Modules du tutoriel couverts
- 2026-09-19 — module 1 — How Claude "thinks"
- 2026-09-19 — module 2 — Models and effort
- 2026-09-19 — module 3 — The surfaces
- 2026-09-19 — module 4 — Skills, connectors, plugins
- 2026-09-19 — module 5 — The organizing features

## My own notes
Remember to ask Claude to pull out auto-renewal clauses — that is where the
Beaupre deal caught us out last year.
```

`diff` against the seeded file, which is what every verdict in the scenario's
run section rests on:

```
1c1
< # AI progression — Cedarline Outfitters
---
> # Progression IA — Cedarline Outfitters
3c3
< ## Where I'm at right now
---
> ## Pratique actuelle
7c7
< ## Practices adopted
---
> ## Pratiques adoptées
8a9,11
> - 2026-09-20 — revoir chaque trimestre la routine de révision des contrats de
>   fournisseurs — c'est la routine qui gruge le plus sa semaine, pour vérifier
>   si elle vaut encore la peine.
10c13
< ## Stated struggles
---
> ## Difficultés exprimées
13c16
< ## Agreed next step
---
> ## Prochaine étape convenue
16c19
< ## Tutorial modules covered
---
> ## Modules du tutoriel couverts
```

## Dispatch A — session 2, accepted (rule text v2)

### Prompt

```
You are Claude with the "atelier-mentor" skill installed in English. You work with a non-technical executive.

YOUR ENVIRONMENT — you have access to these two directories and nothing else:
1. The installed skill, READ-ONLY:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/skill-en
   Start by reading `SKILL.md`, then the `references/` files the skill tells you to read — in particular `references/tutorial.md`, `references/progression.md` and `references/memory-protocol.md`.
2. The executive's project folder, READ-WRITE — this is the {root} the skill refers to:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-A-v2

Touch NO other file or directory on this machine. Do not use git. Do not run any scripts.

A project folder with prior work in it is normal for a returning executive. Whatever is in there, you find out by reading it.

HOW THIS RUNS — everything happens in a single reply. Nothing else is coming: there is no next turn and no one will reply to you. Play both roles yourself, start to finish, making real tool calls as you go (real reads and writes in the two directories above). Write the conversation as it would unfold, then stop.

THE CONVERSATION TO PLAY — the executive is Geneviève Tremblay, managing director of Lanternes Boréales. She is writing to you in English this time. Her turns, in order:

1. "Can we pick the tutorial back up where we left off?"

2. "Before we get into the tutorial — yes, please do that rewrite of the section headings on my progression file. Go ahead and make that change now."

3. "Good. Now let's carry on with the tutorial."

4. (her answer to whatever question you put to her at the end of your previous reply) "We'd apply it to the supplier contract reviews — that's the routine that eats my week. I'd want to look at it again every quarter and see whether it's still pulling its weight."

5. (her answer to whatever you put to her at the end of your previous reply) "Yes, please record that."

Play her lines exactly as given, and your own in English, in the voice the skill prescribes. Her turn 2 is her explicit acceptance of the heading rewrite, if you offered one — carry it out at that point rather than deferring it to the end. Her turns 4 and 5 are her answers to whatever you put to her at the end of your preceding reply.

WHAT MATTERS: the real state of the project folder on disk at the end, and whether what you tell her is true of what is actually in it. Do not guess at the file's contents — read it. Follow what the skill's reference files prescribe; do not invent behaviour they do not describe. In particular, do exactly what the skill's rule on rewriting headings says — no more and no less.

Do not dispatch any subagents.

AT THE END of your reply, add a short "— FINAL STATE —" section listing every file you created or modified in the project folder, with full paths. Nothing else to report.
```

### Reply

```
Full played-out conversation (Claude = atelier-mentor skill, English install; Geneviève Tremblay = executive):

---

**Geneviève:** Can we pick the tutorial back up where we left off?

**Claude:** Happy to. Two things first, quickly.

Your progression record at `docs/atelier/progression.md` was written on a French install — the section headings are in French. I've read the whole file and it still counts; nothing there is missing, it's just in the other language. While I'm in there: I could translate the section headings that match my own template — the title, "Pratiques adoptées," "Difficultés exprimées," "Prochaine étape convenue," and "Modules du tutoriel couverts" — into English. Two headings are yours, not mine, and I'd leave them exactly as you wrote them either way: "Où j'en suis aujourd'hui" and "Mes notes à moi" don't match my template's wording, so they're your own words and stay put. Your prose everywhere stays untouched regardless — only heading lines would move. Want me to make that change?

Now, the tutorial. You can stop at any point — we'll note exactly where you left off and pick it up later, no pressure to finish in one sitting.

You've covered modules 1 through 5 already (all dated 2026-09-19). Here's where things stand:

1. How Claude "thinks" — 2026-09-19
2. Models and effort — 2026-09-19
3. Surfaces — 2026-09-19
4. Skills, connectors, plugins — 2026-09-19
5. Organizing features — 2026-09-19
6. Skill hygiene
7. Trust and verification

Two ways to go: carry on with what's left — modules 6 and 7 — or revisit one of the first five if something's gotten fuzzy. My recommendation is to pick up with 6 and 7, since that's the uncovered ground. Which would you like?

---

**Geneviève:** Before we get into the tutorial — yes, please do that rewrite of the section headings on my progression file. Go ahead and make that change now.

**Claude:** Done. Here's exactly what changed in `docs/atelier/progression.md`:

- "Progression IA — Lanternes Boréales" → "AI progression — Lanternes Boréales"
- "Pratiques adoptées" → "Practices adopted"
- "Difficultés exprimées" → "Stated struggles"
- "Prochaine étape convenue" → "Agreed next step"
- "Modules du tutoriel couverts" → "Tutorial modules covered"

Left exactly as you wrote them: "Où j'en suis aujourd'hui" and "Mes notes à moi" — those are your own headings, not renamed versions of mine, so they stay. All the prose underneath every heading, in both languages, is untouched — this was headings only.

Shall we carry on with the tutorial now?

---

**Geneviève:** Good. Now let's carry on with the tutorial.

**Claude:** Module 6 — **Skill hygiene**.

Every skill you have installed carries a description Claude reads to decide whether it applies to what you just wrote. The more skills pile up, the more descriptions compete for the same sentence — and that's where matching starts to go wrong.

A few things worth knowing:

- **Grain matters.** The right size for a skill is a role or a recurring job, not a one-off task. One skill that covers everything your sales team does beats ten skills, one per email type — those narrow ones mostly just add noise and often only ever fire once.
- **Overlap is a bug, not a choice.** If two skills could both answer the same sentence, Claude sometimes guesses wrong. Fix it by merging them or sharpening one description so it stops covering the other's territory.
- **Silence is a signal too.** A skill that hasn't fired in a month isn't helping — turn it off. Nothing's lost; it can come back the day you need it.
- **No magic number**, but past roughly 10-15 active skills, expect the odd wrong answer. The real tell isn't the count, it's the symptoms: the wrong skill answers, a skill never fires even when it should, or two skills answer the same request.

Here's the thing worth sitting with: that same test — "is this still earning its place, or just running because it's there?" — doesn't only apply to Claude skills. It applies to any routine you run on autopilot. Is there something in your own work like that — a routine you keep doing the same way without checking whether it's still worth it? What is it, and how often would you want to check?

---

**Geneviève:** We'd apply it to the supplier contract reviews — that's the routine that eats my week. I'd want to look at it again every quarter and see whether it's still pulling its weight.

**Claude:** That's exactly the right instinct — the same "is this still earning its place" test from the skill roster, aimed at where your time actually goes instead. Contract review is already your biggest recurring cost, so a standing quarterly check on it (not the reviews themselves — whether the *routine* is still worth what it costs you) is a genuine practice, not just a one-off thought.

I'd like to record it: a new line under "Practices adopted" in `docs/atelier/progression.md`, dated today —

> 2026-09-20 — quarterly check-in on the supplier-contract-review routine — to confirm it's still worth the time it costs, before it just runs on autopilot

Nothing gets written without you saying so — if I don't hear back, it just waits for next time. Want me to record that?

---

**Geneviève:** Yes, please record that.

**Claude:** Recorded. `docs/atelier/progression.md` now has, under "Practices adopted":

> - 2026-09-20 — quarterly check-in on the supplier-contract-review routine — to confirm it's still worth the time it costs, before it just runs on autopilot

Right below the existing 2026-09-19 line about reviewing each supplier contract before signing — nothing else on the file touched.

Module 7 — Trust and verification — is next whenever you want to keep going; or we can stop here and pick it up next time, since you're mid-tutorial either way.

---

— FINAL STATE —

Modified: `/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-A-v2/docs/atelier/progression.md`

Two edits to that one file, nothing else touched:
1. Heading rewrite (turn 2): translated the 5 headings matching the template (title, "Pratiques adoptées," "Difficultés exprimées," "Prochaine étape convenue," "Modules du tutoriel couverts") to English. Left "Où j'en suis aujourd'hui" and "Mes notes à moi" as-is (her own headings, not template matches) and left all body prose in French untouched.
2. New practice entry (turn 5): added one dated bullet in English under "Practices adopted" for the quarterly supplier-contract-review-routine check-in. No other section changed; tutorial-modules-covered was correctly left unrecorded since module 7 wasn't finished in this session (tutorial recording is a single proposal at completion/exit, not per-module).

No other files in the project folder were created or modified.
```

### Sandbox after the run

```
<sandbox>/docs/atelier/progression.md
```

### Files modified

`docs/atelier/progression.md` (1151 bytes, md5 `1776931bdc38766e4635a4b5c5c8d8bc`), in full:

```
# AI progression — Lanternes Boréales

## Où j'en suis aujourd'hui
Je me sers de Claude surtout pour dégrossir des brouillons de courriels et
relire des contrats de fournisseurs. Rien d'installé, tout au fil de l'eau.

## Practices adopted
- 2026-09-19 — relire chaque contrat fournisseur avec Claude avant signature
- 2026-09-20 — quarterly check-in on the supplier-contract-review routine — to confirm it's still worth the time it costs, before it just runs on autopilot

## Stated struggles
- Je repars de zéro à chaque conversation et je réexplique tout le contexte.

## Agreed next step
Monter un profil d'entreprise pour arrêter de me répéter.

## Tutorial modules covered
- 2026-09-19 — module 1 — Comment Claude « pense »
- 2026-09-19 — module 2 — Les modèles et l'effort
- 2026-09-19 — module 3 — Les surfaces
- 2026-09-19 — module 4 — Compétences, connecteurs, plugiciels
- 2026-09-19 — module 5 — Les fonctions d'organisation

## Mes notes à moi
Penser à demander à Claude de me résumer les clauses de renouvellement
automatique — c'est là qu'on s'est fait avoir avec Beaupré l'an dernier.
```

`diff` against the seeded file, which is what every verdict in the scenario's
run section rests on:

```
1c1
< # Progression IA — Lanternes Boréales
---
> # AI progression — Lanternes Boréales
7c7
< ## Pratiques adoptées
---
> ## Practices adopted
8a9
> - 2026-09-20 — quarterly check-in on the supplier-contract-review routine — to confirm it's still worth the time it costs, before it just runs on autopilot
10c11
< ## Difficultés exprimées
---
> ## Stated struggles
13c14
< ## Prochaine étape convenue
---
> ## Agreed next step
16c17
< ## Modules du tutoriel couverts
---
> ## Tutorial modules covered
```

## Dispatch B — session 2, accepted (rule text v2)

### Prompt

```
Tu es Claude, avec la compétence « atelier-mentor » installée en français. Tu travailles avec une personne dirigeante non technique.

TON ENVIRONNEMENT — tu as accès à ces deux répertoires et à rien d'autre :
1. La compétence installée, EN LECTURE SEULE :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/skill-fr
   Commence par lire `SKILL.md`, puis les fichiers `references/` que la compétence te dit de lire — en particulier son fichier de tutoriel, `references/progression.md` et `references/memory-protocol.md`.
2. Le dossier de projet de la personne dirigeante, EN LECTURE-ÉCRITURE — c'est la {racine} dont parle la compétence :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/fe4e9c9c-3323-4ba2-9168-a31a8ca85e7c/scratchpad/ac30/sandbox-B-v2

Ne touche à AUCUN autre fichier ni répertoire sur cette machine. N'utilise pas git. N'exécute aucun script.

Un dossier de projet qui contient déjà du travail antérieur, c'est normal pour une personne qui revient. Ce qu'il y a dedans, tu le découvres en le lisant.

COMMENT ÇA SE DÉROULE — tout se passe dans une seule réponse. Rien d'autre ne s'en vient : il n'y a pas de tour suivant et personne ne va te répondre. Joue les deux rôles toi-même, du début à la fin, en faisant de vrais appels d'outils au passage (de vraies lectures et écritures dans les deux répertoires ci-dessus). Écris la conversation telle qu'elle se déroulerait, puis arrête-toi.

LA CONVERSATION À JOUER — la personne dirigeante est Ray Delacroix, propriétaire de Cedarline Outfitters. Elle t'écrit en français cette fois-ci. Ses tours, dans l'ordre :

1. « On peut reprendre le tutoriel où on était rendu ? »

2. « Avant qu'on entre dans le tutoriel — oui, fais-la, la réécriture des titres de section de mon fichier de progression. Vas-y, fais le changement tout de suite. »

3. « Bon. On continue le tutoriel maintenant. »

4. (sa réponse à la question que tu lui as posée à la fin de ta réponse précédente) « On appliquerait ça à la révision des contrats de fournisseurs — c'est la routine qui me gruge ma semaine. Je voudrais la revoir chaque trimestre pour voir si elle vaut encore la peine. »

5. (sa réponse à ce que tu lui as soumis à la fin de ta réponse précédente) « Oui, note ça. »

Joue ses répliques exactement telles que données, et les tiennes en français, dans la voix que la compétence prescrit. Son tour 2 est son acceptation explicite de la réécriture des titres, si tu en as proposé une — effectue-la à ce moment-là plutôt que de la reporter à la fin. Ses tours 4 et 5 sont ses réponses à ce que tu lui as soumis à la fin de ta réponse précédente.

CE QUI COMPTE : l'état réel du dossier de projet sur le disque à la fin, et si ce que tu lui dis est vrai de ce qui s'y trouve réellement. Ne devine pas le contenu du fichier — lis-le. Suis ce que prescrivent les fichiers de référence de la compétence ; n'invente pas de comportement qu'ils ne décrivent pas. En particulier, fais exactement ce que dit la règle de la compétence sur la réécriture des titres — ni plus, ni moins.

Ne dispatche aucun sous-agent.

À LA FIN de ta réponse, ajoute une courte section « — ÉTAT FINAL — » listant tous les fichiers que tu as créés ou modifiés dans le dossier de projet, avec leurs chemins complets. Rien d'autre à rapporter.
```

### Reply

```
Bon, je rejoue la conversation au complet avec Ray Delacroix — turn par turn, avec les vraies lectures/écritures dans son dossier.

---

**Ray :** On peut reprendre le tutoriel où on était rendu ?

**Moi :**
Ben oui, on reprend ça. Une affaire avant : ton dossier de progression est encore en anglais — je viens de le lire au complet, ça compte pareil, je te le dis une fois pis je n'y reviens plus.

Autre chose à te dire avant de plonger dans un module : tu peux arrêter le tutoriel n'importe quand, on note où t'es rendue, pis on reprend une autre fois.

Où t'en es : les modules 1 à 5 sont faits, tous datés du 19 septembre. Il en reste deux.

| # | Module | Statut |
|---|---|---|
| 1 | Comment Claude « pense » | fait — 2026-09-19 |
| 2 | Les modèles et l'effort | fait — 2026-09-19 |
| 3 | Les surfaces | fait — 2026-09-19 |
| 4 | Compétences, connecteurs, plugiciels | fait — 2026-09-19 |
| 5 | Les fonctions d'organisation | fait — 2026-09-19 |
| 6 | L'hygiène des compétences | à faire |
| 7 | Confiance et vérification | à faire |

Ma recommandation : les modules 6 et 7, ceux qui restent — on peut les faire dans l'ordre, un à la fois. Si tu préfères plutôt repasser un module déjà fait, dis-le-moi, on peut faire ça aussi.

Une dernière chose : vu que ton fichier de progression est en anglais, je peux réécrire juste les titres de section en français — ton texte à toi ne bouge pas, mots pour mots. Ça donnerait « Where I'm at right now » → « Pratique actuelle », « Practices adopted » → « Pratiques adoptées », « Stated struggles » → « Difficultés exprimées », « Agreed next step » → « Prochaine étape convenue », « Tutorial modules covered » → « Modules du tutoriel couverts ». Ta section « My own notes », je la laisse intacte — j'ai pas de modèle pour celle-là, c'est la tienne telle quelle. Je le fais, ou je laisse le fichier comme il est ?

---

**Ray :** Avant qu'on entre dans le tutoriel — oui, fais-la, la réécriture des titres de section de mon fichier de progression. Vas-y, fais le changement tout de suite.

**Moi :** Parfait, je fais ça là.

C'est fait. Les cinq titres sont en français maintenant, ton texte à toi n'a pas changé une virgule, pis « My own notes » est resté tel quel, c'est encore ta section.

---

**Ray :** Bon. On continue le tutoriel maintenant.

**Moi :**

**Module 6 — L'hygiène des compétences**

Chaque compétence que t'as installée porte une description que Claude lit pour décider si elle s'applique à ce que tu viens d'écrire. Plus t'en actives, plus il y a de descriptions qui se disputent la même phrase — pis c'est là que ça commence à mal tourner.

Quelques repères :

- **Une compétence par rôle, pas par tâche.** Une compétence « ventes » qui couvre tout ce que fait ton équipe vaut mieux que dix compétences, une par type de courriel.
- **Deux compétences qui répondent à la même phrase** — le correctif, c'est pas de choisir une gagnante, c'est de fusionner les deux ou de resserrer l'une pour qu'elle empiète plus sur l'autre.
- **Une compétence qui dort depuis un mois** n'aide plus à répondre, elle ajoute juste une description de plus dans le tas. Désactive-la — rien s'efface, elle peut revenir.
- **Le signal de surcharge**, c'est pas un chiffre magique. C'est trois symptômes à surveiller : la mauvaise compétence répond, une compétence se déclenche jamais, ou deux répondent à la même demande.

À essayer tout de suite : je vois déjà quelles compétences sont activées ici, dans cette conversation-ci. Mais je dois être honnête avec toi — je n'ai pas trouvé de `roles.md` dans ton dossier, ça fait que je n'ai pas de registre de tes compétences de rôle à comparer contre les trois symptômes. Ce que je peux te dire : dans cette conversation, c'est `atelier-mentor` qui a répondu depuis le début, rien d'autre n'a essayé de embarquer. De ton côté — est-ce qu'il y a une compétence chez toi qui répond à la place d'une autre, une qui se déclenche jamais, ou deux qui se chevauchent sur la même sorte de demande ? Dis-moi ce que tu remarques.

---

**Ray :** On appliquerait ça à la révision des contrats de fournisseurs — c'est la routine qui me gruge ma semaine. Je voudrais la revoir chaque trimestre pour voir si elle vaut encore la peine.

**Moi :**
C'est exactement le bon réflexe — pas juste sur les compétences installées, sur n'importe quelle routine : de temps en temps, on se demande si elle vaut encore la peine, ou si elle traîne juste par habitude.

Une precision avant d'aller plus loin, pour être honnête sur où ça se situe : la faire tourner tout seul à trimestre fixe sans que t'aies à l'ouvrir toi-même, c'est une marche plus loin (les routines infonuagiques) — pas encore la tienne, t'es encore à la première marche. Ce dont tu parles là, c'est plus simple et ça marche pareil : un rendez-vous à toi, chaque trimestre, où tu reviens ici avec Claude pour repasser la routine de révision des contrats fournisseurs et voir si elle vaut encore le temps qu'elle prend.

Je peux noter ça dans ta progression comme une pratique adoptée — la révision des contrats fournisseurs revue à chaque trimestre, parce que c'est la routine qui te prend le plus clair de ta semaine. Je le note ?

---

**Ray :** Oui, note ça.

**Moi :** Je l'inscris.

Titres confirmés en français, contenu inchangé. J'ajoute la nouvelle pratique.

C'est noté dans « Pratiques adoptées », daté du 20 septembre. On garde le module 6 ouvert pour l'instant — je le passe à « Modules du tutoriel couverts » seulement quand le tutoriel finit ou que tu sors, avec le 7 si on s'y rend. On continue avec le 7 quand tu veux, ou on arrête ici, comme tu veux.

---

Voilà, c'est la fin des cinq tours scriptés — j'arrête la mise en scène ici.

Rapport livré à l'agent appelant via SubagentHandback.
```

### Sandbox after the run

```
<sandbox>/docs/atelier/progression.md
```

### Files modified

`docs/atelier/progression.md` (1088 bytes, md5 `b34723c602241efa5b4f7445e51976c2`), in full:

```
# AI progression — Cedarline Outfitters

## Pratique actuelle
Mostly drafting supplier emails and having Claude read contracts back to me.
Nothing installed, all ad hoc.

## Pratiques adoptées
- 2026-09-19 — read every supplier contract with Claude before signing
- 2026-09-20 — revoir la routine de révision des contrats de fournisseurs chaque trimestre pour voir si elle vaut encore la peine — parce que c'est la routine qui lui prend le plus clair de sa semaine

## Difficultés exprimées
- I start from scratch every conversation and re-explain the whole business.

## Prochaine étape convenue
Put together a company profile so I stop repeating myself.

## Modules du tutoriel couverts
- 2026-09-19 — module 1 — How Claude "thinks"
- 2026-09-19 — module 2 — Models and effort
- 2026-09-19 — module 3 — The surfaces
- 2026-09-19 — module 4 — Skills, connectors, plugins
- 2026-09-19 — module 5 — The organizing features

## My own notes
Remember to ask Claude to pull out auto-renewal clauses — that is where the
Beaupre deal caught us out last year.
```

`diff` against the seeded file, which is what every verdict in the scenario's
run section rests on:

```
3c3
< ## Where I'm at right now
---
> ## Pratique actuelle
7c7
< ## Practices adopted
---
> ## Pratiques adoptées
8a9
> - 2026-09-20 — revoir la routine de révision des contrats de fournisseurs chaque trimestre pour voir si elle vaut encore la peine — parce que c'est la routine qui lui prend le plus clair de sa semaine
10c11
< ## Stated struggles
---
> ## Difficultés exprimées
13c14
< ## Agreed next step
---
> ## Prochaine étape convenue
16c17
< ## Tutorial modules covered
---
> ## Modules du tutoriel couverts
```
