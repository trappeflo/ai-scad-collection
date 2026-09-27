#!/usr/bin/env python3
"""Deterministic pre-print check (gate G1 + material for G2/G3/G4).

Runs the OpenSCAD CLI on a .scad file and writes a Markdown summary plus
preview images and cross-sections to an output folder. See rule
`pre-print-gate` and skill `geometry-check`.

Examples:
  # quick: evaluate only (syntax, assert, warnings), ~1 s, used by the hook
  python tools/check.py scad/draft/foo_001.scad --quick

  # run 1 (before the blind review): all parts, images, no targeted cuts
  python tools/check.py scad/draft/foo_001.scad \\
      --part base=2 --part lid=2 --part print --show assembly \\
      --empty interference

  # run 2 (after reading the requirements): add targeted sections
  # without rerunning everything else
  python tools/check.py scad/draft/foo_001.scad --add \\
      --part base=2 --part lid=2 --cut 10 --cut lid:19.5 --cut base:x=24

Cut syntax: [part:][x=|y=|z=]value. Without part it applies to every
part, without axis it is a Z cut. X cuts are drawn as (Y, Z), Y cuts as
(X, Z).

Why the output is parsed instead of trusting the exit code: OpenSCAD
2021.01 exits with 0 even when an assert() fails.
"""

import argparse
import concurrent.futures as cf
import datetime as dt
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# name -> (camera rotation rx,ry,rz, orthographic?)
VIEWS = {
    "iso":   ((55, 0, 25), False),
    "front": ((90, 0, 0), True),    # looking along +Y
    "side":  ((90, 0, 90), True),   # looking along -X
    "top":   ((0, 0, 0), True),     # looking down -Z
}

ENGINE_NOISE = ("WARNING: Viewall and autocenter",)

# an "empty" part (interference) below this volume is treated as faces
# touching, not as a collision
CONTACT_MM3 = 0.1

# build volume of the reference printer (context/printer.md)
DEFAULT_BED = "250,250,250"

# facets steeper than this from vertical count as overhang
OVERHANG_DEG = 45

# section transforms: bring the cut plane to z=0, 2D axes as named
CUT_XFORM = {
    "z": ("translate([0, 0, {m}])", "X", "Y"),
    "x": ("translate([0, 0, {m}]) rotate([-90, 0, 0]) rotate([0, 0, -90])",
          "Y", "Z"),
    "y": ("translate([0, 0, {v}]) rotate([-90, 0, 0])", "X", "Z"),
}


def openscad_bin():
    exe = shutil.which("openscad")
    if exe:
        return exe
    for cand in (r"C:\Program Files\OpenSCAD\openscad.com",
                 r"C:\Program Files\OpenSCAD\openscad.exe"):
        if os.path.exists(cand):
            return cand
    sys.exit("openscad not found on PATH (see SETUP.md, step 1)")


def run(args, timeout=1800):
    p = subprocess.run([openscad_bin()] + args, capture_output=True,
                       text=True, encoding="utf-8", errors="replace",
                       timeout=timeout)
    return p.returncode, (p.stdout or "") + (p.stderr or "")


def scad_path(p):
    """Path as OpenSCAD wants it inside a .scad file (forward slashes)."""
    return str(Path(p).resolve()).replace("\\", "/")


def parse_log(log):
    lines = log.splitlines()
    errors = [l for l in lines if l.startswith("ERROR")]
    warnings = [l for l in lines if l.startswith("WARNING")
                and not l.startswith(ENGINE_NOISE)]
    echoes = [l[len("ECHO: "):] for l in lines if l.startswith("ECHO:")]
    m_simple = re.search(r"Simple:\s+(\w+)", log)
    m_vol = re.search(r"Volumes:\s+(\d+)", log)
    m_time = re.search(r"Total rendering time: (\S+)", log)
    return {
        "errors": errors,
        "warnings": warnings,
        "echoes": echoes,
        "simple": m_simple.group(1) if m_simple else None,
        "volumes": int(m_vol.group(1)) if m_vol else None,
        "empty": "top level object is empty" in log,
        "time": m_time.group(1) if m_time else None,
    }


def read_stl(path):
    tris, tri = [], []
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            s = line.strip()
            if s.startswith("vertex"):
                tri.append(tuple(float(x) for x in s.split()[1:4]))
                if len(tri) == 3:
                    tris.append(tri)
                    tri = []
    return tris


