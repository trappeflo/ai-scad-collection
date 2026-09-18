// Brillenetui (Klappetui) mit Low-Poly-Kristallhülle – Unterschale + Deckel
// mit Stift-Scharnier, Magnete unsichtbar im Rand, separate TPU-Einlegeschalen
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
//   - Einsatz: Tasche/Rucksack -> darf nicht von selbst aufgehen
//   - Magnete im Rand, nicht in Laschen
//   - Design (_003): verzogene Dreiecke, Hexagons, Vielecke, die die FORM der
//     Außenhülle bilden (kein aufgedrucktes Muster)
//
// Entwurf _003 ist eine Alternative zu _002 (Lichtenberg), kein Nachfolger.
// Übernommen aus _002: Scharnier, Magnete in den vorderen Ecken, Daumenmulde,
// TPU-Schalen. Neu:
//   - Kristallhülle: jittered Hex-Gitter auf dem abgewickelten Seitenring.
//     Jede Zelle ist ein flaches, eigenständig gekipptes Vieleck-Plateau
//     (meist verzogene Hexagons) in eigener Höhe, die Zwischenräume sind
//     verzogene Dreiecke und Vierecke -> durchgehende Low-Poly-Oberfläche,
//     relief_lo..relief_hi (+ Kippung) über der Grundwand.
//   - Grundwand wieder 2.8mm (Relief kommt nur außen dazu).
//   - Deckeloberseite und Boden bleiben flach: beide liegen beim Druck auf dem
//     Bett. Das Relief schneidet dort eine gezackte Kristallkante.
//   - Scharnierachse rückt um die Reliefhöhe nach außen.
//   - Vorschaufarben: Hülle MidnightBlue, TPU schwarz.
//
// Koordinaten (geschlossen): X = Länge, Y = Tiefe (y=0 vorne, y=W hinten/
// Scharnier), Z = Höhe. Trennebene bei z = z_p. W, L = Grundkörper ohne Relief.
//
// Druckausrichtung (part = "print"), alles ohne Stützen:
//   - Unterschale: auf dem Boden, offen nach oben.
//   - Deckel: auf der Oberseite (umgedreht).
//   - TPU-Schalen: auf dem Boden, offen nach oben.
//   Reliefflächen an den Seiten sind höchstens overhang_max aus der Senkrechten
//   geneigt (per assert geprüft, für Schale UND umgedrehten Deckel).
//
// Magnete einkleben: POLUNG BEACHTEN (jedes Paar muss sich anziehen).

/* [Brille (zusammengeklappt)] */
// Länge (Scharnier zu Scharnier)
glasses_l = 145;  // [100:0.5:200]
// Höhe der Gläser (liegt in Etui-Tiefe Y)
glasses_w = 45;   // [25:0.5:80]
// Dicke zusammengeklappt (Bügel + Nasenpads, liegt in Etui-Höhe Z)
glasses_d = 38;   // [15:0.5:60]

/* [Kristallhülle] */
// Zufalls-Seed: jede Zahl ergibt eine andere Facettierung
seed = 3;          // [1:1:999]
// Zellgröße (Abstand der Vielecke)
cell = 14;         // [8:0.5:25]
// Verzerrung der Zellen (0 = regelmäßige Hexagons)
jitter = 0.28;     // [0:0.01:0.4]
// Plateaugröße (Anteil der Zelle, Rest sind Dreiecke/Vierecke)
shrink = 0.5;      // [0.3:0.01:0.8]
// Reliefhöhe min/max über der Grundwand (Plateau-Mitte, + Kippung)
relief_lo = 0.4;   // [0.4:0.1:3]
relief_hi = 1.6;   // [0.8:0.1:5]
// max. Kippung der Plateaus (Steigung)
tilt = 0.4;         // [0:0.01:0.5]

/* [Ausgabe] */
// print = alles in Druckausrichtung, base/lid/inlay_base/inlay_lid = Einzelteile,
// relief_preview = nur die Kristallhülle (schnell, zum Seed-Aussuchen),
// fit_test = Bohrungstest für die Stifte, assembly = zusammengebaut,
// interference = Kollisionsprüfung über den Öffnungswinkel (muss leer sein)
part = "print";   // [print, base, lid, inlay_base, inlay_lid, relief_preview, fit_test, assembly, interference]
// Nur für assembly: Öffnungswinkel des Deckels (°)
open_angle = 100; // [0:5:180]

/* [Hidden] */

