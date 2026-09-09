#!/usr/bin/env python3
"""Print a compact PPA/signoff summary from the newest LibreLane run."""
from __future__ import annotations
import csv
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "librelane/runs")
runs = sorted((p for p in root.glob("*") if p.is_dir()), key=lambda p: p.stat().st_mtime)
if not runs:
    raise SystemExit(f"No runs found below {root}")
run = runs[-1]

metrics: dict[str, object] = {}
for path in run.rglob("metrics.json"):
    try:
        data = json.loads(path.read_text())
        if isinstance(data, dict):
            metrics.update(data)
    except (OSError, json.JSONDecodeError):
        pass
for path in run.rglob("metrics.csv"):
    try:
        with path.open(newline="") as f:
            for row in csv.DictReader(f):
                name = row.get("Metric") or row.get("metric") or row.get("name")
                value = row.get("Value") or row.get("value")
                if name and value is not None:
                    metrics[name] = value
    except OSError:
        pass

aliases = {
    "Area (um^2)": ["design__core__area", "design__instance__area"],
    "Utilization (%)": ["design__instance__utilization", "design__instance__utilization__openroad"],
    "Worst setup slack (ns)": ["timing__setup__ws", "timing__setup__wns"],
    "Worst hold slack (ns)": ["timing__hold__ws", "timing__hold__wns"],
    "Total negative slack (ns)": ["timing__setup__tns"],
    "DPL violations": ["design__violations", "route__drc_errors"],
    "KLayout DRC": ["klayout__drc_error__count"],
    "LVS errors": ["lvs__errors"],
    "Antenna violations": ["antenna__violating__nets", "antenna__violating__pins"],
}

print(f"Run: {run}")
for label, keys in aliases.items():
    value = next((metrics[k] for k in keys if k in metrics), "N/A")
    print(f"{label:29s}: {value}")
print(f"Metrics collected             : {len(metrics)}")
