// Ladeständer für PocketBook Era Color (mit Hülle + Popsocket), Gerät quer,
// Ladebuchse unten, gewinkelter USB-C-Stecker hängt frei in einem Schacht
// Alle Maße in Millimetern (Regel: units-mm)
//
// Änderungen gegenüber _002 (QA-Befunde _002):
//   - Befund 1: R10 senkrecht bis zum ENDE DER GERADEN Anlagefläche gemessen
//     (Kopfrundung abgezogen). back_h 97 -> 99 -> 90.2 mm senkrecht, per
//     assert geprüft; das echo misst jetzt dasselbe (vorher bis zur
//     ungerundeten Ecke: 91.15 behauptet, real 88.3).
//   - Befund 2: Grate an den Wandköpfen neben der Tasche. Radius hinten am
//     Stützenkopf 4 -> 3 (= Restwand hinter der Tasche), seitlicher Kopfradius
//     8 -> 5 (= Rand links der Tasche). Die Bögen laufen jetzt tangential in
//     die Taschenwand statt in einen Grat; per assert gekoppelt.
//   - Befund 3 (R16 erweitert): vordere Ecken des Fußblocks und die
//     Lippenenden gerundet (r 6, Draufsicht senkrecht zur Gerätefläche, also
//     entlang der 70°-Front; die Rundungsfläche hat keinen Überhang).
//
// Änderungen in _002 gegenüber _001 (QA-Befunde + Nutzerwunsch "abgerundete Ecken"):
//   - Befund 1: Kante hinten am Schacht (Stütze hing 2.5 mm über) mit 45° im
//     Gerätesystem angefast -> ~25° aus der Senkrechten, kein Überhang mehr.
//   - Befund 2: back_h 95 -> 97, damit R10 auch senkrecht gilt (97 * sin70 = 91.2).
//   - Befund 3/4: Reserve. shaft_d 20 -> 22, Popsocket-Luft seitlich/unten
//     3 -> 5 (Tasche 50 breit), hinten 2 -> 4 (Tasche 11 tief), dafür
//     back_t 12 -> 14 (Rest hinter der Tasche bleibt 3). Tasche unten rund
//     (U-Form, folgt dem Popsocket).
//   - Befund 6: Ständermasse zieht Schacht, Kanal und Tasche ab (vorher nur
//     die volle Profilfläche).
//   - Abgerundet: Profilecken (Lippe oben, Stützenkopf, Fußplatte hinten,
//     Hohlkehle Stütze/Fußplatte), Stützenkopf seitlich (Vorderansicht),
//     hintere Ecken der Fußplatte (Draufsicht). Nicht gerundet: Kanten am
//     Bett (kein Überhang am Fuß) und die Auflage/Schlitzecken (dort sitzt
//     die Gerätekante).
//
// Kontext (Regel: context-first):
//   - context/printer.md:    Anycubic Kobra S1, 0.4mm Düse, PEI, 250mm Bauraum
//   - context/tolerances.md: kein Passsitz im Teil. Geräteschlitz bewusst
//                            locker (+1 mm/Seite), Stecker/Kabel mit viel Luft.
//   - context/materials.md:  PLA, Rechenwerte (Dichte 1.24, Füllung ~0.6)
//
// ---------------------------------------------------------------------------
// ANFORDERUNGSTABELLE (Design-Gespräch, vom Nutzer bestätigt)
// ---------------------------------------------------------------------------
// | ID  | Anforderung                         | Soll                                   | Quelle        | Prüfmethode                          |
// |-----|-------------------------------------|----------------------------------------|---------------|--------------------------------------|
// | R1  | Gerät quer: 162 br. x 145 h x 13 d  | Aufnahme passend, Gerät darf seitlich   | 145 gemessen, | Bounding Box, Schnitte               |
// |     |                                     | überstehen                             | 162 geschätzt,|                                      |
// |     |                                     |                                        | 13 ca. gem.   |                                      |
// | R2  | Schlitz für die Dicke               | 15 mm (+1/-0), locker                  | ca. gemessen  | Schnitt quer                         |
// | R3  | Neigung                             | 70° ±1° gegen den Tisch                | Nutzer        | Schnitt quer, Winkel                 |
// | R4  | Gerät auf zwei Auflagen, nicht auf  | Schacht unter der Buchse 70 mm lang (X)| angenommen    | Schnitt z = Auflagehöhe              |
// |     | dem Stecker                         | x 17 mm tief (quer zum Gerät)          |               |                                      |
// | R5  | Buchsenposition                     | Mitte ~80 mm vom linken Ende, mittig   | geschätzt     | Schacht zentriert darauf             |
// |     |                                     | in der Dicke                           |               |                                      |
// | R6  | Freiraum Winkelstecker              | Schachttiefe unter dem Gerät >= 20 mm  | angenommen    | Schnitt, Kollisionsteil Stecker      |
// |     |                                     | (Stecker ~15 lang, 12 x 7)             |               |                                      |
// | R7  | Kabelkanal oben offen, nach hinten  | Breite >= 5 mm, Kabel von oben einlegbar| angenommen   | Schnitt, Sichtprüfung                |
// | R8  | Popsocket frei: Ø40 x 7, Mitte 39   | Aussparung >= Ø46, Tiefe >= 9          | geschätzt     | Schnitt, Kollisionsteil              |
// |     | über Unterkante, 51 vom linken Ende |                                        |               |                                      |
// | R9  | Lippe vorne hält die Unterkante     | ~10 mm hoch                            | angenommen    | Schnitt quer                         |
// | R10 | Rückenstütze trägt über dem Schwer- | gerade Anlagefläche endet >= 90 mm     | angenommen    | Schnitt quer                         |
// |     | punkt                               | SENKRECHT über der Auflage (_003)      |               |                                      |
// | R11 | Kippsicher, nur Laden               | Kippwinkel vorne und hinten >= 15°,    | angenommen    | echo(), load-case-check              |
// |     |                                     | mit 330 g                              |               |                                      |
// | R12 | PLA, ohne Stützen druckbar          | Überhang <= 45°, Wände >= 0.8 mm       | Nutzer        | G4                                   |
// | R13 | Druckraum                           | <= 250 x 250 x 250                     | Drucker       | Bounding Box                         |
// | R14 | Teile im print                      | 1 Volumen                              | -             | check.py Volumes                     |
// | R15 | Passtest                            | Teil fit_test: Sockelausschnitt mit    | -             | Druck vor dem ganzen Teil            |
// |     |                                     | Schacht, Kanal, Auflagen               |               |                                      |
// | R16 | Abgerundete Ecken (Nutzer, _002/003)| sichtbare Außenecken gerundet, inkl.   | Nutzer        | Sichtprüfung (G3), Schnitte          |
// |     |                                     | vordere Ecken/Lippenenden; scharf:     |               |                                      |
// |     |                                     | Bettkanten, Auflage/Schlitz, Kanten an |               |                                      |
// |     |                                     | Schacht/Kanal/Tasche, lange Seiten-    |               |                                      |
// |     |                                     | kanten; keine Grate < 0.8 mm           |               |                                      |
//
// Stecker: UGREEN 60W USB-C Winkel 90°. Herstellermaße nicht gefunden ->
// plug_* und cable_d sind ANNAHMEN. Annahme: das Kabel geht parallel zur
// Geräteunterkante ab (X). Steckerseite so wählen, dass es nach rechts
// (zum Kanal) abgeht – USB-C ist verdrehbar.
//
// ---------------------------------------------------------------------------
// Koordinaten
// ---------------------------------------------------------------------------
// X = Breite (x = 0 am linken Ende des Geräts, von vorne gesehen),
// Y = Tiefe (y = 0 Vorderkante Fuß, +Y nach hinten), Z = Höhe.
// Gerätesystem (n, u): u entlang der Gerätefläche nach oben (um tilt nach
// hinten geneigt), n senkrecht dazu nach hinten. Ursprung O = Schnitt von
// Lippen-Innenseite und Auflage. Der Schlitz reicht von n = 0 (Lippe) bis
// n = slot_w (Rückenstütze); das Gerät lehnt an der Stütze.
//
// Aufbau: ein Profil in (Y, Z), über stand_w in X extrudiert:
//   Fuß vorne (massiv unter dem Schlitz), Lippe, Auflage senkrecht zur
//   Gerätefläche, geneigte Rückenstütze als Platte, flache Fußplatte nach
//   hinten. Ausgeschnitten: Steckerschacht unter der Buchse, Kabelkanal
//   (oben offen) nach hinten, Popsocket-Tasche (oben offen) in der Stütze.
//
// Druckausrichtung (part = "print"): so wie er steht, Fußunterseite aufs
// Bett. Keine Brücken (Schacht, Kanal und Tasche sind oben offen). Stärkster
// Überhang: Lippen-Innenseite und Rückseite der Stütze, je tilt = 20° aus
// der Senkrechten.
//
// LASTFÄLLE (rule load-case-check): Das Teil wird nicht bedient, nur
// abgestellt. Bruch unkritisch (330 g auf ~12 mm PLA-Platte, Spannungen
// << 1 MPa). Rutschen unkritisch (Lippe hält formschlüssig). Maßgebend ist
// Kippen, nach hinten (Anstoßen an der Geräteoberkante). echo() unten.

