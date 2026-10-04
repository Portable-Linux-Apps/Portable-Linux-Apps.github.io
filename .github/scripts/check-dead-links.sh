#!/usr/bin/env bash
# check-dead-links.sh — report dead links across every link-bearing text file
# of the site repository.
#
# Usage:
#   .github/scripts/check-dead-links.sh [options] [file ...]
#
# With no file arguments every tracked text file is scanned:
#   * apps/<app>            the # SCREENSHOTS / # SITES / # SOURCES / # BUTTONS
#                           fields (BUTTONS entries are written "Label::url")
#   * *.in *.md *.html *.toml *.yml *.json *.xml *.css *.js *.txt LICENSE
#                           page templates, docs, styles and scripts
#
# Generated translation catalogues (*.po, *.pot) are skipped: gettext hard-wraps
# their msgid lines, which splits URLs into fragments that all look broken.
#
# Binary assets, editor backups ("*~"), the generated build output (public/),
# the caches (.cache/) and the example file apps/.template are never scanned.
#
# Options:
#   -j, --jobs N          parallel checks           (default: 12)
#   -t, --timeout SEC     per-request timeout       (default: 20)
#   -r, --retries N       retries for flaky hosts   (default: 2)
#   -c, --changed REF     only files changed against REF (e.g. origin/main)
#       --all             ignore --changed, check every file
#       --external-only   skip links to this site's own domain (site_url in
#                         pla-site.toml); useful before a deploy, when the
#                         pages a change refers to do not exist yet
#       --report FILE     write a Markdown report to FILE
#       --max-rows N      dead rows in the report   (default: 300)
#       --annotations     also emit GitHub ::error workflow commands
#   -q, --quiet           print only progress and the verdict
#   -h, --help            show this help
#
# A URL counts as DEAD only on conclusive evidence: 400, 404, 410 or 451.
# Everything else (timeout, 403 bot-block, 429 rate-limit, 5xx) is reported as
# UNVERIFIED and never fails the run, so a flaky host cannot turn CI red.
#
# Exit codes:
#   0  no dead links
#   1  at least one dead link
#   2  bad usage / missing dependency

set -uo pipefail

# ---------------------------------------------------------------- defaults
JOBS="${JOBS:-12}"
TIMEOUT="${TIMEOUT:-20}"
RETRIES="${RETRIES:-2}"
UA="${CHECK_UA:-Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36}"

# URLs that must never be reported:
#  * placeholder hosts used in templates and docs (apps/.template, CONTRIBUTING)
#  * placeholder owners such as github.com/name/...
#  * raw.githubusercontent.com branch roots, which are directories: raw cannot
#    serve them, they always answer 404/400. These are base URLs such as the
#    am_repo value in pla-site.toml, not fetchable resources.
SKIP_URL_RE='^https?://(someapp\.io|example\.(com|org|net)|localhost|127\.0\.0\.1|0\.0\.0\.0|pla-site-tool)(/|$)|^https?://github\.com/(name|your-[a-z-]*|username|user-name)/|^https?://raw\.githubusercontent\.com/(.*/$|[^/]+/[^/]+/(main|master|HEAD|trunk)/?$)'

# Endpoints that answer a GET but are not documents: API roots and POST-only
# services. They are meaningful in scripts but there is nothing to fetch.
SKIP_URL_RE="$SKIP_URL_RE"'|^https?://api\.[a-z0-9.-]+/|^https?://[a-z0-9.-]*indexnow[a-z0-9.-]*/'

# Substituted template variables such as $LANG or $APP_NAME in the *.in page
# templates. They are placeholders until pla-site-tool renders the site, so
# they cannot be requested as they stand.

die() { printf 'Error: %s\n' "$*" >&2; exit 2; }

# ------------------------------------------------------------- single probe
# HEAD first; if the host dislikes HEAD or hides behind a WAF, redo it as a
# ranged GET so we do not mistake a bot-block for a missing file.
http_code() {
    local url="$1" code
    code="$(curl -sS -L --max-redirs 10 --max-time "$TIMEOUT" -A "$UA" \
        -o /dev/null -w '%{http_code}' -I "$url" 2>/dev/null)" || code=000
    case "$code" in
        000|400|403|405|501)
            # A ranged GET proves whether HEAD was simply refused.
            code="$(curl -sS -L --max-redirs 10 --max-time "$TIMEOUT" -A "$UA" \
                -r 0-0 -o /dev/null -w '%{http_code}' "$url" 2>/dev/null)" || code=000
            ;;
    esac
    printf '%s' "$code"
}

