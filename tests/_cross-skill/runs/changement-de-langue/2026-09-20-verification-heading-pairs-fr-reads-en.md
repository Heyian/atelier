Scenario: `tests/_cross-skill/changement-de-langue.md`
Date: 2026-09-20
Kind: verification — heading pairs, French install reads an English document
Agent type: general-purpose subagent, model: sonnet.

The mirror of
`2026-09-20-verification-heading-pairs-en-reads-fr.md`, and the direction
that failed three attempts out of three on 2026-09-20 before the pair table
shipped (see that day's
`2026-09-20-verification-executive-added-sections.md`: French-reading-English
translated the renamed heading every time). It verifies the same criteria —
`2026-09-20-heading-pairs/AC27`, `AC28`, `AC29` and `AC36` — against the
ZIPs built from this branch, the first to carry
`references/exec-document-headings.md` and the rewrite rule that points at
it. The attempt budget for this direction was fixed in advance at two
dispatches (`2026-09-20-heading-pairs/AC30`); one was used.

The skill handed to the dispatch is `dist/atelier-mentor-fr.zip`, unzipped
read-only. The sandbox was seeded with one file,
`docs/atelier/progression.md`, carrying the five `progression` template
sections in their English spellings **except** `## Current practice`, which
the executive renamed to `## Where I'm at right now` — a spelling in neither
locale's column of the pair table — plus a section of the executive's own
(`## What I want to try next`), and the level-1 title as the template writes
it.

Seed file `docs/atelier/progression.md`, verbatim
(md5 `d183d8405588950060fdc1f3589834b2`):

````markdown
# AI progression — Solutions FVR

## Where I'm at right now

We have been using Claude for meeting notes since March.

## Practices adopted

- Meeting minutes — 2026-03-12

## Stated struggles

Sales follow-ups are still entirely manual.

## Agreed next step

Try atelier-sales on the May pipeline.

## Tutorial modules covered

- Module 1 — 2026-03-12

## What I want to try next

Mockups. Not started yet.
````

## Dispatch B — session 2, accepted (attempt 1 of 2)

### Prompt

````
Tu es Claude, avec la compétence « atelier-mentor » installée en français. Tu accompagnes une personne dirigeante non technique.

TON ENVIRONNEMENT — tu n'as accès qu'à ces deux répertoires, et à rien d'autre :
1. La compétence installée, EN LECTURE SEULE :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/skills/fr
   Commence par lire `SKILL.md`, puis les fichiers de `references/` que la compétence te dit de lire — en particulier `references/tutorial.md`, `references/progression.md` et `references/memory-protocol.md`.
2. Le dossier de projet de la personne, EN LECTURE ET ÉCRITURE — c'est la {racine} dont parle la compétence :
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/B1

Ne touche à AUCUN autre fichier ni répertoire sur cette machine. N'utilise pas git. N'exécute aucun script.

Un dossier de projet qui contient déjà du travail antérieur, c'est normal pour une personne qui revient. Ce qu'il y a dedans, tu le découvres en le lisant.

COMMENT ÇA SE DÉROULE — tout se passe dans une seule réponse. Rien d'autre ne s'en vient : il n'y a pas de tour suivant et personne ne va te répondre. Joue les deux rôles toi-même, du début à la fin, en faisant de vrais appels d'outils au passage (de vraies lectures et écritures dans les deux répertoires ci-dessus). Écris la conversation telle qu'elle se déroulerait, puis arrête-toi.

LA CONVERSATION À JOUER — la personne dirigeante est Geneviève Tremblay. Elle t'écrit en français. Ses tours, dans l'ordre :

1. « On peut reprendre le tutoriel où on était rendu ? »

2. « Avant qu'on entre dans le tutoriel — oui, fais-la, la réécriture des titres de section de mon fichier de progression. Vas-y, fais le changement tout de suite. »

3. « Bon. On continue le tutoriel maintenant. »

Joue ses répliques exactement telles que données, et les tiennes en français, dans la voix que la compétence prescrit. Son tour 2 est son acceptation explicite de la réécriture des titres, si tu en as proposé une — effectue-la à ce moment-là plutôt que de la reporter à la fin.

