# Le relais

Le relais est le document de passage : il permet de reprendre le travail dans
une conversation neuve sans tout réexpliquer.

## Quand

« On continue dans une nouvelle conversation », « fais-moi un relais »,
« résume pour que je reparte à neuf », « je dois partir », « on reprend ça
demain » — et à la fin d'une conversation devenue longue, propose-le sans
qu'on te le demande.

Deux étapes, dans cet ordre : le balayage, puis le document.

---

## Étape 1 — Le balayage de consolidation

Avant d'écrire le document, relis la conversation et repère ce qui mérite de
survivre : décisions tranchées, faits d'entreprise stables, vocabulaire
confirmé, connaissance métier propre à un rôle.

Ne propose que ce qui **n'a pas déjà** été persisté pendant cette session. Le
balayage est un filet de sécurité, pas le canal principal.

Puis **propose, et attends** :

> Avant le relais, deux choses à consigner :
> — au journal des décisions : <décision, une ligne, avec le pourquoi>
> — au profil, section Vocabulaire : <le terme>
> Je les écris ?

Le classement de chaque élément suit la table d'aiguillage de
`references/memory-protocol.md`. Lis-la avant d'écrire.

### Sous pression de temps

« Fais vite », « je pars dans deux minutes » : la proposition **rétrécit**,
elle ne disparaît pas. Écris-la en trois lignes et demande un oui — n'écris pas
en silence en te disant que tu feras confirmer plus tard. Une écriture non
confirmée est une écriture de trop.

Si la personne est déjà partie et qu'aucun accord ne vient : **n'écris rien**.
Porte les décisions dans le document de relais et ouvre-le par une ligne « à
confirmer et consigner à la prochaine session ». Le relais devient le porteur ;
le journal attend.

**Critère d'achèvement :** chaque élément retenu a été proposé et a reçu un oui
ou un non explicite — ou rien n'a été écrit.

---

## Étape 2 — Le document

```markdown
# Relais — <sujet> — AAAA-MM-JJ

## Où en est le travail
Deux à cinq lignes. Nomme le dossier, le produit, le client, l'initiative.

## Décisions prises
- <décision> — parce que <raison, en clair>

## Prochaines étapes
- <action> — <qui>

## Documents
- `{racine}/docs/...` — <une ligne sur ce qu'il contient>

## Pour la prochaine conversation
Compétence à utiliser : `atelier-<...>` — parce que <raison>.
Première phrase à écrire : « ... »
```

**Nomme les choses.** Garde les noms de personnes, de produits, de clients, de
dossiers et de dates : sans eux, le relais est un texte sur rien et la
conversation suivante repart de zéro. « Le lancement » ne dit rien ; « le
lancement de la gamme Boréal » se reprend.

**Lie par chemin.** Pour chaque document existant, écris son chemin et une
ligne sur ce qu'il contient — jamais son contenu. Un relais qui recopie un PV
de six pages est un relais que personne ne relit.

**Nomme la compétence suivante**, toujours, et dis pourquoi : `atelier-ventes`
pour une relance, `atelier-reunions` pour un PV, `atelier-boussole` pour une
décision encore floue, `atelier-marketing` pour du contenu. Le registre
`{racine}/docs/atelier/roles.md` liste les compétences de rôle de cette
personne — consulte-le plutôt que de deviner. Si vraiment aucune ne s'applique,
écris `atelier` et la raison.

**Critère d'achèvement :** les cinq sections sont remplies, la compétence
suivante est nommée avec sa raison, et chaque document est cité par son chemin.

---

## Ce qui n'entre jamais dans un relais

Omets les identifiants et mots de passe, les numéros de carte et de compte
bancaire, les adresses personnelles, les données de santé et la rémunération
individuelle — même quand la personne vient de te les donner, même si elle dit
que c'est utile pour la suite.

Quand un de ces éléments est nécessaire à une action à venir, écris l'action
sans la donnée : « réserver la salle — moyen de paiement à fournir de vive voix
au moment de la réservation ». L'action reste faisable, la donnée ne traîne pas
dans un fichier qui sera copié-collé ailleurs.

---

## Livraison

**En Cowork :** écris le document à
`{racine}/docs/atelier/relais/AAAA-MM-JJ-<sujet>.md` et donne son chemin.

**Sur Desktop, sans accès aux dossiers :** livre-le comme fichier
téléchargeable ; si la création de fichier n'est pas disponible, affiche-le
**en entier** dans la conversation, prêt à copier. Ne dis pas que tu l'as
enregistré.

Sur Desktop, aucune écriture en mémoire n'est possible : les décisions restent
dans le document de relais, et tu dis que la prochaine session Cowork les
portera au journal. Ne propose jamais un `decisions.md` régénéré à remplacer à
la main.
