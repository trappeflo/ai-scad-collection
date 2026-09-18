// Brillenetui (Klappetui) mit Lichtenberg-Muster – Unterschale + Deckel mit
// Stift-Scharnier, Magnete unsichtbar im Rand, separate TPU-Einlegeschalen
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
//   - Design: Fraktal, Lichtenberg-Verästelung auf Deckel + Seiten
//   - Magnete im Rand, nicht in Laschen
//
// Änderungen gegenüber _001 (Nutzer-Feedback):
//   - Verschlusslaschen entfernt. 2 Magnetpaare 6x2 sitzen jetzt unsichtbar
//     in den vorderen Ecken: Unterschale in der Lippe, Deckel über der
//     Lippen-Aussparung. Dafür sind die vorderen Innenecken stark gerundet
//     (front_r), die hinteren bleiben eng (Platz für die Bügelscharniere der
//     Brille -> Brille mit der Oberkante zum Scharnier einlegen).
//   - Öffnen über eine Daumenmulde vorne mittig in der Unterschale.
//   - Lichtenberg-Muster als Rille (1mm tief) über Deckel und alle Seiten.
//     Es wächst aus der Daumenmulde. seed ändern -> anderes Muster (Unikat).
//     Wand dafür 2.8 -> 3.8mm, Deckel 2.0 -> 2.2mm (Restwand nach Rille >= 1.2).
//   - TPU-Schalen liegen jetzt mit in der print-Ansicht (orange).
//
// Musteraufbau: Die Äste laufen als "Schildkröte" auf der abgewickelten
// Oberfläche (Deckel = XY-Ebene, Seitenring = Abwicklung s/h). Übergänge
// Deckel <-> Seite sind längentreu, das Muster läuft nahtlos über die Kante.
// Geschnitten wird je Wandfacette als 2D-Muster (schnell auch mit CGAL).
//
// Koordinaten (geschlossen): X = Länge, Y = Tiefe (y=0 vorne, y=W hinten/
// Scharnier), Z = Höhe. Trennebene bei z = z_p.
//
// Druckausrichtung (part = "print"), alles ohne Stützen:
//   - Unterschale: auf dem Boden, offen nach oben.
//   - Deckel: auf der Oberseite (umgedreht), Muster liegt auf dem PEI-Bett.
//   - TPU-Schalen: auf dem Boden, offen nach oben.
//   Rillen in den Seitenwänden sind 1mm tiefe Mini-Überhänge (unkritisch).
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

/* [Muster] */
// Zufalls-Seed: jede Zahl ergibt eine andere Verästelung
seed = 7;          // [1:1:999]
// Anzahl Hauptäste aus der Daumenmulde
main_count = 8;    // [3:1:15]
// Länge der Hauptäste
main_len = 80;     // [20:1:150]
// Verzweigungstiefe
levels = 4;        // [1:1:7]

/* [Ausgabe] */
// print = alles in Druckausrichtung, base/lid/inlay_base/inlay_lid = Einzelteile,
// pattern_net = Muster abgewickelt (schnell, zum Seed-Aussuchen),
// fit_test = Bohrungstest für die Stifte, assembly = zusammengebaut,
// interference = Kollisionsprüfung über den Öffnungswinkel (muss leer sein)
part = "print";   // [print, base, lid, inlay_base, inlay_lid, pattern_net, fit_test, assembly, interference]
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
groove_d   = 1.0;   // Rillentiefe des Musters
lip_t      = 1.2;   // Lippe (Unterschale, innen)
lip_clear  = 0.4;   // Spiel Lippe <-> Deckelhaut pro Seite
skin_t     = 1.2 + groove_d;           // Deckelhaut über der Lippe (Rest nach Rille 1.2)
wall_t     = lip_t + lip_clear + skin_t; // 3.8
floor_t    = 2.0;   // Boden Unterschale (ohne Muster)
top_t      = 1.2 + groove_d;           // Decke Deckel (mit Muster)
lip_h      = 2.0;   // Lippenhöhe über der Trennebene
lip_clear_z = 0.2;  // Lippe stößt nicht an -> Magnete liegen sicher an
corner_r   = 8;     // Eckradius außen
corner_k   = 8;     // Facetten je Ecke (Muster wird je Facette geschnitten)
front_r    = 21;    // Innenradius vorne (Platz für die Magnete)
bottom_c   = 1.5;   // 45°-Fase Unterkante (auch gegen Elefantenfuß)
top_c      = 0.8;   // 45°-Fase Deckelkante (klein, damit das Muster darüber läuft)

