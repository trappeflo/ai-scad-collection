# Skill: visual-review

## Purpose

Gate stage G3 (rule `pre-print-gate`): catch models that compile and
measure correctly in the places someone thought to measure, but are
still wrong: a missing feature, a mirrored part, a recess on the wrong
side, a part standing on its head. Those errors pass every numeric check
because nobody thought to measure the thing that is wrong.

## Why "blind"

Whoever knows what the part should look like sees what they expect. So
the description comes **before** the comparison:

1. **Describe without the requirements.** Look only at the images from
   run 1 of `tools/check.py` (`qa/<stem>/check/*_iso|front|side|top.png`,
   any `*_cut_*.png`). Targeted cuts come later, in run 2. Write down
   what is there: basic shape, openings and on which side, number and
   position of holes/pockets/ribs, symmetries, which face lies on the
   bed. Use the axes in the
   image for directions (X red, Y green, Z blue). Write this into the
   report *before* reading the requirements table or the file header.
2. **Then compare** the description with the requirements table, row by
   row. Also look for things in the description that no requirement
   explains (extra body, unexpected step, a hole where none should be).
3. **Go through the checklist:**
   - Is every required feature visible? (F14 in `context/failure-modes.md`)
   - Are features on the intended side / at the intended end? (F5, F6)
   - Anything floating, a thin skin over an opening, a sliver? (F6, F8)
   - `print` part: which face is on the bed, does anything need
     support? (F13)
   - Assemblies: do the parts sit where they belong, does the lid close
     over the right edge?
   - Proportions: does anything look far out of scale (a 2x bump, a wall
     that is visibly thinner than the others)?
4. **Every difference** between description and requirements is either
   explained (e.g. "pocket not visible from outside because it is
   inside the wall, confirmed in section z=1") or reported as a finding.

## Rules

- The images come from the exported STL, not the F5 preview. What is
  reviewed is exactly what would be printed.
- Anything the images cannot decide goes into a section (`tools/check.py
  --add --cut ...`) instead of being guessed.
- The visual review does not replace measurement (G2). It covers the
  class of errors that G2 cannot find because no one measured there.
