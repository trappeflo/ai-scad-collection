# Materials

## Filament in use
- PLA (black and blue spools, see `tolerances.md` open items)
- Brand, temperatures, quirks: _not documented yet_

## Assumptions for calculations (NOT measured)

Used for load-case checks (rule `load-case-check`) and mass estimates.
These are conservative textbook values, not measurements on this setup.
Replace them with measured values once available.

| Value | Assumption | Note |
|---|---|---|
| Density PLA | 1.24 g/cm³ | solid material |
| Effective fill for mass estimates | ~0.6 at 30 % infill | thin walls (≤ ~4 mm) print nearly solid, thick bases don't. Rough value only |
| Tensile strength within a layer (XY) | ~50 MPa | bulk PLA, typical datasheet value |
| Layer adhesion (across layers, Z) | **25 MPa** | deliberately conservative, about half of XY. Governs bending of anything printed standing up (ribs, walls, arms) |
| Young's modulus E | 3500 MPa | for deflection estimates |

Not validated by a print yet. First candidate:
`laptop_tablet_staender_003` (ribs calculated at a safety factor of ~32).
If a rib flexes noticeably or cracks at the root, the 25 MPa is too
optimistic.
