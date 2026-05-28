class Editeur {
  int TAILLE    = 32;
  int COLS      = 20;
  int ROWS      = 15;
  int OFFSET_Y  = 40; // hauteur réservée au HUD en haut
  int PALETTE_X = 640; // COLS * TAILLE - séparateur grille / palette

  char[][] grille = new char[COLS][ROWS];
  char selection  = 'W';
  int  fichierNum = 1;

  boolean estBonus         = false;
  int     nbDiamantsRequis = 10;

  String message      = "";
  int    messageTimer = 0;

  char[]   palChars = {' ', 'W', 'S', 'M', '.', 'O', '*', 'E', 'P', 'Q', 'X', 'B', 'A'};
  String[] palNoms  = {"Vide", "Mur", "Acier", "Mur Mag.", "Terre", "Rocher", "Diamant", "Sortie", "Joueur 1", "Joueur 2", "Ennemi", "Papillon", "Amoeba"};

  Editeur() { reinitialiser(); }

  // Crée un élément temporaire à (0,0) pour l'affichage dans la palette et la grille
  Element creerElementTemp(char c) {
    if (c == 'W') return new Mur(0, 0);
    if (c == 'M') return new MurMagique(0, 0);
    if (c == '.') return new Terre(0, 0);
    if (c == 'O') return new Rocher(0, 0);
    if (c == '*') return new Diamant(0, 0);
    if (c == 'E') return new Sortie(0, 0);
    if (c == 'P') return new Joueur(0, 0);
    if (c == 'S') return new MurAcier(0, 0);
    if (c == 'X') return new Ennemi(0, 0);
    if (c == 'B') return new Papillon(0, 0);
    if (c == 'A') return new Amoeba(0, 0);
    if (c == 'Q') return new Joueur(0, 0, 2);
    return null;
  }

  // Dessine un élément à (px, py) mis à l'échelle de la taille de la grille éditeur
  void dessinerCase(char c, int px, int py, int taille) {
    pushMatrix();
    translate(px, py);
    scale((float)taille / TAILLE_TUILE);
    Element e = creerElementTemp(c);
    if (e != null) {
      e.afficher();
    } else {
      fill(30); noStroke();
      rect(0, 0, TAILLE_TUILE, TAILLE_TUILE);
    }
    popMatrix();
    // Certains afficher() laissent ellipseMode en CORNER — on remet CENTER pour ne pas casser le reste
    ellipseMode(CENTER);
  }

  void reinitialiser() {
    for (int x = 0; x < COLS; x++)
      for (int y = 0; y < ROWS; y++)
        grille[x][y] = (x == 0 || x == COLS-1 || y == 0 || y == ROWS-1) ? 'W' : ' ';
    afficherMessage("Grille réinitialisée");
  }

  void actualiser() {
    if (messageTimer > 0) messageTimer--;
  }

  boolean estBordure(int gx, int gy) {
    return gx == 0 || gx == COLS-1 || gy == 0 || gy == ROWS-1;
  }

  void peindre(int mx, int my, boolean effacer) {
    if (mx >= PALETTE_X || my < OFFSET_Y) return;
    int gx = mx / TAILLE;
    int gy = (my - OFFSET_Y) / TAILLE;
    if (gx < 0 || gx >= COLS || gy < 0 || gy >= ROWS) return;
    if (estBordure(gx, gy)) return;

    if (!effacer) {
      // Joueur et sortie sont uniques dans un niveau : on supprime l'exemplaire précédent avant d'en poser un nouveau
      if (selection == 'P' || selection == 'E') {
        for (int x = 0; x < COLS; x++)
          for (int y = 0; y < ROWS; y++)
            if (grille[x][y] == selection) grille[x][y] = ' ';
      }
    }
    grille[gx][gy] = effacer ? ' ' : selection;
  }

  void clicPalette(int mx, int my) {
    int idx = (my - OFFSET_Y - 16) / 38;
    if (idx >= 0 && idx < palChars.length)
      selection = palChars[idx];
  }

  void gererEntree(char k, int code) {
    if (k == 's' || k == 'S') { sauvegarder();   return; }
    if (k == 'r' || k == 'R') { reinitialiser(); return; }
    if (k == 'l' || k == 'L') { charger();       return; }
    if (k == 'b' || k == 'B') {
      estBonus = !estBonus;
      afficherMessage(estBonus ? "Mode : BONUS (45s)" : "Mode : NORMAL (150s)");
      return;
    }
    if (k == '+' || k == '=') {
      nbDiamantsRequis = min(nbDiamantsRequis + 1, 99);
      afficherMessage("Diamants requis : " + nbDiamantsRequis);
      return;
    }
    if (k == '-') {
      nbDiamantsRequis = max(nbDiamantsRequis - 1, 1);
      afficherMessage("Diamants requis : " + nbDiamantsRequis);
      return;
    }
    if (k >= '1' && k <= '9') {
      fichierNum = k - '0';
      afficherMessage("Fichier cible : level" + fichierNum + ".txt");
    }
  }

  void sauvegarder() {
    int nbP = 0, nbE = 0, nbD = 0;
    for (int x = 0; x < COLS; x++)
      for (int y = 0; y < ROWS; y++) {
        if (grille[x][y] == 'P') nbP++;
        if (grille[x][y] == 'E') nbE++;
        if (grille[x][y] == '*') nbD++;
      }
    // On refuse la sauvegarde si le niveau n'est pas jouable
    if (nbP != 1 || nbE != 1) {
      afficherMessage("Erreur : " + nbP + " joueur(s), " + nbE + " sortie(s) — il en faut 1 de chaque !");
      return;
    }
    if (nbD < nbDiamantsRequis) {
      afficherMessage("Erreur : " + nbD + " diamant(s) sur la carte, " + nbDiamantsRequis + " requis — ajoutez-en !");
      return;
    }
    // Première ligne = en-tête de configuration du niveau
    String[] lignes = new String[ROWS + 1];
    lignes[0] = (estBonus ? "BONUS" : "NORMAL") + ":" + nbDiamantsRequis;
    for (int y = 0; y < ROWS; y++) {
      StringBuilder sb = new StringBuilder();
      for (int x = 0; x < COLS; x++) sb.append(grille[x][y]);
      lignes[y + 1] = sb.toString();
    }
    saveStrings(dataPath("level" + fichierNum + ".txt"), lignes);
    afficherMessage("Sauvegardé : level" + fichierNum + ".txt  (" + nbD + " diamants, " + nbDiamantsRequis + " requis)");
  }

  void charger() {
    String[] lignes = loadStrings("level" + fichierNum + ".txt");
    if (lignes == null) {
      afficherMessage("Introuvable : level" + fichierNum + ".txt");
      return;
    }
    // Lit l'en-tête si présent (une ligne ne peut pas être à la fois NORMAL/BONUS et une rangée de 20 cases)
    int startLine = 0;
    estBonus = false;
    nbDiamantsRequis = 10;
    if (lignes[0].startsWith("NORMAL:") || lignes[0].startsWith("BONUS:")) {
      estBonus = lignes[0].startsWith("BONUS:");
      String[] parts = lignes[0].split(":");
      if (parts.length > 1) nbDiamantsRequis = int(parts[1]);
      startLine = 1;
    }
    for (int x = 0; x < COLS; x++)
      for (int y = 0; y < ROWS; y++)
        grille[x][y] = ' ';
    for (int y = 0; y < min(lignes.length - startLine, ROWS); y++) {
      String ligne = lignes[y + startLine];
      for (int x = 0; x < min(ligne.length(), COLS); x++)
        grille[x][y] = ligne.charAt(x);
    }
    // Force le contour en mur au cas où le fichier ne l'aurait pas
    for (int x = 0; x < COLS; x++) {
      if (grille[x][0]      != 'W') grille[x][0]      = 'W';
      if (grille[x][ROWS-1] != 'W') grille[x][ROWS-1] = 'W';
    }
    for (int y = 0; y < ROWS; y++) {
      if (grille[0][y]      != 'W') grille[0][y]      = 'W';
      if (grille[COLS-1][y] != 'W') grille[COLS-1][y] = 'W';
    }
    afficherMessage("Chargé : level" + fichierNum + ".txt");
  }

  void afficherMessage(String msg) {
    message      = msg;
    messageTimer = 210; // ~3.5 secondes à 60 FPS
  }

  void afficher() {
    background(15);

    for (int x = 0; x < COLS; x++) {
      for (int y = 0; y < ROWS; y++) {
        int px = x * TAILLE;
        int py = OFFSET_Y + y * TAILLE;
        dessinerCase(grille[x][y], px, py, TAILLE);
      }
    }

    // Hachures sur les bordures pour signaler qu'elles sont verrouillées
    stroke(255, 255, 255, 35);
    strokeWeight(1);
    for (int x = 0; x < COLS; x++) {
      for (int y = 0; y < ROWS; y++) {
        if (estBordure(x, y)) {
          int px = x * TAILLE;
          int py = OFFSET_Y + y * TAILLE;
          clip(px, py, TAILLE, TAILLE);
          for (int d = -TAILLE; d < TAILLE * 2; d += 8)
            line(px + d, py, px + d + TAILLE, py + TAILLE);
          noClip();
        }
      }
    }
    noStroke();

    stroke(0, 0, 0, 80);
    strokeWeight(0.5);
    for (int x = 0; x <= COLS; x++)
      line(x*TAILLE, OFFSET_Y, x*TAILLE, OFFSET_Y + ROWS*TAILLE);
    for (int y = 0; y <= ROWS; y++)
      line(0, OFFSET_Y + y*TAILLE, COLS*TAILLE, OFFSET_Y + y*TAILLE);
    noStroke();

    // Aperçu de l'élément sélectionné sous le curseur
    int hx = mouseX / TAILLE;
    int hy = (mouseY - OFFSET_Y) / TAILLE;
    if (mouseX < PALETTE_X && mouseY >= OFFSET_Y && hx >= 0 && hx < COLS && hy >= 0 && hy < ROWS) {
      int cpx = hx * TAILLE;
      int cpy = OFFSET_Y + hy * TAILLE;
      if (estBordure(hx, hy)) {
        // Case verrouillée : croix rouge pour signaler l'interdiction
        fill(220, 50, 50, 80);
        noStroke();
        rect(cpx, cpy, TAILLE, TAILLE);
        stroke(220, 50, 50, 220);
        strokeWeight(2);
        noFill();
        rect(cpx, cpy, TAILLE, TAILLE);
        line(cpx+6,        cpy+6,        cpx+TAILLE-6, cpy+TAILLE-6);
        line(cpx+TAILLE-6, cpy+6,        cpx+6,        cpy+TAILLE-6);
      } else {
        dessinerCase(selection, cpx, cpy, TAILLE);
        fill(255, 255, 255, 70);
        noStroke();
        rect(cpx, cpy, TAILLE, TAILLE);
        stroke(255, 220, 0, 220);
        strokeWeight(2);
        noFill();
        rect(cpx, cpy, TAILLE, TAILLE);
      }
      noStroke();
    }

    // Panneau palette à droite
    fill(22, 22, 32);
    rect(PALETTE_X, 0, width - PALETTE_X, height);
    stroke(55);
    line(PALETTE_X, 0, PALETTE_X, height);
    noStroke();

    fill(180);
    textSize(8);
    textAlign(CENTER, TOP);
    text("PALETTE", PALETTE_X + (width - PALETTE_X) / 2, OFFSET_Y + 4);

    for (int i = 0; i < palChars.length; i++) {
      int py  = OFFSET_Y + 16 + i * 38;
      boolean sel = (palChars[i] == selection);
      if (sel) {
        fill(255, 220, 0, 70);
        stroke(255, 220, 0);
        strokeWeight(1.5);
        rect(PALETTE_X + 6, py, width - PALETTE_X - 12, 34, 5);
        noStroke();
      }
      dessinerCase(palChars[i], PALETTE_X + 12, py + 4, 26);
      fill(sel ? color(255, 220, 0) : color(195));
      textSize(8);
      textAlign(LEFT, CENTER);
      text(palNoms[i], PALETTE_X + 46, py + 11);
      fill(sel ? color(255, 220, 0) : color(110));
      textSize(8);
      text("[" + (palChars[i] == ' ' ? "esp" : str(palChars[i])) + "]", PALETTE_X + 46, py + 24);
    }

    int basePal = OFFSET_Y + 16 + palChars.length * 38 + 6;
    fill(90);
    textSize(8);
    textAlign(LEFT, TOP);
    text("[S] sauvegarder",        PALETTE_X + 10, basePal);
    text("[L] charger",            PALETTE_X + 10, basePal + 12);
    text("[R] réinitialiser",      PALETTE_X + 10, basePal + 24);
    text("[1-9] fichier cible",    PALETTE_X + 10, basePal + 36);
    text("[B] normal / bonus",     PALETTE_X + 10, basePal + 48);
    text("[+/-] diamants requis",  PALETTE_X + 10, basePal + 60);

    fill(0, 170);
    noStroke();
    rect(0, 0, width, OFFSET_Y);
    fill(255);
    textSize(8);
    textAlign(LEFT, CENTER);
    text("ÉDITEUR DE NIVEAUX", 10, 20);
    // Indicateur de mode centré, coloré selon NORMAL/BONUS
    fill(estBonus ? color(255, 180, 0) : color(100, 200, 255));
    textSize(8);
    int nbDPresents = 0;
    for (int x = 0; x < COLS; x++)
      for (int y = 0; y < ROWS; y++)
        if (grille[x][y] == '*') nbDPresents++;
    // Compte mis à jour en temps réel — rouge si insuffisant pour valider le niveau
    boolean manque = nbDPresents < nbDiamantsRequis;
    textAlign(CENTER, CENTER);
    text((estBonus ? "BONUS  45s" : "NORMAL  150s") + "   |   ", PALETTE_X / 2 - 40, 20);
    fill(manque ? color(255, 80, 80) : color(80, 255, 120));
    text(nbDPresents + " / " + nbDiamantsRequis + " diamants", PALETTE_X / 2 + 55, 20);
    fill(160);
    textSize(8);
    textAlign(RIGHT, CENTER);
    text("Fichier : level" + fichierNum + ".txt  |  ESC = retour menu", width - 10, 20);

    fill(estBonus ? color(255, 180, 0) : color(120));
    textSize(8);
    textAlign(LEFT, BOTTOM);
    text("[B] basculer en bonus", 8, height - 5);

    if (messageTimer > 0) {
      // Fondu progressif sur les 40 dernières frames du message
      float alpha = messageTimer > 40 ? 255 : messageTimer * 6.375;
      boolean erreur = message.startsWith("Erreur") || message.startsWith("Introuvable");
      fill(erreur ? color(200, 30, 30, alpha * 0.8) : color(0, 0, 0, alpha * 0.75));
      noStroke();
      rect(0, height - 34, PALETTE_X, 34);
      fill(erreur ? color(255, 100, 100, alpha) : color(255, 220, 0, alpha));
      textSize(8);
      textAlign(CENTER, CENTER);
      text(message, PALETTE_X / 2, height - 17);
    }
  }
}
