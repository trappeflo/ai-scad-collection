// Vertikaler Laptop-/Tablet-Ständer, 2 Schlitze in einem Teil
// Alle Maße in Millimetern (Regel: units-mm)
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
//
// Aufbau / Prinzip:
//   Ein massiver Sockel (floor_t) mit drei aufstehenden Rippen. Dazwischen
//   die beiden Schlitze. Die Schlitze laufen in Y komplett durch (vorne und
//   hinten offen) – das spart Material, macht das Teil leichter zu reinigen
//   und erlaubt es, den Laptop von jeder Seite einzuschieben.
//
//   Die schmale Seite (X, total_w ~52mm) zeigt zum Nutzer, die lange Seite
//   (Y, base_d 110mm) geht in die Tischtiefe. Der Laptop steht also mit
//   seiner Breitseite (~31cm) in Y -> auf dem Tisch verbraucht der Ständer
//   nur ~5cm Breite.
//
//   Schlitzmund und obere Außenkanten sind angefast (mouth_c), der
//   Schlitzgrund hat eine Hohlkehle (fillet_r). Die Fase erleichtert das
//   Einstellen ohne hinzusehen, die Hohlkehle nimmt die Biegespannung an
//   der Rippenwurzel auf – das ist die Stelle, an der so ein Ständer
//   bricht, wenn man seitlich gegen den Laptop kommt.
//
// Druckausrichtung: So wie das Teil steht, Sockelunterseite aufs Bett.
//   Keine Stützen nötig: die Schlitze öffnen nach oben, alle Fasen sind
//   45°-Flächen nach oben, es gibt keine Brücke und keinen Überhang.
//   Die plane 52 x 110mm Fläche auf PEI = sehr gute Haftung.
//   Empfehlung: Infill hoch (>=30%) oder mehr Perimeter – das Gewicht im
//   Sockel ist hier Funktion, nicht Verschwendung (Kippsicherheit).
//   Layerrichtung: die Rippen werden liegend aufgebaut, seitliche
//   Belastung zieht quer zu den Layern. Deshalb sind die Rippen mit 3–4mm
//   bewusst dick und haben unten die Hohlkehle.
//
// Nach dem Druck: 4 Filzgleiter unter den Sockel kleben. Das schützt den
//   Tisch und verhindert, dass der Ständer beim Einschieben wegrutscht.
//
// Anpassen: Laptop dicker/dünner -> nur laptop_t ändern, alles andere
//   rechnet sich mit. Wenn nur ein Gerät rein soll: ipad_slot_on = false.

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

/* [Ständer] */
// Wandstärke der beiden Außenrippen. Muss dicker sein als mouth_c + edge_c,
// sonst läuft die Rippe oben auf eine Schneide aus (siehe assert unten).
wall_t = 3.2;
// Wandstärke der Mittelrippe (trennt beide Schlitze, trägt von zwei Seiten)
mid_wall = 4.4;
// Höhe der Rippen über dem Schlitzgrund = Einstecktiefe des Geräts
wall_h = 60;
// Dicke des massiven Sockels unter den Schlitzen
floor_t = 5.0;
// Tiefe des Ständers (Y, in die Tischtiefe)
base_d = 110;

/* [Kanten] */
// Fase am Schlitzmund (Einführhilfe – die funktionale Fase)
mouth_c = 1.2;
// Fase an den oberen Außenkanten (nur Optik/Haptik, deshalb kleiner:
// mouth_c + edge_c fressen sonst die Rippe oben komplett auf)
edge_c = 0.8;
// Hohlkehle am Schlitzgrund (Kerbspannung an der Rippenwurzel)
fillet_r = 2.0;
// Radius der vier senkrechten Außenkanten
corner_r = 3.0;

/* [Qualität] */
$fn = 48;

// ---------------------------------------------------------------------------
// Abgeleitete Maße
// ---------------------------------------------------------------------------

laptop_w = laptop_t + 2 * laptop_gap;   // lichte Schlitzbreite Laptop
ipad_w   = ipad_t   + 2 * ipad_gap;     // lichte Schlitzbreite iPad

// X-Positionen der Rippen-/Schlitzkanten, von links
x1 = wall_t;                                            // Laptop-Schlitz links
x2 = x1 + laptop_w;                                     // Laptop-Schlitz rechts
x3 = x2 + (ipad_slot_on ? mid_wall : 0);                // iPad-Schlitz links
x4 = x3 + (ipad_slot_on ? ipad_w : 0);                  // iPad-Schlitz rechts

total_w = x4 + wall_t;
total_h = floor_t + wall_h;

// Kippsicherheit: Winkel, um den das Gerät+Ständer als Ganzes gekippt werden
// muss, bis der Schwerpunkt über die Sockelkante wandert. Schwerpunkt grob in
// halber Gerätehöhe angenommen (Laptop geschlossen ~220mm hoch).
device_h   = 220;
cog_z      = floor_t + device_h / 2;
tip_deg    = atan((total_w / 2) / cog_z);
// Spiel des Geräts im Schlitz: um so viel Grad kann es im Schlitz kippeln
play_deg_l = atan(2 * laptop_gap / wall_h);
play_deg_i = atan(2 * ipad_gap / wall_h);

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
assert(corner_r <= total_w / 2 && corner_r <= base_d / 2,
       "corner_r groesser als das halbe Teil");
assert(total_w <= 250 && base_d <= 250 && total_h <= 250,
       "passt nicht auf das Druckbett (250 x 250 x 250)");

echo(str("Aussenmasse (B x T x H): ", total_w, " x ", base_d, " x ", total_h, " mm"));
echo(str("Schlitz Laptop: ", laptop_w, " mm lichte Weite fuer ", laptop_t, " mm Geraet"));
echo(str("Schlitz iPad:   ", ipad_slot_on ? ipad_w : 0, " mm lichte Weite fuer ", ipad_t, " mm Geraet"));
echo(str("Kippwinkel Ganzes (Schwerpunkt ", cog_z, " mm hoch): ", tip_deg, " Grad"));
echo(str("Kippeln im Schlitz: Laptop ", play_deg_l, " Grad, iPad ", play_deg_i, " Grad"));
echo(str("Rippenbreite oben nach Fasen: aussen ", outer_top_w, " mm, mitte ", mid_top_w, " mm"));

// ---------------------------------------------------------------------------
// 2D-Querschnitt (X = Breite, Y der 2D-Ebene = Höhe Z des Teils)
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

// Grundriss mit gerundeten senkrechten Kanten (als Schnittkörper)
module footprint_prism() {
    linear_extrude(height = total_h + 2)
        offset(r = corner_r) offset(delta = -corner_r)
            square([total_w, base_d]);
}

module staender() {
    render(convexity = 8)
        intersection() {
            // Querschnitt entlang Y ausziehen
            rotate([90, 0, 0])
                translate([0, 0, -base_d])
                    linear_extrude(height = base_d)
                        profile();

            translate([0, 0, -1]) footprint_prism();
        }
}

// Auf false setzen (oder per CLI -D render_part=false), wenn die Datei nur
// als Modulquelle für Schnitt-/Prüfskripte eingebunden wird.
render_part = true;
if (render_part) staender();
