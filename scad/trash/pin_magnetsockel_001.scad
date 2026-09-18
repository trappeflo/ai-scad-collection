// Magnetsockel für rechteckigen Ansteck-Pin (Standard: 40 x 25 mm)
// Macht aus einem Ansteck-Pin einen Kühlschrankmagneten, OHNE den Pin zu
// verändern: der Pin behält Nadel und Schmetterlings-Clutch.
// Alle Maße in Millimetern (Regel: units-mm)
//
// Kontext (Regel: context-first), Stand bei Erstellung:
//   - context/printer.md:    Anycubic Kobra S1, 0.4mm Düse, PEI, 250mm Bauraum
//   - context/tolerances.md: Presspassung 0.05–0.15mm/Seite, bewegliche
//                            Passung 0.2–0.25mm/Seite, eff. XY-Fehler
//                            ~0.15–0.2mm/Seite
//   - context/materials.md:  noch leer -> PLA
//
// Anforderungen aus dem Design-Dialog:
//   - Pin rechteckig 40 x 25 mm, ein Nadelstift mit Schmetterlings-Clutch
//   - Halt am Sockel: Nadel durch eine dünne Platte stecken, Clutch dahinter
//     aufsetzen – genau wie auf Stoff. Fest, aber jederzeit abnehmbar,
//     kein Kleber, keine Änderung am Pin.
//   - Sockel haftet mit Magneten auf einer Metallfläche (Kühlschrank)
//   - Magnete: 7 x 2 mm rund (vorhanden), werden eingeklebt
//
// Funktionsprinzip / Aufbau (Z = 0 liegt am Kühlschrank):
//   z 0 .. pocket_d    Clutch-Mulde: nach hinten offene Wanne, in der der
//                      Schmetterling sitzt. Offen, damit man ihn mit den
//                      Fingern oder einer Pinzette aufdrücken kann.
//   z 0 .. 2.1         Magnettaschen, nach hinten offen -> Magnet liegt
//                      direkt (0.1mm zurückgesetzt) an der Metallfläche an,
//                      das ist die maximale Haltekraft.
//   pocket_d .. base_t Klemmplatte (plate_t) mit dem Nadelloch – das ist der
//                      "Stoff", auf den die Clutch klemmt.
//   base_t .. +rim_h   Umlaufender Rand, in dem der Pin liegt. Verhindert,
//                      dass sich der Pin um die einzelne Nadel verdreht.
//                      An der Unterkante eine Griffkerbe zum Herausheben.
//
// Montage:
//   1. Magnete einkleben (alle mit derselben Polung nach außen, sonst
//      schwächen sie sich gegenseitig). Sie dürfen nicht überstehen –
//      die Tasche ist 0.1mm tiefer als der Magnet.
//   2. Clutch vom Pin abziehen, Nadel von vorne durch das Nadelloch stecken,
//      Pin flach in den Rand legen.
//   3. Von hinten die Clutch in der Mulde wieder auf die Nadel drücken.
//
// Druckausrichtung: Rückseite (Magnetseite) auf dem Druckbett, Pin-Auflage
//   nach oben. Keine Stützen nötig. Gebrückt werden nur die Magnettaschen
//   (Ø7.3mm) und die Decke der Clutch-Mulde (Spannweite = pocket_h, ~14mm) –
//   beides unkritisch (printer.md nennt Durchhang erst bei 50mm+).
//   Die plane Rückseite liegt auf dem PEI = gute Haftung und exakt die
//   Fläche, die später am Kühlschrank anliegt.
//
// ZUERST MESSEN (Messschieber) und unten eintragen, dann part="test"
// drucken (~2 Minuten) und die Clutch-Klemmung prüfen:
//   - needle_d   Nadeldurchmesser
//   - needle_len freie Nadellänge ab Pin-Rückseite
//   - clutch_d   Breite der Clutch mit ausgeklappten Flügeln
//   - clutch_h   Bauhöhe der Clutch, auf der Nadel sitzend
//   - pin_w/pin_h/pin_corner_r  Außenmaße und Eckenradius des Pins
//   - needle_off_x/y  Versatz der Nadel aus der Pin-Mitte (oft nicht mittig!)

/* [Pin] */
// Breite des Pins (X)
pin_w = 40;
// Höhe des Pins (Y)
pin_h = 25;
// Eckenradius des Pins. Im Zweifel klein lassen - eine zu runde Aussparung
// klemmt an den Ecken, eine zu eckige laesst nur eine Fuge sichtbar.
pin_corner_r = 1.0;
// Nadelversatz aus der Pin-Mitte in X
needle_off_x = 0;
// Nadelversatz aus der Pin-Mitte in Y
needle_off_y = 0;
// Nadeldurchmesser
needle_d = 1.2;
// Freie Nadellaenge ab Pin-Rueckseite
needle_len = 6.0;
// Breite der Clutch mit ausgeklappten Fluegeln
clutch_d = 12.0;
// Bauhoehe der Clutch auf der Nadel
clutch_h = 5.0;

