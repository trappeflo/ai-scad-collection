# Skill: design-conversation

## Purpose

Asks targeted follow-up questions before any code is generated. 
Gathers the requirements needed for meaningful modeling:

- Dimensions (length, width, height, tolerances)
- Load (static/dynamic, approximate force/weight)
- Mounting type (screws, clips, press fit, glue, ...)
- Use case (operating environment, material requirements)

## Usage

Used by the `design-agent` before the `modeling` skill is invoked. No 
code is proposed without first clarifying the core requirements.
