// Brillenetui (Klappetui) – Unterschale + Deckel mit Stift-Scharnier,
// Magnetverschluss vorne, separate TPU-Einlegeschalen gegen Kratzer
// Alle Maße in Millimetern (Regel: units-mm)
//
// Kontext (Regel: context-first):
//   - context/printer.md:    Anycubic Kobra S1, 0.4mm Düse, PEI, 250mm Bauraum
//   - context/tolerances.md: kurze bewegliche Passungen 0.2–0.25/Seite,
//                            Presspassung 0.05–0.15/Seite, flache Einlage in
//                            niedrigem Rand: 0.3 zu stramm / 0.5 zu locker
//   - context/materials.md:  nur PLA-Annahmen. PETG und TPU sind NICHT
//                            dokumentiert -> Toleranzen für TPU-Inlay und
//                            Stiftbohrungen sind ungetestet (fit_test drucken!)
//
// Anforderungen (Design-Gespräch):
//   - Brille zusammengeklappt: "typische Werte" 145 x 45 x 38 mm (Parameter,
//     bitte nachmessen: Länge Scharnier-Scharnier x Glashöhe x dickste Stelle)
//   - Schale PLA oder PETG, separates TPU-Inlay (Einlegeteil)
//   - Verschluss: Klappdeckel mit Scharnier, Stifte 3 x 30 mm Edelstahl
//   - Einsatz: Tasche/Rucksack -> darf nicht von selbst aufgehen,
//     Deckel darf nicht seitlich verrutschen
//
// Aufbau:
//   - Zwei Scharniere hinten, je 30mm lang (= Stiftlänge, Stift bündig).
//     Außen 2 Gelenkaugen an der Unterschale (Stift sitzt per Presspassung),
//     mittig 1 Auge am Deckel (Stift dreht frei). Stift von der Seite
//     einpressen (Schraubstock).
//   - Umlaufende Lippe an der Unterschale greift in eine Stufe im Deckel ->
//     kein seitliches Verrutschen, steifer gegen Druck in der Tasche.
//   - Verschlusslasche vorne mit 2 Magnetpaaren 6x2mm. Die Deckellasche steht
//     1.5mm weiter vor -> mit dem Daumen anheben.
//   - Offen liegen beide Hälften flach (gleiche Außenhöhe, 180° frei).
//
// Koordinaten (geschlossen): X = Länge, Y = Tiefe (y=0 vorne/Verschluss,
// y=W hinten/Scharnier), Z = Höhe. Trennebene bei z = z_p.
//
// Druckausrichtung (part = "print"), alles ohne Stützen:
//   - Unterschale: auf dem Boden, offen nach oben. Gelenkaugen und Lasche
//     sind unten mit 45° abgestützt, Bohrungen liegen waagerecht (Ø3–3.6 Brücke).
//   - Deckel: auf der Oberseite (umgedreht), offen nach oben. Ebenso.
//   - TPU-Schalen: auf dem Boden, offen nach oben.
//
// Magnete einkleben: POLUNG BEACHTEN (jedes Paar muss sich anziehen).
// Tasche ist 0.1mm tiefer als der Magnet -> Magnet steht nicht über.

/* [Brille (zusammengeklappt)] */
// Länge (Scharnier zu Scharnier)
glasses_l = 145;  // [100:0.5:200]
// Höhe der Gläser (liegt in Etui-Tiefe Y)
glasses_w = 45;   // [25:0.5:80]
// Dicke zusammengeklappt (Bügel + Nasenpads, liegt in Etui-Höhe Z)
glasses_d = 38;   // [15:0.5:60]

/* [Ausgabe] */
// print = Schale + Deckel, base/lid/inlay_base/inlay_lid = Einzelteile,
// fit_test = Bohrungstest für die Stifte, assembly = zusammengebaut,
// interference = Kollisionsprüfung über den Öffnungswinkel (muss leer sein)
part = "print";   // [print, base, lid, inlay_base, inlay_lid, fit_test, assembly, interference]
// Nur für assembly: Öffnungswinkel des Deckels (°)
open_angle = 100; // [0:5:180]

/* [Hidden] */

// ---- Luft um die Brille (innerhalb der TPU-Schalen) ----
air_xy = 1.5;   // pro Seite
air_z  = 1.0;   // gesamt oben

// ---- TPU-Inlay ----
inlay_t     = 1.2;  // Wand + Boden (3 Linien à 0.4)
inlay_clear = 0.3;  // Spiel pro Seite zur Schale (TPU ist nachgiebig; UNGETESTET)
inlay_gap_z = 0.2;  // Abstand zwischen den beiden Inlay-Rändern (geschlossen)

