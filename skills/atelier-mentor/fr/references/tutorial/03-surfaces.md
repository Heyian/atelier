# Les surfaces

Claude apparaît à plus d'un endroit, et le choix de la surface change ce qui
est réellement possible dans la conversation — pas juste son allure.

## Chat contre l'onglet Cowork

Le **Chat** est une conversation : tu écris, Claude répond, et l'échange est
tout le travail. L'**onglet Cowork** est pensé pour un autre genre de tâche —
celle qui prend plus qu'un aller-retour rapide, avec plusieurs étapes entre le
début et la fin.

## claude.ai sur le web contre Desktop, et ce que chacun peut atteindre

Séparément du choix Chat contre Cowork, il y a l'endroit d'où tu travailles :
**claude.ai** dans un navigateur, ou l'application **Claude Desktop**
installée sur ton ordinateur. Cowork lui-même est accessible des trois
façons — claude.ai sur le web, l'application Desktop, et le mobile. Et une
fois dans une session Cowork, l'accès aux dossiers suit une seule règle :
elle peut lire et écrire des fichiers dans les dossiers que tu as connectés
sur ton ordinateur, mais seulement pendant que l'application Claude Desktop
est ouverte et en marche sur cet ordinateur-là. Ferme Desktop, et cet accès
se ferme avec — peu importe que tu aies lancé la session depuis le web,
Desktop, ou ton téléphone.

> **Vérifié le 2026-08-10** — source : centre d'aide Anthropic, article 15520349
> (« Use Claude Cowork on web, desktop, and mobile »). Les capacités changent de
> mois en mois : montre cette date à la personne, et propose de revérifier dans
> `references/sources.md` avant qu'elle bâtisse quoi que ce soit dessus.

Est-ce que l'**onglet Chat** dans Desktop a ce même accès aux dossiers, ou
aucun accès du tout — ce n'est pas tranché par les sources que mentor a
vérifiées. La question reste ouverte, ce n'est pas un « non ». Si ça compte
pour ce que tu t'apprêtes à faire, demande à mentor de revérifier avant de te
fier à l'une ou l'autre réponse.

## La portée des connecteurs

Dans l'interface, cette section s'appelle **Connecteurs** (menu
Personnaliser, sous-menu Connecteurs). Les connecteurs web et distants
fonctionnent depuis claude.ai, Cowork, Claude Desktop et Claude Mobile, sur
tous les plans, sans restriction de plan notée. Les extensions Desktop ne
fonctionnent que dans l'application Claude Desktop. Les connecteurs
personnalisés — ceux que tu configures toi-même, en pointant vers un serveur
de ton choix — fonctionnent depuis claude.ai, Cowork et Desktop, sur les
plans Free, Pro, Max, Team et Enterprise ; Free est plafonné à un seul
connecteur personnalisé. À l'intérieur d'une session Cowork précisément, un
connecteur rejoint le monde extérieur en passant par l'infonuagique
d'Anthropic, pas par ton réseau local, alors un connecteur personnalisé doit
pointer vers un serveur joignable depuis l'internet public.

> **Vérifié le 2026-08-10** — source : centre d'aide Anthropic, article 11176164
> (« Use connectors to extend Claude's capabilities »). Les capacités changent de
> mois en mois : montre cette date à la personne, et propose de revérifier dans
> `references/sources.md` avant qu'elle bâtisse quoi que ce soit dessus.

## À essayer de ton bord

Ouvre claude.ai sur le web et, séparément, l'application Claude Desktop si tu
l'as installée. Compare ce que chacun affiche sous Connecteurs, et, si tu
utilises Cowork, vérifie si Desktop est ouvert avant de lui demander de
toucher à un dossier local — c'est la condition dont dépend la réponse sur
l'accès aux dossiers ci-dessus.
