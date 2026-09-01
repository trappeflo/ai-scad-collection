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
// Änderungen gegenüber 007 (Nutzer-Feedback: kleine hässliche Auswüchse an
// der Kontur + auf der rechten Seite ist die Verbindung zur Klemme wieder
// weg):
//   - Ursache: die Fourier-Basis aus 007 (a1=40.5) stieg von der Rückseite
//     aus zu steil an. Schon ab ca. 10-15° neben der Rückseite lag der
//     Basisradius allein schon über dem für die Verbindung nötigen Maximum -
//     die dort noch nicht vollständig gedämpfte Welle konnte die Kontur an
//     manchen Winkeln (z.B. rechts) wieder über diese Grenze drücken, an
//     anderen (z.B. links) durch Zufall nicht. Daraus die sichtbaren
//     Sprünge/Auswüchse UND die fehlende Verbindung auf der rechten Seite.
//   - Fix: Die Basisform nutzt jetzt eine Potenzfunktion (u^2 statt reinem
//     Kosinus) statt einer Fourier-Reihe. Dadurch bleibt der Radius rund um
//     die Rückseite über einen deutlich breiteren Winkelbereich (~±25-30°)
//     nahezu konstant bei back_r, bevor er Richtung Front ansteigt - viel
//     mehr Sicherheitsabstand für die Welle. Die Welle ist zusätzlich
//     schwächer (6mm/3mm statt 9mm/5mm) und wird über eine breitere
//     Hüllkurve nahe der Rückseite gedämpft. Ein zusätzlicher harter
//     Sicherheits-Deckel (max_neck_r) innerhalb eines engen Winkelbereichs
//     verhindert garantiert jedes Überschreiten, egal welche Wellenphase an
//     welchem Winkel zusammentrifft.

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

// Organische Grundform: Potenzfunktion statt Fourier-Reihe, damit die
// Rückseite (θ=270°) über einen breiten Winkelbereich flach bleibt, statt
// steil anzusteigen.
back_r  = 13;     // Zielradius an der Rückseite (θ=270°) - eng am Klemmkragen
front_r = 95;      // Zielradius an der Front (θ=90°)
flatten_power = 2; // höher = flacherer/breiterer "Hals" um die Klemme, aber schmalere Seiten

// Wellen-Überlagerung für den organischen/wellenförmigen Look (Front/Seiten)
wave_amp1 = 6;   wave_freq1 = 4;  wave_phase1 = 40;
wave_amp2 = 3;   wave_freq2 = 7;  wave_phase2 = 115;
wave_fade_width = 55;   // Welle erreicht erst ab diesem Winkelabstand von der Rückseite volle Stärke

// Harter Sicherheits-Deckel: garantiert, dass die Kontur nahe der Rückseite
// den Klemmkragen nie verfehlt, unabhängig von der Wellenphase
neck_guard_width = 20;                     // Winkelbereich, in dem der Deckel aktiv ist
max_neck_r = clip_r_out + wall_t - 0.3;    // = 14.3mm, garantiert Überlappung mit Sicherheitsabstand
min_r      = clip_r_out - 1;               // globale Untergrenze (Reserve, verhindert Radius <= 0 / Bohrung)

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
    let(u = (1 + cos(phi)) / 2)   // 0 an der Rückseite (θ=270°), 1 an der Front (θ=90°)
    let(base = back_r + (front_r - back_r) * pow(u, flatten_power))
    let(raw_wave = wave_amp1 * sin(wave_freq1 * theta + wave_phase1)
                 + wave_amp2 * sin(wave_freq2 * theta + wave_phase2))
    let(wave = raw_wave * wave_envelope(theta))
    let(r_free = base + wave)
    let(d = angle_diff(theta, 270))
    let(r_guarded = (d < neck_guard_width) ? min(r_free, max_neck_r) : r_free)
    max(r_guarded, min_r);

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
// Überlappt an der Rückseite direkt mit der Innenkontur der Schirmwand.
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