/* [Gerät] */
// Breite quer (lange Kante, mit Hülle) – GESCHÄTZT
dev_w = 162;
// Höhe quer (kurze Kante, mit Hülle) – gemessen
dev_h = 145;
// Dicke mit Hülle, ohne Popsocket – ca. gemessen
dev_t = 13;
// Masse Gerät + Hülle in g – ANNAHME (nur echo)
dev_mass_g = 330;

/* [Popsocket (Rückseite, eingeklappt)] */
pop_d = 40;
pop_h = 7;
// Mitte vom linken Ende (Frontansicht)
pop_x = 51;
// Mitte über der Geräteunterkante
pop_u = 39;
// Luft ringsum in der Tasche
pop_clear = 5;
// Luft hinter dem Popsocket
pop_clear_back = 4;

/* [Buchse und Winkelstecker – ANNAHMEN] */
// Buchsenmitte vom linken Ende
port_x = 80;
// Steckergehäuse: Breite (X), Dicke (n), Länge aus dem Gerät
plug_w = 12;
plug_t = 7;
plug_l = 15;
cable_d = 4;

/* [Ständer] */
// Neigung gegen den Tisch
stand_angle = 70;
// Luft im Schlitz gesamt (Schlitz = dev_t + slot_clear)
slot_clear = 2;
// Breite des Ständers (X), mittig unter dem Gerät
stand_w = 120;
// Lippe vorne: Dicke, Höhe über der Auflage
lip_t = 4;
lip_h = 10;
// Rückenstütze: Anlagehöhe über der Auflage, Plattendicke
back_h = 99;
back_t = 14;
// Fußplatte hinten: Gesamttiefe des Fußes, Höhe
base_d = 80;
base_h = 8;
// Boden unter dem tiefsten Punkt des Schachts
floor_t = 3;

