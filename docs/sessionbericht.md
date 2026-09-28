# Sessionbericht: KI-gestützter OpenSCAD-Workflow

Auswertung aller Arbeitssitzungen vom 01.09. bis 28.09.2026

## 1. Zweck und Datengrundlage

Dieser Bericht dokumentiert, wie der Workflow in der Praxis entstanden ist
und sich verändert hat: Grundgedanken, Änderungen am Regelwerk,
entstandene Modelle, aufgetretene Probleme und deren Behebung.

**Quelle:** die Gesprächsprotokolle von Claude Code für dieses Projekt,
12 Sitzungen mit zusammen rund 85 Nutzereingaben. Claude Code legt sie
automatisch als JSONL-Dateien ab. Ergänzt wurden sie um die Git-Historie
(17 Commits), die QA-Berichte in `qa/` und den aktuellen Stand der
Dateien in `context/`, `rules/` und `skills/`.

**Einschränkungen:**
- Zeitangaben sind Zeitstempel aus dem Chat. Druckzeiten und Arbeit
  außerhalb des Chats (Slicer, Nachmessen, Montage) sind nicht enthalten.
- Druckergebnisse sind Einschätzungen des Nutzers („flutscht“, „zufrieden“).
  Messwerte mit dem Messschieber liegen fast nirgends vor. Das ist in
  `context/tolerances.md` jeweils vermerkt.
- Zum Lampenschirm gibt es zwei Protokolldateien. Die zweite setzt die
  erste fort und enthält sie vollständig, sie zählen als eine Sitzung.
- Diese Auswertung selbst (28.09.) ist nicht mitgezählt.

## 2. Grundgedanken

Das Ziel des Projekts ist, passgenaue Bauteile für den 3D-Druck schneller
herzustellen als mit klassischem CAD, indem eine KI den OpenSCAD-Code
schreibt. Von Anfang an galten dafür sechs Leitideen. Sie wurden im Laufe
des Monats verschärft, aber nicht aufgegeben.

1. **Trennung von Entwurf und Prüfung.** Ein `design-agent` führt das
   Gespräch und modelliert, ein `qa-agent` prüft nur. Begründung: Wer etwas
   gebaut hat, beurteilt es zu wohlwollend. Am Anfang war die Trennung nur
   eine Anweisung. Seit 27.09. läuft die QA technisch erzwungen in einem
   frischen Kontext und ohne Schreibwerkzeug.
2. **Regeln statt implizitem Modellverhalten.** Was die KI tun soll, steht
   in `rules/` und `skills/` als Datei, nicht nur im Prompt. Dadurch ist es
   nachvollziehbar und lässt sich verbessern.
3. **Kontext zuerst.** Drucker, Toleranzen, Material und bekannte
   Fehlerbilder stehen in `context/` und müssen vor jeder Modellierung
   gelesen werden. Werte aus echten Drucken fließen dorthin zurück.
4. **Jede Iteration ist eine neue Datei** (`objekt_001.scad`, `_002` …).
   Nichts wird überschrieben, der Entwurfsprozess bleibt vollständig
   sichtbar.
5. **Der Mensch entscheidet.** Kein Modell wird automatisch als fertig
   übernommen. Seit 27.09. wird auch nicht mehr ohne ausdrückliche
   Freigabe für den Druck exportiert.
6. **Anbieterunabhängigkeit.** Seit 27.09. liegt alles Inhaltliche in
   neutralen Dateien (`AGENTS.md`, `prompts/`). Der Claude-spezifische Teil
   ist ein austauschbarer Adapter.

## 3. Chronologie

| Phase | Datum | Inhalt | Ergebnis für den Workflow |
|---|---|---|---|
| 0 Einrichtung | 01.09. | Ordnerstruktur, Git-Repo, VS-Code-Erweiterungen, OpenSCAD installiert, erster Testwürfel | Grundgerüst mit 2 Agents, 7 Skills, 5 Rules (zunächst reine Konzeptdateien) |
| 1 Erste Modelle ohne Kontext | 01.–02.09. | Blumentopf, Lampenschirm (13 Versionen) | Rule `verify-parametric-geometry`, Techniknotizen in `modeling` |
| 2 Kontext befüllt | 02.09. | Kalibrierdruck (MakerWorld-Testblock) in `printer.md` und `tolerances.md` übertragen | erste belastbare Toleranzwerte |
| 3 Erster Druck-Feedback-Zyklus | 11.–12.09. | Kartenboxen (Flip 7, UNO), Vorlage, README und SETUP | Toleranz für lange Gleitpassungen aus echten Drucken, erste Vorlage |
| 4 Tragende Teile | 16.–18.09. | Pin-Magnetsockel, Laptop-/Tablet-Ständer | Rule `load-case-check`, QA soll als Subagent laufen, Rechenannahmen in `materials.md` |
| 5 Mehrteiliges Objekt, neue Materialien | 18.–19.09. | Brillenetui (PETG + TPU, Scharnier, Fraktal-/Kristall-Design) | Kollisions-Sweep über den Öffnungswinkel, Scharniertest |
| 6 Überarbeitung nach Uni-Feedback | 27.09. | Pre-Print-Gate G1–G5, Prüfskript, Fehlerkatalog, Hook, Befehle, Anbieterunabhängigkeit | heutiger Prozess |
| 7 Erstes Objekt im neuen Prozess | 27.–28.09. | PocketBook-Ladeständer (3 Versionen, 3 QA-Läufe) | Nachweis, dass der Prozess durchgängig funktioniert |

