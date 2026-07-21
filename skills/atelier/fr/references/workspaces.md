# Espaces de travail par département

Un espace de travail est un **projet Claude dédié à un département** :
Marketing, Ventes, Réunions. C'est l'endroit où la personne « va parler à son
marketing ». Les compétences, elles, sont activées pour tout le compte : elles
se déclenchent dans n'importe quel projet. Le projet n'apporte pas les
compétences — il apporte le contexte permanent.

À faire quand la personne demande comment organiser son travail par
département, quand elle mélange plusieurs sujets dans une même conversation, ou
quand `atelier-mentor` l'amène à cette étape.

## La marche à suivre

Un département à la fois, en commençant par celui où elle travaille le plus.

**1. Créer le projet.** Dans Claude : Projets → Nouveau projet. Nomme-le comme
le département, pas comme un outil : « Marketing », « Ventes ». Le nom est ce
qu'elle verra dans sa liste tous les matins.

**2. Écrire les instructions personnalisées.** Courtes — cinq à dix lignes.
Elles disent qui parle, de quoi on parle ici, et ce qui sort d'ici :

```
Ici, c'est le <département> de <entreprise>.
Mon rôle : <rôle de la personne>.
Ce qu'on fait ici : <deux ou trois types de travaux>.
Ce qui n'est pas d'ici : <ce qui va ailleurs> — ça va dans le projet <autre>.
Notre ton : <trois adjectifs du profil>.
Commence toujours par lire le Profil d'entreprise dans la connaissance du projet.
```

Rédige-les à partir du Profil d'entreprise et propose-les toutes faites, prêtes
à coller. Ne redemande pas ce que le profil dit déjà.

**3. Remplir la connaissance du projet.** Trois choses, dans cet ordre :

- **Le Profil d'entreprise** — la copie de
  `{racine}/docs/atelier/company-profile.md`. Toujours. C'est lui qui fait que
  les réponses sonnent comme l'entreprise.
- **La mémoire de ce rôle** — `{racine}/docs/atelier/memory/<nom-canonique>.md`,
  **une fois qu'elle existe**. Elle naît à la première connaissance durable de
  ce rôle ; tant qu'elle n'existe pas, il n'y a rien à déposer et rien à créer.
  Le fichier `roles.md` nomme le fichier de chaque rôle.
- **Les documents de métier du département** — la grille tarifaire pour Ventes,
  la charte de marque pour Marketing, le gabarit de PV pour Réunions. Ce que la
  personne rouvre chaque semaine.

**4. Dire la règle des copies.** Ce qui est dans la connaissance du projet est
une **copie de commodité**. Si elle diffère du fichier, le fichier fait foi. Il
faut revenir remettre la copie à jour quand le fichier bouge — c'est le seul
entretien que demande un espace de travail.

**Critère d'achèvement :** le projet existe, ses instructions personnalisées
sont écrites et collées, la personne sait quels documents déposer dans sa
connaissance, et elle sait laquelle des deux versions fait foi.

## Ensuite

Refaire les mêmes quatre étapes pour le département suivant — mais seulement
quand le premier espace sert vraiment. Trois projets vides valent moins qu'un
projet vivant.

Une fois qu'un espace tourne, `atelier-mentor` est celui qui présente les
routines : les travaux récurrents que Claude exécute sans elle, à intervalle
fixe.
