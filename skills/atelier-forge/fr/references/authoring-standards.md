# Les règles d'écriture d'une compétence

Toute compétence d'Atelier se tient à ces règles, y compris celles que tu
fabriques ici. Une compétence qui les respecte se déclenche au bon moment,
reste lisible, et vieillit bien. Une compétence qui les ignore devient un
document que personne ne relit.

## La description dit *quand*, jamais *comment*

La description est le seul texte que Claude voit avant de décider s'il ouvre la
compétence. Elle énumère les situations qui la déclenchent, dans les mots de la
personne dirigeante — pas les étapes de son travail.

Une description qui résume la marche à suivre se substitue **au** corps :
Claude croit savoir quoi faire et n'ouvre jamais le fichier.

Forme : « À utiliser quand… » suivi de situations concrètes.

```yaml
description: À utiliser quand la personne dirigeante prépare une revue de
  trimestre avec ses franchisés, parle de revue trimestrielle, demande les
  chiffres par territoire, ou veut l'ordre du jour de sa prochaine rencontre
  de réseau.
```

Les mots déclencheurs sont un contrat : chaque formulation recueillie à la
question 2 de l'entretien doit se retrouver **telle quelle** dans la
description. « Revue de trimestre » et « revue trimestrielle » ne sont pas le
même mot pour une recherche de texte : mets les deux.

Et écris la description dans la langue de la personne. Une description traduite
mot à mot ne contient plus aucun de ses mots à elle.

## L'en-tête

Trois champs, dans cet ordre exact, entre deux lignes `---` :

```yaml
---
name: atelier-revues-franchises
description: À utiliser quand…
version: 0.1.0
---
```

- **`name`** — minuscules, chiffres et traits d'union seulement. Pas
  d'espaces, pas d'accents, pas de majuscules. Préfixe `atelier-` pour que la
  compétence se range avec les autres.
- **`description`** — obligatoire. `name` + `description` doivent tenir
  ensemble sous 1024 caractères. C'est large ; ça se dépasse quand on y met la
  marche à suivre, ce qui est déjà une faute.
- **`version`** — `0.1.0` pour une première mouture.

## Le corps reste court

Vise **moins de 500 mots** dans le corps, en-tête exclu. Le corps dit à Claude
quoi faire ensuite ; il n'explique pas le métier. Dès qu'un paragraphe explique
plutôt qu'il ne dirige, il part dans `references/`, où il ne se charge que
quand on en a besoin.

## Un flux de travail, pas un personnage

Une compétence n'est pas un portrait ( « tu es un directeur des opérations
chevronné… » ). C'est une suite de tâches.

- Les déclencheurs vivent dans la description, jamais dans le corps.
- Le corps porte les tâches, une section par tâche.
- La connaissance — gabarits, barèmes, exemples, façons de faire maison — vit
  dans `references/`, appelée par son nom au bon moment.

## Chaque tâche finit sur un critère vérifiable

Une section qui se termine par « aide la personne » ne se vérifie pas. Une
section qui se termine par « le document existe à tel endroit et porte ses
quatre sections » se vérifie.

Écris le critère comme un état atteint, pas comme une intention :

> **Critère d'achèvement :** l'ordre du jour est écrit, chaque écart de plus de
> 10 % est nommé avec son territoire, et chaque point porte le nom de la
> personne qui l'amène.

## La forme suit la défaillance

Pour façonner un livrable, donne la recette : dis ce que le résultat **est** et
les étapes pour l'obtenir. Une liste d'interdits ne dit pas quoi faire à la
place, et Claude improvise.

Un garde-fou dur reste permis quand il nomme le bon geste dans la même phrase :
« ne persiste rien tout de suite — garde-le pour le balayage de fin de
session » nomme l'interdit **et** la conduite correcte. Jamais un « ne fais pas »
tout seul.

## Un seul excellent exemple

Un exemple complet et excellent vaut mieux que trois moyens. Mets-en un quand
la forme du livrable est difficile à décrire en mots — et un seul.

## Le bloc Mémoire

Une seule fois, à un seul endroit, trois parties et rien d'autre :

1. Le paragraphe du Profil d'entreprise, recopié **au caractère près**.
2. Les sources de mémoire de cette compétence : son fichier
   `{racine}/docs/atelier/memory/<nom-de-la-competence>.md` — lu au début, créé
   à la première entrée durable, jamais d'avance — et le journal des décisions
   `{racine}/docs/atelier/decisions.md`.
3. Le renvoi à `references/memory-protocol.md`, à lire avant de proposer la
   moindre écriture.

Pas de quatrième ligne. Le gabarit de `scaffold.md` porte le bloc déjà écrit :
recopie-le, ne le reformule pas.

## Aucun fait d'entreprise dans le corps

Les noms de clients, les prix, les objectifs, les noms de territoires : rien de
tout cela n'entre dans un `SKILL.md`. Ces faits changent, et une compétence ne
se réécrit pas chaque fois qu'un chiffre bouge. Ils vivent dans le Profil
d'entreprise, ou dans la mémoire du rôle.

Un gabarit maison — la trame d'ordre du jour, la grille de relance — n'est pas
un fait d'entreprise : il va dans `references/`.

## Le glossaire et le protocole ne se recopient jamais dans le corps

`references/glossary.md` et `references/memory-protocol.md` sont des textes
communs à toutes les compétences. Ils voyagent dans `references/`, recopiés
tels quels ; personne ne les résume, ne les réécrit ni ne les colle dans le
corps du `SKILL.md`.