## 4. Wie sich der Workflow verändert hat

Fast jede Änderung am Regelwerk ist aus einem konkreten Fehler entstanden.
Die Tabelle nennt jeweils den Anlass.

| Datum | Änderung | Anlass |
|---|---|---|
| 01.09. | Alle Agent-, Skill- und Rule-Dateien auf Englisch | Vorgabe des Nutzers |
| 01.09. | OpenSCAD 2021.01 installiert und in den `PATH` aufgenommen | Die Vorschau-Erweiterung in VS Code tat nichts, weil sie die OpenSCAD-CLI braucht |
| 01.09. | Neue Rule `verify-parametric-geometry`: organische Konturen per vollständigem Parameter-Sweep prüfen, Manifold-Prüfung über die CLI-Statistik (`Simple`, `Volumes`) statt über die Vorschau | Drei echte Geometriefehler und eine Vorschau-Täuschung beim Lampenschirm |
| 01.09. | `modeling`: kein `offset()` auf welligen Konturen, Hohlraum als Ring statt als gefüllte Fläche, Schnitte immer überdimensioniert, `render()` um verschachtelte Boolesche Operationen | ebenso |
| 02.09. | `verify-parametric-geometry` ergänzt: auch den Sprung zwischen benachbarten Stützstellen prüfen und unverhältnismäßige Spitzen suchen | Lampenschirm 012 und 013 |
| 02.09. | `context/` befüllt: Drucker Anycubic Kobra S1 (250 × 250 × 250 mm, 0,4-mm-Düse, PEI), Kalibrierergebnisse, Toleranztabelle | Vorher war `context/` leer, die QA konnte nichts prüfen (Blumentopf) |
| 02.09. | Farbvergleiche einzelner Spulen aus `printer.md` und `materials.md` entfernt | Vorgabe: Der Drucker-Kontext soll nicht von einzelnen Filamenten handeln |
| 11.09. | `tolerances.md`: eigener Abschnitt für lange Gleitpassungen, Werte aus echten Drucken | Kartenbox mit 0,25 mm zu stramm |
| 12.09. | `SETUP.md` neu, README überarbeitet, erste Vorlage in `scad/templates/` | Wiederverwendung der erprobten Kartenbox |
| 18.09. | Neue Rule `load-case-check`: Bruch, Kippen und Rutschen mit der **ungünstigsten** Lastkombination rechnen, Last quer zu den Schichten mit der Schichthaftung, Rechnung als `echo()` in die Datei | Laptop-Ständer: Kippwinkel war mit symmetrischer Last geschönt (12,9° statt 8,0°) |
| 18.09. | `geometry-check`: Restbreiten nach Fasen per `assert` prüfen | Laptop-Ständer 001: Rippe lief oben auf eine 0-mm-Schneide aus |
| 18.09. | `modeling`: `render_part`-Schalter in jede Datei, Querschnitte messen statt nur ansehen | Prüfskripte konnten die Datei nicht einbinden |
| 18.09. | `materials.md`: Rechenannahmen für PLA, ausdrücklich als *nicht gemessen* markiert | Grundlage für Lastfallrechnungen |
| 18.09. | `design-agent`/`qa-agent`: QA soll als eigener Subagent laufen und nur Datei und Anforderungen bekommen | Rollentrennung war bis dahin nur auf dem Papier |
| 18.09. | `design-conversation`: Angaben auf Plausibilität prüfen, bei tragenden Teilen Last erfragen | „iPad 15 cm dick“ |
| 27.09. | **Neue Rule `pre-print-gate`** mit den Stufen G1 Technik, G2 Maße, G3 blinde Sichtprüfung, G4 Druckbarkeit, G5 Freigabe durch den Nutzer | Uni-Feedback: keine konkrete Prüfstrategie gegen „fehlerfrei rendernde, aber unsinnige Modelle“ |
| 27.09. | `tools/check.py` (576 Zeilen): Kompilieren, Manifold, `Volumes` je Teil, Kollisionen, Bauraum, Lage auf dem Bett, Ansichten, gemessene Querschnitte | G1 soll deterministisch sein, nicht von der KI abhängen |
| 27.09. | Neuer Skill `visual-review` (G3): Die QA beschreibt die Bilder, **bevor** sie die Anforderungen liest | Kern des Uni-Feedbacks |
| 27.09. | `design-conversation` endet mit einer Anforderungstabelle mit Sollwert, Quelle (gemessen, nominal, angenommen) und Prüfmethode | G2 braucht etwas, wogegen gemessen wird |
| 27.09. | `context/failure-modes.md`: Katalog mit heute 18 Fehlerbildern, die fehlerfrei rendern, aber falsch sind, jeweils mit der Stufe, die sie findet | Erfahrungen der Vormonate systematisch nutzbar machen |
| 27.09. | Berichte `qa/<datei>/report.md` nach Vorlage, Skill `print-feedback` | Nachweis pro Version, Abgleich Vorhersage und Druck |
| 27.09. | Hook: nach jedem Schreiben einer `.scad`-Datei eine Schnellprüfung (~1 s) | OpenSCAD 2021.01 meldet bei fehlgeschlagenem `assert()` trotzdem Exit-Code 0 |
| 27.09. | QA als Claude-Code-Subagent **ohne Edit/Write-Werkzeug** | Trennung technisch erzwingen |
| 27.09. | Befehle `/neues-objekt` und `/druckfeedback` | Der Prozess soll sich nicht versehentlich umgehen lassen |
| 27.09. | `AGENTS.md` als neutrale Projektanweisung, `CLAUDE.md` und `.claude/` nur noch als Adapter, Migrationsweg in der README | Anforderung Anbieterunabhängigkeit |
| 27.09. | `.gitignore`: nur der Bericht wird versioniert, Bilder und Schnitte sind lokal und reproduzierbar | Repo schlank halten |
| 27.09. | F17 (Montierbarkeit) entschärft: Die QA meldet die Eindringtiefe statt jedes Überstands | Fehlalarm beim Brillenetui |
| 28.09. | F7 (koplanare Flächen) um einen Fall ergänzt, bei dem die Schnitte still leer blieben | PocketBook-Ständer 001 |

