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
// Änderungen gegenüber 003 (Nutzer-Feedback: "Klemme scheint nicht mehr mit
// dem Schirm verbunden zu sein"):
//   - Ursache war ein echter Fehler (nicht nur Vorschau): offset(delta=-wall_t)
//     auf der stark welligen/konkaven Kontur verhielt sich bei den engen
//     Wellentälern unvorhersehbar, wodurch zwischen Klemme und Außenwand ein
//     durchgehender Hohlraum-Ring übrig blieb (bestätigt über CLI-Kompilierung:
//     "Volumes: 3" statt der erwarteten 2 = zwei unverbundene Körper).
//   - Neuer Ansatz: statt die Klemmzone über eine Offset-Subtraktion
//     freizurechnen, wird ein Keil (boss_bridge) direkt aus der Original-
//     Außenkontur (organic_outline, kein offset()) ausgeschnitten und komplett
//     massiv gefüllt. Das garantiert eine feste Verbindung zur Außenwand,
//     unabhängig vom Offset-Verhalten bei starker Welligkeit.

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

min_r = clip_r_out + 6;          // harte Untergrenze: Kontur darf den Klemmkragen nie schneiden
bridge_deg = 140;                // Öffnungswinkel des massiven Verbindungskeils, zentriert auf die Rückseite (270°)

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

// Massiver Verbindungskeil zwischen Klemmkragen und Außenwand: die Original-
// Außenkontur (kein offset()) geschnitten auf einen Sektor um die Rückseite,
// komplett massiv gefüllt von der Mitte bis zur Außenwand. Berührt die
// Außenkontur direkt (garantierte Verbindung) und überdeckt den kompletten
// Klemmkragen (r bis clip_r_out), da bridge_deg > clip_gap_deg.
module boss_bridge_2d() {
    intersection() {
        organic_outline();
        rotate([0, 0, 270])
            pie_wedge_2d(300, bridge_deg);
    }
}

// Voller Klemmkragen-Rohling (Bohrung/Spalt werden erst in 3D herausgeschnitten)
module collar_disk_2d() {
    circle(r = clip_r_out);
}

// 2D-Profil der Wand: normale 2mm-Schale überall + massiver Klemmkragen-
// Rohling + massiver Verbindungskeil zur Rückseite (garantiert verbunden)
module shell_with_boss_2d() {
    union() {
        difference() {
            organic_outline();
            offset(delta = -wall_t)
                organic_outline();
        }
        collar_disk_2d();
        boss_bridge_2d();
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
// Vorschau (F5) korrekt dargestellt wird.
render(convexity = 10)
    difference() {
        organic_shell();
        clamp_cutouts();
    }
