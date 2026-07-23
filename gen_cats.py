import json
import os
import re
import requests
import sys

AMREPO = "https://raw.githubusercontent.com/ivan-hc/AM/main"
arch = "x86_64"

def fetch(path):
    r = requests.get(f"{AMREPO}/{path}")
    if r.status_code != 200:
        print(f"Failed to fetch {path}", file=sys.stderr)
        sys.exit(1)
    return r.text

apps_raw = fetch(f"programs/{arch}-apps")
stats_ai = fetch("programs/stats-appimages")
stats_portable = fetch("programs/stats-portable")

if not apps_raw.startswith("◆ "):
    sys.exit(0)

apps_info = {}
for line in apps_raw.splitlines():
    m = re.match(r"◆ (.+?) : (.+)", line)
    if m:
        name = m.group(1).strip()
        desc = m.group(2).strip()
        apps_info[name] = desc

def parse_stats(text):
    names = set()
    for line in text.splitlines():
        m = re.match(r"◆ (.+?) : (.+)", line)
        if m:
            names.add(m.group(1).strip())
    return names

def parse_stats_tagged(text, tag):
    names = set()
    for line in text.splitlines():
        if tag in line:
            m = re.match(r"◆ (.+?) :", line)
            if m:
                names.add(m.group(1).strip())
    return names

appimage_names = parse_stats(stats_ai)
portable_all = parse_stats(stats_portable)
portable_no_iotf = {n for n in portable_all if n not in parse_stats_tagged(stats_portable, "#itsappimageonthefly")}
portable_iotf = parse_stats_tagged(stats_portable, "#itsappimageonthefly")
portable_cli = parse_stats_tagged(stats_portable, "#itscliapp")
portable_desktop = parse_stats_tagged(stats_portable, "#itsdesktopapp")

# Names that are pure AppImage entries (appears in stats-appimages, not in portable nor portable-cli)
# Not used for individual categories but useful for checking.

METAPACKAGE_NAMES = {"kdegames", "kdeutils", "node", "platform-tools"}

def lookup(name):
    return apps_info.get(name, "")

CATEGORY_PATTERNS = {
    "ai": None,
    "am-utils": re.compile(r'"am-utils"', re.IGNORECASE),
    "android": re.compile(r"android|platform-tools", re.IGNORECASE),
    "audio": re.compile(r"audio|matroska|music|midi|mp3|opus|soundboard", re.IGNORECASE),
    "comic": re.compile(r"comic|manga|anime", re.IGNORECASE),
    "command-line": re.compile(
        r"command-line|command line| cli |-cli|terminal |"
        r'"am-utils"|"node"|"platform-tools"',
        re.IGNORECASE,
    ),
    "communication": re.compile(
        r"communication|voip|messenger|whatsapp|mastodon|skype|chat client|"
        r"social network|conferencing|discord|email|telegram",
        re.IGNORECASE,
    ),
    "disk": re.compile(r"disk|partition|usb drive", re.IGNORECASE),
    "education": re.compile(
        r"education|productivity|study|dictionar|math| book | books |"
        r"book-|ebook|e-book|space simulator|planetarium|astronom|university|"
        r"bible|quran|koran",
        re.IGNORECASE,
    ),
    "emulator": re.compile(r"emulator", re.IGNORECASE),
    "file-manager": re.compile(
        r"file-manager|file manager|file browse|browse.*file|"
        r"file explore|explore.*file",
        re.IGNORECASE,
    ),
    "finance": re.compile(r"finance|wallet|money", re.IGNORECASE),
    "game": re.compile(
        r"game|arcade|steam|wine|strateg|solitaire|poker|chess|puzzle|"
        r"pinball|adventure|playstation|xbox|nintendo|minecraft|doom",
        re.IGNORECASE,
    ),
    "gnome": re.compile(r"gnome", re.IGNORECASE),
    "graphic": re.compile(
        r"drawing|jpg|duplicated images|gimp|inkscape|converseen|visipics|"
        r"imagemagick|photo|svg|png|autocad|blender|3D modeling|paint|"
        r"pixel|wallpaper",
        re.IGNORECASE,
    ),
    "internet": re.compile(r"internet|vpn|torrent|p2p", re.IGNORECASE),
    "kde": re.compile(r"kde", re.IGNORECASE),
    "office": re.compile(r"office|document|pdf|docx|reader|spreadsheet", re.IGNORECASE),
    "password": re.compile(r"password", re.IGNORECASE),
    "steam": re.compile(r"steam", re.IGNORECASE),
    "system-monitor": re.compile(
        r"system-monitor|system monitor|task manager|system resource|"
        r"system resources|linux processes",
        re.IGNORECASE,
    ),
    "video": re.compile(r"video|stream|media player|film|movies|netflix|iptv", re.IGNORECASE),
    "virtual-machine": re.compile(
        r"virtual-machine|virtual machine|virtualization|qemu", re.IGNORECASE
    ),
    "wallet": re.compile(r"wallet", re.IGNORECASE),
    "web-app": re.compile(r"web-app|webapp|web app", re.IGNORECASE),
    "web-browser": re.compile(
        r"web-browser|web.*browser|browser.*web|google-chrome|"
        r"firefox.*browser|firefox.*fork|fork.*firefox|safari|microsoft-edge|"
        r"opera.*browser|brave.*browser|vivaldi.*browser|arc.*browser|"
        r"tor.*browser|chromium|duckduckgo.*browser|orion.*browser|waterfox|"
        r"librewolf|palemoon|seamonkey|maxthon|yandex.*browser|uc.*browser|"
        r"qq.*browser|baidu.*browser|kiwi|puffin|dolphin.*browser|"
        r"epic.*browser|avast.*browser|avg.*browser|midori|falkon|konqueror|"
        r"gnome.*web.*browser|floorp|zen.*browser|slimjet|srware.*iron|"
        r"comodo.*dragon|sleipnir|lunascape|otter.*browser|basilisk|icecat|"
        r"kmeleon|k-melon|netscape|mosaic.*browser",
        re.IGNORECASE,
    ),
    "wine": re.compile(r"wine", re.IGNORECASE),
    "youtube": re.compile(r"youtube", re.IGNORECASE),
}

