#!/usr/bin/env python3
"""Merge translations from a TSV file (exported from Google Sheets) into .po files.

Usage:
    python3 merge_translations.py locales/apps-list.tsv -l it
    python3 merge_translations.py locales/apps-list.tsv --lang it --output locales/it/apps-list.po

The TSV file should have columns:
    App Name | English | Translation | Context

Columns:
    A - App name (used as location comment)
    B - English (msgid)
    C - Translation (msgstr)
    D - Context (msgctxt, optional)

This script:
    1. Reads the TSV file
    2. Updates the corresponding .po file with translations
    3. Adds new entries if they don't exist
    4. Preserves existing translations (won't overwrite unless --force is used)
"""

import argparse
import csv
import re
import sys
from pathlib import Path


def unescape_po(s: str) -> str:
    """Unescape a PO string (\\n -> newline, \\" -> ", etc.)."""
    return (
        s.replace("\\n", "\n")
        .replace("\\t", "\t")
        .replace('\\"', '"')
        .replace("\\\\", "\\")
    )


def escape_po(s: str) -> str:
    """Escape a string for PO format."""
    return (
        s.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\t", "\\t")
    )


def format_po_string(keyword: str, s: str) -> str:
    """Format a string for PO/POT format with proper escaping and line wrapping."""
    escaped = escape_po(s)
    
    if "\n" in s:
        # Multi-line format
        lines = escaped.split("\\n")
        parts = []
        for i, line in enumerate(lines):
            if i < len(lines) - 1:
                parts.append(f'"{line}\\n"')
            else:
                parts.append(f'"{line}"')
        return f'{keyword} ""\n' + "\n".join(parts) + "\n"
    else:
        return f'{keyword} "{escaped}"\n'


def parse_tsv(path: str) -> list[dict]:
    """Parse a TSV file exported from Google Sheets."""
    entries = []
    
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t")
        
        for row in reader:
            app_name = row.get("App Name", "").strip()
            msgid = row.get("English", "").strip()
            msgstr = row.get("Translation", "").strip()
            ctx = row.get("Context", "").strip()
            
            if not msgid:
                continue
            
            entries.append({
                "app_name": app_name,
                "msgid": msgid,
                "msgstr": msgstr,
                "context": ctx,
            })
    
    return entries


def parse_po(path: str) -> list[dict]:
    """Parse a .po file into a list of entries."""
    content = Path(path).read_text(encoding="utf-8")
    entries = []
    
    # Split into blocks by blank lines
    blocks = re.split(r'\n\n+', content)
    
    for block in blocks:
        lines = block.strip().split("\n")
        if not lines:
            continue
        
        # Skip header
        if block.startswith('msgid ""') and "Project-Id-Version" in block:
            continue
        
        # Extract location comment
        app_name = ""
        for line in lines:
            if line.startswith("#: "):
                app_name = line[3:].split(":")[0].strip()
                break
        
        # Extract msgctxt
        ctx = ""
        for line in lines:
            if line.startswith("msgctxt "):
                ctx = unescape_po(line[8:].strip().strip('"'))
                break
        
        # Extract msgid (handle multi-line)
        msgid = ""
        in_msgid = False
        for line in lines:
            if line.startswith("msgid "):
                in_msgid = True
                msgid = unescape_po(line[6:].strip().strip('"'))
            elif in_msgid and line.startswith('"'):
                msgid += unescape_po(line.strip().strip('"'))
            elif in_msgid:
                in_msgid = False
        
        # Extract msgstr (handle multi-line)
        msgstr = ""
        in_msgstr = False
        for line in lines:
            if line.startswith("msgstr "):
                in_msgstr = True
                msgstr = unescape_po(line[7:].strip().strip('"'))
            elif in_msgstr and line.startswith('"'):
                msgstr += unescape_po(line.strip().strip('"'))
            elif in_msgstr:
                in_msgstr = False
        
        entries.append({
            "app_name": app_name,
            "msgid": msgid,
            "msgstr": msgstr,
            "context": ctx,
            "raw": block,
        })
    
    return entries


import datetime


