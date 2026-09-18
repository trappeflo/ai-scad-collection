// Vertikaler Laptop-/Tablet-Ständer, 2 Schlitze in einem Teil
// Alle Maße in Millimetern (Regel: units-mm)
//
// Änderungen gegenüber 002 (Nutzerwunsch: weniger klobig, kürzer):
//   - Obere Ecken der Rippen gerundet (top_r). Das ist rein optisch, nimmt
//     der Silhouette die Klotzigkeit und kostet nur ~2 cm³ Material.
//   - Körper 130 -> 100 mm kurz. Damit die Längsstabilität dabei NICHT
//     mitschrumpft, steht die Fußleiste jetzt auch nach vorn und hinten
//     über (foot_flare_y). Aufstandstiefe 116 mm bei nur 100 mm sichtbarem
//     Körper -> der erlaubte Längsversatz bleibt praktisch gleich, das Teil
//     wirkt aber deutlich kürzer.
//
// Änderungen in 002 gegenüber 001 (Statik nachgerechnet, siehe Lastfälle):
//   - Fußleiste: unten 8 mm pro Seite Überstand, nach oben auf Körperbreite
//     auslaufend. Aufstandsbreite 68.8 mm, der Körper bleibt oben 52.8 mm.
//     Grund: der kritische Lastfall ist NICHT die Rippenfestigkeit, sondern
//     Kippen. Nur die Aufstandsbreite hilft dagegen nennenswert.
//   - base_d 110 -> 130 mm gegen Kippen in Längsrichtung.
//   - floor_t 5 -> 6 mm. Der Sockel ist jetzt die Fußleiste, die äußere
//     Lippe soll nicht zu dünn auslaufen.
//
// Kontext (Regel: context-first), Stand bei Erstellung:
//   - context/printer.md:    Anycubic Kobra S1, 0.4mm Düse, PEI, 250mm Bauraum
//   - context/tolerances.md: eff. XY-Fehler ~0.15–0.2mm/Seite. Hier irrelevant
//                            für die Funktion (kein Passsitz), aber er macht
//                            die Schlitze real ~0.3–0.4mm schmaler als nominal
//                            -> im Puffer unten schon berücksichtigt.
//   - context/materials.md:  noch leer -> PLA angenommen
//
// Anforderungen aus dem Design-Dialog:
//   - Laptop 20mm dick, "ein wenig Puffer" -> 2.0mm Luft pro Seite
//   - iPad 15mm dick (mit Hülle)           -> 1.5mm Luft pro Seite
//   - Ein Teil, beide Schlitze nebeneinander
//   - Geräte stehen senkrecht, straff geführt (keine Neigung)
//   - Minimalistisch und schmal: auf dem Schreibtisch ist wenig Breite frei
//   - Nachgereicht: Kippsicherheit wichtiger als die letzten 16mm Breite,
//     solange der Körper oben schmal bleibt
//
// Aufbau / Prinzip:
//   Eine Fußleiste (foot_h hoch, ringsum überstehend) trägt den Sockel mit
//   drei aufstehenden Rippen. Dazwischen die beiden Schlitze. Die Schlitze
//   laufen in Y komplett durch (vorne und hinten offen) – das spart
//   Material, macht das Teil leichter zu reinigen und erlaubt es, den Laptop
//   von jeder Seite einzuschieben.
//
//   Der Fuß steht in ALLE vier Richtungen über, nicht nur seitlich. Das ist
//   der Trick, mit dem der Körper kurz sein darf: die Kippkanten liegen
//   trotzdem weit außen. Optisch zählt die Länge der Rippen (100 mm), für
//   die Statik zählt die Aufstandsfläche (116 mm).
//
//   Die schmale Seite (X) zeigt zum Nutzer, die lange Seite (Y, base_d) geht
//   in die Tischtiefe. Der Laptop steht also mit seiner Breitseite (~31cm)
//   in Y -> auf dem Tisch verbraucht der Ständer nur ~7cm Breite.
//
//   Schlitzmund und obere Außenkanten sind angefast (mouth_c/edge_c), der
//   Schlitzgrund hat eine Hohlkehle (fillet_r).
//
// ---------------------------------------------------------------------------
// LASTFÄLLE (nachgerechnet, nicht geschätzt)
// ---------------------------------------------------------------------------
//
// 1) Rippe auf Biegung – unkritisch, mit großem Abstand.
//    Rippe = einseitig eingespannter Balken, Länge wall_h, Querschnitt
//    base_d x wall_t. Die Biegespannung an der Wurzel wirkt in Z-Richtung,
//    also QUER zu den Layern -> maßgebend ist die Layerhaftung, konservativ
//    25 MPa (massives PLA hätte ~50).
//      Außenrippe 3.2mm: Bruch erst bei ~92 N Horizontalkraft an der
//                        Rippenoberkante (~9 kg).
//      Mittelrippe 4.4mm: ~175 N (~18 kg).
//    Real wirkt dort: der Laptop lehnt sich im Schlitzspiel (3.8°) an die
//    Rippe -> ~2.2 N, Durchbiegung ~0.12 mm. Sicherheitsfaktor ~40.
//    Das Eigengewicht (1.8kg senkrecht auf 24 x 130 mm Auflage) erzeugt
//    0.006 MPa Druckspannung – irrelevant.
//    -> Die Rippen sind nicht die Schwachstelle. Nicht dünner machen als
//       3.2/4.4, aber dicker bringt nichts außer Breite.
//
// 2) Kippen – das ist der kritische Lastfall.
//    Ungünstig ist NUR der Laptop im linken Schlitz: dann sitzt der
//    Schwerpunkt seitlich außermittig. Die echten Zahlen rechnet der
//    echo()-Block unten aus den aktuellen Parametern aus.
//    Mit 001 (52.8mm breit) warf ihn ein Schubs von ~130 g oben am Laptop
//    um. Mit der Fußleiste sind es ~200 g.
//    Ballast hilft kaum: 150 g Stahl mittig im Sockel bringen nur +14 %,
//    weil mittig eingebaute Masse den Hebelarm nicht verlängert.
//    Nur die Aufstandsbreite zählt.
//
// Druckausrichtung: So wie das Teil steht, Fußunterseite aufs Bett.
//   Keine Stützen nötig: die Schlitze öffnen nach oben, alle Fasen und die
//   Fußschräge sind nach oben gerichtete Flächen, es gibt keine Brücke und
//   keinen Überhang. Auch die Eckenrundung oben ist überhangfrei: sie nimmt
//   nach oben ab, jede Lage ist kleiner als die darunter.
//   Die plane 68.8 x 116mm Fläche auf PEI = sehr gute Haftung.
//   Empfehlung: Infill >= 30%. Layerrichtung: die Rippen werden liegend
//   aufgebaut, seitliche Belastung zieht quer zu den Layern – deshalb die
//   konservative Rechnung oben mit 25 MPa.
//
// Nach dem Druck: 4 Filzgleiter unter den Fuß kleben. Das schützt den Tisch
//   und verhindert, dass der Ständer beim Einschieben wegrutscht.
//
// Anpassen: Laptop dicker/dünner -> nur laptop_t ändern, alles andere
//   rechnet sich mit (auch die Kipp-Rechnung im echo()).

