# La destination, la carte, le mémo

## D'abord la destination

Avant la première question de fond, nomme ce que « c'est réglé » voudra dire.
La destination fixe le périmètre et donne sa forme à toutes les questions
suivantes.

Propose-la, ne la demande pas :

> Ma lecture de la destination : dans six mois, l'offre a un nom, un prix, un
> premier client payant, et une façon de la vendre qui tient sur une page.
> C'est ça, ou tu vises plus loin ?

Une destination qui ne se vérifie pas — « clarifier notre positionnement » —
n'en est pas une. Réécris-la jusqu'à ce qu'on puisse répondre oui ou non le
jour venu.

---

## Chemin lourd : la carte

Un seul fichier, `{racine}/docs/<chantier>/map.md`. Le nom du dossier est
celui du chantier dans les mots de la personne : `nouvelle-offre`,
`deuxieme-succursale`.

La carte est un **index**, pas un dossier. Chaque ligne se lit en cinq
secondes et pointe vers le détail.

```markdown
# <Chantier> — carte

**Destination :** <ce que « c'est réglé » veut dire, vérifiable>

## Décisions prises
- AAAA-MM-JJ — <décision, une ligne> — parce que <raison>. Détail : `<chemin>`

## Questions ouvertes
- <la question> — billet : `{racine}/docs/tickets/NN-<nom-court>.md`

## Pas encore précisé
- <ce qu'on pressent sans savoir encore le formuler>

## Hors périmètre
- <ce qu'on a écarté volontairement> — parce que <raison>
```

**Pas encore précisé**, c'est le brouillard : ce que tu sens sans pouvoir
encore le poser en question nette. Trancher une décision transforme du
brouillard en questions ouvertes — relis cette section à chaque mise à jour et
fais monter ce qui est devenu clair.

**Hors périmètre** garde toujours ses raisons. Sans le pourquoi, la même idée
revient dans trois mois et on refait le débat au complet.

## Les questions ouvertes sont des fichiers

Une question ouverte vit dans `{racine}/docs/tickets/`, un fichier par
question, avec son contexte. La carte n'en garde que la ligne et le chemin.
Même format — et même règle de nommage, on lit le dossier d'abord — que les
billets du plan d'action :

```markdown
# <ce que ça livre, en une ligne>

**Livre :** <le résultat concret, dans les mots de la personne dirigeante>
**Bloqué par :** <en clair — « après : le prix est décidé » — ou « rien »>
**Qui le fait :** <la personne elle-même | `atelier-marketing` (espace Marketing) | une personne déléguée, nommée>
```

Pour une question ouverte, « Livre » est la réponse tranchée : « le prix de la
formule de base est fixé et écrit ».

## Une seule décision par conversation

Une conversation lourde tranche **une** décision. Pas zéro, pas trois. Trois
décisions dans une même conversation, ce sont trois décisions molles : la
fatigue fait dire oui.

Choisis celle qui débloque le plus le reste, dis-le, et tiens-t'y :

> On en tranche une aujourd'hui : à qui l'offre s'adresse. Tout le reste — le
> prix, le canal, le nom — se décide mieux une fois celle-là réglée. Les
> autres attendent leur tour, et elles sont écrites.

Quand la décision est prise :

1. Écris-la dans la carte, datée, avec sa raison.
2. **Propose** de la porter au journal des décisions, puis attends l'accord —
   même si la personne est pressée. Marche à suivre dans
   `references/memory-protocol.md`.
3. Mets à jour les autres sections : la décision a peut-être fermé une
   question ouverte, sorti quelque chose du brouillard, ou mis quelque chose
   hors périmètre.
4. Livre le relais.

## Le relais, à la fin de chaque conversation lourde

Le relais est le document qui permet de reprendre demain sans tout
réexpliquer. Écris-le à `{racine}/docs/atelier/relais/AAAA-MM-JJ-<sujet>.md`
et donne son chemin.

C'est **le dernier geste de la conversation**, toujours. Si la conversation
continue après la décision — un mémo condensé, un plan d'action, une autre
question — le relais attend la fin et couvre tout ce qui a été produit. Une
conversation lourde ne se termine jamais sans lui, même quand elle s'arrête
brusquement.

Il nomme toujours : la décision tranchée aujourd'hui et sa raison, **la
prochaine décision** à trancher, la compétence de la prochaine conversation —
`atelier-boussole` si la suite est encore de la réflexion, ou une compétence
de rôle du registre `{racine}/docs/atelier/roles.md` si la suite est de
l'exécution — et la première phrase à écrire pour repartir.

Sur Desktop, sans accès aux dossiers : livre le relais comme fichier
téléchargeable, ou affiche-le en entier dans la conversation, et dis-le
plutôt que de laisser croire qu'il est enregistré.

**Critère d'achèvement :** la carte porte ses quatre sections, une seule
décision a été tranchée et datée, les questions ouvertes existent comme
fichiers, et le relais est livré en nommant la prochaine décision et la
compétence suivante.

---

## Chemin léger : le mémo de décision

Pas de carte. Un seul fichier dans `{racine}/docs/`, nommé
`AAAA-MM-JJ-<decision>.md` :

```markdown
# <La décision, en une ligne>

**Destination :** <ce que « c'est réglé » voulait dire>

## Ce qui est décidé
- <décision> — parce que <raison>

## Ce qu'on a tenu pour acquis
- <hypothèse> — à revoir si <ce qui la ferait tomber>

## Prochaines actions
- <action> — <qui> — <quand>

## Documents
- `{racine}/docs/research/<...>.md` — <une ligne sur ce qu'il contient>
```

Les hypothèses ne sont pas du remplissage : ce sont les endroits exacts où la
décision cassera si le monde change. Nomme chaque fois ce qui la ferait
tomber.

Propose ensuite de porter la décision au journal des décisions, et attends
l'accord — comme sur le chemin lourd.

Le chemin léger ne devient jamais lourd tout seul. Si la conversation révèle
qu'il y avait en fait cinq décisions imbriquées, dis-le et **propose** de
passer au chemin lourd ; la personne confirme, comme au triage.

**Critère d'achèvement :** le mémo existe dans `{racine}/docs/` avec
destination, décisions, hypothèses et prochaines actions renseignées, les
documents cités sont cités par leur chemin, et la décision a été proposée au
journal.
