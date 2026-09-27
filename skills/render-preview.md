# Skill: render-preview

## Purpose

Renders a model as PNG images, without opening the OpenSCAD GUI. Two
uses with different rules:

| Use | When | Tool | Where the images go |
|---|---|---|---|
| **Gate images** (evidence) | stages G3 and G5 of rule `pre-print-gate` | `python tools/check.py <file> --part ... --cut ...` | `qa/<stem>/check/` (local only, not versioned; reproducible with the commands in the report) |
| **Working previews** | during design, to look at a change quickly | OpenSCAD CLI directly (below) | scratchpad/temp folder, never `scad/` |

## Gate images

`tools/check.py` renders from the exported STL (exactly what would be
printed), with axes and scale:

- per part four standard views: `iso` (perspective), `front` (along Y),
  `side` (along X), `top` (along Z, orthographic)
- per `--cut` a section image plus the measured contours in `check.md`
  (Z cuts, or X/Y cuts with `--cut part:x=24`)
- for assemblies additionally the `interference` part, which must be
  empty or contact-only

Choose the cuts so that every functional feature in the requirements
table is cut at least once (magnet pocket, slot, clearance gap, just
below a chamfer start, through a bore along its axis).

## Working previews

- `openscad -o preview.png --imgsize=1000,750
  --camera=<tx>,<ty>,<tz>,<rx>,<ry>,<rz>,<dist> --colorscheme=Tomorrow
  file.scad`. `<tx..tz>` is the part's center, `<rx..rz>` the rotation.
  Alternatively `--viewall --autocenter` with distance 0.
- At least one perspective view (e.g. rotation `64,0,25`). For
  shape changes (roundings, silhouettes), add the orthogonal view
  that shows the change. Side view along X: rotation `90,0,90`. Front
  view along Y: rotation `90,0,0`.

## What an image can and cannot show

An image is a check step of its own (G3, G5): it shows *whether the
right thing was built*. It does not show *whether it was built to
size*. Manifoldness and dimensions are verified via CLI stats and
measured cross-sections (G1, G2).