def stl_stats(tris):
    """Bounding box and enclosed volume (divergence theorem)."""
    if not tris:
        return None
    lo = [min(v[i] for t in tris for v in t) for i in range(3)]
    hi = [max(v[i] for t in tris for v in t) for i in range(3)]
    vol = 0.0
    for (ax, ay, az), (bx, by, bz), (cx, cy, cz) in tris:
        vol += (ax * (by * cz - bz * cy) - ay * (bx * cz - bz * cx)
                + az * (bx * cy - by * cx)) / 6
    return {"min": lo, "max": hi, "size": [hi[i] - lo[i] for i in range(3)],
            "volume": abs(vol)}


def overhangs(tris, z_bed):
    """Downward facets steeper than OVERHANG_DEG from vertical, bed excluded.
    Grouped by height (0.5 mm bins) so bore ceilings, ledges etc. show up
    as separate rows."""
    limit = -math.sin(math.radians(OVERHANG_DEG))
    bins = {}
    total = 0.0
    for a, b, c in tris:
        u = [b[i] - a[i] for i in range(3)]
        w = [c[i] - a[i] for i in range(3)]
        n = (u[1] * w[2] - u[2] * w[1], u[2] * w[0] - u[0] * w[2],
             u[0] * w[1] - u[1] * w[0])
        ln = math.sqrt(n[0] ** 2 + n[1] ** 2 + n[2] ** 2)
        if ln == 0 or n[2] / ln >= limit:
            continue
        if max(a[2], b[2], c[2]) < z_bed + 0.01:
            continue  # lies on the bed
        area = ln / 2
        total += area
        zc = round((a[2] + b[2] + c[2]) / 3 * 2) / 2
        e = bins.setdefault(zc, {"z": zc, "area": 0.0,
                                 "x": [math.inf, -math.inf],
                                 "y": [math.inf, -math.inf]})
        e["area"] += area
        for v in (a, b, c):
            e["x"] = [min(e["x"][0], v[0]), max(e["x"][1], v[0])]
            e["y"] = [min(e["y"][0], v[1]), max(e["y"][1], v[1])]
    rows = sorted(bins.values(), key=lambda e: -e["area"])
    return {"total": total, "rows": [r for r in rows if r["area"] >= 0.5][:8]}


def svg_loops(path):
    """Closed contours of an OpenSCAD SVG export, in 2D cut coordinates."""
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    loops = []
    for d in re.findall(r'd="([^"]*)"', text):
        for seg in re.split(r"[Mm]", d):
            pts = re.findall(r"(-?[\d.eE+-]+),(-?[\d.eE+-]+)", seg)
            if len(pts) >= 3:
                # SVG y axis points down; OpenSCAD negates y on export
                loops.append([(float(x), -float(y)) for x, y in pts])
    return loops


def inside(pt, poly):
    x, y = pt
    res = False
    for (x1, y1), (x2, y2) in zip(poly, poly[1:] + poly[:1]):
        if (y1 > y) != (y2 > y) and x < x1 + (y - y1) * (x2 - x1) / (y2 - y1):
            res = not res
    return res


def loop_infos(loops):
    infos = []
    for i, pts in enumerate(loops):
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        area = 0.0
        for (x1, y1), (x2, y2) in zip(pts, pts[1:] + pts[:1]):
            area += x1 * y2 - x2 * y1
        depth = sum(1 for j, other in enumerate(loops)
                    if j != i and inside(pts[0], other))
        infos.append({
            "x": (min(xs), max(xs)), "y": (min(ys), max(ys)),
            "w": max(xs) - min(xs), "d": max(ys) - min(ys),
            "area": abs(area) / 2,
            "kind": "hole" if depth % 2 else "material",
        })
    return sorted(infos, key=lambda i: -i["area"])


def fmt(v):
    return f"{v:.2f}"


def render_png(model_scad, png, view, size="1000,750"):
    (rx, ry, rz), ortho = VIEWS[view]
    args = ["-o", str(png), f"--imgsize={size}", "--viewall", "--autocenter",
            "--colorscheme=Tomorrow", "--view=axes,scales",
            f"--camera=0,0,0,{rx},{ry},{rz},0"]
    if ortho:
        args.append("--projection=o")
    run(args + [str(model_scad)], timeout=600)
    return png.exists()


def parse_cut(spec):
    part, _, rest = spec.rpartition(":")
    axis, _, val = rest.rpartition("=")
    axis = (axis or "z").lower()
    if axis not in CUT_XFORM:
        raise argparse.ArgumentTypeError(f"bad cut axis in {spec!r}")
    return {"part": part or None, "axis": axis, "value": float(val)}


def cut_label(c):
    return f"{c['axis']}{c['value']:g}"


