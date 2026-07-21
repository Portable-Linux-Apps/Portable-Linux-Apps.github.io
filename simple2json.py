#!/bin/env python3

import os
import json
import sys

apps_dir = "apps"

def github_actions() -> bool:
    if "CI" in os.environ or os.environ.get("CI") is not None or "GITHUB_RUN_ID" in os.environ:
        return True
    return False

if not github_actions():
    print("Not running in Github Actions")
    sys.exit(0)

all_entries = os.listdir(apps_dir)
print(f"Found {len(all_entries)} entries in {apps_dir}/")

count = 0
skipped = []
failed = []

for f in all_entries:
    full_path = f"{apps_dir}/{f}"

    if "." in f:
        skipped.append((f, "contains a dot"))
        continue

    if not os.path.isfile(full_path):
        skipped.append((f, "not a regular file (directory or symlink?)"))
        continue

    try:
        with open(full_path, 'r') as file:
            lines = file.readlines()

        data = {"name": "", "description": "", "screenshots": [], "sites": [], "sources": [], "buttons": []}
        desc_lines = []

        for line in lines:
            ls = line.strip()
            if ls.startswith("# SCREENSHOTS:"):
                data["screenshots"] = ls[15:].strip().split()
            elif ls.startswith("# SITES:"):
                data["sites"] = ls[8:].strip().split()
            elif ls.startswith("# SOURCES:"):
                data["sources"] = ls[10:].strip().split()
            elif ls.startswith("# BUTTONS:"):
                data["buttons"] = ls[10:].strip().split()
            elif ls.startswith("#"):
                data["name"] = ls[1:].strip()
            else:
                desc_lines.append(line)

            data["description"] = "\n".join(desc_lines).strip()

        text = json.dumps(data, separators=(',', ':'))

        with open(f"{full_path}.json", 'w') as file:
            file.write(text)

        os.remove(full_path)
        count += 1

    except Exception as e:
        failed.append((f, str(e)))

print(f"Processed {count} apps")

if skipped:
    print(f"\nSkipped {len(skipped)} entries:")
    for name, reason in skipped:
        print(f"  - {name}: {reason}")

if failed:
    print(f"\nFAILED on {len(failed)} entries:")
    for name, err in failed:
        print(f"  - {name}: {err}")
    sys.exit(1)