// ---- Daumenmulde (vorne mittig, nur Unterschale) ----
scoop_r   = 9;
scoop_off = 6.5;    // Kugelmitte vor der Front -> Eindringtiefe scoop_r - scoop_off

// ---- Scharnier ----
pin_d      = 3.0;   // Edelstahlstift
pin_l      = 30;    // Stiftlänge = Scharnierlänge
bore_press = 3.2;   // Unterschale: 0.1/Seite Presspassung (tolerances.md) – fit_test!
bore_free  = 3.6;   // Deckel: 0.3/Seite, dreht frei (waagerechte Bohrung sackt oben etwas)
knuckle_r  = 3.5;   // Außenradius Gelenkauge
hinge_gap  = 0.4;   // Abstand Gelenkauge <-> Rückwand (Freigang beim Drehen)
knuckle_gap = 0.4;  // axialer Spalt zwischen den Augen
knuckle_base_l = 8; // Länge je äußeres Auge (Presssitz)
hinge_edge = 12;    // Abstand Scharnier zum Beginn der Eckrundung
hinge_relief = 0.3; // Stützkeil endet so weit unter/über der Trennebene
knuckle_sink = 1.5; // Gelenkauge greift so tief in die Wand (unter die Rillen)

// ---- Magnete ----
mag_d       = 6;
mag_h       = 2;
mag_clear   = 0.15; // Radialspiel zum Einkleben
mag_depth_extra = 0.1;

// ---- Muster (fein) ----
step_l    = 1.5;    // Schrittweite der Äste
jitter    = 22;     // Zick-Zack je Schritt (°)
w_root    = 2.2;    // Rillenbreite Hauptast
w_decay   = 0.8;    // Breite je Verzweigung
w_min     = 0.8;    // schmalste Rille (2x Düse)
bottom_margin = 4;  // Muster endet so weit über der Unterkante
facet_ov  = 0.2;    // Überlappung der Facetten-Schnitte
pattern   = true;   // false = ohne Rillen (schnelle Prüfläufe; Rillen nehmen nur außen Material weg)

// ---- Passungstest ----
fit_bores = [3.1, 3.2, 3.3, 3.5, 3.6, 3.7];

nozzle = 0.4;
build  = 250;
$fn = 48;

// ---- Abgeleitete Maße ----
ic = inlay_clear;
space_l = glasses_l + 2 * air_xy;   // Brillenraum innen (in den TPU-Schalen)
space_w = glasses_w + 2 * air_xy;
space_h = glasses_d + air_z;

cav_l = space_l + 2 * (inlay_t + ic);   // Hohlraum der Schale
cav_w = space_w + 2 * (inlay_t + ic);
cav_h = space_h + 2 * inlay_t + inlay_gap_z;

L = cav_l + 2 * wall_t;                 // Außenmaße (ohne Scharnier)
W = cav_w + 2 * wall_t;
H = cav_h + floor_t + top_t;
z_p = H / 2;                            // Trennebene: beide Hälften gleich hoch
back_r = corner_r - wall_t;             // Innenradius hinten (konzentrisch)

y_a = W + hinge_gap + knuckle_r;        // Scharnierachse (Y), z = z_p
gusset = hinge_gap + knuckle_r + sqrt(2) * knuckle_r + hinge_relief;
knuckle_lid_l = pin_l - 2 * knuckle_base_l - 2 * knuckle_gap;
hinge_x = [corner_r + hinge_edge, L - corner_r - hinge_edge - pin_l];

inlay_base_h = z_p + lip_h - floor_t;
inlay_lid_h  = H - top_t - (z_p + lip_h) - inlay_gap_z;

// Magnete: auf der Eckdiagonale dort, wo die Stege zur Lippen-Außenkante und
// zum Hohlraum gleich dick sind
pocket_d = mag_d + 2 * mag_clear;
pocket_h = mag_h + mag_depth_extra;
lip_out  = skin_t + lip_clear;          // Lippen-Außenkante = Versatz nach innen
mag_t = (sqrt(2) * (wall_t + front_r + corner_r) - front_r - corner_r + lip_out) / (2 * sqrt(2));
web_lip = (corner_r - lip_out) - sqrt(2) * (corner_r - mag_t) - pocket_d / 2;
web_cav = sqrt(2) * (wall_t + front_r - mag_t) - front_r - pocket_d / 2;
mag_pos = [[mag_t, mag_t], [L - mag_t, mag_t]];

