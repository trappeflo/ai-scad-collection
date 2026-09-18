# Skill: promote-finished

## Purpose

Moves an approved version from `scad/draft/` to `scad/finished/`.

## Usage

- **Only on explicit user approval** for this specific file (rule
  `no-auto-promote`). An approval for one version does not carry over
  to later versions.
- Afterwards, archive the superseded versions of the same object via
  skill `archive` (to `scad/trash/` with a note in `NOTES.md`).
- Update the model table in `README.md`.
- If the version is based on a real-print finding, check whether the
  finding still needs to go into `context/`.
