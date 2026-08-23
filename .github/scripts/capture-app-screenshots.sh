#!/usr/bin/env bash
# Capture screenshots for catalog apps missing them and file one issue per app.
#
# Environment:
#   REPO      GitHub repo in owner/name form (default: current repo)
#   MAX_APPS  how many apps to process in this run (default: 10)
#   DELAY     seconds to wait for a window to map (default: 20)
#   SETTLE_DELAY  seconds to wait after the window maps, before capturing
#                 (default: 6) -- window mapping isn't the same as the app
#                 finishing rendering its content
#   GITHUB_STEP_SUMMARY  set by GitHub Actions (optional, for the run summary)
#
# Apps are always processed in alphabetical order, so consecutive runs retry
# the same failed apps (those that created no issue stay in the candidate
# list) until they capture or get an issue.

set -euo pipefail

REPO="${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
MAX_APPS="${MAX_APPS:-10}"
DELAY="${DELAY:-20}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${RUNNER_TEMP:-/tmp}/app-capture"
RELEASE_TAG="screenshots-captured"
# whether to look up the app author's GitHub handle and ask them about the
# screenshot in the issue (set to 0 to disable)
MENTION_AUTHOR="${MENTION_AUTHOR:-1}"
# whether to look for a Flathub screenshot to include in the issue (set to 0 to disable)
FLATHUB_SCREENSHOTS="${FLATHUB_SCREENSHOTS:-1}"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

mkdir -p "$WORK_DIR/out"
export PATH="$HOME/.local/bin:$PATH"

# Friendly runtime settings for GUI apps under a virtual display.
export APPIMAGE_EXTRACT_AND_RUN=1
export ELECTRON_DISABLE_SANDBOX=1
# Gecko (Firefox/Thunderbird-based apps like betterbird) has its own
# sandbox init, separate from Chromium's -- it doesn't read --no-sandbox
# at all, only this env var. Harmless to set for non-Gecko apps.
export MOZ_DISABLE_SANDBOX=1
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
# Mesa tries DRI3 first, which needs a real GPU device node Xvfb doesn't
# have; the fallback to DRI2/software (swrast) doesn't always happen
# cleanly on its own ("glx: failed to create drisw screen" -- pinta,
# qppcad). Forcing DRI3 off skips straight to the path Xvfb supports.
export LIBGL_DRI3_DISABLE=1
export QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-xcb}
# how long to wait after a window is found (mapped) before capturing --
# window mapping doesn't mean rendering is finished, especially for
# apps doing async content loading (QML, Electron renderer, etc.)
export SETTLE_DELAY="${SETTLE_DELAY:-12}"
# no sound hardware in CI: SDL apps (games etc.) abort at startup otherwise
export SDL_AUDIODRIVER=${SDL_AUDIODRIVER:-dummy}
# OpenAL probes ALSA on its own, independent of SDL_AUDIODRIVER -- this is
# what's behind the "ALSA lib confmisc.c..." noise in some game logs
export ALSOFT_DRIVERS=${ALSOFT_DRIVERS:-null}
# Go game engines call snd_pcm_open("default") directly (oto), bypassing
# SDL/OpenAL entirely; with no sound card on the runner that resolves to a
# missing hw:0 and the app aborts ("ALSA error at snd_pcm_open"). A null
# ALSA default device satisfies those opens while dropping all audio.
mkdir -p "$HOME/.config/alsa" 2>/dev/null || true
printf 'pcm.!default { type null }\nctl.!default { type null }\n' > "$HOME/.asoundrc"
export DISPLAY="${DISPLAY:-:99}"

# prevent appimage integration dialog
mkdir -p $HOME/.local/share/appimagekit
sudo mkdir -p /usr/share/appimagekit /etc/appimagekit
touch $HOME/.local/share/appimagekit/no_desktopintegration
sudo touch /usr/share/appimagekit/no_desktopintegration
sudo touch /etc/appimagekit/no_desktopintegration
export DESKTOPINTEGRATION="NO THANKS"

results=()
# log lines go to stderr, not stdout: capture_once is called via
# SHOT=$(capture_once ""), and any stdout from log() inside it would be
# captured into $SHOT, turning a captured png path into log noise.
log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$WORK_DIR/log.txt" >&2; }
cleanup() {
    [ -n "${WM_PID:-}" ] && kill "$WM_PID" 2>/dev/null || true
    [ -n "${XVFB_PID:-}" ] && kill "$XVFB_PID" 2>/dev/null || true
}
trap cleanup EXIT