## 5. Die Modelle

### Übersicht

| Objekt | Versionen | Material | Gedruckt | Status |
|---|---|---|---|---|
| Blumentopf | 2 | – | nein | verworfen (Drafts am 02.09. gelöscht) |
| Lampenschirm | 13 | PLA | ja, `_013`: „passt gut“ | `_013` in `finished/`, `_010` in `trash/` |
| Kartenbox Flip 7 | 2 | PLA | ja, beide | `_002` in `finished/` |
| Kartenbox UNO | 2 | PLA | ja, `_002` | `_002` in `finished/` |
| Kartenbox-Vorlage | 1 | PLA | über UNO erprobt | `scad/templates/` |
| Pin-Magnetsockel | 2 | PLA | ja, beide | `_002` in `finished/` |
| Laptop-/Tablet-Ständer | 3 | PLA | ja, `_003`: „steht gut“ | `_003` in `finished/` |
| Brillenetui | 4 | PETG + TPU | Schale in PETG | `_004` in `draft/`, TPU offen |
| PocketBook-Ladeständer | 3 | PLA | Passtest ja, ganzer Ständer im Druck (28.09.) | `_003` in `draft/` |

### 5.1 Blumentopf (01.09.)

- **Anforderung:** Topf für eine Pflanze mit 80 mm Ø und 60 mm Höhe.
- **Verlauf:** `_001` konisch, 3,2 mm Wand. `_002` mit Hexagon-Gravur in
  halber Wandstärke.
- **Problem:** Auf die Frage „ist das so druckbar?“ konnte die QA nicht
  antworten, weil `context/` noch leer war. Der design-agent verweigerte
  bewusst ein eigenes Urteil.
- **Bedeutung:** Das zeigte früh, dass die Rollentrennung ohne Kontextdaten
  wertlos ist. Unmittelbare Folge war das Befüllen von `context/`.

### 5.2 Lampenschirm (01.–02.09., 13 Versionen)

- **Anforderung:** Schirm aus weißem PLA für eine Stehlampe, 180 mm hoch,
  2 mm Wand, oben und unten offen. Ein Klemmkragen soll ihn seitlich an
  eine 20-mm-Stange klemmen, im unteren Drittel mit Öffnung zur Fassung.
- **Verlauf und Fehler:**

