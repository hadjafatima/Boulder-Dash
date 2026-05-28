class MoteurPhysique {
  GestionnaireJeu jeu;

  MoteurPhysique(GestionnaireJeu jeu) {
    this.jeu = jeu;
  }

  void actualiser(Niveau niveau) {
    int cols = niveau.cols;
    int rows = niveau.rows;
    // Empêche qu'un élément soit déplacé deux fois dans le même tick
    boolean[][] aBoge = new boolean[cols][rows];

    // Parcours de bas en haut pour que la gravité cascade correctement en une seule passe
    for (int y = rows - 2; y >= 0; y--) {
      for (int x = 1; x < cols - 1; x++) {
        if (aBoge[x][y]) continue;

        Element e = niveau.grille[x][y];
        if (!(e instanceof Rocher) && !(e instanceof Diamant)) continue;

        boolean enChuteActuellement = false;
        if (e instanceof Rocher)  enChuteActuellement = ((Rocher)e).enChute;
        if (e instanceof Diamant) enChuteActuellement = ((Diamant)e).enChute;

        Element enDessous = niveau.grille[x][y + 1];

        if (enDessous == null) {
          // Case vide en dessous : chute libre
          niveau.deplacerElement(e, x, y + 1);
          aBoge[x][y + 1] = true;
          setChute(e, true);

        } else if (enDessous instanceof Joueur) {
          Joueur jEcrase = (Joueur) enDessous;
          if (enChuteActuellement && millis() >= jEcrase.bloqueJusquA) {
            jEcrase.vivant = false;
            niveau.declencherExplosion(x, y + 1);
            aBoge[x][y]     = true;
            aBoge[x][y + 1] = true;
          } else {
            setChute(e, false);
          }

        } else if (enDessous instanceof Ennemi) {
          if (enChuteActuellement) {
            boolean papillon = enDessous instanceof Papillon;
            niveau.declencherExplosion(x, y + 1, papillon);
            son.rocherTombe();
            jeu.ajouterBonus(papillon ? 250 : 100);
            aBoge[x][y]     = true;
            aBoge[x][y + 1] = true;
          } else {
            setChute(e, false);
          }

        } else if (enDessous instanceof MurMagique) {
          // Un rocher en chute traversant un mur magique devient un diamant sous le mur
          if (enChuteActuellement && e instanceof Rocher) {
            int bx = x, by = y + 2;
            Element sousMur = by < rows ? niveau.getElement(bx, by) : new Mur(bx, by);
            if (sousMur == null || sousMur instanceof Terre) {
              niveau.grille[x][y] = null;
              niveau.grille[bx][by] = null;
              Diamant d = new Diamant(bx, by);
              d.enChute = true;
              niveau.grille[bx][by] = d;
              aBoge[bx][by] = true;
              son.rocherTombe();
            }
            setChute(e, false);
          } else {
            setChute(e, false);
          }

        } else if (enDessous instanceof Rocher || enDessous instanceof Diamant || enDessous instanceof Mur) {
          setChute(e, false);
          // Glissement latéral : si posé sur un rocher ou diamant arrondi, glisse d'un côté
          if (enDessous instanceof Rocher || enDessous instanceof Diamant) {
            if (niveau.getElement(x-1, y) == null && niveau.getElement(x-1, y+1) == null) {
              niveau.deplacerElement(e, x-1, y);
              aBoge[x-1][y] = true;
            } else if (niveau.getElement(x+1, y) == null && niveau.getElement(x+1, y+1) == null) {
              niveau.deplacerElement(e, x+1, y);
              aBoge[x+1][y] = true;
            }
          }

        } else {
          setChute(e, false);
        }
      }
    }

    for (int i = niveau.ennemis.size() - 1; i >= 0; i--) {
      niveau.ennemis.get(i).actualiser(niveau);
    }

    gererAmoeba(niveau);

    // Nettoyer les explosions terminées
    for (int i = niveau.explosions.size() - 1; i >= 0; i--) {
      Explosion exp = niveau.explosions.get(i);
      if (exp.termine()) {
        if (exp.x >= 0 && exp.x < niveau.cols && exp.y >= 0 && exp.y < niveau.rows) {
          if (niveau.grille[exp.x][exp.y] == exp) {
            niveau.grille[exp.x][exp.y] = exp.laisseDiamant
              ? new Diamant(exp.x, exp.y)
              : null;
          }
        }
        niveau.explosions.remove(i);
      }
    }
  }

  void gererAmoeba(Niveau niveau) {
    if (niveau.amoebas.isEmpty()) return;

    int total = niveau.amoebas.size();
    int max   = (niveau.cols * niveau.rows) / 8;

    // Trop grande → rochers
    if (total >= max) {
      transformerAmoeba(niveau, false);
      son.rocherTombe();
      return;
    }

    boolean peutGrandir = false;
    ArrayList<Amoeba> nouvelles = new ArrayList<Amoeba>();
    int[][] dirs = {{0,-1},{1,0},{0,1},{-1,0}};

    for (Amoeba a : new ArrayList<Amoeba>(niveau.amoebas)) {
      boolean etendue = false;
      for (int[] d : dirs) {
        int nx = a.x + d[0];
        int ny = a.y + d[1];
        if (nx < 0 || nx >= niveau.cols || ny < 0 || ny >= niveau.rows) continue;
        Element voisin = niveau.grille[nx][ny];
        if (voisin == null || voisin instanceof Terre) {
          peutGrandir = true;
          if (!etendue && random(1) < 0.25) {
            Amoeba nouv = new Amoeba(nx, ny);
            niveau.grille[nx][ny] = nouv;
            nouvelles.add(nouv);
            etendue = true;
          }
        }
      }
    }
    niveau.amoebas.addAll(nouvelles);

    // Enfermée → diamants
    if (!peutGrandir) {
      transformerAmoeba(niveau, true);
      son.sortieOuverte();
      return;
    }

    // Tue le joueur si adjacent ou sur la même case
    tuerJoueurParAmoeba(niveau);
  }

  void transformerAmoeba(Niveau niveau, boolean enDiamants) {
    for (Amoeba a : niveau.amoebas) {
      if (a.x >= 0 && a.x < niveau.cols && a.y >= 0 && a.y < niveau.rows) {
        if (niveau.grille[a.x][a.y] == a) {
          niveau.grille[a.x][a.y] = enDiamants ? new Diamant(a.x, a.y) : new Rocher(a.x, a.y);
        }
      }
    }
    niveau.amoebas.clear();
  }

  void tuerJoueurParAmoeba(Niveau niveau) {
    int[][] dirs = {{0,0},{0,-1},{1,0},{0,1},{-1,0}};
    for (Amoeba a : niveau.amoebas) {
      for (Joueur j : new Joueur[]{ niveau.joueur, niveau.joueur2 }) {
        if (j == null || !j.vivant || millis() < j.bloqueJusquA) continue;
        for (int[] d : dirs) {
          if (j.x == a.x + d[0] && j.y == a.y + d[1]) {
            j.vivant = false;
            niveau.declencherExplosion(j.x, j.y);
            return;
          }
        }
      }
    }
  }

  void setChute(Element e, boolean chute) {
    if (e instanceof Rocher)  ((Rocher)e).enChute  = chute;
    if (e instanceof Diamant) ((Diamant)e).enChute = chute;
  }
}
