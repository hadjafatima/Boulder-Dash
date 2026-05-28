class Sortie extends Element {
  boolean ouverte = false;

  Sortie(int x, int y) {
    super(x, y);
  }

  void afficher() {
    int px = x * TAILLE_TUILE;
    int py = y * TAILLE_TUILE;
    if (ouverte) {
      if (tileSortieOuverte != null) {
        int frame = (frameCount / 8) % 4;
        imageMode(CORNER);
        image(tileSortieOuverte[frame], px, py);
      } else {
        fill(30);
        rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
        fill(20, 20, 20);
        rect(px + 5, py + 5, TAILLE_TUILE - 10, TAILLE_TUILE - 10);
        fill(255, 255, 0);
        textSize(8);
        textAlign(CENTER, CENTER);
        text("OUT", px + TAILLE_TUILE/2, py + TAILLE_TUILE/2);
      }
    } else {
      if (tileSortieFermee != null) {
        imageMode(CORNER);
        image(tileSortieFermee, px, py);
      } else {
        fill(150, 0, 0);
        rect(px, py, TAILLE_TUILE, TAILLE_TUILE);
        fill(100, 0, 0);
        rect(px + 5, py + 5, TAILLE_TUILE - 10, TAILLE_TUILE - 10);
        stroke(50, 0, 0);
        strokeWeight(2);
        line(px + TAILLE_TUILE/2, py, px + TAILLE_TUILE/2, py + TAILLE_TUILE);
        noStroke();
      }
    }
  }
}
