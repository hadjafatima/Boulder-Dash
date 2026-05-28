class Papillon extends Ennemi {

  Papillon(int x, int y) {
    super(x, y);
    dx = -1;  // démarre en allant à gauche (comportement miroir de la libellule)
    dy = 0;
  }

  // Quand le papillon tue, l'explosion laisse des diamants
  void tuerJoueur(Joueur j, Niveau niveau) {
    j.vivant = false;
    niveau.declencherExplosion(j.x, j.y, true);
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

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tilePapillon != null) {
      int frame = (frameCount / 10) % 4;
      imageMode(CORNER);
      if (dx < 0) {
        pushMatrix();
        translate(px + TAILLE_TUILE, py);
        scale(-1, 1);
        image(tilePapillon[frame], 0, 0);
        popMatrix();
      } else {
        image(tilePapillon[frame], px, py);
      }
    } else {
      // Fallback : papillon dessiné (ailes violettes)
      fill(30); rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      int cx = px + TAILLE_TUILE / 2;
      int cy = py + TAILLE_TUILE / 2;
      fill(180, 60, 255, 200);
      ellipseMode(CENTER);
      ellipse(cx - 9, cy - 6, 16, 12);
      ellipse(cx + 9, cy - 6, 16, 12);
      ellipse(cx - 7, cy + 6, 12, 10);
      ellipse(cx + 7, cy + 6, 12, 10);
      fill(255, 220, 0);
      ellipse(cx, cy, 6, 10);
    }
  }
}
