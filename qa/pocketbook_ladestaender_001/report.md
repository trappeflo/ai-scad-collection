# QA report: `pocketbook_ladestaender_001`

Rule `pre-print-gate`. Saved as `qa/pocketbook_ladestaender_001/report.md`.
G1–G4 written by the `qa-agent` (returned as text, saved unchanged by the
design-agent), G5 by the user, "Print result" after printing.

- File: `scad/draft/pocketbook_ladestaender_001.scad`
- Previous version / report: none
- Context read: printer.md, tolerances.md, materials.md, failure-modes.md
- Check date: 2026-09-27
- Requirements table passed in by the caller (also in the file header, same content).

## Summary

| Stage | Result | Short note |
|---|---|---|
| G1 Technical | PASS | 4 parts `Simple: yes`, Volumes 2 each as expected, `interference` empty, no WARN |
| G2 Dimensions | FAIL (1 row, minor) | 15/15 rows handled: 13 PASS, R12 FAIL (2.35 mm ledge), R15 PASS with limits; R6/R8 exactly at minimum; R10 depends on reading |
| G3 Visual (blind) | PASS | all features present, correct sides; split backrest explained by R7 |
| G4 Printability | FAIL (minor, 1 open violation) | shaft ledge 70° from vertical, 2.35 x 70 mm; walls ≥ 2.8 mm; tipping governs (19.5° backward) |
| **Recommendation** | **fit_test only** | plug/port/popsocket assumed or estimated; ledge is in the fit_test too |
| G5 Release (user) | open | |

## G1 Technical

Commands (run 1 generic, run 2 `--add` with targeted cuts):

    python tools/check.py scad/draft/pocketbook_ladestaender_001.scad --part print=2 --part stand=2 --part fit_test=2 --show assembly --empty interference --keep-stl
    python tools/check.py scad/draft/pocketbook_ladestaender_001.scad --add --part stand=2 --part fit_test=2 --cut stand:x=130 --cut stand:x=80 --cut stand:x=100 --cut stand:x=51 --cut stand:z=25 --cut stand:z=22.9 --cut stand:z=12 --cut stand:z=60 --cut fit_test:x=43 --keep-stl

Probes (QA only, read the check output, model unchanged):

    python qa/pocketbook_ladestaender_001/extra/section_nu.py qa/pocketbook_ladestaender_001/check/stand_cut_x80.svg qa/pocketbook_ladestaender_001/check/stand_cut_x130.svg qa/pocketbook_ladestaender_001/check/stand_cut_x51.svg qa/pocketbook_ladestaender_001/check/stand_cut_x100.svg
    python qa/pocketbook_ladestaender_001/extra/load_case.py

Result `check/check.md`: **G1 PASS** (OpenSCAD 2021.01, build volume 250 x 250 x 250).

| Part | Status | Simple | Volumes (exp.) | Size X x Y x Z [mm] | Min Z | Volume cm³ |
|---|---|---|---|---|---|---|
| print | PASS | yes | 2 (2) | 120.00 x 80.00 x 111.92 | 0.00 | 215.68 |
| stand | PASS | yes | 2 (2) | 120.00 x 80.00 x 111.92 | 0.00 | 215.68 |
| fit_test | PASS | yes | 2 (2) | 86.00 x 38.90 x 41.54 | 0.00 | 60.95 |
| assembly | PASS | yes | 3 (view only) | 162.00 x 100.00 x 163.35 | 0.00 | 532.29 |
| interference | PASS | – | empty (empty) | – | – | – |

Overhangs > 45° (check.md): only one face, in every part: z 23–23.5,
2 x 80 mm², X = shaft range (stand 45..115), Y 28.80..31.15. This is the
shaft ledge (finding 1).

Sections (check.md, stand):

| Cut | # | Kind | 1st range | 2nd range | Area mm² |
|---|---|---|---|---|---|
| x130 | 1 | material | Y 0..80 | Z 0..111.92 | 2331.1 |
| x80 | 1 | material | Y 0..80 | Z 0..111.92 | 1988.6 |
| x100 | 1 | material | Y 0..80 | Z 0..38.54 | 759.4 |
| x51 | 1 | material | Y 0..80 | Z 0..108.84 | 1277.6 |
| z25 | 1/2/3 | material | X 21..141 / 21..97 / 103..141 | Y 9.10..22.00 / 29.32..42.09 / 29.32..42.09 | 980.4 / 970.5 / 485.3 |
| z22.9 | 1/2/3 | material | X 21..141 / 21..97 / 103..141 | Y 8.33..27.77 / 28.55..41.32 / 28.55..41.32 | 1307.1 / 859.1 / 459.6 |
| z12 | 1 | material | X 21..141 | Y 4.37..37.36 | 2631.7 |
| z60 | 1/2 | material | X 21..97 / 103..141 | Y 42.06..54.83 | 530.0 / 485.3 |
| fit_test x43 | 1 | material | Y 0..38.90 | Z 0..41.54 | 670.8 |