/* [Schacht und Kanal] */
shaft_l = 70;
shaft_w = 17;
shaft_d = 22;
// Kanal nach hinten: X-Position (rechts neben dem Stecker, Platz zum Biegen)
channel_x = 100;
channel_w = 6;

/* [Ansicht] */
part = "print"; // [print, stand, fit_test, assembly, interference]

/* [Hidden] */
nozzle = 0.4;
min_w = 2 * nozzle;
bed = 250;
rho_pla = 1.24;   // g/cm³
fill = 0.6;       // effektive Füllung für Massenschätzung
eps = 0.01;
col_stand = "MidnightBlue";
$fn = 64;

tilt = 90 - stand_angle;       // Neigung aus der Senkrechten
s = sin(tilt);
c = cos(tilt);
slot_w = dev_t + slot_clear;
n_dev0 = slot_w - dev_t;       // Gerät lehnt an der Stütze
n_plug = n_dev0 + dev_t / 2;   // Buchse mittig in der Dicke
// Schachtvorderwand nie genau in der Ebene der Lippen-Innenseite (n = 0):
// koplanare Flächen ergeben Null-Dreiecke in der STL (F7)
shaft_n0 = max(n_plug - shaft_w / 2, 0.5);
shaft_n1 = shaft_n0 + shaft_w;
n_rear = slot_w + back_t;      // Rückseite der Stütze
sx0 = (dev_w - stand_w) / 2;   // Ständer mittig unter dem Gerät
sx1 = sx0 + stand_w;

