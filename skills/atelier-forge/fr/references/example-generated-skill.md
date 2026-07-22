# Un exemple complet

Voici une compétence fabriquée du début à la fin, pour une entreprise inventée
— **Toitures Beaupré**, un couvreur de vingt-deux personnes qui répond à des
appels d'offres municipaux. Sers-t'en comme étalon : c'est le niveau attendu,
pas un modèle à recopier tel quel.

## Ce que l'entretien a donné

| Question | Réponse |
|---|---|
| Le travail | « La semaine passée, j'ai reçu le devis de la ville pour l'aréna. J'ai sorti mes prix au pied carré, j'ai monté la soumission, je l'ai relue deux fois pour les exclusions, et je l'ai envoyée. » |
| Le déclencheur | « Faut que je monte une soumission », « prépare-moi un prix pour… », « on répond à l'appel d'offres de… » |
| Le livrable | Un document de trois à cinq pages : portée, prix, échéancier, exclusions, conditions. |
| Les entrées | Le devis du client, la grille de prix maison, les trois dernières soumissions gagnées. |
| Ce qui rate | « Les exclusions oubliées. C'est là qu'on perd de l'argent. Et un échéancier qui ne tient pas compte des jours de pluie. » |
| À qui c'est | Département Estimation. Compétence de rôle. |

Pourquoi pas `atelier-ventes` : ici le travail n'est pas la relance ni la
relation client, c'est le chiffrage technique. Deux métiers, deux compétences.

## Le `SKILL.md` produit

```markdown
---
name: atelier-soumissions
description: À utiliser quand la personne dirigeante doit monter une soumission, dit « faut que je monte une soumission », demande de préparer un prix pour un chantier, répond à un appel d'offres, ou fait relire une soumission avant de l'envoyer.
version: 0.1.0
---

# Atelier-soumissions — le chiffrage des chantiers

Compétence de rôle, pour l'Estimation : elle monte une soumission complète à
partir d'un devis client, et elle la relit avant l'envoi.

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

Sources de mémoire : `{racine}/docs/atelier/memory/atelier-soumissions.md` —
lis-la au début, crée-la à la première entrée durable et jamais d'avance — et
le journal des décisions `{racine}/docs/atelier/decisions.md`. Avant de
proposer une écriture en mémoire, lis `references/memory-protocol.md`.

## Monter la soumission

Demande le devis du client avant toute chose ; sans lui, tu inventes une
portée. Charge `references/structure.md` pour l'ordre des sections et
`references/prix.md` pour la façon de présenter les montants.

**Critère d'achèvement :** le document porte ses cinq sections — portée, prix,
échéancier, exclusions, conditions — chaque poste de prix renvoie à une ligne
du devis client, et aucun montant n'est inventé pour boucher un trou.

## Relire avant l'envoi

Charge `references/relecture.md` et passe la liste, dans l'ordre. Les
exclusions et l'échéancier passent en premier : c'est là que l'argent se perd.

**Critère d'achèvement :** chaque point de la liste est coché ou signalé comme
manquant, aucun n'est passé en silence, et la personne a la liste sous les yeux
avant de cliquer envoyer.

## Les mots d'Atelier

`references/glossary.md` fixe le sens de racine, profil, relais, registre,
compétence de rôle et compétence socle. Emploie ces mots-là, tels quels.
```

Corps : 309 mots. Deux tâches, deux critères vérifiables, zéro déclencheur dans
le corps, zéro fait d'entreprise.

## Le dossier

```
atelier-soumissions/
├── SKILL.md
└── references/
    ├── glossary.md          ← recopié, tel quel
    ├── memory-protocol.md   ← recopié, tel quel
    ├── structure.md         ← l'ordre des sections, avec un exemple
    ├── prix.md              ← comment la grille maison se présente
    └── relecture.md         ← la liste de vérification, exclusions en tête
```

## La ligne ajoutée au registre

```markdown
| `atelier-soumissions` | Estimation | Chiffrage, montage et relecture des soumissions | Estimation | `memory/atelier-soumissions.md` |
```

`memory/atelier-soumissions.md` n'existe pas encore. Il naîtra le jour où une
session produira une connaissance durable — « on ne chiffre plus les aciers
sous 40 pieds carrés » — et seulement après un accord.

## Ce qui n'est pas entré dans le `SKILL.md`

- **« Le prix au pied carré est de 18,50 $ »** → dans `references/prix.md`, où
  il se corrige sans toucher à la compétence.
- **« Notre concurrent principal, c'est Couvertures Lanaudière »** → dans le
  Profil d'entreprise, section Marché. Tous les rôles s'en servent.
- **« On ne soumissionne plus pour la ville de Sainte-Anne »** → connaissance
  propre au rôle : elle attend la mémoire de l'Estimation, à sa première
  écriture confirmée.
- **« Déclenche-toi quand je parle de soumission »** → dans la description, et
  nulle part ailleurs.

## Les phrases de test livrées

- « Faut que je monte une soumission pour l'aréna. »
- « Prépare-moi un prix pour le toit de l'école. »
- « Relis-moi ça avant que je l'envoie. »

Les trois viennent de la question 2 de l'entretien. Aucune n'a été inventée
pour faire joli.
