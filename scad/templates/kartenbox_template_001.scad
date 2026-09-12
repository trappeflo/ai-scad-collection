// TEMPLATE: Kartenbox (Schuber) – Schublade gleitet in eine Hülle mit
// geschlossener Rückwand, Verschluss über Magnete in den beiden Rückwänden
// Alle Maße in Millimetern (Regel: units-mm)
//
// Basis: kartenbox_uno_002 (im Druck bewährt), verallgemeinert.
// EINGABE: nur Länge, Breite und Tiefe (Höhe) des Kartenstapels – alles
// andere wird daraus abgeleitet. Die Reihenfolge von Länge/Breite ist egal,
// die längere Seite wird automatisch zur Schieberichtung.
//
// Verwendung:
//   a) Datei nach scad/draft/ kopieren (z.B. kartenbox_<spiel>_001.scad),
//      die drei Stapelmaße eintragen, rendern, exportieren.
//   b) Oder direkt im OpenSCAD-Customizer (Fenster -> Customizer) die drei
//      Werte setzen und "part" wählen.
//   Stapelmaße möglichst GENAU messen (Karte mit Lineal/Messschieber): die
//   Luft um den Stapel wird automatisch dazugerechnet.
//
// Kontext (Regel: context-first), Stand bei Erstellung:
//   - context/printer.md:    Anycubic Kobra S1, 0.4mm Düse, PEI, 250mm Bauhöhe
//   - context/tolerances.md: lange Gleitführungen 0.4mm/Seite = "läuft leicht"
//                            (Standard), 0.5 eher locker, 0.25 zu stramm
//   - context/materials.md:  noch leer -> PLA
//   Bei anderem Drucker/Material: slide_clear im Hidden-Bereich prüfen.
//
// Feste Auslegung (aus kartenbox_flip7 / kartenbox_uno übernommen):
//   - Gleitspiel 0.4mm/Seite (kartenbox_uno_002: "Toleranzen sind top")
//   - Luft um den Stapel 0.75mm/Seite, 1.5mm über dem Stapel
//   - Wände: Schublade 1.2mm, Hülle 1.6mm, Rückwände 3.2mm (Magnettaschen)
//   - 2 Magnetpaare 6x2mm, eingeklebt
//
// Mit der Stapelgröße skaliert (für UNO-Maße identisch zu kartenbox_uno_002):
//   - Magnetabstand: max. 36mm, bei schmalen Stapeln enger (Randabstand)
//   - Drückloch: max. Ø16mm, kleiner wenn Magnete/Höhe es erfordern (min. Ø10)
//   - Daumenmulden-Unterkante: max. 12mm, bei flachen Stapeln 1/3 der Höhe
//   - Griffmulden vorne: max. R9, bei flachen Stapeln kleiner
//   Grenzen werden per assert() geprüft: Breite >= ~30mm, Tiefe >= ~10.5mm
//   (sonst passen Magnete + Drückloch nicht), Länge <= ~240mm (Bauhöhe).
//
// Koordinaten: X = Schieberichtung (Kartenlänge), Y = Breite, Z = Höhe.
// Die Karten liegen flach in der Schublade.
//
// Bedienung: Zum Öffnen mit dem Finger durch das Loch in der Rückwand der
// Hülle drücken, bis die Schublade vorne heraussteht, dann an den Griffmulden
// greifen und herausziehen. Beim Schließen ziehen die Magnete die Schublade
// auf den letzten mm zu. Geschlossen liegt die Schublade mit ihrer Rückwand an
// der Hüllen-Rückwand an (definierter Anschlag = Magnete maximal nah).
//
// Druckausrichtung (part = "print"):
//   - Schublade: auf dem Boden liegend, offen nach oben. Keine Stützen.
//     Magnettaschen liegen waagerecht in der Rückwand (Ø6.3mm Brücke, unkritisch).
//   - Hülle: auf der Rückwand stehend, Öffnung nach oben. Keine Stützen,
//     Magnettaschen öffnen nach oben, Griffmulden sind U-Ausschnitte am oberen Rand.
//
// Magnete einkleben: POLUNG BEACHTEN! Jedes Paar muss sich anziehen.
// Tipp: Magnet in die Hüllen-Tasche kleben, Partner-Magnet obenauf setzen
// (zieht sich richtig herum an), dessen Außenseite markieren, dann mit der
// markierten Seite nach außen in die Schubladen-Tasche kleben.
// Magnete dürfen nicht überstehen (Tasche ist 0.1mm tiefer als der Magnet).

