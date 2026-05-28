final int TAILLE_TUILE = 40;
final int FPS          = 60;

final int ETAT_JEU      = 0;
final int ETAT_GAMEOVER = 1;
final int ETAT_VICTOIRE = 2;
final int ETAT_PAUSE         = 3;
final int ETAT_SAISIE_PSEUDO = 4;
final int ETAT_FIN_MULTI     = 5;
final int ETAT_TRANSITION    = 6;
final int ETAT_BONUS_TEMPS   = 7;
final int ETAT_PRE_NIVEAU    = 8;

final int TILE_COL_PAPILLON    = 8;
final int TILE_COL_STEEL_WALL  = 5;
final int TILE_COL_AMOEBA      = 2;

// Spritesheet Rockford (96x240, grille 16x16, fond = couleur(107,109,0))
final int SPR_W = 16;
final int SPR_H = 16;
final int SPR_ROW_IDLE       = 0;  // 6 frames : idle face caméra
final int SPR_ROW_WALK_RIGHT = 2;  // 4 frames : marche droite (aussi miroir pour gauche)
final int SPR_ROW_WALK_DOWN  = 7;  // 3 frames : marche vers caméra
final int SPR_ROW_WALK_UP    = 9;  // 4 frames : marche dos caméra
final int SPR_FRAMES_IDLE       = 6;
final int SPR_FRAMES_WALK_RIGHT = 4;
final int SPR_FRAMES_WALK_DOWN  = 3;
final int SPR_FRAMES_WALK_UP    = 4;

// Tileset (192x384, fond blanc, 16x16 par cellule, 12 cols × 24 rows)
// Chaque groupe de 4 lignes = 4 frames d'animation (thème caverne 1 = lignes 0-3)
final int TILE_COL_DIRT         = 1;
final int TILE_COL_ROCK         = 3;
final int TILE_COL_DIAMOND      = 4;
final int TILE_COL_WALL         = 6;
final int TILE_COL_MAGICWALL    = 7;
final int TILE_COL_EXIT_CLOSED  = 0;
final int TILE_COL_EXIT_OPEN    = 11;
final int TILE_COL_ENEMY        = 9;
