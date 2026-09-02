# Rule: verify-parametric-geometry

Before presenting a parametric or organic contour with a mechanical
constraint (e.g. a contour that must stay clear of a clamp radius, a
bore, or a fitting) as done, the constraint must be verified across the
full parameter range — a fine-grained sweep (e.g. `echo()` over 0.25°
steps for an angular contour), not a handful of spot-checked angles.
Wavy/organic formulas (sums of sines, phase-shifted harmonics) can
violate a constraint at an arbitrary point where phases happen to
align; a few manually-checked angles reliably miss it.

The sweep must also check the step-to-step change, not just the value
at each point: a hard clamp/cap that cuts off abruptly at a fixed
angle (rather than relaxing smoothly) can be invisible at small
amplitude and turn into a multi-mm spike the moment the amplitude is
increased later, since the jump size scales with amplitude while the
clamp boundary doesn't move. Flag any adjacent-sample jump far above
what the sample step alone would explain (e.g. `abs(r[i+1] - r[i])`
across the full sweep) — this is what actually caught that failure
mode in practice, not the boundary-value check alone.

Not every "growth" a user reports is invalid geometry — a smooth,
non-self-intersecting local peak can still look like a defect if it's
disproportionate to its surroundings (e.g. a contour swelling to 2x
its neighboring radius within a few degrees, right next to a
deliberately narrow feature). Check for this directly: flag any point
whose value is far above both its ±15°(or equivalent) neighbors. When
found, prefer scaling the perturbation's amplitude *proportionally* to
the local base geometry (e.g. `wave * (base(θ)/front_r)`) over damping
it with a fixed-width envelope — an envelope's width and the base
shape's growth rate are unrelated parameters that easily mismatch,
reintroducing disproportionate bumps wherever the base is still small
at the point the envelope reaches full strength.

Manifoldness must be verified via the OpenSCAD CLI, not the editor
preview: `openscad -o out.stl file.scad` and check the console stats
for `Simple: yes` and the expected `Volumes` count (2 for a single
watertight part: interior + exterior; a higher count usually means a
disconnected piece, even if the shape "looks" joined in a screenshot).
A cross-section check (`projection(cut=true)` at representative
heights) catches artifacts that `Volumes` alone misses, such as a
technically-connected sliver that reads as broken to the eye.