// Ursprung O: tiefster Schachtpunkt (n = shaft_n1, u = -shaft_d) liegt auf
// z = floor_t; Lippen-Vorderkante trifft den Tisch bei y = 0.
Oz = floor_t + shaft_n1 * s + shaft_d * c;
u_a = -(Oz + lip_t * s) / c;
Oy = lip_t * c - u_a * s;

function F(n, u) = [Oy + n * c + u * s, Oz - n * s + u * c];

u_J = (base_h - Oz + n_rear * s) / c;   // Stützen-Rückseite trifft Fußplatte
PROFILE = [
    [0, 0], [base_d, 0], [base_d, base_h],
    F(n_rear, u_J), F(n_rear, back_h), F(slot_w, back_h),
    F(slot_w, 0), F(0, 0), F(0, lip_h), F(-lip_t, lip_h)
];
// Eckradien je Profilpunkt (R16). 0 = scharf: Bettkanten (kein Überhang)
// und Auflage/Schlitz (dort sitzt die Gerätekante). J = Hohlkehle.
//            A  R1 R2 J  H  G  E  D  C    B
PROFILE_RAD = [0, 0, 3, 4, 3, 3, 0, 0, 1.2, 1.5];
// Seitliche Rundung Stützenkopf (Vorderansicht), hintere Fußecken (Draufsicht),
// vordere Ecken/Lippenenden (Ansicht senkrecht zur Gerätefläche)
top_corner_r = 5;
foot_corner_r = 8;
front_corner_r = 6;

// Ecke i mit Radius r durch einen Kreisbogen ersetzen (konvex und konkav)
function unit(v) = v / norm(v);
function round_corner(P, i, r, k = 12) =
    let(a = P[(i - 1 + len(P)) % len(P)], p = P[i], b = P[(i + 1) % len(P)],
        u1 = unit(a - p), u2 = unit(b - p),
        th = acos(u1 * u2) / 2,
        t = r / tan(th),
        C = p + unit(u1 + u2) * r / sin(th),
        T1 = p + u1 * t, T2 = p + u2 * t,
        a1 = atan2(T1[1] - C[1], T1[0] - C[0]),
        a2 = atan2(T2[1] - C[1], T2[0] - C[0]),
        d0 = a2 - a1,
        d = d0 > 180 ? d0 - 360 : (d0 < -180 ? d0 + 360 : d0))
    [for (j = [0 : k]) C + r * [cos(a1 + d * j / k), sin(a1 + d * j / k)]];
// Tangentenlänge je Ecke, für die Kontrolle "Radien passen auf die Kante"
function tan_len(P, i, r) =
    let(a = P[(i - 1 + len(P)) % len(P)], p = P[i], b = P[(i + 1) % len(P)])
    r / tan(acos(unit(a - p) * unit(b - p)) / 2);
function round_poly(P, R) =
    [for (i = [0 : len(P) - 1]) each (R[i] > 0 ? round_corner(P, i, R[i]) : [P[i]])];
PROFILE_R = round_poly(PROFILE, PROFILE_RAD);

// Kabel verlässt den Stecker knapp über dessen Ende, Kanalboden darunter
cab_u = -plug_l + cable_d / 2 + 1;
cab_P = F(n_plug, cab_u);
channel_z0 = cab_P[1] - cable_d / 2 - 0.5;
channel_y0 = F(0, lip_h)[0] + 0.5;      // hinter der Lippe, schneidet sie nicht

pocket_w = pop_d + 2 * pop_clear;
pocket_dep = pop_h + pop_clear_back;
pocket_x0 = pop_x - pocket_w / 2;
pocket_x1 = pop_x + pocket_w / 2;

// Polygonfläche und Schwerpunkt (Shoelace)
function sumv(v, i = 0) = i >= len(v) ? 0 : v[i] + sumv(v, i + 1);
function cr(P, i) = let(a = P[i], b = P[(i + 1) % len(P)]) a[0] * b[1] - b[0] * a[1];
function parea(P) = sumv([for (i = [0 : len(P) - 1]) cr(P, i)]) / 2;
function pcent(P) = let(A = parea(P)) [
    sumv([for (i = [0 : len(P) - 1]) (P[i][0] + P[(i + 1) % len(P)][0]) * cr(P, i)]) / (6 * A),
    sumv([for (i = [0 : len(P) - 1]) (P[i][1] + P[(i + 1) % len(P)][1]) * cr(P, i)]) / (6 * A)];
