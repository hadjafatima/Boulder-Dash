class Mur extends Element {
  Mur(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tileMur != null) {
      imageMode(CORNER);
      image(tileMur, px, py);
    } else {
      fill(100);
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      stroke(50);
      strokeWeight(2);
      line(px, py, px + TAILLE_TUILE, py + TAILLE_TUILE);
      line(px + TAILLE_TUILE, py, px, py + TAILLE_TUILE);
      noStroke();
    }
  }
}
