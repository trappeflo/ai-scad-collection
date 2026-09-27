# QA report: `pocketbook_ladestaender_003`

Rule `pre-print-gate`. Saved as `qa/pocketbook_ladestaender_003/report.md`.
G1–G4 written by the `qa-agent` (returned as text, saved unchanged by the
design-agent), G5 by the user, "Print result" after printing.

- File: `scad/draft/pocketbook_ladestaender_003.scad`
- Previous version / report: `scad/draft/pocketbook_ladestaender_002.scad` / `qa/pocketbook_ladestaender_002/report.md`
- Context read: printer.md, tolerances.md, materials.md, failure-modes.md
- Check date: 2026-09-27
- Requirements table passed in by the caller (R1–R16; R10 and R16 made more precise in _003, same content as the file header).

## Summary

| Stage | Result | Short note |
|---|---|---|
| G1 Technical | PASS | print/stand/fit_test `Simple: yes`, 2 volumes each as expected, `interference` empty, overhang table 0.0 mm², no WARN |
| G2 Dimensions | PASS | 16/16 rows measured, 16 PASS. R10 vertical 90.21 (margin 0.21, finding 1) |
| G3 Visual (blind) | PASS | all features present and on the correct side; R16 front corners/lip ends now rounded |
| G4 Printability | PASS | walls ≥ 3.0; rest-wall/rim tops now end in 90° edges (_002 finding 2 fixed); tipping backward governs, 18.73° |
| **Recommendation** | **fit_test only** | plug, port, cable and popsocket position are assumed/estimated |
| G5 Release (user) | open | |

## G1 Technical

Commands (run 1 generic, plus one mid-height cut; run 2 `--add` with targeted cuts):

    python tools/check.py scad/draft/pocketbook_ladestaender_003.scad --part print=2 --part stand=2 --part fit_test=2 --show assembly --empty interference
    python tools/check.py scad/draft/pocketbook_ladestaender_003.scad --add --part print=2 --cut print:z=58
    python tools/check.py scad/draft/pocketbook_ladestaender_003.scad --add --part stand=2 --part fit_test=2 --keep-stl --cut stand:x=130 --cut stand:x=80 --cut stand:x=100 --cut stand:x=51 --cut stand:x=21.5 --cut stand:x=23.5 --cut stand:x=140 --cut stand:z=24 --cut stand:z=14 --cut stand:z=4 --cut stand:z=36 --cut stand:z=60 --cut stand:z=105 --cut stand:z=112 --cut stand:z=115 --cut fit_test:x=43 --cut fit_test:x=63

Probes (QA only; they read the check output/STL and leave the model unchanged; in `qa/pocketbook_ladestaender_003/extra/`):

    python qa/pocketbook_ladestaender_003/extra/section_nu.py qa/pocketbook_ladestaender_003/check/stand_cut_x130.svg   # also x80, x100, x51, x21.5, x23.5, x140
    python qa/pocketbook_ladestaender_003/extra/section_xy.py qa/pocketbook_ladestaender_003/check/stand_cut_z24.svg     # also z14, z36, z60, z112
    python qa/pocketbook_ladestaender_003/extra/load_case.py
    python qa/pocketbook_ladestaender_003/extra/rest_wall_top.py

(`section_nu.py`, `section_xy.py` copied unchanged from _002; `load_case.py` = _002 probe with the STL path changed to _003; `rest_wall_top.py` rewritten for the _003 head geometry r3/back_h 99.)

Result `check/check.md`: **G1 PASS** (OpenSCAD 2021.01, build volume 250 x 250 x 250).

| Part | Status | Simple | Volumes (exp.) | Size X x Y x Z [mm] | Min Z | Volume cm³ |
|---|---|---|---|---|---|---|
| print | PASS | yes | 2 (2) | 120.00 x 80.00 x 116.71 | 0.00 | 240.05 |
| stand | PASS | yes | 2 (2) | 120.00 x 80.00 x 116.71 | 0.00 | 240.05 |
| fit_test | PASS | yes | 2 (2) | 86.00 x 41.03 x 43.42 | 0.00 | 70.29 |
| assembly | PASS | yes | 3 (view only) | 162.00 x 100.00 x 165.23 | 0.00 | 556.65 |
| interference | PASS | – | empty (empty) | – | – | – |

Overhangs > 45° (check.md): **0.0 mm² total** for print, stand and fit_test.

Sections (check.md, stand frame X 21..141; `print` is shifted by −21 in X):

