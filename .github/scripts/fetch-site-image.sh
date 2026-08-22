#!/usr/bin/env bash
# Find the biggest relevant image for an app from its AM install script's
# SITE value (github owner/repo -> README images, or the project website).
#
# Usage: fetch-site-image.sh <app> <work_dir>
# Prints the path of the downloaded image on success, or nothing.
#
# AppMan's per-app scripts live at
# https://github.com/ivan-hc/AM/blob/main/programs/x86_64/<app> and set
#   SITE="owner/repo"      (github-hosted apps)
#   SITE="https://website" (anything else)
# with optional SITE1/SITE2/... variants for multi-source apps.

set -euo pipefail

APP="$1"
WORK_DIR="${2:-$(mktemp -d)}"
AM_URL="https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/$APP"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# --- extract SITE from the AM install script --------------------------------
# take the first SITE= / SITE1= / SITE2= assignment found in the file
site=$(curl -fsSL --max-time 30 -A "$UA" "$AM_URL" 2>/dev/null \
    | grep -oE 'SITE[0-9]*="[^"]*"' | head -n1 \
    | sed -E 's/^SITE[0-9]*="//; s/"$//' || true)
[ -n "${site:-}" ] || { echo "no SITE found for $APP" >&2; exit 1; }
echo "SITE: $site" >&2

# Build repos (pkgforge-dev/*-AppImage, Samueru-sama/*-AppImage, ...) just
# package an app; their README image is only the packaging logo, while the
# project's own screenshots live in the UPSTREAM repo they point at. Their
# readmes use a uniform table:
#   | Latest Stable Release | Upstream URL |
#   | :---: | :---: |
#   | [Click here](https://github.com/pkgforge-dev/x/releases/latest) | [Click here](https://github.com/user/theapp) |
# The upstream link is the last one on the data row below the header.
upstream_from_readme() {
    local doc="$1" in_table="" upstream=""
    while IFS= read -r line; do
        if printf '%s' "$line" | grep -q 'Upstream URL'; then
            in_table=1
            continue
        fi
        if [ -n "$in_table" ]; then
            # skip markdown table separator rows
            printf '%s' "$line" | grep -q ':---:' && continue
            printf '%s' "$line" | grep -qE '[^]]*\]\(https?://' || continue
            upstream=$(printf '%s' "$line" | grep -oE '\[[^]]*\]\(https?://[^)]+\)' \
                | grep -oE 'https?://[^)]+' | tail -n1 || true)
            [ -n "$upstream" ] && break
        fi
    done <<<"$doc"
    printf '%s' "$upstream"
}

candidates=()
base=""
hop=0
while [ "$hop" -lt 5 ]; do
    hop=$((hop + 1))
    if [[ "$site" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
        # github repo: scrape the README
        owner=${site%/*}
        repo=${site#*/}
        for readme in README.md readme.md README.MD Readme.md readme.MD README; do
            doc=$(curl -fsSL --max-time 30 "https://raw.githubusercontent.com/$owner/$repo/HEAD/$readme" 2>/dev/null) \
                && break
        done
        if [ -z "${doc:-}" ]; then
            echo "no README for $site" >&2
            exit 1
        fi
        # repo name is a *-AppImage[-suffix] build repo: resolve the
        # upstream project and use its images instead of the packaging logo
        upstream=""
        if [[ "$repo" =~ -[Aa]pp[Ii]mage(-|$) ]]; then
            upstream=$(upstream_from_readme "$doc")
        fi
        if [ -n "$upstream" ]; then
            if [[ "$upstream" =~ ^https?://github\.com/([^/]+)/([^/#?]+) ]]; then
                site="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            else
                site="$upstream"
            fi
            echo "build repo $owner/$repo -> upstream $site" >&2
            continue
        fi
        # markdown images: ![alt](url)
        mapfile -t cands < <(printf '%s' "$doc" | grep -oE '!\[[^]]*\]\([^)]+\)' \
            | sed -E 's/^!\[[^]]*\]\(//; s/\)$//' || true)
        # html images: <img src="...">
        mapfile -t cands_html < <(printf '%s' "$doc" | grep -oE '<img[^>]+>' \
            | grep -oE 'src="[^"]+"' | sed -E 's/^src="//; s/"$//' || true)
        candidates=("${cands[@]}" "${cands_html[@]}")
        base="https://raw.githubusercontent.com/$owner/$repo/HEAD"
        break
    else
        # website: og:image + img tags from the homepage
        page=$(curl -fsSL --max-time 30 -A "$UA" "$site" 2>/dev/null) \
            || { echo "cannot fetch $site" >&2; exit 1; }
        mapfile -t cands_og < <(printf '%s' "$page" | grep -oiE '<meta[^>]+og:image[^>]*>' \
            | grep -oiE '(content|value)="[^"]+"' | sed -E 's/^[^=]+="//; s/"$//' || true)
        mapfile -t cands_img < <(printf '%s' "$page" | grep -oiE '<img[^>]+>' \
            | grep -oiE 'src="[^"]+"' | sed -E 's/^src="//; s/"$//' || true)
        candidates=("${cands_og[@]}" "${cands_img[@]}")
        base="$site"
        break
    fi
done

[ "${#candidates[@]}" -gt 0 ] || { echo "no images found in $site" >&2; exit 1; }

# --- resolve, download, pick the biggest ------------------------------------
seen=()
best=""
bestarea=0
for raw in "${candidates[@]}"; do
    raw=$(printf '%s' "$raw" | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr -d '\r')
    [ -n "$raw" ] || continue
    case "$raw" in
        data:*) continue ;;
        //*) url="https:$raw" ;;
        http://*|https://*) url="$raw" ;;
        /*) url="$base$raw" ;;
        *) url="$base/$raw" ;;
    esac
    # strip query/fragment for dedupe, keep for fetch
    key=$(printf '%s' "${url%%[?#]*}")
    case " ${seen[*]} " in *" $key "*) continue ;; esac
    seen+=("$key")
    case "$key" in
        *.svg|*.webp|*.ico|*.gif) continue ;;
    esac
    fname="$TMP/$(basename "$key")"
    curl -fsSL --max-time 30 -A "$UA" -L "$url" -o "$fname" 2>/dev/null || continue
    [ -s "$fname" ] || continue
    # image sanity: dimensions, skip tiny/broken files
    geom=$(identify -format '%w %h' "$fname" 2>/dev/null) || continue
    w=${geom%% *}; h=${geom##* }
    [ "${w:-0}" -ge 200 ] && [ "${h:-0}" -ge 200 ] || continue
    area=$((w * h))
    if [ "$area" -gt "$bestarea" ]; then
        bestarea=$area
        best="$fname"
    fi
done

[ -n "${best:-}" ] || { echo "no usable image (all failed/tiny)" >&2; exit 1; }

ext=$(identify -format '%m' "$best" 2>/dev/null | tr 'A-Z' 'a-z')
case "$ext" in png|jpeg) : ;; *) ext=png ;; esac
dest="$WORK_DIR/site-$APP.$ext"
cp -f "$best" "$dest"
echo "picked $(identify -format '%wx%h' "$dest" 2>/dev/null) image" >&2
printf '%s' "$dest"