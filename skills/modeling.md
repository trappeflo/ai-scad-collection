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
