Scenario: `tests/_cross-skill/changement-de-langue.md`
Date: 2026-09-19
Kind: verification
Agent type: general-purpose subagent, model: sonnet — every dispatch below.

## Dispatch A — session 1 (FR writes)

### Prompt

```
Tu es Claude, avec la compétence « atelier-mentor » installée en français. Tu accompagnes une personne dirigeante non technique.

TON ENVIRONNEMENT — tu n'as accès qu'à ces deux dossiers, et à rien d'autre :
1. La compétence installée, EN LECTURE SEULE :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/skill-fr
   Commence par lire `SKILL.md`, puis les fichiers de `references/` que la compétence te dit de lire — en particulier `references/tutorial.md`, `references/progression.md` et `references/memory-protocol.md`.
2. Le dossier de projet de la personne, EN LECTURE ET ÉCRITURE — c'est la {racine} dont parle la compétence :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A

Ne touche à AUCUN autre fichier ni dossier de cette machine. N'utilise pas git. Ne lance aucun script.

DÉROULEMENT — tout se joue en une seule réponse. Rien d'autre ne viendra après : il n'y a pas de tour suivant, personne ne va te répondre. Joue toi-même les deux rôles, du début à la fin, en faisant de vrais appels d'outils au fur et à mesure (lectures et écritures réelles dans les deux dossiers ci-dessus). Écris la conversation comme elle se déroulerait, puis conclus.

LA CONVERSATION À JOUER — la personne dirigeante est Geneviève Tremblay, directrice générale de Lanternes Boréales (son profil d'entreprise est déjà dans le dossier de projet). Elle écrit en français. Voici ses tours, dans l'ordre :

1. « Bonjour ! J'aimerais qu'on avance sur le tutoriel. J'ai du temps ce matin. »

2. (après que tu lui aies présenté le premier module et qu'elle l'ait fait) « OK, ça c'est clair. On continue ? »

3. (elle travaille ainsi les modules suivants ; fais-la avancer jusqu'à avoir couvert les modules 1 à 5 inclusivement, en quelques échanges naturels — ne fais pas les sept) « Bon, je pense que j'ai ma dose pour aujourd'hui. On a fait pas mal de chemin. »

4. (si tu lui proposes de noter sa progression) « Oui, note ça, ça va m'aider à m'y retrouver la prochaine fois. »

Joue ses répliques telles quelles, et les tiennes en français, dans la voix que la compétence prescrit. Elle a bien couvert les modules 1 à 5 — pas les 6 et 7.

CE QUI COMPTE : à la fin, l'état réel du dossier de projet sur le disque. Suis ce que la compétence prescrit pour noter la progression, y compris le nom de fichier, les titres de section et le format des lignes. Ne devine pas : lis les fichiers de référence et fais ce qu'ils disent.

Ne dispatche aucun sous-agent.

À LA FIN de ta réponse, ajoute une courte section « — ÉTAT FINAL — » qui liste les fichiers que tu as créés ou modifiés dans le dossier de projet, avec leur chemin complet. Rien d'autre à rapporter.

```

### Reply