// Polygon an der Halbebene p[ax] >= k abschneiden (Sutherland-Hodgman)
function clip_ge(P, ax, k) =
    [for (i = [0 : len(P) - 1])
        let(p = P[i], q = P[(i + 1) % len(P)], pin = p[ax] >= k, qin = q[ax] >= k)
        each concat(pin ? [p] : [],
                    pin != qin ? [p + (q - p) * ((k - p[ax]) / (q[ax] - p[ax]))] : [])];

// Schacht mit 45°-Fase (Gerätesystem n, u): Rechteck unter der Auflage plus
// Dreieck hinten, das die überstehende Stützenkante abträgt (QA-Befund 1)
ch_d = shaft_n1 - slot_w;   // Überstand der Stütze über dem Schacht
SHAFT_NU = [[shaft_n0, -shaft_d], [shaft_n1, -shaft_d], [shaft_n1, 0],
            [slot_w, ch_d], [shaft_n0, ch_d]];
// Anteil des Schachts, der im Material liegt (ohne den leeren Schlitz)
SHAFT_MAT = [for (p = [[shaft_n0, -shaft_d], [shaft_n1, -shaft_d], [shaft_n1, 0],
                       [slot_w, ch_d], [slot_w, 0], [shaft_n0, 0]]) F(p[0], p[1])];

// ---------------------------------------------------------------------------
// Kontrollen
// ---------------------------------------------------------------------------
assert(abs(slot_w - 15) <= 1 && slot_w >= 15, str("R2: Schlitz ", slot_w));
assert(stand_angle >= 60 && stand_angle <= 80, "Neigung unplausibel");
assert(stand_w <= dev_w, "R1: Ständer breiter als das Gerät");
assert(shaft_n0 >= -eps && shaft_n1 <= n_rear - min_w, "Schacht ragt aus Lippe/Stütze");
assert(shaft_d >= plug_l + 5, str("R6: Schacht zu flach für den Stecker: ", shaft_d));
assert(shaft_w >= plug_t + 2 * 2 && shaft_w >= cable_d + 2 * 2, "Schacht zu schmal");
assert(port_x - shaft_l / 2 >= sx0 + 10 && port_x + shaft_l / 2 <= sx1 - 10,
       "R4: Auflagen neben dem Schacht < 10 mm");
assert(shaft_l / 2 - plug_w / 2 >= 8, "R5: Schacht deckt Lageunsicherheit ±8 nicht ab");
assert(channel_x + channel_w / 2 <= port_x + shaft_l / 2 - 2, "Kanal liegt nicht am Schacht");
assert(channel_x - channel_w / 2 >= port_x + plug_w / 2 + 4, "Kanal zu nah am Stecker (Biegung)");
assert(channel_w >= cable_d + 1 && channel_w >= 5, "R7: Kanal zu schmal");
assert(channel_z0 >= floor_t, str("Kanalboden unter Bodenstärke: ", channel_z0));
assert(pocket_x0 >= sx0 + 2 * min_w, "Popsocket-Tasche schneidet die linke Ständerkante");
assert(pocket_x1 <= channel_x - channel_w / 2 - 2 * min_w, "Tasche zu nah am Kanal");
assert(back_t - pocket_dep >= 2 * min_w, str("Rest hinter der Tasche: ", back_t - pocket_dep));
assert(pop_u - pocket_w / 2 > 0 && pop_u + pocket_w / 2 < dev_h, "Popsocket außerhalb Gerät");
assert(back_h >= 90 && back_h < dev_h, "R10: Anlagehöhe");
assert(lip_t >= 2 * min_w && lip_h >= 8, "R9: Lippe");
assert(F(n_rear, u_J)[0] < base_d - 10, "Fußplatte hinter der Stütze zu kurz");
for (i = [0 : len(PROFILE) - 1]) if (PROFILE_RAD[i] > 0) {
    // Tangentenlängen benachbarter Ecken dürfen sich auf einer Kante nicht
    // überschneiden, sonst läuft die Kontur zurück
    j = (i + 1) % len(PROFILE);
    assert(tan_len(PROFILE, i, PROFILE_RAD[i]) + tan_len(PROFILE, j, PROFILE_RAD[j])
           <= norm(PROFILE[j] - PROFILE[i]) - 0.2, str("R16: Radius an Ecke ", i, " zu groß"));
    k = (i - 1 + len(PROFILE)) % len(PROFILE);
    assert(tan_len(PROFILE, i, PROFILE_RAD[i]) + tan_len(PROFILE, k, PROFILE_RAD[k])
           <= norm(PROFILE[k] - PROFILE[i]) - 0.2, str("R16: Radius an Ecke ", i, " zu groß"));
}
assert(foot_corner_r < base_d - F(n_rear, u_J)[0] && front_corner_r < port_x - shaft_l / 2 - sx0,
       "Eckradien zu groß");
