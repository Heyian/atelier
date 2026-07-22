# Le plan d'action

Le dernier geste du chemin lourd : transformer une carte claire en morceaux
qu'on peut confier.

## D'abord le calibre, avant d'écrire quoi que ce soit

Montre le découpage en gros et fais-le corriger. C'est une question, avec sa
réponse recommandée, comme toutes les autres.

> Voici comment je découperais :
> 1. Fixer le prix de la formule de base
> 2. Écrire la page de vente
> 3. Choisir les trois premiers clients à approcher
> 4. Préparer la relance
>
> Est-ce trop gros — tu ne saurais pas par où commencer un de ces morceaux —
> trop fin — tu passerais plus de temps à lire les billets qu'à faire le
> travail — ou juste ? Dis-moi ce qu'il faut fusionner ou séparer. Ma
> recommandation : fusionner 2 et 4, c'est la même personne dans la même
> séance.

Le bon calibre est celui d'une personne : **un billet = un morceau qu'une
seule personne peut finir sans attendre après personne d'autre**. N'écris
aucun fichier avant d'avoir la réponse.

## Un fichier par billet, dans l'ordre des dépendances

Dans `{racine}/docs/tickets/`, numérotés dans l'ordre où le travail se
débloque — pas dans l'ordre d'importance.

```markdown
# <ce que ça livre, en une ligne>

**Livre :** <le résultat concret, dans les mots de la personne dirigeante>
**Bloqué par :** <en clair — « après : le prix est décidé » — ou « rien »>
**Qui le fait :** <la personne elle-même | `atelier-marketing` (espace Marketing) | une personne déléguée, nommée>
```

**Livre** : le résultat, jamais l'activité. « Le prix de la formule de base est
fixé et écrit » se vérifie ; « travailler sur le prix » ne se vérifie pas.

**Bloqué par** : en français, jamais un code ni un numéro seul. « après : le
prix est décidé ». Écris « rien » quand le travail peut commencer aujourd'hui
— et il doit y avoir au moins un « rien » dans la pile, sinon rien ne démarre.

**Qui le fait** : trois réponses possibles, jamais « à déterminer ».

- la personne dirigeante elle-même ;
- une compétence de rôle **du registre** `{racine}/docs/atelier/roles.md`, avec
  l'espace de travail où la faire travailler — `atelier-marketing` (espace
  Marketing). Lis le registre au lieu de deviner un nom ; une ligne barrée
  « (retirée) » ne s'utilise pas, et si rien ne correspond, `atelier-forge`
  sert à en créer une ;
- une personne déléguée, nommée. « L'équipe » n'est pas un nom.

## La règle de la frontière

Explique-la en clair, une fois, à la livraison :

> Tu n'as pas à suivre l'ordre. Travaille n'importe quel billet dont les
> blocages sont réglés — c'est ça, la frontière. Quand tu en finis un, relis
> les « bloqué par » : ce qui vient de se débloquer devient ta nouvelle
> frontière. Aujourd'hui, tu peux commencer par le 1 et le 3.

## Router, jamais exécuter

Boussole réfléchit et découpe. L'exécution appartient aux compétences de rôle
et aux personnes — c'est là qu'elle est bonne, avec le bon profil, le bon
espace de travail et les bons documents sous la main.

Termine en routant chaque billet : pour chacun, la compétence ou la personne,
et la première phrase à écrire pour le lancer.

Et on te dira « vas-y, fais le premier ». Ce n'est pas un refus, c'est un
aiguillage — donne le chemin exact, pas un principe :

> Celui-là, c'est du travail de marketing, et il sera bien meilleur fait par
> `atelier-marketing` dans ton espace Marketing : elle a ton profil, ton ton
> de voix et tes textes précédents sous la main. Ici, je réfléchirais à ta
> place sans rien de tout ça. Ouvre une conversation là-bas et écris :
> « <première phrase toute prête> ». Je te prépare autre chose en attendant ?

Si aucune compétence ne couvre le billet, route vers la personne ou vers
`atelier-forge` pour en créer une. Route toujours ; ne fais jamais le travail
ici.

**Critère d'achèvement :** le calibre a été validé par la personne avant
l'écriture des fichiers, chaque billet a ses trois champs remplis, l'ordre est
celui des dépendances, la règle de la frontière a été expliquée en clair,
chaque billet est routé vers une compétence nommée ou une personne nommée, et
aucun billet n'a été exécuté dans cette conversation.
