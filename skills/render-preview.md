# Skill: render-preview

## Purpose

Renders the current draft as a PNG so the user and the agent can review
it visually, without opening the OpenSCAD GUI.

## Usage

- Via the CLI: `openscad -o preview.png --imgsize=1000,750
  --camera=<tx>,<ty>,<tz>,<rx>,<ry>,<rz>,<dist> --colorscheme=Tomorrow
  file.scad`. `<tx..tz>` is the part's center, `<rx..rz>` the rotation.
- At least one perspective view (e.g. rotation `64,0,25`). For
  shape changes (roundings, silhouettes), add the orthogonal view
  that shows the change. Side view along X: rotation `90,0,90`. Front
  view along Y: rotation `90,0,0`.
- Save previews to the scratchpad/temp folder, not to `scad/`.
- A preview is for a visual check, **not** for verification.
  Manifold checks and dimensions are verified via CLI stats and
  measured cross-sections (see skill `geometry-check`).