// ---- Schale ----
wall_t     = 2.8;   // Wand gesamt = Lippe + Spiel + Deckelhaut
floor_t    = 2.0;   // Boden Unterschale / Decke Deckel
lip_t      = 1.2;   // Lippe (Unterschale, innen)
lip_clear  = 0.4;   // Spiel Lippe <-> Deckelhaut pro Seite (niedriger langer Rand, vgl. Pin-Sockel)
skin_t     = wall_t - lip_t - lip_clear;  // Deckelhaut über der Lippe
lip_h      = 2.0;   // Lippenhöhe über der Trennebene
lip_clear_z = 0.3;  // Lippe stößt nicht an -> Magnete liegen sicher an
corner_r   = 10;    // Eckradius im Grundriss (außen)
edge_c     = 1.5;   // 45°-Fase an Boden-/Deckelkante (auch gegen Elefantenfuß)

// ---- Scharnier ----
pin_d      = 3.0;   // Edelstahlstift
pin_l      = 30;    // Stiftlänge = Scharnierlänge
bore_press = 3.2;   // Unterschale: 0.1/Seite Presspassung (tolerances.md) – fit_test!
bore_free  = 3.6;   // Deckel: 0.3/Seite, dreht frei (waagerechte Bohrung sackt oben etwas)
knuckle_r  = 3.5;   // Außenradius Gelenkauge
hinge_gap  = 0.4;   // Abstand Gelenkauge <-> Rückwand (Freigang beim Drehen)
knuckle_gap = 0.4;  // axialer Spalt zwischen den Augen (0.2–0.25 beweglich + Reserve)
knuckle_base_l = 8; // Länge je äußeres Auge (Presssitz)
hinge_edge = 10;    // Abstand Scharnier zum Beginn der Eckrundung
hinge_relief = 0.3; // Stützkeil endet so weit unter/über der Trennebene

// ---- Magnetverschluss ----
mag_d       = 6;
mag_h       = 2;
mag_clear   = 0.15; // Radialspiel zum Einkleben
mag_depth_extra = 0.1;
mag_spacing = 16;   // Abstand der beiden Magnete (X)
mag_reach   = 0.4;  // Tasche reicht so weit in die Wand hinein (y > 0)
tab_web     = 1.2;  // Material vor der Magnettasche
tab_flat    = 3.5;  // senkrechter Teil der Lasche (Tasche 2.1 + 1.4 Boden)
tab_r       = 3;    // Eckradius der Lasche
grip_extra  = 1.5;  // Deckellasche steht weiter vor (Daumengriff)

// ---- Passungstest ----
fit_bores = [3.1, 3.2, 3.3, 3.5, 3.6, 3.7];

nozzle = 0.4;
build  = 250;
$fn = 64;

// ---- Abgeleitete Maße ----
ic = inlay_clear;
space_l = glasses_l + 2 * air_xy;   // Brillenraum innen (in den TPU-Schalen)
space_w = glasses_w + 2 * air_xy;
space_h = glasses_d + air_z;

cav_l = space_l + 2 * (inlay_t + ic);   // Hohlraum der Schale
cav_w = space_w + 2 * (inlay_t + ic);
cav_h = space_h + 2 * inlay_t + inlay_gap_z;

L = cav_l + 2 * wall_t;                 // Außenmaße (ohne Lasche/Scharnier)
W = cav_w + 2 * wall_t;
H = cav_h + 2 * floor_t;
z_p = H / 2;                            // Trennebene: beide Hälften gleich hoch

y_a = W + hinge_gap + knuckle_r;        // Scharnierachse (Y), z = z_p
gusset = hinge_gap + knuckle_r + sqrt(2) * knuckle_r + hinge_relief; // 45°-Stützkeil
knuckle_lid_l = pin_l - 2 * knuckle_base_l - 2 * knuckle_gap;
hinge_x = [corner_r + hinge_edge, L - corner_r - hinge_edge - pin_l];

pocket_d = mag_d + 2 * mag_clear;
pocket_h = mag_h + mag_depth_extra;
mag_y    = mag_reach - pocket_d / 2;                 // Taschenmitte (Y)
tab_p    = -(mag_y - pocket_d / 2 - tab_web);        // Überstand Unterschalen-Lasche
tab_p_lid = tab_p + grip_extra;
tab_w    = mag_spacing + pocket_d + 2 * 3;
mag_x    = [L / 2 - mag_spacing / 2, L / 2 + mag_spacing / 2];

inlay_base_h = z_p + lip_h - floor_t;                       // bis Oberkante Lippe
inlay_lid_h  = H - floor_t - (z_p + lip_h) - inlay_gap_z;

