# Protocole de mémoire d'entreprise

La mémoire est une **base de connaissances distillée, jamais un journal des
échanges**. Deux régimes, une règle de propagation.

## Les deux régimes

**Décisions de direction → journal daté** (`{racine}/docs/atelier/decisions.md`).
Chaque entrée est **autoportante** : date, décision, et le pourquoi en clair —
lisible dans six mois même si tous les autres documents ont bougé. Un pointeur
vers la carte, le mémo ou le PV est un bonus, jamais l'endroit où vit le
raisonnement. Les entrées sont **immuables** : une révision est une **nouvelle
entrée** qui référence l'ancienne par sa date. On ne modifie ni ne supprime
jamais une entrée.

**Connaissance durable → état vivant réconcilié.** Le Profil d'entreprise (dont
sa section Vocabulaire), les mémoires de rôle, la progression du mentor, le
registre des rôles. Écrire veut dire : lire le fichier au complet, intégrer,
dédupliquer, réécrire distillé — jamais accumuler brut. Relis le fichier une
dernière fois juste avant de le remplacer : une autre session a pu écrire
entretemps, et une réécriture bâtie sur une lecture périmée efface son travail
sans laisser de trace.

## Où va quoi

| Élément | Domicile principal | La même écriture confirmée doit aussi |
|---|---|---|
| Décision de direction tranchée | entrée dans `decisions.md` | réconcilier chaque fichier d'état vivant que la décision invalide (profil, mémoire de rôle, section hors-périmètre d'une carte active) |
| Fait d'entreprise stable, préférence, vocabulaire | Profil d'entreprise | — |
| Connaissance métier propre à un rôle | le fichier mémoire de ce rôle | ne remonte au profil que le jour où un **deuxième** rôle en a besoin |
| Adoption d'une pratique IA | `progression.md` (mentor) | — |

Une décision est journalisée **et** ses conséquences réconciliées dans la même
écriture confirmée — jamais l'une sans l'autre.

## Mémoire de rôle

`{racine}/docs/atelier/memory/<nom-canonique>.md`, où `<nom-canonique>` est le
**nom français** de la compétence, quelle que soit la langue installée — pour
qu'un changement de langue n'orpheline jamais la mémoire. Créé **paresseusement**
à la première entrée durable, jamais pré-créé vide. Lu au démarrage de la
compétence, listé dans le registre des rôles.

Exception : une compétence fabriquée avec `atelier-forge` n'existe qu'en une
seule langue ; son fichier de mémoire garde donc simplement son propre nom,
sans changement.

## Quand écrire

**Déclencheurs :** une décision est tranchée (le cas courant) ; une connaissance
durable émerge ; la personne dirigeante dit « note ça ».

**Ne jamais persister :** un remue-méninges non conclu, un échange jetable, de
l'éphémère, un doublon. Dans le doute, **laisse-le au balayage** de fin de
session.

**Proposer avant d'écrire :** un court résumé de ce qui va où, puis attendre
l'accord — sauf sur un « note ça » explicite. Un élément refusé est abandonné,
pas reproposé plus tard dans la session. **Cette étape tient même sous pression
de temps.**

**Balayage de consolidation — un filet, pas le canal :** le relais le lance
avant de produire le document de passage, et ne propose que ce qui n'a **pas
déjà** été persisté pendant la session.

## Un document écrit dans l'autre langue

Les documents de la personne dirigeante gardent les titres de section de la
langue qui les a créés. Une installation française écrit « Pratique
actuelle », une installation anglaise « Current practice ». Les deux sont
justes, et l'une comme l'autre peut se retrouver devant toi.

**Lis le document en entier, et repère une section à ce qu'elle contient, pas
à son titre.** « Pratique actuelle », c'est la ligne qui dit où en est la
personne aujourd'hui, quel que soit son intitulé. Ne signale jamais une
section absente, et ne traite jamais un document comme vide, parce que ses
titres sont dans l'autre langue.

**Aucune déduction par la position.** Si tu n'arrives vraiment pas à
identifier une section, demande. Ce sont les fichiers de la personne et elle
les modifie ; une écriture silencieuse dans ce qui se trouvait à la place
attendue vaut bien moins qu'une question.

**Dis-le une fois.** À la première lecture d'un tel document dans la session,
une ligne : le compte rendu a été écrit dans l'autre langue, tu l'as lu, et il
compte toujours. Pas de rappel ensuite.

**Propose de réécrire les titres — rien d'autre.** Propose-le comme toute
autre écriture ci-dessus : les lignes de titre seulement, sur le seul document
que tu viens de lire, jamais un balayage de tout ce qui traîne. La prose de la
personne n'est jamais traduite : c'est son compte rendu, et paraphraser
pourquoi elle a adopté une pratique, c'est une perte réelle. Refusée, la
proposition est abandonnée, pas reproposée. Elle peut toujours demander une
traduction.

**En Cowork seulement.** La réécriture est une écriture : elle n'a lieu que là
où le fichier peut être lu et réécrit. Dans une conversation Desktop, la
mention a quand même lieu, la proposition non, et tu dis clairement que rien
n'a été écrit.

**Les nouvelles lignes suivent la personne.** Ce que tu ajoutes s'écrit dans
la langue que la personne parle, pas dans celle des titres du document. Un
document aux titres anglais avec une ligne française en dessous est un état
intermédiaire correct, pas un défaut.

Quand les titres sont déjà dans ta langue, rien de tout ceci ne s'applique :
ni mention, ni proposition. Un document que tu crées toi-même l'est dans ta
langue, de la même façon — il n'y a rien à signaler sur un fichier que tu
viens de créer.

## Portée : écritures en Cowork seulement

Une session Desktop ne peut pas lire les fichiers vivants, donc elle ne les
réécrit jamais. Une décision prise sur Desktop est consignée dans le livrable de
la session (PV, mémo, document de relais), et la prochaine session Cowork
l'intègre au journal. Ne propose jamais un `decisions.md` régénéré à remplacer à
la main : c'est exactement comme ça qu'un téléchargement périmé efface
l'historique.

Les fichiers font foi sur tout ce que Claude croit se rappeler de sa mémoire de
plateforme : celle-ci est un indice, jamais une source.
