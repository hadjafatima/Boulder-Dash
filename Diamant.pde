class Diamant extends Element {
  boolean enChute = false;

  Diamant(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tileDiamant != null) {
      // Décalage de phase par position pour que chaque diamant scintille à son rythme
      int phase = ((frameCount + x * 7 + y * 13) / 10) % 4;
      imageMode(CORNER);
      image(tileDiamant[phase], px, py);
    } else {
      float t = (sin(frameCount * 0.08 + x * 0.7 + y * 1.3) + 1) / 2.0;
      fill(30);
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      fill((int)(t * 120), (int)(180 + t * 75), (int)(220 + t * 35));
      beginShape();
      vertex(px + TAILLE_TUILE/2, py + 5);
      vertex(px + TAILLE_TUILE - 5, py + TAILLE_TUILE/2);
      vertex(px + TAILLE_TUILE/2, py + TAILLE_TUILE - 5);
      vertex(px + 5, py + TAILLE_TUILE/2);
      endShape(CLOSE);
      fill(255, 255, 255, (int)(80 + t * 160));
      beginShape();
      vertex(px + TAILLE_TUILE/2, py + 5);
      vertex(px + TAILLE_TUILE/4, py + TAILLE_TUILE/2);
      vertex(px + TAILLE_TUILE/2, py + TAILLE_TUILE/4);
      endShape(CLOSE);
    }
  }
}
