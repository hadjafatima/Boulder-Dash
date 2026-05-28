// Un rocher en chute qui traverse ce mur réapparaît en dessous transformé en diamant
class MurMagique extends Element {
  MurMagique(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (tileMurMagique != null) {
      int frame = (frameCount / 12) % 4;
      imageMode(CORNER);
      image(tileMurMagique[frame], px, py);
    } else {
      fill(150, 0, 150);
      rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
      stroke(255, 0, 255);
      strokeWeight(2);
      line(px, py, px + TAILLE_TUILE, py + TAILLE_TUILE);
      line(px + TAILLE_TUILE, py, px, py + TAILLE_TUILE);
      noStroke();
    }
  }
}