| Cut | # | Kind | 1st range | 2nd range | Area mm² |
|---|---|---|---|---|---|
| print z58 | 1/2 | material | X 82..120 / 0..76 | Y 41.33..56.23 | 566.1 / 548.9 |
| stand x130 | 1 | material | Y 0..80 | Z 0..116.71 | 2665.7 |
| stand x80 | 1 | material | Y 0..80 | Z 0..116.71 | 2288.6 |
| stand x100 | 1 | material | Y 0..80 | Z 0..40.00 | 802.8 |
| stand x51 | 1 | material | Y 0..80 | Z 0..113.80 | 1355.6 |
| stand x21.5 | 1 | material | Y 3.63..74.96 | Z 0..115.34 | 2454.1 |
| stand x23.5 | 1 | material | Y 0.99..78.00 | Z 0..116.71 | 2610.4 |
| stand x140 | 1 | material | Y 2.64..76.06 | Z 0..116.00 | 2513.3 |
| stand z24 | 1 | material | X 21..141 | Y 8.74..43.85 | 2877.3 |
| stand z14 | 1 | material | X 21..141 | Y 5.10..40.21 | 2859.9 |
| stand z4 | 1 / 2 | material / hole | X 21..141 / 45..115 | Y 1.46..80 / 21.22..24.34 | 9386.0 / 217.8 |
| stand z36 | 1/2/3 | material | X 21..97 / 103..141 / 21.28..140.72 | Y 33.32..48.22 / same / 13.10..17.36 | 1132.3 / 566.1 / 496.8 |
| stand z36 | 4 | hole | X 40.78..61.22 | Y 38.56..45.03 | 88.2 |
| stand z60 | 1/2 | material | X 103..141 / 21..97 | Y 42.06..56.96 | 566.1 / 547.2 |
| stand z105 | 1/2 | material | X 103..141 / 21..97 | Y 58.44..73.33 | 566.1 / 547.0 |
| stand z112 | 1/2 | material | X 103..141 / 21..97 | Y 60.98..75.13 | 533.3 / 485.6 |
| stand z115 | 1/2/3 | material | X 103..140.66 / 76..97 / 21.33..26 | Y 62.10..70.04 | 291.7 / 166.7 / 29.7 |
| fit_test x43 | 1 | material | Y 0..41.03 | Z 0..43.42 | 778.5 |
| fit_test x63 | 1 | material | Y 0..41.03 | Z 0..40.00 | 492.0 |

The two "hole" contours are explained. z4: the shaft floor slopes down 20° toward the rear (lowest point z 3), so a horizontal cut at z 4 crosses it as a closed trough. z36: the U-shaped pocket bottom also slopes down toward the rear, so a trough again. Both are open to the top and face upward, so they are not cavities or overhangs.

Vertices from the section SVGs (Y/Z in mm):
- x130 (full profile): bottom (0,0)→(80,0); rear edge 5.0 + r3 to (77,8); base top z 8 to (43.742,8); concave fillet r4 to (39.983,13.368); backrest rear face at 70.00° to (75.137,109.950); r3 arc; top face **8.000** at 160° (73.344,113.796)→(65.826,116.532); r3 arc to **(61.981,114.739)** = end of the straight contact face; backrest front face at −110° (= 70°) down to **(29.147,24.528)**; support 15.00 at 160° to **(15.052,29.659)** = device origin O; lip inner face 8.800 at 70° + r1.2; lip top flat 1.300 + r1.5; lip front face at 70° (41.518 long) to (0,0).
- x80 (shaft): shaft front wall 22.000 at 70° (7.997,8.814)→(15.521,29.488), 0.500 step to O; floor 17.000 at 160° from (23.972,3.000); rear wall 22.0 up to (31.496,23.673); **chamfer 3.536 at −65° (25° from vertical)** to (30.002,26.878); backrest front face above.
- x100 (channel): channel floor **z 12.975** from y 27.602 (shaft rear wall) to 39.875 (fillet); no material above it except the lip (Z max 40.0).
- x51 (pocket): pocket back face n = 26 from (73.344,113.796) = F(26, 99) down to (44.272,33.922); pocket bottom 11.000 at 160° to (33.935,37.684) = u 14; rest wall n 26..29 = 3.0 perpendicular.
- x21.5 / x23.5 / x140 (near the ends): front face set back to y 3.63 / 0.99 / 2.64 at z 0 (front rounding r6); rear ends at y 74.96 / 78.00 / 76.06 (foot corner r8); head top 115.34 / 116.71 / 116.00 (side rounding r5); at x21.5 the lip is only n −0.6..0 thick (rounded lip end).
- z24 / z14: shaft X **45.00..115.00** (70.0), Y 9.88..27.98 at z14 (18.10 horizontal = 17.0 perpendicular); channel X **97.00..103.00** (6.0) from the shaft rear wall to the rear; front corners rounded (X 21..25.49, arc).
- z36: lip X **21.28..140.72** (lip ends rounded).
- z60: pocket X **26.00..76.00** (50.0), Y 42.06..53.76 (11.70 = 11.0 perpendicular), rest to 56.96 (3.20 = 3.0 perpendicular); left rim X 21..26 = 5.0.
- z112 / z115: head rounded in the front view (arc from X 21.00 to 22.37 at z 112); at z 115 the left rim X 21.33..26.00 remains, nothing between X 26 and 76 (rest wall top z 113.80).

