# OpenSCAD AI Workflow

AI-assisted OpenSCAD workflow for 3D printing. The goal is to save time
compared to classic CAD by using AI-assisted modeling: you describe what
you need, an agent asks the right questions, writes parametric OpenSCAD
code, and verifies it before you print.

**New here? → [SETUP.md](SETUP.md)** (tools, context, first session)

## Concept

Two agents split the work to avoid bias:

- **design-agent** — leads the design conversation, gathers
  requirements (dimensions, load, mounting type, use case), and
  generates/iterates OpenSCAD code. Dialogue-driven, not autonomous.
- **qa-agent** — validates only, no creative modeling. Checks
  geometry, printability, and dimensions against the `context/`
  specs. Kept separate from the design-agent so it doesn't judge its
  own creations too favorably.

The agents, skills, and rules are plain Markdown instruction files.
They are used with [Claude Code](https://claude.com/claude-code) by
referencing the agent file in the prompt:

```
@agents/design-agent.md I need a box for a card game, 80 x 54 x 36 mm.
```

## Project Structure

```
agents/      Role definitions for design-agent and qa-agent
skills/      Individual capabilities used by the agents
rules/       Constraints that apply across the workflow
context/     Printer, tolerance, and material specs (read before every task)
scad/
  draft/     Work-in-progress, versioned iterations
  finished/  Approved models (manual promotion only)
  trash/     Discarded iterations, with a note on why (created on first use)
  templates/ Reusable, proven designs — only the key inputs need to be set
.vscode/     Recommended VS Code extensions for OpenSCAD
CLAUDE.md    Project instructions loaded by Claude Code
SETUP.md     Setup guide
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
4. **Validate** — `geometry-check` skill (qa-agent, running as a
   separate subagent without the design reasoning) checks the model
   against wall thickness (including residual widths after chamfers),
   build volume, manifold geometry, and, for load-bearing parts, the
   load cases. Violations are reported explicitly, never auto-fixed.
5. **Export** — `export-stl` skill exports to `.stl`, only after
   `geometry-check` has passed.
6. **Print and iterate** — feedback from the real print ("too tight",
   "wall bends") leads to the next version (`_002`, `_003`, …). What
   was learned goes back into `context/`.
7. **Promote or archive** — `promote-finished` moves an approved file
   to `scad/finished/`, but only after explicit user approval.
   `archive` moves discarded iterations to `scad/trash/` with a short
   note.

## Model Conventions

- Units are millimeters, noted in the file header.
- The file header documents the context used, the requirements from
  the design conversation, print orientation, and — from `_002` on —
  what changed compared to the previous version and why.
- All dimensions are parameters at the top of the file; derived values
  are computed, not hard-coded.
- Multi-part models have a `part` parameter to choose the output:
  `"print"` (all parts in print orientation), single parts for per-part
  STL export, `"assembly"`, and where useful `"fit_test"` (small test
  pieces to check a fit before the full print) or `"interference"`
  (collision check, must be empty).
- Geometry is verified via the OpenSCAD CLI (`Simple: yes`, expected
  `Volumes` count), not by eyeballing the preview.

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
- **load-case-check** — parts that carry something get their governing
  failure mode (breaking, tipping, sliding) calculated for the worst-case
  load combination, with the calculation as `echo()` in the file.
- **verify-parametric-geometry** — parametric/organic contours with a
  mechanical constraint are verified via a full parameter sweep and
  CLI manifold stats, not spot-checked or eyeballed in the preview.

## Key Findings So Far

Reference setup: Anycubic Kobra S1, 0.4 mm nozzle, PEI plate, PLA.
Details in [context/tolerances.md](context/tolerances.md).

- **Short fits** (test block): 0.2–0.25 mm per side moves, 0.05–0.15 mm
  stays fixed.
- **Long sliding fits** (drawer in sleeve, ~90 mm contact length):
  0.25 mm per side was too tight, **0.4 mm slides easily** (current
  default), 0.5 mm is on the loose side. Next to try: ~0.35 mm.
- **Flat insert in a shallow rim** (pin badge, 40 x 25 mm): 0.3 mm per
  side too tight, 0.5 mm too loose. Next to try: ~0.4 mm, measure the
  insert first.
- For new fits, a quick `fit_test` print (thin rings with several
  clearances) saves a failed full print.

## Templates

| Template | Inputs | Notes |
|---|---|---|
| `scad/templates/kartenbox_template_001.scad` | Length, width, depth of the card stack | Card box (drawer + sleeve, 2x 6x2 mm magnets, 0.4 mm slide clearance). Everything else is derived; magnet spacing, push hole, and grips scale with the size. Valid for stacks ≥ ~30 mm wide and ≥ ~10.5 mm deep, box length ≤ 250 mm (checked by `assert`). Works in the OpenSCAD Customizer. |

To use a template: copy it to `scad/draft/<name>_001.scad` and set the
inputs, or set them directly in the OpenSCAD Customizer
(Window → Customizer).

## Models

| Model | Status | Notes |
|---|---|---|
| `lampenschirm_010`, `_013` | finished | Organic wavy lamp shade with integrated clamp collar |
| `kartenbox_flip7_002` | finished | Card box (Flip 7), drawer + sleeve, magnetic catch (6x2 mm), 0.5 mm slide clearance |
| `kartenbox_uno_002` | finished | Card box (UNO Minecraft), same design, 0.4 mm slide clearance — printed, works |
| `laptop_tablet_staender_003` | finished | Vertical laptop/tablet stand, two slots in one part, flared foot against tipping |
| `pin_magnetsockel_002` | finished | Magnet base that turns a rectangular pin badge (40 x 25 mm) into a fridge magnet, pin stays unmodified |

## Status

The workflow is in use. `context/printer.md` and `context/tolerances.md`
are filled in for the reference setup and are updated with every print;
`context/materials.md` is still empty.