// ---- Prüfungen (Restwandstärken >= 2x Düse) ----
min_w = 2 * nozzle - 1e-6;  // 1e-6: Gleitkomma-Rundung
assert(skin_t >= min_w, str("Deckelhaut zu dünn: ", skin_t));
assert(lip_t >= min_w, str("Lippe zu dünn: ", lip_t));
assert(inlay_t >= min_w, str("Inlay zu dünn: ", inlay_t));
assert(knuckle_r - bore_free / 2 >= min_w, "Gelenkauge Deckel zu dünn");
assert(knuckle_lid_l >= 8, str("Mittleres Gelenkauge zu kurz: ", knuckle_lid_l));
// Magnettasche Deckel: Steg zur Lippen-Aussparung (beginnt bei y = skin_t)
assert(skin_t - mag_reach >= min_w, str("Steg Magnettasche/Aussparung: ", skin_t - mag_reach));
assert(tab_flat - pocket_h >= min_w, "Boden unter Magnettasche zu dünn");
assert(z_p - tab_flat - tab_p_lid > edge_c, "Lasche zu hoch für die Etuihöhe");
assert(z_p - gusset > edge_c, "Scharnier-Stützkeil zu hoch für die Etuihöhe");
assert(hinge_x[1] - hinge_x[0] >= pin_l + 10, "Etui zu kurz für zwei Scharniere");
assert(tab_w <= L - 2 * corner_r, "Lasche breiter als die gerade Front");
assert(L <= build && W + tab_p_lid + 2 * knuckle_r <= build, "Größer als Bauraum");

echo(str("Etui außen (L x B x H): ", L, " x ", W, " x ", H,
         " mm, mit Lasche + Scharnier: B = ", tab_p_lid + y_a + knuckle_r, " mm"));
echo(str("Brillenraum innen (in den TPU-Schalen): ", space_l, " x ", space_w, " x ", space_h, " mm"));
echo(str("Hälften je ", z_p, " mm hoch, Lippe ", lip_h, " mm, Deckelhaut ", skin_t, " mm"));
echo(str("Inlay Schale ", inlay_base_h, " mm hoch, Inlay Deckel ", inlay_lid_h, " mm hoch"));
echo(str("Scharniere bei x = ", hinge_x, ", Augen ", knuckle_base_l, " / ", knuckle_lid_l,
         " / ", knuckle_base_l, " mm"));

// ---- 2D-Formen ----

module rounded_rect(l, w, r) {
    translate([r, r]) offset(r = r) square([l - 2 * r, w - 2 * r]);
}

// Grundriss, um d nach innen versetzt (konzentrische Radien)
module inset2d(d) {
    translate([d, d]) rounded_rect(L - 2 * d, W - 2 * d, corner_r - d);
}

// Außenkörper von z=0 bis h, untere Kante 45° gefast
module shell_body(h) {
    hull() {
        linear_extrude(0.01) inset2d(edge_c);
        translate([0, 0, edge_c]) linear_extrude(h - edge_c) inset2d(0);
    }
}

// ---- Verschlusslasche ----
// s = -1: Unterschale (unter der Ebene), s = +1: Deckel (über der Ebene)
module tab(p, s) {
    x0 = L / 2 - tab_w / 2;
    hull() {
        // senkrechter Teil
        translate([0, 0, s < 0 ? z_p - tab_flat : z_p]) linear_extrude(tab_flat) hull() {
            for (x = [x0 + tab_r, x0 + tab_w - tab_r])
                translate([x, -p + tab_r]) circle(r = tab_r);
            translate([x0, 0]) square([tab_w, 0.5]);
        }
        // 45°-Anlauf zur Wand (druckbar ohne Stützen)
        translate([x0 + tab_r, 0, z_p + s * (tab_flat + p) - (s < 0 ? 0 : 0.01)])
            cube([tab_w - 2 * tab_r, 0.5, 0.01]);
    }
}

// ---- Gelenkauge ----
// s = -1: Unterschale, s = +1: Deckel. Keil mit 45° zur Rückwand.
module knuckle(x0, len, s) {
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(len) {
        hull() {
            translate([y_a, z_p]) circle(r = knuckle_r);
            translate([W, s < 0 ? z_p - gusset : z_p + hinge_relief])
                square([0.01, gusset - hinge_relief]);
        }
        // Überlappung in die Wand (für sauberes union)
        translate([W - 0.5, s < 0 ? z_p - gusset : z_p + hinge_relief])
            square([0.51, gusset - hinge_relief]);
    }
}

module pin_bore(d) {
    for (hx = hinge_x)
        translate([hx - 1, y_a, z_p]) rotate([0, 90, 0]) cylinder(d = d, h = pin_l + 2);
}

// ---- Teile (in geschlossener Lage) ----

