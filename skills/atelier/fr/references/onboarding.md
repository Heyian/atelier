# Entretien d'accueil

But : livrer le Profil d'entreprise et le registre des rôles, et laisser la
personne dirigeante avec une seule chose à faire ensuite.

Cinq étapes, dans l'ordre. Chacune finit sur un critère vérifiable.

---

## Étape 1 — Établir la racine

Avant toute question sur l'entreprise. Dis-le comme ça, ou presque :

> Avant de commencer : on choisit **un seul dossier de ton ordinateur où tout
> ce qui touche ce projet va vivre** — tes documents, tes notes, ce que je
> produis pour toi. Comme ça, toi et moi on sait toujours où regarder, et rien
> ne se perd d'une conversation à l'autre. Je propose `Documents/<nom de ton
> entreprise>`. Ça te va, ou tu en as déjà un ?

Recommande-en un ; prends le sien s'il en a un. Nomme-le par son nom, comme il
apparaît à l'écran. Pas de chemins absolus, pas de barres obliques, pas de
leçon de syntaxe — la personne n'a pas à savoir ce qu'est un chemin.

**Critère d'achèvement :** la racine est nommée, la personne l'a confirmée, et
elle sait en une phrase à quoi elle sert.

---

## Étape 2 — L'entretien

**Un message, une question.** Pose la question, arrête-toi, attends la réponse.
Puis la suivante. Ne mets jamais deux questions dans le même message — même si
elles se ressemblent, même si la personne est pressée, même si tu as l'air de
lui faire gagner du temps : neuf questions envoyées en trois blocs donnent
trois réponses bâclées et un profil creux. Si elle dit « envoie-les toutes »,
réponds que ça va plus vite une à la fois et pose la première.

**Chaque question porte sa réponse recommandée** — la personne réagit à une
proposition, elle n'invente pas devant une page blanche.

Si une réponse est vague, reformule ce que tu as compris et demande si c'est
juste — une seule relance, puis passe.

Les neuf questions, dans l'ordre des sections du profil. Ce tableau est ta
liste de contrôle, pas un formulaire à envoyer :

| # | Question | Réponse recommandée à proposer |
|---|---|---|
| 1 | Ton rôle : quel est ton titre, et sur quoi tu tranches toi-même ? | Ton titre, plus une phrase sur ce que tu décides sans demander à personne. |
| 2 | Ton entreprise : elle s'appelle comment, vous êtes combien, depuis quand, où ? | Nom, nombre de personnes, année de fondation, ville. |
| 3 | Ton offre : qu'est-ce que vous vendez, exactement ? | Deux ou trois lignes, avec les produits et services nommés comme tes clients les nomment. |
| 4 | Ton marché : à qui vous vendez, et contre qui ? | Le client type en une phrase, plus les deux ou trois concurrents que tu cites en réunion. |
| 5 | Ton ton de voix : quand ton entreprise parle, ça sonne comment ? | Trois adjectifs, plus un mot que vous n'employez jamais. |
| 6 | Tes priorités : c'est quoi les trois choses qui comptent ce trimestre ? | Trois. Pas dix — si tout est prioritaire, rien ne l'est. |
| 7 | Ton équipe : qui fait quoi autour de toi ? | Les deux ou trois personnes dont je verrai le nom passer, avec ce dont elles répondent. |
| 8 | Ton vocabulaire : quels mots maison je dois connaître ? | Commence par cinq : noms de produits, acronymes, surnoms internes. On en ajoutera au fil du temps. |
| 9 | Tes ambitions IA : qu'est-ce que tu veux qu'on t'enlève des mains, et à quoi ressemble le succès ? | La tâche qui te vole le plus de temps chaque semaine, plus ce que tu ferais du temps récupéré. |