// Kein Grat an den Wandköpfen neben der Tasche (QA _002 Befund 2): die Radien
// dürfen höchstens so groß sein wie die Wand, in die sie laufen
assert(top_corner_r <= pocket_x0 - sx0, str("Kopfradius seitlich > Rand links der Tasche: ",
       top_corner_r, " > ", pocket_x0 - sx0));
assert(PROFILE_RAD[4] <= back_t - pocket_dep, str("Kopfradius hinten > Restwand hinter der Tasche: ",
       PROFILE_RAD[4], " > ", back_t - pocket_dep));
// R10: gerade Anlagefläche endet dort, wo die Kopfrundung G beginnt
u_contact = back_h - tan_len(PROFILE, 5, PROFILE_RAD[5]);
contact_vert = F(slot_w, u_contact)[1] - F(slot_w, 0)[1];
assert(contact_vert >= 90, str("R10: Anlage senkrecht nur ", contact_vert, " mm"));
// Fase: Fläche im Gerätesystem 45° -> Winkel aus der Senkrechten in Weltkoordinaten
chamfer_vert = atan((ch_d * c - ch_d * s) / (ch_d * s + ch_d * c));
assert(chamfer_vert <= 45, str("R12: Schachtfase ", chamfer_vert, "° aus der Senkrechten"));
assert(max([for (p = PROFILE) p[0]]) <= bed && stand_w <= bed &&
       max([for (p = PROFILE) p[1]]) <= bed, "R13: größer als Bauraum");

// ---------------------------------------------------------------------------
// Kippen (R11). Konservativ: nur Gerät. Zusätzlich mit Ständermasse:
// Profil x Breite minus Schacht, Kanal und Tasche (QA-Befund 6). Die
// Eckrundungen in Vorder- und Draufsicht sind vernachlässigt (< 1 cm³).
// ---------------------------------------------------------------------------
function vol_cg(A, cg, w) = [abs(A) * w, cg];   // [mm³, [y, z]]
V_prof = vol_cg(parea(PROFILE_R), pcent(PROFILE_R), stand_w);
V_shaft = vol_cg(parea(SHAFT_MAT), pcent(SHAFT_MAT), shaft_l);
CH_PROF = clip_ge(clip_ge(PROFILE_R, 0, channel_y0), 1, channel_z0);
CH_SHAFT = clip_ge(clip_ge(SHAFT_MAT, 0, channel_y0), 1, channel_z0);
V_ch = [channel_w * (abs(parea(CH_PROF)) - abs(parea(CH_SHAFT))),
        (pcent(CH_PROF) * abs(parea(CH_PROF)) - pcent(CH_SHAFT) * abs(parea(CH_SHAFT)))
            / (abs(parea(CH_PROF)) - abs(parea(CH_SHAFT)))];
pr = pocket_w / 2;
pA1 = pocket_w * (back_h - pop_u);
pA2 = PI * pr * pr / 2;
p_uc = (pA1 * (pop_u + back_h) / 2 + pA2 * (pop_u - 4 * pr / (3 * PI))) / (pA1 + pA2);
V_pocket = [(pA1 + pA2) * pocket_dep, F(slot_w + pocket_dep / 2, p_uc)];
st_vol = V_prof[0] - V_shaft[0] - V_ch[0] - V_pocket[0];
st_cg = (V_prof[1] * V_prof[0] - V_shaft[1] * V_shaft[0] - V_ch[1] * V_ch[0]
         - V_pocket[1] * V_pocket[0]) / st_vol;
