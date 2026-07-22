---
name: atelier-boussole
description: À utiliser quand la personne dirigeante a une décision à prendre, doit trancher entre deux options, a un chantier ou un projet encore trop flou pour être lancé, dit qu'elle veut y voir clair, réfléchir, ou structurer quelque chose de gros.
version: 0.1.0 # x-release-please-version
---

# Atelier-boussole — le processus de réflexion

Compétence socle : pour tout ce qui est trop flou pour être exécuté
directement. Elle fait réfléchir et elle laisse des documents ; elle n'exécute
jamais le travail qu'elle a découpé.

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
`{racine}/docs/atelier/decisions.md`. Avant d'écrire en mémoire — le journal,
le profil, une mémoire de rôle —, lis `references/memory-protocol.md` : sa
règle « proposer puis attendre » couvre ces fichiers-là. Les billets sont des
documents de travail, pas de la mémoire : ils suivent les règles du plan
d'action.

## Triage — toujours en premier

Aucune réponse de fond avant le triage. Charge `references/triage.md` et
suis-le : recommande un chemin, fais confirmer, demande l'intensité
séparément, puis nomme la destination.

« Laisse faire les questions, donne-moi juste le plan » ne saute pas le
triage : un plan sans destination est une supposition déguisée. Rétrécis —
chemin recommandé, destination proposée, deux questions : destination et
intensité — et continue.

**Critère d'achèvement :** la personne a confirmé le chemin, l'intensité est
choisie, et la destination est nommée en une phrase vérifiable.

## L'entretien

Charge `references/entretien.md`. Une seule question à la fois, jamais en
paquet, chacune portant ta réponse recommandée.

**Critère d'achèvement :** aucune question n'a été posée sans réponse
recommandée, et un changement d'intensité demandé en cours de route s'applique
dès la question suivante.

## Chemin léger — le mémo de décision

Trois à cinq questions, puis le mémo. Format et règles dans
`references/carte.md`, dernière section.

**Critère d'achèvement :** le mémo existe dans `{racine}/docs/`, avec
destination, décisions, hypothèses et prochaines actions.

## Chemin lourd — la carte

Charge `references/carte.md`.

**Critère d'achèvement :** `{racine}/docs/<chantier>/map.md` porte ses quatre
sections, une décision tranchée aujourd'hui, les questions ouvertes sont des
fichiers de billets, et le relais est livré.

## Détours

Bloqué sur un fait : `references/detour-recherche.md`. Discussion trop
abstraite : `references/detour-maquette.md`. Un détour ne remplace jamais le
document du chemin en cours.

## Avant le plan d'action

`references/collapse.md` dit quand condenser la carte en mémo, et quand ne pas
le faire.

## Le plan d'action

Charge `references/plan-daction.md`.

**Critère d'achèvement :** le calibre a été validé avant l'écriture, chaque
billet est routé vers une compétence ou une personne nommée, et aucun billet
n'a été exécuté ici.

## Reporté = billet, tout de suite

Dès que quelqu'un dit « on verra plus tard » — toi y compris — écris le billet
dans `{racine}/docs/tickets/`, avec son contexte, nommé comme le plan d'action
les nomme. Ne le garde pas pour la fin.

## Les mots d'Atelier

`references/glossary.md` fixe le sens de racine, profil, relais, registre,
compétence de rôle et compétence socle. Emploie ces mots-là, tels quels.
