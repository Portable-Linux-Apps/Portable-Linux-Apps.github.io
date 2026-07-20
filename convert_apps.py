#!/usr/bin/env python3
import re, json, sys
from pathlib import Path

APPS_DIR = Path("apps")

TITLE_RE = re.compile(r'^#\s+(.+)$')
SITE_RE = re.compile(r'^SITE:\s*(.+?)\s*$', re.IGNORECASE)
SITES_RE = re.compile(r'^SITES:\s*(.+?)\s*$', re.IGNORECASE)
SITE_SOURCE_RE = re.compile(r'^SITE\s*&\s*SOURCE:\s*(.+?)\s*$', re.IGNORECASE)
SOURCE_RE = re.compile(r'^SOURCE:\s*(.+?)\s*$', re.IGNORECASE)
SOURCES_RE = re.compile(r'^SOURCES:\s*(.+?)\s*$', re.IGNORECASE)
TABLE_ROW_RE = re.compile(r'^\s*\|')
METADATA_KEY_RE = re.compile(r'^[A-Z][A-Z\s&]+:')
MD_IMG_RE = re.compile(r'!\[(.*?)\]\((https?://[^\s)]+)\)')

SITE_PATTERNS = [SITE_SOURCE_RE, SITES_RE, SITE_RE]
SOURCE_PATTERNS = [SOURCES_RE, SOURCE_RE]


def md_img_to_html(text):
    return MD_IMG_RE.sub(r'<img src="\2" alt="\1">', text)


def is_break_line(stripped):
    if not stripped:
        return False
    if TABLE_ROW_RE.match(stripped):
        return True
    if METADATA_KEY_RE.match(stripped):
        return True
    return False


def clean_line(l):
    return l.rstrip('\n').rstrip('\r')


def parse_md(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()

    data = {
        'name': None,
        'description': '',
        'sites': [],
        'sources': [],
    }

    state = 'title'
    desc_lines = []

    for line in lines:
        s = clean_line(line)
        st = s.strip()

        if state == 'title':
            m = TITLE_RE.match(s)
            if m:
                data['name'] = m.group(1).strip().lower()
                state = 'desc'
            continue

        if state == 'desc':
            if is_break_line(st):
                state = 'meta'
            else:
                desc_lines.append(s)
                continue

        if state == 'meta':
            if not st:
                continue
            if TABLE_ROW_RE.match(st):
                continue
            if METADATA_KEY_RE.match(st):
                pass
            else:
                continue

            matched = False

            m = SITE_SOURCE_RE.match(st)
            if m:
                url = m.group(1).strip()
                if url not in data['sites']:
                    data['sites'].append(url)
                if url not in data['sources']:
                    data['sources'].append(url)
                matched = True

            if not matched:
                m = SITES_RE.match(st)
                if m:
                    for url in m.group(1).strip().split():
                        if url not in data['sites']:
                            data['sites'].append(url)
                    matched = True

            if not matched:
                m = SITE_RE.match(st)
                if m:
                    url = m.group(1).strip()
                    if url not in data['sites']:
                        data['sites'].append(url)
                    matched = True

            if not matched:
                m = SOURCES_RE.match(st)
                if m:
                    for url in m.group(1).strip().split():
                        if url not in data['sources']:
                            data['sources'].append(url)
                    matched = True

            if not matched:
                m = SOURCE_RE.match(st)
                if m:
                    url = m.group(1).strip()
                    if url not in data['sources']:
                        data['sources'].append(url)
                    matched = True

    while desc_lines and not desc_lines[0].strip():
        desc_lines.pop(0)
    while desc_lines and not desc_lines[-1].strip():
        desc_lines.pop()

    raw_desc = '\n'.join(desc_lines).strip()
    data['description'] = md_img_to_html(raw_desc)

    return data


def main():
    md_files = sorted(APPS_DIR.glob('*.md'))
    if not md_files:
        print("No .md files found in apps/")
        return 1

    total = len(md_files)
    ok = 0
    err = 0

    for i, md_path in enumerate(md_files):
        app_name = md_path.stem
        try:
            data = parse_md(md_path)
            output = {
                'name': data['name'] or app_name,
                'description': data['description'],
                'sites': data['sites'],
                'sources': data['sources'],
            }
            json_path = APPS_DIR / f"{app_name}.json"
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(output, f, indent=2, ensure_ascii=False)
            ok += 1
            print(f"[{i+1}/{total}] {app_name}")
        except Exception as e:
            err += 1
            print(f"[{i+1}/{total}] ERROR {app_name}: {e}", file=sys.stderr)

        if (i + 1) % 100 == 0:
            print(f"--- {i+1}/{total} processed ---", file=sys.stderr)

    print(f"\nDone: {ok} converted, {err} errors out of {total} files.")
    return 0


if __name__ == '__main__':
    sys.exit(main())
