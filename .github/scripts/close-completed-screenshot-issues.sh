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
# Three buckets, because only one of them is the answer to "what did this run
# do": ready (closed or about to be closed), fails (needs a rerun/attention) and
# rest (touched nothing -- still waiting on the app author). The summary shows
# the first two and folds the third away, so a sweep over hundreds of open
# issues does not bury the handful that actually got closed.
ready=()
fails=()
rest=()
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
        rest+=("SKIP #$number ($title) — unrecognised title")
        skipped=$((skipped + 1))
        continue
    fi

    if ! value=$(catalog_screenshots "$app"); then
        log "SKIP #$number: no catalog entry apps/$app (app removed from the catalog?)"
        rest+=("SKIP #$number ($app) — no catalog entry")
        skipped=$((skipped + 1))
        continue
    fi

    if ! has_real_screenshot "$value"; then
        log "SKIP #$number: $app still has no screenshot (SCREENSHOTS: '${value:-<empty>}')"
        rest+=("OPEN #$number ($app) — still missing a screenshot")
        already=$((already + 1))
        continue
    fi

    log "READY #$number: $app has screenshots ($value)"

    if [ "$DRY_RUN" = "1" ]; then
        ready+=("WOULD CLOSE #$number ($app)")
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
        fails+=("FAIL #$number ($app) — comment failed")
        failed=$((failed + 1))
        continue
    fi

    # state-reason completed: "not planned" would read as the request being
    # rejected rather than fulfilled.
    if gh issue close "$number" -R "$REPO" --reason completed >/dev/null 2>&1; then
        log "closed #$number ($app)"
        ready+=("CLOSED #$number ($app)")
        closed=$((closed + 1))
    else
        log "could not close #$number"
        echo "::error::could not close #$number ($app)"
        fails+=("FAIL #$number ($app) — close failed")
        failed=$((failed + 1))
    fi
done

# ---------------------------------------------------------------- summary
# Only what this run changed is listed up front. The issues that are still open
# because their app has no screenshot yet are the normal case, not news, so they
# go into a collapsed section instead of a table of their own -- a dry run over
# 500 open issues then reads as "nothing to close" plus a count.
{
    echo ""
    echo "## Screenshot issues"
    echo ""
    if [ "$DRY_RUN" = "1" ]; then
        echo "Checked $total open issue(s) — **$closed would be closed**, nothing was modified."
    else
        echo "Checked $total open issue(s) — **$closed closed**, $failed failed."
    fi
    echo ""

    if [ "${#ready[@]}" -gt 0 ]; then
        if [ "$DRY_RUN" = "1" ]; then
            echo "### Would be closed"
        else
            echo "### Closed"
        fi
        echo ""
        echo "| issue |"
        echo "|---|"
        printf '| %s |\n' "${ready[@]}"
        echo ""
    else
        # only claim there is nothing to do when nothing failed either: an empty
        # closed-table next to a failure table would read as "nothing to close"
        if [ "${#fails[@]}" -eq 0 ]; then
            echo "Nothing to close: every open issue's app still has no screenshot."
            echo ""
        fi
    fi

    if [ "${#fails[@]}" -gt 0 ]; then
        echo "### Failed (left open)"
        echo ""
        echo "| issue |"
        echo "|---|"
        printf '| %s |\n' "${fails[@]}"
        echo ""
    fi

    if [ "${#rest[@]}" -gt 0 ]; then
        echo "<details>"
        echo "<summary>$((already + skipped)) issue(s) left open ($already still missing a screenshot, $skipped skipped)</summary>"
        echo ""
        echo "| issue |"
        echo "|---|"
        printf '| %s |\n' "${rest[@]}"
        echo ""
        echo "</details>"
        echo ""
    fi

    echo "Run: ${GITHUB_SERVER_URL:-github.com}/$REPO/actions/runs/${GITHUB_RUN_ID:-local}"
} >>"${GITHUB_STEP_SUMMARY:-/dev/null}"

# console output mirrors the summary: candidates and failures, not the backlog
printf '%s\n' "${ready[@]:-}" "${fails[@]:-}" | grep -v '^$' || echo "(nothing to do)"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0