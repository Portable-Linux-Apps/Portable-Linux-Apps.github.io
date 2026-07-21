#!/bin/env python3

import json
import sys

def remove_whitespace_eol(s: str) -> str:
    r = []
    for line in s.splitlines():
        r.append(line.rstrip())

    return "\n".join(r)

filepath = sys.argv[1]

with open(filepath) as f:
    data = json.load(f)
    f.close()

with open(f"{filepath[:-5]}", 'w') as file:
    string = f"# {data['name']}\n"
    string += f"{data['description']}\n"

    screenshots = data.get('screenshots')   # returns None if key is missing
    if screenshots is not None and len(screenshots) > 0:
        string += f"# SCREENSHOTS: {' '.join(screenshots)}\n"

    string += f"# SITES: {' '.join(data['sites'])}\n"

    sources = data.get('sources')
    if sources is not None and len(sources) > 0:
        string += f"# SOURCES: {' '.join(sources)}\n"

    buttons = data.get('buttons')
    if buttons is not None and len(buttons) != 0:
        string += f"# BUTTONS: {' '.join(buttons)}\n"

    file.write(remove_whitespace_eol(string))
    file.close()
