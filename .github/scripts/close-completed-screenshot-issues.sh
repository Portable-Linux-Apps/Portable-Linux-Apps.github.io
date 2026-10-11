#!/usr/bin/env bash
# close-completed-screenshot-issues.sh — close "Screenshot for <app>" issues whose
# app now has a real screenshot in the catalog.
#
# Companion to capture-app-screenshots.sh: that script files one issue per app
# missing a screenshot, this one closes the ones that have been resolved. An app
# counts as resolved when apps/<app> on the default branch has a non-empty
# `# SCREENSHOTS:` line that is not the `contribute_ss.webp` placeholder — the
# exact same test select-apps-missing-screenshots.py uses to pick candidates, so
# an issue is closed precisely when the app would no longer be a candidate.
#
# Environment:
#   REPO       GitHub repo in owner/name form (default: current repo)
#   MAX_ISSUES how many open issues to consider (default: 0 = all)
#   DRY_RUN    1 to report what would be closed without touching anything
#   GITHUB_STEP_SUMMARY  set by GitHub Actions (optional, for the run summary)
#
# Exit codes:
#   0  nothing left to close, or dry run completed
#   1  at least one issue could not be commented on / closed
#   2  bad usage / missing dependency

set -uo pipefail

# ---------------------------------------------------------------- defaults
REPO="${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
MAX_ISSUES="${MAX_ISSUES:-0}"
DRY_RUN="${DRY_RUN:-0}"
# every "Screenshot for <app>" issue filed by capture-app-screenshots.sh
TITLE_PREFIX="Screenshot for "

command -v gh >/dev/null 2>&1 || { echo "gh CLI is required" >&2; exit 2; }

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# catalog app IDs are file names, but the title comes from issue text, so it is
# validated before being interpolated into an API path: no slashes, no "..".
valid_app_name() {
    [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]*$ ]] && [[ "$1" != *".."* ]]
}

# Echo the app's `# SCREENSHOTS:` value on the default branch, or nothing when
# the entry is missing, the line is absent/empty, or it still holds the
# placeholder. Fetched through the contents API so the answer always reflects
# the default branch, not whatever ref this run happens to be on.
catalog_screenshots() {
    local app="$1" file="$WORK_DIR/$app.app"
    gh api -H 'Accept: application/vnd.github.raw' \
        "repos/$REPO/contents/apps/$app" >"$file" 2>/dev/null || return 1
    sed -n -E 's/^#[[:space:]]*SCREENSHOTS[[:space:]]*:[[:space:]]*(.*[^[:space:]])?[[:space:]]*$/\1/p' \
        "$file" | head -n1
}

has_real_screenshot() {
    local value="$1"
    [ -n "$value" ] || return 1
    printf '%s' "$value" | grep -qi 'contribute_ss' && return 1
    return 0
}

# ---------------------------------------------------------------- collect
limit=1000
if [ "$MAX_ISSUES" -gt 0 ] 2>/dev/null; then
    limit="$MAX_ISSUES"
fi

log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$WORK_DIR/log.txt" >&2; }

log "looking for open '${TITLE_PREFIX}<app>' issues in $REPO (limit $limit)"

issues=$(gh issue list -R "$REPO" --state open --limit "$limit" \
    --search "\"$TITLE_PREFIX\" in:title" \
    --json number,title,url 2>/dev/null) || issues=""
if [ -z "$issues" ]; then
    log "no matching open issues (or the listing failed) — nothing to do"
    {
        echo ""
        echo "## Screenshot issues"
        echo ""
        echo "No open \`$TITLE_PREFIX<app>\` issues found."
    } >>"${GITHUB_STEP_SUMMARY:-/dev/null}"
    exit 0
fi

total=$(printf '%s' "$issues" | jq 'length')
log "found $total open screenshot issue(s)"

# ---------------------------------------------------------------- sweep
results=()
closed=0
already=0
skipped=0
failed=0

for row in $(printf '%s' "$issues" | jq -r '.[] | @base64'); do
    number=$(printf '%s' "$row" | base64 -d | jq -r '.number')
    title=$(printf '%s' "$row" | base64 -d | jq -r '.title')
    url=$(printf '%s' "$row" | base64 -d | jq -r '.url')

    # exact prefix match: the search is a substring one, so it also returns
    # titles like "Screenshot for foo (take 2)" or "Re: Screenshot for foo"
    app=${title#"$TITLE_PREFIX"}
    if [ "$app" = "$title" ] || ! valid_app_name "$app"; then
        log "SKIP #$number: '$title' is not a plain '$TITLE_PREFIX<app>' title"
        results+=("SKIP #$number ($title) — unrecognised title")
        skipped=$((skipped + 1))
        continue
    fi

    if ! value=$(catalog_screenshots "$app"); then
        log "SKIP #$number: no catalog entry apps/$app (app removed from the catalog?)"
        results+=("SKIP #$number ($app) — no catalog entry")
        skipped=$((skipped + 1))
        continue
    fi

    if ! has_real_screenshot "$value"; then
        log "SKIP #$number: $app still has no screenshot (SCREENSHOTS: '${value:-<empty>}')"
        results+=("OPEN #$number ($app) — still missing a screenshot")
        already=$((already + 1))
        continue
    fi

    log "READY #$number: $app has screenshots ($value)"

    if [ "$DRY_RUN" = "1" ]; then
        results+=("WOULD CLOSE #$number ($app)")
        closed=$((closed + 1))
        continue
    fi

    # Comment first: if the close fails, the issue still carries the evidence
    # that the app is done, and a re-run finds the issue still open.
    body="$WORK_DIR/$number.comment.md"
    {
        cat <<EOF
**Resolved automatically.** \`apps/$app\` now has a screenshot in the catalog:

\`\`\`
# SCREENSHOTS: $value
\`\`\`

Closing this issue as completed.
EOF
    } >"$body"

    if ! gh issue comment "$number" -R "$REPO" --body-file "$body" >/dev/null 2>&1; then
        log "could not comment on #$number"
        echo "::error::could not comment on #$number ($app)"
        results+=("FAIL #$number ($app) — comment failed")
        failed=$((failed + 1))
        continue
    fi

    # state-reason completed: "not planned" would read as the request being
    # rejected rather than fulfilled.
    if gh issue close "$number" -R "$REPO" --reason completed >/dev/null 2>&1; then
        log "closed #$number ($app)"
        results+=("CLOSED #$number ($app)")
        closed=$((closed + 1))
    else
        log "could not close #$number"
        echo "::error::could not close #$number ($app)"
        results+=("FAIL #$number ($app) — close failed")
        failed=$((failed + 1))
    fi
done

# ---------------------------------------------------------------- summary
{
    echo ""
    echo "## Screenshot issues"
    echo ""
    if [ "$DRY_RUN" = "1" ]; then
        echo "Dry run — ${closed} issue(s) would be closed, nothing was modified."
    else
        echo "Closed **$closed**, still missing a screenshot: **$already**, skipped: **$skipped**, failed: **$failed**."
    fi
    echo ""
    echo "| issue |"
    echo "|---|"
    printf '| %s |\n' "${results[@]:-(nothing to do)}"
    echo ""
    echo "Run: ${GITHUB_SERVER_URL:-github.com}/$REPO/actions/runs/${GITHUB_RUN_ID:-local}"
} >>"${GITHUB_STEP_SUMMARY:-/dev/null}"

printf '%s\n' "${results[@]:-(nothing to do)}"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0