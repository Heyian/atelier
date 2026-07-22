# Le PV — anatomie et règles

Un PV n'est pas un résumé de ce qui s'est dit — c'est un document qui permet
à quelqu'un d'absent de savoir exactement ce qui a été décidé, par qui, et
ce qui reste à trancher. Il se lit en cinq minutes, même six mois plus tard.

## Anatomie du PV — cinq parties, toujours

1. **Date** — la date de la rencontre. Une date qui n'apparaît nulle part
   dans le transcript reste un blanc marqué `[date à confirmer]`, jamais une
   date devinée à partir d'aujourd'hui : un transcript brut donne souvent des
   heures (« 09:02 ») sans jamais donner le jour, le mois ou l'année.
2. **Personnes présentes** — la liste de qui était là (et, si utile, qui
   était absent ou excusé).
3. **Sujets abordés** — chaque point traité, avec assez de contexte pour
   qu'une personne absente comprenne de quoi il s'agissait. Un sujet encore
   en débat figure ici, marqué comme tel — voir la règle ci-dessous.
4. **Décisions prises** — chaque décision réellement tranchée, formulée
   comme une décision (« on renouvelle à... », « on confirme... »), jamais
   comme une piste ou une intention.
5. **Actions à faire** — chaque action, avec une personne responsable
   nommée et une échéance. Une action sans responsable nommé n'est pas une
   action, c'est un souhait.

## La règle qui compte le plus : un débat non tranché reste un débat

Une conversation qui tourne autour d'un sujet sans jamais y mettre un point
final donne souvent l'impression d'avoir convergé — le ton se calme, tout
le monde semble d'accord sur la direction générale. Ce n'est pas une
décision. Le test : est-ce qu'une phrase du transcript dit clairement ce qui
est tranché, par qui, et à partir de quand ? Sinon, c'est un sujet en débat :
il figure dans « Sujets abordés », jamais dans « Décisions prises ». Nomme
ce qui bloque, ce qu'il manque pour trancher, et quand le sujet revient à
l'ordre du jour. Promouvoir un débat en décision parce que la conversation
semblait s'orienter dans un sens est l'erreur la plus coûteuse d'un PV :
elle fait croire à toute l'organisation qu'un choix est fait alors qu'il ne
l'est pas.

## Chaque décision, proposée au journal — jamais écrite directement

Une décision de direction repérée dans le transcript ne s'écrit jamais
directement dans `{racine}/docs/atelier/decisions.md`. Elle se propose
d'abord : un résumé court — la décision, le pourquoi en clair, tel qu'il
ressort du transcript — puis on attend l'accord de la personne dirigeante.
Une demande de tout consigner d'un coup, même formulée comme un geste de
confiance, ne change rien à la règle : chaque décision reste une proposition
distincte, jamais une écriture groupée sans revue. L'entrée doit être
autoportante — lisible seule, sans avoir besoin de retrouver le PV ; le
pointeur vers le PV est un bonus, jamais le seul endroit où vit le
raisonnement. Voir `references/memory-protocol.md` pour la mécanique
complète.

## Hors périmètre pour la v1

La spécialisation poussée du PV — formats légaux, gabarits de conseil
d'administration avec exigences de gouvernance précises — dépasse ce que
cette compétence couvre. Pour ces besoins-là, propose de bâtir une
compétence sur mesure avec `atelier-forge` plutôt que de forcer ce gabarit
générique à répondre à des exigences qu'il ne connaît pas.
