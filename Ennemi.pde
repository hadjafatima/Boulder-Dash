class Ennemi extends Element {
  int dx = 1;
  int dy = 0;

  Ennemi(int x, int y) {
    super(x, y);
  }

  // Déclenche l'explosion centrée sur le joueur tué (surchargé par Papillon)
  void tuerJoueur(Joueur j, Niveau niveau) {
    j.vivant = false;
    niveau.declencherExplosion(j.x, j.y, false);
  }

  void actualiser(Niveau niveau) {
    int nx = x + dx;
    Element cible = niveau.getElement(nx, y);

    if (cible instanceof Joueur) {
      Joueur j = (Joueur) cible;
      if (millis() >= j.bloqueJusquA) tuerJoueur(j, niveau);
      return;
    }

    if (cible == null) {
      niveau.deplacerElement(this, nx, y);
    } else {
      dx = -dx;
      nx = x + dx;
      cible = niveau.getElement(nx, y);
      if (cible instanceof Joueur) {
        Joueur j = (Joueur) cible;
        if (millis() >= j.bloqueJusquA) tuerJoueur(j, niveau);
        return;
      }
      if (cible == null) niveau.deplacerElement(this, nx, y);
    }

    verifierChevauchement(niveau);
  }

  void verifierChevauchement(Niveau niveau) {
    if (niveau.joueur != null && niveau.joueur.vivant) {
      if (niveau.joueur.x == x && niveau.joueur.y == y) {
        if (millis() >= niveau.joueur.bloqueJusquA) tuerJoueur(niveau.joueur, niveau);
      }
    }
    if (niveau.joueur2 != null && niveau.joueur2.vivant) {
      if (niveau.joueur2.x == x && niveau.joueur2.y == y) {
        if (millis() >= niveau.joueur2.bloqueJusquA) tuerJoueur(niveau.joueur2, niveau);
      }
    }
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tileEnnemi != null) {
      int frame = (frameCount / 10) % 4;
      imageMode(CORNER);
      if (dx < 0) {
        pushMatrix();
        translate(px + TAILLE_TUILE, py);
        scale(-1, 1);
        image(tileEnnemi[frame], 0, 0);
        popMatrix();
      } else {
        image(tileEnnemi[frame], px, py);
      }
    } else {
      fill(30); rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      fill(210, 40, 40);
      ellipseMode(CORNER);
      ellipse(px + 4, py + 6, TAILLE_TUILE - 8, TAILLE_TUILE - 12);
    }
  }
}