probe() {
    local url="$1" code attempt=0 max
    max=$((RETRIES + 1))
    while [ "$attempt" -lt "$max" ]; do
        attempt=$((attempt + 1))
        code="$(http_code "$url")"
        case "$code" in
            2??|3??) break ;;                     # alive: settled
            429|5??|000) ;;                      # transient: try again
            *) break ;;                         # any other 4xx is an answer
        esac
        [ "$attempt" -lt "$max" ] && sleep $((attempt * 2))
    done

    case "$code" in
        400|404|410|451) printf 'dead\t%s\n' "$url" ;;
        2??|3??)         printf 'ok\t%s\n' "$url" ;;
        *)               printf 'unverified\t%s\n' "$url" ;;
    esac
}

# Internal mode used by the worker pool: check exactly one URL.
if [ "${1:-}" = "_probe" ]; then
    shift
    [ $# -eq 1 ] || exit 2
    probe "$1"
    exit 0
fi

# --------------------------------------------------------------- the options
JOBS=12; TIMEOUT=20; RETRIES=2
REPORT=""
MAX_ROWS=300
ANNOTATIONS=0
QUIET=0
CHANGED_REF=""
EXTERNAL_ONLY=0
declare -a TARGETS=()

usage() { sed -n '2,42p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; }

while [ $# -gt 0 ]; do
    case "$1" in
        -j|--jobs)     JOBS="${2:?--jobs needs a number}"; shift 2 ;;
        -t|--timeout)  TIMEOUT="${2:?--timeout needs seconds}"; shift 2 ;;
        -r|--retries)  RETRIES="${2:?--retries needs a number}"; shift 2 ;;
        -c|--changed)  CHANGED_REF="${2:?--changed needs a ref}"; shift 2 ;;
        --all)         CHANGED_REF=""; shift ;;
        --external-only) EXTERNAL_ONLY=1; shift ;;
        --report)      REPORT="${2:?--report needs a path}"; shift 2 ;;
        --max-rows)    MAX_ROWS="${2:?--max-rows needs a number}"; shift 2 ;;
        --annotations) ANNOTATIONS=1; shift ;;
        -q|--quiet)    QUIET=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        -*)            die "unknown option: $1" ;;
        *)             TARGETS+=("$1"); shift ;;
    esac
done

command -v curl >/dev/null 2>&1 || die "curl is required"
[[ "$JOBS" =~ ^[0-9]+$ ]] && [ "$JOBS" -ge 1 ] || die "--jobs must be a positive integer"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
REPO_DIR="${REPO_DIR:-$(git -C "$SCRIPT_DIR/../.." rev-parse --show-toplevel 2>/dev/null || pwd)}"
[ -d "$REPO_DIR" ] || die "repository directory not found: $REPO_DIR"
cd "$REPO_DIR" || die "cannot enter $REPO_DIR"

# Our own domain, used by --external-only. Links pointing at the deployed site
# cannot be validated before a deploy, so pull request runs skip them; the
# scheduled full run does check them, once the site is actually live.
SELF_HOST="${SITE_URL:-$(sed -n 's/^site_url[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' \
    pla-site.toml 2>/dev/null | head -n1)}"
SELF_HOST="${SELF_HOST%/}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FOUND="$TMP/found.tsv"       # url <TAB> file <TAB> field
TODO="$TMP/todo.txt"         # distinct urls, one per line
RESULTS="$TMP/results.tsv"   # status <TAB> url

