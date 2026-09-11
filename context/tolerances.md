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
- **Long sliding fits** (drawers, sleeves, slide-in lids — contact length
  of several cm, thin walls): plan for **~0.5 mm clearance per side**
  (nominal, in the CAD model), not the 0.2–0.25 mm above. 0.5 mm slides
  easily but is on the loose side — fine when something else holds the
  part in place (magnets, latch). For a slide that has to hold by friction
  alone, go slightly tighter (~0.4 mm, not yet tested). See real-part
  finding below.

## Real-part finding: long sliding fit (kartenbox_001, PLA)

Card box, drawer sliding into a sleeve. Contact length ~87 mm, drawer
walls 1.2 mm, sleeve walls 1.6 mm. Sleeve printed standing (90 mm tall),
drawer printed lying on its floor.

| Nominal clearance per side | Result |
|---|---|
| 0.25 mm | **Too tight.** Drawer could be pushed in, but was very hard to get out again. |
| 0.50 mm | **Slides well** ("flutscht"). Without the magnets probably slightly too loose; with magnets holding it closed, it works. (Sleeve from `kartenbox_002`, same drawer as 001.) |

Explanation (not measured, inferred):
- The effective X/Y error (~0.15–0.2 mm per side, see above) is taken off
  the nominal clearance. 0.25 mm nominal leaves only ~0.05–0.1 mm of real
  clearance, which is in the "fixed" range of the test block.
- The small test-block pieces are short and stiff. Long, thin walls
  probably also bow slightly inward (especially tall walls printed
  standing), which the test block does not capture.
- Rule of thumb derived from this: target ~0.3 mm effective clearance
  ("fully movable" in the test block) + ~0.2 mm X/Y error = **~0.5 mm
  nominal per side**.

Status: **0.5 mm confirmed by print** (slides well, slightly loose
without a holding element).

## Open items
- Test ~0.4 mm per side for long sliding fits that must hold by friction
  alone (e.g. via the `fit_test` rings in `kartenbox_002`).
- If possible, measure where a tight long slide actually binds (caliper:
  outer drawer vs. inner sleeve, at the ends and in the middle) to tell
  wall bowing apart from general X/Y error.
- Test the 0.05–0.15 mm steps individually and add results here.
- Check whether values differ between the two PLA spools (black/blue, see
  `materials.md`).