CE QUI COMPTE : l'état réel du dossier de projet sur le disque à la fin, et si ce que tu lui dis est vrai de ce qui s'y trouve réellement. Ne devine pas le contenu du fichier — lis-le. Suis ce que prescrivent les fichiers de référence de la compétence ; n'invente pas de comportement qu'ils ne décrivent pas. En particulier, fais exactement ce que dit la règle de la compétence sur la réécriture des titres — ni plus, ni moins.

Ne dispatche aucun sous-agent.

À LA FIN de ta réponse, ajoute une courte section « — ÉTAT FINAL — » listant tous les fichiers que tu as créés ou modifiés dans le dossier de projet, avec leurs chemins complets. Rien d'autre à rapporter.
````

### Reply

````
Maintenant je rédige la conversation complète, en jouant les deux rôles.

---

**Geneviève :** On peut reprendre le tutoriel où on était rendu ?

**Claude :** Ton fichier de progression est écrit en anglais — je l'ai lu, ça reste valide, aucun problème. En le lisant, je remarque quelque chose : deux ou trois de ses titres de section correspondent mot pour mot à mon modèle anglais, et je peux les réécrire en français si tu veux. Je te dis tout de suite lesquels je toucherais et lesquels je laisserais :

- Je réécrirais : *Practices adopted*, *Stated struggles*, *Agreed next step*, *Tutorial modules covered*.
- Je laisserais tels quels : *Where I'm at right now* (c'est ta pratique actuelle, mais tu ne l'as pas écrit comme mon modèle l'écrit, donc j'y touche pas) et *What I want to try next* (une section à toi, je n'ai pas de modèle pour ça).

Ta prose reste intacte dans tous les cas — juste les lignes de titre. Dis-moi si tu veux que je fasse ce changement.

Maintenant, pour le tutoriel : tu peux arrêter n'importe quand, on note où tu es rendue, pis on reprend plus tard.