/* [Kartenstapel] */
// Länge des Kartenstapels (mm)
stack_length = 87;   // [30:0.5:230]
// Breite des Kartenstapels (mm)
stack_width  = 56;   // [30:0.5:230]
// Tiefe (Höhe) des Kartenstapels (mm)
stack_depth  = 40;   // [11:0.5:150]

/* [Ausgabe] */
// print = beide Teile in Druckausrichtung, drawer/sleeve = Einzelteil für STL-Export,
// fit_test = Passungstest-Ringe, assembly = zusammengebaut, interference = Kollisionsprüfung (muss leer sein)
part    = "print";   // [print, drawer, sleeve, fit_test, assembly, interference]
// Nur für assembly: wie weit die Schublade herausgezogen ist (mm)
open_mm = 30;        // [0:1:100]

/* [Hidden] */

// ---- Karten ----
card_clear_xy  = 0.75; // Luft pro Seite um den Stapel (eff. XY-Fehler frisst ~0.15–0.2 davon)
stack_headroom = 1.5;  // Luft über dem Stapel (Stapelhöhe schwankt je nach Mischen/Feuchte)

// ---- Schublade ----
d_side_t  = 1.2;  // Seitenwände (3 Linien à 0.4)
d_floor_t = 1.2;  // Boden (6 Schichten à 0.2)
d_front_t = 2.0;  // Front (sichtbare Stirnseite, bündig mit der Hüllenöffnung)
d_back_t  = 3.2;  // Rückwand, trägt die Magnettaschen
d_chamfer = 0.6;  // Fase an den 4 Längskanten: Freigang in den Innenecken der
                  // Hülle, wirkt zugleich gegen Elefantenfuß

// ---- Hülle ----
s_wall_t     = 1.6;  // Wände (4 Linien à 0.4)
s_back_t     = 3.2;  // Rückwand, trägt Magnettaschen + Drückloch
slide_clear  = 0.4;  // Gleitspiel pro Seite, nominal (tolerances.md: Standard für lange Gleitführungen)
front_recess = 0.2;  // Schublade sitzt geschlossen minimal hinter der Öffnung (steht nie über)
s_edge_r     = 2;    // Rundung der 4 Längskanten außen
rim_chamfer  = 0.4;  // Einführfase innen an der Öffnung

// ---- Magnete ----
mag_d           = 6;    // Magnetdurchmesser (5 / 6 / 7 vorhanden)
mag_h           = 2;    // Magnethöhe
mag_clear       = 0.15; // Radialspiel pro Seite zum Einkleben
mag_depth_extra = 0.1;  // Tasche tiefer als Magnet -> Magnet steht nicht über
mag_spacing_max = 36;   // Abstand der beiden Magnetpaare Mitte-Mitte (Y), Obergrenze
mag_edge        = 2.5;  // Mindestabstand Magnettasche zur Außenkante der Schublade
mag_web         = 3;    // Mindeststeg zwischen Magnettasche und Drückloch

// ---- Griffe ----
push_hole_max = 16;  // Drückloch in der Hüllen-Rückwand (Fingerkuppe), Obergrenze
push_hole_min = 10;  // darunter wird es unbenutzbar -> assert
notch_w       = 24;  // Breite der Daumenmulden in den Seitenwänden der Schublade
notch_bottom_max = 12; // Unterkante der Daumenmulde über der Schubladenunterseite, Obergrenze
grip_r_max    = 9;   // Radius der Griffmulden vorne in den Hüllen-Seitenwänden, Obergrenze

// ---- Passungstest ----
fit_test_clears = [0.3, 0.4, 0.5]; // Spiel pro Seite der drei Ringe (1 / 2 / 3 Kerben)
fit_test_h      = 6;               // Höhe der Ringe
fit_test_plate  = 3;               // Dicke des Schubladen-Querschnitts

// ---- Drucker ----
build_h = 250;  // Bauhöhe Kobra S1 (printer.md) – Hülle wird stehend gedruckt

$fn = 64;

// ---- Abgeleitete Maße ----
card_l  = max(stack_length, stack_width);  // längere Seite = Schieberichtung
card_w  = min(stack_length, stack_width);
stack_h = stack_depth;

d_in_l = card_l + 2 * card_clear_xy;     // Kartenfach Länge
d_in_w = card_w + 2 * card_clear_xy;     // Kartenfach Breite
d_in_h = stack_h + stack_headroom;       // Kartenfach Höhe (bis Oberkante Seitenwand)
d_l = d_back_t + d_in_l + d_front_t;     // Schublade außen
d_w = d_in_w + 2 * d_side_t;
d_h = d_floor_t + d_in_h;

