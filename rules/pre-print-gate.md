# Rule: pre-print-gate

No model goes to the printer (no STL export for printing) until it has
passed five documented check stages, in this order. Each stage has a
pass criterion and targets its own class of errors. A model can compile
cleanly and still be nonsense (wrong axis, missing feature, hole on the
wrong side, tolerance applied twice). Stages G2 and G3 exist for that.

| Stage | Who | Checks | Pass criterion | Catches |
|---|---|---|---|---|
| **G1 Technical** | `tools/check.py` (script, deterministic) | compiles, no `ERROR`/failed `assert`, `Simple: yes`, `Volumes` as expected per part, `interference` empty | `check.md` says PASS; every WARN is explained in the report | broken geometry, disconnected pieces, collisions |
| **G2 Dimensions** | `qa-agent` | every row of the requirements table (skill `design-conversation`) measured: bounding box, cross-sections, recalculated `echo()` values | every row PASS or explicitly "not checkable" with reason | wrong dimensions, wrong units, wrong axis, tolerance on the wrong side |
| **G3 Blind visual review** | `qa-agent` | describe the preview images **before** reading the requirements, then compare (skill `visual-review`) | every difference between description and requirements explained | geometry that renders fine but is nonsense: missing/extra/mirrored features, wrong orientation |
| **G4 Printability** | `qa-agent` | wall thickness incl. residual widths, overhangs, bridges, print orientation, build volume, load cases (skill `geometry-check`) | no open violation | unprintable or weak parts |
| **G5 Release** | **user** | looks at the preview images and the QA report, decides | explicit release for this file version ("`<file>` release for printing") | everything the AI does not notice |

## How

- The `qa-agent` runs G1–G4 in a fresh context (subagent, or a new
  session in tools without subagents) and returns the
  report (template: `qa/TEMPLATE.md`); the design-agent saves it
  unchanged to `qa/<file-stem>/report.md`. The script output lands in
  `qa/<file-stem>/check/`.
- G1 runs twice: run 1 generic (all parts, images) before the blind
  description, run 2 with `--add` and targeted cuts after the
  requirements have been read (see `agents/qa-agent.md`).
- G5 is the user's. The agent presents the report summary and the
  images and asks for release. It never assumes release, and a release
  for one version does not carry over to the next (like
  `no-auto-promote`).
- Only after G5: skill `export-stl`.
- **Fit test first.** If the model contains a fit whose clearance is
  not yet confirmed in `context/tolerances.md` (new fit type, new
  material), the gate result is "release `fit_test` only". The full
  part follows after the fit test has been printed and assessed.
  If there is no test part for such a fit (e.g. magnet pocket, insert),
  the report names it as an untested fit. The user then decides in G5:
  add a test part, or print the full part and accept the risk. The
  report records which.
- **After printing**, the result goes into the same report (section
  "Print result", skill `print-feedback`). This records which errors the
  gate caught and which only showed up in the print, so the check
  strategy itself can be evaluated.

## Shortcut for trivial changes

A new version that changes only a parameter value (no new geometry,
e.g. clearance 0.4 → 0.35) may reuse G3 from the previous report if the
images show no visible change. G1, G2 and G5 are always rerun. The
report says so explicitly ("G3 reused from `_004`, reason: …").
