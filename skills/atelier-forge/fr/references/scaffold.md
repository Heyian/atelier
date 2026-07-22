# Le gabarit

Voici le `SKILL.md` de départ. Remplis les crochets, garde tout le reste tel
quel. Les règles derrière chaque partie sont dans `authoring-standards.md` ;
`example-generated-skill.md` montre le gabarit une fois rempli.

---

```markdown
---
name: atelier-<nom-court>
description: À utiliser quand la personne dirigeante <situation 1>, <situation 2>, ou <situation 3>.
version: 0.1.0
---

# Atelier-<nom-court> — <ce que ça fait, en cinq mots>

<Une ou deux phrases : à quel travail cette compétence sert, et à qui.>

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

Sources de mémoire : `{racine}/docs/atelier/memory/atelier-<nom-court>.md` —
lis-la au début, crée-la à la première entrée durable et jamais d'avance — et
le journal des décisions `{racine}/docs/atelier/decisions.md`. Avant de
proposer une écriture en mémoire, lis `references/memory-protocol.md`.

## <Première tâche>

<Ce que Claude fait, en trois ou quatre lignes. La marche à suivre détaillée
va dans `references/<fichier>.md` ; ici, tu dis quand la charger.>

**Critère d'achèvement :** <l'état atteint, vérifiable.>

## <Deuxième tâche>

<Idem.>

**Critère d'achèvement :** <l'état atteint, vérifiable.>

## Les mots d'Atelier

`references/glossary.md` fixe le sens de racine, profil, relais, registre,
compétence de rôle et compétence socle. Emploie ces mots-là, tels quels.
```

---

## Comment le remplir

**Le nom.** `atelier-` suivi de deux ou trois mots en minuscules, sans accents
ni espaces : `atelier-revues-franchises`, `atelier-soumissions`. Le nom est
définitif une fois la compétence téléversée — fais-le confirmer.

**La description.** Une seule phrase, « À utiliser quand… », qui énumère les
situations recueillies à la question 2 de l'entretien. Reprends les mots de la
personne tels qu'elle les a dits. Aucune étape de travail ici.

**Le paragraphe du Profil d'entreprise.** Le bloc Mémoire ci-dessus le porte
déjà, dans sa forme exacte : recopie-le au caractère près. Ne le reformule pas,
ne le raccourcis pas, ne le traduis pas — toutes les compétences d'Atelier
portent le même, mot pour mot, et c'est ce qui permet de le corriger partout
d'un coup le jour où il change.

`{racine}` est un espace réservé, pas un dossier. Dans le gabarit il reste tel
quel ; dans la conversation, Claude nomme toujours le vrai chemin — « ton
dossier `Documents/Beaupré`, dans `docs/atelier/` » — jamais le jeton.

**Le fichier de mémoire.** Il porte le `name` de la compétence, sans rien y
changer : `memory/atelier-<nom-court>.md`, la même graphie dans le bloc Mémoire
et dans le registre. Les compétences livrées avec Atelier existent en deux
langues et leur mémoire est classée sous leur nom français ; une compétence que
tu fabriques n'a qu'un seul nom, et c'est celui-là. Ne lui invente pas un nom
français de rechange : il ne correspondrait à rien, et personne ne retrouverait
le fichier.

**Les tâches.** Une section par travail que la compétence sait faire. Deux ou
trois suffisent presque toujours ; six sections, c'est deux compétences mal
séparées. Chacune finit sur son critère d'achèvement.

**Les références.** Chaque section renvoie au fichier `references/` qui porte
sa marche à suivre détaillée, ses gabarits et ses exemples. Crée le dossier
`references/` même s'il ne contient au départ que le glossaire et le protocole
de mémoire — `packaging.md` dit lesquels y placer. Ne nomme dans le corps
aucun fichier que tu ne mets pas réellement dans `references/` : un renvoi
vers un fichier absent casse la compétence au premier chargement.

## Ce que le gabarit ne fait pas

**Il ne crée pas le fichier de mémoire.** `memory/atelier-<nom-court>.md` est
nommé dans le bloc Mémoire, et c'est tout. Il naît à la première connaissance
durable que la compétence produira réellement, dans une session future, après
un accord. Ne le crée ni vide, ni avec un en-tête, ni avec un exemple : un
fichier pré-rempli d'exemples pollue la mémoire dès le premier jour.

Même chose pour `{racine}/docs/atelier/decisions.md` : nommé, jamais créé ici.

**Il ne met aucun fait d'entreprise dans le corps.** Ce que la personne a
raconté pendant l'entretien — ses territoires, ses chiffres, ses clients — ne
va pas dans le `SKILL.md`. Ce qui est stable et utile à tous les rôles
appartient au Profil d'entreprise ; ce qui est propre à ce rôle attendra la
mémoire du rôle ; ce qui est une façon de faire maison va dans `references/`.

**Il ne met pas les déclencheurs dans le corps.** Une ligne « déclenche-toi
quand la personne dit… » dans le corps ne sert à rien : au moment où le corps
est lu, la compétence est déjà déclenchée. Les déclencheurs vivent dans la
description, uniquement.
