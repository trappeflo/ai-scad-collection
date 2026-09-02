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
// Änderungen gegenüber 012 (Nutzer-Feedback: "Auswüchse an der Klemme immer
// noch da"):
//   - Erster Versuch (harte Untergrenze neck_floor, weich von min_r bis
//     safe_floor_far über floor_relax_width=90°) verhinderte zwar neue
//     ungeschützte VERBINDUNGEN zum Klemmenradius, behob aber NICHT das
//     eigentliche visuelle Problem: die "Flügel" waren gar kein entartetes
//     Polygon (kein Selbstschnitt, kein Hohlraum in der Nahaufnahme) -
//     sondern ein echter, glatter, aber stark UNPROPORTIONALER lokaler
//     Wellen-Peak direkt neben dem 13mm engen Hals (z.B. Radius 23mm bei
//     nur 50° Abstand), der optisch wie ein Auswuchs wirkt, weil die feste
//     Wellenamplitude (±15mm) dort schon fast voll durchschlug, während die
//     Grundform selbst erst ~15mm groß war.
//   - Fix: die Wellenamplitude skaliert jetzt PROPORTIONAL zur lokalen
//     Grundform-Größe (wave_scale = base(θ)/front_r) statt nur über eine
//     feste Winkel-Hüllkurve gedämpft zu werden. Dadurch ist die Welle nahe
//     des engen Halses von selbst winzig (13/95 ≈ 14% der vollen Amplitude)
//     und wächst erst mit der Kontur selbst auf volle Stärke - keine
//     Sonderbehandlung für einen bestimmten Winkelbereich nötig, das
//     Verhältnis Welle:Grundform bleibt überall ähnlich. neck_cap/neck_floor
//     bleiben zusätzlich als Sicherheitsnetz erhalten (siehe Regel
//     `verify-parametric-geometry`).
//   - Per Sweep verifiziert: "verbundene" Winkel (organic_r <= clip_r_out+
//     wall_t) kommen jetzt nur noch in EINER einzigen Zone um die Rückseite
//     vor, keine unproportionalen Spitzen mehr in der Nahaufnahme.

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

// Wellen-Überlagerung für den organischen/wellenförmigen Look (Front/Seiten).
// Amplitude wird in organic_r() proportional zur lokalen Grundform-Größe
// skaliert (wave_scale = base/front_r) statt über eine feste Winkel-
// Hüllkurve gedämpft - dadurch bleibt das Verhältnis Welle:Kontur überall
// ähnlich, keine unproportionalen Spitzen nahe des engen Halses.
wave_amp1 = 10;  wave_freq1 = 5;  wave_phase1 = 40;
wave_amp2 = 5;   wave_freq2 = 8;  wave_phase2 = 115;

// Sicherheitsgrenzen nahe der Rückseite: sowohl Deckel (neck_cap, verhindert
// zu großen Radius) als auch Untergrenze (neck_floor, verhindert zu kleinen
// Radius außerhalb der Rückseiten-Zone) wachsen WEICH statt hart abzu-
// schneiden. neck_cap braucht nur bis neck_guard_width Wirkung (die Basis-
// form selbst wächst dort schon steil genug), neck_floor muss deutlich
// weiter wirken (floor_relax_width), weil die Grundform erst dort von sich
// aus groß genug ist, um der vollen Wellenamplitude sicher zu widerstehen.
neck_guard_width  = 40;                    // Breite für den oberen Deckel (neck_cap)
floor_relax_width = 90;                    // Breite für die Untergrenze (neck_floor) - per Sweep ermittelt
max_neck_r    = clip_r_out + wall_t - 0.3; // = 14.3mm, garantiert Überlappung mit Sicherheitsabstand
min_r         = 13.0;                       // Untergrenze an der Rückseite selbst, IMMER > clip_r_out
safe_floor_far = clip_r_out + wall_t + 3;  // = 17.6mm, sicherer Abstand zum Klemmenradius abseits der Rückseite
cap_relax_far  = 1000;                      // "praktisch unbegrenzt" für den ausgelaufenen Deckel

cut_far = 300;   // "unendlich" großer Radius für Schnitte, die garantiert bis nach außen durchbrechen sollen