st_mass_g = st_vol / 1000 * rho_pla * fill;
dev_cg = F(n_dev0 + dev_t / 2, dev_h / 2);
tot_mass = dev_mass_g + st_mass_g;
tot_cg = (dev_cg * dev_mass_g + st_cg * st_mass_g) / tot_mass;
dev_top = F(n_dev0, dev_h);
tip_f_dev = atan(dev_cg[0] / dev_cg[1]);
tip_b_dev = atan((base_d - dev_cg[0]) / dev_cg[1]);
tip_f_tot = atan(tot_cg[0] / tot_cg[1]);
tip_b_tot = atan((base_d - tot_cg[0]) / tot_cg[1]);
push_b_g = tot_mass * (base_d - tot_cg[0]) / dev_top[1];   // horizontal an der Geräteoberkante
assert(tip_f_dev >= 15 && tip_b_dev >= 15,
       str("R11: Kippwinkel (nur Gerät) vorne ", tip_f_dev, "° hinten ", tip_b_dev, "°"));

echo(str("Schlitz ", slot_w, " mm, Neigung ", stand_angle, "°, Auflage auf z = ", Oz, " (vorne) bis ", F(slot_w, 0)[1]));
echo(str("Ständer: ", stand_w, " x ", base_d, " x ", max([for (p = PROFILE_R) p[1]]), " mm, Volumen ~",
         st_vol / 1000, " cm³, Masse ~", st_mass_g, " g (Füllung ", fill, ", Schätzung)"));
echo(str("Schacht ", shaft_l, " x ", shaft_w, " x ", shaft_d, ", Fase ", ch_d, " mm, ", chamfer_vert, "° aus der Senkrechten"));
echo(str("Tasche ", pocket_w, " breit, ", pocket_dep, " tief, Boden bei u = ", pop_u - pocket_w / 2,
         "; gerade Anlage bis u = ", u_contact, " (entlang), senkrecht ", contact_vert, " mm über der Auflage"));
echo(str("Kippen nur Gerät: vorne ", tip_f_dev, "°, hinten ", tip_b_dev, "°"));
echo(str("Kippen mit Ständer: vorne ", tip_f_tot, "°, hinten ", tip_b_tot, "°"));
echo(str("Schub an der Geräteoberkante nach hinten bis Kippen: ~", push_b_g, " g"));
echo(str("Kanal: x = ", channel_x, ", Boden z = ", channel_z0, ", Rest hinter Tasche ", back_t - pocket_dep, " mm"));

// ---------------------------------------------------------------------------
// Geometrie
// ---------------------------------------------------------------------------
// Gerätesystem: lokal x -> X, y -> n, z -> u
module in_dev() {
    multmatrix([[1, 0, 0, 0], [0, c, s, Oy], [0, -s, c, Oz], [0, 0, 0, 1]]) children();
}

module profile_solid() {
    translate([sx0, 0, 0]) rotate([90, 0, 90])
        linear_extrude(height = stand_w) polygon(PROFILE_R);
}

// Stützenkopf seitlich gerundet, Vorderansicht (x, u). Bogenmitte 0.5 über
// der Oberkante, damit keine Fläche genau auf der Kopffläche liegt (F7).
module top_round_2d() {
    r = top_corner_r;
    translate([sx0 - 10, -200]) square([stand_w + 20, 200 + back_h + 0.5 - r]);
    hull() {
        translate([sx0 + r, back_h + 0.5 - r]) circle(r = r);
        translate([sx1 - r, back_h + 0.5 - r]) circle(r = r);
    }
    translate([sx0 + r, back_h + 0.5 - r]) square([stand_w - 2 * r, r + 30]);
}
// Hintere Fußecken gerundet, Draufsicht (x, y)
module foot_round_2d() {
    r = foot_corner_r;
    translate([sx0 - 10, -10]) square([stand_w + 20, base_d + 10 - r + 0.2]);
    hull() {
        translate([sx0 + r, base_d + 0.2 - r]) circle(r = r);
        translate([sx1 - r, base_d + 0.2 - r]) circle(r = r);
    }
}
// Vordere Ecken und Lippenenden, Schnitt senkrecht zur Gerätefläche (x, n),
// entlang u extrudiert: die Front ist die Ebene n = -lip_t. Bogenmitte 0.2
// vor der Front (F7, s. o.).
module front_round_2d() {
    r = front_corner_r;
    n0 = -lip_t - 0.2;
    translate([sx0 - 10, n0 + r]) square([stand_w + 20, 400]);
    hull() {
        translate([sx0 + r, n0 + r]) circle(r = r);
        translate([sx1 - r, n0 + r]) circle(r = r);
    }
}