/* [Magnete] */
// Magnetdurchmesser
magnet_d = 7.0;
// Magnetdicke
magnet_t = 2.0;
// Anzahl Magnete bei automatischer Platzierung
magnet_count = 4; // [2, 4]
// Magnetpositionen [x,y] relativ zur Sockelmitte. Leer = automatisch in die
// Ecken. Bei stark aussermittiger Nadel kollidieren die automatischen
// Positionen evtl. mit der Clutch-Mulde - dann hier von Hand setzen,
// Die Pruefung unten meldet jede Kollision mit Nummer und Abstand.
// Geprueftes Beispiel fuer needle_off_x=8, needle_off_y=4 (Pin 40x25):
//   magnet_pos = [[-16.25, 8.75], [-16.25, -8.75], [8, -9]]
magnet_pos = [];

/* [Sockel] */
// Hoehe des Randes um den Pin. Sinnvoll: etwa die Dicke des Pins, hoechstens
// so hoch wie der Pin dick ist - sonst steht der Rand vor dem Pin.
// 0 = kein Rand, dann haelt nur die Clutch (Pin kann sich dann verdrehen).
rim_h = 1.5;
// Wandstaerke des Randes
rim_t = 1.6;
// Luft zwischen Pin und Rand pro Seite
pin_fit = 0.3;
// Dicke der Klemmplatte (der "Stoff" fuer die Clutch)
plate_t = 1.2;
// Breite der Griffkerbe im Rand (0 = keine)
notch_w = 12;
// Zusaetzlicher Platz in der Clutch-Mulde zum Zugreifen (Finger/Pinzette).
// Bei kleineren Pins verkleinern, dann passen die Magnete wieder daneben.
clutch_access = 8;

/* [Ausgabe] */
// sockel = fertiges Teil, test = kleiner Pruefkoerper nur fuer Nadel+Clutch
part = "sockel"; // [sockel, test]

/* [Hidden] */
$fa = 2;
$fs = 0.4;
eps = 0.01;

// ---- abgeleitete Maße -------------------------------------------------
// Nadelloch etwas groesser als die Nadel: es soll nicht klemmen, das Halten
// uebernimmt die Clutch. Der Rand verhindert das Verdrehen.
needle_hole_d   = needle_d + 0.4;
// Magnettaschen: 0.3mm Uebermaß zum Einkleben (wie kartenbox_*: 6mm -> 6.3),
// 0.1mm tiefer als der Magnet, damit nichts uebersteht.
magnet_pocket_d = magnet_d + 0.3;
magnet_pocket_t = magnet_t + 0.1;
// Rand-Abstand der Magnettaschen zur Außenkante
magnet_wall     = 2.0;

// Clutch-Mulde: rundum Luft um die Clutch, zusaetzlich Zugriff fuer Finger
// bzw. Pinzette. Deshalb deutlich groesser als die Clutch selbst.
pocket_w = clutch_d + clutch_access;
pocket_h = max(clutch_d + 2, 12);
pocket_r = 3;
// Tiefe: die Clutch muss komplett versenkt sein UND die Nadelspitze darf
// nicht hinten herausstehen (sonst kratzt sie am Kuehlschrank).
pocket_d = max(clutch_h + 0.5, needle_len - plate_t + 0.5);

base_t = plate_t + pocket_d;
base_w = pin_w + 2 * (pin_fit + rim_t);
base_h = pin_h + 2 * (pin_fit + rim_t);
base_r = pin_corner_r + pin_fit + rim_t;

recess_w = pin_w + 2 * pin_fit;
recess_h = pin_h + 2 * pin_fit;
recess_r = pin_corner_r + pin_fit;

magnet_x_auto = base_w / 2 - magnet_pocket_d / 2 - magnet_wall;
magnet_y_auto = base_h / 2 - magnet_pocket_d / 2 - magnet_wall;
magnets = (len(magnet_pos) > 0) ? magnet_pos
        : (magnet_count == 4)
          ? [for (sx = [-1, 1], sy = [-1, 1])
                [sx * magnet_x_auto, sy * magnet_y_auto]]
          : [for (sx = [-1, 1]) [sx * magnet_x_auto, 0]];

// ---- Pruefungen -------------------------------------------------------
// Vorzeichenbehafteter Abstand eines Punktes zum Rand eines abgerundeten
// Rechtecks (negativ = innerhalb). Damit wird echt in 2D geprueft, ob eine
// Magnettasche die Clutch-Mulde anschneidet bzw. aus dem Sockel laeuft -
// eine reine X- oder Y-Betrachtung uebersieht die Diagonale.
function sdf_rrect(p, c, hw, hh, r) =
    let (dx = abs(p[0] - c[0]) - (hw - r),
         dy = abs(p[1] - c[1]) - (hh - r))
    sqrt(pow(max(dx, 0), 2) + pow(max(dy, 0), 2)) + min(max(dx, dy), 0) - r;

// Abstand Magnettasche <-> Clutch-Mulde (Material dazwischen)
gap_pocket = [for (m = magnets)
    sdf_rrect(m, [needle_off_x, needle_off_y], pocket_w / 2, pocket_h / 2,
              pocket_r) - magnet_pocket_d / 2];