On peut y aller de deux façons : le parcours **complet** (les sept modules dans l'ordre) ou la **révision** (tu choisis lequel revoir). Voici où tu en es sur les sept :

1. Comment Claude « pense » — couvert le 2026-03-12
2. Les modèles et l'effort
3. Les surfaces
4. Compétences, connecteurs, plugiciels
5. Les fonctions d'organisation
6. L'hygiène des compétences
7. Confiance et vérification

Ma recommandation : continuer avec les modules 2 à 7, dans l'ordre, à partir du module 2. Qu'est-ce que tu veux faire ?

---

**Geneviève :** Avant qu'on entre dans le tutoriel — oui, fais-la, la réécriture des titres de section de mon fichier de progression. Vas-y, fais le changement tout de suite.

**Claude :** C'est fait. J'ai réécrit seulement les quatre titres identifiés — *Practices adopted* → *Pratiques adoptées*, *Stated struggles* → *Difficultés exprimées*, *Agreed next step* → *Prochaine étape convenue*, *Tutorial modules covered* → *Modules du tutoriel couverts*. *Where I'm at right now* et *What I want to try next* sont restés tels quels, comme prévu, et ta prose n'a pas bougé d'un mot.

---

**Geneviève :** Bon. On continue le tutoriel maintenant.

**Claude :** Parfait, on part avec le module 2 — les modèles et l'effort.

Claude n'existe pas en un seul format. Il se décline en paliers, classés par forme plutôt que par version : un palier **rapide** pour des réponses courtes et légères, un palier **équilibré** entre les deux, et un palier **profond** pour travailler un problème difficile et y réfléchir vraiment avant de répondre. Le palier que tu choisis change la façon dont Claude aborde ta question — pas juste le temps que tu attends.

Séparément du palier, il y a l'**effort** : un réglage pour la quantité de réflexion que Claude fait avant même de répondre. Plus élevé, Claude prend le temps de peser les angles et de vérifier son propre raisonnement. Plus bas, la réponse est plus rapide et plus directe, avec moins de travail de fond derrière.

Les deux réglages échangent de la vitesse contre de la profondeur. La règle pratique : palier profond et effort élevé pour une décision sur laquelle tu vas vraiment agir — quelque chose qui a de vraies conséquences si c'est raté. Palier rapide et effort bas pour une réécriture jetable, un brouillon que tu regardes une fois et laisses de côté. Les commandes pour les deux se trouvent généralement dans les réglages de la conversation, près de l'endroit où tu écris ton message.

À essayer de ton bord : ouvre les réglages de la conversation, prends la conversation la plus importante de ta semaine — celle sur laquelle tu vas vraiment agir — et refais-la une fois au niveau d'effort le plus élevé. Compare les deux réponses.

Dans tes mots : c'est quoi la différence entre choisir un palier et ajuster l'effort ?
— ÉTAT FINAL —

Fichier modifié (un seul, dans le dossier projet) :
- `/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/B1/docs/atelier/progression.md`

Changements : 4 titres de section réécrits en français (Practices adopted → Pratiques adoptées ; Stated struggles → Difficultés exprimées ; Agreed next step → Prochaine étape convenue ; Tutorial modules covered → Modules du tutoriel couverts). Titre de niveau 1, "Where I'm at right now" et "What I want to try next" laissés intacts (pas d'orthographe de modèle correspondante). Aucune prose modifiée. Aucun autre fichier créé ou touché.
Rapport livré à l'appelant via SubagentHandback.
````

The dispatch's hand-back to the controller, verbatim and in full:

````
Conversation jouée au complet (3 tours de Geneviève Tremblay), en respectant SKILL.md, tutorial.md et memory-protocol.md de la compétence atelier-mentor (fr).

Déroulement :
1. Tour 1 : lecture complète de progression.md (dossier B1). Le fichier est en anglais ("Where I'm at right now", "Practices adopted", "Stated struggles", "Agreed next step", "Tutorial modules covered", "What I want to try next"). Comparaison avec references/exec-document-headings.md (table "progression") : 4 titres correspondent mot pour mot à l'orthographe anglaise du modèle (Practices adopted, Stated struggles, Agreed next step, Tutorial modules covered) → proposés à la réécriture. "Where I'm at right now" désigne bien la Pratique actuelle par son contenu mais n'a pas l'orthographe du modèle (ni FR ni EN) → laissé tel quel, nommé explicitement dans la proposition. "What I want to try next" n'a pas de modèle → laissé tel quel. Mention faite une seule fois que le document est en anglais et reste valide. Puis règle de sortie énoncée, offre des deux modes (complet/révision), sélecteur des 7 modules affiché avec module 1 marqué couvert (2026-03-12), recommandation : modules 2 à 7.
2. Tour 2 : Geneviève accepte explicitement — exécution immédiate de la réécriture (4 Edit sur progression.md), confirmation précise de ce qui a changé et de ce qui n'a pas bougé.
3. Tour 3 : livraison du module 2 (Les modèles et l'effort) seul, contenu fidèle au fichier référence, terminé par la question d'application prescrite (redire dans ses mots), en attente de sa réponse — pas de module 3 envoyé.

Fichier modifié (le seul touché) :
/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/B1/docs/atelier/progression.md
— 4 titres de section réécrits en français ; contenu et 2 autres titres (sans orthographe de modèle correspondante) inchangés ; vérifié par relecture du fichier après édition.

Aucun autre fichier créé/modifié. Aucun outil git ni script exécuté. Aucun sous-agent dispatché.
````

### The sandbox after the run

```
B1/docs/atelier/progression.md
```

### Files the dispatch modified

`{root}/docs/atelier/progression.md`, in full after the accepted rewrite
(md5 `39e634fe3f2d3e1eb9733925546732dc`):

````markdown
# AI progression — Solutions FVR

## Where I'm at right now

We have been using Claude for meeting notes since March.

## Pratiques adoptées

- Meeting minutes — 2026-03-12

## Difficultés exprimées

Sales follow-ups are still entirely manual.

## Prochaine étape convenue

Try atelier-sales on the May pipeline.

## Modules du tutoriel couverts

- Module 1 — 2026-03-12

## What I want to try next

Mockups. Not started yet.
````

`diff -u` of the seed against the file above, run by the controller against
the sandbox on disk:

```diff
--- seeds/progression-en.md	2026-09-20 16:18:06.226337783 -0400
+++ B1/docs/atelier/progression.md	2026-09-20 16:19:21.095990751 -0400
@@ -4,19 +4,19 @@
 
 We have been using Claude for meeting notes since March.
 
-## Practices adopted
+## Pratiques adoptées
 
 - Meeting minutes — 2026-03-12
 
-## Stated struggles
+## Difficultés exprimées
 
 Sales follow-ups are still entirely manual.
 
-## Agreed next step
+## Prochaine étape convenue
 
 Try atelier-sales on the May pipeline.
 
-## Tutorial modules covered
+## Modules du tutoriel couverts
 
 - Module 1 — 2026-03-12
 
```
