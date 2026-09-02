# Printer: Anycubic Kobra S1

## Technical specifications
- Build volume: 250 x 250 x 250 mm
- Architecture: CoreXY
- Nozzle: 0.4 mm standard (0.25/0.6/0.8 mm available separately)
- Layer height range: 0.05–0.28 mm
- Filament diameter: 1.75 mm
- Hotend max temperature: 320 °C
- Heated bed max temperature: 120 °C
- Print speed: up to 600 mm/s (recommended ~300 mm/s), max acceleration 20,000 mm/s²
- Auto-leveling: LeviQ 3.0 with vibration compensation
- Extra: tool-free quick-change hotend, power-loss recovery, spaghetti detection

## Setup (this workshop)
- Print bed: PEI plate
- Nozzle: 0.4 mm

## Calibration test print
Reference model: "Ultimate 3D printer calibration and test block" (MakerWorld, NicoM1989)
https://makerworld.com/en/models/1451728-ultimate-3d-printer-calibration-and-test-block

Areas covered per model description: overhang (30–90°), stringing, tolerance
(0.05–0.30 mm), bridges (50/75/90 mm), ball-on-bar, Z lettering/engraving,
steps/ramps.

## Results & observations (visual evaluation)

### Overhang ramp
- Ramp prints cleanly up to steep angles.
- At the shallow end (lowest angle), some ripples/ridging ("gear-like"
  texture) are visible.
- Takeaway: cooling isn't fully dialed in for the steep-overhang range yet.
  → Check the fan curve for low layer-time/overhang sections in the slicer.

### Stringing (free-standing pins)
- Fine strings visible between the pins.
- Takeaway: fine-tune retraction distance/speed, or try lowering print
  temperature slightly (~5 °C).

### Bridges (50/75/90 mm)
- Visible sag (catenary curve) in the bridge line.
- Takeaway: increase bridge fan speed and/or slightly reduce bridge flow.

### Ball-on-bar
- Ball shape/roundness on the thin post not consistently clean across prints.
- Takeaway: possibly insufficient cooling or too-high temperature for very
  small overhanging details.

### Z engraving / lettering ("X"/"Y"/"Z" cubes)
- Sharp, well-defined, easily readable letters, no ghosting/ringing visible.
- Takeaway: acceleration/jerk settings and first-layer adhesion on PEI are
  generally well tuned.

## Open items / next steps
- Fine-tune the fan curve and bridge settings specifically for
  overhang/bridging.
- Re-check the ball-on-bar result more closely (macro photo) — currently
  only suspected from photo evaluation, not confirmed.