// ---- Prüfungen ----
min_w = 2 * nozzle - 1e-6;  // 1e-6: Gleitkomma-Rundung
assert(skin_t - groove_d >= min_w, "Deckelhaut nach Rille zu dünn");
assert(top_t - groove_d >= min_w, "Deckel nach Rille zu dünn");
assert(wall_t - groove_d >= min_w, "Wand nach Rille zu dünn");
assert(lip_t >= min_w, str("Lippe zu dünn: ", lip_t));
assert(inlay_t >= min_w, str("Inlay zu dünn: ", inlay_t));
assert(w_min >= min_w, "Rille schmaler als 2x Düse");
assert(knuckle_r - bore_free / 2 >= min_w, "Gelenkauge Deckel zu dünn");
assert(knuckle_lid_l >= 8, str("Mittleres Gelenkauge zu kurz: ", knuckle_lid_l));
assert(mag_t <= corner_r, "Magnetlage außerhalb der Eckrundung");
assert(web_lip >= min_w && web_cav >= min_w,
    str("Magnettasche: Steg außen ", web_lip, ", Steg innen ", web_cav, " -> front_r erhöhen"));
assert(wall_t - (scoop_r - scoop_off) >= min_w, "Daumenmulde zu tief");
assert(z_p - gusset > bottom_c, "Scharnier-Stützkeil zu hoch für die Etuihöhe");
assert(back_r > 0 && front_r + back_r <= cav_w, "Innenradien passen nicht");
assert(L <= build && W + 2 * knuckle_r + hinge_gap <= build, "Größer als Bauraum");

echo(str("Etui außen (L x B x H): ", L, " x ", W, " x ", H,
         " mm, mit Scharnier: B = ", y_a + knuckle_r, " mm"));
echo(str("Brillenraum innen (in den TPU-Schalen): ", space_l, " x ", space_w, " x ", space_h,
         " mm, Innenecken vorne R", front_r - ic - inlay_t, ", hinten R", max(back_r - ic - inlay_t, 0)));
echo(str("Hälften je ", z_p, " mm hoch, Wand ", wall_t, ", Magnetstege außen ", web_lip,
         " / innen ", web_cav, " mm"));

// =====================================================================
// Umriss als explizites Polygon (CCW). Jede Kante ist eine Wandfacette.
// Start hinten mittig -> Naht der Abwicklung liegt zwischen den Scharnieren.
// =====================================================================
function arc(c, a0, a1) = [for (j = [0 : corner_k]) c + corner_r * [cos(a0 + j * (a1 - a0) / corner_k), sin(a0 + j * (a1 - a0) / corner_k)]];
R = corner_r;
OP = concat([[L / 2, W]],
            arc([R, W - R], 90, 180), arc([R, R], 180, 270),
            arc([L - R, R], 270, 360), arc([L - R, W - R], 0, 90));
N  = len(OP);
EV = [for (i = [0 : N - 1]) OP[(i + 1) % N] - OP[i]];
EL = [for (e = EV) norm(e)];
ET = [for (i = [0 : N - 1]) EV[i] / EL[i]];
EN = [for (t = ET) [t[1], -t[0]]];                  // Außennormale (CCW)
function cum(v, i) = i == 0 ? 0 : cum(v, i - 1) + v[i - 1];
ES = [for (i = [0 : N - 1]) cum(EL, i)];            // Bogenlänge am Kantenanfang
PER = cum(EL, N);                                   // Umfang
function md(s) = s - PER * floor(s / PER);
function wrapc(x) = x - PER * round(x / PER);
function edge_at(s) = let(ss = md(s)) len([for (i = [1 : N - 1]) if (ES[i] <= ss) 1]);

// ---- Schildkröte auf der Oberfläche ----
// Zustand: [fläche, a, b, da, db]; fläche 0 = Deckel (x, y), 1 = Seite (s, h)
// h = Abstand unter der Oberkante. Seitenrahmen (s, h) ist von außen gesehen
// gespiegelt -> Drehwinkel dort mit umgekehrtem Vorzeichen.
h_max = H - bottom_margin;