Vertices read from the section SVGs (probe `section_nu.py`, Y/Z in mm):
- x130 (full profile): lip front (0,0)→(14.029,38.544), 70.000°; lip top
  4.000 at 160°; lip inner face (14.367,27.779)→(17.788,37.176) 10.000
  at 70.000°; support (28.463,22.649)→(14.367,27.779) 15.0 at 160°;
  backrest front (28.463,22.649)→(60.955,111.920) 95.0 at 70.000°;
  backrest top 12.000; rear face down to (35.901,8.000); base plate
  z 0..8 to y = 80.
- x80 (shaft): shaft front wall (7.997,8.814)→(14.837,27.608) 20.000 at
  70°; floor (23.972,3.000)→(7.997,8.814) 17.000 at 160°; rear wall 21.0
  (u −20..+1); ledge (28.805,23.589)→(31.154,22.733) 2.500 at −20°
  (downward face); 0.500 step between lip face and shaft.
- x51 (pocket): pocket bottom at u = 16 (15.0 above support corner),
  pocket depth 9.000, rest wall 3.000, open to the top.
- x100 (channel): channel floor z = 11.096 from the shaft rear wall
  (26.918) to the rear end; no backrest above it.
- z60: pocket X 28..74 (46.0), Y depth 9.578 (= 9.0 perpendicular),
  rest 3.19 in Y (= 3.0 perpendicular). z12: shaft X 45..115 (70.0),
  channel X 97..103 (6.0).

echo() claims (checked in G2/G4): slot 15, 70°, support z 27.7792–22.6489
(confirmed), 120 x 80 x 111.92 (confirmed), mass ~208.1 g (NOT confirmed,
see finding 6), device-only tipping 26.89°/19.45° (confirmed),
with stand 31.96°/26.39° (real 31.53°/25.43°), push 116.7 g (real 104.9 g),
channel floor 11.0957 (confirmed), rest behind pocket 3 (confirmed).

No WARN.

## G3 Blind description

_Written from the images of run 1 only (stand/print/fit_test/assembly
iso/front/side/top), before the requirements were read in detail._

- `stand` / `print`: one body, 120 x 80 x 112, stands on a flat
  rectangular footprint on the bed (z = 0). Seen from the side (YZ) it is
  a leaning L/V profile: in front (small Y) a solid wedge-shaped block
  whose front face leans back at about 70°. A thin lip on top of it at
  the front, then an open slot leaning back, then a plate about 12 mm
  thick (backrest) that leans back parallel to the slot up to z ≈ 112.
  At the back a thin flat base plate (about 8 mm) reaches to Y = 80.
- Front view: a narrow slot about 6 mm wide at X ≈ 97..103 (in stand
  frame 21..141) cuts the backrest vertically from the top down to below
  the front block's edge. The backrest is two tongues (left about 76,
  right about 38 mm wide). At the top left of the backrest (X ≈ 28..74)
  there is a shallow notch/recess open to the top edge, a pocket in the
  front face.
- Top view: under the slot, a long dark recess X ≈ 45..115 (a pocket
  below the support). The channel continues as a stripe towards the
  back.
- check.md shows an overhang face 70 mm long at z ≈ 23 at the rear of
  that recess (under the backrest).
- `assembly`: a thin board 162 x ~145 (device) leans in the slot. It is
  wider than the stand by about 21 mm per side. A thin rod (cable) runs
  backwards at z ≈ 12–14 over the base plate to Y = 100.
- `fit_test`: a slice of the front block, X 86 wide, with lip, slot
  bottom, stubs of both backrest tongues (the channel gap between them)
  and part of the base, cut vertically at the rear at Y ≈ 39.
- Nothing floating, no extra body. Bed face = bottom of the footprint.

## G2 Dimensions: requirements table, target vs. actual

Device frame for the measurements: u along the device face (up),
n perpendicular (backwards). Origin = lip inner face / support corner
(14.367, 27.779), from section x130.