# ------------------------------------------------------------ file selection
pick_files() {
    if [ ${#TARGETS[@]} -gt 0 ]; then
        printf '%s\n' "${TARGETS[@]}"
        return
    fi
    if [ -n "$CHANGED_REF" ]; then
        local base
        base="$(git merge-base HEAD "$CHANGED_REF" 2>/dev/null)" || base="$(git rev-parse HEAD)"
        # committed range plus anything still uncommitted, so the flag is
        # useful locally too and not only inside CI
        {
            git diff --name-only --diff-filter=ACMR "$base"...HEAD 2>/dev/null
            git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null
            git diff --name-only --diff-filter=ACMR --cached HEAD 2>/dev/null
        } | sort -u
        return
    fi
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git ls-files
    else
        find . -type f -not -path './.git/*' -not -path './.cache/*' \
            -not -path './public/*' -not -path './node_modules/*' -not -name '*~'
    fi
}

is_scannable() {
    case "$1" in
        *'~') return 1 ;;                        # editor backups
        .cache/*|public/*|node_modules/*) return 1 ;;
        apps/.template|*/.template) return 1 ;;  # placeholder urls
        *.png|*.webp|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.cast|*.woff|*.woff2|\
        *.ttf|*.otf|*.mp4|*.webm|*.zip|*.bin) return 1 ;;
        apps/*) return 0 ;;                      # app files have no extension
        *.in|*.md|*.html|*.htm|*.toml|*.yml|*.yaml|*.json|*.xml|*.css|*.js|\
        *.mjs|*.txt) return 0 ;;
        # .po/.pot are skipped on purpose: gettext hard-wraps msgid lines, so
        # URLs are split mid-string and every wrapped one looks broken. They
        # are generated from the .in templates that are scanned instead.
        LICENSE|*/LICENSE) return 0 ;;
        *) return 1 ;;
    esac
}

# ------------------------------------------------------------ url extraction
# Emits "url<TAB>file<TAB>field" for every checkable link in one file.
extract_urls() {
    local file="$1" line field url

    if [ "${file#apps/}" != "$file" ]; then
        while IFS= read -r line; do
            field="${line%%:*}"
            case "$field" in
                '# SCREENSHOTS'|'# SITES'|'# SOURCES'|'# BUTTONS') ;;
                *) continue ;;
            esac
            field="${field#\# }"
            for url in ${line#*: }; do
                url="${url##*::}"                  # BUTTONS: Label::url
                url="${url%,}"; url="${url%;}"
                case "$url" in
                    http://*|https://*) printf '%s\t%s\t%s\n' "$url" "$file" "$field" ;;
                esac
            done
        done < "$file"
        return
    fi

    grep -oE 'https?://[^][<>"'"'"'`[:space:],;(){}]+' "$file" 2>/dev/null \
    | sed -e 's/[.!?:]*$//' \
    | while IFS= read -r url; do
        # Shell case patterns (http://*|https://*) and similar globs are code,
        # not links.
        case "$url" in
            *'*'*|*'<'*|*'>'*|*'|'*|*'$'*|*';'*) continue ;;
        esac
        printf '%s\t%s\t%s\n' "$url" "$file" '-'
    done
}

