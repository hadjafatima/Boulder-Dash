class GestionnaireJeu {
  Niveau         niveau;
  MoteurPhysique physique;

  boolean modeMulti    = false;

  // --- Solo ---
  int etat;
  int diamantsRecoltes;
  int scoreGlobal   = 0;
  int scoreCible    = 10;
  int indexNiveau   = 0;
  int vies          = 3;

  int dernierTick      = 0;
  int intervalleTick   = 150;

  int tempsInitial;
  int tempsRestant;
  int dernierTempsMillis;
  int pauseDebut = 0;

  boolean scoreDejaEnregistre = false;
  boolean nouvelleEntreeTop5  = false;
  String  pseudoEnCours       = "";
  int     etatApres           = ETAT_GAMEOVER;

  boolean mortEnCours      = false;
  int     mortDebut        = 0;
  int     dernierTickBonus = 0;
  int     preNiveauDebut   = 0;

  // --- Multi ---
  int scoreJ1      = 0;
  int scoreJ2      = 0;
  int diamantsJ1   = 0;
  int diamantsJ2   = 0;
  int timerGlobal  = 300;
  boolean avancerNiveauAuto = false;
  int     tempsTransition   = 0;    // millis() timestamp de fin de transition inter-niveaux

  // Constructeur solo
  GestionnaireJeu() {
    modeMulti = false;
    physique  = new MoteurPhysique(this);
    initialiserNiveau();
  }

  // Constructeur multi
  GestionnaireJeu(boolean multi) {
    modeMulti = multi;
    physique  = new MoteurPhysique(this);
    if (modeMulti) initialiserNiveauMulti();
    else           initialiserNiveau();
  }

  // ─── SOLO ───────────────────────────────────────────────────────────────

  void demarrerJeu() {
    etat               = ETAT_JEU;
    dernierTempsMillis = millis();
    dernierTick        = millis();
  }

  void initialiserNiveau() {
    etat                = ETAT_PRE_NIVEAU;
    preNiveauDebut      = millis();
    diamantsRecoltes    = 0;
    scoreDejaEnregistre = false;
    nouvelleEntreeTop5  = false;
    pseudoEnCours       = "";
    mortEnCours         = false;

    niveau       = new Niveau(indexNiveau + 1);
    scoreCible   = niveau.nbDiamantsRequis;
    tempsInitial = niveau.estBonus ? 45 : 150;
    tempsRestant = tempsInitial;

    if (niveau.estBonus && niveau.sortie != null) {
      niveau.sortie.ouverte = true;
    }

    if (!niveau.succesChargement) {
      terminerPartie(ETAT_VICTOIRE);
    }
  }

  void perdreVie() {
    vies--;
    if (vies <= 0) {
      vies = 0;
      terminerPartie(ETAT_GAMEOVER);
    } else {
      initialiserNiveau();
    }
  }

  void terminerPartie(int etatCible) {
    if (etatCible == ETAT_GAMEOVER) son.jingleGameOver();
    else if (etatCible == ETAT_VICTOIRE) son.jingleVictoire();

    if (!scoreDejaEnregistre && scoreGlobal > 0 && top5.estNouveauTop(scoreGlobal)) {
      nouvelleEntreeTop5 = true;
      etatApres          = etatCible;
      pseudoEnCours      = "";
      etat               = ETAT_SAISIE_PSEUDO;
    } else {
      enregistrerScore();
      etat = etatCible;
    }
  }

  void enregistrerScore() {
    if (!scoreDejaEnregistre && scoreGlobal > 0) {
      nouvelleEntreeTop5  = top5.estNouveauTop(scoreGlobal);
      top5.ajouterScore(scoreGlobal, pseudoEnCours.trim().length() > 0 ? pseudoEnCours.trim() : "");
      scoreDejaEnregistre = true;
    }
  }

  void confirmerPseudo() {
    if (!scoreDejaEnregistre && scoreGlobal > 0) {
      String nom = pseudoEnCours.trim().length() > 0 ? pseudoEnCours.trim() : "???";
      top5.ajouterScore(scoreGlobal, nom);
      scoreDejaEnregistre = true;
      nouvelleEntreeTop5  = true;
    }
    etat = etatApres;
  }

  // ─── MULTI ──────────────────────────────────────────────────────────────

  void initialiserNiveauMulti() {
    etat              = ETAT_JEU;
    diamantsJ1        = 0;
    diamantsJ2        = 0;
    avancerNiveauAuto = false;
    dernierTempsMillis = millis();
    dernierTick        = millis();

    niveau     = new Niveau(indexNiveau + 1, true);
    scoreCible = niveau.nbDiamantsRequis;

    if (!niveau.succesChargement) {
      finDePartieMulti();
      return;
    }
    if (niveau.estBonus && niveau.sortie != null) {
      niveau.sortie.ouverte = true;
    }
  }

  void finDePartieMulti() {
    etat = ETAT_FIN_MULTI;
  }

  // Respawn d'un joueur à sa position de départ avec pénalité de 3 secondes
  void respawnerJoueur(Joueur j) {
    // Retirer le joueur de sa case actuelle si c'est bien lui qui l'occupe
    if (j.x >= 0 && j.x < niveau.cols && j.y >= 0 && j.y < niveau.rows) {
      if (niveau.grille[j.x][j.y] == j) niveau.grille[j.x][j.y] = null;
    }
    // Forcer le placement à la position de départ
    j.x = j.startX;
    j.y = j.startY;
    j.vivant      = true;
    j.bloqueJusquA = millis() + 3000;
    if (j.startX >= 0 && j.startX < niveau.cols && j.startY >= 0 && j.startY < niveau.rows) {
      niveau.grille[j.startX][j.startY] = j;
    }
  }

  void demarrerBonusTemps() {
    son.sortieOuverte();
    if (tempsRestant > 0) {
      etat             = ETAT_BONUS_TEMPS;
      dernierTickBonus = millis();
    } else {
      niveauSuivant();
    }
  }

  // ─── COMMUN ─────────────────────────────────────────────────────────────

  void niveauSuivant() {
    indexNiveau++;
    if (modeMulti) initialiserNiveauMulti();
    else           initialiserNiveau();
  }

  void ajouterScore(int points, int joueurNum) {
    son.collecterDiamant();
    if (modeMulti) {
      if (joueurNum == 1) { scoreJ1 += points * 10; diamantsJ1 += points; }
      else                { scoreJ2 += points * 10; diamantsJ2 += points; }
      // Avancer uniquement quand TOUS les diamants de la carte sont ramassés
      if (compterDiamantsRestants() == 0) {
        avancerNiveauAuto = true;
      }
    } else {
      diamantsRecoltes += points;
      scoreGlobal      += points * 10;
      if (diamantsRecoltes >= scoreCible && niveau.sortie != null && !niveau.sortie.ouverte) {
        niveau.sortie.ouverte = true;
        son.sortieOuverte();
      }
    }
  }

  int compterDiamantsRestants() {
    int count = 0;
    for (int cy = 0; cy < niveau.rows; cy++)
      for (int cx = 0; cx < niveau.cols; cx++)
        if (niveau.grille[cx][cy] instanceof Diamant) count++;
    return count;
  }

  void ajouterBonus(int points) {
    if (modeMulti) {
      scoreJ1 += points / 2;
      scoreJ2 += points / 2;
    } else {
      scoreGlobal += points;
    }
  }

  // ─── BOUCLE ─────────────────────────────────────────────────────────────

  void actualiser() {
    if (etat == ETAT_PAUSE)        return;
    if (etat == ETAT_SAISIE_PSEUDO) return;

    // Transition inter-niveaux : attendre la fin du délai puis charger le niveau suivant
    if (etat == ETAT_TRANSITION) {
      if (millis() >= tempsTransition) niveauSuivant();
      return;
    }

    if (etat == ETAT_PRE_NIVEAU) {
      if (millis() - preNiveauDebut >= 2500) demarrerJeu();
      return;
    }

    if (etat == ETAT_BONUS_TEMPS) {
      int tb = millis();
      if (tb - dernierTickBonus >= 60) {
        dernierTickBonus = tb;
        if (tempsRestant > 0) {
          tempsRestant--;
          scoreGlobal += 5;
          son.collecterDiamant();
        } else {
          niveauSuivant();
        }
      }
      return;
    }

    if (etat != ETAT_JEU) return;

    // Attendre la fin de l'explosion avant de perdre une vie
    if (!modeMulti && mortEnCours) {
      if (millis() - mortDebut >= 900) {
        mortEnCours = false;
        perdreVie();
      }
      return;
    }

    int t = millis();

    if (modeMulti) {
      if (t - dernierTempsMillis >= 1000) {
        timerGlobal--;
        dernierTempsMillis += 1000;
        if (timerGlobal <= 0) {
          timerGlobal = 0;
          finDePartieMulti();
          return;
        }
      }
    } else {
      if (t - dernierTempsMillis >= 1000) {
        tempsRestant--;
        dernierTempsMillis += 1000;
        if (tempsRestant <= 0) {
          tempsRestant = 0;
          if (niveau.joueur != null && niveau.joueur.vivant && !mortEnCours) {
            niveau.joueur.vivant = false;
            niveau.declencherExplosion(niveau.joueur.x, niveau.joueur.y);
            son.joueurMort();
            mortEnCours = true;
            mortDebut   = millis();
          }
          return;
        }
      }
    }

    // Auto-avancement multi : tous les diamants collectés → écran de transition
    if (modeMulti && avancerNiveauAuto) {
      avancerNiveauAuto = false;
      son.sortieOuverte();
      etat             = ETAT_TRANSITION;
      tempsTransition  = millis() + 2500;
      return;
    }

    if (t - dernierTick > intervalleTick) {
      physique.actualiser(niveau);
      dernierTick = t;

      if (modeMulti) {
        if (niveau.joueur  != null && !niveau.joueur.vivant) {
          son.joueurMort();
          respawnerJoueur(niveau.joueur);
        }
        if (niveau.joueur2 != null && !niveau.joueur2.vivant) {
          son.joueurMort();
          respawnerJoueur(niveau.joueur2);
        }
      } else {
        if (niveau.joueur != null && !niveau.joueur.vivant && !mortEnCours) {
          son.joueurMort();
          mortEnCours = true;
          mortDebut   = millis();
        }
      }
    }
  }

  void gererEntree(char k, int code) {
    if (!modeMulti && etat == ETAT_SAISIE_PSEUDO) {
      if (code == ENTER || k == '\n' || k == '\r') {
        confirmerPseudo();
      } else if (code == BACKSPACE) {
        if (pseudoEnCours.length() > 0)
          pseudoEnCours = pseudoEnCours.substring(0, pseudoEnCours.length() - 1);
      } else if (k >= 32 && k < 127 && pseudoEnCours.length() < 10) {
        pseudoEnCours += k;
      }
      return;
    }

    if (etat == ETAT_PRE_NIVEAU) { demarrerJeu(); return; }
    if (etat == ETAT_BONUS_TEMPS) return;

    if (k == 'p' || k == 'P') {
      if (etat == ETAT_JEU) {
        etat       = ETAT_PAUSE;
        pauseDebut = millis();
        son.menuSelect();
      } else if (etat == ETAT_PAUSE) {
        int duree = millis() - pauseDebut;
        dernierTempsMillis += duree;
        dernierTick        += duree;
        etat = ETAT_JEU;
        son.menuSelect();
      }
      return;
    }

    if (k == 'm' || k == 'M') {
      son.basculer();
      return;
    }

    if (etat == ETAT_PAUSE) return;

    if (etat != ETAT_JEU) {
      if (modeMulti) {
        return;  // En multi : seul ESC (géré par BoulderDash) retourne au menu
      } else {
        enregistrerScore();
        indexNiveau = 0;
        scoreGlobal = 0;
        vies        = 3;
        initialiserNiveau();
      }
      return;
    }

    if (niveau.joueur != null) {
      niveau.joueur.deplacer(k, code, niveau, this);
    }
    if (modeMulti && niveau.joueur2 != null) {
      niveau.joueur2.deplacer(k, code, niveau, this);
    }
  }

  // ─── AFFICHAGE ──────────────────────────────────────────────────────────

  void afficher() {
    if (etat == ETAT_PRE_NIVEAU && !modeMulti) {
      afficherPreNiveau();
      return;
    }

    if (niveau != null && niveau.succesChargement) {
      niveau.afficher();
    }

    if (modeMulti) {
      afficherHUDMulti();
    } else {
      afficherHUDSolo();
    }
  }

  void afficherPreNiveau() {
    background(0);
    int T = TAILLE_TUILE;

    // Bordure de murs
    if (tileMur != null) {
      imageMode(CORNER);
      for (int x = 0; x < width; x += T) {
        image(tileMur, x, 0);
        image(tileMur, x, height - T);
      }
      for (int y = T; y < height - T; y += T) {
        image(tileMur, 0, y);
        image(tileMur, width - T, y);
      }
    }

    // Nom de la cave
    char lettre = (char)('A' + indexNiveau);
    textAlign(CENTER, CENTER);
    fill(80, 40, 0); textSize(32);
    text("CAVE  " + lettre, width/2 + 3, 143);
    fill(255, 200, 0);
    text("CAVE  " + lettre, width/2, 140);

    if (niveau != null && niveau.estBonus) {
      fill(80, 40, 0); textSize(24);
      text("BONUS !", width/2 + 2, 202);
      fill(255, 140, 0);
      text("BONUS !", width/2, 200);
    }

    // Séparateur en diamants
    if (tileDiamant != null) {
      int f = (frameCount / 10) % 4;
      imageMode(CENTER);
      for (int i = -3; i <= 3; i++) image(tileDiamant[f], width/2 + i * 48, 270);
      imageMode(CORNER);
    }

    // Infos du niveau
    fill(255); textSize(12);
    text("Diamants requis    " + scoreCible, width/2, 330);
    text("Points par diamant    10", width/2, 375);
    text("Temps imparti    " + tempsInitial + " sec", width/2, 420);

    // Score en cours
    fill(160); textSize(8);
    text("Score    " + scoreGlobal + "    Vies    " + vies, width/2, 480);

    // PRESS ANY KEY clignotant
    if ((frameCount / 25) % 2 == 0) {
      fill(255); textSize(8);
      text("PRESS ANY KEY", width/2, 540);
    }
  }

  void afficherHUDMulti() {
    fill(0, 170);
    noStroke();
    rect(0, 0, width, 40);

    // Joueur 1 (gauche, vert)
    fill(0, 220, 0);
    textSize(8);
    textAlign(LEFT, CENTER);
    text("J1: " + scoreJ1 + " pts", 10, 13);
    fill(160);
    textSize(8);
    text("D: " + diamantsJ1, 10, 30);

    // Centre : Niveau + diamants restants + Timer
    int restants = (niveau != null && niveau.succesChargement) ? compterDiamantsRestants() : 0;
    fill(255);
    textSize(8);
    textAlign(CENTER, CENTER);
    text("Niveau " + (indexNiveau + 1) + "   |   Restants: " + restants, width / 2, 13);
    if (timerGlobal <= 30) fill(255, 50, 50);
    else if (timerGlobal <= 60) fill(255, 180, 0);
    else fill(255, 220, 0);
    textSize(8);
    text("Temps: " + timerGlobal + "s", width / 2, 30);

    // Joueur 2 (droite, orange)
    fill(255, 90, 20);
    textSize(8);
    textAlign(RIGHT, CENTER);
    text("J2: " + scoreJ2 + " pts", width - 10, 13);
    fill(160);
    textSize(8);
    text("D: " + diamantsJ2, width - 10, 30);

    // Son
    fill(son.sonActif ? color(80, 255, 80) : color(200, 80, 80));
    textSize(8);
    textAlign(LEFT, BOTTOM);
    text(son.sonActif ? "[M] Son:ON" : "[M] Son:OFF", 8, height - 5);

    // Contrôles
    fill(120);
    textSize(8);
    textAlign(RIGHT, BOTTOM);
    text("J1:ZQSD  J2:Fleches  |  [P]Pause  |  [ESC]Menu", width - 8, height - 5);

    if (etat == ETAT_PAUSE) {
      fill(0, 190);
      rect(0, 0, width, height);
      fill(255, 220, 0);
      textSize(32);
      textAlign(CENTER, CENTER);
      text("PAUSE", width / 2, height / 2 - 30);
      fill(200);
      textSize(12);
      text("Appuyez sur P pour continuer", width / 2, height / 2 + 35);
    }

    if (etat == ETAT_TRANSITION) {
      // La carte reste visible en arrière-plan, overlay semi-transparent par-dessus
      fill(0, 0, 0, 170);
      rect(0, 0, width, height);

      fill(255, 220, 0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("NIVEAU TERMINE !", width / 2, height / 2 - 80);

      fill(0, 220, 0);
      textSize(16);
      text("J1  " + scoreJ1 + " pts", width / 2 - 160, height / 2);
      fill(255, 90, 20);
      text("J2  " + scoreJ2 + " pts", width / 2 + 160, height / 2);

      int resteSec = max(1, (tempsTransition - millis() + 999) / 1000);
      fill(200);
      textSize(12);
      text("Niveau suivant dans " + resteSec + "...", width / 2, height / 2 + 70);
    }

    if (etat == ETAT_FIN_MULTI) {
      fill(0, 210);
      rect(0, 0, width, height);

      String msg;
      color cMsg;
      if (scoreJ1 > scoreJ2) {
        msg  = "JOUEUR 1 GAGNE !";
        cMsg = color(0, 255, 0);
      } else if (scoreJ2 > scoreJ1) {
        msg  = "JOUEUR 2 GAGNE !";
        cMsg = color(255, 90, 20);
      } else {
        msg  = "EGALITE !";
        cMsg = color(255, 220, 0);
      }

      fill(cMsg);
      textSize(32);
      textAlign(CENTER, CENTER);
      text(msg, width / 2, height / 2 - 90);

      // Scores finaux
      fill(0, 220, 0);
      textSize(16);
      text("J1  " + scoreJ1 + " pts", width / 2 - 150, height / 2);
      fill(255, 90, 20);
      text("J2  " + scoreJ2 + " pts", width / 2 + 150, height / 2);

      fill(180);
      textSize(10);
      textAlign(CENTER, CENTER);
      text("Appuyez sur ESC pour retourner au menu", width / 2, height / 2 + 65);
    }
  }

  void afficherHUDSolo() {
    fill(0, 160);
    noStroke();
    rect(0, 0, width, 40);

    fill(255);
    textSize(8);
    textAlign(LEFT, CENTER);
    text("Niv." + (indexNiveau + 1), 8, 20);
    if (niveau != null && niveau.estBonus) {
      fill(255, 180, 0);
      text(" BONUS", 8, 31);
      fill(255);
    }

    textAlign(CENTER, CENTER);
    text("Diamants: " + diamantsRecoltes + "/" + scoreCible, width * 0.28, 20);
    text("Score: " + scoreGlobal, width * 0.50, 20);

    // Vies : sprite Rockford ou cercle de secours
    int iconSize = 24;
    int iconGap  = 28;
    int iy = (40 - iconSize) / 2;
    int ix = (int)(width * 0.72);
    imageMode(CORNER);
    for (int i = 0; i < 3; i++) {
      if (spritesJoueur != null) {
        if (i >= vies) tint(50, 50, 50, 120);
        image(spritesJoueur[0][0], ix + i * iconGap, iy, iconSize, iconSize);
        noTint();
      } else {
        fill(i < vies ? color(0, 255, 0) : color(60, 90, 60));
        noStroke();
        ellipseMode(CORNER);
        ellipse(ix + i * iconGap, iy, iconSize, iconSize);
      }
    }
    ellipseMode(CENTER);

    textAlign(RIGHT, CENTER);
    if (etat == ETAT_BONUS_TEMPS) {
      fill((frameCount / 8) % 2 == 0 ? color(255, 220, 0) : color(255, 160, 0));
      text("BONUS +" + (tempsRestant * 5), width - 8, 20);
    } else {
      if (tempsRestant <= 10) fill(255, 50, 50);
      else fill(255);
      text("Temps: " + tempsRestant, width - 8, 20);
    }

    fill(son.sonActif ? color(80, 255, 80) : color(200, 80, 80));
    textSize(8);
    textAlign(LEFT, BOTTOM);
    text(son.sonActif ? "[M] Son : ON" : "[M] Son : OFF", 8, height - 5);

    textAlign(RIGHT, BOTTOM);
    fill(120);
    textSize(8);
    text("[P] Pause  |  [ESC] Menu", width - 8, height - 5);

    if (etat == ETAT_PAUSE) {
      fill(0, 190);
      rect(0, 0, width, height);
      fill(255, 220, 0);
      textSize(32);
      textAlign(CENTER, CENTER);
      text("PAUSE", width/2, height/2 - 30);
      fill(200);
      textSize(12);
      text("Appuyez sur P pour continuer", width/2, height/2 + 35);
      fill(130);
      textSize(8);
      text("ESC = retour au menu", width/2, height/2 + 72);
    }

    if (etat == ETAT_SAISIE_PSEUDO) {
      fill(0, 200);
      rect(0, 0, width, height);
      fill(255, 215, 0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("NOUVEAU TOP 5 !", width/2, height/2 - 105);
      fill(255);
      textSize(12);
      text("Score : " + scoreGlobal, width/2, height/2 - 58);
      fill(200);
      textSize(12);
      text("Entrez votre pseudo :", width/2, height/2 - 12);
      fill(20);
      noStroke();
      rect(width/2 - 160, height/2 + 12, 320, 54, 10);
      fill(255, 215, 0);
      textSize(16);
      text(pseudoEnCours + (frameCount % 60 < 30 ? "|" : " "), width/2, height/2 + 39);
      fill(150);
      textSize(8);
      text("ENTRÉE pour valider   (max 10 caractères)", width/2, height/2 + 100);
    }

    if (etat == ETAT_GAMEOVER) {
      // Fond noir opaque
      fill(0, 220);
      noStroke();
      rect(0, 0, width, height);

      // Rochers qui tombent
      if (tileRocher != null) {
        imageMode(CORNER);
        int[] rocksX = { 60, 180, 340, 500, 650, 750 };
        for (int i = 0; i < rocksX.length; i++) {
          int ry = (int)((frameCount * (1.5 + i * 0.4) + i * 110) % (height + TAILLE_TUILE)) - TAILLE_TUILE;
          image(tileRocher[0], rocksX[i], ry);
        }
      }

      // Bordure murs haut/bas
      if (tileMur != null) {
        imageMode(CORNER);
        for (int x = 0; x < width; x += TAILLE_TUILE) {
          image(tileMur, x, 0);
          image(tileMur, x, height - TAILLE_TUILE);
        }
      }

      // Rockford écrasé (teinte rouge)
      if (spritesJoueur != null) {
        imageMode(CENTER);
        tint(255, 60, 60);
        image(spritesJoueur[0][0], width/2, 260, TAILLE_TUILE * 3, TAILLE_TUILE * 3);
        noTint();
        imageMode(CORNER);
      }

      // Titre GAME OVER
      textAlign(CENTER, CENTER);
      fill(80, 0, 0);
      textSize(32);
      text("GAME OVER", width/2 + 3, 163);
      fill(255, 40, 40);
      text("GAME OVER", width/2, 160);

      // Score
      fill(255);
      textSize(12);
      text("SCORE : " + scoreGlobal, width/2, 370);

      if (nouvelleEntreeTop5) {
        fill(255, 215, 0);
        textSize(12);
        text("NOUVEAU TOP 5 !", width/2, 410);
      }
      fill(120);
      textSize(8);
      text("MEILLEUR : " + (top5.scores[0] > 0 ? str(top5.scores[0]) : "---"), width/2, 440);

      // Appuyez sur une touche (clignotant)
      if ((frameCount / 25) % 2 == 0) {
        fill(255);
        textSize(8);
        text("PRESS ANY KEY", width/2, 500);
      }
      fill(80);
      textSize(8);
      text("ESC = MENU", width/2, 530);
    }

    if (etat == ETAT_VICTOIRE) {
      // Fond noir opaque
      fill(0, 220);
      noStroke();
      rect(0, 0, width, height);

      // Diamants qui tombent
      if (tileDiamant != null) {
        imageMode(CORNER);
        int[] diaX = { 50, 150, 270, 400, 530, 660, 760 };
        for (int i = 0; i < diaX.length; i++) {
          int dy = (int)((frameCount * (1.2 + i * 0.3) + i * 90) % (height + TAILLE_TUILE)) - TAILLE_TUILE;
          image(tileDiamant[(frameCount / 10 + i) % 4], diaX[i], dy);
        }
      }

      // Bordure murs haut/bas
      if (tileMur != null) {
        imageMode(CORNER);
        for (int x = 0; x < width; x += TAILLE_TUILE) {
          image(tileMur, x, 0);
          image(tileMur, x, height - TAILLE_TUILE);
        }
      }

      // Rockford qui célèbre (animation idle)
      if (spritesJoueur != null) {
        int frame = (frameCount / 8) % SPR_FRAMES_IDLE;
        imageMode(CENTER);
        tint(255, 220, 80);
        image(spritesJoueur[0][frame], width/2, 270, TAILLE_TUILE * 3, TAILLE_TUILE * 3);
        noTint();
        imageMode(CORNER);
      }

      // Titre VICTOIRE
      textAlign(CENTER, CENTER);
      fill(100, 70, 0);
      textSize(32);
      text("VICTOIRE!", width/2 + 3, 163);
      fill(255, 200, 0);
      text("VICTOIRE!", width/2, 160);

      // Score
      fill(255);
      textSize(12);
      text("SCORE : " + scoreGlobal, width/2, 380);

      if (nouvelleEntreeTop5) {
        fill(255, 215, 0);
        textSize(12);
        text("NOUVEAU TOP 5 !", width/2, 420);
      }
      fill(120);
      textSize(8);
      text("MEILLEUR : " + (top5.scores[0] > 0 ? str(top5.scores[0]) : "---"), width/2, 450);

      // Appuyez sur une touche (clignotant)
      if ((frameCount / 25) % 2 == 0) {
        fill(255);
        textSize(8);
        text("PRESS ANY KEY", width/2, 505);
      }
      fill(80);
      textSize(8);
      text("ESC = MENU", width/2, 535);
    }
  }
}
