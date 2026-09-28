# Failure modes of AI-generated OpenSCAD code

Catalog of errors that compile and render without complaint but are
wrong. Read before every modeling task (rule `context-first`) and used by
the `qa-agent` as a checklist. Each entry names the stage of rule
`pre-print-gate` that catches it.

**Keep this file alive:** every error that got past a stage (found by a
later stage, by the user, or only in the print) is added here with the
model where it happened.

| # | Failure mode | Example / how it looks | Caught by | Prevention in the model |
|---|---|---|---|---|
| F1 | **Polygonal holes are too small.** `circle()`/`cylinder()` are inscribed polygons; with low `$fn` a bore is narrower than its nominal diameter | `$fn=16`, Ø 6 mm → only ~5.88 mm across the flats; the magnet doesn't fit | G2 (section, measure the hole) | for fit-relevant holes `$fn` ≥ 64 or enlarge by `1/cos(180/$fn)` |
| F2 | **Clearance applied twice or on the wrong side** | clearance added to the hole *and* subtracted from the pin → double gap; or subtracted from the hole → press fit instead of slide | G2 (measure both parts, compare with the table row) | clearance applied in exactly one place, as a named parameter, per side |
| F3 | **Radius/diameter mixed up** | `cylinder(r = 6)` for a Ø 6 mm magnet → 12 mm pocket | G2 | always name `d =` explicitly |
| F4 | **Unit / scale wrong** | cm or inch values, part is 10x too small/large | G1 bounding box vs. G2 table | rule `units-mm`; plausibility `assert` on the overall size |
| F5 | **Transform order** `rotate` before/after `translate` | feature sits in the wrong place or outside the part | G3 (image), G2 (section position) | build features at the origin, then move them |
| F6 | **Operands of `difference()` swapped / cut doesn't reach** | the cutter remains as a solid body, or a slot stops 0.01 mm short of the surface (skin left over) | G3, G1 (`Volumes` too high) | cutters with an overlap of ≥ 0.01 mm, beyond the part's maximum extent (see `modeling`) |
| F7 | **Coplanar faces / zero thickness** | Z-fighting in the preview, `Simple: no`, walls of 0 mm. Also with `Simple: yes`: `pocketbook_ladestaender_001` (self-check), shaft wall exactly in the plane of the lip face → zero-area triangles in the STL, CGAL cannot re-import it, and **every `check.py` cut came back empty** ("empty (outside the part?)") instead of failing | G1 (a cut that is empty although it lies inside the bounding box is a symptom, not "outside the part") | overlap `eps`, never touch exactly; offset cutters a few tenths from faces they would otherwise continue |
| F8 | **Floating or disconnected pieces** | a rib that doesn't reach the body; looks joined in the image | G1 (`Volumes` > expected) | check `Volumes` per part |
| F9 | **Knife-edge walls after chamfers** | `laptop_tablet_staender_001`: 3 mm rib, 1.5 mm chamfer on both sides → 0 mm edge | G4 (section just below the chamfer start) | `assert()` residual width ≥ 2x nozzle |
| F10 | **`offset()` on concave/wavy contours** | disconnected or self-intersecting geometry (`lampenschirm`) | G1, G3 | compute the inset directly from `r(θ) - wall` |
| F11 | **Constraint violated between sample points** | organic contour hits the clamp radius where phases align (`lampenschirm`) | G2 (full sweep, rule `verify-parametric-geometry`) | sweep with fine steps, check step-to-step change |
| F12 | **Symmetric load estimate instead of worst case** | `laptop_tablet_staender_001`: 12.9° instead of real 8.0° tipping angle | G4 (independent recalculation) | rule `load-case-check` |
| F13 | **Print orientation not considered** | part in `print` does not lie on z=0, or needs support although "no support" was required | G1 (min Z), G3 (side view), G4 | `print` part lies at z=0; overhang `assert` |
| F14 | **Requirement silently dropped** | the requested thumb recess / magnet pocket is simply missing | G3 (blind description has no recess), G2 (row without measurement) | every requirement is a row in the header table |
| F15 | **Measured dimension replaced by a guess** | `kartenbox_uno_001`: cards measured roughly at 90 x 60 instead of the standard 87 x 56 → 2 mm play per side | G2 (source column "measured / nominal / assumed") | ask; mark assumptions as such |
| F17 | **Assembly access blocked.** A part that is inserted after printing has no free path, although the finished assembly is fine | e.g. a screw or insert whose path is blocked by a rib; the interference check (lid vs. base) can't see it. Calibration: `brillenetui_004` hinge 2, pin path 0.27 mm into a PETG facet, was pressed through without trouble (false alarm) | G4 (insertion-path probe, report the intrusion depth) | model the insertion path as a solid; a few tenths of printed plastic in front of a steel pin are no obstacle, millimetres are |
| F18 | **Print plate larger than the bed** although every single part fits | `brillenetui_004`: `print` plate 278 mm in Y, bed 250 mm; the size `assert` only checked single parts | G1 (`--part print`, build-volume check) | lay out `print` from the parts' sizes and `assert` the plate size; split by material |
| F16 | **Preview (F5) differs from the render (F6)** | preview looks broken, export is fine, or vice versa | G1 (the check works on the exported STL) | `render(convexity = N)` around nested booleans |

## Not a failure (known false alarms)

- **Interference with 0 mm³:** faces touching (e.g. lid on the base at
  the parting plane). `tools/check.py` reports this as WARN "contact
  only". Only a real volume is a collision.
- **"Object may not be a valid 2-manifold"** on the `interference` part
  itself: follows from the zero-volume contact above, not from the
  parts.