/* [Geräte] */
// Dicke des Laptops (gemessen, geschlossen)
laptop_t = 20;
// Luft pro Seite im Laptop-Schlitz
laptop_gap = 2.0;
// Dicke des iPads inkl. Hülle
ipad_t = 15;
// Luft pro Seite im iPad-Schlitz
ipad_gap = 1.5;
// Zweiten Schlitz überhaupt bauen
ipad_slot_on = true;

/* [Geräte-Annahmen für die Kipp-Rechnung] */
// Masse des Laptops in Gramm (14-Zoll-Klasse). Nur für echo(), nicht für
// die Geometrie – bei Bedarf mit dem echten Wert überschreiben.
laptop_mass_g = 1800;
// Höhe des geschlossenen Laptops, auf der Kante stehend
laptop_dev_h = 220;
// Masse des iPads inkl. Hülle in Gramm
ipad_mass_g = 700;
// Höhe des iPads, auf der Kante stehend
ipad_dev_h = 180;

/* [Ständer] */
// Wandstärke der beiden Außenrippen. Muss dicker sein als mouth_c + edge_c,
// sonst läuft die Rippe oben auf eine Schneide aus (siehe assert unten).
wall_t = 3.2;
// Wandstärke der Mittelrippe (trennt beide Schlitze, trägt von zwei Seiten)
mid_wall = 4.4;
// Höhe der Rippen über dem Schlitzgrund = Einstecktiefe des Geräts
wall_h = 60;
// Dicke des massiven Sockels unter den Schlitzen (= Höhe der Fußleiste)
floor_t = 6.0;
// Tiefe des sichtbaren Körpers (Y, in die Tischtiefe). Das ist das Maß, das
// das Teil "lang" aussehen lässt – die Standfestigkeit hängt am Fuß, nicht
// hieran.
base_d = 100;