function inside(p) = max([for (i = [0 : N - 1]) (p - OP[i]) * EN[i]]) <= 0;

function step_top(st, l) =
    let(p = [st[1], st[2]], d = [st[3], st[4]], q = p + l * d)
    inside(q) ? [0, q[0], q[1], d[0], d[1]] :
    let(taus = [for (i = [0 : N - 1]) let(dn = d * EN[i]) if (dn > 1e-9) [((OP[i] - p) * EN[i]) / dn, i]],
        tm = min([for (x = taus) x[0]]),
        i = [for (x = taus) if (x[0] == tm) x[1]][0],
        tau = max(0, tm), X = p + tau * d,
        ds = d * ET[i], dh = d * EN[i], r = l - tau)
    [1, md(ES[i] + (X - OP[i]) * ET[i] + ds * r), dh * r, ds, dh];

function step_side(st, l) =
    let(s = st[1], h = st[2], ds = st[3], dh = st[4], h2 = h + l * dh)
    h2 >= 0 ? [1, md(s + l * ds), h2, ds, dh] :
    let(tau = h / (-dh), s1 = md(s + ds * tau), i = edge_at(s1),
        X = OP[i] + (s1 - ES[i]) * ET[i], d = ds * ET[i] + dh * EN[i], q = X + (l - tau) * d)
    [0, q[0], q[1], d[0], d[1]];

function stepst(st, l) = st[0] == 0 ? step_top(st, l) : step_side(st, l);

function turn(st, a) =
    let(g = st[0] == 0 ? a : -a, c = cos(g), sn = sin(g))
    [st[0], st[1], st[2], c * st[3] - sn * st[4], sn * st[3] + c * st[4]];

function walk(st, n, rs, i = 0) =
    (i >= n || (st[0] == 1 && st[2] > h_max)) ? [st] :
    concat([st], walk(stepst(turn(st, rs[i]), step_l), n, rs, i + 1));

// Ast: Zick-Zack-Pfad, Seitenäste zweigen irgendwo auf dem Pfad ab
function grow(st, len, w, lvl, sd) =
    let(n = max(1, round(len / step_l)),
        rs = rands(-jitter, jitter, n, sd),
        path = walk(st, n, rs),
        segs = [for (i = [0 : len(path) - 2]) [path[i], path[i + 1], w]],
        rc = rands(0, 1, 12, sd + 7),
        nk = (lvl <= 1 || w * w_decay < w_min || len(path) < 3) ? 0 : (rc[11] < 0.4 ? 3 : 2),
        kids = nk == 0 ? [] : [for (k = [0 : nk - 1])
            let(idx = floor((0.25 + 0.7 * rc[3 * k]) * (len(path) - 1)),
                ang = (rc[3 * k + 1] < 0.5 ? -1 : 1) * (20 + 40 * rc[3 * k + 2]))
            each grow(turn(path[idx], ang), len * (0.45 + 0.3 * rc[3 * k + 2]),
                      w * w_decay, lvl - 1, sd * 7 + k * 131 + 17)])
    concat(segs, kids);

// Wurzel: Mitte der Daumenmulde (Front, Trennebene)
function side_sh(st) = st[0] == 1 ? [st[1], st[2]] :
    let(p = [st[1], st[2]], dd = [for (i = [0 : N - 1]) (p - OP[i]) * EN[i]], mx = max(dd),
        i = [for (j = [0 : N - 1]) if (dd[j] == mx) j][0])
    [md(ES[i] + (p - OP[i]) * ET[i]), mx];
function top_xy(st) = st[0] == 0 ? [st[1], st[2]] :
    let(i = edge_at(st[1])) OP[i] + (st[1] - ES[i]) * ET[i] + st[2] * EN[i];

s_root = side_sh([0, L / 2, 0.01, 1, 0])[0];
root_dirs = let(r = rands(-12, 12, main_count, seed + 3))
    [for (m = [0 : main_count - 1]) 270 + (m - (main_count - 1) / 2) * 230 / (main_count - 1) + r[m]];
SEGS = [for (m = [0 : main_count - 1])
    let(a = root_dirs[m], lm = main_len * (0.7 + 0.6 * rands(0, 1, 1, seed * 13 + m)[0]))
    each grow([1, s_root, H - z_p, cos(a), sin(a)], lm, w_root, levels, seed * 1000 + m * 97)];

