# OpenSCAD AI Workflow

AI-assisted OpenSCAD workflow for 3D printing. The goal is to save time
compared to classic CAD by using AI-assisted modeling: you describe what
you need, an agent asks the right questions, writes parametric OpenSCAD
code, and verifies it before you print.

**New here? → [SETUP.md](SETUP.md)** (tools, context, first session)

## Concept

Two agents split the work to avoid bias:

- **design-agent** — leads the design conversation, gathers
  requirements (dimensions, load, mounting type, use case), and
  generates/iterates OpenSCAD code. Dialogue-driven, not autonomous.
- **qa-agent** — validates only, no creative modeling. Checks
  geometry, printability, and dimensions against the requirements and
  the `context/` specs. Kept separate from the design-agent so it
  doesn't judge its own creations too favorably. Runs in a fresh
  context (a subagent, or a new session).

The agents, skills, rules and prompts are plain Markdown instruction
files, and the checks are a plain Python script. Nothing in the
workflow depends on one AI vendor (see
[Vendor independence](#vendor-independence-and-migration)). The
reference setup is [Claude Code](https://claude.com/claude-code):

```
/neues-objekt a box for a card game, 80 x 54 x 36 mm
```

## Project Structure

```
AGENTS.md    Project instructions, vendor-neutral (read by any AI tool)
prompts/     Entry prompts: new object, print feedback (vendor-neutral)
agents/      Role definitions for design-agent and qa-agent
skills/      Individual capabilities used by the agents
rules/       Constraints that apply across the workflow
context/     Printer, tolerance, material specs and failure-mode catalog (read before every task)
tools/       check.py: deterministic pre-print check (gate stage G1), previews, sections
qa/          One folder per checked version: report.md + check/ (images, sections, log)
scad/
  draft/     Work-in-progress, versioned iterations
  finished/  Approved models (manual promotion only)
  trash/     Discarded iterations, with a note on why (created on first use)
  templates/ Reusable, proven designs — only the key inputs need to be set
.claude/     Claude Code adapter: qa-agent subagent, /commands, quick-check hook
.vscode/     Recommended VS Code extensions for OpenSCAD
CLAUDE.md    Claude Code adapter: imports AGENTS.md
SETUP.md     Setup guide
```

## Workflow

1. **Gather requirements** — `design-conversation` skill asks about
   dimensions, load, mounting type, and use case before any code is
   written. Result: a requirements table (target, source, check
   method per row) that the user confirms.
2. **Model** — `modeling` skill reads `context/` and generates a new
   versioned file in `scad/draft/` (`object-name_001.scad`) with the
   requirements table in the header and `assert()`s for everything
   computable.
3. **Pre-print gate** (rule `pre-print-gate`) — five documented stages
   before anything is printed:

   | Stage | Who | Catches |
   |---|---|---|
   | G1 Technical | `tools/check.py` | broken geometry, disconnected pieces, collisions, failed `assert` |
   | G2 Dimensions | qa-agent | wrong size, unit, axis, tolerance side — every requirement row measured |
   | G3 Blind visual review | qa-agent | models that render fine but are nonsense (missing/mirrored features, wrong orientation) |
   | G4 Printability | qa-agent | thin walls, overhangs, build volume, load cases |
   | G5 Release | **user** | everything the AI does not notice |

   The qa-agent writes `qa/<file>/report.md`. New, unconfirmed fits
   get a `fit_test` release first.
4. **Export** — `export-stl` skill, only after G5.
5. **Print and iterate** — `print-feedback` records the real result in
   the report and compares it with the gate's prediction. Errors that
   got through go into `context/failure-modes.md`, fit results into
   `context/tolerances.md`. The next version (`_002`, …) goes through
   the gate again.
6. **Promote or archive** — `promote-finished` moves an approved file
   to `scad/finished/`, but only after explicit user approval.
   `archive` moves discarded iterations to `scad/trash/` with a short
   note.

## Vendor independence and migration

The workflow is built in two layers. The **core** holds all the
knowledge and process and works with any AI coding tool. The
**adapter** only adds conveniences for one tool and can be thrown away.

| Layer | Files | Vendor-specific? |
|---|---|---|
| Core | `AGENTS.md`, `agents/`, `rules/`, `skills/`, `context/`, `prompts/`, `qa/`, `scad/` | no, plain Markdown and OpenSCAD |
| Core | `tools/check.py` | no, Python standard library + OpenSCAD CLI |
| Adapter (Claude Code) | `CLAUDE.md` (one line: `@AGENTS.md` + notes) | yes |
| Adapter (Claude Code) | `.claude/agents/qa-agent.md` (QA subagent without write tools) | yes |
| Adapter (Claude Code) | `.claude/skills/` (`/neues-objekt`, `/druckfeedback`, each only points to `prompts/`) | yes |
| Adapter (Claude Code) | `.claude/settings.json` (hook: quick check after every `.scad` write) | yes |

### What the target tool must be able to do

- read and write files in the repo
- run shell commands (`python`, `openscad`)
- **read images**: stage G3 (blind visual review) needs it. Without
  image input the user does G3 by looking at `qa/<file>/check/*.png`
- nice to have: subagents with their own context, custom commands, hooks

### Migration in four steps (about 15–30 minutes)

1. **Instructions.** Many tools read `AGENTS.md` directly (e.g. OpenAI
   Codex, Cursor, GitHub Copilot, Zed). Others need a pointer or a
   setting (e.g. Gemini CLI: `GEMINI.md` or `contextFileName`; Aider:
   `--read AGENTS.md`). Check the target tool's docs. If it uses its own
   file name, create that file with a pointer ("Follow `AGENTS.md`") or
   a copy.
2. **Entry prompts.** If the tool supports custom commands, create two
   commands that each say "Follow `prompts/neues-objekt.md` /
   `prompts/druckfeedback.md`, arguments: …". If not, start a session
   with the content of the prompt file and replace `<ARGUMENTE>`.
3. **Separate QA context.** If the tool has subagents, define one from
   `agents/qa-agent.md`, ideally without write/edit tools. If not: when
   the design agent reports a draft ready for QA, open a **new**
   session and start it with `agents/qa-agent.md`, the `.scad` path and
   the requirements table. Save the returned report to
   `qa/<file>/report.md`. The separation is what matters, not the
   mechanism.
4. **Quick check.** If the tool has hooks, run `python tools/check.py
   --hook` after file writes (it reads the tool's JSON from stdin and
   needs `tool_input.file_path`; adjust if the format differs). If not,
   the agent runs `python tools/check.py <file> --quick` after every
   change (already stated in `AGENTS.md`).

The `.claude/` folder and `CLAUDE.md` can stay in the repo; other tools
ignore them.

### What gets weaker without the adapter

- The QA's "no write access" becomes an instruction instead of being
  enforced by the tool.
- The quick check depends on the agent following `AGENTS.md` instead
  of running automatically.
- Both are covered by the gate itself: G1 runs through `tools/check.py`
  anyway, and the user's release (G5) stays the last step before any
  print.

## Model Conventions

- Units are millimeters, noted in the file header.
- The file header documents the context used, the requirements from
  the design conversation, print orientation, and — from `_002` on —
  what changed compared to the previous version and why.
- All dimensions are parameters at the top of the file; derived values
  are computed, not hard-coded.
- Multi-part models have a `part` parameter to choose the output:
  `"print"` (all parts in print orientation), single parts for per-part
  STL export, `"assembly"`, and where useful `"fit_test"` (small test
  pieces to check a fit before the full print) or `"interference"`
  (collision check, must be empty).
- Geometry is verified via the OpenSCAD CLI (`Simple: yes`, expected
  `Volumes` count), not by eyeballing the preview. `tools/check.py`
  does this and parses the log, because OpenSCAD 2021.01 exits with 0
  even when an `assert()` fails.

## Key Rules

- **pre-print-gate** — no print without the five documented check
  stages G1–G5; G5 is the user's release.
- **context-first** — all of `context/` (printer, tolerances,
  materials, failure modes) must be read before every modeling task.
- **versioning** — iterations are always versioned
  (`object-name_001.scad`, `002`, ...), never overwritten.
- **units-mm** — units are consistently millimeters, noted in the
  generated code.
- **no-auto-promote** — moving files to `scad/finished/` is always a
  manual, explicit user decision.
- **printability-report** — printability violations are reported to
  the user, never silently auto-fixed.
- **load-case-check** — parts that carry something get their governing
  failure mode (breaking, tipping, sliding) calculated for the worst-case
  load combination, with the calculation as `echo()` in the file.
- **verify-parametric-geometry** — parametric/organic contours with a
  mechanical constraint are verified via a full parameter sweep and
  CLI manifold stats, not spot-checked or eyeballed in the preview.

## Key Findings So Far

Reference setup: Anycubic Kobra S1, 0.4 mm nozzle, PEI plate, PLA.
Details in [context/tolerances.md](context/tolerances.md).

- **Short fits** (test block): 0.2–0.25 mm per side moves, 0.05–0.15 mm
  stays fixed.
- **Long sliding fits** (drawer in sleeve, ~90 mm contact length):
  0.25 mm per side was too tight, **0.4 mm slides easily** (current
  default), 0.5 mm is on the loose side. Next to try: ~0.35 mm.
- **Flat insert in a shallow rim** (pin badge, 40 x 25 mm): 0.3 mm per
  side too tight, 0.5 mm too loose. Next to try: ~0.4 mm, measure the
  insert first.
- For new fits, a quick `fit_test` print (thin rings with several
  clearances) saves a failed full print.

## Templates

| Template | Inputs | Notes |
|---|---|---|
| `scad/templates/kartenbox_template_001.scad` | Length, width, depth of the card stack | Card box (drawer + sleeve, 2x 6x2 mm magnets, 0.4 mm slide clearance). Everything else is derived; magnet spacing, push hole, and grips scale with the size. Valid for stacks ≥ ~30 mm wide and ≥ ~10.5 mm deep, box length ≤ 250 mm (checked by `assert`). Works in the OpenSCAD Customizer. |

To use a template: copy it to `scad/draft/<name>_001.scad` and set the
inputs, or set them directly in the OpenSCAD Customizer
(Window → Customizer).

## Models

| Model | Status | Notes |
|---|---|---|
| `lampenschirm_010`, `_013` | finished | Organic wavy lamp shade with integrated clamp collar |
| `kartenbox_flip7_002` | finished | Card box (Flip 7), drawer + sleeve, magnetic catch (6x2 mm), 0.5 mm slide clearance |
| `kartenbox_uno_002` | finished | Card box (UNO Minecraft), same design, 0.4 mm slide clearance — printed, works |
| `laptop_tablet_staender_003` | finished | Vertical laptop/tablet stand, two slots in one part, flared foot against tipping |
| `pin_magnetsockel_002` | finished | Magnet base that turns a rectangular pin badge (40 x 25 mm) into a fridge magnet, pin stays unmodified |

## Status

The workflow is in use. `context/printer.md` and `context/tolerances.md`
are filled in for the reference setup and are updated with every print;
`context/materials.md` is still empty.