/* [Fußleiste] */
// Überstand der Fußleiste pro Seite in X. Das ist der einzige wirksame
// Hebel gegen seitliches Kippen – siehe Lastfall 2 im Kopf.
foot_flare = 8.0;
// Überstand der Fußleiste nach vorn und hinten. Hält den erlaubten
// Längsversatz oben, obwohl der Körper kurz ist.
foot_flare_y = 8.0;
// Höhe der Fußleiste. Muss <= floor_t bleiben, sonst ragt sie in die
// Schlitze (siehe assert unten).
foot_h = 6.0;
// Davon der untere, senkrechte Teil. Der Rest läuft schräg nach oben auf
// Körperbreite aus. Nicht auf 0 setzen: die äußere Lippe würde sonst
// spitz auslaufen und beim ersten Anstoßen abbrechen.
foot_straight = 2.5;

/* [Kanten] */
// Fase am Schlitzmund (Einführhilfe – die funktionale Fase)
mouth_c = 1.2;
// Fase an den oberen Außenkanten (nur Optik/Haptik, deshalb kleiner:
// mouth_c + edge_c fressen sonst die Rippe oben komplett auf)
edge_c = 0.8;
// Hohlkehle am Schlitzgrund (Kerbspannung an der Rippenwurzel)
fillet_r = 2.0;
// Radius der senkrechten Außenkanten
corner_r = 3.0;
// Radius der oberen Ecken in der Seitenansicht (vorn und hinten oben).
// Rein optisch: nimmt der Silhouette die Klotzigkeit. 0 = eckig wie 002.
top_r = 20.0;

/* [Qualität] */
$fn = 48;

// ---------------------------------------------------------------------------
// Abgeleitete Maße
// ---------------------------------------------------------------------------

laptop_w = laptop_t + 2 * laptop_gap;   // lichte Schlitzbreite Laptop
ipad_w   = ipad_t   + 2 * ipad_gap;     // lichte Schlitzbreite iPad

// X-Positionen der Rippen-/Schlitzkanten, von links (0 = linke Körperkante)
x1 = wall_t;                                            // Laptop-Schlitz links
x2 = x1 + laptop_w;                                     // Laptop-Schlitz rechts
x3 = x2 + (ipad_slot_on ? mid_wall : 0);                // iPad-Schlitz links
x4 = x3 + (ipad_slot_on ? ipad_w : 0);                  // iPad-Schlitz rechts

total_w = x4 + wall_t;                  // Körperbreite oben
total_h = floor_t + wall_h;
foot_w  = total_w + 2 * foot_flare;     // Aufstandsbreite unten
foot_d  = base_d  + 2 * foot_flare_y;   // Aufstandstiefe unten

// ---------------------------------------------------------------------------
// Kipp-Rechnung: Schwerpunkt der Einheit Ständer + Gerät(e)
// ---------------------------------------------------------------------------
// Alle x-Werte ab der LINKEN KANTE DER AUFSTANDSFLÄCHE, damit die Abstände
// direkt die Hebelarme zur Kippkante sind. Der Körper beginnt also bei
// x = foot_flare.