| Version | Änderung | Problem | Gefunden von |
|---|---|---|---|
| 001 | D-Querschnitt, C-Klemmring | Rückwand lief mitten durch die Klemme | Nutzer |
| 002 | Bohrung durch die ganze Baugruppe, Schlitz zur Fassung | „sieht kaputt aus“: nur ein Anzeigefehler der Schnellvorschau (F5), die Geometrie war korrekt. Behoben mit `render()` | Nutzer, von der KI als Vorschaueffekt erkannt |
| 003 | organische Fourier-Kontur statt D-Form | Klemme hing lose im Schirm (`Volumes: 3`), Ursache `offset()` auf welliger Kontur | Nutzer |
| 004 | massiver Keil als Verbindung | Montagespalt schnitt nicht bis außen durch, man konnte die Stange nicht einclipsen | Nutzer |
| 005 | Spalt mit großem Schnittradius | Verbindung „übel hässlich und wulstig“ | Nutzer |
| 006–007 | schlanke Stege, dann Kontur zieht sich selbst um die Klemme | Auswüchse, Verbindung rechts weg | Nutzer |
| 008–010 | flachere Grundform, kleinere Welle | Zwei echte Fehler: Sicherheitsradius `min_r` lag unter dem Klemmradius, Hohlraum war eine gefüllte Fläche statt eines Rings (Klemme an der Fassungsseite hohl) | KI, per Sweep über 1440 Winkel |
| 011 | welliger | Auswüchse an der Klemme | Nutzer |
| 012 | weiche statt harter Begrenzung | Radius sprang an der Zonengrenze um 8 mm auf 0,5° | KI, per Sprungprüfung |
| 013 | Wellenamplitude proportional zur lokalen Konturgröße | keine Auswüchse mehr, `Volumes: 2` | Nutzer: „gefällt mir sehr gut“ |

- **Auswertung:** Neun Korrekturen gingen auf den Blick des Nutzers in die
  Vorschau zurück. Darunter sind ein reiner Anzeigefehler (002) und zwei
  optische Wünsche (005, 006). Von sich aus fand die KI drei Fehler (die
  Schlaufe in 008, zwei Fehler in 010). Vor jeder Nutzermeldung hatte die
  KI „kompiliert, manifold“ gemeldet. Das ist genau die Fehlerklasse aus
  dem späteren Uni-Feedback und der Grund für die blinde Sichtprüfung G3.
- **Druck:** `_013` in PLA, laut Nutzer „passt gut“. Damit ist auch der
  Klemmring bestätigt: Innendurchmesser 19,2 mm auf der 20-mm-Stange, also
  0,8 mm Untermaß als Vorspannung, 3 mm Wand.
- **Dauer:** ~1,5 h am 01.09. und ~20 min am 02.09.

### 5.3 Kartenboxen Flip 7 und UNO, Vorlage (11.–12.09.)

- **Anforderung:** Box für einen Stapel von 80 × 54 × 36 mm (Flip 7),
  rucksacktauglich, PLA, vorhandene Magnete 6 × 2 mm.
- **Gespräch:** Die KI bemerkte einen Widerspruch („Karten quadratisch“,
  aber 80 × 54 mm) und schlug 5 Verschlussvarianten mit Vor- und Nachteilen
  vor. Gewählt: Schuber (Schublade in Hülle) mit Magneten.
- **Flip 7 `_001`:** 0,25 mm Gleitspiel pro Seite, der Wert aus dem
  Toleranztest für bewegliche Teile. **Im Druck zu stramm:** Die Schublade
  ging hinein, aber kaum wieder heraus.
- **Flip 7 `_002`:** Nur die Hülle geändert: 0,5 mm Spiel, Griffmulden,
  Passungstest mit drei Ringen (0,4 / 0,5 / 0,6 mm). Dass die Schublade
  unverändert blieb und nicht neu gedruckt werden musste, prüfte die KI
  durch Vergleich der exportierten Dreiecke. Ergebnis im Druck: „flutscht“,
  ohne Magnete eher zu locker.
- **UNO `_001` → `_002`:** Der Nutzer wünschte 0,4 mm. Die angegebenen
  90 × 60 mm waren nur grob gemessen. Die KI fragte nach und wechselte auf
  das UNO-Standardmaß 87 × 56 mm. Ergebnis: 0,4 mm „reicht locker“.
- **Vorlage `kartenbox_template_001`:** Eingabe sind nur Länge, Breite und
  Tiefe des Stapels. Magnetabstand, Drückloch und Mulden wachsen mit.
  Geprüft: Für die UNO-Maße entsteht Dreieck für Dreieck dieselbe Geometrie
  wie bei `kartenbox_uno_002`. Sechs weitere Größen sind geschlossen und
  kollisionsfrei. Grenzfälle brechen per `assert` mit Meldung ab.
- **Bedeutung:** Erster vollständiger Kreislauf aus Entwurf, Druck,
  Rückmeldung und Kontext-Update. Er zeigte, dass Werte aus kurzen
  Testkörpern nicht auf lange, dünnwandige Passungen übertragbar sind.

### 5.4 Pin-Magnetsockel (16.–18.09.)

- **Anforderung:** Ein rechteckiger Anstecker (40 × 25 mm) soll zum
  Kühlschrankmagneten werden, ohne ihn zu verändern.
- **Lösung:** 1,2 mm dünne „Stoffersatz“-Platte mit Nadelloch, dahinter
  eine Mulde für den Verschluss, 4 Magnete 7 × 2 mm nach hinten offen,
  umlaufender Rand gegen Verdrehen. Dazu ein 2-Minuten-Testchip.
- **Selbst gefunden:** Bei außermittiger Nadel kollidierten die
  automatischen Magnetpositionen mit der Mulde. Behoben mit einer echten
  2D-Abstandsprüfung und überschreibbaren Positionen.