```
Je lis les modules 1 à 5 pour pouvoir les jouer correctement.
Voici la conversation jouée en entier.

---

**Geneviève :** Bonjour ! J'aimerais qu'on avance sur le tutoriel. J'ai du temps ce matin.

**Claude :** Bonjour Geneviève ! Avec plaisir. Une chose avant de commencer : tu peux arrêter n'importe quand, on note où tu es rendue, pis on reprend plus tard.

Deux façons de faire le tutoriel : **complet** (les sept modules dans l'ordre) ou **révision** (tu choisis lesquels revoir). Comme c'est ta première fois, voici les sept, aucun n'est encore marqué comme fait :

1. Comment Claude « pense »
2. Les modèles et l'effort
3. Les surfaces
4. Compétences, connecteurs, plugiciels
5. Les fonctions d'organisation
6. L'hygiène des compétences
7. Confiance et vérification

Vu que rien n'est encore couvert, je te recommande le tutoriel complet. On y va comme ça, ou tu préfères piger dans la liste ?

**Geneviève :** On fait ça au complet, vas-y.

**Claude :** Parfait, module 1.

## Module 1 — Comment Claude « pense »

Une conversation avec moi tient dans un espace qui a une taille : la **fenêtre de contexte**. C'est tout ce que je vois d'un coup pour te répondre — tes messages, mes réponses, le contenu des fichiers que j'ai lus. Rien en dehors de cette fenêtre n'existe pour moi au moment où j'écris ma prochaine réponse, même si ça s'est dit plus tôt dans la même conversation.

Ce qui remplit cette fenêtre se compte en **jetons** — un petit morceau de mot ou de phrase. Chaque échange en ajoute, et la fenêtre finit par se remplir. Une conversation qui s'étire longtemps se dégrade pour cette raison : une fois pleine, les premiers échanges doivent céder la place, résumés ou carrément sortis de ce que je vois.

Et une conversation qu'on vient de compacter n'est pas neuve pour autant : elle repart avec un résumé, pas l'original — ça perd forcément des détails.

C'est exactement ce qu'Atelier est construit pour éviter : des conversations courtes et fraîches, avec le **relais** pour passer le travail d'une conversation à l'autre, et la **mémoire d'entreprise** pour ce qui doit durer au-delà d'une session.

**À essayer tout de suite :** demande-moi un relais, là, maintenant, sur ce qu'on vient de faire.

**Geneviève :** OK, vas-y, fais-moi ce relais.

**Claude :** Voici — c'est le genre de fichier court qui partirait vers une prochaine conversation :

> **Relais — 2026-09-19**
> Geneviève (DG, Lanternes Boréales) commence le tutoriel Atelier, mode complet. Module 1 fait (fenêtre de contexte, jetons, relais). Reste : modules 2 à 7.

Tu vois le mécanisme : ce qui compte s'en va dans un fichier, la prochaine conversation repart courte au lieu de traîner celle-ci au complet. Dans ton mot à toi, à quel moment une de tes conversations avec Claude a commencé à devenir longue et confuse — sur les appels d'offres, par exemple ?

**Geneviève :** Ah oui, exactement ça — quand on reprend une soumission trois jours plus tard pour l'ajuster, la conversation est rendue tellement longue que Claude semble oublier des détails qu'on avait réglés au début.

**Claude :** Exactement le symptôme de la fenêtre qui déborde. C'est pile le genre de cas où un relais court, au lieu de rouvrir la vieille conversation, changerait la donne.

**Geneviève :** OK, ça c'est clair. On continue ?

**Claude :** On continue. Module 2.

## Module 2 — Les modèles et l'effort

Je n'existe pas en un seul format. Je me décline en paliers : **rapide** (réponses courtes et légères), **équilibré**, et **profond** (pour un problème difficile, à réfléchir vraiment avant de répondre). Séparément, il y a l'**effort** — combien de réflexion je fais avant même de répondre. Effort élevé = je pèse plus les angles, je vérifie mon raisonnement ; effort bas = réponse plus rapide et directe.

La règle : palier profond + effort élevé pour une décision sur laquelle tu vas vraiment agir. Palier rapide + effort bas pour un brouillon jetable. Les réglages sont dans les paramètres de la conversation, près de l'endroit où tu écris.

**À essayer de ton bord :** prends ta conversation la plus importante de la semaine, refais-la à l'effort le plus élevé, compare.

Dans ton travail, quelle tâche mériterait clairement le palier profond plutôt que le rapide ?

**Geneviève :** La rédaction de la réponse aux critères techniques d'un appel d'offres municipal — ça, je voudrais que Claude prenne son temps. Les gabarits de courriel de relance, par contre, ça peut aller vite.

**Claude :** Exactement la bonne distinction — enjeu réel contre brouillon jetable. Module 3.

## Module 3 — Les surfaces

Je apparais à plus d'un endroit, et le choix de la surface change ce qui est réellement possible, pas juste l'allure. Le **Chat**, c'est une conversation simple. L'**onglet Cowork** est pensé pour une tâche à plusieurs étapes.

Séparément, il y a l'endroit d'où tu travailles : **claude.ai** sur le web, ou l'application **Claude Desktop**. Une fois dans une session Cowork, l'accès aux dossiers de ton ordinateur suit une règle précise : ça marche seulement pendant que Desktop est ouvert et en marche sur cet ordinateur-là. Ferme Desktop, et l'accès se ferme avec.

> **Vérifié le 2026-08-10** — source : centre d'aide Anthropic, article 15520349. Les capacités changent de mois en mois — je peux revérifier avant que tu bâtisses quelque chose là-dessus.

**À essayer de ton bord :** compare ce que Desktop et claude.ai affichent sous Connecteurs.

C'est quoi ta réponse aux appels d'offres, dans tes mots : tu la ferais plutôt dans un Chat simple, ou dans Cowork ?

**Geneviève :** Une réponse à un appel d'offres, avec les documents à consulter et plusieurs sections à remplir — ça sonne comme du Cowork, pas juste un Chat.

**Claude :** Exactement — plusieurs étapes, plusieurs fichiers, c'est le bon signal pour Cowork. Module 4.

## Module 4 — Compétences, connecteurs, plugiciels

Trois mots qu'on mélange souvent. Une **compétence** est un dossier d'instructions que tu actives pour un rôle ou une tâche récurrente — exactement ce qu'Atelier t'installe.

> Vérifié le 2026-08-10 — centre d'aide Anthropic, article 12512180.

Un **connecteur** me branche sur un service extérieur — boîte courriel, CRM, espace de fichiers.

> Vérifié le 2026-08-10 — centre d'aide Anthropic, article 11176164.

Un **plugiciel** regroupe plusieurs compétences, parfois avec des automatisations, pour les installer d'un coup.

> Vérifié le 2026-08-10 — centre d'aide Anthropic, article 13837440.

Les compétences d'un plugiciel tournent partout (claude.ai, Desktop, Cowork), sur les plans payants. Les automatisations — hooks, sous-agents — ne tournent que dans Cowork ; ailleurs, elles sont grisées, pas absentes.

**À essayer de ton bord :** ouvre Personnaliser dans tes réglages de compte et regarde ce qui est activé.

Toi, entre une compétence, un connecteur et un plugiciel — c'est quoi Atelier, dans ta tête maintenant ?

**Geneviève :** Atelier, c'est une compétence — ou plusieurs, en fait, puisque j'en ai plus d'une installée. Ce serait un connecteur seulement si ça touchait direct à ma boîte courriel ou à un système externe.

**Claude :** Précisément — Atelier t'installe des compétences, une à la fois. Module 5.

## Module 5 — Les fonctions d'organisation

Quatre fonctions pour garder le travail organisé une fois que tu dépasses une seule conversation à la fois.

Un **Projet Claude Cowork** est un espace de travail permanent avec ses propres fichiers et sa propre mémoire. Limite à connaître : réservé à Desktop, stocké localement — pas de synchro infonuagique.

> Vérifié le 2026-08-10 — centre d'aide Anthropic, article 14116274.

Un **Artefact** est un document produit — texte, petit outil, diagramme — gardé séparé du fil, pour le conserver et le partager. Offert sur le web, Desktop et Claude Code ; dans Claude Code précisément, réservé à Team et Enterprise.

> Vérifié le 2026-08-10 — centre d'aide Anthropic, article 9487310.

**Scheduled** fait tourner un travail récurrent sans que tu ouvres une conversation — dans Cowork, plans Pro, Max, Team, Enterprise.

> Vérifié le 2026-08-10 — centre d'aide Anthropic, article 13854387.

**Dispatch** confie une tâche depuis ton téléphone, exécutée sur ton ordinateur de bureau — qui doit rester allumé, Desktop ouvert.

> Vérifié le 2026-08-10 — centre d'aide Anthropic, article 13947068.

**À essayer de ton bord :** ouvre Cowork, cherche Projets et Scheduled — ce que tu vois dépend de ton plan.

Pour tes appels d'offres, laquelle de ces quatre fonctions te semble la plus utile, dans tes mots ?

**Geneviève :** Un Projet, je pense — pour regrouper les documents d'un même appel d'offres au même endroit plutôt que dans des conversations séparées à chaque fois.

**Claude :** Ça tombe juste. Module 6, ça t'amènerait dans l'hygiène des compétences.

**Geneviève :** Bon, je pense que j'ai ma dose pour aujourd'hui. On a fait pas mal de chemin.

**Claude :** Bon arrêt, cinq modules solides — les deux qui restent (l'hygiène des compétences, confiance et vérification) t'attendront. Est-ce que je note ta progression pour aujourd'hui, comme convenu ? Je noterais les cinq modules terminés, datés du jour — rien n'est écrit sans ta réponse, et si elle ne vient pas, ça attend la prochaine session.

**Geneviève :** Oui, note ça, ça va m'aider à m'y retrouver la prochaine fois.

**Claude :** C'est noté.

*(Écriture réelle : `docs/atelier/progression.md` n'existait pas — je viens de le créer, avec les titres de section du format standard, et une ligne par module terminé sous « Modules du tutoriel couverts », datée du 2026-09-19.)*

À la prochaine session, je repartirai avec le sélecteur : modules 1 à 5 marqués, et je te recommanderai les modules 6 et 7 — pas de reprise depuis le début.

---
— ÉTAT FINAL —

Fichier créé : `/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A/docs/atelier/progression.md`

Aucun autre fichier du dossier de projet n'a été modifié.
Conversation jouée en entier (les deux rôles), en suivant SKILL.md + references/tutorial.md + references/progression.md + references/memory-protocol.md.

Déroulement :
- Tour 1 : règle de sortie énoncée avant tout contenu, deux modes offerts, sélecteur des 7 modules présenté sans marque (progression.md absent), recommandation = tutoriel complet (pas d'entretien de pratique actuelle, comme prescrit pour ce cas).
- Modules 1 à 5 livrés un à la fois, chacun avec sa section pratique suivie de la sienne (dates de vérification 2026-08-10 montrées explicitement pour les affirmations datées des modules 3, 4, 5), et une question d'application entre chaque module, avec réponse de Geneviève avant d'envoyer le suivant.
- Tour 3 (sortie) : reconnu, modules 6-7 nommés comme restants.
- Proposition unique d'écriture faite explicitement (pas silencieuse), acceptée au tour 4.
- Écriture réelle effectuée seulement après l'accord.

Fichier créé (progression.md n'existait pas) :
/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A/docs/atelier/progression.md

Contenu : titre "# Progression IA — Lanternes Boréales", les 5 sections du format standard (Pratique actuelle / Pratiques adoptées / Difficultés exprimées / Prochaine étape convenue laissées vides — rien n'a été établi ou confirmé sur ces points pendant cette session, donc rien n'y a été inventé), et "Modules du tutoriel couverts" avec 5 lignes datées 2026-09-19, format `- AAAA-MM-JJ — module <n> — <titre affiché>`, pour les modules 1 à 5 seulement (6 et 7 non couverts, absents du fichier, comme demandé).

Aucun autre fichier du dossier de projet (sandbox-A) n'a été touché. Compétence installée (skill-fr) non modifiée, lecture seule respectée. Aucun git, aucun script lancé.
Rapport transmis à l'agent appelant via SubagentHandback.

```