// Eigenmasse, grob: Volumen mal PLA-Dichte mal effektive Füllung. Die Rippen
// drucken bei 3.2/4.4mm Wandstärke praktisch massiv, der Sockel nicht ->
// ~0.6 im Mittel. Nur für die Rechnung, nicht kritisch.
rib_t      = 2 * wall_t + (ipad_slot_on ? mid_wall : 0);   // Summe der Rippendicken
vol_body   = total_w * base_d * floor_t + rib_t * base_d * wall_h;
// Fuß: Ring um den Körper, im Mittel auf halber Schrägenhöhe
foot_mid_h = foot_straight + (foot_h - foot_straight) / 2;
vol_foot   = (foot_w * foot_d - total_w * base_d) * foot_mid_h;
// Was die Eckenrundung oben wegnimmt: pro Ecke r^2 * (1 - pi/4), zwei Ecken,
// über die Summe der Rippendicken.
vol_round  = 2 * top_r * top_r * (1 - PI/4) * rib_t;
stand_g    = (vol_body + vol_foot - vol_round) * 1.24e-3 * 0.6;

x_laptop   = foot_flare + x1 + laptop_w / 2;   // Schlitzmitte Laptop
x_ipad     = foot_flare + x3 + ipad_w / 2;     // Schlitzmitte iPad

// Schwerpunkt für eine Lastkombination. Rückgabe: [Masse, x, z]
function cog(ms, xs, zs) =
    let (M = ms[0] + ms[1] + ms[2])
    [ M,
      (ms[0]*xs[0] + ms[1]*xs[1] + ms[2]*xs[2]) / M,
      (ms[0]*zs[0] + ms[1]*zs[1] + ms[2]*zs[2]) / M ];

// Kippwinkel = atan(Hebelarm zur nächsten Kippkante / Schwerpunkthöhe)
function tip_angle(c) = atan(min(c[1], foot_w - c[1]) / c[2]);
// Horizontalkraft oben am Gerät, die zum Umkippen reicht, in Gramm-Äquivalent
function tip_push_g(c, push_h) = c[0] * min(c[1], foot_w - c[1]) / push_h;

c_lap  = cog([stand_g, laptop_mass_g, 0],
             [foot_w/2, x_laptop, 0],
             [floor_t * 0.9, floor_t + laptop_dev_h/2, 0]);
c_both = cog([stand_g, laptop_mass_g, ipad_mass_g],
             [foot_w/2, x_laptop, x_ipad],
             [floor_t * 0.9, floor_t + laptop_dev_h/2, floor_t + ipad_dev_h/2]);

// Längskippen: wie weit darf der Laptop in Y aus der Mitte stehen. Maßgebend
// ist die Aufstandstiefe des Fußes, nicht die Körpertiefe.
y_off_max = (foot_d / 2) * c_lap[0] / laptop_mass_g;

// Spiel des Geräts im Schlitz: um so viel Grad kann es im Schlitz kippeln
play_deg_l = atan(2 * laptop_gap / wall_h);
play_deg_i = atan(2 * ipad_gap / wall_h);

// Rippenfestigkeit (Lastfall 1): Bruchkraft an der Rippenoberkante.
// W = Widerstandsmoment des Rippenquerschnitts, sigma_z = Layerhaftung.
sigma_z   = 25;    // MPa, konservativ für PLA quer zu den Layern
f_break_o = sigma_z * (base_d * wall_t   * wall_t   / 6) / wall_h;
f_break_m = sigma_z * (base_d * mid_wall * mid_wall / 6) / wall_h;

// ---------------------------------------------------------------------------
// Prüfungen (Regel: printability-report – wird gemeldet, nicht stillschweigend
// korrigiert)
// ---------------------------------------------------------------------------

nozzle_d = 0.4;

// Restbreite der Rippen ganz oben, nachdem die Fasen abgezogen sind. Das ist
// die kritische Größe: läuft eine Rippe oben auf eine Schneide aus, kann der
// Drucker die letzten Layer nicht mehr sauber legen und die Kante wird
// ausgefranst und bröselig.
outer_top_w = wall_t   - mouth_c - edge_c;
mid_top_w   = mid_wall - 2 * mouth_c;

