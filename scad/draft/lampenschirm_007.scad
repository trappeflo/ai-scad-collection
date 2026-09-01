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
// Änderungen gegenüber 006 (Nutzer-Feedback: "die markierten Auswüchse
// [Verbindungsstege] sollen ganz weg"):
//   - Keine separaten Verbindungsstege/Rippen mehr. Stattdessen zieht sich
//     die Außenkontur an der Rückseite (θ=270°) selbst eng um den
//     Klemmkragen zusammen (Fourier-Basis neu gefittet: Rückseite jetzt
//     ~14mm statt ~25mm), sodass Kragen und Wand dort direkt ineinander
//     übergehen - keine separate Geometrie, kein sichtbarer "Auswuchs".
//   - Die Wellen-Überlagerung wird über eine weiche Hüllkurve (wave_envelope)
//     in der Nähe der Rückseite ausgeblendet, damit die enge Passage dort
//     nicht durch die Wellen unvorhersehbar eingeschnürt oder aufgerissen
//     wird. Abseits der Rückseite (Seiten/Front) bleibt die volle Wellenform
//     erhalten.
//   - Die Wandberechnung nutzt jetzt keine offset()-Funktion mehr, sondern
//     berechnet die Innenkontur direkt über denselben Radius abzüglich
//     wall_t (organic_outline(shrink=wall_t)). Das ist robuster als
//     offset() bei welligen/konkaven Konturen (siehe Bugs in 003/004) und
//     garantiert gleichzeitig, dass die Innenkontur an der Rückseite den
//     Klemmkragen direkt überlappt (keine Lücke, keine Rippe nötig).

// ---- Parameter ----
shade_height = 180;   // Gesamthöhe des Schirms
wall_t       = 2;     // Wandstärke Schirm (durchgehend, auch am Klemmkragen-Übergang)

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
// front (θ=90°, +Y) ≈ 95mm, Seiten (θ=0°/180°) ≈ 50mm, Rückseite (θ=270°,
// -Y) ≈ 14mm - eng genug, dass die Wand dort direkt in den Klemmkragen
// (clip_r_out = 12.6mm) übergeht.
base_a0 = 52.25;
base_a1 = 40.5;
base_a2 = 2.25;

// Wellen-Überlagerung für den organischen/wellenförmigen Look
wave_amp1 = 9;   wave_freq1 = 4;  wave_phase1 = 40;
wave_amp2 = 5;   wave_freq2 = 7;  wave_phase2 = 115;

// Hüllkurve, die die Welle in der Nähe der Rückseite (θ=270°) ausblendet,
// damit die enge Passage um den Klemmkragen nicht durch die Welle gestört
// wird. Volle Wellenstärke ab wave_fade_width Grad Abstand von der Rückseite.
wave_fade_width = 50;

min_r = clip_r_out + wall_t - 1.2;   // Sicherheitsuntergrenze (Reserve, greift im Normalfall nicht ein)

cut_far = 300;   // "unendlich" großer Radius für Schnitte, die garantiert bis nach außen durchbrechen sollen

$fn = 96;

// Winkelabstand zwischen theta und center (0-180°, robust über den 0°/360°-Übergang)
function angle_diff(theta, center) =
    let(d = abs(theta - center))
    (d > 180) ? 360 - d : d;

// Hüllkurve 0 (direkt an der Rückseite) bis 1 (ab wave_fade_width Grad Abstand)
function wave_envelope(theta) =
    let(d = angle_diff(theta, 270))
    (d >= wave_fade_width) ? 1 : (1 - cos(180 * d / wave_fade_width)) / 2;

// Radius der organischen Kontur in Abhängigkeit vom Winkel θ (Grad)
function organic_r(theta) =
    let(phi = theta - 90)
    let(base = base_a0 + base_a1 * cos(phi) + base_a2 * cos(2 * phi))
    let(raw_wave = wave_amp1 * sin(wave_freq1 * theta + wave_phase1)
                 + wave_amp2 * sin(wave_freq2 * theta + wave_phase2))
    let(wave = raw_wave * wave_envelope(theta))
    max(base + wave, min_r);

// Geschlossenes 2D-Profil der organischen Kontur, um shrink (mm) nach innen
// verkleinert (shrink=0 -> Außenkontur, shrink=wall_t -> Innenkontur).
// Direkte Radius-Berechnung statt offset() - robust bei welliger Kontur.
module organic_outline(shrink = 0) {
    step = 360 / $fn;
    polygon(points = [
        for (t = [0 : step : 360 - step])
            [(organic_r(t) - shrink) * cos(t), (organic_r(t) - shrink) * sin(t)]
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

// Voller Klemmkragen-Rohling (Bohrung/Spalt werden erst in 3D herausgeschnitten).
// Überlappt an der Rückseite direkt mit der Innenkontur der Schirmwand
// (organic_outline(wall_t) hat dort Radius < clip_r_out) - keine zusätzliche
// Verbindungsgeometrie nötig.
module collar_disk_2d() {
    circle(r = clip_r_out);
}

// 2D-Profil der Wand: durchgehend wall_t dick, plus Klemmkragen-Rohling
module shell_with_boss_2d() {
    union() {
        difference() {
            organic_outline(0);
            organic_outline(wall_t);
        }
        collar_disk_2d();
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
