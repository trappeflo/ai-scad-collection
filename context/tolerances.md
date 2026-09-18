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
  of several cm, thin walls): plan for **~0.4 mm clearance per side**
  (nominal, in the CAD model), not the 0.2–0.25 mm above. 0.4 mm still
  slides easily; 0.5 mm is on the loose side. 0.25 mm is too tight. The
  lower limit lies somewhere between 0.25 and 0.4 mm — next time try
  ~0.35 mm. See real-part findings below.

## Real-part findings: long sliding fit (card boxes, PLA)

Card boxes, drawer sliding into a sleeve. Drawer walls 1.2 mm, sleeve
walls 1.6 mm. Sleeve printed standing, drawer printed lying on its floor.
- Flip 7 box: contact length ~87 mm, sleeve 90 mm tall.
- UNO box: contact length ~94 mm, sleeve ~97 mm tall.

| Nominal clearance per side | Box | Result |
|---|---|---|
| 0.25 mm | Flip 7 (`kartenbox_flip7_001`) | **Too tight.** Drawer could be pushed in, but was very hard to get out again. |
| 0.40 mm | UNO (`kartenbox_uno_002`) | **Slides easily** ("reicht locker"). Room to go slightly tighter. |
| 0.50 mm | Flip 7 (sleeve `kartenbox_flip7_002`, drawer 001) | **Slides well** ("flutscht"). Without the magnets probably slightly too loose; with magnets holding it closed, it works. |

Explanation (not measured, inferred):
- The effective X/Y error (~0.15–0.2 mm per side, see above) is taken off
  the nominal clearance. 0.25 mm nominal leaves only ~0.05–0.1 mm of real
  clearance, which is in the "fixed" range of the test block.
- The small test-block pieces are short and stiff. Long, thin walls
  probably also bow slightly inward (especially tall walls printed
  standing), which the test block does not capture.
- First estimate was target ~0.3 mm effective clearance + ~0.2 mm X/Y
  error = 0.5 mm nominal. In practice 0.4 mm already slides easily, so
  the real loss on long slides is smaller than that estimate assumed.

Status: **0.4 mm confirmed by print** (slides easily), 0.5 mm confirmed
(loose side). Recommended default for long slides: **0.4 mm**.

## Real-part findings: flat insert in a shallow rim (pin magnet base, PLA)

A rectangular pin badge (nominal 40 x 25 mm, corner radius ~1 mm) lies
flat in a surrounding rim of 1.5 mm height and 1.6 mm wall thickness.
The part is printed flat, so the pocket outline lies in XY and the
contact height is only 1.5 mm.

| Nominal clearance per side | Version | Result |
|---|---|---|
| 0.30 mm | `pin_magnetsockel_001` | **Too tight.** Pin didn't fully fit into the rim. |
| 0.50 mm | `pin_magnetsockel_002` | **Too loose.** |

Takeaway: the boundary lies between 0.3 and 0.5 mm. That's noticeably
more than the 0.2–0.25 mm that the short test-block pieces call
"movable". Not clarified: whether the pin was measured with calipers
or only given as nominal 40 x 25 mm. Stamped/enamel pins deviate
easily by a few tenths, which would explain part of the gap.
→ Next time: measure the insert with calipers and try **~0.4 mm**
per side.

## Open items
- Try ~0.35 mm per side on the next long sliding fit (drawer/sleeve) to
  narrow down the lower limit between 0.25 (too tight) and 0.4 (easy).
- If possible, measure where a tight long slide actually binds (caliper:
  outer drawer vs. inner sleeve, at the ends and in the middle) to tell
  wall bowing apart from general X/Y error.
- Test the 0.05–0.15 mm steps individually and add results here.
- Flat insert in a rim: narrow down between 0.3 (too tight) and 0.5
  (too loose), measure the insert first (see above).
- Check whether values differ between the two PLA spools (black/blue, see
  `materials.md`).
