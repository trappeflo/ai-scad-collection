# Skill: geometry-check

## Purpose

Runs gate stages G1, G2 and G4 of rule `pre-print-gate` (G3: skill
`visual-review`) and validates the model against:

- the requirements table in the file header (skill `design-conversation`)
- `context/printer.md`, `context/tolerances.md`, `context/materials.md`
- `context/failure-modes.md` as a checklist

## G1 Technical (script)

```
# run 1, before the blind description
python tools/check.py scad/draft/<file>.scad \
    --part <part>=<expected volumes> ... --part print \
    --show assembly --empty interference

# run 2, after reading the requirements: targeted sections, added
python tools/check.py scad/draft/<file>.scad --add \
    --part <part>=<volumes> --cut <part>:z=<h> --cut <part>:x=<pos> ...
```

- One `--part` per printable part, expected `Volumes` = 1 + number of
  physically separate bodies (a single watertight part: 2). Also the
  `print` part (the whole plate): it is checked against the build
  volume too, and a plate can exceed the bed although every part fits.
- `--show` for parts that are not printed (assembly): images only, no
  bed/build-volume check.
- `--empty interference` for every model that has an interference part.
- `--cut [part:][x=|y=|z=]value`: sections through every functional
  feature (see G2). Heights are in the part's own print coordinates
  (a flipped lid has z' = H − z). X/Y cuts for horizontal bores,
  knuckles, wall profiles.
- The script flags per printable part: min Z ≠ 0, bounding box larger
  than the build volume (`--bed`, default from `context/printer.md`),
  and lists overhangs > 45°. Section contours are labeled `hole` or
  `material`.
- `--keep-stl` keeps the exported STLs for extra probes.
- Pass: `check.md` says PASS. WARN is allowed only if every warning is
  explained in the report (e.g. contact-only interference at the parting
  plane). Note: OpenSCAD 2021.01 exits with 0 even when an `assert()`
  fails. Only the script's evaluation of the log counts.

## G2 Dimensions

Every row of the requirements table gets a measured actual value:

- Overall dimensions from the bounding box in `check.md`.
- Inner dimensions, pockets, slots, clearances from the section
  contours in `check.md` (X/Y range of the inner loop). Pick heights
  just inside each feature boundary (e.g. 0.1 mm below a chamfer
  start), because that's where errors show. For finer features export
  a dedicated section (skill `modeling`, "Measure cross-sections").
- Fits: measure **both** mating parts and compute the real gap per side.
  Compare with `context/tolerances.md` (F2 double clearance, F1
  polygonal holes).
- Computed values (`echo()`): recalculate independently, don't copy.
  The `echo()` output is a claim of the file.
- Result per row: PASS / FAIL / not checkable (with reason, e.g. "only
  in the print: magnet holding force").

## G4 Printability

- Wall thickness relative to nozzle diameter — **including residual
  widths after edge treatments**, not just the input parameters. Two
  chamfers from both sides of a wall, a fillet plus a chamfer, or a
  tapered lip can thin a wall that passes on paper down to a knife
  edge. (`laptop_tablet_staender_001`: a 3.0 mm wall passed the check,
  but with 1.5 mm chamfers on both sides the rib ended in a 0 mm edge
  at the top. Only the cross-section caught it.) The model should
  `assert()` every derived minimum width ≥ 2x nozzle.
- Dimensions relative to build plate size.
- Print orientation: every part in `print` lies at z = 0 (min Z in
  `check.md`); overhangs > 45° (table in `check.md`) and bridges only
  where intended and compatible with `context/printer.md` (bridges sag
  noticeably there). Small bore ceilings are normal.
- Build volume: every printable part **and the whole `print` plate**
  (F18).
- **Assembly access** (F17): every part that is inserted after printing
  (pins, magnets, screws, inserts) must have a free path in: check the
  insertion path over its full length from the side it is meant to go
  in, e.g. with a probe cylinder intersected with the part
  (`qa/<stem>/extra/`). Report the intrusion depth, don't just flag
  "not empty": a few tenths of printed plastic in front of a steel pin
  were pushed through without trouble (`brillenetui_004`, 0.27 mm,
  PETG). Flag intrusions of ~0.5 mm and more, and any intrusion for
  soft or brittle inserted parts (magnets, glass, printed pins).
- For parts that carry or hold something: an independent load-case
  check per rule `load-case-check`. Recalculate it; don't just read the
  design-agent's `echo()` output. Check that the worst-case load
  combination was used.
- For parametric/organic contours with a mechanical constraint (e.g. a
  clamp radius): full parameter-sweep verification per rule
  `verify-parametric-geometry`, independent of whatever check the
  `design-agent` already ran — that's the point of separating QA from
  creation.

## Usage

Used by the `qa-agent`. Results go into `qa/<stem>/report.md`
(template `qa/TEMPLATE.md`). Violations are explicitly reported per rule
`printability-report`, not fixed automatically. Passed G1–G4 plus the
user's release (G5) are the prerequisite for skill `export-stl`.