- **Druck `_001`:** Pin passte nicht ganz in den Rand (0,3 mm pro Seite),
  der Verschluss stand über, die Griffkerbe gefiel nicht.
- **`_002`:** 0,5 mm, geschlossener Rand, tiefere Mulde. Laut späterem
  Eintrag in `tolerances.md` war 0,5 mm **zu locker**. Die Grenze liegt
  also zwischen 0,3 und 0,5 mm. Offen ist, ob der Pin nachgemessen war.

### 5.5 Laptop-/Tablet-Ständer (17.09.)

- **Anforderung:** Vertikaler Ständer für Laptop (20 mm) und iPad,
  schmal, weil auf dem Schreibtisch wenig Breite frei ist.
- **Plausibilitätsprüfung:** „iPad 15 cm dick“ wurde als unmöglich erkannt
  und nachgefragt.
- **`_001`:** 52,8 mm breit. Der Querschnitt-Check fand eine Rippe, die
  nach beidseitigen Fasen oben auf 0 mm auslief. Behoben, mit `assert`
  abgesichert.
- **Problem Standfestigkeit:** Die KI meldete zuerst einen Kippwinkel von
  12,9°, gerechnet mit symmetrischer Last. Der Nutzer zweifelte an der
  Konstruktion. Die Nachrechnung ergab: Die Rippen halten mit
  Sicherheitsfaktor 36, das echte Problem ist Kippen. Im ungünstigsten Fall
  (nur Laptop im Außenschlitz) sind es 8,0°, ein Schubs von ~130 g genügt.
  Ballast brachte rechnerisch fast nichts, nur Breite unten hilft.
- **`_002`:** Fußleiste mit 8 mm pro Seite, Tiefe 130 mm. Seitlich 12,2°
  bzw. 200 g.
- **`_003`:** Obere Ecken R20, Körper auf 100 mm gekürzt. Der Fuß steht
  auch vorne und hinten über, damit bleibt die Standfestigkeit fast gleich
  (12,0°, 197 g).
- **Druck:** `_003` in PLA, laut Nutzer „steht gut“. Zu den Rippen gibt
  es keine eigene Beobachtung. Ein Nachgeben wurde aber auch nicht
  gemeldet.
- **Bedeutung:** Anlass für die Rule `load-case-check` und für den Eintrag
  F12 im Fehlerkatalog. Die Sorge des Nutzers war berechtigt, zeigte aber
  auf die falsche Stelle.

### 5.6 Brillenetui (18.–19.09. und 27.09.)

- **Anforderung:** Schale aus PLA oder PETG, TPU-Einlage gegen Kratzer.
- **`_001`:** Scharnier mit zwei Stahlstiften, umlaufende Lippe,
  Verschlusslasche mit Magneten. Kollisionsprüfung über den Öffnungswinkel
  0–180°. Der Nutzer lehnte das Design ab: TPU-Schalen nicht sichtbar,
  Magnete sollen in den Rand, zu langweilig, Wunsch „Fraktal-Stil“.
- **Designfindung:** Die KI renderte mehrere Fraktal-Konzepte auf dem
  Deckel, statt sie nur zu beschreiben. Der Nutzer wählte eines aus.
- **`_002`:** Lichtenberg-Verästelung als Rillen, nahtlos über die Kanten,
  weil sie auf der abgewickelten Oberfläche wächst. Magnete unsichtbar in
  den Ecken. Renderzeit 2:20 min pro Hälfte mit OpenSCAD 2021.
- **`_003`:** Auf Wunsch echte Geometrie statt aufgedruckter Muster:
  verzogene Vielecke als gekippte Facetten. Eine eingebaute Prüfung fand,
  dass einzelne Facetten unter die Grundwand tauchten. Die Überhänge sind
  per `assert` auf 45° begrenzt. Farben der Vorschau seitdem fest: Hülle
  MidnightBlue, TPU schwarz.
- **`_004`:** Die Gelenkaugen sind Kristall-Prismen und liegen in einer
  Kerbe im Relief. Der Kollisions-Sweep fand eine echte Überschneidung bei
  180°, behoben durch eine Kerbe über die volle Keilhöhe. Dazu ein
  `hinge_test`, der aus den echten Teilen herausgeschnitten ist.
- **Druck (PETG):** „sehr gut“, Stifte und Magnete ließen sich gut
  einpressen, der Deckel schwenkt frei. TPU-Einlagen sind noch nicht
  gedruckt.
- **Nachträgliche QA (27.09.):** Das Etui war der Testfall für das neue
  Gate. Abgleich der 6 Befunde mit dem Druck: 1 echt und relevant (die
  Druckplatte war mit 278 mm größer als das 250-mm-Bett), 1 berechtigter
  Vorbehalt, 2 Fehlalarme (Magnet-Presssitz, Stiftweg), 2 informativ. Kein
  Fehler tauchte erst im Druck auf.