| ID | Requirement | Target | Source | Actual | How measured | Result |
|---|---|---|---|---|---|---|
| R1 | Device landscape 162 x 145 x 13, may overhang at the sides | fits | 145 measured, 162 estimated, 13 approx. | stand 120 wide, device overhangs 21 per side; slot open in X; backrest 95 < 145; assembly bbox 162 x 100 x 163.35 | bbox, x130 | PASS |
| R2 | Slot for the thickness | 15 (+1/−0) | approx. measured | 15.00 perpendicular (lip inner face ↔ backrest face) | x130 vertices | PASS (at lower limit, effectively ~14.6 after X/Y error, still > 13) |
| R3 | Inclination | 70° ±1° | user | 70.000° (lip, backrest, shaft walls) | x130/x80 edge angles | PASS |
| R4 | Device on two supports, shaft 70 (X) x 17 (across) | 70 x 17 | assumed | 70.0 (X 45..115) x 17.000 (n 0.5..17.5); supports X 21..45 (24) and 115..141 (26), each 15 deep | z12, z25, x80 | PASS |
| R5 | Port centre ~80 from left, centred in thickness | shaft centred | estimated | shaft X centre 80.0; n centre 9.0 vs port n 8.5 (0.5 offset, plug 7 thick has 4.5/5.5 each side; also fits if the device leans on the lip, port n 6.5) | z12, x80 | PASS |
| R6 | Room for angled plug, shaft depth under device | ≥ 20 | assumed | 20.000 (u 0..−20); plug 15 → 5 margin; `interference` (plug + cable + device) empty | x80, interference | PASS (at minimum, plug dims assumed → fit_test) |
| R7 | Cable channel open at the top, from shaft to the rear | ≥ 5 wide, lay in from above | assumed | 6.0 wide (X 97..103), floor z 11.096, open to the top along its full length, joins the shaft; cable Ø4 at z 13.6 → 0.5 clearance to floor | z12, x100 | PASS |
| R8 | Popsocket clearance Ø40 x 7, centre u 39 / x 51 | pocket ≥ Ø46, depth ≥ 9 | estimated | pocket 46.0 wide (X 28..74, centre 51), depth 9.000, bottom at u 16 (popsocket u 19..59 → 3 mm), open to the top so it slides in; rest wall 3.0 | z60, x51 | PASS (depth at minimum, see finding 4) |
| R9 | Front lip | ~10 high | assumed | 10.000 along the device, 4.0 thick | x130 | PASS |
| R10 | Backrest above the CG | contact ≥ 90 above bottom edge | assumed | 95.0 along the device (CG at 72.5); vertical 89.3 | x130 | PASS (along the device); see finding 2 |
| R11 | Tipping ≥ 15° front and back, 330 g | ≥ 15° | assumed | device only: forward 26.89°, backward 19.45°; with stand (STL, 160.5 g): 31.53°/25.43°; sideways ≥ 31.5° | recalculated (`load_case.py`) | PASS |
| R12 | PLA, no supports | overhang ≤ 45°, walls ≥ 0.8 | user | walls ≥ 2.8 mm; one overhang face 70° from vertical, 2.35 x 70 mm (shaft ledge); all other faces ≤ 20° | check.md overhangs, x80 | FAIL (minor, finding 1) |
| R13 | Build volume | ≤ 250³ | printer | stand/print 120 x 80 x 111.92; fit_test 86 x 38.9 x 41.54 | bbox | PASS |
| R14 | Parts in print | 1 volume | – | print Volumes 2 (= 1 body), Simple yes | check.md | PASS |
| R15 | Fit test | shaft, channel, supports | – | fit_test X 37..123: shaft complete, channel 97..103, supports 8 mm each side, lip, slot, backrest stubs to z 41.54, pocket bottom partly (x 37..74); 1 body | check.md, fit_test images, x43 | PASS (limits: finding 8) |

## G3 Comparison: description vs. requirements

- Leaning profile, lip, slot, backrest → R2, R3, R9, R10. Matches.
- Vertical slot through the backrest (X 97..103) → cable channel R7.
  It is open to the top, so it necessarily splits the backrest into two
  tongues. Explained (finding 5, no load problem).
- Recess at top left, open to the top edge → popsocket pocket R8, left
  of centre as required (X 28..74, centre 51, front-view frame). Right
  side.
- Recess under the slot → plug shaft R4/R5/R6, centred on X 80. Channel
  to the right of the plug as the header describes.
- Overhang face at z ≈ 23 → rear shaft ledge, not required by any row.
  It follows from shaft 17 > slot 15. Finding 1.
- Stand narrower than the device → allowed by R1.
- Checklist: features complete (F14: yes); sides correct (F5/F6:
  pocket left, channel right of the port, lip at the front); nothing
  floating, Volumes 2 (F8); bed face = footprint, min Z 0 (F13); assembly
  device/plug/cable in place, interference empty; proportions
  plausible, no knife edge or thin skin.

## G4 Printability

