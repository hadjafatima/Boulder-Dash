class Explosion extends Element {
  int     createdAt;
  boolean laisseDiamant;
  static final int DUREE_MS = 800;

  Explosion(int x, int y) {
    this(x, y, false);
  }

  Explosion(int x, int y, boolean laisseDiamant) {
    super(x, y);
    this.laisseDiamant = laisseDiamant;
    createdAt = millis();
  }

  boolean termine() { return millis() - createdAt >= DUREE_MS; }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    float t  = constrain((float)(millis() - createdAt) / DUREE_MS, 0, 1);
    int   al = (int)(255 * (1.0 - t));

    noStroke();
    // Diamants qui explosent : teinte cyan/bleue
    if (laisseDiamant) {
      fill(80, 200, 255, al);
    } else {
      fill(255, (int)(160 * (1 - t)), 0, al);
    }
    rect(px, py, TAILLE_TUILE, TAILLE_TUILE);

    if (t < 0.4) {
      fill(255, 255, 200, al);
      int m = (int)(TAILLE_TUILE * 0.2);
      rect(px + m, py + m, TAILLE_TUILE - m * 2, TAILLE_TUILE - m * 2);
    }
  }
}
