// Technischer Testdurchstich: prüft, ob SCAD-Dateien korrekt erstellt werden
// und sich im VS-Code-Preview rendern lassen.

r = 2;

translate([10, 10, 10])
minkowski() {
    cube(20 - 2 * r, center = true);
    sphere(r, $fn = 32);
}