$fn = 96;

// Winkelabstand zwischen theta und center (0-180°, robust über den 0°/360°-Übergang)
function angle_diff(theta, center) =
    let(d = abs(theta - center))
    (d > 180) ? 360 - d : d;

// Weicher Übergang 0->1 zwischen edge0 und edge1 (klassisches smoothstep)
function smoothstep(edge0, edge1, x) =
    let(t = min(max((x - edge0) / (edge1 - edge0), 0), 1))
    t * t * (3 - 2 * t);

// Deckel (Obergrenze) nahe der Rückseite: startet bei max_neck_r (d=0) und
// wächst weich auf cap_relax_far (d>=neck_guard_width) - verhindert einen zu
// GROSSEN Radius direkt an der Klemme, unabhängig von der Wellenamplitude.
function neck_cap(d) =
    max_neck_r + (cap_relax_far - max_neck_r) * smoothstep(0, neck_guard_width, d);

// Untergrenze abseits der Rückseite: startet bei min_r (d=0, erlaubt die
// beabsichtigte enge Passage) und wächst weich auf safe_floor_far
// (d>=floor_relax_width) - verhindert, dass die freie Welle die Kontur an
// UNBEABSICHTIGTEN Winkeln nah genug an den Klemmenradius zieht, um dort
// eine ungeschützte (Artefakt-anfällige) Kreuzung zu erzeugen.
function neck_floor(d) =
    min_r + (safe_floor_far - min_r) * smoothstep(0, floor_relax_width, d);

// Radius der organischen Außenkontur in Abhängigkeit vom Winkel θ (Grad)
function organic_r(theta) =
    let(phi = theta - 90)
    let(u = (1 + cos(phi)) / 2)   // 0 an der Rückseite (θ=270°), 1 an der Front (θ=90°)
    let(base = back_r + (front_r - back_r) * pow(u, flatten_power))
    let(raw_wave = wave_amp1 * sin(wave_freq1 * theta + wave_phase1)
                 + wave_amp2 * sin(wave_freq2 * theta + wave_phase2))
    let(wave_scale = base / front_r)   // proportional zur lokalen Kontur-Größe
    let(wave = raw_wave * wave_scale)
    let(r_free = base + wave)
    let(d = angle_diff(theta, 270))
    let(r_capped = min(r_free, neck_cap(d)))
    max(r_capped, neck_floor(d));

// Radius der Kavität (Hohlraum-Grenze): normale Wandinnenseite, aber nie
// enger als der Klemmkragen (clip_r_out) - dadurch bleibt der Kragen überall
// solide statt hohl, ganz ohne separate Kreis-Verschneidung.
function cavity_r(theta) =
    max(organic_r(theta) - wall_t, clip_r_out);

// Geschlossenes 2D-Profil, um shrink (mm) nach innen verkleinert
module organic_outline(shrink = 0) {
    step = 360 / $fn;
    polygon(points = [
        for (t = [0 : step : 360 - step])
            [(organic_r(t) - shrink) * cos(t), (organic_r(t) - shrink) * sin(t)]
    ]);
}

// Ringform (Annulus): gefüllte Fläche bis cavity_r(θ) MINUS Kreis(clip_r_out).
// Wichtig: eine reine gefüllte Fläche bis cavity_r(θ) wäre FALSCH - da
// cavity_r(θ) an Winkeln fern der Rückseite sehr groß wird (z.B. ~93mm an
// der Front), würde eine gefüllte Fläche dort den kompletten Klemmkragen
// mit-entfernen. Der Kreisabzug stellt sicher, dass r < clip_r_out IMMER
// massiv bleibt, unabhängig vom Winkel.
module cavity_outline() {
    step = 360 / $fn;
    difference() {
        polygon(points = [
            for (t = [0 : step : 360 - step])
                [cavity_r(t) * cos(t), cavity_r(t) * sin(t)]
        ]);
        circle(r = clip_r_out);
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

// 2D-Profil der Wand: durchgehend wall_t dick, mit massivem, nahtlos
// integriertem Klemmkragen-Rohling an der Rückseite
module shell_with_boss_2d() {
    difference() {
        organic_outline(0);
        cavity_outline();
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