- **Prozessabweichung:** Gedruckt wurde vor einer dokumentierten Freigabe
  (G5). Das steht so im Bericht.

### 5.7 PocketBook-Ladeständer (27.–28.09.)

- **Anforderung:** Aufsteller zum Laden eines PocketBook Era Color mit
  Hülle und Popsocket. Der Nutzer lieferte zwei Handskizzen.
- **Gespräch:** Das größte Missverständnis war die Ausrichtung. Die KI nahm
  erst „hochkant“ mit seitlicher Buchse an, tatsächlich steht das Gerät auf
  der Seite, mit der Buchse unten. Mit einem gewinkelten USB-C-Stecker
  (UGREEN 90°) wurde der Sockel niedriger. Ergebnis war eine vom Nutzer
  bestätigte Anforderungstabelle mit 15, später 16 Zeilen, jede mit Quelle
  und Prüfmethode.
- **`_001`:** Die Eigenprüfung (G1) fand vor der QA zwei Fehler: Der
  Kabelkanal begann zu weit hinten, und eine Schachtwand lag exakt in der
  Ebene der Lippe (F7). Dadurch blieben alle Querschnitte still leer,
  statt einen Fehler zu melden. QA: 13 von 15 Anforderungen erfüllt, eine
  Überhangkante am Schacht (FAIL), Massenschätzung im `echo()` zu hoch.
- **`_002`:** Fase am Schacht, mehr Luft für den Popsocket, abgerundete
  Ecken auf Nutzerwunsch. Die QA fand, dass das `echo()` eine Stützenhöhe
  von 91,2 mm behauptete, real aber 88,3 mm vorlagen, weil die neue
  Rundung nicht eingerechnet war. Außerdem spitze Grate neben der Tasche.
- **`_003`:** 16 von 16 Anforderungen, G1–G4 bestanden. Die QA empfahl
  trotzdem zuerst den Passtest, weil Stecker, Kabel und Popsocket-Position
  angenommen waren.
- **Freigabe und Druck:** Wörtlich im Bericht dokumentiert: erst „nur
  fit_test“, nach dem Passtest („zufrieden“) der ganze Ständer. Die
  ungemessene Popsocket-Position ist als bewusst akzeptiertes Risiko
  vermerkt. Der ganze Ständer war bei Abschluss dieses Berichts noch im
  Druck.
- **Dauer:** vom ersten Prompt bis zum Export des Passtests ~70 min,
  inklusive drei QA-Läufen von je 7–10 min.

## 6. Probleme und Lösungen im Überblick

### 6.1 Modellierfehler der KI

| Problem | Beispiel | Lösung | Verankert in |
|---|---|---|---|
| Teile nicht verbunden, sehen aber verbunden aus | Lampenschirm 003 | `Volumes` je Teil prüfen | F8, G1 |
| `offset()` auf welligen Konturen erzeugt kaputte Geometrie | Lampenschirm 003 | Innenkontur direkt als `r(θ) - wand` rechnen | F10, `modeling` |
| Schnitt reicht nicht bis zur Oberfläche | Lampenschirm 004 | Schnittkörper deutlich überdimensionieren | F6 |
| Randbedingung zwischen Stützstellen verletzt | Lampenschirm 010, 012 | vollständiger Sweep, Sprung zwischen Nachbarn prüfen | F11, `verify-parametric-geometry` |
| Schneide nach Fasen | Laptop-Ständer 001 | `assert` auf Restbreite | F9, G4 |
| Geschönte Lastannahme | Laptop-Ständer 001 | ungünstigster Lastfall, unabhängig nachgerechnet | F12, `load-case-check` |
| Koplanare Flächen machen Prüfungen blind | PocketBook 001 | Schnittkörper einige Zehntel versetzen | F7 |
| `echo()` behauptet falschen Wert | PocketBook 002 | QA behandelt `echo()` als Behauptung und misst nach | `qa-agent` |
| Druckplatte größer als das Bett, obwohl jedes Teil passt | Brillenetui 004 | Bauraumprüfung für `print` | F18, G1 |
| Grob gemessenes Maß als exakt verwendet | Kartenbox UNO 001 | Quelle jedes Maßes in der Anforderungstabelle | F15 |

### 6.2 Kalibrierung und Toleranzen

Die wichtigste inhaltliche Erkenntnis: Die Werte aus dem
Kalibriertestblock gelten für kurze, steife Passungen. Reale Bauteile
brauchen je nach Art der Passung mehr Spiel. Stand `context/tolerances.md`:

| Passungsart | Material | Zu eng | Gut | Zu locker |
|---|---|---|---|---|
| Lange Gleitpassung (Schublade in Hülle) | PLA | 0,25 mm | **0,4 mm** | 0,5 mm (mit Magneten brauchbar) |
| Flache Einlage im Rand (Pin) | PLA | 0,3 mm | offen, ~0,4 mm | 0,5 mm |
| Stift-Presssitz Ø3 | PETG | – | **0,10 mm** | – |
| Magnet-Presssitz Ø6 | PETG | – | **0,15 mm** | – |
| Drehgelenk auf Ø3-Stift | PETG | – | 0,30 mm (frei, eher locker) | – |
| Klemmring auf Ø20-Stange (C-Ring, 3 mm Wand) | PLA | – | **−0,4 mm** (Ø19,2, Vorspannung) | – |

Alle Werte sind pro Seite und im CAD-Modell. Sie beruhen auf der
Einschätzung des Nutzers, nicht auf Messungen. TPU ist noch ohne Wert.

### 6.3 Prüf- und Prozessprobleme

| Problem | Folge | Lösung |
|---|---|---|
| Ohne Kontextdaten ist QA nicht möglich | Blumentopf ungeprüft | `context/` befüllt, Rule `context-first` |
| Die KI hielt sauber rendernde Modelle für fertig, der Nutzer sah die Fehler | beim Lampenschirm 9 Korrekturen vom Nutzer angestoßen, 3 von der KI | G3 blinde Sichtprüfung |
| Schnellvorschau zeigt Fehler, die es nicht gibt | Verwirrung beim Lampenschirm 002 | Prüfung immer am exportierten STL, `render()` |
| OpenSCAD 2021.01 meldet fehlgeschlagene `assert()` mit Exit-Code 0 | Fehler würden durchrutschen | `check.py` wertet die Ausgabe aus |
| QA als Subagent erst nach Neustart verfügbar | erster QA-Lauf am 27.09. über einen allgemeinen Agenten mit der QA-Anweisung | Neustart, seitdem als eigener Agententyp |
| Druck vor der Freigabe | Brillenetui ohne dokumentierte G5 | Befehl `/druckfeedback` vermerkt das, Freigabe wird wörtlich in den Bericht übernommen |
| QA zu vorsichtig | 2 Fehlalarme beim Brillenetui | F17 kalibriert, PETG-Werte in `tolerances.md` |
| Lange Renderzeiten bei vielen Booleschen Operationen | 2:20 min pro Hälfte beim Lichtenberg-Muster | schnelle Vorschau-Teile (`pattern_net`, `relief_preview`) |

### 6.4 Fehler des Agenten außerhalb der Modellierung

Diese Fälle sind für die Bewertung der Mensch-KI-Aufgabenteilung relevant:

- **18.09.:** Der Agent hielt `skills/render-preview.md` und
  `promote-finished.md` für nicht vorhanden, weil seine Verzeichnisliste
  abgeschnitten war, und überschrieb sie, ohne sie zu lesen. Er bemerkte
  das selbst, verglich mit der Git-Version und meldete es. Die neuen
  Fassungen enthielten den alten Inhalt vollständig.
- **18.09.:** Beim Aufräumen lag `lampenschirm_010` plötzlich in `trash/`
  statt in `finished/`. Der Agent konnte das nicht erklären, meldete es und
  schob die Datei bewusst nicht zurück.
- **18.09.:** Vor dem Löschen alter Entwürfe wies der Agent darauf hin,
  dass sie nicht in Git waren, und schlug Archivieren statt Löschen vor.

## 7. Wirksamkeit der Prüfstrategie

Das Uni-Feedback bemängelte eine fehlende konkrete Prüfstrategie gegen
Modelle, die fehlerfrei rendern, aber geometrisch unsinnig sind. Die
Sitzungsdaten erlauben einen Vorher-Nachher-Vergleich.

**Vor dem Gate (Lampenschirm, 01.–02.09.):** Die KI prüfte Kompilierung
und Manifold. Funktionale und optische Fehler fand meist der Nutzer
(9 Korrekturen, gegenüber 3 von der KI selbst gefundenen Fehlern).

**Mit dem Gate (PocketBook-Ständer, 27.–28.09.):**

| Fehler | Gefunden in | Vor dem Druck? |
|---|---|---|
| Kabelkanal beginnt zu weit hinten | G1 Eigenprüfung `_001` | ja |
| Koplanare Wand, Schnitte leer | G1 Eigenprüfung `_001` | ja |
| Überhangkante am Schacht | QA `_001` (G2/G4) | ja |
| Massenschätzung zu hoch | QA `_001` (G2) | ja |
| `echo()` behauptet falsche Stützenhöhe | QA `_002` (G2) | ja |
| Grate neben der Tasche | QA `_002` (G4) | ja |
| Fehler erst im Druck entdeckt | – | keine (Passtest) |

**Nachträglich angewendet (Brillenetui `_004`):** 6 Befunde, davon 1 echt,
1 berechtigter Vorbehalt, 2 Fehlalarme, 2 informativ. Kein Fehler tauchte
erst im Druck auf.