col_shell = "MidnightBlue";
col_tpu   = "Black";

// ---- Luft um die Brille (innerhalb der TPU-Schalen) ----
air_xy = 1.5;
air_z  = 1.0;

// ---- TPU-Inlay ----
inlay_t     = 1.2;
inlay_clear = 0.3;  // UNGETESTET
inlay_gap_z = 0.2;

// ---- Schale ----
lip_t      = 1.2;
lip_clear  = 0.4;
skin_t     = 1.2;
wall_t     = lip_t + lip_clear + skin_t;  // 2.8
floor_t    = 2.0;
top_t      = 2.0;
lip_h      = 2.0;
lip_clear_z = 0.2;
corner_r   = 8;     // Eckradius Grundkörper
corner_k   = 8;     // Facetten je Ecke
front_r    = 22;    // Innenradius vorne (Platz für die Magnete)
relief_in  = 1.0;   // Relief greift so tief in die Grundwand (Verbindung)
overhang_max = 45;  // max. Neigung der Reliefflächen aus der Senkrechten (°)

// ---- Daumenmulde ----
scoop_r   = 9;
scoop_off = 7;      // Eindringtiefe in die Grundwand = scoop_r - scoop_off

// ---- Scharnier ----
pin_d      = 3.0;
pin_l      = 30;
bore_press = 3.2;   // fit_test!
bore_free  = 3.6;
knuckle_r  = 3.5;
hinge_gap  = 0.4;
knuckle_gap = 0.4;
knuckle_base_l = 8;
hinge_edge = 12;
hinge_relief = 0.3;
knuckle_sink = 1.0; // Gelenkauge greift so tief in die Grundwand

// ---- Magnete ----
mag_d       = 6;
mag_h       = 2;
mag_clear   = 0.15;
mag_depth_extra = 0.1;

// ---- Passungstest ----
fit_bores = [3.1, 3.2, 3.3, 3.5, 3.6, 3.7];

nozzle = 0.4;
build  = 250;
$fn = 48;

// ---- Abgeleitete Maße ----
ic = inlay_clear;
space_l = glasses_l + 2 * air_xy;
space_w = glasses_w + 2 * air_xy;
space_h = glasses_d + air_z;

cav_l = space_l + 2 * (inlay_t + ic);
cav_w = space_w + 2 * (inlay_t + ic);
cav_h = space_h + 2 * inlay_t + inlay_gap_z;

L = cav_l + 2 * wall_t;
W = cav_w + 2 * wall_t;
H = cav_h + floor_t + top_t;
z_p = H / 2;
back_r = corner_r - wall_t;

knuckle_lid_l = pin_l - 2 * knuckle_base_l - 2 * knuckle_gap;
hinge_x = [corner_r + hinge_edge, L - corner_r - hinge_edge - pin_l];

inlay_base_h = z_p + lip_h - floor_t;
inlay_lid_h  = H - top_t - (z_p + lip_h) - inlay_gap_z;

pocket_d = mag_d + 2 * mag_clear;
pocket_h = mag_h + mag_depth_extra;
lip_out  = skin_t + lip_clear;
mag_t = (sqrt(2) * (wall_t + front_r + corner_r) - front_r - corner_r + lip_out) / (2 * sqrt(2));
web_lip = (corner_r - lip_out) - sqrt(2) * (corner_r - mag_t) - pocket_d / 2;
web_cav = sqrt(2) * (wall_t + front_r - mag_t) - front_r - pocket_d / 2;
mag_pos = [[mag_t, mag_t], [L - mag_t, mag_t]];

// =====================================================================
// Grundriss als Polygon (CCW), Start hinten mittig
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
EN = [for (t = ET) [t[1], -t[0]]];
function cum(v, i) = i == 0 ? 0 : cum(v, i - 1) + v[i - 1];
ES = [for (i = [0 : N - 1]) cum(EL, i)];
PER = cum(EL, N);
function md(s) = s - PER * floor(s / PER);
function wrapc(x) = x - PER * round(x / PER);
function edge_at(s) = let(ss = md(s)) len([for (i = [1 : N - 1]) if (ES[i] <= ss) 1]);

// Abwicklung (s, z, Höhe) -> 3D
function map3(c) = let(s = md(c[0]), i = edge_at(s), P = OP[i] + (s - ES[i]) * ET[i] + c[2] * EN[i])
    [P[0], P[1], c[1]];