| Check | Value | Limit | Result |
|---|---|---|---|
| Min. wall / residual width | shaft floor 3.0 vertical (2.82 perpendicular), pocket rest 3.0, lip 4.0, shaft front wall 4.5, pocket side rim 7.0; no chamfers (F9 n/a) | ≥ 0.8 | PASS |
| Overhangs | lip inner face, backrest rear face, shaft front wall: 20° from vertical. **Shaft ledge: 70° from vertical, 2.35 mm horizontal, 70 mm long, at the backrest foot** | ≤ 45° (R12) | FAIL (minor, finding 1) |
| Bridges | none (shaft, channel, pocket open to the top) | – | PASS |
| Build volume (parts and `print` plate) | 120 x 80 x 111.92; fit_test 86 x 38.9 x 41.54 | 250³ | PASS |
| Assembly access | plug put into the device first, device lowered through the slot (plug 7 thick < 15, shaft 70 long open to the slot); popsocket slides down in the pocket open to the top; cable laid from above into the channel open to the top (X 97..103 through the backrest); bend room X ≈ 86..100 in the shaft (Y 9.7..27.8 at z 13.6) | free path | PASS |
| Load case (governing failure mode) | **Tipping backward** governs: 19.45° (device only, conservative, CG y 47.15 z 93.00); with stand 25.43°; push at the device top edge to tip ≈ 1.0 N (105 g). Breaking not critical: backrest root with all the load on the 38 mm tongue σ ≈ 0.16 MPa, SF ≈ 150 vs 25 MPa (Z layer adhesion). Sliding not critical (lip holds by shape) | R11 ≥ 15° | PASS |

Load case recalculated independently (`extra/load_case.py`): stand
volume and centroid from the STL (215.68 cm³, CG y 40.79 z 33.30),
device CG from the measured section. The device-only case is
conservative because the stand's own d/h ratio (≈ 1.2 forward, ≈ 1.2
backward) is above the device's. Worst case: device only / backward.
Sideways: the popsocket fixes X to ±3 mm, ≥ 31.5°.
Parametric sweep (rule `verify-parametric-geometry`): n/a, no organic
contour.

Fits: no press or sliding fit. Slot 15 for 13 (2 mm total) is loose,
but the device, port, plug and popsocket sizes are estimated or
assumed. So per `pre-print-gate` "fit test first" → fit_test.

## Findings

Not fixed by QA (rule `printability-report`).

1. **G2/G4, R12, overhang (no F number; closest F13).** Shaft ledge
   at n 15..17.5, u = +1: a downward face 70° from vertical, 2.35 mm
   horizontal, 70 mm long, at z 22.7–23.6 (check.md: z 23–23.5,
   Y 28.80..31.15). It follows from shaft 17 deep > slot 15 plus the
   shaft cutter reaching to u = +1. It sits at the foot of the backrest
   face where the device's lower rear edge rests. Droop could leave a
   bump. Probably printable without supports. Recommendation: chamfer
   the ledge at 45° (design-agent), or the user accepts it in G5. The
   fit_test contains the ledge and shows how it prints.
2. **G2, R10, reading.** 95.0 along the device = 89.3 vertical. If "90 mm
   above the bottom edge" means vertical, the row fails by 0.7 mm. The
   intent (above CG u = 72.5) is met. The user should clarify.
3. **G2, R6/R8 at the minimum (F15 risk).** Shaft depth exactly 20.0,
   pocket depth exactly 9.0, both based on assumed or estimated sizes
   (plug length 15, popsocket height 7). No margin beyond the table.
4. **G3/G4, popsocket fixes the device position (F15 risk).** Clearance
   3 mm per side / 3 mm below. If the estimated position (x 51, u 39) is
   more than 3 mm off, the device sits on the pocket edge instead of on
   the supports. The fit_test only covers the pocket bottom (u 16..~20) and
   the right wall (x 74), not the left wall (x 28). Recommendation:
   measure the popsocket position with calipers before the full part.
5. **G3, split backrest (information).** The channel open to the top
   (R7) cuts the backrest from z 11.1 up into two tongues (76 and 38 mm).
   Strength SF ≈ 150, so no problem. It follows from R7.
6. **G4, echo() mass claim (F12-like: claim ≠ result).** The file
   computes the stand mass from the uncut profile (~208 g). From the STL
   it is 160.5 g (fill 0.6). Stand-inclusive tipping and push force are
   slightly optimistic (26.39° → 25.43° backward, 116.7 → 104.9 g). R11
   uses the device-only case, so it is unaffected.
7. **G4, information.** About 1.0 N (105 g) at the device's top edge
   tips the stand backward. Fine for a charging stand that is not
   operated (R11). A bump knocks it over.
8. **R15, fit_test limits.** Footprint ends at y 38.9, device CG y 47.2:
   the fit_test does not stand with the device in it, so hold it by
   hand. It checks the plug in the shaft, the slot, the supports, the
   channel/cable path and the ledge. Popsocket only partly (finding 4).

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