echo() claims and check:

| Claim | Check |
|---|---|
| slot 15 | confirmed |
| inclination 70° | confirmed |
| support z 29.6586 to 24.5283 | confirmed (29.659 / 24.528) |
| 120 x 80 x 116.71 | confirmed |
| volume 240.773 cm³ / mass 179.1 g | STL 240.05 cm³ / 178.6 g, 0.3 % |
| shaft 70 x 17 x 22, chamfer 2.5 at 25° | confirmed |
| pocket 50 wide, 11 deep, bottom u 14 | confirmed |
| straight contact to u 96 along, 90.2105 vertical | **confirmed**: 114.739 − 24.528 = 90.211 |
| tipping device only 26.756° / 18.727° | confirmed (26.76 / 18.73) |
| tipping with stand 31.70° / 24.77° | recalculated 31.69 / 24.74 |
| push 105.4 g | recalculated 105.2 g |
| channel floor 12.9751 | confirmed |
| rest behind pocket 3 | confirmed |

No WARN.

## G3 Blind description

_Written from the images of run 1 only (print/stand/fit_test/assembly iso/front/side/top, cut print z58), before the requirements were read in detail._

- `print` / `stand`: one body, 120 x 80 x ~117, standing on a flat footprint on the bed (z = 0). Side view (YZ): a leaning profile. At the front a solid wedge whose front face leans back at ~70°, topped by a thin lip at about z 40 with a rounded tip. Behind it an open slot, then a ~15 mm thick plate (backrest) leaning back parallel to it up to z ≈ 117, with a rounded head. A thin base plate (~8 mm) runs back to Y = 80 with a rounded rear top edge. There is a concave fillet between the backrest and the base plate.
- Front view: a narrow vertical gap ~6 mm wide at X ≈ 76..82 (print frame) cuts through the backrest from the top down to lip height. The backrest is two tongues (left ~76, right ~38 wide). The outer top corners of the backrest are rounded. The top edge over X ≈ 5..55 is slightly lower than the rest. The front block has rounded vertical edges at both X ends.
- Iso: in the front face of the left tongue a U-shaped pocket (round bottom, open to the top edge). To its left a narrow column (~5 mm) remains. The lip top is rounded.
- Top view: under the slot a rectangular recess X ≈ 24..94 (print frame), a shaft below the support. From it a stripe (the gap) runs backward. The pocket shows as a half-round recess on the left. All four footprint corners are rounded: the rear ones with a large radius, the front ones smaller, along the leaning front.
- Cut z58: two separate material strips ~15 deep (Y 41..56). The left one has a recess X 5..55, open to the front and ~12 deep, with a ~3 mm wall behind it. The gap is X 76..82.
- `assembly`: a board 162 x ~145 (device) leans in the slot and overhangs the stand on both sides. A thin rod (cable) runs backward at z ≈ 12–15 to Y = 100.
- `fit_test`: a slice of the front block, 86 wide, 41 deep, 43 high: lip, slot, stubs of both backrest tongues with the gap, part of the pocket's curved bottom on the left, cut vertically at the rear.
- Nothing floating, no extra body. Bed face = footprint underside.

## G2 Dimensions: requirements table, target vs. actual

Device frame: u along the device face (up), n perpendicular (backward), origin O = lip inner face / support corner (15.052, 29.659), tilt 20° from vertical (section x130).