**Einordnung:** Zwei Objekte sind zu wenig für eine statistische Aussage.
Sie zeigen aber das Muster: Das Gate verschiebt die Fehlersuche vom Nutzer
zur QA und vom Druck in die Zeit davor. Der Preis sind gelegentliche
Fehlalarme und ~10 min pro QA-Lauf. Die Fehlalarme werden über den
Fehlerkatalog und `tolerances.md` nachkalibriert.

## 8. Mensch-KI-Aufgabenteilung in der Praxis

**Was der Nutzer beigetragen hat:**
- Anforderungen, Skizzen und Maße sowie das Nachmessen realer Teile
- Gestalterische Entscheidungen (organisch statt D-Form, Fraktal- und
  Kristallstil, „weniger klobig“)
- Visuelle Fehlererkennung, vor dem Gate der wichtigste Prüfschritt
- Druck und Bewertung der realen Teile, Freigaben
- Zweifel an Ergebnissen der KI, die zu besseren Rechnungen führten
  (Standfestigkeit Laptop-Ständer)

**Was die KI beigetragen hat:**
- Rückfragen und Plausibilitätsprüfung der Angaben (quadratische Karten,
  iPad-Dicke, UNO-Maß, Ausrichtung des PocketBooks)
- Variantenvorschläge mit Vor- und Nachteilen (Verschlüsse, Kabelführung,
  Designkonzepte als Renderings)
- Parametrischer Code mit `assert`-Absicherung und Rechnungen im `echo()`
- Numerische Prüfungen: Sweeps, Kollisionen über den Öffnungswinkel,
  gemessene Querschnitte, Lastfälle, Dreiecksvergleiche
- Pflege von Kontext, Fehlerkatalog und Berichten

**Bewusst beim Menschen geblieben:** Toleranzwerte kommen nur aus echten
Drucken, nie aus Schätzungen der KI. Freigabe zum Druck und Übernahme nach
`finished/` erfolgen nur auf ausdrückliche Anweisung. Beides wurde in allen
Sitzungen eingehalten. Ausnahme: der Druck des Brillenetuis vor der
Freigabe, eine Abweichung auf Nutzerseite.

## 9. Offene Punkte

- **TPU:** Die Einlagen des Brillenetuis sind noch nicht gedruckt, es gibt
  keinen TPU-Toleranzwert.
- **Toleranzgrenzen eingrenzen:** lange Gleitpassung ~0,35 mm, flache
  Einlage ~0,4 mm, PETG-Drehgelenk ~0,25 mm.
- **Messwerte:** Fast alle Druckergebnisse sind Einschätzungen. Für
  belastbare Werte fehlen Messschieber-Messungen an den gedruckten Teilen.
- **Materialannahmen:** Die Festigkeitswerte in `materials.md` sind nicht
  durch einen Druck bestätigt.
- **PocketBook-Ständer:** Der ganze Ständer ist im Druck. Das Ergebnis
  (Popsocket, Standfestigkeit) kommt per `/druckfeedback` in den
  QA-Bericht.
- **Aufräumen:** `brillenetui_001–003` und `pocketbook_ladestaender_001–002`
  liegen noch in `draft/`. `lampenschirm_010` liegt in `trash/`, ohne
  Eintrag in `NOTES.md`, und steht in der README noch als fertig.
- **Neue Werkzeuge:** Das Gate ist bisher an zwei Objekten erprobt. Nach
  dem Wechsel zu einem anderen KI-Tool wurde der Migrationsweg noch nicht
  praktisch getestet.

## Anhang: Sitzungsliste

| Datum | Sitzung | Nutzereingaben | Inhalt |
|---|---|---|---|
| 01.09. | 8c993dda | 6 | Grundgerüst, Erweiterungen, OpenSCAD, Testwürfel |
| 01.09. | df20cec9 | 4 | Konzeptdateien Agents, Skills, Rules; README; erster Push |
| 01.09. | 78d8da6b | 3 | Blumentopf |
| 01.–02.09. | c9b97058 (enthält a9d95f7a) | 17 | Lampenschirm 001–013, Rule `verify-parametric-geometry` |
| 02.–06.09. | ddf75a02 | 4 | `context/` befüllt, PoC-Beschreibung für die Hausarbeit |
| 11.–12.09. | d0f001d4 | 14 | Kartenboxen, Toleranzen, README, SETUP, Vorlage |
| 16.09. | 15caff9f | 2 | Pin-Magnetsockel |
| 17.–18.09. | a7abf4b9 | 4 | Laptop-Ständer, Rule `load-case-check`, Agents überarbeitet |
| 18.09. | 1fa515b9 | 1 | Freigaben, Archivierung, Aufräumen |
| 18.–19.09. | 99f68f3a | 7 | Brillenetui 001–004, Scharniertest |
| 27.09. | 3245bc8a | 10 | Uni-Feedback: Gate, `check.py`, Fehlerkatalog, Befehle, Anbieterunabhängigkeit; PETG-Druckergebnis |
| 27.–28.09. | cd5b68f8 | 13 | PocketBook-Ladeständer 001–003, Passtest, Freigabe |
