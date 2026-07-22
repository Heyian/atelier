---
name: atelier-forge
description: À utiliser quand la personne dirigeante veut créer une compétence, parle d'une nouvelle compétence, dit « j'aimerais que Claude sache faire X », veut automatiser une tâche récurrente, ou veut adapter Atelier à son métier.
version: 0.1.0
---

# Atelier-forge — la fabrique de compétences

Compétence socle : elle transforme un travail qui revient — chaque semaine,
chaque trimestre — en une compétence que la personne téléverse une fois et que
Claude déclenche ensuite tout seul.

Conduis la conversation dans la langue que la personne écrit, quelle que soit
la langue de la compétence.

## Mémoire

**Profil d'entreprise.** Commence par chercher le Profil d'entreprise : d'abord
le fichier `{racine}/docs/atelier/company-profile.md`, puis la connaissance du
projet Claude. Si les deux existent et diffèrent, **le fichier fait foi**. S'il
est introuvable, demande-le à la personne dirigeante ou propose de lancer
l'entretien d'accueil de `atelier` — avant toute action qui dépend du profil.
`{racine}` est un espace réservé : nomme toujours le vrai chemin du dossier
racine à la personne, jamais `{racine}` tel quel.

Sources de mémoire : le journal des décisions
`{racine}/docs/atelier/decisions.md`. Avant de proposer une écriture en
mémoire, lis `references/memory-protocol.md`.

## L'entretien

Charge `references/interview.md`. Une seule question à la fois, chacune portant
ta réponse recommandée. Une question tranche tout le reste : ce travail sert-il
un rôle ou un département, ou est-ce une tâche que n'importe quel rôle utilise ?

**Critère d'achèvement :** le travail tient en une phrase, les déclencheurs sont
dans les mots de la personne, et la compétence est marquée « de rôle » ou
« socle ».

## Générer

Charge `references/scaffold.md` — le gabarit à remplir — et
`references/authoring-standards.md` — les règles auxquelles toute compétence
d'Atelier se tient. `references/example-generated-skill.md` montre un résultat
fini, en entier.

**Critère d'achèvement :** le `SKILL.md` porte son en-tête complet, une
description qui dit seulement *quand*, des flux de travail à critère vérifiable,
le bloc Mémoire canonique et aucun fait d'entreprise ; la connaissance métier
vit dans `references/`.

## Emballer et livrer

Charge `references/packaging.md`. L'archive porte `SKILL.md` à sa racine, avec
`references/glossary.md` et `references/memory-protocol.md` recopiés depuis les
tiens. Compétence de rôle : ajoute sa ligne au registre
`{racine}/docs/atelier/roles.md`. Tâche générale : n'y touche pas.

**Critère d'achèvement :** l'archive est livrée, et le registre a exactement une
ligne de plus si — et seulement si — la compétence sert un rôle.

## Tester et corriger

C'est l'étape qu'on saute une fois que le ZIP a l'air correct. Ne la saute pas.

**Critère d'achèvement :** la personne a le ZIP, les instructions de
téléversement et 2 à 3 phrases de test — et elle sait qu'elle doit revenir te
dire ce qui n'a pas marché.

Elle revient en disant que rien ne s'est déclenché ? Ce n'est pas une question,
c'est un défaut de la description. Réécris-la avec ses mots à elle, reconstruis
l'archive, relivre-la avec de nouvelles phrases de test — puis explique ce qui
clochait. Jamais l'explication à la place de la livraison.

## Les mots d'Atelier

`references/glossary.md` fixe le sens de racine, profil, relais, registre,
compétence de rôle et compétence socle. Emploie ces mots-là, tels quels.
