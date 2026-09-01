# Rule: verify-parametric-geometry

Before presenting a parametric or organic contour with a mechanical
constraint (e.g. a contour that must stay clear of a clamp radius, a
bore, or a fitting) as done, the constraint must be verified across the
full parameter range — a fine-grained sweep (e.g. `echo()` over 0.25°
steps for an angular contour), not a handful of spot-checked angles.
Wavy/organic formulas (sums of sines, phase-shifted harmonics) can
violate a constraint at an arbitrary point where phases happen to
align; a few manually-checked angles reliably miss it.

Manifoldness must be verified via the OpenSCAD CLI, not the editor
preview: `openscad -o out.stl file.scad` and check the console stats
for `Simple: yes` and the expected `Volumes` count (2 for a single
watertight part: interior + exterior; a higher count usually means a
disconnected piece, even if the shape "looks" joined in a screenshot).
A cross-section check (`projection(cut=true)` at representative
heights) catches artifacts that `Volumes` alone misses, such as a
technically-connected sliver that reads as broken to the eye.