| ID | Requirement | Target | Source | Actual | How measured | Result |
|---|---|---|---|---|---|---|
| R1 | Device landscape 162 x 145 x 13, may overhang at the sides | fits | 145 measured, 162 estimated, 13 approx. | stand X 21..141 (120), device 0..162 overhangs 21 per side; slot open in X; backrest 99 along < 145; assembly bbox 162 x 100 x 165.23 | bbox, x130 | PASS |
| R2 | Slot for the thickness | 15 (+1/−0), loose | approx. measured | 15.00 perpendicular (support at 160° between lip inner face and backrest face) | x130 vertices | PASS (at lower limit, 2 mm total for 13) |
| R3 | Inclination | 70° ±1° | user | 70.000° (lip front/inner, backrest front/rear, shaft walls) | x130/x80 edge angles | PASS |
| R4 | Two supports, shaft 70 (X) x 17 (across) | 70 x 17 | assumed | shaft X 45.00..115.00 (70.0) x 17.0 (n 0.5..17.5); supports X 21..45 (24) and 115..141 (26), each n 0..15 | z24, z14, x80 | PASS |
| R5 | Port centre ~80 from left, centred in thickness | shaft centred on it | estimated | shaft X centre 80.0; n centre 9.0 vs port n 8.5 (plug n 5..12: 4.5 front / 5.5 rear clearance) | z14, x80 | PASS |
| R6 | Room for angled plug, shaft depth under device | ≥ 20 | assumed | **22.000** (u 0..−22); plug 15 → 7 margin; `interference` (device + popsocket + plug + cable) empty | x80, interference | PASS |
| R7 | Cable channel open at the top, from shaft to the rear | ≥ 5 wide, lay in from above | assumed | 6.0 wide (X 97..103), floor z 12.975 from the shaft rear wall (y 27.6) to the rear, open to the top over its full length; cable Ø4 at z 15.475 | z14, z24, x100 | PASS |
| R8 | Popsocket Ø40 x 7, centre u 39 / x 51 | pocket ≥ Ø46, depth ≥ 9 | estimated | pocket **50.0** wide (X 26..76, centre 51), depth **11.0**, bottom u 14 (popsocket u 19..59, 5 below), 5 per side, 4 behind; open to the top; rest wall 3.0 | z60, x51, interference | PASS (position estimated, finding 2) |
| R9 | Front lip | ~10 high | assumed | 10.0 along the device (8.8 straight + r1.2), 4.0 thick | x130 | PASS |
| R10 | Straight contact face ends ≥ 90 VERTICALLY above the support | ≥ 90 vertical | assumed | straight front face from (29.147,24.528) to (61.981,114.739): **90.21 vertical**, 96.0 along; CG at u 72.5 | x130 vertices | PASS (margin 0.21, finding 1) |
| R11 | Tipping ≥ 15° front and back, 330 g | ≥ 15° | assumed | device only: forward 26.76°, backward **18.73°**; device leaning on the lip instead: forward 25.7°; with stand (STL, 178.6 g): 31.69° / 24.74°; sideways ≥ 30.1° | recalculated (`load_case.py`) | PASS |
| R12 | PLA, no supports | overhang ≤ 45°, walls ≥ 0.8 | user | overhang table empty; steepest faces 25° (shaft chamfer), 20° (lip inner, backrest rear, shaft front wall); walls ≥ 3.0 (see G4) | check.md, x80, x51, probe | PASS |
| R13 | Build volume | ≤ 250³ | printer | stand/print 120 x 80 x 116.71; fit_test 86 x 41.03 x 43.42 | bbox | PASS |
| R14 | Parts in print | 1 volume | – | print Volumes 2 (= 1 body), Simple yes | check.md | PASS |
| R15 | Fit test | shaft, channel, supports | – | fit_test X 37..123 (stand frame): shaft complete with chamfer, channel 97..103, supports 8 each side, lip, slot, backrest stubs to z 43.42, pocket bottom partly; 1 body; identical to _002 (same bbox and volume 70.29) | check.md, fit_test images, x43/x63 | PASS (limits: finding 4) |
| R16 | Rounded visible outer corners incl. front corners and lip ends; sharp: bed edges, support/slot, shaft/channel/pocket edges, long side edges; no ridges < 0.8 | as specified | user | rounded: front corners / lip ends r6 (z36 lip X 21.28..140.72; x21.5 front at y 3.63), rear foot corners r8, head sides r5 (front view), head front/rear r3, lip top r1.2/r1.5, fillet r4, base rear edge r3. Sharp: bed edges, support/slot, cut-out edges, long side edges (as required). Wall tops beside the pocket: arcs end tangentially in 90° edges (rest wall < 0.8 only in the top 0.35 mm, see G4). Lip end meets the slot face at 72.5° (finding 6) | images, x130, x21.5, x23.5, x140, z36, z112, z115, probe | PASS |

