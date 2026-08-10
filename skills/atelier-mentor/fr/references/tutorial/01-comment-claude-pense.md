# Comment Claude « pense »

Une conversation avec Claude tient dans un espace qui a une taille : la
**fenêtre de contexte**. C'est tout ce que Claude voit d'un coup pour te
répondre — tes messages, ses réponses, le contenu des fichiers qu'il a lus.
Rien en dehors de cette fenêtre n'existe pour lui au moment où il écrit sa
prochaine réponse, même si ça s'est dit plus tôt dans la même conversation.

Ce qui remplit cette fenêtre se compte en **jetons** — pense à un jeton
comme un petit morceau de mot ou de phrase, la même unité pour ce que tu
écris, ce que Claude répond, et ce qu'il lit dans un fichier. Chaque échange
en ajoute. La fenêtre a une taille fixe, et elle finit par se remplir.

Une conversation qui s'étire longtemps se dégrade pour cette raison précise :
une fois la fenêtre pleine, les premiers échanges doivent céder la place —
soit ils sont résumés, soit ils sortent carrément de ce que Claude voit. Le
fil que tu croyais partagé depuis le début ne l'est plus vraiment ; Claude
répond avec une version amputée ou résumée de ce qui s'est dit, pas avec le
souvenir complet.

Et une conversation qu'on vient de compacter n'est pas une conversation
neuve pour autant : elle repart avec un **résumé** de ce qui précède, pas
l'original. Un résumé garde ce que le résumeur a jugé essentiel — il perd
forcément des détails, des nuances, une phrase précise que tu avais
formulée avec soin trois échanges plus tôt. Une conversation neuve, elle,
n'a pas ce poids : elle commence vide, avec seulement ce que tu choisis d'y
mettre.

C'est exactement le problème que la pratique d'Atelier est construite pour
éviter. Plutôt que de laisser une conversation s'étirer jusqu'à devoir être
compactée, Atelier mise sur des conversations courtes et fraîches, et sur
une mémoire qui vit dans des fichiers plutôt que dans le fil de discussion :
le **relais** pour passer le travail d'une conversation à l'autre sans tout
réexpliquer, et la **mémoire d'entreprise** pour ce qui doit durer au-delà
d'une seule session.

## À essayer tout de suite

Demande-moi un relais, là, maintenant, sur ce qu'on vient de faire. Tu vas
voir le mécanisme dont je viens de parler : ce qui compte s'en va dans un
fichier, et la prochaine conversation repart courte au lieu de traîner
celle-ci.