SEG_TOP  = [for (g = SEGS) if (g[0][0] == 0 || g[1][0] == 0) [top_xy(g[0]), top_xy(g[1]), g[2]]];
SEG_SIDE = [for (g = SEGS) if (g[0][0] == 1 || g[1][0] == 1) [side_sh(g[0]), side_sh(g[1]), g[2]]];
echo(str("Muster: ", len(SEGS), " Segmente (Deckel ", len(SEG_TOP), ", Seiten ", len(SEG_SIDE), ")"));

// ---- Rillen-Schnittkörper ----
module seg2d(a, b, w) {
    hull() { translate(a) circle(d = w, $fn = 12); translate(b) circle(d = w, $fn = 12); }
}

module groove_top() {
    translate([0, 0, H - groove_d]) linear_extrude(groove_d + 1)
        for (g = SEG_TOP) seg2d(g[0], g[1], g[2]);
}

// Facette j: lokale 2D-Koordinaten (u = s - ES[j], v = h) -> Wandebene,
// extrudiert entlang der Innennormalen
module groove_facet(j) {
    t = ET[j]; n = EN[j]; P = OP[j];
    segs = [for (g = SEG_SIDE)
        let(u1 = wrapc(g[0][0] - ES[j]), u2 = u1 + wrapc(g[1][0] - g[0][0]), m = g[2] + 1)
        if (min(u1, u2) < EL[j] + m && max(u1, u2) > -m) [[u1, g[0][1]], [u2, g[1][1]], g[2]]];
    if (len(segs) > 0)
        multmatrix([[t[0], 0, -n[0], P[0]], [t[1], 0, -n[1], P[1]], [0, -1, 0, H], [0, 0, 0, 1]])
            translate([0, 0, -1]) linear_extrude(groove_d + 1)
                intersection() {
                    translate([-facet_ov, -2]) square([EL[j] + 2 * facet_ov, H + 4]);
                    union() for (g = segs) seg2d(g[0], g[1], g[2]);
                }
}

module grooves() if (pattern) {
    groove_top();
    for (j = [0 : N - 1]) groove_facet(j);
}

// ---- 2D-Formen ----
module outline2d() { polygon(OP); }
module inset2d(d) { offset(delta = -d) outline2d(); }
module cavity2d() {
    hull() {
        for (x = [wall_t + front_r, L - wall_t - front_r]) translate([x, wall_t + front_r]) circle(r = front_r, $fn = 96);
        for (x = [R, L - R]) translate([x, W - R]) circle(r = back_r);
    }
}

// Außenkörper von z=0 bis h, untere Kante mit 45°-Fase c
module shell_body(h, c) {
    hull() {
        linear_extrude(0.01) inset2d(c);
        translate([0, 0, c]) linear_extrude(h - c) outline2d();
    }
}

// ---- Gelenkauge ----
module knuckle(x0, len, s) {
    z0 = s < 0 ? z_p - gusset : z_p + hinge_relief;
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(len) {
        hull() {
            translate([y_a, z_p]) circle(r = knuckle_r);
            translate([W, z0]) square([0.01, gusset - hinge_relief]);
        }
        translate([W - knuckle_sink, z0]) square([knuckle_sink + 0.01, gusset - hinge_relief]);
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
            difference() {
                shell_body(z_p, bottom_c);
                grooves();
                translate([L / 2, -scoop_off, z_p]) sphere(r = scoop_r, $fn = 64);
            }
            translate([0, 0, z_p - 0.01]) linear_extrude(lip_h + 0.01)
                difference() { inset2d(lip_out); cavity2d(); }
            for (hx = hinge_x) {
                knuckle(hx, knuckle_base_l, -1);
                knuckle(hx + pin_l - knuckle_base_l, knuckle_base_l, -1);
            }
        }
        translate([0, 0, floor_t]) linear_extrude(H) cavity2d();
        for (p = mag_pos) translate([p[0], p[1], z_p + lip_h - pocket_h]) cylinder(d = pocket_d, h = pocket_h + 1);
        pin_bore(bore_press);
    }
}

