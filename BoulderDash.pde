GestionnaireJeu jeu;
Son             son;
Menu            menu;
Editeur         editeur;
Top5            top5;
boolean         dansSplash  = true;
boolean         dansMenu    = false;
boolean         dansEditeur = false;
boolean         dansTop5    = false;

SplashScreen    splash;

PFont    fontArcade;
PImage[][] spritesJoueur; // [direction 0-4][frame]

// Tuiles du tileset
PImage   tileTerre;
PImage[] tileRocher;         // 4 frames
PImage[] tileDiamant;        // 4 frames
PImage   tileMur;
PImage[] tileMurMagique;     // 4 frames
PImage   tileSortieFermee;
PImage[] tileSortieOuverte;  // 4 frames
PImage[] tileEnnemi;         // 4 frames (libellule / firefly)
PImage[] tilePapillon;       // 4 frames (papillon / butterfly)
PImage   tileMurAcier;       // 1 frame  (mur en acier)
PImage[] tileAmoeba;         // 4 frames

void setup() {
  size(800, 640);
  frameRate(FPS);
  son  = new Son(this);
  top5 = new Top5();
  menu = new Menu();
  fontArcade = createFont("PressStart2P.ttf", 64);
  textFont(fontArcade);
  chargerSprites();
  chargerTuiles();
  splash = new SplashScreen();
  son.demarrerMusique("menu.mid");
}

void chargerSprites() {
  PImage sheet = loadImage("rockford.png");
  if (sheet == null) return;

  // Remplacer la couleur de fond (107,109,0) par transparent
  sheet.loadPixels();
  int bg = sheet.pixels[0];
  for (int i = 0; i < sheet.pixels.length; i++) {
    if (sheet.pixels[i] == bg) sheet.pixels[i] = color(0, 0, 0, 0);
  }
  sheet.updatePixels();

  // direction 0=idle, 1=droite, 2=gauche(miroir), 3=haut, 4=bas
  int[] rows   = { SPR_ROW_IDLE, SPR_ROW_WALK_RIGHT, SPR_ROW_WALK_RIGHT, SPR_ROW_WALK_UP, SPR_ROW_WALK_DOWN };
  int[] frames = { SPR_FRAMES_IDLE, SPR_FRAMES_WALK_RIGHT, SPR_FRAMES_WALK_RIGHT, SPR_FRAMES_WALK_UP, SPR_FRAMES_WALK_DOWN };

  spritesJoueur = new PImage[5][];
  for (int dir = 0; dir < 5; dir++) {
    spritesJoueur[dir] = new PImage[frames[dir]];
    for (int f = 0; f < frames[dir]; f++) {
      PImage src = sheet.get(f * SPR_W, rows[dir] * SPR_H, SPR_W, SPR_H);
      if (dir == 2) src = miroir(src); // gauche = miroir droite
      src.resize(TAILLE_TUILE, TAILLE_TUILE);
      spritesJoueur[dir][f] = src;
    }
  }
}

void chargerTuiles() {
  PImage sheet = loadImage("tileset.png");
  if (sheet == null) return;
  // Pas de suppression de fond : chaque cellule a son propre fond noir

  tileTerre       = scaleTile(sheet, TILE_COL_DIRT, 0);
  tileMur          = scaleTile(sheet, TILE_COL_WALL, 0);
  tileSortieFermee = scaleTile(sheet, TILE_COL_EXIT_CLOSED, 0);

  tileRocher = new PImage[4];
  for (int f = 0; f < 4; f++) tileRocher[f] = scaleTile(sheet, TILE_COL_ROCK, f);

  tileDiamant = new PImage[4];
  for (int f = 0; f < 4; f++) tileDiamant[f] = scaleTile(sheet, TILE_COL_DIAMOND, f);

  tileMurMagique = new PImage[4];
  for (int f = 0; f < 4; f++) tileMurMagique[f] = scaleTile(sheet, TILE_COL_MAGICWALL, f);

  tileSortieOuverte = new PImage[4];
  for (int f = 0; f < 4; f++) tileSortieOuverte[f] = scaleTile(sheet, TILE_COL_EXIT_OPEN, f);

  tileEnnemi = new PImage[4];
  for (int f = 0; f < 4; f++) tileEnnemi[f] = scaleTile(sheet, TILE_COL_ENEMY, f);

  tilePapillon = new PImage[4];
  for (int f = 0; f < 4; f++) tilePapillon[f] = scaleTile(sheet, TILE_COL_PAPILLON, f);

  tileMurAcier = scaleTile(sheet, TILE_COL_STEEL_WALL, 0);

  tileAmoeba = new PImage[4];
  for (int f = 0; f < 4; f++) tileAmoeba[f] = scaleTile(sheet, TILE_COL_AMOEBA, f);
}