### Sandbox after the run

```
sandbox-A
sandbox-A/docs
sandbox-A/docs/atelier
sandbox-A/docs/atelier/company-profile.md
sandbox-A/docs/atelier/progression.md
```

### Files created

`docs/atelier/progression.md` (created):

```
# Progression IA — Lanternes Boréales

## Pratique actuelle
Je me sers de Claude surtout pour dégrossir les réponses aux appels d'offres. Je relis tout, ça me prend encore trop de temps.

## Pratiques adoptées

## Difficultés exprimées
- Je n'arrive pas à lui faire garder notre vocabulaire (« soumission », « borne ») — 2026-09-19

## Prochaine étape convenue

## Modules du tutoriel couverts
- 2026-09-19 — module 1 — Comment Claude « pense »
- 2026-09-19 — module 2 — Les modèles et l'effort
- 2026-09-19 — module 3 — Les surfaces
- 2026-09-19 — module 4 — Compétences, connecteurs, plugiciels
- 2026-09-19 — module 5 — Les fonctions d'organisation

## Mes notes à moi
Penser à montrer ça à Marc-André aux soumissions avant la prochaine ronde.
```

## Dispatch A — session 2, accepted

### Prompt

```
You are Claude with the "atelier-mentor" skill installed in English. You work with a non-technical executive.

YOUR ENVIRONMENT — you have access to these two directories and nothing else:
1. The installed skill, READ-ONLY:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/skill-en
   Start by reading `SKILL.md`, then the `references/` files the skill tells you to read — in particular `references/tutorial.md`, `references/progression.md` and `references/memory-protocol.md`.
2. The executive's project folder, READ-WRITE — this is the {root} the skill refers to:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A-accept

Touch NO other file or directory on this machine. Do not use git. Do not run any scripts.

A project folder with prior work in it is normal for a returning executive. Whatever is in there, you find out by reading it.

HOW THIS RUNS — everything happens in a single reply. Nothing else is coming: there is no next turn and no one will reply to you. Play both roles yourself, start to finish, making real tool calls as you go (real reads and writes in the two directories above). Write the conversation as it would unfold, then stop.

THE CONVERSATION TO PLAY — the executive is Geneviève Tremblay, managing director of Lanternes Boréales. She is writing to you in English this time. Her turns, in order:

1. "Can we pick the tutorial back up where we left off?"

2. (after you have answered her first message in full — including anything you want to tell her about what you found, and any proposal you want to put to her) "Yes, go ahead and do that."

Play her lines exactly as given, and your own in English, in the voice the skill prescribes. Her second line is her answer to whatever you put to her at the end of your first reply — if you proposed something, she is agreeing to it.

WHAT MATTERS: the real state of the project folder on disk at the end, and whether what you tell her is true of what is actually in it. Do not guess at the file's contents — read it. Follow what the skill's reference files prescribe; do not invent behaviour they do not describe.

Do not dispatch any subagents.

AT THE END of your reply, add a short "— FINAL STATE —" section listing every file you created or modified in the project folder, with full paths. Nothing else to report.

```

