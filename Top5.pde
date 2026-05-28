class Top5 {
  int[]    scores = new int[5];
  String[] noms   = new String[5];

  int       NB_OBJETS = 14;
  float[]   ox, oy, ov;
  boolean[] estDiamant;
  int       frame = 0;

  Top5() {
    for (int i = 0; i < 5; i++) noms[i] = "";
    ox         = new float[NB_OBJETS];
    oy         = new float[NB_OBJETS];
    ov         = new float[NB_OBJETS];
    estDiamant = new boolean[NB_OBJETS];
    for (int i = 0; i < NB_OBJETS; i++) {
      ox[i]         = random(width);
      oy[i]         = random(-height, 0);
      ov[i]         = random(1.2, 3.5);
      estDiamant[i] = (random(1) < 0.4);
    }
    charger();
  }

  void actualiser() {
    frame++;
    for (int i = 0; i < NB_OBJETS; i++) {
      oy[i] += ov[i];
      if (oy[i] > height + 50) {
        ox[i]         = random(width);
        oy[i]         = -50;
        ov[i]         = random(1.2, 3.5);
        estDiamant[i] = (random(1) < 0.4);
      }
    }
  }

  void charger() {
    for (int i = 0; i < 5; i++) { scores[i] = 0; noms[i] = ""; }
    String[] lignes = loadStrings("top5.txt");
    if (lignes == null) return;
    // Format de chaque ligne : "pseudo|score" (le pseudo peut être vide)
    for (int i = 0; i < min(lignes.length, 5); i++) {
      String s = trim(lignes[i]);
      if (s.length() == 0) continue;
      int sep = s.indexOf('|');
      if (sep >= 0) {
        noms[i]   = s.substring(0, sep);
        scores[i] = int(s.substring(sep + 1));
      } else {
        scores[i] = int(s);
        noms[i]   = "";
      }
    }
  }

  void sauvegarder() {
    String[] lignes = new String[5];
    for (int i = 0; i < 5; i++) lignes[i] = noms[i] + "|" + str(scores[i]);
    saveStrings(dataPath("top5.txt"), lignes);
  }

  void ajouterScore(int score, String nom) {
    if (score <= 0) return;
    // Insertion triée : décale les entrées moins bonnes vers le bas
    for (int i = 0; i < 5; i++) {
      if (score > scores[i]) {
        for (int j = 4; j > i; j--) {
          scores[j] = scores[j - 1];
          noms[j]   = noms[j - 1];
        }
        scores[i] = score;
        noms[i]   = nom;
        sauvegarder();
        return;
      }
    }
  }

  // Vérifie si le score dépasse la dernière place du classement
  boolean estNouveauTop(int score) {
    return score > 0 && score > scores[4];
  }

  void afficher() {
    background(10, 8, 20);

    for (int i = 0; i < NB_OBJETS; i++) {
      if (estDiamant[i]) {
        dessinerDiamant((int)ox[i], (int)oy[i], 12, color(0, 180, 230, 140));
      } else {
        fill(55, 55, 60, 150);
        noStroke();
        ellipse(ox[i], oy[i], TAILLE_TUILE - 6, TAILLE_TUILE - 6);
      }
    }

    fill(0, 0, 0, 200);
    noStroke();
    rect(width/2 - 240, 48, 480, 104, 16);

    fill(120, 60, 0);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("TOP  5", width/2 + 3, 103);
    fill(255, 195, 0);
    text("TOP  5", width/2, 100);

    dessinerDiamant(width/2 - 208, 100, 18, color(0, 210, 255));
    dessinerDiamant(width/2 + 208, 100, 18, color(0, 210, 255));

    // Couleurs de rang : or, argent, bronze, puis gris décroissant
    color[] coulRangs = {
      color(255, 215,   0),
      color(210, 210, 210),
      color(190, 120,  55),
      color(170, 170, 170),
      color(130, 130, 130)
    };
    String[] medailles = { "#1", "#2", "#3", "#4", "#5" };

    for (int i = 0; i < 5; i++) {
      int ry = 205 + i * 66;
      boolean present = (scores[i] > 0);

      fill(0, 0, 0, present ? 175 : 80);
      noStroke();
      rect(width/2 - 270, ry - 25, 540, 50, 10);

      fill(coulRangs[i]);
      textSize(16);
      textAlign(LEFT, CENTER);
      text(medailles[i], width/2 - 248, ry);

      if (present) {
        fill(200);
        textSize(12);
        textAlign(LEFT, CENTER);
        text(noms[i].length() > 0 ? noms[i] : "---", width/2 - 185, ry);
        fill(255);
        textSize(16);
        textAlign(RIGHT, CENTER);
        text(str(scores[i]), width/2 + 248, ry);
      } else {
        fill(75);
        textSize(16);
        textAlign(RIGHT, CENTER);
        text("- - -", width/2 + 248, ry);
      }

      if (i < 4) {
        stroke(255, 255, 255, 20);
        strokeWeight(1);
        line(width/2 - 250, ry + 25, width/2 + 250, ry + 25);
        noStroke();
      }
    }

    fill(100);
    textSize(8);
    textAlign(CENTER, CENTER);
    text("ESC = retour au menu", width/2, height - 26);
  }

  void dessinerDiamant(int cx, int cy, int r, color c) {
    fill(c);
    noStroke();
    beginShape();
    vertex(cx,     cy - r);
    vertex(cx + r, cy);
    vertex(cx,     cy + r);
    vertex(cx - r, cy);
    endShape(CLOSE);
  }
}