assert(wall_t   >= 2 * nozzle_d, "wall_t unter 2x Duesendurchmesser");
assert(mid_wall >= 2 * nozzle_d, "mid_wall unter 2x Duesendurchmesser");
assert(floor_t  >= 2 * nozzle_d, "floor_t unter 2x Duesendurchmesser");
assert(fillet_r <= wall_h,       "fillet_r groesser als die Rippenhoehe");
assert(outer_top_w >= 2 * nozzle_d,
       "Aussenrippe laeuft oben spitz zu: wall_t erhoehen oder Fasen kleiner");
assert(!ipad_slot_on || mid_top_w >= 2 * nozzle_d,
       "Mittelrippe laeuft oben spitz zu: mid_wall erhoehen oder mouth_c kleiner");
assert(mouth_c * 2 < min(laptop_w, ipad_slot_on ? ipad_w : 1e9),
       "mouth_c zu gross - die Fasen fressen den Schlitz auf");
assert(foot_h <= floor_t,
       "foot_h groesser als floor_t - die Fussleiste ragt in die Schlitze");
assert(foot_straight > 0 && foot_straight <= foot_h,
       "foot_straight muss zwischen 0 und foot_h liegen");
assert(foot_straight >= 2 * nozzle_d,
       "Fusslippe laeuft spitz aus: foot_straight erhoehen");
assert(corner_r <= foot_w / 2 && corner_r <= base_d / 2,
       "corner_r groesser als das halbe Teil");
assert(top_r <= wall_h,
       "top_r groesser als die Rippenhoehe - die Rundung frisst den Sockel an");
assert(top_r <= base_d / 2,
       "top_r groesser als die halbe Koerpertiefe - die Rundungen ueberlappen");
assert(foot_w <= 250 && foot_d <= 250 && total_h <= 250,
       "passt nicht auf das Druckbett (250 x 250 x 250)");

echo(str("Koerper: ", total_w, " x ", base_d, " mm, Hoehe ", total_h, " mm"));
echo(str("Aufstandsflaeche (Fuss): ", foot_w, " x ", foot_d, " mm"));
echo(str("Schlitz Laptop: ", laptop_w, " mm lichte Weite fuer ", laptop_t, " mm Geraet"));
echo(str("Schlitz iPad:   ", ipad_slot_on ? ipad_w : 0, " mm lichte Weite fuer ", ipad_t, " mm Geraet"));
echo(str("Rippenbreite oben nach Fasen: aussen ", outer_top_w, " mm, mitte ", mid_top_w, " mm"));
echo(str("Staender-Eigenmasse (geschaetzt, 30% Infill): ", round(stand_g), " g"));
echo(str("Lastfall 1 Rippenbruch: aussen ", round(f_break_o), " N, mitte ",
         round(f_break_m), " N an der Rippenoberkante"));
echo(str("Lastfall 2 Kippen, NUR Laptop links: ", tip_angle(c_lap),
         " Grad, Schubs oben ", round(tip_push_g(c_lap, floor_t + laptop_dev_h)), " g"));
echo(str("Lastfall 2 Kippen, beide Geraete:    ", tip_angle(c_both),
         " Grad, Schubs oben ", round(tip_push_g(c_both, floor_t + laptop_dev_h)), " g"));
echo(str("Laengskippen: Laptop darf max ", round(y_off_max), " mm aus der Mitte stehen"));
echo(str("Kippeln im Schlitz: Laptop ", play_deg_l, " Grad, iPad ", play_deg_i, " Grad"));

// ---------------------------------------------------------------------------
// 2D-Querschnitt des Körpers (X = Breite, Y der 2D-Ebene = Höhe Z des Teils)
// ---------------------------------------------------------------------------