## G3 Comparison: description vs. requirements

- Leaning profile, lip, slot, backrest, base plate → R2, R3, R9, R10. Matches.
- Vertical gap through the backrest (print X 76..82 = stand X 97..103) → cable channel R7, open to the top, so it splits the backrest (finding 3).
- U-shaped pocket, open to the top, left of centre (print X 5..55 = stand X 26..76) → popsocket pocket R8, centre 51. On the correct side. The ~5 mm column to its left is the pocket rim. The lower top edge over the pocket is the 3 mm rest wall behind it (top z 113.80 vs 116.71).
- Recess under the slot (print X 24..94 = stand X 45..115) → plug shaft R4/R5/R6, centred on X 80; the channel is to the right of the plug.
- Rod in the assembly at z 12–15 → cable dummy (Ø4 at z 15.475), leaves through the channel. Matches R7.
- Rounded front corners and lip ends, head, lip top, fillet, rear foot corners → R16 as extended in _003. The sharp long side edges and cut-out edges are allowed exceptions.
- Checklist:
  - Features complete (F14): yes, every R row is visible.
  - Sides correct (F5/F6): pocket left, channel right of the port, lip at the front, chamfer at the rear of the shaft.
  - Nothing floating, Volumes 2 (F8).
  - Bed face = footprint, min Z 0, no overhang (F13).
  - Assembly: device, popsocket, plug and cable in place, interference empty.
  - Proportions plausible. The 5 mm rim and the 3 mm rest wall are visibly thin but measured ≥ 3 mm below their rounded tops.

## G4 Printability

| Check | Value | Limit | Result |
|---|---|---|---|
| Min. wall / residual width | rest wall behind the pocket 3.0 (3.2 horizontal); left pocket rim 5.0; lip 4.0 (1.3 flat on top); shaft front wall 4.5; shaft floor 3.0 vertical. Rest wall top: the r3 arc ends tangentially at the pocket face, giving a 90° edge at z 113.796. Layer width 0.28 / 0.51 / 0.71 / 1.06 / 1.72 mm at 0.1 / 0.2 / 0.3 / 0.5 / 1.0 below that edge, so < 0.8 only in the top ~0.35 mm (1–2 layers; _002: 0.5 mm, 71° ridge). Left rim: front-view r5 is centred at X 26 = pocket face, flat top 2.2 wide, 90° edge. Lip end: 72.5° corner at the slot face, < 0.8 thick only over the last 0.3 mm in X | ≥ 0.8 | PASS |
| Overhangs | check.md 0.0 mm²; shaft chamfer 25° from vertical; lip inner face, backrest rear face, shaft front wall 20°; front rounding r6 is a cylinder along u, its normals are horizontal or point upward | ≤ 45° (R12) | PASS |
| Bridges | none (shaft, channel, pocket open to the top) | – | PASS |
| Build volume (parts and `print` plate) | 120 x 80 x 116.71; fit_test 86 x 41.03 x 43.42 | 250³ | PASS |
| Assembly access | plug goes into the device first, then the device is lowered along u (plug n 5..12 inside shaft n 0.5..17.5, X 74..86 inside 45..115); popsocket slides down into the pocket, which is open to the top; cable laid from above into the channel, which is open to the top. Shaft/channel geometry unchanged from _002 (z14/z24/x100 identical), so the largest cable bend radius stays ≈ 8.7 mm | free path | PASS (bend radius for an assumed Ø4 cable, check in the fit_test) |
| Load case (governing failure mode) | **tipping backward** governs: 18.73° (device only, conservative; device CG y 47.84, z 94.88); with stand 24.74°; horizontal push at the device top edge (z 165.23) to tip ≈ 1.03 N (105 g). Breaking not critical: backrest root, all load on the 38 mm right tongue, M 150 Nmm, W 1241 mm³, σ 0.12 MPa, SF ≈ 207 against 25 MPa (Z layer adhesion). Sliding not critical (lip holds by shape) | R11 ≥ 15° | PASS |

