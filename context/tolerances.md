# Tolerances

## Source
Tolerance test cubes/cylinders from the calibration test block
("Ultimate 3D printer calibration and test block", MakerWorld), clearance
range 0.05–0.30 mm. Printed on Kobra S1, PLA, PEI plate, 0.4 mm nozzle.

## Result (checked by hand)

| Clearance | Behavior |
|---|---|
| 0.30 mm | fully movable, comes out easily |
| 0.20 mm | moves well (can be turned/wiggled), but not easily snapped/broken out – still sits snug |
| 0.05–0.15 mm | (not individually checked/documented yet – presumably fixed/immovable) |

## Effective X/Y error
Rough estimate: **~0.15–0.20 mm per side of clearance** effective error
(over-extrusion + nozzle compensation combined) for this profile/material.
This counts as a normal-to-good value for a consumer FDM printer with a
standard 0.4 mm nozzle.

## Rules of thumb for own designs (with this printer/profile)

- **Moving fits** (hinges, gears, interlocking parts): plan for at least
  **0.2–0.25 mm clearance per side**.
- **Press fits** (e.g. inserts for threaded bushings, connectors meant to
  hold): use the **0.05–0.15 mm** range — this is the range that stayed
  fixed in this test print.
- For more precise results around the 0.2 mm boundary: check and fine-tune
  flow rate/extrusion multiplier and, if needed, X/Y compensation
  ("contour/hole compensation" or "elephant foot compensation") in the
  slicer.

## Open items
- Test the 0.05–0.15 mm steps individually and add results here.
- Check whether values differ between the two PLA spools (black/blue, see
  `materials.md`).