// Material, das in eine Innenecke des Schlitzgrunds zurückgelegt wird:
// Quadrat minus Kreis = Hohlkehle. dir = +1 linke Ecke, -1 rechte Ecke.
module fillet_piece(x, dir) {
    r = fillet_r;
    translate([x, floor_t])
        difference() {
            translate([dir > 0 ? 0 : -r, 0]) square([r, r]);
            translate([dir * r, r]) circle(r = r);
        }
}

// Schnittfigur eines Schlitzes: Rechteck nach oben offen + Trichter am Mund.
module slot_cut(a, b) {
    c = mouth_c;
    union() {
        translate([a, floor_t]) square([b - a, total_h - floor_t + 1]);
        polygon([
            [a,     total_h - c],
            [b,     total_h - c],
            [b + c, total_h    ],
            [b + c, total_h + 1],
            [a - c, total_h + 1],
            [a - c, total_h    ]
        ]);
    }
}

module profile() {
    c = edge_c;
    union() {
        difference() {
            square([total_w, total_h]);

            slot_cut(x1, x2);
            if (ipad_slot_on) slot_cut(x3, x4);

            // Fasen an den oberen Außenkanten
            polygon([[-1, total_h - c], [c, total_h],
                     [c, total_h + 1], [-1, total_h + 1]]);
            polygon([[total_w + 1, total_h - c], [total_w - c, total_h],
                     [total_w - c, total_h + 1], [total_w + 1, total_h + 1]]);
        }

        // Hohlkehlen am Schlitzgrund
        fillet_piece(x1,  1);
        fillet_piece(x2, -1);
        if (ipad_slot_on) {
            fillet_piece(x3,  1);
            fillet_piece(x4, -1);
        }
    }
}

// ---------------------------------------------------------------------------
// Körper
// ---------------------------------------------------------------------------

// Prisma mit gerundeten senkrechten Kanten, Ursprung linke vordere Ecke
module rounded_prism(w, d, h) {
    linear_extrude(height = h)
        offset(r = corner_r) offset(delta = -corner_r)
            square([w, d]);
}

// Der eigentliche Ständer, ohne Fuß. Sitzt bei x = 0 .. total_w.
module koerper() {
    intersection() {
        // Querschnitt entlang Y ausziehen
        rotate([90, 0, 0])
            translate([0, 0, -base_d])
                linear_extrude(height = base_d)
                    profile();

        translate([0, 0, -1]) rounded_prism(total_w, base_d, total_h + 2);
    }
}

// Fußleiste: unten foot_straight senkrecht auf voller Aufstandsfläche,
// darüber per hull() ringsum schräg auf den Körpergrundriss auslaufend.
// hull() zwischen den beiden Scheiben übernimmt automatisch die
// Eckenrundung beider Grundrisse.
module fuss() {
    eps = 0.01;
    hull() {
        translate([-foot_flare, -foot_flare_y, 0])
            rounded_prism(foot_w, foot_d, foot_straight);
        translate([0, 0, foot_h - eps])
            rounded_prism(total_w, base_d, eps);
    }
}

// Schnittmaske für die gerundeten oberen Ecken in der Seitenansicht.
// 2D in (Y, Z), danach nach X ausgezogen. Unten bewusst über den Fuß hinaus
// verbreitert, damit die Maske dort nichts abschneidet.
module top_round_mask() {
    m = foot_flare_y + 1;
    w = foot_w + 2;
    rotate([90, 0, 90])
        translate([0, 0, -foot_flare - 1])
            linear_extrude(height = w)
                union() {
                    offset(r = top_r) offset(delta = -top_r)
                        square([base_d, total_h]);
                    translate([-m, 0]) square([base_d + 2 * m, total_h - top_r]);
                }
}

module staender() {
    render(convexity = 10)
        intersection() {
            union() {
                koerper();
                fuss();
            }
            if (top_r > 0) top_round_mask();
            else translate([-foot_flare - 1, -foot_flare_y - 1, -1])
                     cube([foot_w + 2, foot_d + 2, total_h + 2]);
        }
}

// Auf false setzen (oder per CLI -D render_part=false), wenn die Datei nur
// als Modulquelle für Schnitt-/Prüfskripte eingebunden wird.
render_part = true;
if (render_part) staender();
