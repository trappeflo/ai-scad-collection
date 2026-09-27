# QA report: `<file-stem>`

Rule `pre-print-gate`. Saved as `qa/<file-stem>/report.md`. G1–G4 are
written by the `qa-agent` (returned as text, saved unchanged by the
design-agent), G5 by the user (or by the agent quoting the user's
words), "Print result" after printing (skill `print-feedback`).

- File: `scad/draft/<file-stem>.scad`
- Previous version / report: `<…>` or none
- Context read: printer.md, tolerances.md, materials.md, failure-modes.md
- Check date: YYYY-MM-DD

## Summary

| Stage | Result | Short note |
|---|---|---|
| G1 Technical | PASS / WARN / FAIL | |
| G2 Dimensions | PASS / FAIL | x of y rows measured |
| G3 Visual (blind) | PASS / FAIL | |
| G4 Printability | PASS / FAIL | |
| **Recommendation** | print / fit_test only / revise | |
| G5 Release (user) | open / released on YYYY-MM-DD / rejected | |

## G1 Technical

Commands (run 1 generic, run 2 `--add` with targeted cuts):

```
python tools/check.py scad/draft/<file>.scad --part … --show … --empty …
python tools/check.py scad/draft/<file>.scad --add --part … --cut …
```

Result from `check/check.md` (local working data, not versioned: copy
the part table and every value used below into this report, so it
stands on its own). Explain every WARN here.

## G3 Blind description

_Written from the images only, BEFORE reading the requirements._

…

## G2 Dimensions: requirements table, target vs. actual

| ID | Requirement | Target | Source | Actual | How measured | Result |
|---|---|---|---|---|---|---|
| R1 | | | measured / nominal / assumed | | section z=… / bbox / recalculated | PASS / FAIL / n.c. |

## G3 Comparison: description vs. requirements

- Differences and their explanation:
- Checklist (`skills/visual-review.md`): features complete / sides /
  floating parts / bed face / assembly / proportions

## G4 Printability

| Check | Value | Limit | Result |
|---|---|---|---|
| Min. wall / residual width | | ≥ 2x nozzle | |
| Overhangs | | ≤ 45° or intended | |
| Build volume (parts and `print` plate) | | printer.md | |
| Assembly access (pins, magnets, inserts) | | free path | |
| Load case (governing failure mode) | | | |

## Findings

Numbered. For each: stage, failure mode from `context/failure-modes.md`
if one fits, description, recommendation. Not fixed by QA (rule
`printability-report`).

1. …

## G5 Release

- Released by the user: _yes/no_, date, exact wording
- Scope: all parts / `fit_test` only

## Export

- Parts, date

## Print result

_After printing, skill `print-feedback`._

| ID | Observation in the print | Matches prediction? |
|---|---|---|
| | | yes / no → escaped defect at stage G? |

- Escaped defects → added to `context/failure-modes.md` as: …
- Fit findings → `context/tolerances.md`: …