def check_part(src, part, expect, a, out, tmp):
    tag = part or "default"
    show = expect == "show"
    res = {"part": tag, "expect": None if show else expect, "show": show,
           "status": "PASS", "notes": []}
    d_args = []
    for kv in a.defines:
        d_args += ["-D", kv]
    if part:
        d_args += ["-D", f'part="{part}"']

    stl = out / f"{tag}.stl"
    code, log = run(["-o", str(stl)] + d_args + [str(src)])
    info = parse_log(log)
    res.update({k: info[k] for k in ("simple", "volumes", "empty", "time",
                                     "errors", "warnings", "echoes")})
    (out / f"{tag}.log").write_text(log, encoding="utf-8")

    def fail(msg):
        res["status"] = "FAIL"
        res["notes"].append(msg)

    if info["errors"]:
        fail("ERROR/assert in log")
    tris = read_stl(stl) if stl.exists() else []
    st = stl_stats(tris)
    res["bbox"] = st

    if expect == "empty":
        if info["empty"]:
            return res
        if not st:
            fail("expected empty (no collision), got geometry")
            return res
        where = (" x ".join(fmt(x) for x in st["size"])
                 + " mm at X " + fmt(st["min"][0]) + ".." + fmt(st["max"][0])
                 + ", Y " + fmt(st["min"][1]) + ".." + fmt(st["max"][1])
                 + ", Z " + fmt(st["min"][2]) + ".." + fmt(st["max"][2]))
        if st["volume"] < CONTACT_MM3:
            # zero-volume result: faces touch (e.g. lid on base at the
            # parting plane), nothing penetrates
            if res["status"] == "PASS":
                res["status"] = "WARN"
            res["notes"].append(
                f"contact only ({st['volume']:.3f} mm³ < {CONTACT_MM3}), "
                f"no penetration: {where}. Check that touching there is "
                "intended")
        else:
            fail(f"COLLISION {st['volume']:.2f} mm³ in {where}")
        return res

    if info["empty"] or not st:
        fail("no geometry produced")
        return res
    if info["simple"] != "yes":
        fail(f"Simple: {info['simple']} (not manifold)")
    if expect is not None and not show and info["volumes"] != expect:
        fail(f"Volumes {info['volumes']} != expected {expect}")
    if info["warnings"] and res["status"] == "PASS":
        res["status"] = "WARN"
        res["notes"].append("warnings must be explained in the QA report")

    if not show:
        # printable part: must lie on the bed and fit the build volume
        if abs(st["min"][2]) > 0.01:
            fail(f"min Z = {fmt(st['min'][2])}, not on the bed")
        over = [f"{'XYZ'[i]} {fmt(st['size'][i])} > {a.bed[i]:g}"
                for i in range(3) if st["size"][i] > a.bed[i]]
        if over:
            fail("exceeds build volume: " + ", ".join(over))
        res["overhang"] = overhangs(tris, st["min"][2])

    # previews/sections work on the exported STL, so they show exactly
    # the geometry that would be printed
    model = tmp / f"{tag}_model.scad"
    model.write_text(f'import("{scad_path(stl)}");\n', encoding="utf-8")

    cuts = [c for c in a.cut if c["part"] in (None, part)]
    jobs = []
    with cf.ThreadPoolExecutor(max_workers=4) as ex:
        if not a.no_png:
            for v in VIEWS:
                jobs.append(ex.submit(render_png, model,
                                      out / f"{tag}_{v}.png", v))
        sec_futs = []
        for c in cuts:
            lab = cut_label(c)
            xf, _, _ = CUT_XFORM[c["axis"]]
            xf = xf.format(m=-c["value"], v=c["value"])
            sec = tmp / f"{tag}_cut_{lab}.scad"
            sec.write_text(f'projection(cut = true) {xf}\n'
                           f'    import("{scad_path(stl)}");\n',
                           encoding="utf-8")
            svg = out / f"{tag}_cut_{lab}.svg"
            if svg.exists():
                svg.unlink()
            sec_futs.append((c, svg, ex.submit(run, ["-o", str(svg),
                                                     str(sec)], 600)))
            if not a.no_png:
                jobs.append(ex.submit(render_png, sec,
                                      out / f"{tag}_cut_{lab}.png", "top"))
        res["sections"] = []
        for c, svg, fut in sec_futs:
            fut.result()
            _, ax1, ax2 = CUT_XFORM[c["axis"]]
            entry = {"label": cut_label(c), "axes": f"{ax1}/{ax2}", "loops": []}
            if svg.exists():
                entry["loops"] = loop_infos(svg_loops(svg))
            else:
                res["notes"].append(f"cut {entry['label']}: empty "
                                    "(outside the part?)")
            res["sections"].append(entry)
        for j in jobs:
            j.result()
    if not a.keep_stl:
        stl.unlink()
    return res


