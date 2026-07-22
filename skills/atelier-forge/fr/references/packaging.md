# Emballer, livrer, corriger

Une compétence qui reste dans la conversation n'a jamais servi à rien. Cette
étape se termine avec un fichier ZIP entre les mains de la personne, les
instructions pour le téléverser, et deux ou trois phrases à essayer.

## 1. Monter le dossier

Un seul dossier, sous la racine, portant le nom de la compétence :

```
{racine}/docs/atelier/competences/atelier-<nom-court>/
├── SKILL.md
└── references/
    ├── glossary.md
    ├── memory-protocol.md
    └── <les fichiers de connaissance de la compétence>
```

`glossary.md` et `memory-protocol.md` se recopient **tels quels** depuis tes
propres `references/`. Ce sont les textes communs à toutes les compétences
d'Atelier ; ne les résume pas, ne les réécris pas, ne les traduis pas. La copie
doit être identique au caractère près, sinon deux compétences finissent par ne
plus parler la même langue.

**Critère d'achèvement :** quand tu as accès aux dossiers, le dossier existe,
`SKILL.md` est à sa racine, et chaque fichier `references/` que le corps du
`SKILL.md` nomme existe réellement dedans — un renvoi vers un fichier absent
casse la compétence au premier chargement. Sur Desktop, sans accès aux
dossiers, ce critère ne s'applique pas ; passe à l'étape 2.

## 2. Faire l'archive

Compresse le **contenu** du dossier, pas le dossier lui-même. C'est l'erreur
qui empêche le téléversement : si l'archive contient un dossier qui contient
`SKILL.md`, elle sera refusée.

L'archive s'appelle `atelier-<nom-court>.zip` et se retrouve à côté du dossier
source, dans `{racine}/docs/atelier/competences/`.

Vérifie avant de livrer : ouvre l'archive, tu dois voir `SKILL.md` tout de
suite, au premier niveau, à côté de `references/`.

Sur Desktop, sans accès aux dossiers : tu ne peux pas fabriquer l'archive.
Livre chaque fichier en téléchargement — et si la création de fichier n'est pas
disponible, affiche-les en entier dans la conversation, prêts à copier — puis
dis exactement quoi faire :

> Crée un dossier `atelier-<nom-court>`, mets `SKILL.md` dedans, crée un
> sous-dossier `references` et mets-y les autres. Ensuite **entre** dans le
> dossier, sélectionne `SKILL.md` et `references`, clic droit → Compresser.
> Tu obtiens le ZIP. (Si tu compresses le dossier vu de l'extérieur, ça ne
> marchera pas.)

Ne dis jamais « j'ai créé ton archive » quand tu n'as fait que l'afficher.

**Critère d'achèvement :** l'archive existe et `SKILL.md` est à son premier
niveau — vérifié, pas supposé.

## 3. Inscrire au registre — si c'est une compétence de rôle

L'entretien a tranché. Compétence de **rôle** : ajoute une ligne à
`{racine}/docs/atelier/roles.md`, sans toucher aux lignes existantes.

```markdown
| Compétence | Rôle servi | Ce qu'elle fait | Espace de travail | Mémoire |
|---|---|---|---|---|
| `atelier-revues-franchises` | Opérations réseau | Chiffres par territoire, écarts, ordre du jour | Opérations | `memory/atelier-revues-franchises.md` |
```

La colonne **Mémoire** nomme un fichier qui n'existe pas encore : il naîtra à
la première connaissance durable de ce rôle. Le registre le nomme ; personne ne
le crée ici. Elle reprend le `name` de la compétence, à l'identique — la même
graphie que dans son bloc Mémoire, jamais une variante traduite.

Compétence **socle** — une tâche que n'importe quel rôle utilise : **n'ajoute
rien**. Dis-le à la personne en une phrase, pour qu'elle sache que ce n'est pas
un oubli :

> Je ne l'inscris pas au registre : le registre est l'annuaire de tes
> départements, et celle-ci sert tout le monde. Elle se déclenchera partout
> pareil.

Le registre est absent : ne l'invente pas au passage. Propose l'accueil de
`atelier`, qui le crée avec le Profil d'entreprise.

**Critère d'achèvement :** le registre a exactement une ligne de plus pour une
compétence de rôle, aucune pour une tâche générale, et aucune ligne existante
n'a bougé.

## 4. Livrer : le ZIP, les pas, les phrases

Les trois ensemble, dans le même message. Le ZIP seul ne suffit pas : personne
ne devine où ça se téléverse.

> **Ton fichier :** `{racine}/docs/atelier/competences/atelier-<nom-court>.zip`
>
> **Pour l'installer :**
> 1. Ouvre Claude dans ton navigateur.
> 2. Va dans **Personnaliser → Compétences**.
> 3. Clique **Téléverser une compétence** et choisis le ZIP.
> 4. Vérifie qu'elle apparaît dans la liste, activée.
>
> **Pour l'essayer :** ouvre une **nouvelle conversation** — pas celle-ci, elle
> est déjà pleine de notre discussion — et écris l'une de ces phrases :
> - « <phrase 1, dans ses mots> »
> - « <phrase 2, une autre formulation> »
> - « <phrase 3, la version pressée d'un lundi matin> »
>
> **Si rien ne se passe, reviens me le dire.** Ça arrive à peu près une fois
> sur trois du premier coup ; je corrige et je te redonne le fichier.

Les phrases de test viennent de la question 2 de l'entretien, pas de ton
imagination. Une phrase de test que la personne n'écrirait jamais ne teste
rien. Deux ou trois, jamais dix.

**Critère d'achèvement :** la personne a le ZIP, les étapes de téléversement et
2 à 3 phrases de test — et elle sait qu'elle doit revenir dire ce qui n'a pas
marché.

## 5. Quand elle revient : corriger et relivrer

« J'ai tapé ta phrase et rien ne s'est passé. »

C'est un défaut de la compétence, pas une erreur de la personne, et surtout pas
une occasion de faire un cours. **Corrige d'abord, explique après.**

1. Demande **une** chose : la phrase exacte qu'elle a tapée. C'est la seule
   information qui manque, et c'est la formulation qui doit entrer dans la
   description.
2. Réécris la description en y ajoutant cette formulation **telle quelle**,
   plus les deux ou trois voisines qu'elle utiliserait aussi. Une description
   qui ne se déclenche pas est presque toujours une description écrite dans tes
   mots plutôt que dans les siens.
3. Reconstruis l'archive et **relivre-la**, avec les étapes de téléversement —
   en précisant qu'il faut remplacer l'ancienne version, pas en ajouter une
   deuxième.
4. Donne de nouvelles phrases de test, dont celle qui a échoué.
5. **Ensuite seulement**, dis en une phrase ce qui clochait.

Deuxième échec sur la même compétence : c'est le nom ou le périmètre qui est
mauvais, pas seulement les mots. Reprends les questions 1 et 2 de l'entretien
et refais la description à partir de zéro.

**Critère d'achèvement :** une nouvelle archive a été livrée dans la même
conversation, avec de nouvelles phrases de test. Une réponse qui explique sans
relivrer ne compte pas.
