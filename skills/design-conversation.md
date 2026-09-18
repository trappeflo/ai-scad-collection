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

## Usage

Used by the `design-agent` before the `modeling` skill is invoked. No 
code is proposed without first clarifying the core requirements.