PImage scaleTile(PImage sheet, int col, int row) {
  PImage tile = sheet.get(col * SPR_W, row * SPR_H, SPR_W, SPR_H);
  tile.resize(TAILLE_TUILE, TAILLE_TUILE);
  return tile;
}

PImage miroir(PImage src) {
  PImage dst = createImage(src.width, src.height, ARGB);
  src.loadPixels();
  dst.loadPixels();
  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      dst.pixels[y * src.width + (src.width - 1 - x)] = src.pixels[y * src.width + x];
    }
  }
  dst.updatePixels();
  return dst;
}

void draw() {
  background(0);
  if (dansSplash) {
    splash.actualiser();
    splash.afficher();
    return;
  }
  if (dansMenu) {
    menu.actualiser();
    menu.afficher();
  } else if (dansEditeur) {
    editeur.actualiser();
    editeur.afficher();
  } else if (dansTop5) {
    top5.actualiser();
    top5.afficher();
  } else {
    jeu.actualiser();
    jeu.afficher();
  }
}

void keyPressed() {
  if (dansSplash) {
    if (splash.gererEntree()) {
      dansSplash = false;
      dansMenu   = true;
      menu       = new Menu();
    }
    return;
  }

  // key = 0 empêche Processing de fermer la fenêtre sur ESC
  if (keyCode == ESC) {
    key = 0;
    if (dansEditeur) {
      dansEditeur = false;
      dansMenu    = true;
      menu        = new Menu();
      son.demarrerMusique("menu.mid");
    } else if (dansTop5) {
      dansTop5 = false;
      dansMenu = true;
      menu     = new Menu();
      son.demarrerMusique("menu.mid");
    } else if (!dansMenu) {
      if (jeu != null) jeu.enregistrerScore();
      dansMenu = true;
      menu     = new Menu();
      son.demarrerMusique("menu.mid");
    }
    return;
  }

  if (dansTop5) return;

  if (dansMenu) {
    boolean lancer = menu.gererEntree(key, keyCode);
    if (lancer) {
      son.arreterMusique();
      dansMenu = false;
      if (menu.choix == 3) {
        dansEditeur = true;
        editeur     = new Editeur();
      } else if (menu.choix == 2) {
        dansTop5 = true;
      } else if (menu.choix == 4) {
        jeu = new GestionnaireJeu(true);
      } else {
        jeu = new GestionnaireJeu();
      }
    }
  } else if (dansEditeur) {
    editeur.gererEntree(key, keyCode);
  } else {
    jeu.gererEntree(key, keyCode);
  }
}

void mousePressed() {
  if (!dansEditeur) return;
  // Clic à droite de PALETTE_X = clic sur la palette, sinon on peint la grille
  if (mouseX >= editeur.PALETTE_X) {
    editeur.clicPalette(mouseX, mouseY);
  } else {
    editeur.peindre(mouseX, mouseY, mouseButton == RIGHT);
  }
}

void mouseDragged() {
  if (!dansEditeur) return;
  if (mouseX < editeur.PALETTE_X) {
    editeur.peindre(mouseX, mouseY, mouseButton == RIGHT);
  }
}
