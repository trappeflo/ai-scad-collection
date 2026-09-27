# Skill: print-feedback

## Purpose

Closes the loop after a print: records the real result against the
gate's prediction, so errors that got through can be traced to the
stage that should have caught them.

## Usage

When the user reports on a print ("too tight", "works", "wall bends"):

1. **Fill in "Print result" in `qa/<stem>/report.md`**: date, material,
   slicer settings if relevant, the user's observation per requirement
   row (worked / didn't / not tested), measured values if any.
2. **Compare with the gate.** For every problem in the print: did a
   stage flag it?
   - flagged, but released anyway → note the reason (accepted risk).
   - not flagged → **escaped defect**. Name the stage that should have
     caught it (G1–G4) and why it didn't.
3. **Escaped defects go into `context/failure-modes.md`** as a new row
   or as an extra example in an existing one, with the model name.
   Where a stage can be sharpened (new `--cut` height, new checklist
   item, new `assert`), change the skill or rule too.
4. **Fit results go into `context/tolerances.md`** (as before).
5. The next version (`_00X+1`) starts from the updated context.

## Why

The report archive in `qa/` makes the check strategy measurable: how
many defects each stage caught before the print, and how many only
showed up in the print. That is the evidence that the gate works, or
the pointer to where it does not.