s_in_w = d_w + 2 * slide_clear;          // Hülle innen
s_in_h = d_h + 2 * slide_clear;
s_in_l = d_l + front_recess;
s_l = s_back_t + s_in_l;                 // Hülle außen = Box außen
s_w = s_in_w + 2 * s_wall_t;
s_h = s_in_h + 2 * s_wall_t;

pocket_d = mag_d + 2 * mag_clear;
pocket_h = mag_h + mag_depth_extra;

// Größenabhängige Features (für UNO 87x56x40 identisch zu kartenbox_uno_002)
mag_spacing  = min(mag_spacing_max, d_w - pocket_d - 2 * mag_edge);
push_hole_d  = min(push_hole_max, mag_spacing - pocket_d - 2 * mag_web, s_in_h - 4);
notch_bottom = min(notch_bottom_max, d_h / 3);
grip_r       = min(grip_r_max, s_in_h / 2 - 2);

// Lage der Schublade in der Hülle (zentriert im Gleitspiel)
d_off_y = s_wall_t + slide_clear;
d_off_z = s_wall_t + slide_clear;

// Magnet-Mittelpunkte: in beiden Teilen aus derselben Größe abgeleitet,
// damit die Paare im geschlossenen Zustand exakt fluchten
mag_z_drawer = d_h / 2;
mag_z_sleeve = d_off_z + mag_z_drawer;
function mag_y_list(width) = [width / 2 - mag_spacing / 2, width / 2 + mag_spacing / 2];

// ---- Plausibilitätsprüfungen ----
assert(push_hole_d >= push_hole_min,
    str("Stapel zu schmal/flach für Magnete + Drückloch (Drückloch wäre nur Ø",
        push_hole_d, "mm). Mindestens ca. 30mm Breite und 10.5mm Tiefe."));
assert(s_l <= build_h,
    str("Box zu lang für stehenden Druck der Hülle: ", s_l, "mm > ", build_h, "mm Bauhöhe."));

echo(str("Box außen (L x B x H): ", s_l, " x ", s_w, " x ", s_h, " mm"));
echo(str("Schublade außen: ", d_l, " x ", d_w, " x ", d_h, " mm"));
echo(str("Kartenfach innen: ", d_in_l, " x ", d_in_w, " x ", d_in_h, " mm"));
echo(str("Magnetabstand: ", mag_spacing, " mm, Drückloch: Ø", push_hole_d,
         " mm, Griffmulde: R", grip_r, " mm, Daumenmulde ab: ", notch_bottom, " mm"));

// ---- 2D-Hilfsformen ----

// Rechteck [0,w]x[0,h] mit 45°-Fasen an den Ecken (konvex -> offset unkritisch)
module chamfered_rect(w, h, c) {
    translate([c, c]) offset(delta = c, chamfer = true) square([w - 2 * c, h - 2 * c]);
}

// Rechteck [0,w]x[0,h] mit gerundeten Ecken (konvex -> offset unkritisch)
module rounded_rect(w, h, r) {
    translate([r, r]) offset(r = r) square([w - 2 * r, h - 2 * r]);
}

// Daumenmulde als U-Form in der XZ-Ebene (x um 0 zentriert)
module notch_2d() {
    r = notch_w / 2;
    translate([0, notch_bottom + r]) circle(r = r);
    translate([-r, notch_bottom + r]) square([notch_w, d_h]);
}

// Magnettasche entlang +X, Öffnung bei x=0
module magnet_pocket_x() {
    rotate([0, 90, 0]) cylinder(d = pocket_d, h = pocket_h + 0.01);
}

// ---- Teile ----

// Schublade: Rückwand bei x=0, Front bei x=d_l
module drawer() {
    difference() {
        // Außenkörper: gefastes YZ-Profil entlang X extrudiert
        rotate([90, 0, 90]) linear_extrude(d_l) chamfered_rect(d_w, d_h, d_chamfer);

        // Kartenfach (nach oben offen)
        translate([d_back_t, d_side_t, d_floor_t]) cube([d_in_l, d_in_w, d_in_h + 1]);

        // Daumenmulden in beiden Seitenwänden, mittig über dem Kartenfach
        translate([d_back_t + d_in_l / 2, d_w + 1, 0])
            rotate([90, 0, 0]) linear_extrude(d_w + 2) notch_2d();

        // Magnettaschen, öffnen nach hinten (Richtung Hüllen-Rückwand)
        for (y = mag_y_list(d_w))
            translate([-0.01, y, mag_z_drawer]) magnet_pocket_x();
    }
}

