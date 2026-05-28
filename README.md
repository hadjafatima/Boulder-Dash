# 🪨 Boulder Dash — Jeu vidéo en Processing (POO)

> Projet réalisé dans le cadre de l'UE Programmation Orientée Objet — Semestre 4, FST de Limoges (2025-2026)  
> Encadré par **M. Tristan Vaccon**  
> Réalisé par **Mariem El Babidi**, **Hadja Fatoumata Dramé**, **Kadiatou Traoré** & **Alseny Diallo**

---

## Présentation

Recréation du classique arcade **Boulder Dash** (1984, Peter Liepa & Chris Gray) en **Processing 4 / Java**.  
Le joueur incarne Rockford : il creuse la terre, collecte des diamants, évite les rochers et les ennemis, puis atteint la sortie pour progresser.

Ce projet met en œuvre les principes fondamentaux de la **Programmation Orientée Objet** : héritage, polymorphisme, encapsulation, abstraction, et architecture MVC.

---

## Fonctionnalités

- 🎮 **6 niveaux** jouables au format texte `.txt` (dont des niveaux bonus)
- 👥 **Mode multijoueur** (2 joueurs simultanés, scores indépendants)
- 🌑 **Menu principal animé** (rochers et diamants en chute)
- 🔊 **Son procédural** (aucun fichier audio externe, synthèse Java pure)
- 🏆 **Classement Top 5** persistant avec saisie de pseudo
- 🛠️ **Éditeur de niveaux** graphique intégré
- ⏸️ **Pause** avec compensation du timer et du moteur physique
- 💀 Système de **3 vies**, timer de 150s, écrans Game Over et Victoire

---

## Règles du jeu

1. Collecter le quota minimal de diamants dans la grille.
2. Le quota atteint → la sortie s'ouvre automatiquement (son + changement visuel).
3. Toucher un ennemi ou être écrasé par un rocher = perte d'une vie (3 vies en solo).
4. Timer à 0 ou 0 vie restante = **Game Over**.
5. Atteindre la sortie ouverte = niveau suivant. Compléter les 6 niveaux = **Victoire**.

---

## Contrôles

| Touche(s) | Action |
|-----------|--------|
| Flèches / ZQSD | Déplacement (solo) |
| ZQSD (J1) / Flèches (J2) | Déplacement multijoueur |
| `P` | Pause |
| `M` | Son on/off |
| `ESC` | Retour au menu principal |

---

## Éléments de jeu

| Symbole | Élément | Description |
|---------|---------|-------------|
| `P` / `Q` | Joueur J1 / J2 | Personnage contrôlé (Q = multi uniquement) |
| `*` | Diamant | Collectible, tombe par gravité, scintille |
| `O` | Rocher | Tombe, écrase, poussable |
| `.` | Terre | Creusable, bloque la chute |
| `W` / `M` | Mur / Mur Magique | Fixe / Transforme un Rocher en Diamant |
| `E` | Sortie | S'ouvre quand le quota est atteint |
| `X` | Ennemi | Patrouille horizontale, tue au contact |

---

## Architecture

Le projet suit le patron **MVC** :

- **Modèle** — `Niveau.pde` + tableau `Element[][]` : état complet de la grille
- **Vue** — méthode `afficher()` de chaque sous-classe d'`Element`
- **Contrôleur** — `GestionnaireJeu.pde` + `MoteurPhysique.pde`

### Hiérarchie de classes

```
Element (abstraite)
├── Joueur
├── Ennemi
├── Rocher
├── Diamant
├── Mur
├── MurMagique
├── Sortie
└── Terre
```

### Structure des fichiers

```
BoulderDash/
├── BoulderDash.pde       # Point d'entrée (setup, draw, entrées)
├── GestionnaireJeu.pde   # États, score, timer, transitions, Top 5
├── MoteurPhysique.pde    # Gravité, collisions, IA ennemis (tick 150ms)
├── Niveau.pde            # Chargement et affichage de la grille
├── Element.pde           # Classe abstraite de base
├── Joueur.pde / Ennemi.pde / Rocher.pde / Diamant.pde
├── Mur.pde / MurMagique.pde / Sortie.pde / Terre.pde
├── Menu.pde              # Menu animé
├── Editeur.pde           # Éditeur de niveaux graphique
├── Son.pde + Son.java    # Audio procédural (Java pur)
├── Top5.pde              # Classement persistant (top5.txt)
├── constants.pde         # Constantes globales
└── data/
    ├── level1.txt
    ├── level2.txt
    ├── ...
    └── level6.txt
```

---

## Format des niveaux

Fichier `.txt` de **20×15 caractères**. Contraintes : exactement 1 joueur (`P`) et 1 sortie (`E`). Les bordures sont des murs (`W`).

La première ligne peut contenir un en-tête optionnel : `NORMAL:N` ou `BONUS:N` (N = nombre de diamants requis).

```
NORMAL:10
WWWWWWWWWWWWWWWWWWWW
W P  .  O  *  .    W
W  .  *  .  O  *   W
...
W                 E W
WWWWWWWWWWWWWWWWWWWW
```

---

## Éditeur de niveaux

L'éditeur graphique intégré permet de créer et modifier des niveaux sans quitter le jeu :

- **Clic gauche** : poser un élément
- **Clic droit** : effacer
- Palette d'éléments à droite, zone de dessin à gauche
- Sauvegarde vers `level1-6.txt` avec validation (1 joueur et 1 sortie obligatoires)

---

## Difficultés techniques résolues

**Gravité en cascade** — Parcours de la grille de bas en haut + tableau `aBoge[][]` pour éviter qu'un élément soit déplacé plusieurs fois par tick. Le moteur physique s'exécute à 150ms, indépendamment des 60 FPS d'affichage.

**Conflit `open()` Processing/Java** — La méthode `open()` de `PApplet` entre en conflit avec `javax.sound.sampled`. Solution : tout le code audio est isolé dans `Son.java` (Java pur), relié à Processing via `Son.pde`.

**Pause et timer** — À la mise en pause, `pauseDebut` est mémorisé. À la reprise, la durée de pause est ajoutée à `dernierTempsMillis` et à `dernierTick` pour éviter tout décalage.

---

## Environnement

| Outil | Détail |
|-------|--------|
| Langage | Java / Processing 4 |
| IDE | Processing IDE 4.x |
| Système | Windows 10 / 11 |
| Audio | `javax.sound.sampled` (Java SE) |
| Versioning | GitHub |

---

## Lancement

1. Ouvrir `BoulderDash.pde` dans **Processing IDE 4.x**
2. Cliquer sur ▶ **Run**
3. Naviguer dans le menu avec les flèches + Entrée
