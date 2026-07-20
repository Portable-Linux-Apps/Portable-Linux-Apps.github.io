import json, glob, re

for f in sorted(glob.glob('apps/*.json')):
    with open(f) as fh:
        data = json.load(fh)
    desc = data.get('description', '')

    urls = re.findall(r'<img\s[^>]*src="([^"]+)"[^>]*>', desc)

    if not urls:
        continue

    desc_clean = re.sub(
        r'<table[^>]*>.*?</table>',
        '',
        desc,
        flags=re.DOTALL,
    )
    desc_clean = re.sub(
        r'<img\s[^>]*src="[^"]+"[^>]*>\s*',
        '',
        desc_clean,
    )
    desc_clean = re.sub(r'\n{3,}', '\n\n', desc_clean)
    desc_clean = desc_clean.strip()

    data['description'] = desc_clean
    data['screenshots'] = urls

    with open(f, 'w') as fh:
        json.dump(data, fh, separators=(',', ':'))

    print(f'{f}: {len(urls)} screenshot(s)')