// =====================================================================
// Kristallhülle: periodisches, gejittertes Dreiecksgitter auf dem
// Seitenring. Punkte (Plateau-Ecken) = je Dreieck t und Ecke k:
// c = Site + shrink * (Schwerpunkt - Site), Höhe aus der Plateau-Ebene
// der Site. Flächen: Dreieck je t, Viereck je Gitterkante, Vieleck je Site.
// =====================================================================
n_s = max(3, round(PER / cell));
au  = PER / n_s;                         // Zellabstand entlang des Umfangs
bv  = cell * sqrt(3) / 2;                // Zeilenabstand
v0  = -1.2 * bv;
nr  = ceil((H - 2 * v0) / bv) + 1;       // Zeilen (über Ober-/Unterkante hinaus)
NT  = (nr - 1) * n_s * 2;

function imod(i) = (i % n_s + n_s) % n_s;
function sid(i, j) = j * n_s + imod(i);
function site(i, j) = let(r = rands(-1, 1, 2, seed * 100003 + sid(i, j) * 7 + 1))
    [(i + (j % 2) * 0.5) * au + r[0] * jitter * au, v0 + j * bv + r[1] * jitter * bv];
// Plateau-Mitte um die Kipp-Reichweite angehoben, damit keine Ecke unter
// relief_lo fällt (Ecken liegen <= shrink * ~0.8 * cell von der Site entfernt)
tilt_reach = tilt * shrink * 0.8 * cell;
function plane(i, j) = let(r = rands(0, 1, 3, seed * 7777 + sid(i, j) * 13 + 5))
    [relief_lo + tilt_reach * r[1] + (relief_hi - relief_lo) * r[0], tilt * r[1] * [cos(360 * r[2]), sin(360 * r[2])]];
function tri_sites(i, j, ty) = j % 2 == 0
    ? (ty == 0 ? [[i, j], [i + 1, j], [i, j + 1]] : [[i + 1, j], [i + 1, j + 1], [i, j + 1]])
    : (ty == 0 ? [[i, j], [i + 1, j], [i + 1, j + 1]] : [[i, j], [i + 1, j + 1], [i, j + 1]]);
function tid(i, j, ty) = (j * n_s + imod(i)) * 2 + ty;
function corner(i, j, ty, k) =
    let(S = tri_sites(i, j, ty), P3 = [for (q = S) site(q[0], q[1])],
        cen = (P3[0] + P3[1] + P3[2]) / 3, A = P3[k], c = A + shrink * (cen - A),
        pl = plane(S[k][0], S[k][1]))
    [c[0], c[1], pl[0] + pl[1] * (c - A)];

CORN = [for (j = [0 : nr - 2]) for (i = [0 : n_s - 1]) for (ty = [0 : 1]) for (k = [0 : 2]) corner(i, j, ty, k)];
NV = len(CORN);

// Flächen (CCW in der Abwicklung = von außen gesehen gegen den Uhrzeigersinn)
F_TRI = [for (t = [0 : NT - 1]) [3 * t, 3 * t + 1, 3 * t + 2]];
F_QUAD = [for (j = [0 : nr - 2]) for (i = [0 : n_s - 1])
    let(t = tid(i, j, 0), p = j % 2,
        qs = concat(
            j >= 1 ? [let(u = tid(i, j - 1, 1)) [3 * u + 2, 3 * u + 1, 3 * t + 1, 3 * t]] : [],
            [let(u = tid(p == 0 ? i : i + 1, j, 1)) [3 * u, 3 * u + 2, 3 * t + 2, 3 * t + 1]],
            [let(u = tid(p == 0 ? i - 1 : i, j, 1)) [3 * u + 1, 3 * u, 3 * t, 3 * t + 2]]))
    for (q = qs) each [[q[0], q[1], q[2]], [q[0], q[2], q[3]]]];

function qsort(v) = len(v) <= 1 ? v :
    let(p = v[0][0]) concat(qsort([for (x = v) if (x[0] < p) x]), [for (x = v) if (x[0] == p) x],
                            qsort([for (x = v) if (x[0] > p) x]));
function hex_inc(i, j) = j % 2 == 0
    ? [[tid(i, j, 0), 0], [tid(i - 1, j, 0), 1], [tid(i - 1, j, 1), 0],
       [tid(i - 1, j - 1, 0), 2], [tid(i, j - 1, 1), 2], [tid(i - 1, j - 1, 1), 1]]
    : [[tid(i, j, 0), 0], [tid(i - 1, j, 0), 1], [tid(i, j, 1), 0],
       [tid(i, j - 1, 0), 2], [tid(i, j - 1, 1), 2], [tid(i - 1, j - 1, 1), 1]];
