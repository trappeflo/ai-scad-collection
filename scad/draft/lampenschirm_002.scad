// Lampenschirm für Stehlampe – D-förmiger Querschnitt mit Klemmkragen
// Alle Maße in Millimetern (Regel: units-mm)
//
// Kontext: context/printer.md, context/tolerances.md und context/materials.md
// waren zum Zeitpunkt der Modellierung leer (siehe Regel: context-first).
// Folgende Annahmen wurden im Design-Dialog mit dem Nutzer geklärt:
//   - Baubett >= 200mm Z-Höhe vorhanden -> Schirm wird als ein Teil,
//     stehend, in voller Höhe gedruckt.
//   - Klemmkragen als offener Federclip (C-Ring): Innendurchmesser 0.8mm
//     unter Stangendurchmesser (19.2mm ID auf 20mm Stange) für Vorspannung.
//   - E14-Fassung wird separat an der Stange montiert; der Schirm ist reine
//     Abdeckung/Diffusor ohne Kabeldurchführung.
//   - Klemmkragen-Wandstärke bewusst dicker als die 2mm-Schirmwand gewählt
//     (Klemmkraft/Stabilität), da context/tolerances.md keine Vorgabe macht.
//     -> Vor dem Druck gegenrechnen/prüfen (qa-agent / geometry-check).
//
// Änderungen gegenüber 001 (Nutzer-Feedback):
//   - Bohrung für die Stange schneidet jetzt durch die GESAMTE Baugruppe
//     (Schirmwand + Klemmkragen), nicht nur durch den Klemmkragen selbst.
//     Vorher blieb die Rückwand des Schirms mittig in der Klemme stehen,
//     wodurch die Stange nicht eingeklemmt werden konnte.
//   - Zusätzlicher zweiter Schlitz im unteren Drittel der Klemme auf der
//     Innenseite (Richtung Schirm-Innenraum, +Y), damit die Klemme seitlich
//     über die an der Stange montierte E14-Fassung geschoben werden kann.
//     Breite des Schlitzes (socket_slot_deg) ist eine Annahme, da die
//     tatsächlichen Maße der Fassung/Halterung nicht bekannt sind -> vor
//     dem Druck gegen die reale Fassung prüfen.

// ---- Parameter ----
shade_height = 180;   // Gesamthöhe des Schirms
shade_width  = 100;   // Breite entlang der flachen Rückseite (X)
shade_depth  = 120;   // Tiefe von Rückseite bis vorderster Wölbung (Y)
wall_t       = 2;     // Wandstärke Schirm (dünn für Lichtdurchlässigkeit)

rod_d      = 20;                 // Durchmesser der Metallstange
rod_r      = rod_d / 2;
clip_id    = 19.2;               // Innendurchmesser Klemmkragen (Vorspannung, ~0.8mm Untermaß)
clip_r_in  = clip_id / 2;
clip_wall  = 3;                  // Wandstärke Klemmkragen (dicker als Schirmwand, siehe oben)
clip_r_out = clip_r_in + clip_wall;
clip_gap_deg = 40;                    // Öffnungswinkel des C-Rings (Montagespalt, zeigt nach -Y)

socket_slot_deg    = 60;              // Öffnungswinkel des Fassungs-Schlitzes (Innenseite, +Y) - Annahme
socket_slot_height = shade_height / 3; // unteres Drittel der Klemme ist auf der Innenseite offen

$fn = 96;

// D-förmiges 2D-Profil: flache Rückseite bei y=0 (Breite = shade_width),
// halbovale (elliptische) Vorderseite bis y=shade_depth
module shade_outline() {
    intersection() {
        scale([shade_width / 2, shade_depth, 1])
            circle(r = 1);
        translate([-shade_width, 0, 0])
            square([shade_width * 2, shade_depth + 1]);
    }
}

// Dünnwandige Hülle des Schirms, oben und unten offen (kein Deckel/Boden)
module shade_shell() {
    linear_extrude(height = shade_height)
        difference() {
            shade_outline();
            offset(delta = -wall_t)
                shade_outline();
        }
}

// Keilförmiger 2D-Ausschnitt, zentriert auf Winkel 0
module pie_wedge_2d(radius, angle_deg) {
    a = angle_deg / 2;
    polygon(points = [
        [0, 0],
        [radius * cos(a), radius * sin(a)],
        [radius * cos(-a), radius * sin(-a)]
    ]);
}

// Radialer Schlitz von z0 bis z1, in Richtung facing_deg ausgerichtet
module radial_slot(radius, angle_deg, facing_deg, z0, z1) {
    translate([0, 0, z0])
        rotate([0, 0, facing_deg])
            linear_extrude(z1 - z0)
                pie_wedge_2d(radius, angle_deg);
}

// Alle Ausschnitte für die Klemme: durchgehende Stangenbohrung + Montagespalt
// (volle Höhe, -Y) + Fassungs-Schlitz (unteres Drittel, +Y). Wird von der
// GESAMTEN Baugruppe (Schirmwand + Klemmkragen-Rohling) subtrahiert, damit
// auch die Schirm-Rückwand im Bohrungsbereich mit entfernt wird.
module clamp_cutouts() {
    union() {
        translate([0, 0, -1])
            cylinder(r = clip_r_in, h = shade_height + 2);

        radial_slot(clip_r_out + 5, clip_gap_deg, 270, -1, shade_height + 1);

        radial_slot(clip_r_out + 5, socket_slot_deg, 90, -1, socket_slot_height + 1);
    }
}

// render() erzwingt hier die vollständige (exakte) Boolesche Berechnung statt
// der schnellen OpenCSG-Live-Vorschau. Ohne render() kann die verschachtelte
// difference()/union()-Struktur in der OpenSCAD-Vorschau (F5) fehlerhaft
// aussehen (Z-Fighting/scheinbar "kaputte" geschlossene Klemme), obwohl die
// tatsächlich berechnete Geometrie (F6 bzw. STL-Export) bereits korrekt ist.
render(convexity = 10)
    difference() {
        union() {
            shade_shell();
            cylinder(r = clip_r_out, h = shade_height); // Klemmkragen-Rohling, zentriert auf der Rückseite (x=0, y=0)
        }
        clamp_cutouts();
    }