// Hülle: Rückwand bei x=0, Öffnung bei x=s_l
module sleeve() {
    difference() {
        rotate([90, 0, 90]) linear_extrude(s_l) rounded_rect(s_w, s_h, s_edge_r);

        // Innenraum, vorne offen
        translate([s_back_t, s_wall_t, s_wall_t]) cube([s_in_l + 1, s_in_w, s_in_h]);

        // Einführfase an der Öffnung
        hull() {
            translate([s_l - rim_chamfer, s_wall_t, s_wall_t])
                cube([0.01, s_in_w, s_in_h]);
            translate([s_l, s_wall_t - rim_chamfer, s_wall_t - rim_chamfer])
                cube([0.01, s_in_w + 2 * rim_chamfer, s_in_h + 2 * rim_chamfer]);
        }

        // Griffmulden vorne: Halbkreis in beiden Seitenwänden, mittig in der
        // Höhe. Liegt nur über dem massiven Frontbereich der Schublade, nicht
        // über deren Daumenmulden.
        translate([s_l, s_w + 1, s_h / 2])
            rotate([90, 0, 0]) cylinder(r = grip_r, h = s_w + 2);

        // Drückloch in der Rückwand
        translate([-1, s_w / 2, s_h / 2])
            rotate([0, 90, 0]) cylinder(d = push_hole_d, h = s_back_t + 2);

        // Magnettaschen, öffnen zur Innenseite der Rückwand
        for (y = mag_y_list(s_w))
            translate([s_back_t - pocket_h, y, mag_z_sleeve]) magnet_pocket_x();
    }
}

// ---- Passungstest ----

// Kurzer Hüllen-Ring mit Spiel "clear" pro Seite, liegend gedruckt – das
// entspricht der echten Hülle, die stehend gedruckt wird (Querschnitt in XY).
// Markierung: "marks" Kerben an der Oberkante einer Längsseite.
module sleeve_ring(clear, marks) {
    in_w = d_w + 2 * clear;
    in_h = d_h + 2 * clear;
    o_w  = in_w + 2 * s_wall_t;
    o_h  = in_h + 2 * s_wall_t;
    difference() {
        linear_extrude(fit_test_h) rounded_rect(o_w, o_h, s_edge_r);
        translate([s_wall_t, s_wall_t, -1]) cube([in_w, in_h, fit_test_h + 2]);
        for (i = [0 : marks - 1])
            translate([o_w / 2 - (marks - 1) * 1.5 + i * 3 - 0.75, -0.01, fit_test_h - 1.5])
                cube([1.5, 0.8, 1.6]);
    }
}

// Schubladen-Querschnitt, stehend gedruckt wie die echte Schublade (Breite in
// XY, Höhe in Z). Massiv -> steifer als die echten Seitenwände, der Test ist
// also eher konservativ (passt der Querschnitt, passt die Schublade).
module drawer_section() {
    rotate([90, 0, 0]) linear_extrude(fit_test_plate) chamfered_rect(d_w, d_h, d_chamfer);
}

module fit_test() {
    pitch_x = d_w + 2 * max(fit_test_clears) + 2 * s_wall_t + 8;
    pitch_y = d_h + 2 * max(fit_test_clears) + 2 * s_wall_t + 8;
    for (i = [0 : len(fit_test_clears) - 1])
        translate([(i % 2) * pitch_x, floor(i / 2) * pitch_y, 0])
            sleeve_ring(fit_test_clears[i], i + 1);
    translate([pitch_x, pitch_y + fit_test_plate, 0]) drawer_section();
}

// ---- Ausgabe ----

module drawer_in_sleeve(pull) {
    translate([s_back_t + pull, d_off_y, d_off_z]) drawer();
}

// render() erzwingt die exakte Boolesche Berechnung, damit die F5-Vorschau
// dem Export entspricht (siehe skills/modeling.md)
if (part == "print") {
    render(convexity = 10) drawer();
    // Hülle auf die Rückwand gestellt (x -> z), rechts neben die Schublade
    translate([d_l + 10 + s_h, 0, 0]) rotate([0, -90, 0]) render(convexity = 10) sleeve();
} else if (part == "drawer") {
    render(convexity = 10) drawer();
} else if (part == "sleeve") {
    rotate([0, -90, 0]) render(convexity = 10) sleeve();
} else if (part == "fit_test") {
    render(convexity = 10) fit_test();
} else if (part == "assembly") {
    color("SteelBlue", 0.6) render(convexity = 10) sleeve();
    color("Orange") render(convexity = 10) drawer_in_sleeve(open_mm);
} else if (part == "interference") {
    intersection() {
        sleeve();
        drawer_in_sleeve(0);
    }
}
