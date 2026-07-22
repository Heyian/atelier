# L'échelle de progression et `progression.md`

Ce fichier est le mode d'emploi de `atelier-mentor` — pas le dossier de la
personne dirigeante. Le dossier lui-même vit à
`{racine}/docs/atelier/progression.md` ; ce document explique comment le lire
et l'écrire, et sur quelle échelle situer une recommandation.

## L'échelle de progression

Trois marches, dans l'ordre :

1. **Les compétences** — téléverser et utiliser Atelier tel quel, conversation
   par conversation. C'est là que tout le monde commence.
2. **Les espaces de travail par département** — un projet Claude dédié par
   département, avec ses instructions et sa connaissance permanente.
   `atelier-mentor` ne fait pas cette marche à suivre — il la recommande, puis
   relaie vers la compétence `atelier` pour la marche à suivre des espaces de
   travail par département.
3. **Les routines infonuagiques (Cloud Routines)** — un travail récurrent que
   Claude exécute à intervalle fixe, sans que la personne ouvre une
   conversation. Les détails de mise en place changent avec le produit :
   vérifie-les dans `sources.md` au moment d'y arriver, ne les décris pas de
   mémoire.

## La règle de la zone proximale

**Recommande toujours la seule marche suivante, jamais l'échelle au complet.**
Une personne qui utilise à peine une compétence n'a pas besoin d'entendre
parler de routines infonuagiques ; elle a besoin d'un encouragement sur ce
qu'elle fait déjà, ou de la marche juste au-dessus. Si elle demande la vue
d'ensemble, tu peux nommer les trois marches en une phrase — mais la
recommandation concrète reste toujours une seule pratique à la fois.

## Format de `progression.md`

```markdown
# Progression IA — <personne ou entreprise>

## Pratique actuelle
<une ou deux lignes sur où en est la personne aujourd'hui>

## Pratiques adoptées
- AAAA-MM-JJ — <pratique> — <pourquoi, en clair>

## Difficultés exprimées
- <difficulté> — <date>

## Prochaine étape convenue
<la seule prochaine pratique recommandée, et pourquoi c'est la bonne marche>
```

### Exemple

```markdown
# Progression IA — Nordec Emballages inc.

## Pratique actuelle
Utilise `atelier` et `atelier-ventes` en conversation à conversation ; pas
encore d'espace de travail dédié.

## Pratiques adoptées
- 2026-06-02 — registre de faits approuvés pour les prix de gros — parce
  qu'un brouillon de proposition avait inventé un rabais qui n'existait pas.

## Difficultés exprimées
- 2026-07-14 — trouve que les conversations de vente deviennent longues et
  confuses après plusieurs relances.

## Prochaine étape convenue
Ouvrir un espace de travail Ventes dédié, pour que chaque relance parte d'une
conversation courte et centrée au lieu d'une seule conversation qui s'étire.
```

## Quand écrire

Créé paresseusement à la première pratique confirmée — jamais pré-créé vide.
Lu en entier au début d'une session si présent. Mis à jour seulement après que
la personne confirme explicitement avoir adopté une pratique — jamais sur une
simple mention en passant. La marche à suivre pour proposer l'écriture vient
de `references/memory-protocol.md`.
