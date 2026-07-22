# Installer Atelier

Ce guide t'accompagne pas à pas pour installer Atelier sur ton compte
claude.ai — même si tu n'as jamais installé quoi que ce soit sur un
ordinateur. Aucune connaissance technique requise, aucun terminal, rien à
configurer à la main. Tout se passe dans ton navigateur.

Compte environ dix minutes pour la première compétence.

## 1. Ce dont tu as besoin

- Un compte [claude.ai](https://claude.ai) (gratuit ou payant, les deux
  fonctionnent).
- L'application **Claude Desktop** ou **Claude Cowork**, ouverte dans ton
  navigateur ou installée sur ton poste. Si tu ne sais pas laquelle tu as,
  ce n'est pas grave : les étapes ci-dessous sont identiques dans les deux.

C'est tout. Pas de compte développeur, pas de carte de crédit
supplémentaire, pas de logiciel à installer en dehors de Claude lui-même.

## 2. Activer les capacités

Atelier a besoin que deux capacités soient allumées sur ton compte :
**l'exécution de code** et **la création de fichiers**. Ce sont elles qui
permettent à Claude de produire tes documents (profil d'entreprise,
comptes rendus, etc.).

1. Ouvre les **Réglages** de Claude (l'icône en haut ou dans le menu de ton
   compte).
2. Va dans **Capacités**.
3. Assure-toi que **l'exécution de code** et **la création de fichiers**
   sont toutes deux activées.

![Réglages → Capacités, avec l'exécution de code et la création de fichiers activées](screenshots/capabilities-toggle.png)

Si l'un des deux interrupteurs est déjà activé, tant mieux — passe à
l'étape suivante.

## 3. Télécharger les compétences

Atelier est un ensemble de sept compétences. Chacune se télécharge sous
forme de fichier **ZIP** — une seule pièce jointe qui regroupe tout le
contenu de la compétence. Tu n'as **pas besoin de l'ouvrir ni de le
décompresser** : Claude s'en charge tout seul quand tu le lui donnes tel
quel à l'étape suivante.

**Pour commencer, une seule compétence suffit : `atelier-fr.zip`.** C'est
le cœur d'Atelier — il te guide à travers un entretien d'accueil et te
propose les autres compétences au moment où tu en as besoin. Inutile de
tout télécharger d'un coup.

Clique sur un lien ci-dessous pour télécharger le ZIP correspondant.

| Compétence | Ce qu'elle fait | Télécharger |
|---|---|---|
| `atelier` | Le cœur : entretien d'accueil, profil d'entreprise | [atelier-fr.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-fr.zip) |
| `atelier-mentor` | Le guide : t'oriente vers la bonne compétence | [atelier-mentor-fr.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-mentor-fr.zip) |
| `atelier-boussole` | Le processus de réflexion pour les décisions difficiles | [atelier-boussole-fr.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-boussole-fr.zip) |
| `atelier-forge` | Crée tes propres compétences sur mesure | [atelier-forge-fr.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-forge-fr.zip) |
| `atelier-marketing` | Contenu, campagnes, voix de marque | [atelier-marketing-fr.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-marketing-fr.zip) |
| `atelier-ventes` | Pipeline, suivis, propositions, CRM | [atelier-ventes-fr.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-ventes-fr.zip) |
| `atelier-reunions` | Préparation, procès-verbaux, journaux de décisions | [atelier-reunions-fr.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-reunions-fr.zip) |

Le fichier atterrit dans ton dossier de téléchargements habituel — comme
n'importe quelle pièce jointe.

## 4. Téléverser une compétence

1. Dans Claude, ouvre **Personnaliser**.
2. Va dans **Compétences**.

![Personnaliser → Compétences](screenshots/customize-skills.png)

3. Clique sur le bouton pour téléverser une nouvelle compétence.
4. Choisis le fichier ZIP que tu viens de télécharger (par exemple
   `atelier-fr.zip`) — **sans le décompresser au préalable.**

![La fenêtre de téléversement, avec le fichier ZIP sélectionné](screenshots/upload-zip.png)

5. Confirme. Claude importe la compétence en quelques secondes.

Répète ces étapes pour chaque compétence additionnelle que tu veux
ajouter, quand tu en as besoin.

## 5. Vérifier que ça marche

Ouvre une **nouvelle conversation** et écris simplement :

> Je viens d'installer Atelier, par où je commence ?

![Une compétence Atelier affichée comme activée dans la liste des compétences](screenshots/skill-enabled.png)

Si tout fonctionne, Claude te répond par un court entretien d'accueil : il
te pose quelques questions sur ton entreprise et ton rôle, puis prépare
ton profil d'entreprise. Cet entretien est la preuve que la compétence est
bien installée et active.

## 6. Mettre à jour

Quand une nouvelle version d'Atelier sort :

1. Télécharge le nouveau ZIP de la même compétence (même lien qu'à
   l'étape 3).
2. Retéléverse-le dans **Personnaliser → Compétences**, comme à l'étape 4.

C'est tout — la nouvelle version remplace l'ancienne. Pour savoir ce qui a
changé d'une version à l'autre, consulte le fichier `CHANGELOG.md` du
dépôt : il liste les nouveautés en langage clair, sans jargon technique.

## 7. Si ça ne marche pas

Trois causes couvrent la grande majorité des cas :

1. **Les capacités sont désactivées.** Retourne à l'étape 2 et vérifie que
   l'exécution de code et la création de fichiers sont bien activées.
2. **La compétence n'est pas activée sur ton compte.** Retourne dans
   **Personnaliser → Compétences** et confirme qu'elle apparaît dans la
   liste, activée (comme à l'étape 5).
3. **Le ZIP a été décompressé avant d'être téléversé.** Si ton ordinateur
   a automatiquement extrait le fichier ZIP (certains navigateurs ou
   systèmes le font), tu te retrouves avec un dossier plutôt qu'un ZIP, ou
   avec un ZIP qui contient un dossier imbriqué. Claude s'attend à
   retrouver le contenu de la compétence directement à la racine du ZIP.
   Retélécharge le fichier original et téléverse-le sans y toucher, sans
   l'ouvrir, sans le renommer.

Si le problème persiste après avoir vérifié ces trois points, essaie de
fermer la conversation, d'en ouvrir une nouvelle, et de reposer la
question de l'étape 5.