def merge(old, new):
    """--add: new part results replace old ones; sections accumulate."""
    by_part = {r["part"]: r for r in old}
    for r in new:
        prev = by_part.get(r["part"])
        if prev:
            labels = {s["label"] for s in r.get("sections", [])}
            r["sections"] = [s for s in prev.get("sections", [])
                             if s["label"] not in labels] + r.get("sections", [])
        by_part[r["part"]] = r
    return list(by_part.values())


def write_md(src, results, out, bed):
    L = []
    rel = os.path.relpath(src, REPO).replace("\\", "/")
    L.append(f"# G1 check: `{rel}`\n")
    L.append(f"- Date: {dt.datetime.now():%Y-%m-%d %H:%M}")
    _, ver = run(["--version"])
    L.append(f"- OpenSCAD: {ver.strip()}")
    L.append(f"- Build volume checked: {' x '.join(f'{b:g}' for b in bed)} mm")
    overall = "PASS"
    for r in results:
        if r["status"] == "FAIL":
            overall = "FAIL"
        elif r["status"] == "WARN" and overall == "PASS":
            overall = "WARN"
    L.append(f"- **Result G1: {overall}**\n")

    L.append("| Part | Status | Simple | Volumes (exp.) | Size X x Y x Z [mm] | Min Z | Volume cm³ | Notes |")
    L.append("|---|---|---|---|---|---|---|---|")
    for r in results:
        bb = r.get("bbox")
        size = " x ".join(fmt(s) for s in bb["size"]) if bb else "–"
        minz = fmt(bb["min"][2]) if bb else "–"
        cm3 = f"{bb['volume'] / 1000:.2f}" if bb else "–"
        exp = "view only" if r.get("show") else (
            r["expect"] if r["expect"] is not None else "?")
        vol = "empty" if r.get("empty") else r.get("volumes")
        L.append(f"| {r['part']} | {r['status']} | {r.get('simple') or '–'} | "
                 f"{vol} ({exp}) | {size} | {minz} | {cm3} | {'; '.join(r['notes'])} |")
    L.append("")

    for r in results:
        if r.get("errors") or r.get("warnings"):
            L.append(f"## Errors / warnings: {r['part']}\n")
            for l in r["errors"] + r["warnings"]:
                L.append(f"- `{l}`")
            L.append("")

    oh = [r for r in results if r.get("overhang")]
    if oh:
        L.append(f"## Overhangs > {OVERHANG_DEG}° from vertical\n")
        L.append("Downward facets, bed face excluded, grouped by height. "
                 "Bore ceilings and small ledges usually show up here and "
                 "are fine; anything large must be intended.\n")
        L.append("| Part | z | Area mm² | X range | Y range |")
        L.append("|---|---|---|---|---|")
        for r in oh:
            o = r["overhang"]
            if not o["rows"]:
                L.append(f"| {r['part']} | – | {o['total']:.1f} total | | |")
            for e in o["rows"]:
                L.append(f"| {r['part']} | {e['z']:g} | {e['area']:.1f} "
                         f"| {fmt(e['x'][0])} .. {fmt(e['x'][1])} "
                         f"| {fmt(e['y'][0])} .. {fmt(e['y'][1])} |")
        L.append("")

    for r in results:
        if not r.get("sections"):
            continue
        L.append(f"## Sections: {r['part']}\n")
        L.append("Contours sorted by area. `hole` = contour inside material "
                 "(pocket, bore, cavity). Ranges in the cut's 2D axes.\n")
        L.append("| Cut | Axes | # | Kind | 1st range | 2nd range | Size | Area mm² |")
        L.append("|---|---|---|---|---|---|---|---|")
        for s in r["sections"]:
            for i, lp in enumerate(s["loops"]):
                L.append(f"| {s['label']} | {s['axes']} | {i + 1} | {lp['kind']} "
                         f"| {fmt(lp['x'][0])} .. {fmt(lp['x'][1])} "
                         f"| {fmt(lp['y'][0])} .. {fmt(lp['y'][1])} "
                         f"| {fmt(lp['w'])} x {fmt(lp['d'])} | {lp['area']:.1f} |")
        L.append("")

    echoes = next((r["echoes"] for r in results if r.get("echoes")), [])
    if echoes:
        L.append("## echo() output (claims of the file, not results)\n")
        for e in echoes:
            L.append(f"- {e}")
        L.append("")

    imgs = sorted(p.name for p in out.glob("*.png"))
    if imgs:
        L.append("## Images\n")
        for name in imgs:
            L.append(f"- [{name}]({name})")
        L.append("")

    (out / "check.md").write_text("\n".join(L), encoding="utf-8")
    (out / "check.json").write_text(json.dumps(results, indent=1),
                                    encoding="utf-8")
    return overall


