// Classe de base pour tous les éléments de la grille
abstract class Element {
  int x, y;

  Element(int x, int y) {
    this.x = x;
    this.y = y;
  }

  abstract void afficher();
}
