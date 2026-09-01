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
clip_gap_deg = 40;               // Öffnungswinkel des C-Rings (Montagespalt, zeigt nach hinten/-Y)

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

// Keilförmiger Ausschnitt für die Öffnung des C-Rings, zentriert auf Winkel 0
module pie_cut(radius, angle_deg, height) {
    a = angle_deg / 2;
    translate([0, 0, -height / 2])
        linear_extrude(height)
            polygon(points = [
                [0, 0],
                [radius * cos(a), radius * sin(a)],
                [radius * cos(-a), radius * sin(-a)]
            ]);
}

// Klemmkragen: offener C-Ring über volle Schirmhöhe, zentriert auf der
// flachen Rückseite (x=0, y=0), Öffnung zeigt nach -Y (von der Stange weg
// nach außen, damit die Stange seitlich eingeclipst werden kann)
module clamp_collar() {
    difference() {
        cylinder(r = clip_r_out, h = shade_height);
        translate([0, 0, -1])
            cylinder(r = clip_r_in, h = shade_height + 2);
        translate([0, 0, shade_height / 2])
            rotate([0, 0, 270])
                pie_cut(clip_r_out + 5, clip_gap_deg, shade_height + 2);
    }
}

union() {
    shade_shell();
    clamp_collar();
}
