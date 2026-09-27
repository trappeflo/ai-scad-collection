# QA report: `brillenetui_004`

- File: `scad/draft/brillenetui_004.scad`
- Previous version / report: `brillenetui_003` (no QA report)
- Context read: printer.md, tolerances.md, materials.md, failure-modes.md
- Check date: 2026-09-27
- Requirements table passed in by the caller (not yet in the file header).

## Summary

| Stage | Result | Short note |
|---|---|---|
| G1 Technical | WARN (explained) | 8 parts Simple: yes, Volumes as expected; interference contact only 0.000 mm³ |
| G2 Dimensions | PASS with caveats | 10/10 rows measured; R1 corner caveat (finding 2); R4 force n.c. |
| G3 Visual (blind) | PASS | all features present, correct sides |
| G4 Printability | PASS with findings | >45° only bore ceilings + 0.4 mm ledge; walls 0.80–0.93 at limit; `print` plate 278 mm |
| **Recommendation** | **fit_test only** (+ hinge_test) | unconfirmed fits, PETG/TPU undocumented |
| G5 Release (user) | not recorded; base + lid printed in PETG | print result below |

## G1 Technical

    python tools/check.py scad/draft/brillenetui_004.scad --part base=2 --part lid=2 --part inlay_base=2 --part inlay_lid=2 --part print --part fit_test --part hinge_test --part assembly --empty interference --cut 1 --cut 5 --cut 10 --cut 20 --cut 30
    python tools/check.py scad/draft/brillenetui_004.scad --out qa/brillenetui_004/check_cuts --part base=2 --part lid=2 --part inlay_base=2 --part inlay_lid=2 --part fit_test=2 --part hinge_test=3 --cut 1.1 --cut 1.3 --cut 1.9 --cut 2.1 --cut 4 --cut 12 --cut 19.5 --cut 20.5 --cut 21.5 --cut 22.75 --cut 24 --cut 24.7

[check/check.md](check/check.md) WARN, [check_cuts/check.md](check_cuts/check.md) PASS.

| Part | Simple | Volumes (exp.) | Size X x Y x Z | Min Z |
|---|---|---|---|---|
| base | yes | 2 (2) | 165.19 x 69.49 x 26.22 | 0.00 |
| lid (print) | yes | 2 (2) | 165.15 x 69.39 x 26.42 | 0.00 |
| inlay_base | yes | 2 (2) | 150.40 x 50.40 x 22.80 | 0.00 |
| inlay_lid | yes | 2 (2) | 150.40 x 50.40 x 18.60 | 0.00 |
| print | yes | 5 (4 bodies) | 165.19 x **278.30** x 26.42 | 0.00 |
| fit_test | yes | 2 (2) | 48 x 8 x 8 | 0.00 |
| hinge_test | yes | 3 (3) | 42.00 x 45.60 x 14.87 | -0.00 |
| assembly | yes | 5 | 165.19 x 99.41 x 86.97 | 0.00 |
| interference | – | contact only 0.000 mm³ | Z 22.80..43.60 | – |

WARN explained: contact at the parting plane z_p = 22.8 (0° step) and inlay_lid flush against the lid ceiling (z = 43.6), both intended; no penetration at 0..180° in 5° steps. The 2-manifold warning follows from the zero-volume contact (known false alarm). assembly 5 = base+inlay, lid+inlay, 2 pins. No ERROR / failed assert.

Extra probes in [extra/](extra/): probe.scad (includes the draft unchanged), YZ sections through the knuckles at x = 24/35/44, knuckle row section at z_p+1, pin insertion paths (Ø3 x 30 from both ends of each hinge), full STL facet overhang scan of base and lid (overhang.py).

## G3 Blind description

_Written from the images only, before reading the requirements/header._

- Base: open box ~165 x 69 x 26 on its flat floor; sides are irregular low-poly facets (random tilted triangles/polygons), rim and floor flat. Cavity 151 x 51, large corner radii on the front (low Y) side, small at the back. Lip ring on the rim. Two Ø~6.3 holes in the rim at the front corners. Half-spherical dimple in the front face at mid-length at the rim. Four knuckles on the back edge in two pairs, horizontal bores along X, rising above the rim, in a notch in the facets.
- Lid: same outline/facets, printed upside down, rim with a recessed step, two round pockets at the corners opposite the hinge, two wider (13 mm) knuckles between the base pairs.
- Inlays: two thin-walled D-shaped trays 150.4 x 50.4, 22.8 and 18.6 tall.
- Assembly: lid opened ~100° about the top back edge, knuckles interleaved, magnet holes face each other at the front. Nothing floating.
- print: flipped lid, base, two inlays in a row along Y, all on z = 0, row ~278 mm long.
- hinge_test: two wall cut-outs with irregular ~7-sided knuckle prisms, lying on cut faces.
- fit_test: bar 48 x 8 x 8, six horizontal holes labeled 3.1 3.2 3.3 3.5 3.6 3.7.

