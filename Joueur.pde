class Joueur extends Element {
  boolean vivant = true;
  int numero;
  int startX, startY;
  int bloqueJusquA = 0;

  // direction : 0=idle, 1=droite, 2=gauche, 3=haut, 4=bas
  int direction      = 0;
  int prevDirection  = 0;
  int frameAnim      = 0;
  int compteurAnim   = 0;
  int dernierMvt     = 0; // frameCount du dernier déplacement

  Joueur(int x, int y) {
    super(x, y);
    numero = 1;
    startX = x;
    startY = y;
  }

  Joueur(int x, int y, int num) {
    super(x, y);
    numero = num;
    startX = x;
    startY = y;
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;

    int tempsBloque = max(0, bloqueJusquA - millis());
    boolean bloque  = tempsBloque > 0;

    // Retour à idle si aucun mouvement depuis 10 frames
    if (frameCount - dernierMvt > 10) direction = 0;

    // Clignotement + compte à rebours pendant pénalité de respawn
    if (bloque && frameCount % 14 < 7) {
      fill(30); noStroke();
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      int secondes = (tempsBloque + 999) / 1000;
      fill(255, 220, 0);
      textSize(10);
      textAlign(CENTER, CENTER);
      text(secondes, px + TAILLE_TUILE / 2, py + TAILLE_TUILE / 2);
      return;
    }

    // Réinitialiser l'animation si la direction a changé
    if (direction != prevDirection) {
      frameAnim    = 0;
      compteurAnim = 0;
      prevDirection = direction;
    }

    // Avancer l'animation
    compteurAnim++;
    if (compteurAnim >= 8) {
      compteurAnim = 0;
      int nbFrames = getNbFrames();
      frameAnim = (frameAnim + 1) % nbFrames;
    }

    // Fond de case
    fill(30); noStroke();
    rect(px, py, TAILLE_TUILE, TAILLE_TUILE);

    if (spritesJoueur != null) {
      PImage sprite = spritesJoueur[direction][frameAnim];
      imageMode(CORNER);
      if (numero == 2) tint(100, 149, 237); // teinte bleue pour J2
      image(sprite, px, py);
      noTint();
    } else {
      // Fallback si sprites non chargés
      color c = (numero == 1) ? color(0, 255, 0) : color(255, 90, 20);
      fill(c);
      ellipseMode(CORNER);
      ellipse(px + 4, py + 4, TAILLE_TUILE - 8, TAILLE_TUILE - 8);
      if (!bloque) {
        fill(0);
        ellipse(px + 12, py + 12, 6, 6);
        ellipse(px + 22, py + 12, 6, 6);
      }
    }

    if (bloque) {
      int secondes = (tempsBloque + 999) / 1000;
      fill(255, 220, 0);
      textSize(10);
      textAlign(CENTER, CENTER);
      text(secondes, px + TAILLE_TUILE / 2, py + TAILLE_TUILE / 2);
    }
  }

  int getNbFrames() {
    switch (direction) {
      case 1: case 2: return SPR_FRAMES_WALK_RIGHT;
      case 3:         return SPR_FRAMES_WALK_UP;
      case 4:         return SPR_FRAMES_WALK_DOWN;
      default:        return SPR_FRAMES_IDLE;
    }
  }

  void deplacer(char k, int code, Niveau niveau, GestionnaireJeu jeu) {
    if (!vivant) return;
    if (millis() < bloqueJusquA) return;

    int dx = 0, dy = 0;

    if (numero == 1) {
      if (jeu.modeMulti) {
        if      (k == 'z' || k == 'Z' || k == 'w' || k == 'W') dy = -1;
        else if (k == 's' || k == 'S')                          dy =  1;
        else if (k == 'q' || k == 'Q' || k == 'a' || k == 'A') dx = -1;
        else if (k == 'd' || k == 'D')                          dx =  1;
      } else {
        if      (code == UP    || k == 'z' || k == 'Z' || k == 'w' || k == 'W') dy = -1;
        else if (code == DOWN  || k == 's' || k == 'S')                          dy =  1;
        else if (code == LEFT  || k == 'q' || k == 'Q' || k == 'a' || k == 'A') dx = -1;
        else if (code == RIGHT || k == 'd' || k == 'D')                          dx =  1;
      }
    } else {
      if      (code == UP)    dy = -1;
      else if (code == DOWN)  dy =  1;
      else if (code == LEFT)  dx = -1;
      else if (code == RIGHT) dx =  1;
    }

    if      (dx ==  1) { direction = 1; dernierMvt = frameCount; }
    else if (dx == -1) { direction = 2; dernierMvt = frameCount; }
    else if (dy == -1) { direction = 3; dernierMvt = frameCount; }
    else if (dy ==  1) { direction = 4; dernierMvt = frameCount; }

    if (dx != 0 || dy != 0) {
      int nx = x + dx;
      int ny = y + dy;

      Element cible = niveau.getElement(nx, ny);

      if (cible == null || cible instanceof Terre) {
        niveau.deplacerElement(this, nx, ny);
      } else if (cible instanceof Diamant) {
        niveau.deplacerElement(this, nx, ny);
        jeu.ajouterScore(1, numero);
      } else if (cible instanceof Rocher && dy == 0) {
        int px2 = nx + dx;
        if (niveau.getElement(px2, ny) == null) {
          niveau.deplacerElement(cible, px2, ny);
          niveau.deplacerElement(this, nx, ny);
        }
      } else if (cible instanceof Amoeba) {
        vivant = false;
        niveau.declencherExplosion(x, y);
      } else if (cible instanceof Sortie) {
        Sortie sortie = (Sortie) cible;
        if (sortie.ouverte) {
          niveau.deplacerElement(this, nx, ny);
          if (jeu.modeMulti) jeu.niveauSuivant();
          else               jeu.demarrerBonusTemps();
        }
      }
    }
  }
}
