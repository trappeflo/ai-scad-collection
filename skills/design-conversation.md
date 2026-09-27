# Skill: design-conversation

## Purpose

Asks targeted follow-up questions before any code is generated. 
Gathers the requirements needed for meaningful modeling:

- Dimensions (length, width, height, tolerances)
- Load (static/dynamic, approximate force/weight)
- Mounting type (screws, clips, press fit, glue, ...)
- Use case (operating environment, material requirements)

## Checks on the answers

- **Plausibility**: numbers that can't be physically right get asked
  back, not guessed or silently corrected (example: "iPad 15 cm thick"
  -> presumably 15 mm with case, but ask).
- **Load-bearing parts**: ask for the mass and size of the load, or, if
  the user doesn't know, make them parameters with a typical value and
  say so openly. Rule `load-case-check` needs these values.
- **Space constraints**: ask which direction is limited (e.g. "not
  much room on the desk widthwise"). That decides the part's
  orientation and which dimension can grow for stability.
- **Source of every dimension**: measured with calipers, nominal
  (datasheet, standard size) or assumed. Stamped, enamel or cast parts
  deviate from nominal by tenths (see `context/tolerances.md`, pin
  badge). Assumed values are asked to be measured before the release.

## Result: requirements table

The conversation ends with a table that the user confirms. It is the
reference for gate stages G2 and G3 (rule `pre-print-gate`), so every
row must be checkable on the finished model:

```
| ID | Requirement            | Target       | Source   | Check method                  |
|----|------------------------|--------------|----------|-------------------------------|
| R1 | Inner size drawer X    | 87.0 +0.8    | nominal  | section z=10, inner contour   |
| R2 | Magnet pocket Ø        | 6.0 +0.2     | measured | section z=1.0                 |
| R3 | Tipping angle worst c. | ≥ 12°        | assumed  | recalculated (load-case-check)|
| R4 | Parts in "print"       | 2            | –        | check.py Volumes              |
| R5 | Thumb recess front     | present      | –        | visual (G3), section z=…      |
```

- Target with direction of the tolerance (`+0.8` = may be larger,
  never smaller).
- Qualitative requirements ("must not open by itself", "crystal look")
  also get a row. Their check method names what shows it (magnet force
  in `echo()`, visual review), or says "only in the print".
- The table goes into the file header (skill `modeling`) and is
  carried over and updated in every later version.

## Usage

Used by the `design-agent` before the `modeling` skill is invoked. No 
code is proposed without first clarifying the core requirements and
without a confirmed requirements table.
