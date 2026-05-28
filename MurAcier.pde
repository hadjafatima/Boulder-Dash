// Mur en acier : indestructible (instanceof Mur = ignoré par declencherExplosion)
class MurAcier extends Mur {

  MurAcier(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tileMurAcier != null) {
      imageMode(CORNER);
      image(tileMurAcier, px, py);
    } else {
      // Fallback : gris argenté avec hachures
      fill(100, 110, 120);
      noStroke();
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      fill(130, 140, 150);
      rect(px + 2, py + 2, TAILLE_TUILE - 4, TAILLE_TUILE - 4);
      stroke(80, 90, 100);
      strokeWeight(1);
      for (int d = 0; d < TAILLE_TUILE; d += 8)
        line(px + d, py, px, py + d);
      noStroke();
    }
  }
}
