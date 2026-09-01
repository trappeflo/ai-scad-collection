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
// Änderungen gegenüber 002 (Nutzer-Feedback: "weg von der D-Form, organischer"):
//   - Der Querschnitt ist jetzt eine glatte, asymmetrische, wellenförmige
//     Freiform-Kurve (Fourier-Basisform + zwei Wellen-Harmonische) statt
//     flacher Rückseite + halbovaler Front. Bleibt weiterhin als konstanter
//     Querschnitt über die volle Höhe extrudiert (keine Verjüngung).
//   - Die Rückseite hat keine scharfe Kante mehr: die Kontur läuft glatt um
//     den Klemmkragen herum. Der Kragen ist dadurch kein aufgesetzter
//     Zylinder mehr, sondern eine massive "Boss"-Zone innerhalb der
//     ohnehin an dieser Stelle dickeren organischen Wand.
//   - Sicherheitsabstand (min_r / boss_r) stellt rechnerisch sicher, dass
//     die Wellenkontur den Klemmkragen nie schneidet, auch nicht an den
//     tiefsten Punkten der Welle.

// ---- Parameter ----
shade_height = 180;   // Gesamthöhe des Schirms
wall_t       = 2;     // Wandstärke Schirm (dünn für Lichtdurchlässigkeit)

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

min_r = clip_r_out + 6;   // harte Untergrenze: Kontur darf den Klemmkragen nie schneiden
boss_r = clip_r_out + 2;  // Radius der massiven Zone um den Klemmkragen (liegt sicher innerhalb min_r - wall_t)

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

// 2D-Profil der Wand: normale 2mm-Schale überall, aber massiv (kein Hohlraum)
// in der boss_r-Zone um den Klemmkragen, damit dieser fest mit der Wand
// verbunden ist statt frei im Hohlraum zu schweben.
module shell_with_boss_2d() {
    difference() {
        organic_outline();
        difference() {
            offset(delta = -wall_t)
                organic_outline();
            circle(r = boss_r);
        }
    }
}

module organic_shell() {
    linear_extrude(height = shade_height)
        shell_with_boss_2d();
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
// (volle Höhe, -Y) + Fassungs-Schlitz (unteres Drittel, +Y)
module clamp_cutouts() {
    union() {
        translate([0, 0, -1])
            cylinder(r = clip_r_in, h = shade_height + 2);

        radial_slot(clip_r_out + 5, clip_gap_deg, 270, -1, shade_height + 1);

        radial_slot(clip_r_out + 5, socket_slot_deg, 90, -1, socket_slot_height + 1);
    }
}

// render() erzwingt die vollständige (exakte) Boolesche Berechnung statt der
// schnellen OpenCSG-Live-Vorschau, damit die Klemme auch in der OpenSCAD-
// Vorschau (F5) korrekt offen dargestellt wird.
render(convexity = 10)
    difference() {
        organic_shell();
        clamp_cutouts();
    }
