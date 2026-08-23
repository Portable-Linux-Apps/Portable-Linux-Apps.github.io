#!/usr/bin/env python3
"""Select catalog apps that are missing real screenshots.

Prints a JSON array of app file names (AM app IDs) whose `# SCREENSHOTS:` line
is missing, empty, or still holds the `contribute_ss.webp` placeholder.
Sorted alphabetically so repeated runs retry the same failing apps.

Exclusions are read from `screenshot_capture_blacklist` next to this script.
"""
import os
import re
import sys
from urllib.request import urlopen
import json

APPS_DIR = sys.argv[1] if len(sys.argv) > 1 else "apps"

blacklist = set()

with urlopen("https://portable-linux-apps.github.io/categories/command-line.json") as resp:
    data = json.loads(resp.read())
    for k in data.keys():
        blacklist.add(k)

with open('.github/scripts/screenshot_capture_blacklist', 'r') as f:
    lines = f.readlines()
    names = [line.strip() for line in lines if line.strip() != '']
    blacklist.update(names)

PLACEHOLDER = re.compile(r"contribute_ss")

candidates = []
for fname in sorted(os.listdir(APPS_DIR)):
    if fname.startswith(".") or fname.endswith("~"):
        continue
    if fname in blacklist:
        continue
    try:
        text = open(os.path.join(APPS_DIR, fname), "r", errors="replace").read()
    except OSError:
        continue
    m = re.search(r"^#\s*SCREENSHOTS\s*:\s*(.*?)\s*$", text, re.M)
    if not m or not m.group(1).strip() or PLACEHOLDER.search(m.group(1)):
        candidates.append(fname)

print("\n".join(candidates))
