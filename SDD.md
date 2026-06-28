# Software Design Dokument – Weltraum-Sim (Prototyp)

**Projekt:** StarVoyage_Prototype (Godot 4.6.3 stable mono)
**Repository:** github.com/CptHectorX/StarVoyage_Prototype (public, open source)
**Lokaler Pfad:** D:\Godot_Projects\StarVoyage_Prototype
**Referenz-Spiel:** Star Valor
**Status:** Prototyp – ein Sektor
**Letzte Aktualisierung:** 28.06.2026

---

## 1. Vision

Eine Top-Down Weltraum-Sim mit Newtonscher Physik. Der Spieler steuert ein 3D-Raumschiff
auf einer flachen Spielebene. Die Welt ist im Kern 2D (Gameplay auf einer Ebene), die
Objekte darin (Schiff, Asteroiden) sind 3D-Modelle, damit sie sich drehen lassen und gut
aussehen. Vorbild für Look & Feel ist **Star Valor**.

---

## 2. Steuerung

| Eingabe | Aktion |
|---------|--------|
| **Maus** | Schiff dreht sich Richtung Mauszeiger (Aim) |
| **W** | Schub nach vorne (in Blickrichtung) |
| **S** | Schub nach hinten (bremsen / rückwärts) |
| **A** | Strafe links (seitwärts gleiten) |
| **D** | Strafe rechts (seitwärts gleiten) |
| **X** | Auto-Stop: Schiff bremst automatisch auf Geschwindigkeit 0 |

### Physik-Modell: Pure Newton

- Das Schiff behält sein Momentum. Lässt man die Tasten los, gleitet es **unendlich** weiter
  in die aktuelle Richtung (kein automatisches Abbremsen).
- Bremsen erfolgt aktiv: drehen + Gegenschub, oder über die X-Taste.
- Gute Triebwerke = schnelles Bremsen (Schub-Wert bestimmt, wie schnell man die
  Geschwindigkeit ändern kann).

### Technische Umsetzung Player

- **Player = `Node3D` mit selbst gerechnetem Velocity-Vektor.** Newton-Physik
  (Momentum, Schub, Auto-Stop) wird im Script selbst berechnet – volle Kontrolle,
  einfach nachvollziehbar. Bewusst **kein** `CharacterBody3D` (für laufende Figuren
  gedacht) und **kein** `RigidBody3D` (Engine würde gegen präzisen Auto-Stop/Maus-Aim
  arbeiten) für den Prototyp.
- **⚠ MUSS später ergänzt werden (auf jeden Fall):** Kollisionen und Abpraller
  (Schiff ↔ Asteroiden, Schiff ↔ Wand) – via `Area3D`/`CharacterBody3D` oder
  Umstieg auf Physik-Körper. Bewusst nach hinten geschoben, aber fest eingeplant.

### Auto-Stop (X-Taste) – Verhalten

- Ein Druck auf **X** aktiviert den Auto-Stop (Taste muss **nicht** gehalten werden).
- Das System kehrt die Geschwindigkeit um und bremst mit **derselben Beschleunigung**
  wie normaler Schub, bis die Geschwindigkeit **exakt 0** erreicht – dann stoppt es
  automatisch (kein Überschießen ins Gegenteil).
- **W (oder anderer Schub-Input) während des Auto-Stops bricht ihn sofort ab** – der
  Spieler übernimmt wieder die Kontrolle (fühlt sich responsiver an).

---

## 3. Kamera

- **Top-Down-Ansicht** von oben auf die Spielebene.
- **Zoombar:** rein- und rauszoomen (z. B. Mausrad).
- Folgt dem Schiff.
- *(Offen / später zu kalibrieren: Zoom-Grenzen min/max, ob die Kamera dem Schiff
  starr folgt oder leicht nachzieht / "lerp".)*

---

## 4. Spielwelt-Architektur

### Grundprinzip: 2D-Ebene mit 3D-Objekten

- Gameplay findet auf einer flachen Ebene statt (Top-Down, wie Star Valor).
- Die Objekte darauf (Schiff, Asteroiden) sind echte 3D-Modelle, die sich drehen können.
- **Kein** echtes Hoch-/Runter-Fliegen – die Bewegung bleibt auf der Ebene.
- **Die Sektor-Ebene ist KEIN sichtbares Mesh.** Sie ist nur eine logische Höhe (XZ-Ebene
  bei y=0), auf der alles liegt. Der Hintergrund wird über eine **Skybox**
  (`WorldEnvironment` + Sky-Material: Sterne/Nebel/Weltraum) realisiert, nicht über eine
  gemalte Hintergrund-Plane. Wirkt nie "flach" und geht in alle Richtungen.