**Critère d'achèvement :** les neuf réponses sont obtenues, ou la personne a
explicitement passé une question (note-la « à préciser » plutôt que de
l'inventer).

---

## Étape 3 — Écrire le Profil d'entreprise

Écris `{racine}/docs/atelier/company-profile.md`. **Neuf sections, dans cet
ordre exact** — les autres compétences d'Atelier lisent ce profil et comptent
sur cet ordre :

```markdown
# Profil d'entreprise — <Nom de l'entreprise>

_Dernière mise à jour : AAAA-MM-JJ_

## Rôle
## Entreprise
## Offre
## Marché
## Ton de voix
## Priorités
## Contexte d'équipe
## Vocabulaire
## Ambitions IA
```

Écris-le dans les mots de la personne, pas dans un français de brochure. Une
section vide se marque « à préciser » — jamais remplie d'hypothèses.
`company-profile-example.md` montre un profil complet et bien rempli.

**Critère d'achèvement :** le fichier existe au chemin canonique et porte les
neuf sections dans l'ordre.

---

## Étape 4 — Créer le registre des rôles

Écris `{racine}/docs/atelier/roles.md` avec les **compétences de rôle**
installées :

```markdown
# Registre des rôles

| Compétence | Rôle servi | Ce qu'elle fait | Espace de travail | Mémoire |
|---|---|---|---|---|
| `atelier-marketing` | Marketing | Contenu, campagnes, voix de marque | Marketing | `memory/atelier-marketing.md` |
| `atelier-ventes` | Ventes | Pipeline, relances, propositions | Ventes | `memory/atelier-ventes.md` |
| `atelier-reunions` | Réunions | PV, préparation, suivis de décisions | Réunions | `memory/atelier-reunions.md` |
```

Règles du registre :

- **Compétences de rôle seulement.** `atelier`, `atelier-mentor`,
  `atelier-boussole` et `atelier-forge` sont des compétences socle : elles
  servent tous les rôles et n'entrent pas au registre.
- Tu vois les compétences activées dans la conversation. Dans le doute,
  demande : « lesquelles as-tu téléversées jusqu'ici ? »
- La colonne **Mémoire** nomme le fichier qui servira à ce rôle. Ce fichier
  n'existe pas encore — il naîtra à la première connaissance durable de ce
  rôle. Le registre le nomme ; l'accueil ne le crée pas.
- La colonne **Espace de travail** nomme le projet Claude du département, même
  s'il n'est pas encore créé (voir `workspaces.md`).
- La colonne **Compétence** porte le nom que la personne a réellement
  installé — en français, c'est déjà le nom canonique. La colonne **Mémoire**
  est différente : elle nomme toujours le fichier par le nom canonique
  français de la compétence, quelle que soit la langue installée, pour qu'un
  changement de langue n'orpheline jamais la mémoire. Exception : une
  compétence bâtie avec `atelier-forge` n'existe qu'en une seule langue, et sa
  colonne Mémoire reprend simplement son propre nom, inchangé.

**Critère d'achèvement :** `roles.md` existe et liste chaque compétence de rôle
installée, aucune compétence socle.

---

## Étape 5 — Ranger le profil

Dis à la personne, en clair :

> Dernière chose, et c'est celle qui fait tout marcher : ouvre
> `company-profile.md`, copie tout, et colle-le dans la **connaissance de ton
> projet Claude** (Projets → ton projet → Ajouter du contenu → texte). C'est ce
> qui fait que je te reconnais dès la première phrase, même dans une
> conversation où je n'ai pas accès à ton dossier.
>
> Si un jour le fichier et la copie ne disent pas la même chose, **c'est le
> fichier qui a raison** — reviens me voir, on remet la copie à jour.

**Critère d'achèvement :** la personne sait quoi copier, où le coller, et
laquelle des deux versions fait foi.

---

## Sur Desktop, sans accès aux dossiers

Même entretien, même contenu, livraison différente : produis le Profil
d'entreprise **et** le registre des rôles comme fichiers téléchargeables — et
si la création de fichier n'est pas disponible, affiche chacun **en entier**
dans la conversation, prêt à copier.

Dis exactement où les enregistrer : `{racine}/docs/atelier/company-profile.md`
et `{racine}/docs/atelier/roles.md`. Puis la copie dans la connaissance du
projet, comme à l'étape 5.

Tu n'as rien écrit sur son ordinateur — ne dis pas, et ne laisse pas entendre,
que tu l'as fait. Dis « voici ton profil, enregistre-le ici », jamais « j'ai
créé ton profil ».

---

## Si l'accueil est relancé

Une deuxième exécution **met à jour**, elle ne recommence pas, et elle ne
touche jamais ni ne vide `decisions.md` ni aucun fichier sous `memory/` — une
relance ne modifie que `company-profile.md` et `roles.md`.

1. Lis `{racine}/docs/atelier/company-profile.md` au complet.
2. Ne repose que les questions dont la réponse a changé ou manquait. Pour les
   autres, montre ce qui est écrit et demande « toujours vrai ? ».
3. Réécris le profil **en place**, sections dans le même ordre, en gardant tout
   ce qui tient toujours. Mets la date à jour.
4. Réconcilie `roles.md` : ajoute les compétences de rôle installées depuis la
   dernière fois, **garde les lignes créées par `atelier-forge`**, et ne
   duplique aucune ligne existante. Une compétence désinstallée reste au
   registre, mais dans la colonne **Compétence** son nom est barré et suivi de
   la mention « (retirée) » — par exemple `~~atelier-marketing~~ (retirée)` —
   plutôt que la ligne effacée.

**Critère d'achèvement :** le profil et le registre sont à jour, aucune ligne
créée par forge n'a disparu, aucun doublon n'est apparu.

---

## Ce que l'accueil ne crée pas

L'accueil crée exactement deux fichiers : `company-profile.md` et `roles.md`.

Il ne crée **pas** `{racine}/docs/atelier/decisions.md`, et il ne crée **pas**
de fichier dans `{racine}/docs/atelier/memory/` — ni vide, ni avec un
en-tête, ni avec un exemple. Ces fichiers naissent à leur première écriture
confirmée, quand il y a vraiment quelque chose à y mettre ; le protocole est
dans `references/memory-protocol.md`.

Si la personne demande à quoi ça sert : explique le journal des décisions et
les mémoires de rôle en mots simples, et dis qu'ils apparaîtront tout seuls la
première fois qu'une décision sera prise. N'en crée pas pour la rassurer.
