class Amoeba extends Element {

  Amoeba(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tileAmoeba != null) {
      int frame = (frameCount / 12 + x * 3 + y * 7) % 4;
      imageMode(CORNER);
      image(tileAmoeba[frame], px, py);
    } else {
      // Fallback : blob vert pulsant
      float pulse = 0.8 + 0.2 * sin(frameCount * 0.15 + x + y);
      fill(30); noStroke();
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      fill(30, (int)(200 * pulse), 60, 220);
      int m = (int)(TAILLE_TUILE * 0.1);
      rect(px + m, py + m, TAILLE_TUILE - m * 2, TAILLE_TUILE - m * 2, 6);
      fill(80, 255, 100, 160);
      int m2 = (int)(TAILLE_TUILE * 0.3);
      ellipseMode(CORNER);
      ellipse(px + m2, py + m2, TAILLE_TUILE - m2 * 2, TAILLE_TUILE - m2 * 2);
    }
  }
}