### Sektoren

- Die Welt besteht aus **Sektoren**. Für den Prototyp gibt es **nur einen Sektor**.
- Die Architektur soll aber von Anfang an **mehrere Sektoren** im Hinterkopf behalten.

> **⚠ Zu testen / offene Architektur-Entscheidung:**
> Ob ein **nahtloses 2D-Universum** (seamless, ohne Ladegrenzen) möglich ist, oder ob es
> **Übergänge** zwischen Sektoren braucht (Laden/Entladen). Diese Frage muss **früh**
> getestet werden, bevor zu viel auf einer Annahme aufgebaut wird.

### Sektor-Größe (Prototyp)

- Grobe Zielvorgabe: in jede Richtung ca. **10 Sekunden Flugzeit** bis zum Rand.
- **Hinweis:** Bei Newton-Physik hängt die tatsächliche Distanz von der
  Maximalgeschwindigkeit ab → muss später **kalibriert** werden.

### Sektor-Grenze: "Wand des Universums"

- Eine **sichtbare, rot-transparente Wand** am Sektorrand (bewusst als Gag – die
  "Grenze des Universums").
- Das Schiff wird an der Wand **abrupt gestoppt** (harte Kollision).

---

## 5. Visuelle Elemente

### Raumstaub (Partikel)

- Partikel-System, das die Bewegung sichtbar macht (man "fühlt", dass man fliegt).
- Bewegt sich relativ zum Schiff.

### Asteroiden (zuletzt umsetzen)

- 3D-Objekte, die im Sektor platziert werden.
- Können sich drehen (Vorteil der 3D-Modelle auf der 2D-Ebene).
- Assets werden vom Nutzer geliefert.

---

## 6. Aktueller Stand (Was schon existiert)

Frischer Neustart als `StarVoyage_Prototype` (das alte `ShipDemo` ist verworfen):

- Leeres Godot-Projekt angelegt unter `D:\Godot_Projects\StarVoyage_Prototype`.
- Assets importiert:
  - Schiff: `ship_002.glb` (~9.842 Faces / 11.191 Verts – game-ready)
  - Asteroid: `asteroid_001.glb`
- Git-Repo initialisiert und zu GitHub gepusht (public):
  `github.com/CptHectorX/StarVoyage_Prototype`
- Godots Standard-`.gitignore` schließt `.godot/`-Cache aus.
- **Konvention:** Code, Commit-Messages, Variablen und Kommentare auf **Englisch**.

### Szenen-Struktur (`main.tscn`)

Saubere Trennung von Logik und Mesh (bewusst so aufgebaut):

```
Main (Node3D)              ← Welt-Wurzel / Container
├── Player (Node3D)        ← reine Logik + Steuerung (player.gd)
│   ├── ShipModel (glb)    ← nur Mesh; Rotation Y = -180 (Nase auf -Z ausgerichtet)
│   └── Camera3D           ← Top-Down: Pos (0,5,0), Rot X -90
├── asteroid_001 … 010     ← Test-Asteroiden zum Sichtbarmachen der Bewegung
```

- **Wichtig gelernt:** Das Script gehört an `Player` (Logik), nicht ans `ShipModel`.
  Die Mesh-Ausrichtung wird am `ShipModel` korrigiert (Rot Y -180), damit `player.gd`
  mit der sauberen Konvention "vorne = -Z" arbeiten kann.

### Erledigt (Steuerung Grundgerüst)

- Input Map: `thrust_forward` (W), `thrust_back` (S), `strafe_left` (A),
  `strafe_right` (D), `auto_stop` (X).
- `player.gd` mit Newton-Physik: Velocity-Vektor, Schub addiert Beschleunigung,
  `max_speed`-Cap, Gleiten ohne automatisches Abbremsen. Getestet – W/S/A/D + Gleiten
  funktionieren.
- **Noch offen in Schritt 1:** Maus-Drehung (Aim) und Auto-Stop (X-Logik).

---

## 7. Bekannte technische Risiken / offene Punkte