# --- Flathub screenshot helper -----------------------------------------------
flathub_screenshot() {
    # Search Flathub for an app by name and download its first screenshot.
    # Prints the path of the downloaded image on success, or nothing.
    local app="$1" work_dir="$2"

    # Search Flathub for the app by name
    local hits
    hits=$(curl -sS --max-time 30 \
        -H 'Content-Type: application/json' \
        -d "{\"query\":\"$app\",\"filters\":[],\"hitsPerPage\":5,\"page\":1}" \
        "https://flathub.org/api/v2/search" 2>/dev/null || true)
    [ -n "$hits" ] || return 0

    # Extract the first app_id whose name or app_id matches the query
    local app_id
    app_id=$(printf '%s' "$hits" | jq -r '
        [.hits[]? | select(
            (.name | ascii_downcase | contains($APP | ascii_downcase)) or
            (.app_id | ascii_downcase | contains($APP | ascii_downcase))
         ) | .app_id][0] // empty
    ' --arg APP "$app" 2>/dev/null || true)

    [ -n "$app_id" ] || return 0

    log "flathub: $app -> $app_id"

    # Fetch app details (screenshots live in appstream)
    local details
    details=$(curl -sS --max-time 30 \
        "https://flathub.org/api/v2/appstream/$app_id" 2>/dev/null || true)
    [ -n "$details" ] || return 0

    # Extract first screenshot URL -- prefer a ~1248px wide version for
    # readable inline display; fall back to the largest available size.
    local url
    url=$(printf '%s' "$details" | jq -r '
        (.screenshots[0].sizes[] | select(.width == "1248") | .src)
        // (.screenshots[0].sizes | sort_by(.tonumber) | reverse | .[0].src)
        // empty
    ' 2>/dev/null || true)
    # Fallback: grep for known Flathub screenshot URL pattern
    [ -n "$url" ] || url=$(printf '%s' "$details" \
        | grep -oE '"src":"https://dl\.flathub\.org/media/[^"]+\.(png|jpg|jpeg|webp)"' \
        | head -n1 | sed -E 's/^"src":"//; s/"$//' || true)
    [ -n "$url" ] || return 0

    # Download the screenshot
    local fname="$work_dir/flathub-$app.png"
    if curl -fsSL --max-time 30 -o "$fname" "$url" 2>/dev/null; then
        [ -s "$fname" ] && log "flathub screenshot from $url" && printf '%s' "$fname"
    fi
}

# --- candidate selection ----------------------------------------------------
mapfile -t APPS < <(
    python3 "$SCRIPT_DIR/select-apps-missing-screenshots.py" "${GITHUB_WORKSPACE:-$PWD}/apps"
)
log "apps needing screenshots: ${#APPS[@]} (processing up to $MAX_APPS)"

# --- image hosting via a dedicated release ----------------------------------
if ! gh release view "$RELEASE_TAG" -R "$REPO" >/dev/null 2>&1; then
    gh release create "$RELEASE_TAG" -R "$REPO" \
        --latest=false --title "Auto-captured screenshots" \
        --notes "Screenshots captured automatically and referenced from screenshot-request issues." >/dev/null
fi


# --- virtual display --------------------------------------------------------
# +extension GLX is an attempt at fixing native OpenGL apps (Qt/GLX
# "Failed to finding matching FBConfig" errors) -- worth it since it's free
# if Xvfb ignores it, but unverified against a real GLX app.
Xvfb :99 -screen 0 1280x800x24 +extension GLX +render -noreset >/dev/null 2>&1 &
XVFB_PID=$!
sleep 2
# a minimal WM gives windows sane stacking/focus; harmless if absent
if command -v openbox >/dev/null 2>&1; then
    openbox >/dev/null 2>&1 &
    WM_PID=$!
fi
sleep 1

count=0
LAUNCH_PGID=0
for app in "${APPS[@]}"; do
    # skip apps that already have an open screenshot-request issue before
    # consuming a $MAX_APPS slot, so a run always processes $MAX_APPS apps
    # that actually need handling (issues already filed don't count toward
    # the limit)
    open_issues=$(gh issue list -R "$REPO" --state open \
        --search "in:title \"Screenshot for $app\"" --json number -q 'length' 2>/dev/null || echo 0)
    if [ "${open_issues:-0}" -ge 1 ]; then
        log "SKIP: 'Screenshot for $app' issue already open"
        results+=("SKIP $app (issue already open)")
        continue
    fi

    count=$((count + 1))
    if [ "$count" -gt "$MAX_APPS" ]; then
        log "[$count/$MAX_APPS] reached max, stopping"
        break
    fi
    log "===== [$count/$MAX_APPS] $app ====="

    # install via AppMan (local, no root)
    log "installing $app via appman..."
    if ! timeout 900 env appman_location="$HOME/Applications" \
        appman -y -i "$app" >"$WORK_DIR/$app.install.log" 2>&1; then
        log "install failed - last lines from $app.install.log:"
        tail -n 15 "$WORK_DIR/$app.install.log" | tee -a "$WORK_DIR/log.txt" >&2
        results+=("FAIL $app (install)")
        continue
    fi

    # locate the executable: launcher symlink first, then .desktop Exec, then app dir
    BIN=""
    if [ -x "$HOME/.local/bin/$app" ]; then
        BIN="$HOME/.local/bin/$app"
    elif [ -f "$HOME/.local/share/applications/$app-AM.desktop" ]; then
        BIN=$(grep -m1 '^Exec=' "$HOME/.local/share/applications/$app-AM.desktop" \
            | sed 's/^Exec=//; s/ *%[uUfF]//g' | tr -d '\r' | xargs)
    else
        BIN=$(find "$HOME/Applications/$app" -maxdepth 1 -type f -perm -u+x 2>/dev/null | head -n1)
    fi
    if [ -z "$BIN" ] || [ ! -x "$BIN" ]; then
        log "could not locate executable after install
  - ~/.local/bin/$app: $([ -e "$HOME/.local/bin/$app" ] && echo 'exists' || echo 'missing')"
        log "  - contents of $HOME/Applications/$app:" 
        ls -la "$HOME/Applications/$app" 2>/dev/null | tee -a "$WORK_DIR/log.txt" >&2 || true
        results+=("FAIL $app (no binary)")
        continue
    fi
    log "BIN=$BIN"

    # --- site image from the app's own website/repo (independent of capture) --
    SITE_IMG=""
    if SITE_IMG=$(timeout 80 bash "$SCRIPT_DIR/fetch-site-image.sh" "$app" "$WORK_DIR" \
        2>"$WORK_DIR/$app.site.log"); then
        if [ -s "$SITE_IMG" ]; then
            log "site image: $SITE_IMG ($(identify -format '%wx%h' "$SITE_IMG" 2>/dev/null || echo '?'))"
        else
            SITE_IMG=""
        fi
    else
        SITE_IMG=""
        log "no site image ($(tail -n1 "$WORK_DIR/$app.site.log" 2>/dev/null || echo '?') )"
    fi

    # --- launch & capture under Xvfb (plain `import`, no teasr needed) ----

    launch_app() {
        # some apps refuse to start when their config dir is missing (e.g.
        # deskthing cannot create ~/.config/<app>/logs); make it exist first
        mkdir -p "$HOME/.config/$app" 2>/dev/null || true
        setsid nohup dbus-run-session -- "$BIN" ${1:-} >"$WORK_DIR/$app.launch.log" 2>&1 &
        echo $! > "$WORK_DIR/$app.pid"
        LAUNCH_PGID=$!
    }
    stop_apps() {
        local pid child
        pid=$(cat "$WORK_DIR/$app.pid" 2>/dev/null || true)
        if [ -n "${pid:-}" ]; then
            # TERM the app itself first; killing the whole group at once also
            # takes out dbus-run-session, which makes Chromium/Electron report
            # "D-Bus connection was disconnected" FATAL spam in the launch log
            child=$(pgrep -P "$pid" 2>/dev/null | tail -n1 || true)
            [ -n "${child:-}" ] && kill "$child" 2>/dev/null || true
            sleep 1
            # setsid gives the app its own process group: kill the whole tree
            kill -- -"$pid" 2>/dev/null || true
            sleep 1
            kill -9 -- -"$pid" 2>/dev/null || true
            rm -f "$WORK_DIR/$app.pid"
        fi
        # kill any orphaned X clients left behind by a hardened app (they
        # daemonize out of our process group, keep their windows mapped, and
        # then get mistaken for the *next* app's window)
        local wid wpid
        while read -r wid size rest; do
            wpid=$(timeout 5 xprop -id "$wid" _NET_WM_PID 2>/dev/null | grep -oE '[0-9]+$')
            [ -n "${wpid:-}" ] || continue
            if [ "${wpid:-0}" -ne "${LAUNCH_PGID:-0}" ] && kill -0 "$wpid" 2>/dev/null; then
                kill -9 "$wpid" 2>/dev/null || true
            fi
        done < <(timeout 10 xwininfo -root -children 2>/dev/null \
            | grep -E '^     0x[0-9a-f]+ ' \
            | awk '{ for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+x[0-9]+\+/) { print $1, $i; break } }')
        sleep 1
    }
    capture_once() {  # $1 = extra args for the app
        rm -rf "$WORK_DIR/out"
        mkdir -p "$WORK_DIR/out"
        launch_app "${1:-}"

        # poll for the window instead of one fixed sleep: some apps (SDL
        # engines especially) take much longer than others to map their
        # window, and a fixed sleep either wastes time on fast apps or
        # misses the window entirely on slow ones. Bound by actual elapsed
        # time (not iteration count) so a slow/unresponsive X server on a
        # given app can't stall past $DELAY even with the per-call timeouts
        # inside find_main_window.
        local main_wid="" start_ts=$SECONDS
        while [ "$((SECONDS - start_ts))" -lt "$DELAY" ]; do
            main_wid=$(find_main_window)
            [ -n "$main_wid" ] && break
            sleep 1
        done
        local waited=$((SECONDS - start_ts))

        if [ -n "$main_wid" ]; then
            log "  window found after ${waited}s: $main_wid"
            timeout 5 xdotool windowsize "$main_wid" 1280 800 >/dev/null 2>&1 || \
                log "  windowsize rejected (fixed-size window)"
            log "  settling ${SETTLE_DELAY}s before capture"
            sleep "$SETTLE_DELAY"
            # capturing the window itself crops any blank space around it
        else
            log "  no window found on display after ${DELAY}s, capturing full root"
            timeout 10 xwininfo -root -tree 2>/dev/null | tail -n 15 > "$WORK_DIR/$app.tree.log" || true
        fi

        # window-targeted capture; fall back to root if it yields nothing.
        # xwd reads the X server raw XGetImage (no MIT-SHM), which import's
        # XShmGetImage path can fail with "Resource temporarily unavailable"
        # on CI runners for all windows, root included; on hosts with both,
        # try xwd first and keep import as a backup. xwd's -id only takes a
        # numeric window id, so resolve the root window's id numerically.
        ROOT_WID=$(timeout 5 xwininfo -display "$DISPLAY" -root 2>/dev/null \
            | awk '/Window id:/{print $4; exit}')
        captured=""
        for target in "${main_wid:-}" "$ROOT_WID"; do
            [ -n "$target" ] || continue
            [ -z "$captured" ] || break
            if command -v xwd >/dev/null 2>&1; then
                timeout 20 xwd -display "$DISPLAY" -silent -id "$target" \
                    -out "$WORK_DIR/out/$app.xwd" >"$WORK_DIR/$app.import.log" 2>&1 || true
                if [ -s "$WORK_DIR/out/$app.xwd" ]; then
                    convert "$WORK_DIR/out/$app.xwd" "$WORK_DIR/out/$app.png" \
                        >>"$WORK_DIR/$app.import.log" 2>&1 || true
                    rm -f "$WORK_DIR/out/$app.xwd"
                fi
            fi
            if [ ! -s "$WORK_DIR/out/$app.png" ]; then
                log "  xwd empty for ${target}, falling back to import"
                timeout 20 import -display "$DISPLAY" -window "$target" \
                    "$WORK_DIR/out/$app.png" >>"$WORK_DIR/$app.import.log" 2>&1 || true
            fi
            [ -s "$WORK_DIR/out/$app.png" ] && captured=1 || true
        done
        stop_apps
        if [ -s "$WORK_DIR/out/$app.png" ]; then
            printf '%s' "$WORK_DIR/out/$app.png"
        fi
    }

    find_main_window() {
        # largest *viewable* top-level window; prefers one owned by this
        # app's process group (if discoverable) but falls back to any
        # viewable window -- strict PID filtering rejects real apps (Qt
        # helper processes, python wrappers, zenity dialogs) without
        # _NET_WM_PID or running in a different process group. Stale
        # windows are instead killed between apps in stop_apps.
        local wid size w h area best bestarea fallback fallarea wpid pgid
        best=""; bestarea=0
        fallback=""; fallarea=0
        while read -r wid size rest; do
            w=${size%x*}; h=${size#*x}
            [ -n "${w:-}" ] && [ -n "${h:-}" ] || continue
            area=$((w * h))
            # must be mapped+viewable: xwininfo -children lists windows that
            # are not currently viewable too, and import fails on those
            timeout 5 xwininfo -id "$wid" 2>/dev/null | grep -q 'Map State: IsViewable' || continue
            # remember any viewable window as fallback
            if [ "$area" -gt "$fallarea" ]; then
                fallarea=$area
                fallback=$wid
            fi
            # tightly-scoped preference: window owned by this app's pgid
            wpid=$(timeout 5 xprop -id "$wid" _NET_WM_PID 2>/dev/null | grep -oE '[0-9]+$')
            [ -n "${wpid:-}" ] || continue
            pgid=$(ps -o pgid= -p "$wpid" 2>/dev/null | tr -d ' ')
            [ "$pgid" = "$LAUNCH_PGID" ] || continue
            if [ "$area" -gt "$bestarea" ]; then
                bestarea=$area
                best=$wid
            fi
        done < <(timeout 10 xwininfo -root -children 2>/dev/null \
            | grep -E '^     0x[0-9a-f]+ ' \
            | awk '{ for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+x[0-9]+\+/) { print $1, $i; break } }')
        printf '%s' "${best:-$fallback}"
    }

    is_blank() {
        if command -v identify >/dev/null 2>&1; then
            local colors
            colors=$(identify -format '%k' "$1" 2>/dev/null || echo 999)
            [ "${colors:-999}" -lt 16 ]
        else
            return 1
        fi
    }

    # Chromium/Electron log a distinctive message when they cannot start in
    # the sandbox; adding --no-sandbox to a GTK/Qt app would just be eaten
    # as a positional file argument (e.g. DIE's filename box), so only add
    # the flag when the app's own stderr asks for it.
    sandbox_hint() {
        grep -qi -E 'no-sandbox|suid sandbox|failed to create sandbox|sandbox helper' \
            "$WORK_DIR/$app.launch.log" 2>/dev/null || return 1
    }
    # headless Xvfb has no GPU: Chromium/Electron often abort with GPU
    # process failures -- needs --disable-gpu (and --no-sandbox too, same
    # stderr-asking-for-it rationale as above)
    gpu_hint() {
        grep -qi -E 'gpu process|gpu.*(fail|usable|crash)|vk[A-Za-z]+\(|vulkan|dri3|libOpenGL|libEGL|angle|eglinitialize' \
            "$WORK_DIR/$app.launch.log" 2>/dev/null || return 1
    }

    # first try without any flags
    SHOT=""
    SHOT_A=""
    site_url=""
    SHOT=$(capture_once "")
    if [ -z "$SHOT" ] || is_blank "$SHOT"; then
        if sandbox_hint; then
            log "sandbox error detected, retrying with --no-sandbox"
            SHOT=$(capture_once "--no-sandbox")
        elif gpu_hint; then
            log "GPU error detected, retrying with --no-sandbox --disable-gpu --disable-dev-shm-usage"
            SHOT=$(capture_once "--no-sandbox --disable-gpu --disable-dev-shm-usage")
            if [ -z "$SHOT" ] || is_blank "$SHOT"; then
                log "still failing, retrying with --use-gl=swiftshader --disable-gpu-compositing too"
                SHOT=$(capture_once "--no-sandbox --disable-gpu --disable-dev-shm-usage --use-gl=swiftshader --disable-gpu-compositing")
            fi
        else
            log "no/blank capture, retrying"
            SHOT=$(capture_once "")
        fi
    fi
    if [ -z "$SHOT" ] || [ ! -s "$SHOT" ]; then
        log "capture failed - last lines from $app.launch.log:"
        tail -n 15 "$WORK_DIR/$app.launch.log" | tee -a "$WORK_DIR/log.txt" >&2 || true
        if [ -s "$WORK_DIR/$app.import.log" ]; then
            log "import errors from $app.import.log:"
            tail -n 5 "$WORK_DIR/$app.import.log" | tee -a "$WORK_DIR/log.txt" >&2 || true
        fi
        if [ -s "$WORK_DIR/$app.tree.log" ]; then
            log "window tree when no window found:"
            cat "$WORK_DIR/$app.tree.log" | tee -a "$WORK_DIR/log.txt" >&2 || true
        fi
        if [ -n "$SITE_IMG" ]; then
            log "capture failed, falling back to site image only"
            SHOT_A="$SITE_IMG"
            SITE_IMG=""
        else
            results+=("FAIL $app (capture)")
            continue
        fi
    elif is_blank "$SHOT"; then
        log "capture looks blank, skipping ($(identify -format '%k colors' "$SHOT" 2>/dev/null || echo '?') on $SHOT)"
        if [ -n "$SITE_IMG" ]; then
            log "blank capture, falling back to site image only"
            SHOT_A="$SITE_IMG"
            SITE_IMG=""
        else
            results+=("SKIP $app (blank capture)")
            continue
        fi
    else
        SHOT_A="$SHOT"
    fi
    log "captured $SHOT_A ($(identify -format '%wx%h, %k colors' "$SHOT_A" 2>/dev/null || echo 'size?'))"

    # shrink for embedding in issues (only for real captures)
    if [ "$SHOT_A" = "$SHOT" ]; then
        convert "$SHOT_A" -resize '1280x800>' -strip "${SHOT_A}.small.png" 2>&1 | tee -a "$WORK_DIR/log.txt" >&2 || true
        mv -f "${SHOT_A}.small.png" "$SHOT_A" 2>/dev/null || true
    fi

    if ! gh release upload "$RELEASE_TAG" "$SHOT_A" -R "$REPO" --clobber >/dev/null 2>&1; then
        log "release upload failed for $SHOT_A"
        results+=("FAIL $app (upload)")
        continue
    fi
    img_url="https://github.com/$REPO/releases/download/$RELEASE_TAG/$(basename "$SHOT_A")"

    if [ -n "$SITE_IMG" ]; then
        if ! gh release upload "$RELEASE_TAG" "$SITE_IMG" -R "$REPO" --clobber >/dev/null 2>&1; then
            log "release upload failed for site image $SITE_IMG"
        else
            site_url="https://github.com/$REPO/releases/download/$RELEASE_TAG/$(basename "$SITE_IMG")"
        fi
    fi

    # --- Flathub screenshot (for comparison in the issue) ----------------------
    FLATHUB_SHOT=""
    if [ "$FLATHUB_SCREENSHOTS" = "1" ]; then
        if FLATHUB_SHOT=$(flathub_screenshot "$app" "$WORK_DIR"); then
            if [ -n "$FLATHUB_SHOT" ] && [ -s "$FLATHUB_SHOT" ]; then
                log "flathub screenshot: $FLATHUB_SHOT ($(identify -format '%wx%h' "$FLATHUB_SHOT" 2>/dev/null || echo '?'))"
            else
                FLATHUB_SHOT=""
            fi
        else
            FLATHUB_SHOT=""
        fi
    fi

    if [ -n "$FLATHUB_SHOT" ]; then
        if gh release upload "$RELEASE_TAG" "$FLATHUB_SHOT" -R "$REPO" --clobber >/dev/null 2>&1; then
            flathub_url="https://github.com/$REPO/releases/download/$RELEASE_TAG/$(basename "$FLATHUB_SHOT")"
        fi
    fi

    # find the app author's GitHub handle (to ask about the screenshot) --
    # the AM install script's SITE= value is "owner/repo" for github-hosted
    # apps; repos whose name ends in -appimage (e.g. pkgforge-dev/*-AppImage)
    # only *package* the app, so resolve their README's "Upstream URL" to the
    # real project and use the owner only when that upstream is a GitHub repo.
    author=""
    if [ "$MENTION_AUTHOR" = "1" ]; then
        site=$(curl -fsSL --max-time 30 -A "$UA" \
            "https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/$app" 2>/dev/null \
            | grep -oE 'SITE[0-9]*="[^"]*"' | head -n1 \
            | sed -E 's/^SITE[0-9]*="//; s/"$//' || true)
        if [[ "$site" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
            owner=${site%/*}
            repo=${site#*/}
            if [[ "$repo" =~ -[Aa]pp[Ii]mage(-|$) ]]; then
                # packaging repo: its README lists the real project under an
                # "Upstream URL" table header. Take the first canonical
                # github.com/<owner>/<repo> root link after that header whose
                # repo name matches the app (case-insensitive). The packaging
                # repo's own /releases/... links appear in the same table, so
                # links with a path after the repo name are skipped.
                # Splitting the readme on '|' puts every table cell on its
                # own line, so one github link per line is guaranteed.
                app_lc=$(printf '%s' "$app" | tr 'A-Z' 'a-z')
                upstream=""
                while IFS= read -r line; do
                    [ -n "$upstream" ] && break
                    if [ -z "${in_table:-}" ]; then
                        printf '%s' "$line" | grep -qi 'upstream' && in_table=1
                        continue
                    fi
                    printf '%s' "$line" | grep -q ':---:' && continue
                    if [[ "$line" =~ github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+) ]]; then
                        # snapshot before any other =~ test: a failed regex
                        # match unsets BASH_REMATCH
                        gh_owner="${BASH_REMATCH[1]}"
                        gh_repo="${BASH_REMATCH[2]}"
                        rest="${line#*${BASH_REMATCH[0]}}"
                        [[ "$rest" =~ ^/[^[:space:]]* ]] && continue
                        gh_repo_lc=$(printf '%s' "$gh_repo" | tr 'A-Z' 'a-z')
                        if [[ "$gh_repo_lc" == *"$app_lc"* ]] || [[ "$app_lc" == *"$gh_repo_lc"* ]]; then
                            upstream="$gh_owner/$gh_repo"
                        fi
                    fi
                done < <(curl -fsSL --max-time 30 \
                    "https://raw.githubusercontent.com/$owner/$repo/HEAD/README.md" 2>/dev/null \
                    | tr '|' '\n' || true)
                if [ -n "$upstream" ]; then
                    author="${upstream%/*}"
                    log "author of $app (upstream of $owner/$repo): @$author"
                fi
            else
                author="$owner"
                log "author of $app: @$author"
            fi
        fi
    fi

    # build the issue body; embed whatever images we have
    {
        cat <<EOF
This issue was opened automatically for **$app**, which is missing a screenshot
in the catalog.

EOF
        # build image block with whatever screenshots we have
        imgs=""
        imgs+="![captured screenshot of $app]($img_url)\n\n"
        if [ -n "$SITE_IMG" ] && [ -n "${site_url:-}" ]; then
            imgs+="![site image of $app]($site_url)\n\n"
        fi
        if [ -n "$FLATHUB_SHOT" ] && [ -n "${flathub_url:-}" ]; then
            imgs+="![Flathub screenshot of $app]($flathub_url)\n\n"
        fi
        printf '%b' "$imgs"
        if [ -n "$author" ]; then
            cat <<EOF
@${author}, as the author of **$app**: is/are the screenshot(s) above okay to add to
the catalog? Let me know if you'd like it removed or replaced.

EOF
        fi
        cat <<'EOF'
**Checklist**
- [ ] review the screenshot(s) above
- [ ] add the best one to the _SCREENSHOTS_ line for this app in the catalog
- [ ] close this issue when done

EOF
    } > "$WORK_DIR/$app.body.md"

    if gh issue create -R "$REPO" --title "Screenshot for $app" \
        --body-file "$WORK_DIR/$app.body.md" >"$WORK_DIR/$app.issue.log" 2>&1; then
        result_line=$(tail -n1 "$WORK_DIR/$app.issue.log")
        log "issue created: $result_line"
        results+=("OK $app")
    else
        log "issue creation failed: $(tail -n3 "$WORK_DIR/$app.issue.log")"
        results+=("FAIL $app (issue)")
    fi

    # uninstall to free disk space on the runner
    log "uninstalling $app..."
    appman -R "$app" >"$WORK_DIR/$app.uninstall.log" 2>&1 || true
    # remove app temp folders in /tmp/ (Electron, Qt, etc.)
    sudo rm -rf /tmp/*"$app"* 2>/dev/null || true
    sudo rm -rf "$HOME/.config/$app" 2>/dev/null || true
done

# --- run summary -------------------------------------------------------------
{ echo ""
  echo "## Screenshot capture results"
  echo ""
  echo "| result |"
  echo "|---|"
  printf '| %s |\n' "${results[@]:-(no results)}"
  echo ""
  echo "Logs: ${GITHUB_SERVER_URL:-github.com}/$REPO/actions/runs/${GITHUB_RUN_ID:-this run}"
} >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
printf '%s\n' "${results[@]:-(no results)}"
