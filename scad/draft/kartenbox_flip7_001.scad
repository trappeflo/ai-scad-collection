// Kartenbox (Schuber) – Schublade gleitet in eine Hülle mit geschlossener
// Rückwand, Verschluss über Magnete in den beiden Rückwänden
// Alle Maße in Millimetern (Regel: units-mm)
//
// Kontext (Regel: context-first):
//   - context/printer.md:    Anycubic Kobra S1, 0.4mm Düse, PEI
//   - context/tolerances.md: Gleitpassung 0.2–0.25mm/Seite, eff. XY-Fehler
//                            ~0.15–0.2mm/Seite
//   - context/materials.md:  noch leer -> PLA laut Nutzer
//
// Anforderungen aus dem Design-Dialog:
//   - Kartenstapel 80 x 54 mm, 36 mm hoch, ohne Sleeves (auch künftig nicht)
//   - Gelegentlicher Transport im Rucksack -> Verschluss muss sicher halten
//   - Verschluss: Schuber + Magnete, Magnete werden eingeklebt
//     (vorhanden: 5x2, 6x2, 7x2 mm rund -> Standard hier 6x2)
//   - PLA, einfarbig, keine Gravur (vorerst)
//
// Koordinaten: X = Schieberichtung (Kartenlänge), Y = Breite, Z = Höhe.
// Die Karten liegen flach in der Schublade.
//
// Bedienung: Zum Öffnen mit dem Finger durch das Loch in der Rückwand der
// Hülle drücken, bis die Schublade vorne heraussteht, dann herausziehen.
// Beim Schließen ziehen die Magnete die Schublade auf den letzten mm zu.
// Geschlossen liegt die Schublade mit ihrer Rückwand an der Hüllen-
// Rückwand an (definierter Anschlag = Magnete maximal nah beieinander).
//
// Druckausrichtung (part = "print"):
//   - Schublade: auf dem Boden liegend, offen nach oben. Keine Stützen.
//     Magnettaschen liegen waagerecht in der Rückwand (Ø6.3mm Brücke, unkritisch).
//   - Hülle: auf der Rückwand stehend, Öffnung nach oben. Keine Stützen,
//     Magnettaschen öffnen nach oben.
//
// Magnete einkleben: POLUNG BEACHTEN! Jedes Paar muss sich anziehen.
// Tipp: Magnet in die Hüllen-Tasche kleben, Partner-Magnet obenauf setzen
// (zieht sich richtig herum an), dessen Außenseite markieren, dann mit der
// markierten Seite nach außen in die Schubladen-Tasche kleben.
// Magnete dürfen nicht überstehen (Tasche ist 0.1mm tiefer als der Magnet).

// ---- Ausgabe ----
// "print"        = beide Teile in Druckausrichtung nebeneinander
// "drawer"       = nur Schublade (Druckausrichtung)
// "sleeve"       = nur Hülle (Druckausrichtung)
// "assembly"     = zusammengebaut, Schublade um open_mm herausgezogen
// "interference" = Schnittmenge beider Teile im geschlossenen Zustand (muss leer sein)
part    = "print";
open_mm = 30;

// ---- Karten ----
card_l  = 80;     // Kartenlänge (X)
card_w  = 54;     // Kartenbreite (Y)
stack_h = 36;     // Stapelhöhe (Z)
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
slide_clear  = 0.25; // Gleitspiel pro Seite (tolerances.md: 0.2–0.25 für bewegliche Passungen)
front_recess = 0.2;  // Schublade sitzt geschlossen minimal hinter der Öffnung (steht nie über)
s_edge_r     = 2;    // Rundung der 4 Längskanten außen
rim_chamfer  = 0.4;  // Einführfase innen an der Öffnung

// ---- Magnete ----
mag_d           = 6;    // Magnetdurchmesser (5 / 6 / 7 vorhanden)
mag_h           = 2;    // Magnethöhe
mag_clear       = 0.15; // Radialspiel pro Seite zum Einkleben
mag_depth_extra = 0.1;  // Tasche tiefer als Magnet -> Magnet steht nicht über
mag_spacing     = 36;   // Abstand der beiden Magnetpaare Mitte-Mitte (Y)

// ---- Griffe ----
push_hole_d  = 16;  // Drückloch in der Hüllen-Rückwand (Fingerkuppe)
notch_w      = 24;  // Breite der Daumenmulden in den Seitenwänden der Schublade
notch_bottom = 12;  // Unterkante der Daumenmulde über der Schubladenunterseite

$fn = 64;

// ---- Abgeleitete Maße ----
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

// Lage der Schublade in der Hülle (zentriert im Gleitspiel)
d_off_y = s_wall_t + slide_clear;
d_off_z = s_wall_t + slide_clear;

// Magnet-Mittelpunkte: in beiden Teilen aus derselben Größe abgeleitet,
// damit die Paare im geschlossenen Zustand exakt fluchten
mag_z_drawer = d_h / 2;
mag_z_sleeve = d_off_z + mag_z_drawer;
function mag_y_list(width) = [width / 2 - mag_spacing / 2, width / 2 + mag_spacing / 2];

echo(str("Box außen (L x B x H): ", s_l, " x ", s_w, " x ", s_h, " mm"));
echo(str("Schublade außen: ", d_l, " x ", d_w, " x ", d_h, " mm"));
echo(str("Kartenfach innen: ", d_in_l, " x ", d_in_w, " x ", d_in_h, " mm"));

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

        // Drückloch in der Rückwand
        translate([-1, s_w / 2, s_h / 2])
            rotate([0, 90, 0]) cylinder(d = push_hole_d, h = s_back_t + 2);

        // Magnettaschen, öffnen zur Innenseite der Rückwand
        for (y = mag_y_list(s_w))
            translate([s_back_t - pocket_h, y, mag_z_sleeve]) magnet_pocket_x();
    }
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
} else if (part == "assembly") {
    color("SteelBlue", 0.6) render(convexity = 10) sleeve();
    color("Orange") render(convexity = 10) drawer_in_sleeve(open_mm);
} else if (part == "interference") {
    intersection() {
        sleeve();
        drawer_in_sleeve(0);
    }
}