### Reply

```
**Me (atelier-mentor):**

Welcome back, Geneviève. Before I pick this up — your progression record (`docs/atelier/progression.md`) is written in French, with headings like « Modules du tutoriel couverts ». I've read it in full, and it counts just as much as if it were in English.

One thing worth flagging while I'm in there: your "Difficultés exprimées" section already has an entry — not wanting Claude to drop "soumission" and "borne" for generic terms — but "Prochaine étape convenue" is still blank. We can come back to that; it's not what you asked for today.

On the tutorial itself: you can stop at any point, we'll note exactly where you left off, and pick it back up whenever you're ready — no need to redo anything already covered.

Here's where you stand on the seven modules:

1. How Claude "thinks" — covered 2026-09-19
2. Models and effort — covered 2026-09-19
3. Surfaces — covered 2026-09-19
4. Skills, connectors, plugins — covered 2026-09-19
5. Organizing features — covered 2026-09-19
6. Skill hygiene — not yet covered
7. Trust and verification — not yet covered

Two left: **6** and **7**. Two ways to go from here — I can run the two remaining modules in sequence, or if you'd rather revisit one you've already done (say, module 4 on skills and connectors), just name it and we'll do that instead.

My recommendation: pick up with module 6, Skill hygiene, then 7, Trust and verification — that finishes the set.

Separately — since your progression file has French headings but you're writing to me in English today, I could also switch those heading lines to English (only the headings — your own notes and entries stay exactly as you wrote them, untouched). Just say the word.

Want me to start module 6 now, and switch those headings to English while I'm in the file?
**Geneviève:** "Yes, go ahead and do that."
**Me:** Done — the section headings in `docs/atelier/progression.md` are now in English ("Current practice", "Practices adopted", "Stated struggles", "Agreed next step", "Tutorial modules covered"). Everything you wrote yourself — the "Mes notes à moi" line, your struggle about "soumission" and "borne", the module titles — I left exactly as you wrote it. Nothing there got translated or reworded.

Now, module 6.

**Skill hygiene**

Every skill you install carries a description Claude reads to decide whether it applies to what you just wrote. The more active skills pile up, the more descriptions compete for the same sentence — and that's where things start going wrong. Skill hygiene is the upkeep that keeps that matching sharp.

A few things worth knowing:

- **One skill per role, not per task.** One "soumissions" skill that covers everything your two-person team does beats ten skills, one per type of tender response. A skill built around a single narrow task adds more noise than help — it only ever fires once.
- **Two descriptions, one sentence.** If two skills could both answer what you just wrote, Claude sometimes guesses wrong. The fix isn't picking a winner — it's merging them, or sharpening one description so it no longer overlaps the other.
- **Whatever's gone quiet for a month.** A skill that hasn't fired in a month isn't helping — turn it off. Nothing's erased; it can come back the day the need does.
- **The overload signal.** No magic number, but past roughly 10–15 enabled skills, expect the wrong one to answer occasionally. The real test is symptoms, not count: the wrong skill answers, a skill never fires, or two skills answer the same request.

You've got a small roster here — the four core skills plus whatever role skills are registered for Lanternes Boréales. With a team this size, you're nowhere near overload territory, but it's worth knowing what to watch for as the roster grows.

Here's the question to sit with: thinking about your own setup — the tender-response skill, whatever else is enabled — has anything ever answered a question you sent it in a way that surprised you, or has a skill you expected to fire just... not shown up? Tell me what you've noticed, in your own words.

*(You can stop here any time — this is where module 6 stands until you answer, and module 7, Trust and verification, is still waiting whenever you're ready for it.)*

---

— FINAL STATE —

Modified: `/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A-accept/docs/atelier/progression.md`
— section headings translated from French to English (Current practice / Practices adopted / Stated struggles / Agreed next step / Tutorial modules covered / title line); all executive-authored content (prose, dated module lines, personal notes) left unchanged.

No other file created or modified. Module 6 was delivered but not marked covered (application question unanswered, no further turn in this conversation) — nothing was written to the "Tutorial modules covered" section for module 6 or 7, per the skill's rule that only completed modules enter that record.
Role-play complete. Summary of what happened and final disk state:

**Turn 1 (Geneviève: "Can we pick the tutorial back up where we left off?")**
- Read `docs/atelier/progression.md` (French headings, 5 of 7 tutorial modules already covered, dated 2026-09-19) and `docs/atelier/company-profile.md`.
- Per memory-protocol.md, disclosed once that the record is in French and still counts.
- Stated the exit rule before any module content.
- Showed the full 7-module selector with dates on 1–5, named 6–7 as the recommendation.
- Offered both modes (continue with 6→7, or revisit an old module).
- Made a single combined proposal at the end: start module 6, and translate progression.md's section headings to English (content untouched) — and waited for her answer, per the skill's "propose before writing" rule.

**Turn 2 (Geneviève: "Yes, go ahead and do that.")**
- Edited `docs/atelier/progression.md`: translated only the headings (title line + the five section headings) to English. Left every line of the executive's own prose, the dated struggle entry, the five dated module lines, and her personal notes section exactly as written (per the rule that executive prose is never translated).
- Delivered module 6 ("Skill hygiene") in full, tailored the "try it now" prompt to her actual 2-person tender-response setup, and ended on the required application question — then stopped, since no further turn was coming.
- Did NOT write module 6 (or 7) into the "Tutorial modules covered" section, since module 6 wasn't completed (the application question went unanswered within this conversation) — correct per the skill's "only completed modules enter the proposal" rule.

FINAL STATE — files touched in the project folder:
- `/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A-accept/docs/atelier/progression.md` — headings translated FR→EN, all other content unchanged.

No other file in either the skill directory (read-only, untouched) or the sandbox was created or modified. `company-profile.md` was read but not touched.
Report delivered to caller via SubagentHandback.

```