## G2 Dimensions

Recalculated: L x W x H 156.6 x 56.6 x 45.6, z_p 22.8, axis y_a 60.8, hinge_x [20, 106.6].

| ID | Requirement | Target | Source | Actual | How measured | Result |
|---|---|---|---|---|---|---|
| R1 | Glasses fit | 145x45x38 + clearance | assumed | inner 148.00 x 48.00, height 39.2; front corners R20.5 → 145x45 rectangle intrudes 6.4 mm per front corner, needs glasses corner ≥ R15.4 | inlay sections, loop area, Z recalculated | PASS bbox / caveat (F2) |
| R2 | 4 single bodies | – | – | all Simple yes, Volumes 2 | check.py | PASS |
| R3 | Hinge, pins 3x30 | press bore, 30 mm span | nominal | knuckles 20–28 / 28.4–41.6 / 42–50, gaps 0.40, span 30.0; bores 3.20 (0.10/side) / 3.60 (0.30/side); ring walls 1.25 / 1.03 min | knuckle_row.svg, yz_*.svg, kpoly recalculated | PASS geometry; fit untested; F5 |
| R4 | Doesn't open by itself | magnets | – | 2 pairs Ø6x2, pockets 6.30 x 2.1 at front corners, 0.4 mm magnet gap | sections base 22.75/24/24.7, lid 19.5/20.5 | PASS present; force n.c. |
| R5 | Magnets in rim | walls ≥ 0.8 | – | web to cavity 0.93, to lip outside 0.90 (echo claims 0.929), to faceted outside ≥ 3.68 | loop distances | PASS at limit |
| R6 | Crystal shell | faceted sides | – | relief 0.42–5.44, top/bottom flat | images | PASS |
| R7 | Faceted knuckles | not cylinders | – | 7-corner irregular prisms | hinge_test_iso, YZ sections | PASS |
| R8 | No support | ≤45°, z=0 | – | min Z 0; >45° only Ø3.2/3.6 bore ceilings and a 0.4 mm lip ledge over the dimple (1.3 mm²) | STL facet scan | PASS |
| R9 | Lid opens freely | empty/contact | – | 0.000 mm³, 0..180° / 5° | --empty interference | PASS |
| R10 | Fits printer | ≤250³ per part | printer.md | max part 165.2 x 69.5 x 26.4; `print` plate 278.3 in Y | bbox | PASS per part; plate FAIL (F1) |

## G3 Comparison

- Differences: thumb dimple (no requirement, carried over from _002, OK); D-shaped cavity from front_r for the magnets (→ F2); knuckles above the rim (intended interleave); fit_test has no 3.4 (deliberate, covers 3.2/3.6); 278 mm print row (F1).
- Checklist: features complete; magnets front / hinge back in both parts; no floating parts (gap at z 22.5–22.8 between wall and base knuckle is the intended hinge_relief groove, knuckle attached below); bed faces correct; assembly correct; proportions OK.

## G4 Printability

| Check | Value | Limit | Result |
|---|---|---|---|
| Min. wall / residual | dimple wall 0.80, lip web 0.90, cavity web 0.93, knuckle rings 1.03/1.25, inlay 1.2 | ≥ 0.8 | PASS (at limit) |
| Overhangs | relief/gussets ≤45° everywhere; bore ceilings and 0.4 ledge >45° | ≤45° or intended | PASS |
| Build volume | parts ≤165.2; `print` 278.3 | 250 | parts PASS / plate FAIL |
| Load case | lid levered past free swing: ~120 N per hinge vs ~680 N (lid knuckle, 2 x 1.03 x 13.2 x 25 MPa) / ~500 N per base knuckle → SF ~4–5 | – | PASS (estimate) |

Governing mode: the lid knuckle splitting across layers. Not critical: wall bending, tipping, sliding. Parametric constraint: back relief measured ≤ W+3.05 (cap 3.8); all facets scanned for overhang.

