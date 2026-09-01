# OpenSCAD AI Workflow

AI-assisted OpenSCAD workflow for 3D printing. The goal is to save time 
compared to classic CAD by using AI-assisted modeling.

## Concept

Two agents split the work to avoid bias:

- **design-agent** — leads the design conversation, gathers 
  requirements (dimensions, load, mounting type, use case), and 
  generates/iterates OpenSCAD code. Dialogue-driven, not autonomous.
- **qa-agent** — validates only, no creative modeling. Checks 
  geometry, printability, and dimensions against the `context/` 
  specs. Kept separate from the design-agent so it doesn't judge its 
  own creations too favorably.

## Project Structure

```
agents/     Role definitions for design-agent and qa-agent
skills/     Individual capabilities used by the agents
rules/      Constraints that apply across the workflow
context/    Printer, tolerance, and material specs (read before every task)
scad/
  draft/    Work-in-progress, versioned iterations
  finished/ Approved models (manual promotion only)
  trash/    Discarded iterations, with a note on why
  templates/ Reusable OpenSCAD building blocks
```

## Workflow

1. **Gather requirements** — `design-conversation` skill asks about 
   dimensions, load, mounting type, and use case before any code is 
   written.
2. **Model** — `modeling` skill reads `context/` (printer, 
   tolerances, materials) and generates a new versioned file in 
   `scad/draft/` (`object-name_001.scad`).
3. **Preview** — `render-preview` skill renders the current draft for 
   visual review.
4. **Validate** — `geometry-check` skill (qa-agent) checks the model 
   against wall thickness, build volume, and manifold-geometry rules. 
   Violations are reported explicitly, never auto-fixed.
5. **Export** — `export-stl` skill exports to `.stl`, only after 
   `geometry-check` has passed.
6. **Promote or archive** — `promote-finished` moves an approved file 
   to `scad/finished/`, but only after explicit user approval. 
   `archive` moves discarded iterations to `scad/trash/` with a short 
   note.

## Key Rules

- **context-first** — `context/printer.md`, `context/tolerances.md`, 
  and `context/materials.md` must be read before every modeling task.
- **versioning** — iterations are always versioned 
  (`object-name_001.scad`, `002`, ...), never overwritten.
- **units-mm** — units are consistently millimeters, noted in the 
  generated code.
- **no-auto-promote** — moving files to `scad/finished/` is always a 
  manual, explicit user decision.
- **printability-report** — printability violations are reported to 
  the user, never silently auto-fixed.

## Status

Early planning stage. Agent, skill, and rule definitions exist as 
concept files; `context/` specs (printer, tolerances, materials) are 
not yet filled in.
