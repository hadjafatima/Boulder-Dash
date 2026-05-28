class Niveau {
  int cols, rows;
  Element[][] grille;
  boolean succesChargement = false;
  boolean estBonus         = false;
  int     nbDiamantsRequis = 10;
  Joueur joueur;
  Joueur joueur2;
  Sortie sortie;
  ArrayList<Ennemi>    ennemis    = new ArrayList<Ennemi>();
  ArrayList<Explosion> explosions = new ArrayList<Explosion>();
  ArrayList<Amoeba>    amoebas    = new ArrayList<Amoeba>();

  boolean avecJoueur2 = false;

  Niveau(int index) {
    this(index, false);
  }

  Niveau(int index, boolean multi) {
    avecJoueur2 = multi;
    String[] lignes = loadStrings("level" + index + ".txt");
    if (lignes != null && lignes.length > 0) {
      int startLine = 0;
      if (lignes[0].startsWith("NORMAL:") || lignes[0].startsWith("BONUS:")) {
        estBonus = lignes[0].startsWith("BONUS:");
        String[] parts = lignes[0].split(":");
        if (parts.length > 1) nbDiamantsRequis = int(parts[1]);
        startLine = 1;
      }
      rows = lignes.length - startLine;
      cols = lignes[startLine].length();
      grille = new Element[cols][rows];
      chargerGrille(lignes, startLine);
      succesChargement = true;
    }
  }

  void chargerGrille(String[] lignes, int startLine) {
    for (int y = 0; y < rows; y++) {
      String ligne = lignes[y + startLine];
      for (int x = 0; x < cols && x < ligne.length(); x++) {
        char c = ligne.charAt(x);
        if      (c == 'W') grille[x][y] = new Mur(x, y);
        else if (c == 'M') grille[x][y] = new MurMagique(x, y);
        else if (c == '.') grille[x][y] = new Terre(x, y);
        else if (c == 'O') grille[x][y] = new Rocher(x, y);
        else if (c == '*') grille[x][y] = new Diamant(x, y);
        else if (c == 'E') {
          sortie = new Sortie(x, y);
          grille[x][y] = sortie;
        }
        else if (c == 'P') {
          joueur = new Joueur(x, y, 1);
          grille[x][y] = joueur;
        }
        else if (c == 'Q') {
          // Q = position de départ joueur 2, ignoré en mode solo (case vide)
          if (avecJoueur2) {
            joueur2 = new Joueur(x, y, 2);
            grille[x][y] = joueur2;
          }
        }
        else if (c == 'X') {
          Ennemi e = new Ennemi(x, y);
          ennemis.add(e);
          grille[x][y] = e;
        }
        else if (c == 'B') {
          Papillon p = new Papillon(x, y);
          ennemis.add(p);
          grille[x][y] = p;
        }
        else if (c == 'S') grille[x][y] = new MurAcier(x, y);
        else if (c == 'A') {
          Amoeba a = new Amoeba(x, y);
          amoebas.add(a);
          grille[x][y] = a;
        }
      }
    }
  }

  void declencherExplosion(int cx, int cy) {
    declencherExplosion(cx, cy, false);
  }

  void declencherExplosion(int cx, int cy, boolean laisseDiamants) {
    son.explosion();
    for (int oy = -1; oy <= 1; oy++) {
      for (int ox = -1; ox <= 1; ox++) {
        int ex = cx + ox;
        int ey = cy + oy;
        if (ex < 0 || ex >= cols || ey < 0 || ey >= rows) continue;
        Element e = grille[ex][ey];
        if (e instanceof Mur) continue;
        if (e instanceof Ennemi) ennemis.remove((Ennemi) e);
        Explosion exp = new Explosion(ex, ey, laisseDiamants);
        grille[ex][ey] = exp;
        explosions.add(exp);
      }
    }
  }

  Element getElement(int x, int y) {
    if (x < 0 || x >= cols || y < 0 || y >= rows) return new Mur(x, y);
    return grille[x][y];
  }

  void deplacerElement(Element e, int nx, int ny) {
    if (e.x >= 0 && e.x < cols && e.y >= 0 && e.y < rows) {
      grille[e.x][e.y] = null;
    }
    e.x = nx;
    e.y = ny;
    if (nx >= 0 && nx < cols && ny >= 0 && ny < rows) {
      grille[nx][ny] = e;
    }
  }

  void afficher() {
    pushMatrix();
    translate(0, TAILLE_TUILE);
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        Element e = grille[x][y];
        if (e == null) {
          fill(0);
          rect(x * TAILLE_TUILE, y * TAILLE_TUILE, TAILLE_TUILE, TAILLE_TUILE);
        } else {
          e.afficher();
        }
      }
    }
    popMatrix();
  }
}
