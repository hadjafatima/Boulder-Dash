class SplashScreen {
  int  frameAnim    = 0;
  int  compteurAnim = 0;
  int  tempsDebut;
  // Décalages oscillants des diamants décoratifs
  float[] dOx = { 120, 280, 520, 680, 200, 600 };
  float[] dOy = { 220, 310, 260, 330, 430, 410 };
  float[] dOp = { 0, 1.2, 2.5, 0.7, 1.8, 3.1 }; // phase

  SplashScreen() {
    tempsDebut = millis();
  }

  void actualiser() {
    compteurAnim++;
    if (compteurAnim >= 8) {
      compteurAnim = 0;
      frameAnim = (frameAnim + 1) % SPR_FRAMES_IDLE;
    }
    for (int i = 0; i < dOy.length; i++) {
      dOp[i] += 0.04;
    }
  }

  void afficher() {
    int T = TAILLE_TUILE;
    background(0);

    // ── Bordure de murs haut et bas ──────────────────────────────────────
    if (tileMur != null) {
      imageMode(CORNER);
      for (int x = 0; x < width; x += T) {
        image(tileMur, x, 0);
        image(tileMur, x, height - T);
      }
      // Colonnes gauche et droite
      for (int y = T; y < height - T; y += T) {
        image(tileMur, 0, y);
        image(tileMur, width - T, y);
      }
    }

    // ── Rochers et diamants décoratifs flottants ─────────────────────────
    imageMode(CENTER);
    for (int i = 0; i < dOy.length; i++) {
      float fy = dOy[i] + sin(dOp[i]) * 8;
      if (i % 2 == 0 && tileRocher != null) {
        tint(255, 180);
        image(tileRocher[0], dOx[i], fy);
        noTint();
      } else if (tileDiamant != null) {
        int frame = (frameCount / 10 + i) % 4;
        image(tileDiamant[frame], dOx[i], fy);
      }
    }
    imageMode(CORNER);

    // ── Titre ────────────────────────────────────────────────────────────
    textAlign(CENTER, CENTER);

    // Ombre
    fill(100, 50, 0);
    textSize(32);
    text("BOULDER", width/2 + 3, 163);
    text("DASH",    width/2 + 3, 203);

    // Texte principal
    fill(255, 200, 0);
    text("BOULDER", width/2, 160);
    fill(255, 140, 0);
    text("DASH",    width/2, 200);

    // ── Rockford animé ───────────────────────────────────────────────────
    if (spritesJoueur != null) {
      imageMode(CENTER);
      image(spritesJoueur[0][frameAnim], width/2, 320, T * 3, T * 3);
      imageMode(CORNER);
    }

    // ── Ligne de diamants décoratifs sous Rockford ───────────────────────
    if (tileDiamant != null) {
      int frame = (frameCount / 10) % 4;
      imageMode(CENTER);
      int[] xs = { width/2 - 120, width/2 - 60, width/2, width/2 + 60, width/2 + 120 };
      for (int x : xs) image(tileDiamant[frame], x, 420);
      imageMode(CORNER);
    }

    // ── "PRESS ANY KEY" clignotant ───────────────────────────────────────
    if ((frameCount / 25) % 2 == 0) {
      fill(255);
      textSize(16);
      textAlign(CENTER, CENTER);
      text("PRESS ANY KEY", width/2, 500);
    }

    // ── Crédits ──────────────────────────────────────────────────────────
    fill(80);
    textSize(8);
    textAlign(CENTER, CENTER);
    text("BASED ON BOULDER DASH (C) 1984 FIRST STAR SOFTWARE", width/2, height - T - 16);
  }

  // Retourne true si le splash peut être quitté (après 1 sec minimum)
  boolean gererEntree() {
    return millis() - tempsDebut > 1000;
  }
}