1. **Performance des Schiff-Modells:** ~940.000 Primitive, **1511 Objekte/Sub-Meshes**,
   ~208 MB Video-RAM. Im Test nur **24 FPS** mit nur dem Schiff in der Szene.
   - Reduzierung über Blender-Decimate scheiterte (Modell zu schwer, Blender hängt).
   - **Lösungsidee:** TripoSplat erneut mit niedrigerer Auflösung exportieren (< 352).
   - **Muss vor Asteroiden-Vervielfachung gelöst werden** – sonst summiert sich die Last.
2. **Seamless vs. Sektorübergänge** (siehe 4) – früh testen.
3. **Sektor-Größe / Geschwindigkeit** muss kalibriert werden.
4. **Große Asset-Dateien im Repo:** `asteroid_001.glb` ist 69 MB – über GitHubs
   empfohlenem Maximum (50 MB), aber unter der harten Grenze (100 MB). Push läuft,
   ist aber eine Warnung. Bewusst für den Prototyp so belassen, weil die finalen Meshes
   ohnehin leichter werden. Falls Assets doch groß bleiben: Git LFS einrichten.

---

## 8. Umsetzungsreihenfolge (Vorschlag)

1. Steuerung umbauen: Newton-Physik + Maus-Aim + WASD + Auto-Stop (X).
2. Kamera: Top-Down + Zoom.
3. Raumstaub-Partikel.
4. Sektor-Grenze (rote Wand).
5. Asteroiden (Assets vom Nutzer).
6. Performance final prüfen.

---

## 9. Fortschritt / Status-Log

> **Workflow-Abmachung:** Dieses Dokument ist die "Single Source of Truth". Am Ende jedes
> abgeschlossenen Schritts wird dieser Abschnitt aktualisiert und die neue Version
> heruntergeladen/abgelegt. Bei neuer Session oder Kontextverlust: SDD + aktuelle Scripts
> hochladen → sofort wieder auf Stand. Für den Projektstand gelten die Dateien, nicht das
> Gedächtnis des Assistenten.

### Status-Übersicht

| # | Schritt | Status |
|---|---------|--------|
| – | Frischer Projekt-Neustart `StarVoyage_Prototype` | ✅ erledigt |
| – | Assets importiert (Schiff + Asteroid) | ✅ erledigt |
| – | Git-Repo + GitHub-Push (public) | ✅ erledigt |
| – | Saubere Szenen-Struktur (Player/ShipModel/Camera) | ✅ erledigt |
| 1a | Steuerung: Newton + WASD-Schub | ✅ erledigt |
| 1b | Steuerung: Maus-Aim + Auto-Stop (X) | ⬜ offen (nächster Schritt) |
| 2 | Kamera: Top-Down + Zoom | ⬜ offen |
| 3 | Raumstaub-Partikel | ⬜ offen |
| 4 | Sektor-Grenze (rote Wand) | ⬜ offen |
| 5 | Asteroiden | ⬜ offen |
| 6 | Performance final prüfen | ⬜ offen |

### Verlauf (neueste zuerst)

- **28.06.2026** – Steuerung Grundgerüst läuft: Input Map (WASD+X) definiert, `player.gd`
  mit Newton-Physik am `Player`-Node. Saubere Node-Struktur aufgebaut (Player=Logik,
  ShipModel=Mesh mit Rot Y -180, Camera als Geschwister). W/S/A/D + Gleiten getestet und ok.
  Schiff fliegt korrekt Richtung Nase. Skybox statt sichtbarer Plane beschlossen.
- **28.06.2026** – Neues, leichtes Schiff-Mesh (~9.842 Faces) ersetzt das alte schwere
  (~940k). Performance-Risiko damit an der Wurzel gelöst.
- **28.06.2026** – Frischer Neustart `StarVoyage_Prototype`, Assets importiert,
  Git-Repo public zu GitHub gepusht, SDD ins Repo aufgenommen.
- **28.06.2026** – SDD erstellt und finalisiert.

### Notizen für die nächste Session

- Steuerungs-Script kommt auf den Schiff-Node (`extends Node3D`).
- Asset-Dateinamen: Schiff `ship_002.glb`, Asteroid `asteroid_001.glb`.
- Godot-Version: 4.6.3 stable mono.
- Repo: `github.com/CptHectorX/StarVoyage_Prototype`, lokaler Pfad
  `D:\Godot_Projects\StarVoyage_Prototype`.
- Code/Commits/Variablen auf Englisch.
- Offen vor Schritt 5: Performance-Frage (TripoSplat ggf. niedrigere Auflösung).