def quick(src, defines, out=sys.stdout):
    d_args = []
    for kv in defines:
        d_args += ["-D", kv]
    with tempfile.TemporaryDirectory() as tmp:
        _, log = run(["-o", str(Path(tmp) / "q.csg")] + d_args + [str(src)],
                     timeout=120)
    info = parse_log(log)
    name = Path(src).name
    if info["errors"]:
        print(f"G1-quick FAIL {name}:", file=out)
        for l in info["errors"]:
            print("  " + l, file=out)
        return 2
    if info["warnings"]:
        print(f"G1-quick WARN {name}:", file=out)
        for l in info["warnings"]:
            print("  " + l, file=out)
        return 1
    print(f"G1-quick OK {name} (evaluates, no assert failed). "
          "Full gate: python tools/check.py <file> --part ...", file=out)
    return 0


def hook():
    """PostToolUse hook: quick check after Write/Edit of a .scad file.
    Expects the tool's JSON on stdin with tool_input.file_path (Claude
    Code format). Exit 2 feeds stderr back to the agent; everything else
    stays silent."""
    try:
        data = json.load(sys.stdin)
    except ValueError:
        return 0
    f = ((data.get("tool_input") or {}).get("file_path")
         or (data.get("tool_response") or {}).get("filePath") or "")
    if not f.lower().endswith(".scad") or not os.path.exists(f):
        return 0
    return 2 if quick(Path(f), [], out=sys.stderr) else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("file", nargs="?")
    ap.add_argument("--hook", action="store_true",
                    help="PostToolUse hook mode: file path from stdin JSON")
    ap.add_argument("--quick", action="store_true",
                    help="evaluate only (CSG export): syntax, assert, warnings")
    ap.add_argument("--part", action="append", default=[],
                    help="printable part, optionally with expected volumes: "
                         "base=2. Checked for bed contact, build volume, "
                         "overhangs. Without --part/--show the file default")
    ap.add_argument("--show", action="append", default=[],
                    help="part rendered for images only, not printed "
                         "(e.g. assembly)")
    ap.add_argument("--empty", action="append", default=[],
                    help="part that must be empty (e.g. interference)")
    ap.add_argument("--cut", action="append", type=parse_cut, default=[],
                    help="section [part:][x=|y=|z=]value, repeatable")
    ap.add_argument("--bed", default=DEFAULT_BED,
                    help=f"build volume X,Y,Z in mm (default {DEFAULT_BED})")
    ap.add_argument("-D", dest="defines", action="append", default=[],
                    help="extra OpenSCAD define, e.g. -D seed=4")
    ap.add_argument("--out", help="output folder (default: qa/<file>/check)")
    ap.add_argument("--add", action="store_true",
                    help="keep earlier results in the output folder and add "
                         "to them (e.g. more cuts) instead of starting over")
    ap.add_argument("--keep-stl", action="store_true",
                    help="keep the exported STLs for further analysis")
    ap.add_argument("--no-png", action="store_true")
    a = ap.parse_args()
    if a.hook:
        sys.exit(hook())
    if not a.file:
        ap.error("file is required")
    a.bed = [float(x) for x in a.bed.split(",")]

    src = Path(a.file).resolve()
    if not src.exists():
        sys.exit(f"not found: {src}")
    if a.quick:
        sys.exit(2 if quick(src, a.defines) == 2 else 0)

    out = Path(a.out) if a.out else REPO / "qa" / src.stem / "check"
    old = []
    if a.add and (out / "check.json").exists():
        old = json.loads((out / "check.json").read_text(encoding="utf-8"))
    elif out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True, exist_ok=True)

    specs = []
    for p in a.part or ([] if a.show or a.empty else [""]):
        name, _, n = p.partition("=")
        specs.append((name or None, int(n) if n else None))
    specs += [(p, "show") for p in a.show]
    specs += [(p, "empty") for p in a.empty]

    results = []
    with tempfile.TemporaryDirectory() as tmp:
        for name, exp in specs:
            print(f"checking part {name or 'default'} ...", flush=True)
            results.append(check_part(src, name, exp, a, out, Path(tmp)))
    overall = write_md(src, merge(old, results), out, a.bed)
    print(f"G1 {overall} -> {os.path.relpath(out / 'check.md', REPO)}")
    sys.exit(1 if overall == "FAIL" else 0)


if __name__ == "__main__":
    main()