module base() {
    difference() {
        union() {
            shell_body(z_p);
            // Lippe
            translate([0, 0, z_p - 0.01]) linear_extrude(lip_h + 0.01)
                difference() { inset2d(skin_t + lip_clear); inset2d(wall_t); }
            tab(tab_p, -1);
            for (hx = hinge_x) {
                knuckle(hx, knuckle_base_l, -1);
                knuckle(hx + pin_l - knuckle_base_l, knuckle_base_l, -1);
            }
        }
        translate([0, 0, floor_t]) linear_extrude(H) inset2d(wall_t);
        for (x = mag_x) translate([x, mag_y, z_p - pocket_h]) cylinder(d = pocket_d, h = pocket_h + 1);
        pin_bore(bore_press);
    }
}

module lid() {
    difference() {
        union() {
            translate([0, 0, H]) mirror([0, 0, 1]) shell_body(H - z_p);
            tab(tab_p_lid, +1);
            for (hx = hinge_x)
                knuckle(hx + knuckle_base_l + knuckle_gap, knuckle_lid_l, +1);
        }
        translate([0, 0, z_p - 1]) linear_extrude(H - floor_t - z_p + 1) inset2d(wall_t);
        // Aussparung für die Lippe
        translate([0, 0, z_p - 1]) linear_extrude(lip_h + lip_clear_z + 1) inset2d(skin_t);
        for (x = mag_x) translate([x, mag_y, z_p - 1]) cylinder(d = pocket_d, h = pocket_h + 1);
        pin_bore(bore_free);
    }
}

// TPU-Schale, offen nach oben, Boden bei z=0
module inlay(h) {
    difference() {
        translate([-(wall_t + ic), -(wall_t + ic), 0]) linear_extrude(h) inset2d(wall_t + ic);
        translate([-(wall_t + ic), -(wall_t + ic), inlay_t]) linear_extrude(h) inset2d(wall_t + ic + inlay_t);
    }
}

module inlay_base_placed() {
    translate([wall_t + ic, wall_t + ic, floor_t]) inlay(inlay_base_h);
}
module inlay_lid_placed() {
    translate([wall_t + ic, wall_t + ic, H - floor_t]) mirror([0, 0, 1]) inlay(inlay_lid_h);
}

module lid_open(a) {
    translate([0, y_a, z_p]) rotate([-a, 0, 0]) translate([0, -y_a, -z_p]) children();
}

// ---- Passungstest: waagerechte Bohrungen wie in den Gelenkaugen ----
module fit_test() {
    pitch = 8;
    blk_h = 8;
    difference() {
        cube([pitch * len(fit_bores), knuckle_base_l, blk_h]);
        for (i = [0 : len(fit_bores) - 1]) {
            translate([pitch * (i + 0.5), -1, blk_h / 2]) rotate([-90, 0, 0])
                cylinder(d = fit_bores[i], h = knuckle_base_l + 2);
            // Bohrungsmaß oben eingraviert
            translate([pitch * (i + 0.5), knuckle_base_l / 2, blk_h - 0.6])
                linear_extrude(1) text(str(fit_bores[i]), size = 2.2,
                                       halign = "center", valign = "center");
        }
    }
}

// ---- Ausgabe ----
// render() erzwingt die exakte Berechnung (F5-Vorschau = Export)

module lid_print() {  // umgedreht, Oberseite auf dem Bett
    translate([0, 0, H]) rotate([180, 0, 0]) lid();
}

if (part == "print") {
    render(convexity = 10) base();
    translate([0, -(W + tab_p_lid + tab_p + 10), 0])
        translate([0, W, 0]) render(convexity = 10) lid_print();
} else if (part == "base") {
    render(convexity = 10) base();
} else if (part == "lid") {
    render(convexity = 10) lid_print();
} else if (part == "inlay_base") {
    render(convexity = 10) inlay(inlay_base_h);
} else if (part == "inlay_lid") {
    render(convexity = 10) inlay(inlay_lid_h);
} else if (part == "fit_test") {
    render(convexity = 10) fit_test();
} else if (part == "assembly") {
    color("SteelBlue") render(convexity = 10) base();
    color("DimGray") inlay_base_placed();
    lid_open(open_angle) {
        color("LightSteelBlue", 0.8) render(convexity = 10) lid();
        color("DimGray") inlay_lid_placed();
    }
    color("Silver") for (hx = hinge_x)
        translate([hx, y_a, z_p]) rotate([0, 90, 0]) cylinder(d = pin_d, h = pin_l);
} else if (part == "interference") {
    // Schale gegen Deckel über den ganzen Öffnungswinkel,
    // dazu die Inlays im geschlossenen Zustand
    for (a = [0 : 5 : 180]) intersection() { base(); lid_open(a) lid(); }
    intersection() { base(); inlay_base_placed(); }
    intersection() { lid(); inlay_lid_placed(); }
    intersection() { inlay_base_placed(); inlay_lid_placed(); }
}
