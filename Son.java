import javax.sound.sampled.*;
import javax.sound.midi.*;

class Son {
  boolean sonActif = true;
  private processing.core.PApplet parent;
  private Sequencer sequencer       = null;
  private String    derniereMusique = null;

  Son(processing.core.PApplet parent) {
    this.parent = parent;
  }

  void collecterDiamant() { jouer(1100, 80,  "sin"); }
  void rocherTombe()       { jouer(80,   200, "carre"); }
  void joueurMort()        { jouer(140,  500, "carre"); }
  void sortieOuverte()     { jouer(660,  250, "sin"); }
  void victoire()          { jouer(880,  500, "sin"); }
  void menuSelect()        { jouer(440,  60,  "sin"); }

  void explosion()        { jouer(100,  600, "carre"); }

  void jingleGameOver() {
    if (!sonActif) return;
    arreterMusique();
    Thread t = new Thread(new Runnable() {
      public void run() {
        // Descente chromatique "wah wah wah waaaaah"
        int[][] seq = { {392,130},{370,130},{349,130},{330,130},{311,130},{294,130},{262,700} };
        for (int[] n : seq) lireEchantillons(creerEchantillons(n[0], n[1], "carre"));
      }
    });
    t.setDaemon(true);
    t.start();
  }

  void jingleVictoire() {
    if (!sonActif) return;
    arreterMusique();
    Thread t = new Thread(new Runnable() {
      public void run() {
        // Fanfare montante C5→E5→G5→C6
        int[][] seq = { {523,90},{659,90},{784,90},{1047,500} };
        for (int[] n : seq) lireEchantillons(creerEchantillons(n[0], n[1], "sin"));
      }
    });
    t.setDaemon(true);
    t.start();
  }

  void basculer() {
    sonActif = !sonActif;
    if (!sonActif) {
      arreterMusique();
    } else if (derniereMusique != null) {
      demarrerMusique(derniereMusique);
    }
  }

  // ─── Musique MIDI ────────────────────────────────────────────────────────

  void demarrerMusique(String fichier) {
    derniereMusique = fichier;
    if (!sonActif) return;
    arreterMusique();
    try {
      java.io.File f = new java.io.File(parent.dataPath(fichier));
      Sequence seq   = MidiSystem.getSequence(f);
      sequencer      = MidiSystem.getSequencer();
      sequencer.open();
      sequencer.setSequence(seq);
      sequencer.setLoopCount(Sequencer.LOOP_CONTINUOUSLY);
      sequencer.start();
    } catch (Exception e) { /* silencieux */ }
  }

  void arreterMusique() {
    if (sequencer != null && sequencer.isOpen()) {
      sequencer.stop();
      sequencer.close();
      sequencer = null;
    }
  }

  // ─── Sons synthétisés ────────────────────────────────────────────────────

  void jouer(final float freq, final int dureeMs, final String forme) {
    if (!sonActif) return;
    final byte[] buf = creerEchantillons(freq, dureeMs, forme);
    Thread t = new Thread(new Runnable() {
      public void run() { lireEchantillons(buf); }
    });
    t.setDaemon(true);
    t.start();
  }

  byte[] creerEchantillons(float freq, int dureeMs, String forme) {
    int sampleRate   = 44100;
    int nbSamples    = sampleRate * dureeMs / 1000;
    byte[] buf       = new byte[nbSamples];
    float TWO_PI_VAL = (float)(2 * Math.PI);
    for (int i = 0; i < nbSamples; i++) {
      float temps = (float) i / sampleRate;
      float env   = 1.0f - (float) i / nbSamples;
      float val;
      if (forme.equals("carre")) {
        val = ((float)Math.sin(TWO_PI_VAL * freq * temps) >= 0) ? 1.0f : -1.0f;
      } else {
        val = (float)Math.sin(TWO_PI_VAL * freq * temps);
      }
      buf[i] = (byte)(val * env * 80);
    }
    return buf;
  }

  void lireEchantillons(byte[] buf) {
    try {
      AudioFormat audioFormat = new AudioFormat(44100, 8, 1, true, false);
      SourceDataLine ligne    = AudioSystem.getSourceDataLine(audioFormat);
      ligne.open(audioFormat);
      ligne.start();
      ligne.write(buf, 0, buf.length);
      ligne.drain();
      ligne.close();
    }
    catch (Exception e) { /* silencieux */ }
  }
}
