# Skill: geometry-check

## Purpose

Validates the generated model against the specifications in `context/`:

- `context/printer.md`
- `context/tolerances.md`
- `context/materials.md`

## Checks

- Wall thickness relative to nozzle diameter
- Dimensions relative to build plate size
- Non-manifold geometry — verified via the OpenSCAD CLI compile stats
  (`Simple: yes`, and `Volumes` matches the expected count for the
  number of physically separate parts; see rule
  `verify-parametric-geometry`), not by eyeballing the editor preview
- For parametric/organic contours with a mechanical constraint (e.g. a
  clamp radius): full parameter-sweep verification per rule
  `verify-parametric-geometry`, independent of whatever check the
  `design-agent` already ran — that's the point of separating QA from
  creation

## Usage

Used by the `qa-agent`. Violations are explicitly reported per rule 
`printability-report`, not fixed automatically. A passed 
`geometry-check` is a prerequisite for the `export-stl` skill.
