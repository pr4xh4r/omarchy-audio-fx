#!/usr/bin/env python3
"""
apply-audio.py  <device-preset>  <mode-preset>

Merges a device compensation preset (IEM, Headphones, etc.) with a
sound-mode preset (Marshall, Gaming, etc.) into a single EasyEffects
preset and loads it.

Rules:
  - device=""  mode=""   → bypass (Off)
  - device set mode=""   → load device preset only
  - device=""  mode set  → load mode preset only
  - both set             → merge: device EQ (compensation) runs FIRST in
                           the chain, then all mode plugins follow.
                           Merged result saved as "__Active-Profile" and loaded.
"""

import json
import os
import subprocess
import sys

PRESET_DIR = os.path.expanduser("~/.local/share/easyeffects/output")
MERGED_NAME = "__Active-Profile"


def load_preset(name: str) -> dict | None:
    if not name:
        return None
    path = os.path.join(PRESET_DIR, f"{name}.json")
    if not os.path.exists(path):
        return None
    with open(path) as f:
        return json.load(f)


def ee(*args):
    subprocess.run(["easyeffects"] + list(args),
                   capture_output=True)


def apply_single(preset_name: str):
    ee("--bypass", "0")
    ee("--load-preset", preset_name)


def merge_and_apply(device_name: str, mode_name: str):
    device_data = load_preset(device_name)
    mode_data   = load_preset(mode_name)

    if device_data is None and mode_data is None:
        ee("--bypass", "1")
        return

    if device_data is None:
        apply_single(mode_name)
        return

    if mode_data is None:
        apply_single(device_name)
        return

    dev_out  = device_data.get("output", {})
    mode_out = mode_data.get("output", {})

    dev_plugins  = dev_out.get("plugins_order", [])
    mode_plugins = mode_out.get("plugins_order", [])

    # ── Find device's equalizer (if any) and rename it so it doesn't
    #    collide with the mode's equalizer#0.
    #    We slot it in as equalizer#9 (very unlikely to exist in mode). ──
    DEV_EQ_ALIAS = "equalizer#9"
    dev_eq_original = None
    for p in dev_plugins:
        if p.startswith("equalizer"):
            dev_eq_original = p
            break

    merged_plugins = []
    merged_plugins_data = {}

    # 1. Device EQ first (compensation layer)
    if dev_eq_original and dev_eq_original in dev_out:
        merged_plugins.append(DEV_EQ_ALIAS)
        merged_plugins_data[DEV_EQ_ALIAS] = dev_out[dev_eq_original]

    # 2. All mode plugins after (creative/effect layer)
    for p in mode_plugins:
        if p not in merged_plugins:
            merged_plugins.append(p)
        if p in mode_out:
            merged_plugins_data[p] = mode_out[p]

    merged = {
        "output": {
            "blocklist": [],
            "plugins_order": merged_plugins,
            **merged_plugins_data
        }
    }

    # Write merged preset
    merged_path = os.path.join(PRESET_DIR, f"{MERGED_NAME}.json")
    with open(merged_path, "w") as f:
        json.dump(merged, f, indent=2)

    ee("--bypass", "0")
    ee("--load-preset", MERGED_NAME)


def main():
    device = sys.argv[1].strip() if len(sys.argv) > 1 else ""
    mode   = sys.argv[2].strip() if len(sys.argv) > 2 else ""

    if not device and not mode:
        ee("--bypass", "1")
        return

    if not device:
        apply_single(mode)
        return

    if not mode:
        apply_single(device)
        return

    merge_and_apply(device, mode)


if __name__ == "__main__":
    main()