def update_po_header(content: str, lang: str) -> str:
    """Update the .po file header with correct metadata.
    
    In .po files, header strings use \\n to represent newlines.
    When read as text in Python, \\n is literally backslash-n (two chars).
    In regex replacements, we need \\\\n to produce a literal \\n in output.
    """
    now = datetime.datetime.now(datetime.timezone.utc)
    revision_date = now.strftime("%Y-%m-%d %H:%M%z")
    
    # Replace the PO-Revision-Date line
    content = re.sub(
        r'"PO-Revision-Date: [^"]*"',
        f'"PO-Revision-Date: {revision_date}\\\\n"',
        content
    )
    
    # Replace Last-Translator
    content = re.sub(
        r'"Last-Translator: [^"]*"',
        '"Last-Translator: Automatic translation\\\\n"',
        content
    )
    
    # Replace Language-Team
    content = re.sub(
        r'"Language-Team: [^"]*"',
        f'"Language-Team: {lang}\\\\n"',
        content
    )
    
    # Replace Language
    content = re.sub(
        r'"Language: [^"]*"',
        f'"Language: {lang}\\\\n"',
        content
    )
    
    return content


def merge_translations(tsv_path: str, po_path: str, force: bool = False, lang: str = "it"):
    """Merge translations from TSV into the .po file."""
    tsv_entries = parse_tsv(tsv_path)
    po_entries = parse_po(po_path)
    
    # Build lookup by (msgid, context) for TSV
    tsv_lookup = {}
    for entry in tsv_entries:
        key = (entry["msgid"], entry["context"])
        tsv_lookup[key] = entry
    
    # Track changes
    updated = 0
    added = 0
    unchanged = 0
    
    # Update existing entries
    new_po_blocks = []
    for entry in po_entries:
        key = (entry["msgid"], entry["context"])
        
        if key in tsv_lookup:
            tsv_entry = tsv_lookup[key]
            new_msgstr = tsv_entry["msgstr"]
            
            if new_msgstr and (force or entry["msgstr"] != new_msgstr):
                # Update the msgstr
                lines = entry["raw"].split("\n")
                new_lines = []
                for line in lines:
                    if line.startswith("msgstr "):
                        new_lines.append(format_po_string("msgstr", new_msgstr).rstrip())
                    else:
                        new_lines.append(line)
                new_po_blocks.append("\n".join(new_lines))
                updated += 1
            else:
                new_po_blocks.append(entry["raw"])
                unchanged += 1
            
            # Mark as processed
            del tsv_lookup[key]
        else:
            new_po_blocks.append(entry["raw"])
    
    # Add new entries from TSV that weren't in .po
    for key, tsv_entry in tsv_lookup.items():
        if not tsv_entry["msgstr"]:
            continue  # Skip empty translations
        
        block = ""
        if tsv_entry["app_name"]:
            block += f"#: {tsv_entry['app_name']}:1\n"
        if tsv_entry["context"]:
            block += format_po_string("msgctxt", tsv_entry["context"])
        block += format_po_string("msgid", tsv_entry["msgid"])
        block += format_po_string("msgstr", tsv_entry["msgstr"])
        
        new_po_blocks.append(block)
        added += 1
    
    # Write the updated .po file
    content = "\n\n".join(new_po_blocks) + "\n"
    
    # Update header metadata
    content = update_po_header(content, lang)
    
    Path(po_path).write_text(content, encoding="utf-8")
    
    print(f"Updated: {po_path}")
    print(f"  Updated: {updated} entries")
    print(f"  Added: {added} entries")
    print(f"  Unchanged: {unchanged} entries")


def main():
    parser = argparse.ArgumentParser(
        description="Merge translations from TSV into .po files"
    )
    parser.add_argument("tsv", help="Input TSV file (exported from Google Sheets)")
    parser.add_argument(
        "-l", "--lang", default="it", help="Target language code (default: it)"
    )
    parser.add_argument(
        "-o", "--output", help="Output .po file (default: locales/<lang>/apps-list.po)"
    )
    parser.add_argument(
        "-f", "--force", action="store_true",
        help="Overwrite existing translations"
    )
    args = parser.parse_args()
    
    output = args.output or f"locales/{args.lang}/apps-list.po"
    
    if not Path(args.tsv).exists():
        print(f"Error: TSV file not found: {args.tsv}", file=sys.stderr)
        sys.exit(1)
    
    if not Path(output).exists():
        print(f"Error: .po file not found: {output}", file=sys.stderr)
        print("Create it first with: msginit -i locales/apps-list.pot -o " + output)
        sys.exit(1)
    
    merge_translations(args.tsv, output, args.force, args.lang)


if __name__ == "__main__":
    main()