// Abstand Magnettasche <-> Außenkante des Sockels
gap_edge = [for (m = magnets)
    -sdf_rrect(m, [0, 0], base_w / 2, base_h / 2, base_r)
    - magnet_pocket_d / 2];

for (i = [0 : len(magnets) - 1]) {
    assert(gap_pocket[i] >= 0.8,
           str("Magnet ", i, " bei ", magnets[i],
               " schneidet die Clutch-Mulde an (Abstand ", gap_pocket[i],
               "mm, noetig 0.8). Abhilfe: clutch_access kleiner, kleinere ",
               "Magnete, magnet_pos von Hand setzen oder magnet_count=2."));
    assert(gap_edge[i] >= 1.2,
           str("Magnet ", i, " bei ", magnets[i],
               " liegt zu nah an der Außenkante (Wand ", gap_edge[i],
               "mm, noetig 1.2)."));
}
// Mulde muss mit Restwand innerhalb des Sockels liegen
assert(-sdf_rrect([needle_off_x + pocket_w / 2, needle_off_y + pocket_h / 2],
                  [0, 0], base_w / 2, base_h / 2, base_r) >= 0
       && abs(needle_off_x) + pocket_w / 2 <= base_w / 2 - 2.0
       && abs(needle_off_y) + pocket_h / 2 <= base_h / 2 - 2.0,
       "Clutch-Mulde passt nicht in den Sockel (Pin zu klein oder Nadel zu weit aussen).");
// Material ueber dem Magneten
assert(base_t - magnet_pocket_t >= 1.2,
       "Zu wenig Material ueber den Magnettaschen.");
// Nadelspitze darf nicht hinten herausstehen
assert(pocket_d - (needle_len - plate_t) >= 0.4,
       "Nadel steht hinten heraus - pocket_d/needle_len pruefen.");
// Wandstaerken (Regel: printability-report) - 2x Duesendurchmesser = 0.8mm
assert(rim_t >= 0.8 && plate_t >= 0.8,
       "Wandstaerke unter 0.8mm (2x Duese 0.4mm).");

echo(str("--- pin_magnetsockel: Sockel ", base_w, " x ", base_h,
         " x ", base_t + rim_h, " mm ---"));
echo(str("Klemmplatte ", plate_t, "mm, Clutch-Mulde ", pocket_w, " x ",
         pocket_h, " x ", pocket_d, "mm tief"));
echo(str("Nadelspitze endet ", pocket_d - (needle_len - plate_t),
         "mm vor der Rueckseite"));
echo(str("Magnete: ", len(magnets), "x ", magnet_d, "x", magnet_t,
         " bei ", magnets));
echo(str("Wand Magnet->Mulde ", gap_pocket, "mm, Magnet->Außenkante ",
         gap_edge, "mm"));
echo(str("Bruecken: Magnettasche ", magnet_pocket_d, "mm, Muldendecke ",
         pocket_h, "mm - beide unkritisch"));

// ---- Hilfsmodule ------------------------------------------------------
module rrect(w, h, r) {
    hull() for (x = [-1, 1], y = [-1, 1])
        translate([x * (w / 2 - r), y * (h / 2 - r)]) circle(r = r);
}

// Clutch-Mulde + Nadelloch, als Werkzeug zum Abziehen
module clutch_cuts() {
    translate([needle_off_x, needle_off_y, -eps])
        linear_extrude(pocket_d + eps)
            rrect(pocket_w, pocket_h, pocket_r);
    translate([needle_off_x, needle_off_y, -eps])
        cylinder(d = needle_hole_d, h = base_t + 2 * eps);
}

// ---- Teile ------------------------------------------------------------
module sockel() {
    render(convexity = 8)
    difference() {
        union() {
            linear_extrude(base_t) rrect(base_w, base_h, base_r);
            if (rim_h > 0)
                translate([0, 0, base_t]) linear_extrude(rim_h)
                    difference() {
                        rrect(base_w, base_h, base_r);
                        rrect(recess_w, recess_h, recess_r);
                    }
        }
        clutch_cuts();
        // Magnettaschen, nach hinten offen
        for (m = magnets)
            translate([m[0], m[1], -eps])
                cylinder(d = magnet_pocket_d, h = magnet_pocket_t + eps);
        // Griffkerbe im Rand (Vorderkante, -Y), zum Herausheben des Pins
        if (notch_w > 0 && rim_h > 0)
            translate([-notch_w / 2, -base_h / 2 - 1, base_t - eps])
                cube([notch_w, base_h / 2 - recess_h / 2 + 1 + eps,
                      rim_h + 2 * eps]);
    }
}

// Pruefkoerper: nur Klemmplatte + Mulde + Nadelloch, gleiche Dicken wie am
// Sockel. Damit vor dem Volldruck testen, ob die Clutch sicher greift und
// ob die Nadel lang genug ist.
module test_chip() {
    render(convexity = 6)
    difference() {
        translate([needle_off_x, needle_off_y, 0])
            linear_extrude(base_t) rrect(pocket_w + 8, pocket_h + 6, 3);
        clutch_cuts();
    }
}

if (part == "sockel") sockel();
else if (part == "test") test_chip();