F_HEX = [for (j = [1 : nr - 2]) for (i = [0 : n_s - 1])
    let(A = site(i, j),
        hs = qsort([for (e = hex_inc(i, j)) let(ix = 3 * e[0] + e[1], c = CORN[ix])
                    [atan2(c[1] - A[1], wrapc(c[0] - A[0])), ix]]),
        h = [for (x = hs) x[1]])
    for (m = [1 : len(h) - 2]) [h[0], h[m], h[m + 1]]];

F_OUT = concat(F_TRI, F_QUAD, F_HEX);

// Randkanten (nur eine Fläche) -> Wände zwischen Außen- und Innenhaut
EDG  = [for (f = F_OUT) for (e = [0 : 2]) [f[e], f[(e + 1) % 3]]];
EKEY = [for (e = EDG) e[0] * 100000 + e[1]];
RHIT = search([for (e = EDG) e[1] * 100000 + e[0]], EKEY);
F_BND = [for (q = [0 : len(EDG) - 1]) if (RHIT[q] == []) EDG[q]];

// Überhang-Prüfung: Neigung jeder Fläche aus der Senkrechten. Schale (unter
// z_p) hängt über, wenn die Fläche nach unten zeigt, der umgedrehte Deckel,
// wenn sie nach oben zeigt.
function fnorm(f) = let(a = CORN[f[0]], b = CORN[f[1]], c = CORN[f[2]],
    e1 = [wrapc(b[0] - a[0]), b[1] - a[1], b[2] - a[2]],
    e2 = [wrapc(c[0] - a[0]), c[1] - a[1], c[2] - a[2]]) cross(e1, e2);
OVH = [for (f = F_OUT)
    let(n = fnorm(f), zc = (CORN[f[0]][1] + CORN[f[1]][1] + CORN[f[2]][1]) / 3,
        down = zc < z_p ? -n[1] : n[1])
    if (zc > -1 && zc < H + 1 && down > 0) asin(down / norm(n))];
overhang = max(concat([0], OVH));
relief_top = max([for (c = CORN) c[2]]);
relief_bot = min([for (c = CORN) c[2]]);

// Scharnierachse außerhalb des Reliefs
W_out = W + relief_top;
y_a = W_out + hinge_gap + knuckle_r;
gusset = hinge_gap + knuckle_r + sqrt(2) * knuckle_r + hinge_relief;

// ---- Prüfungen ----
min_w = 2 * nozzle - 1e-6;
assert(skin_t >= min_w && lip_t >= min_w && inlay_t >= min_w, "Wand zu dünn");
assert(knuckle_r - bore_free / 2 >= min_w, "Gelenkauge Deckel zu dünn");
assert(knuckle_lid_l >= 8, str("Mittleres Gelenkauge zu kurz: ", knuckle_lid_l));
assert(mag_t <= corner_r, "Magnetlage außerhalb der Eckrundung");
assert(web_lip >= min_w && web_cav >= min_w,
    str("Magnettasche: Steg außen ", web_lip, ", Steg innen ", web_cav, " -> front_r erhöhen"));
assert(wall_t - (scoop_r - scoop_off) >= min_w, "Daumenmulde zu tief");
assert(knuckle_sink <= skin_t - 0.2, "Gelenkauge ragt in die Lippen-Aussparung");
assert(z_p - gusset > 1, "Scharnier-Stützkeil zu hoch für die Etuihöhe");
assert(back_r > 0 && front_r + back_r <= cav_w, "Innenradien passen nicht");
assert(relief_bot > 0, str("Relief taucht unter die Grundwand: ", relief_bot));
assert(relief_hi > relief_lo, "relief_hi muss größer als relief_lo sein");
assert(overhang <= overhang_max, str("Reliefflächen zu flach (Überhang ", overhang, "°) -> tilt/relief kleiner oder cell größer"));
assert(L + 2 * relief_top <= build && y_a + knuckle_r + relief_top <= build, "Größer als Bauraum");

echo(str("Grundkörper (L x B x H): ", L, " x ", W, " x ", H, " mm, mit Relief ca. ",
         L + 2 * relief_top, " x ", W + 2 * relief_top, " mm, mit Scharnier B = ", y_a + knuckle_r + relief_top, " mm"));