module stand() {
    difference() {
        intersection() {
            profile_solid();
            in_dev() rotate([90, 0, 0])
                linear_extrude(height = 400, center = true) top_round_2d();
            translate([0, 0, -1]) linear_extrude(height = bed) foot_round_2d();
            in_dev() translate([0, 0, -300]) linear_extrude(height = 600) front_round_2d();
        }
        // Steckerschacht mit Fase hinten (R4, R6, R12)
        in_dev() translate([port_x - shaft_l / 2, 0, 0]) rotate([90, 0, 90])
            linear_extrude(height = shaft_l) polygon(SHAFT_NU);
        // Kabelkanal nach hinten, oben offen (R7)
        translate([channel_x - channel_w / 2, channel_y0, channel_z0])
            cube([channel_w, base_d + 1 - channel_y0, bed]);
        // Popsocket-Tasche, oben offen, unten rund (R8)
        in_dev() {
            translate([pop_x, slot_w - 1, pop_u]) rotate([-90, 0, 0])
                cylinder(d = pocket_w, h = pocket_dep + 1);
            translate([pocket_x0, slot_w - 1, pop_u])
                cube([pocket_w, pocket_dep + 1, dev_h]);
        }
    }
}

// Dummies (nicht gedruckt)
module device(g = 0) {
    in_dev() {
        translate([g, n_dev0 + g, g]) cube([dev_w - 2 * g, dev_t - 2 * g, dev_h - 2 * g]);
        translate([pop_x, slot_w + g, pop_u]) rotate([-90, 0, 0])
            cylinder(d = pop_d, h = pop_h - g);
    }
}
module plug() {
    in_dev() translate([port_x - plug_w / 2, n_plug - plug_t / 2, -plug_l])
        cube([plug_w, plug_t, plug_l]);
}
module cable() {
    in_dev() translate([port_x, n_plug, cab_u]) rotate([0, 90, 0])
        cylinder(d = cable_d, h = channel_x - port_x);
    translate([channel_x, cab_P[0], cab_P[1]]) sphere(d = cable_d);
    translate([channel_x, cab_P[0], cab_P[1]]) rotate([-90, 0, 0])
        cylinder(d = cable_d, h = base_d + 20 - cab_P[0]);
}

fx0 = port_x - shaft_l / 2 - 8;
fx1 = port_x + shaft_l / 2 + 8;
fz1 = F(-lip_t, lip_h)[1] + 3;
fy1 = F(n_rear, u_J)[0] + 3;
module fit_test() {
    intersection() {
        stand();
        translate([fx0, -1, -1]) cube([fx1 - fx0, fy1 + 1, fz1 + 1]);
    }
}

if (part == "print") {
    color(col_stand) translate([-sx0, 0, 0]) render(convexity = 6) stand();
} else if (part == "stand") {
    color(col_stand) render(convexity = 6) stand();
} else if (part == "fit_test") {
    color(col_stand) translate([-fx0, 0, 0]) render(convexity = 6) fit_test();
} else if (part == "assembly") {
    color(col_stand) render(convexity = 6) stand();
    color("Gray", 0.6) device();
    color("White") plug();
    color("DimGray") cable();
} else if (part == "interference") {
    // Kontakt Gerät/Auflage/Stütze ist gewollt -> Dummies um 0.05 geschrumpft
    intersection() {
        stand();
        union() { device(0.05); plug(); cable(); }
    }
}
