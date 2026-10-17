#!/usr/bin/env python3
"""Render the fabric templates offline and diff them against running configs.

    python3 tools/render.py                 # render all, diff vs backups/, summary
    python3 tools/render.py leaf4 --show    # print leaf4's rendered config
    python3 tools/render.py --report docs/DRIFT-REPORT.md

The diff is SEMANTIC: each config line is compared together with its parent
stanza (e.g. 'router bgp 65004 > vrf gold > rd 10.0.250.17:1'), ignoring order,
blank lines, comments and empty physical-interface stanzas. That is the same
way EOS computes a config-session diff, so it predicts what Salt will show.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import jinja2
import yaml

ROOT = Path(__file__).resolve().parent.parent
TEMPLATE = {"spine": "fabric/templates/spine.j2", "leaf": "fabric/templates/leaf.j2", "border": "fabric/templates/leaf.j2"}


def _merge(a: dict, b: dict) -> dict:
    for k, v in b.items():
        a[k] = _merge(a.get(k, {}), v) if isinstance(v, dict) and isinstance(a.get(k), dict) else v
    return a


def load_fabric() -> dict:
    """fabric.sls + users.sls (git-ignored; falls back to users.sls.example), merged like Salt does."""
    fabric = yaml.safe_load((ROOT / "pillar" / "fabric.sls").read_text())
    users = ROOT / "pillar" / "users.sls"
    if not users.exists():
        users = ROOT / "pillar" / "users.sls.example"
    return _merge(fabric, yaml.safe_load(users.read_text()))["fabric"]


HASH = re.compile(r"(secret sha512 )\S+")   # backups are stored with hashes redacted


def env(trim: bool) -> jinja2.Environment:
    # Salt's default Jinja settings: no trim/lstrip, 'do' extension enabled
    return jinja2.Environment(
        loader=jinja2.FileSystemLoader(str(ROOT / "salt")),
        extensions=["jinja2.ext.do"],
        trim_blocks=trim,
        lstrip_blocks=trim,
        undefined=jinja2.StrictUndefined,
        keep_trailing_newline=True,
    )


def render(device: str, fabric: dict, trim: bool = False) -> str:
    role = fabric["devices"][device]["role"]
    tpl = env(trim).get_template(TEMPLATE[role])
    return tpl.render(pillar={"fabric": fabric, "hostname": device})


def paths(cfg: str) -> set[tuple[str, ...]]:
    """Config text -> set of (parent, ..., line) tuples."""
    out: set[tuple[str, ...]] = set()
    stack: list[tuple[int, str]] = []
    children: dict[tuple[str, ...], int] = {}
    for raw in cfg.splitlines():
        if not raw.strip() or raw.strip().startswith("!") or raw.strip() == "end":
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        line = HASH.sub(r"\1<redacted>", " ".join(raw.split()))
        while stack and stack[-1][0] >= indent:
            stack.pop()
        p = tuple(s for _, s in stack) + (line,)
        out.add(p)
        if len(p) > 1:
            children[p[:-1]] = children.get(p[:-1], 0) + 1
        stack.append((indent, line))
    # an 'interface EthernetN' with no sub-commands is just a default physical port
    return {p for p in out if not (len(p) == 1 and p[0].startswith("interface Ethernet") and p not in children)}


def fmt(p: tuple[str, ...]) -> str:
    return " > ".join(p)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("device", nargs="?")
    ap.add_argument("--show", action="store_true", help="print the rendered config")
    ap.add_argument("--report", help="write a markdown drift report")
    a = ap.parse_args()

    fabric = load_fabric()
    devices = [a.device] if a.device else list(fabric["devices"])
    report = ["# Drift report: intended (templates) vs running configs\n",
              "`+` = Salt will ADD this line · `-` = Salt will REMOVE this line\n"]
    total = 0
    for dev in devices:
        text = render(dev, fabric)
        # guard: a command glued onto '!' would be silently treated as a comment by EOS
        glued = [ln for ln in text.splitlines() if ln.lstrip().startswith("!") and ln.strip() not in ("!",)]
        assert not glued, f"{dev}: command glued to '!' (whitespace-control bug): {glued[:3]}"
        # same result with Salt's default and with trimmed whitespace
        assert paths(text) == paths(render(dev, fabric, trim=True)), f"{dev}: whitespace-sensitive template"
        if a.show:
            print(text)
            continue
        backup = ROOT / "backups" / f"{dev}.cfg"
        if not backup.exists():
            print(f"{dev}: rendered {len(text.splitlines())} lines (no backup to compare)")
            continue
        want, have = paths(text), paths(backup.read_text())
        add, rem = sorted(want - have), sorted(have - want)
        total += len(add) + len(rem)
        print(f"{dev:12s} +{len(add):<3d} -{len(rem):<3d}")
        report.append(f"\n## {dev}  (+{len(add)} / -{len(rem)})\n\n```diff")
        report += [f"- {fmt(p)}" for p in rem] + [f"+ {fmt(p)}" for p in add]
        report.append("```")
    if a.report:
        Path(a.report).write_text("\n".join(report) + "\n")
        print(f"report -> {a.report}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
