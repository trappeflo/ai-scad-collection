# Skill: geometry-check

## Purpose

Validates the generated model against the specifications in `context/`:

- `context/printer.md`
- `context/tolerances.md`
- `context/materials.md`

## Checks

- Wall thickness relative to nozzle diameter — **including residual
  widths after edge treatments**, not just the input parameters. Two
  chamfers from both sides of a wall, a fillet plus a chamfer, or a
  tapered lip can thin a wall that passes on paper down to a knife
  edge. (`laptop_tablet_staender_001`: a 3.0 mm wall passed the check,
  but with 1.5 mm chamfers on both sides the rib ended in a 0 mm edge
  at the top. Only the cross-section caught it.) The model should
  `assert()` every derived minimum width ≥ 2x nozzle.
- Dimensions relative to build plate size
- Non-manifold geometry — verified via the OpenSCAD CLI compile stats
  (`Simple: yes`, and `Volumes` matches the expected count for the
  number of physically separate parts; see rule
  `verify-parametric-geometry`), not by eyeballing the editor preview
- For parts that carry or hold something: an independent load-case
  check per rule `load-case-check`. Recalculate it; don't just read the
  design-agent's `echo()` output. Check that the worst-case load
  combination was used.
- For parametric/organic contours with a mechanical constraint (e.g. a
  clamp radius): full parameter-sweep verification per rule
  `verify-parametric-geometry`, independent of whatever check the
  `design-agent` already ran — that's the point of separating QA from
  creation

## Usage

Used by the `qa-agent`. Violations are explicitly reported per rule 
`printability-report`, not fixed automatically. A passed 
`geometry-check` is a prerequisite for the `export-stl` skill.