CATEGORY_EXCLUDE = {
    "education": re.compile(r"game|manga|anime", re.IGNORECASE),
    "emulator": re.compile(r"terminal emulator", re.IGNORECASE),
    "office": re.compile(r"manga|comic", re.IGNORECASE),
    "web-browser": re.compile(r"embedded web browser video player", re.IGNORECASE),
}

def match_by_pattern(cat, pat, exclude):
    matched = []
    for name, desc in apps_info.items():
        line = f"◆ {name} : {desc}"
        if pat.search(line):
            if exclude and exclude.search(line):
                continue
            matched.append({"name": name, "description": desc})
    matched.sort(key=lambda x: x["name"].lower())
    return matched

def write_json(cat, matched):
    with open(f"categories/{cat}.json", "w") as f:
        f.write("[\n")
        for i, app in enumerate(matched):
            if i > 0:
                f.write(",\n")
            json.dump(app, f, indent=None, separators=(",", ":"), ensure_ascii=False)
        f.write("\n]\n")
    print(f"categories/{cat}.json  ({len(matched)} apps)")

os.makedirs("categories", exist_ok=True)

# --- AI (case-sensitive "AI" match + space-delimited meta, matching upstream) ---
ai_set = set()
for name, desc in apps_info.items():
    line = f"◆ {name} : {desc}"
    # case-sensitive "AI"
    if re.search(r"AI", line):
        ai_set.add(name)
        continue
    # case-insensitive for all other terms, with " meta " (space-delimited)
    if re.search(
        r"chatgpt|openai|gemini|claude|copilot|perplexity| meta |grok|"
        r"anthropic|huggingface|mistral|cohere|together|replicate|cursor|"
        r"codeium|tabnine|replit|windsurf|midjourney|firefly|canva|runway|"
        r"leonardo|synthesia|elevenlabs|heygen|zapier|z\.ai|clickup|grammarly|"
        r"ollama|lmstudio|openwebui|salesforce|watsonx",
        line,
        re.IGNORECASE,
    ):
        ai_set.add(name)

ai_matched = [{"name": n, "description": apps_info[n]} for n in sorted(ai_set, key=str.lower)]
write_json("ai", ai_matched)

# --- Pattern-based categories ---
for cat in sorted(CATEGORY_PATTERNS.keys()):
    pat = CATEGORY_PATTERNS[cat]
    if pat is None:
        continue
    exclude = CATEGORY_EXCLUDE.get(cat)
    matched = match_by_pattern(cat, pat, exclude)
    write_json(cat, matched)

# --- metapackages ---
meta_matched = []
for name in METAPACKAGE_NAMES:
    if name in apps_info:
        meta_matched.append({"name": name, "description": apps_info[name]})
# Also include apps whose description references "kdegames", "kdeutils", "node", "platform-tools"
for name, desc in apps_info.items():
    if name in METAPACKAGE_NAMES:
        continue
    line = f"◆ {name} : {desc}"
    if re.search(r'"kdegames"|"kdeutils"|"node"|"platform-tools"', line, re.IGNORECASE):
        meta_matched.append({"name": name, "description": desc})
meta_matched.sort(key=lambda x: x["name"].lower())
write_json("metapackages", meta_matched)

# --- portable (from stats-portable minus #itsappimageonthefly, looked up in apps_info) ---
portable_matched = []
for n in sorted(portable_no_iotf, key=str.lower):
    if n in apps_info:
        portable_matched.append({"name": n, "description": apps_info[n]})
    else:
        portable_matched.append({"name": n, "description": lookup(n)})
write_json("portable", portable_matched)

# --- portable-cli (from stats-portable with #itscliapp) ---
pcli_matched = []
for n in sorted(portable_cli, key=str.lower):
    if n in apps_info:
        pcli_matched.append({"name": n, "description": apps_info[n]})
    else:
        pcli_matched.append({"name": n, "description": lookup(n)})
write_json("portable-cli", pcli_matched)

# --- portable-desktop (from stats-portable with #itsdesktopapp) ---
pdesk_matched = []
for n in sorted(portable_desktop, key=str.lower):
    if n in apps_info:
        pdesk_matched.append({"name": n, "description": apps_info[n]})
    else:
        pdesk_matched.append({"name": n, "description": lookup(n)})
write_json("portable-desktop", pdesk_matched)

# --- appimage-on-the-fly (from stats-portable with #itsappimageonthefly) ---
iotf_matched = []
for n in sorted(portable_iotf, key=str.lower):
    if n in apps_info:
        iotf_matched.append({"name": n, "description": apps_info[n]})
    else:
        iotf_matched.append({"name": n, "description": lookup(n)})
write_json("appimage-on-the-fly", iotf_matched)

# --- appimages (from stats-appimages, looked up in apps_info) ---
ai_apps = []
for n in sorted(appimage_names, key=str.lower):
    if n in apps_info:
        ai_apps.append({"name": n, "description": apps_info[n]})
    else:
        ai_apps.append({"name": n, "description": lookup(n)})
write_json("appimages", ai_apps)
