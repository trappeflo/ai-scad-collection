// Lampenschirm für Stehlampe – organischer, wellenförmiger Querschnitt
// mit Klemmkragen, der in die Form integriert ist (keine D-Form mehr)
// Alle Maße in Millimetern (Regel: units-mm)
//
// Kontext: context/printer.md, context/tolerances.md und context/materials.md
// waren zum Zeitpunkt der Modellierung leer (siehe Regel: context-first).
// Annahmen aus dem Design-Dialog (siehe auch 001/002):
//   - Baubett >= 200mm Z-Höhe vorhanden -> Schirm wird als ein Teil,
//     stehend, in voller Höhe gedruckt.
//   - Klemmkragen als offener Federclip (C-Ring): Innendurchmesser 0.8mm
//     unter Stangendurchmesser (19.2mm ID auf 20mm Stange) für Vorspannung.
//   - E14-Fassung wird separat an der Stange montiert.
//
// Änderungen gegenüber 005 (Nutzer-Feedback: "Verbindung zwischen Klemme und
// Wand sieht wulstig/hässlich aus, soll dieselbe Wandstärke wie sonst haben"):
//   - Der massive Verbindungskeil (boss_bridge_2d, voller Sektor von 140°) ist
//     ersetzt durch zwei schlanke Stege (bridge_ribs_2d), jeweils exakt
//     wall_t (2mm) dick - gebaut über hull() von zwei Kreisen (Kapsel-Technik),
//     dadurch garantiert konstante Wandstärke unabhängig von der Wellenform.
//   - Die Stege sitzen bei ±55° neben dem Montagespalt (Winkel 215°/325°,
//     Spalt selbst bleibt bei 250°-290° frei) und verbinden den Klemmkragen
//     direkt mit der Innenseite der normalen Schirmwand an der jeweiligen
//     Stelle.

// ---- Parameter ----
shade_height = 180;   // Gesamthöhe des Schirms
wall_t       = 2;     // Wandstärke Schirm (dünn für Lichtdurchlässigkeit) - gilt jetzt auch für die Klemm-Stege

rod_d      = 20;                 // Durchmesser der Metallstange
rod_r      = rod_d / 2;
clip_id    = 19.2;               // Innendurchmesser Klemmkragen (Vorspannung, ~0.8mm Untermaß)
clip_r_in  = clip_id / 2;
clip_wall  = 3;                  // Wandstärke Klemmkragen (dicker als Schirmwand, für Klemmkraft)
clip_r_out = clip_r_in + clip_wall;
clip_gap_deg = 40;               // Öffnungswinkel des C-Rings (Montagespalt, zeigt nach -Y)

socket_slot_deg    = 60;              // Öffnungswinkel des Fassungs-Schlitzes (Innenseite, +Y) - Annahme
socket_slot_height = shade_height / 3; // unteres Drittel der Klemme ist auf der Innenseite offen

// Organische Grundform (Fourier-Basis, Radius in mm ab Stangenmitte):
// front (θ=90°, +Y) ≈ 95mm, Seiten (θ=0°/180°) ≈ 50mm, Rückseite (θ=270°, -Y) ≈ 25mm
base_a0 = 55;
base_a1 = 35;
base_a2 = 5;

// Wellen-Überlagerung für den organischen/wellenförmigen Look
wave_amp1 = 9;   wave_freq1 = 4;  wave_phase1 = 40;
wave_amp2 = 5;   wave_freq2 = 7;  wave_phase2 = 115;

min_r = clip_r_out + 6;          // harte Untergrenze: Kontur darf den Klemmkragen nie schneiden
cut_far = 300;                   // "unendlich" großer Radius für Schnitte, die garantiert bis nach außen durchbrechen sollen

rib_angles = [215, 325];         // Winkel der Verbindungsstege (neben dem Montagespalt bei 250°-290°)

$fn = 96;

// Radius der organischen Kontur in Abhängigkeit vom Winkel θ (Grad)
function organic_r(theta) =
    let(phi = theta - 90)
    let(base = base_a0 + base_a1 * cos(phi) + base_a2 * cos(2 * phi))
    let(wave = wave_amp1 * sin(wave_freq1 * theta + wave_phase1)
             + wave_amp2 * sin(wave_freq2 * theta + wave_phase2))
    max(base + wave, min_r);

// Geschlossenes 2D-Profil der organischen Außenkontur
module organic_outline() {
    step = 360 / $fn;
    polygon(points = [
        for (t = [0 : step : 360 - step])
            [organic_r(t) * cos(t), organic_r(t) * sin(t)]
    ]);
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

// Ein schlanker Verbindungssteg (konstante Breite wall_t) vom Klemmkragen
// (r=clip_r_out) radial nach außen bis zur Innenseite der Schirmwand, an
// einem festen Winkel. hull() zweier Kreise ergibt eine "Kapsel" mit exakt
// konstanter Breite - unabhängig von offset()/Wellenform.
module rib_2d(angle_deg) {
    r_outer = organic_r(angle_deg) - wall_t / 2;
    p1 = [clip_r_out * cos(angle_deg), clip_r_out * sin(angle_deg)];
    p2 = [r_outer * cos(angle_deg), r_outer * sin(angle_deg)];
    hull() {
        translate(p1) circle(r = wall_t / 2);
        translate(p2) circle(r = wall_t / 2);
    }
}

module bridge_ribs_2d() {
    union()
        for (a = rib_angles)
            rib_2d(a);
}

// Voller Klemmkragen-Rohling (Bohrung/Spalt werden erst in 3D herausgeschnitten)
module collar_disk_2d() {
    circle(r = clip_r_out);
}

// 2D-Profil der Wand: normale 2mm-Schale überall + Klemmkragen-Rohling +
// zwei schlanke 2mm-Stege, die den Kragen mit der Wand verbinden
module shell_with_boss_2d() {
    union() {
        difference() {
            organic_outline();
            offset(delta = -wall_t)
                organic_outline();
        }
        collar_disk_2d();
        bridge_ribs_2d();
    }
}

module organic_shell() {
    linear_extrude(height = shade_height)
        shell_with_boss_2d();
}

// Radialer Schlitz von z0 bis z1, in Richtung facing_deg ausgerichtet
module radial_slot(radius, angle_deg, facing_deg, z0, z1) {
    translate([0, 0, z0])
        rotate([0, 0, facing_deg])
            linear_extrude(z1 - z0)
                pie_wedge_2d(radius, angle_deg);
}

// Alle Ausschnitte für die Klemme: durchgehende Stangenbohrung + Montagespalt
// (volle Höhe, -Y, bricht bis zur echten Außenwand durch, damit seitlich
// eingeclipst werden kann) + Fassungs-Schlitz (unteres Drittel, +Y, öffnet
// nur bis in den ohnehin dort schon hohlen Innenraum)
module clamp_cutouts() {
    union() {
        translate([0, 0, -1])
            cylinder(r = clip_r_in, h = shade_height + 2);

        radial_slot(cut_far, clip_gap_deg, 270, -1, shade_height + 1);

        radial_slot(clip_r_out + 5, socket_slot_deg, 90, -1, socket_slot_height + 1);
    }
}

// render() erzwingt die vollständige (exakte) Boolesche Berechnung statt der
// schnellen OpenCSG-Live-Vorschau, damit die Klemme auch in der OpenSCAD-
// Vorschau (F5) korrekt dargestellt wird.
render(convexity = 10)
    difference() {
        organic_shell();
        clamp_cutouts();
    }
