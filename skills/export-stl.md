# Skill: export-stl

## Purpose

Exports a `.scad` file to `.stl` for printing.

## Usage

- Only after rule `pre-print-gate` is complete: G1–G4 passed in
  `qa/<stem>/report.md` **and** the user's release (G5) for exactly this
  file version is recorded there.
- If the gate result was "release `fit_test` only", export only that
  part.
- One STL per part: `openscad -o <stem>_<part>.stl -D 'part="<part>"'
  scad/draft/<stem>.scad`. Check the log again for `Simple: yes`.
- Note the exported parts and the date in the report ("Export").
