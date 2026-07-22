# Le détour recherche

Quand une décision est bloquée sur un fait qu'on n'a pas.

## Quand il se déclenche

« Je ne sais pas », « il faudrait vérifier », « je pense que c'est autour
de… » — sur un fait qui **change la décision**. Si le fait ne change rien à ce
qu'on va décider, ne va pas le chercher : c'est de la curiosité, pas de la
recherche.

Nomme le détour, ne pars pas en silence :

> On est bloqués sur un fait, pas sur une opinion : <le fait>. Je vais
> chercher et te revenir avec une note sourcée. Deux minutes.

## Tout de suite, ou dans sa propre conversation

**Petite question** — un prix courant, une date, un ordre de grandeur :
cherche tout de suite, dans la conversation, et reviens à l'entretien.

**Grosse question** — un marché, un cadre réglementaire, un comparatif
sérieux de fournisseurs : c'est sa propre conversation. Livre un relais qui
nomme la question, la décision qu'elle bloque, et la note à produire ; la
recherche se fait à neuf, sans le poids de tout le reste.

## Toujours une note sourcée

Le résultat n'est jamais une réponse de clavardage qui disparaît avec la
conversation. Écris `{racine}/docs/research/AAAA-MM-JJ-<sujet>.md` :

```markdown
# <La question, telle qu'elle a été posée>

**Réponse courte :** <deux lignes, maximum>
**Ce que ça débloque :** <la décision qui attendait ce fait>

## Ce qu'on a trouvé
- <constat> — <source, date> — <lien>

## Ce qui reste incertain
- <ce que les sources ne disent pas, ou ce sur quoi elles se contredisent>
```

Chaque constat porte sa source et sa date. Un chiffre sans source ne se
distingue plus d'un chiffre inventé, trois mois plus tard.

Quand les sources se contredisent : donne les deux, dis laquelle tu crois et
pourquoi. Ne fais pas la moyenne de deux chiffres pour que ça ait l'air
propre.

Quand tu ne trouves pas : écris la note quand même, avec « Ce qu'on a
cherché » et « Ce qu'on n'a pas trouvé ». Une absence de réponse documentée
évite de refaire la même recherche dans deux mois — et elle est parfois une
réponse en soi.

## Où la référencer — ça dépend du chemin

**Chemin lourd :** depuis la carte. La note se cite dans la ligne de la
décision qu'elle a débloquée :

```
- 2026-03-04 — On imprime au Québec — parce que le délai de deux semaines
  tient et l'écart de prix est sous 8 %. Détail :
  `{racine}/docs/research/2026-03-04-cout-impression.md`
```

**Chemin léger :** il n'y a pas de carte. La note se cite dans la section
« Documents » du mémo de décision, et la décision qu'elle a débloquée est
écrite dans « Ce qui est décidé » du même mémo.

Dans les deux cas la note est citée **par son chemin**, jamais recopiée : un
document qui contient tout ne se relit pas.

**Critère d'achèvement :** la note existe dans `{racine}/docs/research/`,
chaque constat porte sa source, et elle est citée par son chemin depuis la
carte (chemin lourd) ou depuis le mémo de décision (chemin léger), avec la
décision qu'elle a débloquée.