How the load case was recalculated (`extra/load_case.py`):
- Stand volume and centroid are taken from the STL: 240.05 cm³, CG x 85.86 / y 42.06 / z 36.00, 178.6 g at fill 0.6.
- The device CG is placed from the measured origin O.
- The worst case is the device alone, tipping backward. The stand's own mass only adds stability.
- Tipping edges: rear y 80 over X 29..133 (r8 corners), front y 0 over X 27..135 (r6 corners). The device CG sits at X 81, in the middle.
- Rule `verify-parametric-geometry`: no organic contour here. The rounding radii are checked by tangent-length and "radius ≤ wall" asserts in the file, and the sections show no contour running backward.
- Fits: none of them is a press or sliding fit. But device, port, plug, cable and popsocket sizes are estimated or assumed, so `pre-print-gate` requires the fit test first.

Status of the _002 findings:

| _002 # | Topic | Status in _003 |
|---|---|---|
| 1 | R10 vertical 88.3 < 90, echo measured to the unrounded corner | **fixed**: back_h 99, straight contact to z 114.739 = 90.21 vertical; echo 90.2105 confirmed; assert on the contact end |
| 2 | ridges < 0.8 mm at the wall tops beside the pocket | **fixed**: rear head radius 3 = rest wall, side radius 5 = rim; both end tangentially in 90° edges (< 0.8 only in the top ~0.35 mm) |
| 3 | R16 scope (front corners / lip ends sharp) | **fixed**: R16 extended by the user, front corners and lip ends r6 |
| 4 | popsocket position estimated | unchanged (finding 2) |
| 5 | split backrest | unchanged, information (finding 3) |
| 6 | fit_test limits | unchanged (finding 4) |
| 7 | push force ~1 N | unchanged, information (finding 5) |

## Findings

Not fixed by QA (rule `printability-report`).

1. **G2, R10 margin 0.21 mm.** The straight contact ends 90.21 mm vertically above the support (96.0 along the device). PASS. The assert in the file makes any later change to `back_h` or the head radius fail the quick check straight away. No action needed.
2. **G2/G4, popsocket position (F15 risk).** 5 mm clearance per side and below, 4 behind. The position (x 51, u 39) is still estimated. The fit_test contains only the pocket bottom and the right wall (X 76), not the left wall (X 26). Recommendation: measure the popsocket position with calipers before printing the full stand.
3. **G3, split backrest (information).** The open channel (R7) splits the backrest from z 12.975 upward into tongues of 76 and 38 mm. SF ≈ 207. This follows from R7.
4. **R15, fit_test limits.** Unchanged from _002.
   - The footprint ends at Y 41.03 but the device CG is at Y 47.84, so the fit_test does not stand with the device in it. Hold it by hand.
   - It checks the plug in the shaft, the chamfer, supports, slot, lip, channel and the cable bend (largest bend radius ≈ 8.7 mm for the assumed Ø4 cable; the real UGREEN cable may be stiffer).
   - The popsocket is only partly covered (finding 2), and backrest contact only up to z 43.4.
5. **G4, information.** About 1.03 N (105 g) pushed backward at the device's top edge tips the stand over. Fine for a charging stand that is not operated (R11), but a bump can knock it over.
6. **G3/G4, R16 detail (minor).** The rounded lip end (r6 in the plane perpendicular to the device) meets the slot face at a 72.5° corner. The lip is thinner than 0.8 mm only over its last 0.3 mm in X (x21.5 section: 0.6 thick). That edge is a support/slot edge, which R16 allows to stay sharp, and it is not a ridge. No action needed.

## G5 Release

- Released by the user (2026-09-27, verbatim): "pocketbook_ladestaender_003 Freigabe zum Druck, nur fit_test"
- Scope: `fit_test` only. The full stand is not released (popsocket position to be measured first, fit test result pending).

## Export

- 2026-09-27: `fit_test` → `qa/pocketbook_ladestaender_003/pocketbook_ladestaender_003_fit_test.stl` (local, not versioned). Command: `openscad -o qa/pocketbook_ladestaender_003/pocketbook_ladestaender_003_fit_test.stl -D 'part="fit_test"' scad/draft/pocketbook_ladestaender_003.scad`. Log: `Simple: yes`, `Volumes: 2`.

## Print result

_After printing, skill `print-feedback`._

| ID | Observation in the print | Matches prediction? |
|---|---|---|
| | | |

- Escaped defects → added to `context/failure-modes.md` as: …
- Fit findings → `context/tolerances.md`: …