echo(str("Brillenraum innen: ", space_l, " x ", space_w, " x ", space_h,
         " mm, Innenecken vorne R", front_r - ic - inlay_t));
echo(str("Relief ", relief_bot, " .. ", relief_top, " mm, ", n_s, " x ", nr, " Zellen, max. Überhang ",
         overhang, "° (Grenze ", overhang_max, "°)"));
echo(str("Magnetstege außen ", web_lip, " / innen ", web_cav, " mm"));

// ---- Kristallhülle als geschlossenes Polyeder ----
module relief_band() {
    pts = concat([for (c = CORN) map3(c)], [for (c = CORN) map3([c[0], c[1], -relief_in])]);
    faces = concat(
        [for (f = F_OUT) [f[2], f[1], f[0]]],                 // außen (OpenSCAD: im Uhrzeigersinn)
        [for (f = F_OUT) [f[0] + NV, f[1] + NV, f[2] + NV]],  // innen
        [for (e = F_BND) each [[e[0], e[1], e[1] + NV], [e[0], e[1] + NV, e[0] + NV]]]);
    polyhedron(points = pts, faces = faces, convexity = 6);
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

// Außenkörper zwischen z0 und z1: Grundkörper + Kristallhülle, flach geschnitten
module outer_solid(z0, z1) {
    intersection() {
        union() {
            linear_extrude(H) outline2d();
            relief_band();
        }
        translate([-20, -20, z0]) cube([L + 40, W + 40, z1 - z0]);
    }
}

// ---- Gelenkauge ----
module knuckle(x0, len, s) {
    z0 = s < 0 ? z_p - gusset : z_p + hinge_relief;
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(len) {
        hull() {
            translate([y_a, z_p]) circle(r = knuckle_r);
            translate([W_out, z0]) square([0.01, gusset - hinge_relief]);
        }
        translate([W - knuckle_sink, z0]) square([W_out - W + knuckle_sink + 0.01, gusset - hinge_relief]);
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
                outer_solid(0, z_p);
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
            outer_solid(z_p, H);
            for (hx = hinge_x)
                knuckle(hx + knuckle_base_l + knuckle_gap, knuckle_lid_l, +1);
        }
        translate([0, 0, z_p - 1]) linear_extrude(H - top_t - z_p + 1) cavity2d();
        translate([0, 0, z_p - 1]) linear_extrude(lip_h + lip_clear_z + 1) inset2d(skin_t);
        for (p = mag_pos) translate([p[0], p[1], z_p + lip_h + lip_clear_z - 1]) cylinder(d = pocket_d, h = pocket_h + 1);
        pin_bore(bore_free);
    }
}

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
module lid_print() { translate([0, 0, H]) rotate([180, 0, 0]) lid(); }

if (part == "print") {
    color(col_shell) render(convexity = 10) base();
    color(col_shell) translate([0, -12 - relief_top, 0]) render(convexity = 10) lid_print();
    color(col_tpu) translate([0, y_a + knuckle_r + 12, 0]) render(convexity = 10) inlay(inlay_base_h);
    color(col_tpu) translate([0, y_a + knuckle_r + W + 22, 0]) render(convexity = 10) inlay(inlay_lid_h);
} else if (part == "base") {
    render(convexity = 10) base();
} else if (part == "lid") {
    render(convexity = 10) lid_print();
} else if (part == "inlay_base") {
    render(convexity = 10) inlay(inlay_base_h);
} else if (part == "inlay_lid") {
    render(convexity = 10) inlay(inlay_lid_h);
} else if (part == "relief_preview") {
    color(col_shell) outer_solid(0, H);
} else if (part == "fit_test") {
    render(convexity = 10) fit_test();
} else if (part == "assembly") {
    color(col_shell) render(convexity = 10) base();
    color(col_tpu) inlay_base_placed();
    lid_open(open_angle) {
        color(col_shell) render(convexity = 10) lid();
        color(col_tpu) inlay_lid_placed();
    }
    color("Silver") for (hx = hinge_x)
        translate([hx, y_a, z_p]) rotate([0, 90, 0]) cylinder(d = pin_d, h = pin_l);
} else if (part == "interference") {
    for (a = [0 : 5 : 180]) intersection() { base(); lid_open(a) lid(); }
    intersection() { base(); inlay_base_placed(); }
    intersection() { lid(); inlay_lid_placed(); }
    intersection() { inlay_base_placed(); inlay_lid_placed(); }
}
