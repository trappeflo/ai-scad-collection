# QA report: `pocketbook_ladestaender_002`

Rule `pre-print-gate`. Saved as `qa/pocketbook_ladestaender_002/report.md`.
G1–G4 written by the `qa-agent` (returned as text, saved unchanged by the
design-agent), G5 by the user, "Print result" after printing.

- File: `scad/draft/pocketbook_ladestaender_002.scad`
- Previous version / report: `scad/draft/pocketbook_ladestaender_001.scad` / `qa/pocketbook_ladestaender_001/report.md`
- Context read: printer.md, tolerances.md, materials.md, failure-modes.md
- Check date: 2026-09-27
- Requirements table passed in by the caller (R1–R16, R16 new in _002 at the user's request; same content as the file header).

## Summary

| Stage | Result | Short note |
|---|---|---|
| G1 Technical | PASS | 4 parts `Simple: yes`, Volumes 2 each as expected, `interference` empty, overhang table empty, no WARN |
| G2 Dimensions | FAIL (minor, 1 row) | 16/16 rows measured: 15 PASS; R10 PASS along the device (94.0), FAIL under the vertical reading adopted in the header (88.3 < 90; echo claims 91.15) |
| G3 Visual (blind) | PASS | all features present and on the correct side; R16 scope for the user to confirm (finding 3) |
| G4 Printability | PASS | _001 shaft ledge fixed (chamfer 25° from vertical); walls ≥ 3 mm; cosmetic sub-0.8 mm wall tops under the rounding (finding 2); tipping backward governs, 18.73° |
| **Recommendation** | **fit_test only** | plug, port, cable and popsocket sizes are assumed or estimated; fit_test first |
| G5 Release (user) | open | |

## G1 Technical

Commands (run 1 generic, run 2 `--add` with targeted cuts):

    python tools/check.py scad/draft/pocketbook_ladestaender_002.scad --part stand=2 --part fit_test=2 --part print=2 --show assembly --empty interference --keep-stl
    python tools/check.py scad/draft/pocketbook_ladestaender_002.scad --add --part stand=2 --part fit_test=2 --cut stand:x=130 --cut stand:x=80 --cut stand:x=100 --cut stand:x=51 --cut stand:x=23.5 --cut stand:z=24 --cut stand:z=20 --cut stand:z=14 --cut stand:z=60 --cut stand:z=105 --cut stand:z=112 --cut fit_test:x=43 --cut fit_test:x=63 --keep-stl

Probes (QA only, read the check output/STL, model unchanged; in `qa/pocketbook_ladestaender_002/extra/`):

    python qa/pocketbook_ladestaender_002/extra/section_nu.py qa/pocketbook_ladestaender_002/check/stand_cut_x130.svg   # also x80, x100, x51
    python qa/pocketbook_ladestaender_002/extra/section_xy.py qa/pocketbook_ladestaender_002/check/stand_cut_z24.svg qa/pocketbook_ladestaender_002/check/stand_cut_z14.svg qa/pocketbook_ladestaender_002/check/stand_cut_z60.svg qa/pocketbook_ladestaender_002/check/stand_cut_z105.svg qa/pocketbook_ladestaender_002/check/stand_cut_z112.svg
    python qa/pocketbook_ladestaender_002/extra/load_case.py
    python qa/pocketbook_ladestaender_002/extra/rest_wall_top.py

Result `check/check.md`: **G1 PASS** (OpenSCAD 2021.01, build volume 250 x 250 x 250).

| Part | Status | Simple | Volumes (exp.) | Size X x Y x Z [mm] | Min Z | Volume cm³ |
|---|---|---|---|---|---|---|
| stand | PASS | yes | 2 (2) | 120.00 x 80.00 x 114.83 | 0.00 | 238.19 |
| fit_test | PASS | yes | 2 (2) | 86.00 x 41.03 x 43.42 | 0.00 | 70.29 |
| print | PASS | yes | 2 (2) | 120.00 x 80.00 x 114.83 | 0.00 | 238.19 |
| assembly | PASS | yes | 3 (view only) | 162.00 x 100.00 x 165.23 | 0.00 | 554.79 |
| interference | PASS | – | empty (empty) | – | – | – |

Overhangs > 45° (check.md): **0.0 mm² total** for stand, fit_test and print (in _001: 2 x 80 mm² shaft ledge).

Sections (check.md):

| Cut | # | Kind | 1st range | 2nd range | Area mm² |
|---|---|---|---|---|---|
| stand x130 | 1 | material | Y 0..80 | Z 0..114.83 | 2636.2 |
| stand x80 | 1 | material | Y 0..80 | Z 0..114.83 | 2259.1 |
| stand x100 | 1 | material | Y 0..80 | Z 0..40.00 | 802.8 |
| stand x51 | 1 | material | Y 0..80 | Z 0..111.80 | 1348.1 |
| stand x23.5 | 1 | material | Y 0..78.00 | Z 0..113.98 | 2603.0 |
| stand z24 | 1 | material | X 21..141 | Y 8.74..43.85 | 2891.7 |
| stand z20 | 1 | material | X 21..141 | Y 7.28..42.40 | 2874.3 |
| stand z14 | 1 | material | X 21..141 | Y 5.10..40.21 | 2874.3 |
| stand z60 | 1/2 | material | X 103..141 / 21..97 | Y 42.06..56.96 | 566.1 / 547.2 |
| stand z105 | 1/2 | material | X 103..141 / 21..97 | Y 58.44..73.33 | 566.0 / 546.9 |
| stand z112 | 1/2/3 | material | X 103..140.14 / 76..97 / 21.86..26 | Y 60.98..72.28 | 401.5 / 237.2 / 28.9 |
| fit_test x43 | 1 | material | Y 0..41.03 | Z 0..43.42 | 778.5 |
| fit_test x63 | 1 | material | Y 0..41.03 | Z 0..40.00 | 492.0 |

Vertices from the section SVGs (Y/Z in mm, probes `section_nu.py` / `section_xy.py`):
- x130 (full profile): bottom (0,0)→(80,0); rear foot edge 5.0 + r3 arc to (77,8); base top z 8 to (43.74,8); concave fillet r4 to (39.98,13.37); backrest rear face 70.000° to (74.11,107.13); r4 arc; top face 7.000 at 160° (71.72,112.26)→(65.14,114.65); r3 arc to (61.30,112.86); backrest front face −110° (= 70°) down to **(29.147,24.528)**; support 15.0 at 160° to **(15.052,29.659)** = device origin O; lip inner face 8.800 at 70° + r1.2 arc; lip top flat 1.300 + r1.5 arc; lip front face 70° to (0,0). Lip total height 10.0 along the device, thickness 4.0.
- x80 (shaft): front face ends at (30.002,26.878) = n 15/u 2.5; **chamfer (30.002,26.878)→(31.496,23.673), 3.536 long, −65° = 25° from vertical, faces forward-down**; shaft rear wall 22.0 at −110° to (23.972,3.000); floor 17.000 at 160° to (7.997,8.814); front wall 22.000 at 70° to (15.521,29.488); 0.500 step to O.
- x100 (channel): channel floor z **12.975** from y 27.602 (shaft rear wall) to 39.875 (fillet); no material above it except the lip (Z max 40.0 = lip top).
- x51 (pocket): pocket back face n = 26 from (72.615,111.795) down to (44.272,33.922); pocket bottom 11.000 at 160° to (33.935,37.684) = u 14; rest wall behind it 3.0 perpendicular.
- z24 / z14: shaft notch X **45.00..115.00** (70.0), Y 13.52..31.34 (z24) / 9.88..27.98 (z14, 18.10 horizontal = 17.0 perpendicular); channel X **97.00..103.00** (6.0) from the shaft rear wall to the rear.
- z60: pocket X **26.00..76.00** (50.0), Y 42.06..53.76 (11.70 = 11.0 perpendicular), rest to 56.96 (3.20 = 3.0 perpendicular); left rim X 21..26 = **5.0** (7.0 in _001).
- z105 / z112 / x23.5: backrest head rounded in the front view (X from 21.86 at z 112, arc to 140.14); foot rear corners rounded (x23.5 ends at Y 78.0 = r8 corner).

echo() claims and check: slot 15 (confirmed), 70° (confirmed), support z 29.6586–24.5283 (confirmed 29.659/24.528), 120 x 80 x 114.83 (confirmed), volume 238.508 cm³ / mass 177.45 g (STL 238.19 cm³ / 177.2 g, confirmed within 0.2 %), shaft 70 x 17 x 22 with chamfer 2.5 at 25° (confirmed), pocket 50 wide, 11 deep, bottom u 14 (confirmed), **"Stütze senkrecht 91.15 mm über der Auflage" NOT confirmed as contact height: the flat contact ends at 88.33 vertical (finding 1)**, tipping device only 26.756°/18.727° (confirmed 26.76/18.73), with stand 31.70°/24.86° (confirmed 31.69/24.87), push 105.3 g (confirmed), channel floor 12.9751 (confirmed), rest behind pocket 3 (confirmed).

No WARN.

## G3 Blind description

_Written from the images of run 1 only (stand/print/fit_test/assembly iso/front/side/top), before the requirements were read in detail._

- `stand` / `print`: one body, 120 x 80 x 115, standing on a flat footprint on the bed (z = 0). Side view (YZ): a leaning profile. At the front (small Y) a solid wedge whose front face leans back at ~70°, topped by a thin lip at about z 40. Behind the lip an open slot leaning back, then a plate ~14–15 mm thick (backrest) leaning back parallel to it up to z ≈ 115, with a rounded head. At the back a thin base plate (~8 mm) runs to Y = 80 with a rounded rear top edge. The backrest meets the base plate with a concave fillet.
- Front view: a narrow gap ~6 mm wide at X ≈ 97..103 (stand frame) cuts the backrest from the top down to about the lip height (z ≈ 40). The backrest is two tongues (left ~76, right ~38 wide). The top corners of the backrest are rounded (r ≈ 8). The top edge over X ≈ 26..76 is ~3 mm lower than the rest. The front block is rectangular with sharp corners.
- Iso: in the front face of the left tongue a U-shaped pocket (round bottom, open to the top edge). To its left only a narrow column (~5 mm) remains up to the top. The lip top edge is rounded.
- Top view: under the slot a rectangular recess X ≈ 45..115 (a shaft below the support). From it a stripe (the gap) runs backward to about Y 74. The pocket shows as a half-round recess on the left. The rear corners of the footprint are rounded, the front corners are sharp.
- `assembly`: a board 162 x ~145 (device) leans in the slot, wider than the stand by ~21 per side. A thin rod (cable) runs backward at z ≈ 12–15 above the base plate to Y = 100, leaving at X ≈ 100.
- `fit_test`: a slice of the front block, 86 wide, 41 deep, 43 high: lip, slot, stubs of both backrest tongues with the gap between them, part of the pocket bottom (curved notch on the left), cut vertically at the rear. A small notch at the rear edge at z ≈ 8–16 (the fillet cut open).
- Nothing floating, no extra body. Bed face = footprint underside.

## G2 Dimensions: requirements table, target vs. actual

Device frame: u along the device face (up), n perpendicular (backward), origin O = lip inner face / support corner (15.052, 29.659), tilt 20° from vertical (section x130).

| ID | Requirement | Target | Source | Actual | How measured | Result |
|---|---|---|---|---|---|---|
| R1 | Device landscape 162 x 145 x 13, may overhang at the sides | fits | 145 measured, 162 estimated, 13 approx. | stand X 21..141 (120), device 0..162 overhangs 21 per side; slot open in X; backrest 97 along < 145; assembly bbox 162 x 100 x 165.23 | bbox, x130 | PASS |
| R2 | Slot for the thickness | 15 (+1/−0) | approx. measured | 15.00 perpendicular (support length at 160° between lip inner face and backrest face) | x130 vertices | PASS (at lower limit; 2 mm total for 13) |
| R3 | Inclination | 70° ±1° | user | 70.000° (lip front/inner, backrest front/rear, shaft walls) | x130/x80 edge angles | PASS |
| R4 | Two supports, shaft 70 (X) x 17 (across) | 70 x 17 | assumed | shaft X 45.00..115.00 (70.0) x 17.000 (n 0.5..17.5); supports X 21..45 (24) and 115..141 (26), each n 0..15 | z24, z14, x80 | PASS |
| R5 | Port centre ~80 from left, centred in thickness | shaft centred on it | estimated | shaft X centre 80.0; n centre 9.0 vs port n 8.5 (plug n 5..12 has 4.5/5.5 to the walls) | z14, x80 | PASS |
| R6 | Room for angled plug, shaft depth under device | ≥ 20 | assumed | **22.000** (front and rear walls, u 0..−22); plug 15 → 7 margin; `interference` (device + popsocket + plug + cable) empty | x80, interference | PASS |
| R7 | Cable channel open at the top, from shaft to the rear | ≥ 5 wide, lay in from above | assumed | 6.0 wide (X 97..103), floor z 12.975 from the shaft rear wall (y 27.6) to the rear; open to the top along its full length (x100: no material above except the lip); cable Ø4 at z 15.475 → 0.5 to the floor | z14, z24, x100 | PASS |
| R8 | Popsocket Ø40 x 7, centre u 39 / x 51 | pocket ≥ Ø46, depth ≥ 9 | estimated | pocket **50.0** wide (X 26..76, centre 51), depth **11.0**, bottom u 14 (popsocket u 19..59 → 5 below), 5 per side, 4 behind; open to the top; rest wall 3.0 | z60, x51, interference | PASS |
| R9 | Front lip | ~10 high | assumed | 10.0 along the device (8.8 straight + r1.2), 4.0 thick | x130 | PASS |
| R10 | Backrest above the CG | contact ≥ 90 above bottom edge | assumed | flat contact face to u = **94.0** along the device (97 − r3 head rounding); vertical: z 24.528 → 112.859 = **88.33**; CG at u 72.5 | x130 vertices | PASS along the device / **FAIL vertical (−1.7)**, finding 1 |
| R11 | Tipping ≥ 15° front and back, 330 g | ≥ 15° | assumed | device only: forward 26.76°, backward **18.73°**; with stand (STL, 177.2 g): 31.69°/24.87°; sideways ≥ 30.1° | recalculated (`load_case.py`) | PASS |
| R12 | PLA, no supports | overhang ≤ 45°, walls ≥ 0.8 | user | overhang table empty; steepest faces 25° (shaft chamfer), 20° (lip inner, backrest rear, shaft front wall); walls ≥ 3.0 (see G4), cosmetic sub-0.8 tops under the rounding (finding 2) | check.md, x80, x51, probe | PASS |
| R13 | Build volume | ≤ 250³ | printer | stand/print 120 x 80 x 114.83; fit_test 86 x 41.03 x 43.42 | bbox | PASS |
| R14 | Parts in print | 1 volume | – | print Volumes 2 (= 1 body), Simple yes | check.md | PASS |
| R15 | Fit test | shaft, channel, supports | – | fit_test X 37..123 (stand frame): shaft complete with chamfer, channel 97..103, supports 8 each side, lip, slot, backrest stubs to z 43.42, pocket bottom partly; 1 body | check.md, fit_test images, x43/x63 | PASS (limits: finding 6) |
| R16 | Rounded corners; bed edges and support/slot sharp | visible outer corners rounded | user | rounded: lip top r1.5/r1.2, head r3/r4, fillet r4, base rear edge r3, head sides r8 (front view), rear foot corners r8 (top view); sharp: bed edges, support corners D/E (as required); **also sharp**: front footprint corners / lip ends (front block, X 21 and 141), long side edges, cut-out edges (pocket, channel, shaft) | images, x130, z105/z112, x23.5 | PASS as specified, scope for the user (finding 3) |

## G3 Comparison: description vs. requirements

- Leaning profile, lip, slot, backrest, base plate → R2, R3, R9, R10. Matches.
- Vertical gap through the backrest (X 97..103) → cable channel R7, open to the top, so it splits the backrest. Explained (finding 5).
- U-shaped pocket, open to the top, left of centre → popsocket pocket R8 (X 26..76, centre 51). Right side. The ~5 mm column to its left is the pocket rim (5.0 at z60). The lower top edge over X 26..76 is the 3 mm rest wall behind the pocket (top z 111.8 vs 114.83).
- Recess under the slot → plug shaft R4/R5/R6, centred on X 80; channel to the right of the plug.
- Rod in the assembly at z 12–15 → cable dummy (Ø4 at z 15.475), leaves through the channel. Matches R7.
- Rounded head, lip, fillet, rear foot corners; sharp front corners → R16. The sharp front corners are not named in R16's exceptions → finding 3.
- Notch at the rear of the fit_test → the fillet cut open by the fit_test box at Y 41.03. Explained, no function.
- Checklist: features complete (F14: yes, all R rows visible); sides correct (F5/F6: pocket left, channel right of the port, lip at the front, chamfer at the rear of the shaft); nothing floating, Volumes 2 (F8); bed face = footprint, min Z 0, no overhang (F13); assembly device/popsocket/plug/cable in place, interference empty; proportions plausible. The 5 mm rim and the 3 mm rest wall are visibly thin but measured ≥ 3 mm below their rounded tops (finding 2).

## G4 Printability

| Check | Value | Limit | Result |
|---|---|---|---|
| Min. wall / residual width | rest wall behind pocket 3.0 (3.2 horizontal); left pocket rim 5.0; lip 4.0 (1.3 flat on top after r1.5 + r1.2); shaft front wall 4.5; shaft floor 3.0 vertical; rest wall top: layer width < 0.8 only in the top ~0.5 mm (z 111.3–111.8: 0.77 → 0.00), ridge ~71°; left rim top: front-view r8 runs into the pocket face at X 26, ridge ~68° | ≥ 0.8 | PASS (cosmetic tops, finding 2) |
| Overhangs | check.md 0.0 mm²; shaft chamfer 25° from vertical (was 70° ledge in _001); lip inner face, backrest rear face, shaft front wall 20° | ≤ 45° (R12) | PASS |
| Bridges | none (shaft, channel, pocket open to the top) | – | PASS |
| Build volume (parts and `print` plate) | 120 x 80 x 114.83; fit_test 86 x 41.03 x 43.42 | 250³ | PASS |
| Assembly access | plug into the device first, device lowered along u (plug n 5..12 inside shaft n 0.5..17.5, X 74..86 inside 45..115); popsocket slides down into the pocket open to the top; cable laid from above into the channel open to the top; cable bend in the shaft: max bend radius ≈ 8.7 mm (bend must finish between y 18.9 and the shaft rear wall at y 27.6, x ≤ 100) | free path | PASS (bend radius for an assumed Ø4 cable, fit_test) |
| Load case (governing failure mode) | **Tipping backward** governs: 18.73° (device only, conservative; device CG y 47.84, z 94.88); with stand 24.87°; push at the device top edge (z 165.23) to tip ≈ 1.03 N (105 g). Breaking not critical: backrest root, all load on the 38 mm right tongue, M 150 Nmm, W 1241 mm³, σ 0.12 MPa, SF ≈ 207 vs 25 MPa (Z layer adhesion). Sliding not critical (lip holds by shape) | R11 ≥ 15° | PASS |

Load case recalculated independently (`extra/load_case.py`): stand volume and centroid from the STL (238.19 cm³, CG x 85.78, y 41.70, z 35.17; mass 177.2 g at fill 0.6), device CG from the measured origin O. Worst case: device only / backward. The stand only adds stability. Sideways: popsocket fixes X to ±5 mm → ≥ 30.1°.
Parametric sweep (rule `verify-parametric-geometry`): n/a, no organic contour. The rounding radii are checked by tangent-length asserts in the file, and the sections show no reversed contour.

Fits: no press or sliding fit. The slot (15 for 13) is loose, but device, port, plug, cable and popsocket sizes are estimated or assumed → "fit test first" per `pre-print-gate` → fit_test.

Status of the _001 findings:

| _001 # | Topic | Status in _002 |
|---|---|---|
| 1 | shaft ledge 70° overhang | fixed: chamfer 2.5, 25° from vertical, overhang table empty |
| 2 | R10 vertical reading (89.3) | partly: back_h 97, but the new r3 head rounding cuts the flat contact to 94.0 along = 88.33 vertical (finding 1) |
| 3 | R6/R8 at minimum | fixed: shaft 22, pocket 50 x 11 |
| 4 | popsocket fixes the position, 3 mm | improved: 5 mm per side/below; position still estimated (finding 4) |
| 5 | split backrest | unchanged, information (finding 5) |
| 6 | echo mass from the uncut profile | fixed: echo 177.45 g vs STL 177.2 g |
| 7 | push force ~1 N | unchanged, information (finding 7) |
| 8 | fit_test limits | unchanged (finding 6) |

## Findings

Not fixed by QA (rule `printability-report`).

1. **G2, R10: claim ≠ result.** The new head rounding G (r = 3, R16) ends the flat contact face at u = 94.0. Vertically that is z 24.528 → 112.859 = **88.33 mm**, not the 91.15 mm the echo reports (the echo measures to the unrounded profile corner F(slot_w, back_h)). Along the device 94.0 ≥ 90 → PASS. Under the vertical reading, which the header adopts for _001 finding 2 ("damit R10 auch senkrecht gilt"), it is FAIL by 1.7 mm. Function: CG at u 72.5, so the contact is well above it. Recommendation: the user settles the reading. If vertical, the design-agent sets back_h ≥ 99 ((99 − 3) · sin 70° = 90.2) and bases the echo on back_h − r.
2. **G4, residual width at wall tops (F9-type, cosmetic).** Behind the pocket the 3 mm rest wall has no flat top left: the rear radius r4 (centre n 25) runs into the pocket face at n 26. Layer width is < 0.8 mm over the top ~0.5 mm (z 111.3–111.8, ridge ~71°). Likewise the 5 mm left rim: the front-view radius r8 meets the pocket face at X 26 (ridge ~68°). This is not structural (no load there). The slicer may drop or thin the last layers, and the ridges are sharp to the touch. No assert covers residual widths after rounding. Recommendation: accept, or the design-agent uses r ≤ 3 at the rear head corner (the arc then ends tangentially on the pocket face).
3. **G3, R16 scope.** Rounded as the header describes. Still sharp: the front corners of the footprint / front block and the lip ends (X 21 and 141, from the bed up to z 40), all long side edges, and the edges of pocket, channel and shaft cut-outs. R16's stated exceptions name only bed edges and support/slot. Rounding the front corners in the top view would be printable without an overhang. Recommendation: the user checks `stand_iso.png` / `stand_top.png` and decides in G5 whether that is what was meant.
4. **G2/G4, popsocket position (F15 risk, improved).** Clearance is now 5 mm per side and below (was 3). The position (x 51, u 39) is still estimated. The fit_test contains only the pocket bottom and right wall (X 76), not the left wall (X 26). Recommendation: measure the popsocket position with calipers before the full part.
5. **G3, split backrest (information).** The open channel (R7) splits the backrest from z 12.975 into tongues of 76 and 38 mm. SF ≈ 207. Follows from R7.
6. **R15, fit_test limits.** The footprint ends at Y 41.03, device CG at Y 47.84: the fit_test does not stand with the device in it, hold it by hand. It checks plug in the shaft, chamfer, supports, slot, lip, channel and cable bend (max bend radius ≈ 8.7 mm for the assumed Ø4 cable; the real UGREEN cable may be stiffer). Popsocket only partly (finding 4). Backrest contact only up to z 43.4.
7. **G4, information.** About 1.03 N (105 g) at the device's top edge tips the stand backward. Fine for a charging stand that is not operated (R11). A bump can knock it over.

## G5 Release

- Released by the user: _open_
- Scope: recommended `fit_test` only

## Export

- _none yet_

## Print result

_After printing, skill `print-feedback`._

| ID | Observation in the print | Matches prediction? |
|---|---|---|
| | | |

- Escaped defects → added to `context/failure-modes.md` as: …
- Fit findings → `context/tolerances.md`: …
