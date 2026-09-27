# Setup Guide

How to get the OpenSCAD AI workflow running on a new machine. Written
for Windows (the reference setup); on macOS/Linux the steps are the same,
only the install commands and paths differ.

## 1. Install the tools

| Tool | Why | Notes |
|---|---|---|
| **Git** | Version control for models and context | Any recent version |
| **OpenSCAD** | Renders the `.scad` models, CLI is used for manifold checks and STL export | Reference setup: 2021.01. Download from [openscad.org](https://openscad.org/downloads.html) |
| **Claude Code** (reference) | Runs the design and QA agents | VS Code extension or CLI. On Windows e.g. `winget install Anthropic.ClaudeCode`. Other AI tools work too, see README "Vendor independence and migration" |
| **VS Code** | Editor, hosts Claude Code and the OpenSCAD extensions | Optional if you use the Claude Code CLI only |
| **Slicer** | Turns the exported STL into G-code | Any slicer with a profile for your printer |
| **Python 3** | Runs `tools/check.py` (pre-print check, hook) | Standard library only, no packages needed |

### Make the OpenSCAD CLI reachable

The agents call `openscad` on the command line to verify geometry
(`Simple: yes`, `Volumes: N`) and to render previews. It must be on your
`PATH`:

```powershell
openscad --version
# OpenSCAD version 2021.01
```

If the command is not found, add the install folder (default
`C:\Program Files\OpenSCAD`) to your user `PATH` and restart the
terminal / VS Code.

## 2. Clone and open the repo

```powershell
git clone https://git.int.trappeonline.xyz/trappeflo/ai-scad-collection.git ai-scad
cd ai-scad
code .
```

VS Code will offer the recommended extensions from
`.vscode/extensions.json` — accept them:

- `Leathong.openscad-support-vscode` — syntax highlighting for `.scad`
- `thijsdaniels.vscode-openscad-preview` — 3D preview inside VS Code

## 3. Fill in the context (most important step)

Everything in `context/` is read by the agents before **every** modeling
task (rule `context-first`). The quality of the fits and wall thicknesses
depends directly on these files. The values in this repo are measured for
**one specific setup** (Anycubic Kobra S1, 0.4 mm nozzle, PEI plate, PLA).
If your printer, nozzle, or material differ, replace them — don't reuse
them blindly.

| File | What goes in | How to get it |
|---|---|---|
| `context/printer.md` | Printer specs, build volume, nozzle, bed, calibration observations (overhangs, bridges, stringing) | Printer datasheet + a calibration print (e.g. the test block linked in the file) |
| `context/tolerances.md` | Clearance per side that moves / stays fixed, effective X/Y error, real-part findings | Print a tolerance test (0.05–0.30 mm steps), check by hand; add results from real parts (e.g. "0.25 mm too tight on a long slide") |
| `context/materials.md` | Filament type, brand, color, temperatures, quirks | Currently empty — fill in as you go |
| `context/failure-modes.md` | Errors that render fine but are wrong, and which check stage catches them | Grows with every error that got past a stage |

Keep these files alive: whenever a print teaches you something ("too
tight", "wall too thin", "bridge sagged"), ask the agent to transfer the
finding into the context (see step 6).

## 4. Check that everything works

Export one part of an existing model through the CLI:

```powershell
openscad -o "$env:TEMP\drawer.stl" -D 'part="drawer"' scad/finished/kartenbox_flip7_002.scad
```

Expected at the end of the output:

```
   Simple:        yes
   Volumes:         2
```

`Volumes: 2` means one watertight part (interior + exterior). If this
works, the agents can run their checks too. Then try the check script:

```powershell
python tools/check.py scad/finished/kartenbox_flip7_002.scad --part drawer=2 --cut 5 --out "$env:TEMP\check"
```

It writes `check.md` with the stats, bounding box, section contours and
preview images to the output folder.

## 5. Your first design session

Open the Claude Code panel in VS Code (or run `claude` in the repo
folder) and start with the project command `/neues-objekt`. It loads the
design agent, the rules and the context, and follows the pre-print
gate:

```
/neues-objekt a box for a card game, the stack is 80 x 54 x 36 mm.
Not sure how to close it — make suggestions.
```

(Referencing `@agents/design-agent.md` directly also works, but the
command makes sure no step is skipped.) After a print, report back with
`/druckfeedback <file> <what happened>`.

What happens next:

1. **Questions first.** The agent asks for dimensions, load, mounting,
   and use case before writing any code. Answer them — vague answers
   ("roughly measured") are fine, just say so.
2. **Draft.** It writes `scad/draft/<name>_001.scad`, checks it with the
   OpenSCAD CLI, and reports dimensions and thin spots.
3. **Check before printing.** The agent starts the `qa-agent`, which
   runs gate stages G1–G4 (rule `pre-print-gate`) and writes
   `qa/<file>/report.md` with preview images. Look at the images and the
   findings, then release explicitly: "`<file>` release for printing".
   New fits get a `fit_test` release first.
4. **Render and export.** Open the file in OpenSCAD. Multi-part models
   have a `part` parameter at the top, e.g.:

   | `part` | Output |
   |---|---|
   | `"print"` | all parts in print orientation |
   | `"drawer"`, `"sleeve"`, … | a single part, for per-part STL export |
   | `"assembly"` | assembled view |
   | `"fit_test"` | small test pieces to check a fit before the full print |

   Render with **F6** (not only F5 preview), then export the STL.
5. **Print and give feedback.** "Too tight", "wall bends", "magnets
   don't line up" — the agent creates `_002`, `_003`, … Files are never
   overwritten (rule `versioning`).
   The agent records the result in the QA report (skill
   `print-feedback`).
6. **Approve.** Tell the agent explicitly, e.g. "`<file>` is finished".
   Only then is it moved to `scad/finished/` (rule `no-auto-promote`).

## 6. Feed learnings back

After a print, ask the agent to transfer what you learned into the
context, e.g.:

```
transfer the findings into the context
```

Example from this repo: long sliding fits (drawer in sleeve) turned out
to need **0.4 mm clearance per side** instead of the 0.2–0.25 mm the
tolerance test block suggested — now recorded in
`context/tolerances.md` and used for every new model.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `openscad` not found | OpenSCAD not on `PATH`, see step 1 |
| Model looks broken in the F5 preview | Preview artifact of complex boolean trees. Render with F6 — the exported geometry is what counts. The models wrap their output in `render()` to reduce this. |
| CLI ends with `Current top level object is empty` and exit code 1 for `part="interference"` | Expected: the interference check intersects two parts that must not touch — empty means no collision |
| Printed fit much tighter than designed | Effective X/Y error eats into the clearance. Check `context/tolerances.md`, print the `fit_test` part first |
| Agent moved nothing to `finished/` | Intended — it only does so after your explicit approval |
