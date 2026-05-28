class Terre extends Element {
  Terre(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tileTerre != null) {
      imageMode(CORNER);
      image(tileTerre, px, py);
    } else {
      fill(139, 69, 19);
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      fill(100, 50, 10);
      rect(px + 5,  py + 5,  5, 5);
      rect(px + 20, py + 15, 6, 6);
      rect(px + 10, py + 25, 4, 4);
    }
  }
}
