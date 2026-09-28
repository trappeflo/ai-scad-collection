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

## Real-part findings: press fits in PETG (glasses case, `brillenetui_004`)

Shell printed in PETG (base upright, lid upside down), 0.4 mm nozzle.
User assessment only ("ließen sich sehr gut einpressen"), not measured.

| Fit | Geometry | Nominal clearance per side | Result |
|---|---|---|---|
| Steel pin Ø3 x 30 mm in the base knuckles | horizontal bore Ø3.2 (axis along X, bore ceiling is an overhang), `$fn = 48` | 0.10 mm | **Good press fit**, pressed in well |
| Neodymium magnet Ø6 x 2 mm | vertical pocket Ø6.3 x 2.1 mm, 0.90 mm web to the outside | 0.15 mm | **Good press fit**, pressed in well, web held |
| Lid knuckles on the Ø3 steel pin (pivot) | horizontal bore Ø3.6 | 0.30 mm | **Swings freely**, "could sit minimally tighter" → next time ~0.25 mm |

Also: at hinge 2 the pin path ran 0.27 mm into a relief facet at the
entry. The pin was pressed in from that side without trouble. A few
tenths of printed PETG in the way of a steel pin are no obstacle.

Takeaways:
- In PETG the 0.10–0.15 mm range works as a press fit for both a
  horizontal bore and a vertical pocket, consistent with the PLA test
  block ("0.05–0.15 stays fixed").
- The QA had rated the magnet pocket as "≈0 effective clearance, glue
  instead of pressing" (effective X/Y error ~0.15–0.2 mm from PLA). For
  small round press fits in PETG that was too pessimistic.
- Free pivot in PETG: 0.30 mm per side turns freely, slightly loose.
  The lower limit is somewhere below; ~0.25 mm is the next value to try.

## Real-part findings: clamp ring on a round rod (lamp shade, PLA)

`lampenschirm_013`, printed in PLA. User assessment only ("passt gut"),
not measured.

| Fit | Geometry | Nominal | Result |
|---|---|---|---|
| C-ring clamp on a Ø20 metal rod, snapped on from the side | ring ID 19.2 mm, wall 3 mm, opening 40°, 180 mm tall | **−0.4 mm per side** (0.8 mm undersize on the diameter, as preload) | **Fits well** |

Takeaway: for a snap-on C-ring with a 3 mm PLA wall, 0.8 mm undersize
on the diameter gives a good clamp and still snaps on. Stiffer rings
(thicker wall, smaller opening) probably need less.

## Real-part findings: loose device slot + angled USB-C plug (PocketBook stand, PLA)

`pocketbook_ladestaender_003`, fit_test printed 2026-09-28. User
assessment only ("zufrieden"), no measured values.

| Fit | Geometry | Nominal clearance | Result |
|---|---|---|---|
| E-reader with case (~13 mm, approx. measured) in a leaning slot (70°) | slot 15 mm, device leans on the backrest | 2 mm total | OK (assessment) |
| Angled USB-C plug (UGREEN 90°, not measured) hanging in a shaft under the device | shaft 70 x 17 x 22 mm deep, plug assumed 12 x 7 x 15 | ≥ 5 mm per side, 7 mm below | OK (assessment) |
| Cable from the plug into a channel open at the top | channel 6 mm wide, cable assumed Ø4, bend room ≤ ~8.7 mm radius | 1 mm per side | OK (assessment) |

Takeaway: no tolerance value to derive (loose fits, sizes assumed). It
only confirms that these generous assumptions were enough for this
cable and device.

## Open items
- PETG pivot: try ~0.25 mm per side (bore 3.5 on a Ø3 pin) next time.
- TPU: no values yet. First data point: `brillenetui_004` inlays, 0.3 mm
  per side in the PETG cavity (untested).
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
