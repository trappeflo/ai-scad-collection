# Skill: geometry-check

## Purpose

Validates the generated model against the specifications in `context/`:

- `context/printer.md`
- `context/tolerances.md`
- `context/materials.md`

## Checks

- Wall thickness relative to nozzle diameter
- Dimensions relative to build plate size
- Non-manifold geometry

## Usage

Used by the `qa-agent`. Violations are explicitly reported per rule 
`printability-report`, not fixed automatically. A passed 
`geometry-check` is a prerequisite for the `export-stl` skill.
