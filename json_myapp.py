import json
import os
import sys

filepath = sys.argv[1]

with open(filepath) as f:
    content = f.read()

data = {"name": "", "description": "", "buttons":[], "sites": [], "sources": [], "screenshots": []}
desc_lines = []

for line in content.splitlines():
    ls = line.strip()
    if ls.startswith("#"):
        data["name"] = ls[1:].strip()
    elif ls.startswith("SITES:"):
        data["sites"] = ls[6:].strip().split()
    elif ls.startswith("SOURCES:"):
        data["sources"] = ls[8:].strip().split()
    elif ls.startswith("SCREENSHOTS:"):
        data["screenshots"] = ls[13:].strip().split()
    elif ls.startswith("BUTTONS:"):
        data["buttons"] = ls[8:].strip().split()
    else:
        desc_lines.append(line)

data["description"] = "\n".join(desc_lines).strip()

text = json.dumps(data, separators=(',', ':'))
print(text)

outname = os.path.splitext(filepath)[0] + ".json"
with open(outname, 'w') as f:
    f.write(text)