module lid() {
    difference() {
        union() {
            difference() {
                translate([0, 0, H]) mirror([0, 0, 1]) shell_body(H - z_p, top_c);
                grooves();
            }
            for (hx = hinge_x)
                knuckle(hx + knuckle_base_l + knuckle_gap, knuckle_lid_l, +1);
        }
        translate([0, 0, z_p - 1]) linear_extrude(H - top_t - z_p + 1) cavity2d();
        translate([0, 0, z_p - 1]) linear_extrude(lip_h + lip_clear_z + 1) inset2d(skin_t);
        for (p = mag_pos) translate([p[0], p[1], z_p + lip_h + lip_clear_z - 1]) cylinder(d = pocket_d, h = pocket_h + 1);
        pin_bore(bore_free);
    }
}

// TPU-Schale, offen nach oben, Boden bei z=0, in Etui-XY-Koordinaten
module inlay(h) {
    difference() {
        linear_extrude(h) offset(delta = -ic) cavity2d();
        translate([0, 0, inlay_t]) linear_extrude(h) offset(delta = -(ic + inlay_t)) cavity2d();
    }
}
module inlay_base_placed() { translate([0, 0, floor_t]) inlay(inlay_base_h); }
module inlay_lid_placed()  { translate([0, 0, H - top_t]) mirror([0, 0, 1]) inlay(inlay_lid_h); }

module lid_open(a) {
    translate([0, y_a, z_p]) rotate([-a, 0, 0]) translate([0, -y_a, -z_p]) children();
}

// ---- Abwicklung zum Seed-Aussuchen (2D, schnell) ----
module pattern_net() {
    color("DimGray") outline2d();
    color("White") for (g = SEG_TOP) seg2d(g[0], g[1], g[2]);
    // Seitenring als Streifen unter dem Deckel (s nach rechts, h nach unten)
    translate([0, -10]) {
        color("DimGray") translate([0, -H]) square([PER, H]);
        color("Gray") translate([0, -(H - z_p) - 0.2]) square([PER, 0.4]);  // Trennlinie
        color("White") for (g = SEG_SIDE)
            let(a = g[0], b = [a[0] + wrapc(g[1][0] - a[0]), g[1][1]])
            seg2d([a[0], -a[1]], [b[0], -b[1]], g[2]);
    }
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
            translate([pitch * (i + 0.5), knuckle_base_l / 2, blk_h - 0.6])
                linear_extrude(1) text(str(fit_bores[i]), size = 2.2,
                                       halign = "center", valign = "center");
        }
    }
}

// ---- Ausgabe ----
module lid_print() { translate([0, 0, H]) rotate([180, 0, 0]) lid(); }  // Oberseite aufs Bett

if (part == "print") {
    color("#2b2f36") render(convexity = 10) base();
    color("#2b2f36") translate([0, -12, 0]) render(convexity = 10) lid_print();
    color("#ff7a1a") translate([0, W + 2 * knuckle_r + 12, 0]) render(convexity = 10) inlay(inlay_base_h);
    color("#ff7a1a") translate([0, 2 * W + 2 * knuckle_r + 22, 0]) render(convexity = 10) inlay(inlay_lid_h);
} else if (part == "base") {
    render(convexity = 10) base();
} else if (part == "lid") {
    render(convexity = 10) lid_print();
} else if (part == "inlay_base") {
    render(convexity = 10) inlay(inlay_base_h);
} else if (part == "inlay_lid") {
    render(convexity = 10) inlay(inlay_lid_h);
} else if (part == "pattern_net") {
    pattern_net();
} else if (part == "fit_test") {
    render(convexity = 10) fit_test();
} else if (part == "assembly") {
    color("#2b2f36") render(convexity = 10) base();
    color("#ff7a1a") inlay_base_placed();
    lid_open(open_angle) {
        color("#3a404a") render(convexity = 10) lid();
        color("#ff7a1a") inlay_lid_placed();
    }
    color("Silver") for (hx = hinge_x)
        translate([hx, y_a, z_p]) rotate([0, 90, 0]) cylinder(d = pin_d, h = pin_l);
} else if (part == "interference") {
    for (a = [0 : 5 : 180]) intersection() { base(); lid_open(a) lid(); }
    intersection() { base(); inlay_base_placed(); }
    intersection() { lid(); inlay_lid_placed(); }
    intersection() { inlay_base_placed(); inlay_lid_placed(); }
}
