class Menu {
  String[] options      = { "JOUER", "2 JOUEURS", "TOP 5", "EDITEUR", "QUITTER" };
  int      optionChoisie = 0;
  int      nbOptions     = options.length;
  int      choix         = 1; // 1 = jouer, 2 = top5, 3 = éditeur, 4 = multi

  // Objets décoratifs qui tombent en arrière-plan (rochers et diamants)
  int     NB_OBJETS  = 18;
  float[] ox, oy, ov;
  boolean[] estDiamant;
  int     menuFrame  = 0;

  Menu() {
    ox         = new float[NB_OBJETS];
    oy         = new float[NB_OBJETS];
    ov         = new float[NB_OBJETS];
    estDiamant = new boolean[NB_OBJETS];
    for (int i = 0; i < NB_OBJETS; i++) {
      ox[i]         = random(width);
      oy[i]         = random(-height, 0); // décalage vertical initial pour éviter un burst au démarrage
      ov[i]         = random(1.2, 4.0);
      estDiamant[i] = (random(1) < 0.35);
    }
  }

  void actualiser() {
    menuFrame++;
    for (int i = 0; i < NB_OBJETS; i++) {
      oy[i] += ov[i];
      if (oy[i] > height + 50) {
        ox[i]         = random(width);
        oy[i]         = -50;
        ov[i]         = random(1.2, 4.0);
        estDiamant[i] = (random(1) < 0.35);
      }
    }
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
    rect(width/2 - 320, 55, 640, 160, 18);

    // Ombre décalée puis titre principal pour un effet de relief
    fill(120, 60, 0);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("BOULDER DASH", width/2 + 4, 144);
    fill(255, 195, 0);
    text("BOULDER DASH", width/2, 140);

    dessinerDiamant(width/2 - 295, 140, 22, color(0, 210, 255));
    dessinerDiamant(width/2 + 295, 140, 22, color(0, 210, 255));

    fill(170);
    textSize(8);
    text("Collectez les diamants, ouvrez la sortie, survivez !", width/2, 215);

    int panY = 265;
    fill(0, 0, 0, 180);
    noStroke();
    rect(width/2 - 210, panY, 420, nbOptions * 68 + 20, 12);

    for (int i = 0; i < nbOptions; i++) {
      int optY = panY + 44 + i * 68;
      if (i == optionChoisie) {
        fill(255, 200, 0, 200);
        noStroke();
        rect(width/2 - 170, optY - 26, 340, 50, 8);
        fill(20);
        textSize(16);
        textAlign(CENTER, CENTER);
        text(options[i], width/2, optY);
        // Chevrons animés qui oscillent pour signaler l'option sélectionnée
        int decal = (int)(sin(menuFrame * 0.13) * 6);
        textSize(16);
        text(">", width/2 - 140 - decal, optY);
        text("<", width/2 + 140 + decal, optY);
      } else {
        fill(170);
        textSize(16);
        textAlign(CENTER, CENTER);
        text(options[i], width/2, optY);
      }
    }

    fill(100);
    textSize(8);
    textAlign(CENTER, CENTER);
    text("↑ ↓  naviguer   |   ENTRÉE  valider   |   M  son on/off", width/2, height - 44);
    text("1 joueur : flèches / ZQSD   |   2 joueurs : J1=ZQSD  J2=IJKL", width/2, height - 20);

    fill(son.sonActif ? color(80, 230, 80) : color(220, 80, 80));
    textSize(8);
    textAlign(LEFT, BOTTOM);
    text(son.sonActif ? "[M] Son : ON" : "[M] Son : OFF", 8, height - 4);
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

  // Retourne true quand l'utilisateur valide une option
  boolean gererEntree(char k, int code) {
    if (code == UP) {
      optionChoisie = (optionChoisie - 1 + nbOptions) % nbOptions;
      son.menuSelect();
    } else if (code == DOWN) {
      optionChoisie = (optionChoisie + 1) % nbOptions;
      son.menuSelect();
    } else if (code == ENTER || k == '\n' || k == '\r') {
      if      (optionChoisie == 0) { son.menuSelect(); choix = 1; return true; }
      else if (optionChoisie == 1) { son.menuSelect(); choix = 4; return true; }
      else if (optionChoisie == 2) { son.menuSelect(); choix = 2; return true; }
      else if (optionChoisie == 3) { son.menuSelect(); choix = 3; return true; }
      else exit();
    } else if (k == 'm' || k == 'M') {
      son.basculer();
    }
    return false;
  }
}