collect() {
    local file url
    : > "$FOUND"
    while IFS= read -r file; do
        [ -n "$file" ] || continue
        is_scannable "$file" || continue
        [ -f "$file" ] || continue
        while IFS=$'\t' read -r url file_field field; do
            [[ "$url" =~ $SKIP_URL_RE ]] && continue
            case "$url" in *'$'*|*'{{'*|*'}}'*) continue ;; esac
            if [ "$EXTERNAL_ONLY" -eq 1 ]; then
                case "$url" in "$SELF_HOST"/*|"$SELF_HOST") continue ;; esac
            fi
            printf '%s\t%s\t%s\n' "$url" "$file_field" "$field" >> "$FOUND"
        done < <(extract_urls "$file")
    done < <(pick_files)
    cut -f1 "$FOUND" | sort -u > "$TODO"
}

# --------------------------------------------------------------------- main
collect

TOTAL_URLS=$(wc -l < "$TODO" | tr -d ' ')
TOTAL_FILES=$(cut -f2 "$FOUND" | sort -u | wc -l | tr -d ' ')

write_empty_report() {
    [ -n "$REPORT" ] || return 0
    {
        echo "# Dead link check"
        echo
        echo "| | |"
        echo "|---|---|"
        echo "| files scanned | $TOTAL_FILES |"
        echo "| urls checked | $TOTAL_URLS |"
        echo "| **dead** | **0** |"
        echo
        echo "No links found to check."
    } > "$REPORT"
}

if [ "$TOTAL_URLS" -eq 0 ]; then
    [ "$QUIET" -eq 1 ] || echo "No links found to check."
    write_empty_report
    exit 0
fi

if [ "$QUIET" -eq 1 ]; then
    printf 'checking %s urls from %s files with %s jobs...\n' "$TOTAL_URLS" "$TOTAL_FILES" "$JOBS"
else
    printf 'checking %s distinct urls from %s files (%s parallel jobs)\n' \
        "$TOTAL_URLS" "$TOTAL_FILES" "$JOBS"
fi

: > "$RESULTS"
xargs -P "$JOBS" -I '{}' "$SCRIPT_PATH" _probe '{}' < "$TODO" >> "$RESULTS" 2>/dev/null

declare -A STATUS
while IFS=$'\t' read -r st url; do
    [ -n "$url" ] && STATUS["$url"]="$st"
done < "$RESULTS"

DEAD_COUNT=$(grep -c '^dead' "$RESULTS" || true)
UNVERIFIED_COUNT=$(grep -c '^unverified' "$RESULTS" || true)
OK_COUNT=$(grep -c '^ok' "$RESULTS" || true)

# --------------------------------------------------------------- the report
if [ -n "$REPORT" ]; then
    {
        echo "# Dead link check"
        echo
        echo "| | |"
        echo "|---|---|"
        echo "| files scanned | $TOTAL_FILES |"
        echo "| urls checked | $TOTAL_URLS |"
        echo "| alive | $OK_COUNT |"
        echo "| **dead** | **$DEAD_COUNT** |"
        echo "| unverified (timeout, 403, 429, 5xx) | $UNVERIFIED_COUNT |"
        echo
        if [ "$DEAD_COUNT" -gt 0 ]; then
            echo "## Dead links ($DEAD_COUNT)"
            echo
            echo "| file | field | url |"
            echo "|---|---|---|"
            shown=0
            while IFS=$'\t' read -r url file field; do
                [ "${STATUS[$url]:-}" = dead ] || continue
                [ "$shown" -ge "$MAX_ROWS" ] && break
                printf '| `%s` | %s | %s |\n' "$file" "$field" "$url"
                shown=$((shown + 1))
            done < "$FOUND"
            if [ "$shown" -lt "$DEAD_COUNT" ]; then
                echo
                echo "_...and $((DEAD_COUNT - shown)) more, see the job artifact for the full list._"
            fi
            echo
        else
            echo "## Dead links"
            echo
            echo "None."
            echo
        fi
        if [ "$UNVERIFIED_COUNT" -gt 0 ]; then
            echo "## Unverified ($UNVERIFIED_COUNT)"
            echo
            echo "No conclusive status, so these are **not** counted as dead."
            echo
            echo "| url |"
            echo "|---|"
            grep '^unverified' "$RESULTS" | head -n 50 | cut -f2 | sed 's/^/| /; s/$/ |/'
            echo
        fi
    } > "$REPORT"
fi

# ------------------------------------------------- console + GH annotations
if [ "$ANNOTATIONS" -eq 1 ] && [ -n "${GITHUB_ACTIONS:-}" ]; then
    declare -A annotated=()
    while IFS=$'\t' read -r url file field; do
        [ "${STATUS[$url]:-}" = dead ] || continue
        [ -n "${annotated[$url]:-}" ] && continue
        annotated[$url]=1
        printf '::error file=%s,title=Dead link in %s::%s\n' "$file" "$field" "$url"
    done < "$FOUND"
fi

if [ "$QUIET" -eq 1 ]; then
    printf 'dead: %s, unverified: %s, alive: %s\n' "$DEAD_COUNT" "$UNVERIFIED_COUNT" "$OK_COUNT"
elif [ "$DEAD_COUNT" -eq 0 ]; then
    echo "no dead links ($OK_COUNT alive, $UNVERIFIED_COUNT unverified)"
else
    echo
    echo "dead links ($DEAD_COUNT):"
    while IFS=$'\t' read -r url file field; do
        [ "${STATUS[$url]:-}" = dead ] || continue
        printf '  %-30s %-11s %s\n' "$file" "$field" "$url"
    done < "$FOUND"
    echo
    echo "unverified: $UNVERIFIED_COUNT (not counted as dead)"
fi

[ "$DEAD_COUNT" -eq 0 ] || exit 1
exit 0