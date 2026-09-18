# Skill: modeling

## Purpose

Translates the previously gathered requirements into OpenSCAD code.

## Usage

- Creates a new, versioned file in `scad/draft/` 
  (format: `object-name_001.scad`, see rule `versioning`).
- Assumes requirements have already been clarified via the 
  `design-conversation` skill.
- Assumes `context/printer.md`, `context/tolerances.md`, and 
  `context/materials.md` have been read (see rule `context-first`).
- Follows the `units-mm` rule.
- Before delivery, follows rule `verify-parametric-geometry` for any
  parametric/organic contour with a mechanical constraint.

## Technique notes (learned from past bugs)

- **Avoid `offset()` on wavy/concave 2D contours.** It is numerically
  fragile on non-convex shapes and can silently produce disconnected
  or self-intersecting geometry. For a star-shaped profile (single
  radius per angle), compute the inset boundary directly from the same
  `r(θ)` function (`r(θ) - wall_t`) instead of calling `offset()`.
- **Hollow ≠ filled shape.** A cavity that should only start beyond
  some inner radius (e.g. "hollow everywhere except within the clamp
  radius") must be built as an annulus — a circle subtracted from a
  filled polygon — never as a standalone filled polygon up to that
  radius. A filled cavity polygon removes *everything* inside it,
  including the part you meant to keep solid.
- **Cuts that must reach a part's exterior** (e.g. a mounting slit
  through a clamp collar) should use a cut radius/size well beyond the
  part's own maximum extent, never a locally-estimated size — the
  actual wall position can vary with an organic/parametric outline.
- **Wrap complex nested `difference()`/`union()` trees in
  `render(convexity = N)`.** OpenSCAD's fast preview (F5, OpenCSG) can
  visually misrepresent deeply nested boolean trees even when the
  final computed geometry (F6, CLI export) is correct. `render()`
  forces the exact computation so the interactive preview matches what
  actually gets exported — cheap insurance against a user report of
  "this looks broken" that is really just a preview artifact.
- **Every file ends with a `render_part` switch**
  (`render_part = true; if (render_part) part();`). A file that renders
  unconditionally at top level can't be `include`d into a check script
  that does `projection(cut=true)`: OpenSCAD refuses to mix the 2D cut
  with the 3D top-level object. The check script sets
  `render_part = false;` after the `include` (last assignment wins), or
  passes `-D render_part=false`.
- **Measure cross-sections, don't just look at them.** Export
  `projection(cut = true) translate([0, 0, -z]) part();` as SVG via the
  CLI (`-D cutz=<z>`), parse the coordinates, and compare the X/Y
  extents and inner edges against the values you expect. This verifies
  slot widths, tapers (at mid-height of a linear taper the width must
  be exactly halfway), and where roundings start, to within a tenth of
  a millimeter. Pick heights just inside each feature boundary (e.g.
  0.1 mm below a chamfer start), because that's where errors show.
- **Stacked edge treatments eat walls.** Before adding a chamfer or
  fillet to a thin wall, compute what's left of the wall (e.g.
  `wall_t - mouth_c - edge_c`) and `assert()` it against 2x nozzle.
  Keep the functional chamfer (e.g. an insertion funnel) larger and
  the cosmetic one smaller, instead of using one value for both.
- **Round or taper a silhouette with a mask, not by rebuilding it.**
  A 2D shape in the (Y, Z) plane, extruded along X and intersected
  with the part (`rotate([90, 0, 90])` maps 2D-x→Y, 2D-y→Z,
  extrusion→X), rounds the top corners of every rib at once. For a
  foot that tapers on all sides, use `hull()` between a wide bottom
  slab and a thin slab the size of the body at the top of the taper.
  The hull carries the corner radii of both outlines automatically.