## Findings

1. G3/G4: the `print` plate is 278.3 mm long in Y, more than the 250 mm bed. The assert only checks single parts. Split into shells and inlays plates (different materials anyway).
2. G2 R1 (F15-adjacent): the front inner corners are R20.5. A 145x45 outline fits only with glasses corners ≥ R15.4. Measure the real glasses; put the straight brow line at the hinge side.
3. Fit test first: pin press fit in a horizontal bore (0.10/side), TPU inlay 0.3/side, magnet pocket 0.15/side (≈0 effective) are unconfirmed, and PETG/TPU are undocumented. fit_test/hinge_test cover the pin fits only.
4. G4: dimple wall 0.80, lip web 0.90, cavity web 0.93, all at the 2x nozzle limit. Glue the magnets rather than press them (lip web may crack).
5. G2 R3 (F11-like): the hinge 2 pin path is blocked by the relief from the outer end (0.27 mm, x 145–150) and only just touches the relief from the inner end (~0 mm clearance). Hinge 1 is clear. The header's "von außen einpressen" does not work at hinge 2.
6. G1: interference is sampled at 5° steps (informational).

## G5 Release
- Released by the user: not recorded before the print. The user printed
  the PETG shell parts (base + lid) directly, not only fit_test/hinge_test
  as recommended. Recorded after the fact on 2026-09-27.
- Scope printed: base + lid (PETG). TPU inlays: not printed yet.

## Export
- base, lid (PETG), exported by the user. Plate layout on the bed not
  recorded (the `print` part is 278 mm and would not fit, finding 1).

## Print result

2026-09-27, PETG shell (base + lid). User: "sehr gutes Ergebnis".

| ID | Observation in the print | Matches prediction? |
|---|---|---|
| R2 | Shell parts printed fine | yes |
| R3 | Steel pins 3 x 30 mm pressed in "sehr gut" (bore 3.2, 0.10 mm/side, horizontal) | yes, geometry PASS; fit was untested, now confirmed for PETG |
| R4/R5 | Magnets Ø6 x 2 pressed in "sehr gut" (pocket 6.3, 0.15 mm/side, vertical) | **prediction too pessimistic**: QA called the fit ≈0 effective clearance and advised gluing (finding 4); pressing worked, the 0.90 mm lip web held |
| R6/R7 | Crystal shell and knuckles: no problems reported | yes |
| R8 | No support problems reported | yes |
| F5 | Pin at hinge 2 pressed in **from outside**, "sehr gut", despite the 0.27 mm intrusion into the relief | **false alarm**: the steel pin pushes through 0.27 mm of PETG facet without effort |
| R3 lid | Lid swings freely on Ø3.6 bore (0.30 mm/side); "could sit minimally tighter" | yes (free); slightly loose |
| R4 | Magnets hold the lid closed | yes |
| R1 | Glasses fit into the shell (without inlay), including the R20.5 front corners | yes; finding 2 was a valid caveat, real glasses fit |
| F1 | User split the parts onto several plates in the slicer ("split into objects") | finding correct: the `print` plate does not fit; worked around in the slicer, model unchanged |
| TPU inlays | not printed yet | open |

- Escaped defects: none. Every problem that could have stopped the
  print was either flagged (F1) or did not occur.
- Gate prediction accuracy for this print: 6 findings → 1 real and
  relevant (F1, plate size, worked around), 1 valid caveat that turned
  out fine (F2, corners), 2 false alarms (F4 magnet press fit, F5 pin
  path), 2 informational (F3 untested fits, now partly confirmed; F6).
- False alarm F4 (magnet press fit): the effective X/Y error in
  `tolerances.md` comes from PLA on the test block; a Ø6 magnet in a
  vertical PETG pocket tolerates more. Calibration gap, not a failure
  mode → values in `context/tolerances.md`.
- False alarm F5 (pin path): an intrusion of a few tenths into printed
  plastic is no obstacle for a steel press-fit pin. The assembly-access
  check (F17) now reports the intrusion depth instead of requiring an
  empty path.
- Fit findings → `context/tolerances.md`: PETG pin press fit 0.10/side,
  PETG magnet pocket 0.15/side, PETG free pivot 0.30/side (free, slightly
  loose → next time ~0.25).
- Next version (if any): lay out `part = "print"` on two plates (shell /
  TPU) or check the plate size by `assert` (F18); lid bore 3.6 → ~3.5.