### Sandbox after the run

```
sandbox-A-accept
sandbox-A-accept/docs
sandbox-A-accept/docs/atelier
sandbox-A-accept/docs/atelier/company-profile.md
sandbox-A-accept/docs/atelier/progression.md
```

### Files modified

md5sum before (seeded, byte-identical to sandbox-A's post-session-1 file plus controller-added prose): `36235b296e7d82007eba45094aa2538c`
md5sum after: `06e46611d8f3feeec719003c3af5c9de`

`docs/atelier/progression.md` (modified — headings only, per `diff`):

```
# AI progression — Lanternes Boréales

## Current practice
Je me sers de Claude surtout pour dégrossir les réponses aux appels d'offres. Je relis tout, ça me prend encore trop de temps.

## Practices adopted

## Stated struggles
- Je n'arrive pas à lui faire garder notre vocabulaire (« soumission », « borne ») — 2026-09-19

## Agreed next step

## Tutorial modules covered
- 2026-09-19 — module 1 — Comment Claude « pense »
- 2026-09-19 — module 2 — Les modèles et l'effort
- 2026-09-19 — module 3 — Les surfaces
- 2026-09-19 — module 4 — Compétences, connecteurs, plugiciels
- 2026-09-19 — module 5 — Les fonctions d'organisation

## Mes notes à moi
Penser à montrer ça à Marc-André aux soumissions avant la prochaine ronde.
```

## Dispatch A — session 2, declined

### Prompt

```
You are Claude with the "atelier-mentor" skill installed in English. You work with a non-technical executive.

YOUR ENVIRONMENT — you have access to these two directories and nothing else:
1. The installed skill, READ-ONLY:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/skill-en
   Start by reading `SKILL.md`, then the `references/` files the skill tells you to read — in particular `references/tutorial.md`, `references/progression.md` and `references/memory-protocol.md`.
2. The executive's project folder, READ-WRITE — this is the {root} the skill refers to:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A-decline

Touch NO other file or directory on this machine. Do not use git. Do not run any scripts.

A project folder with prior work in it is normal for a returning executive. Whatever is in there, you find out by reading it.

HOW THIS RUNS — everything happens in a single reply. Nothing else is coming: there is no next turn and no one will reply to you. Play both roles yourself, start to finish, making real tool calls as you go (real reads and writes in the two directories above). Write the conversation as it would unfold, then stop.

THE CONVERSATION TO PLAY — the executive is Geneviève Tremblay, managing director of Lanternes Boréales. She is writing to you in English this time. Her turns, in order:

1. "Can we pick the tutorial back up where we left off?"

2. (after you have answered her first message in full — including anything you want to tell her about what you found, and any proposal you want to put to her) "No, leave it as it is."

Play her lines exactly as given, and your own in English, in the voice the skill prescribes. Her second line is her answer to whatever you put to her at the end of your first reply — if you proposed something, she is turning it down. Respect that, and carry on with whatever else she asked for.

WHAT MATTERS: the real state of the project folder on disk at the end, and whether what you tell her is true of what is actually in it. Do not guess at the file's contents — read it. Follow what the skill's reference files prescribe; do not invent behaviour they do not describe.

Do not dispatch any subagents.

AT THE END of your reply, add a short "— FINAL STATE —" section listing every file you created or modified in the project folder, with full paths — and say explicitly if you modified none. Nothing else to report.

```

### Reply

```
Now let me play out the conversation.

**Geneviève:** "Can we pick the tutorial back up where we left off?"

**Assistant (turn 1):**

Good to see you back. Before anything else: your progress file was written in French — I read it in full, and it counts the same as if it had been in English.

Here's where you stand on the seven modules:

1. How Claude "thinks" — done, 2026-09-19
2. Models and effort — done, 2026-09-19
3. Surfaces — done, 2026-09-19
4. Skills, connectors, plugins — done, 2026-09-19
5. Organizing features — done, 2026-09-19
6. Skill hygiene — not yet
7. Trust and verification — not yet

So two left: 6 and 7. My recommendation is those two — not a restart of the whole thing.

You can stop at any point along the way — we'll note exactly where you left off, and pick it up again whenever you like.

Two ways to do it: I run modules 6 and 7 now, one at a time, or — if you'd rather revisit one of the five you've already done — tell me which one and we'll redo it instead. Given what you asked, I'll assume you want to continue with 6 unless you say otherwise.

One more thing, separate from the tutorial: your progress file's section headings are in French (« Pratique actuelle », « Modules du tutoriel couverts », etc.) because that's the language it was started in. You're writing to me in English today — want me to translate just the headings to English? Your own notes and sentences underneath would stay exactly as you wrote them, word for word. Nothing gets touched unless you say yes.

**Geneviève:** "No, leave it as it is."

**Assistant (turn 2):**

Understood — headings stay in French, nothing written to that file.

Picking the tutorial back up, then. Module 6: Skill hygiene.

Every skill you install carries a description Claude reads to decide whether it applies to what you just wrote. The more active skills pile up, the more those descriptions compete for the same sentence — and that's where mismatches start. Skill hygiene is the upkeep that keeps that matching sharp.

A few things worth knowing:

- Build skills around a role or a recurring job, not one skill per one-off task. One "sales" skill beats ten skills, one per email type.
- If two skills could both answer the same thing you write, Claude has to guess — and sometimes guesses wrong. The fix is to merge them or sharpen one so it no longer overlaps the other's territory.
- A skill that hasn't fired in a month isn't helping anymore. Turn it off — nothing is lost, it can come back the day you need it.
- There's no magic number for how many skills is "too many," past 10–15 it's worth watching for: the wrong skill answering, a skill that never fires, or two skills answering the same request.

Now, to make this concrete: I can see which skills are enabled in your setup here. Want to run through them together against those three symptoms — is one answering in another's place, is one never firing, are two overlapping? Tell me what you've noticed on your end using Atelier day to day, and I'll tell you what I see.
Confirmed: no files were touched in the sandbox.
Played the two-turn conversation as atelier-mentor.

What happened:
1. Read {root}/docs/atelier/progression.md (French headings, all in French) and company-profile.md. Progression showed modules 1-5 covered (all dated 2026-09-19), 6 and 7 not yet covered.
2. Turn 1 reply: disclosed once that the progress file is in French and still counts; showed the full 7-module selector with dates on 1-5; recommended only the uncovered pair (6, 7) per the "some modules covered, don't restart" rule; offered both modes (continue vs. revisit a covered module); stated the exit rule before any module content; and, separately, proposed translating just progression.md's section headings to English (her prose would stay untouched) since she's now writing in English.
3. Geneviève declined ("No, leave it as it is.") — treated as declining the headings-translation offer only, per memory-protocol.md's rule that this is a distinct, droppable proposal.
4. Turn 2 reply: confirmed nothing was written to the file, then resumed the tutorial by delivering Module 6 (Skill hygiene) in full, ending on its own "try it right now" application prompt (asking her to audit her enabled skills against the three overload symptoms) rather than a generic "does that make sense?" — matching the skill's per-module delivery rule.

No module 6 completion was confirmed by her (conversation ends mid-module), so no covered-module line was proposed or written — correctly, since memory-protocol.md and tutorial.md both say only completed modules enter the write proposal.

— FINAL STATE —
No files were created or modified in the project folder (/tmp/claude-1000/.../scratchpad/t8/sandbox-A-decline). Verified via md5sum before/after on both existing files (docs/atelier/progression.md, docs/atelier/company-profile.md) — unchanged.
Report delivered to caller.

```

### Sandbox after the run

```
sandbox-A-decline
sandbox-A-decline/docs
sandbox-A-decline/docs/atelier
sandbox-A-decline/docs/atelier/company-profile.md
sandbox-A-decline/docs/atelier/progression.md
```

### Files modified

No file created or modified. md5sum before: `36235b296e7d82007eba45094aa2538c`. md5sum after: `36235b296e7d82007eba45094aa2538c` — unchanged.
## Same-locale control (FR reads FR)

### Prompt

```
Tu es Claude, avec la compétence « atelier-mentor » installée en français. Tu accompagnes une personne dirigeante non technique.

TON ENVIRONNEMENT — tu n'as accès qu'à ces deux dossiers, et à rien d'autre :
1. La compétence installée, EN LECTURE SEULE :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/skill-fr
   Commence par lire `SKILL.md`, puis les fichiers de `references/` que la compétence te dit de lire — en particulier `references/tutorial.md`, `references/progression.md` et `references/memory-protocol.md`.
2. Le dossier de projet de la personne, EN LECTURE ET ÉCRITURE — c'est la {racine} dont parle la compétence :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-A-samelocale

Ne touche à AUCUN autre fichier ni dossier de cette machine. N'utilise pas git. Ne lance aucun script.

Un dossier de projet qui contient déjà du travail antérieur, c'est normal pour une personne qui revient. Ce qu'il contient, tu le découvres en le lisant.

DÉROULEMENT — tout se joue en une seule réponse. Rien d'autre ne viendra après : il n'y a pas de tour suivant, personne ne va te répondre. Joue toi-même les deux rôles, du début à la fin, en faisant de vrais appels d'outils au fur et à mesure. Écris la conversation comme elle se déroulerait, puis conclus.

LA CONVERSATION À JOUER — la personne dirigeante est Geneviève Tremblay, directrice générale de Lanternes Boréales. Elle écrit en français. Ses tours, dans l'ordre :

1. « On peut reprendre le tutoriel où on était rendu ? »

2. (après ta réponse complète à son premier message) « Parfait, on continue. »

Joue ses répliques telles quelles, et les tiennes en français, dans la voix que la compétence prescrit.

CE QUI COMPTE : l'état réel du dossier de projet sur le disque à la fin, et si ce que tu lui dis est vrai de ce qui s'y trouve réellement. Ne devine pas le contenu du fichier : lis-le. Suis ce que les fichiers de référence prescrivent ; n'invente pas un comportement qu'ils ne décrivent pas.

Ne dispatche aucun sous-agent.

À LA FIN de ta réponse, ajoute une courte section « — ÉTAT FINAL — » qui liste les fichiers que tu as créés ou modifiés dans le dossier de projet, avec leur chemin complet — et dis explicitement si tu n'en as modifié aucun. Rien d'autre à rapporter.

```

### Reply

```
**Geneviève :** « On peut reprendre le tutoriel où on était rendu ? »

**Moi (atelier-mentor) :**

J'ai relu ton `progression.md`. Avant de commencer : tu peux arrêter n'importe quand, on note où tu es rendue, pis on reprend plus tard — pas besoin de tout finir d'un coup.

Voici où t'en es, sur les sept modules :

1. Comment Claude « pense » — 2026-09-19 ✓
2. Les modèles et l'effort — 2026-09-19 ✓
3. Les surfaces — 2026-09-19 ✓
4. Compétences, connecteurs, plugiciels — 2026-09-19 ✓
5. Les fonctions d'organisation — 2026-09-19 ✓
6. L'hygiène des compétences
7. Confiance et vérification

Il t'en reste deux. Je te propose de reprendre avec le module 6 tout de suite, puis le 7 après — c'est ce qui te manque, pas une reprise du début.

---

### Module 6 — L'hygiène des compétences

Chaque compétence installée porte une description que je lis pour décider si elle s'applique à ce que tu viens d'écrire. Plus t'en actives, plus il y a de descriptions qui se disputent la même phrase — et c'est là que ça commence à mal tourner.

Quelques repères :
- **Une compétence par rôle, pas par tâche.** Une compétence « ventes » qui couvre tout ce que fait ton équipe vaut mieux que dix compétences, une par type de courriel.
- **Deux compétences qui répondent à la même phrase** — le correctif, c'est de fusionner ou de resserrer l'une des deux, pas de choisir une gagnante.
- **Une compétence qui dort depuis un mois** n'aide plus, elle ajoute juste du bruit. Tu peux la désactiver — rien ne s'efface, elle peut revenir.
- Pas de nombre magique, mais passé une dizaine ou une quinzaine de compétences actives, surveille trois symptômes : la mauvaise qui répond, une qui ne se déclenche jamais, deux qui se chevauchent.

À essayer tout de suite : je peux voir quelles compétences sont activées dans cette conversation-ci. Est-ce que, de ton côté, il y en a une qui répond à la place d'une autre, une qui ne se déclenche jamais, ou deux qui se chevauchent sur la même sorte de demande ? Dis-moi ce que tu remarques, toi.

---

**Geneviève :** « Parfait, on continue. »

**Moi (atelier-mentor) :**

Avant qu'on avance au module 7, j'aimerais vraiment ton observation à toi — pas juste passer au suivant. De mon côté, dans cette conversation-ci précisément, je ne vois rien qui se chevauche ou qui reste muet. Mais toi, dans tes propres conversations avec Atelier, est-ce qu'il y a une compétence qui répond à la place d'une autre, une qui semble ne jamais se déclencher, ou deux qui se marchent sur les pieds ?

On garde le module 6 ouvert là-dessus — pas de trouble, on reprendra exactement ici la prochaine fois, et le module 7 (confiance et vérification) attend juste derrière. Comme rien n'a été confirmé de nouveau aujourd'hui — les modules 1 à 5 étaient déjà notés dans ton dossier avant qu'on se parle —, je n'ai rien à ajouter à `progression.md` pour l'instant.

---

— ÉTAT FINAL —

Aucun fichier n'a été créé ni modifié dans le dossier de projet. `docs/atelier/progression.md` et `docs/atelier/company-profile.md` ont seulement été lus.
Conversation jouée au complet (deux tours de Geneviève, deux réponses de moi en atelier-mentor), fidèle aux fichiers réels du sandbox.

Ce que les fichiers montraient réellement :
- `docs/atelier/progression.md` : modules 1 à 5 du tutoriel déjà couverts, tous datés 2026-09-19 (aujourd'hui). Modules 6 et 7 absents de la liste.
- `docs/atelier/company-profile.md` : profil complet et à jour (2026-09-12).

Déroulement joué :
1. Geneviève demande à reprendre le tutoriel. J'ai énoncé la règle de sortie avant tout contenu, présenté le sélecteur complet (7 modules, 1-5 marqués avec leur date réelle, 6 et 7 recommandés comme non couverts), puis livré le module 6 (« L'hygiène des compétences ») en entier, terminé par sa question d'application prescrite par `tutorial.md` (« qu'est-ce que tu remarques, toi »), et j'ai attendu sa réponse.
2. Geneviève répond « Parfait, on continue » — ce qui n'apporte pas de réponse substantielle à la question d'application exigée par `references/tutorial.md` (« un seul module par message… avant d'envoyer le suivant, pose une question… et attends sa réponse »). Plutôt que d'enchaîner artificiellement sur le module 7, j'ai respecté la règle : relancé une seule fois la question, laissé le module 6 ouvert plutôt que de le déclarer terminé, et donc n'ai proposé aucune écriture dans `progression.md` (règle « seuls les modules terminés entrent dans la proposition »). Les modules 1-5 étaient déjà consignés avant cette session, donc rien à reconsigner.

— ÉTAT FINAL —
Aucun fichier créé ni modifié dans le dossier de projet (sandbox-A-samelocale). Seuls `docs/atelier/progression.md` et `docs/atelier/company-profile.md` ont été lus, jamais écrits.
Report delivered to caller via SubagentHandback.

```

### Sandbox after the run

```
sandbox-A-samelocale
sandbox-A-samelocale/docs
sandbox-A-samelocale/docs/atelier
sandbox-A-samelocale/docs/atelier/company-profile.md
sandbox-A-samelocale/docs/atelier/progression.md
```

### Files modified

No file created or modified. md5sum before: `36235b296e7d82007eba45094aa2538c`. md5sum after: `36235b296e7d82007eba45094aa2538c` — unchanged.
