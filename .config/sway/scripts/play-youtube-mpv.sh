#!/usr/bin/env bash
set -euo pipefail

log_file="/tmp/play-youtube-mpv.log"
yt_dlp_cmd="${HOME}/.virtualenvs/python3/bin/yt-dlp"

notify() {
    local message="$1"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "play-youtube-mpv" "${message}"
    fi

    printf '%s\n' "${message}" >&2
}

require() {
    if ! command -v "$1" >/dev/null 2>&1; then
        notify "Missing dependency: $1"
        exit 1
    fi
}

resolve_yt_dlp() {
    if [ -x "${yt_dlp_cmd}" ]; then
        printf '%s\n' "${yt_dlp_cmd}"
        return
    fi

    if command -v yt-dlp >/dev/null 2>&1; then
        command -v yt-dlp
        return
    fi

    notify "Missing dependency: yt-dlp"
    exit 1
}

prompt_text() {
    local prompt="$1"
    printf '' | rofi -dmenu -i -p "${prompt}" -theme-str 'listview { enabled: false; }'
}

prompt_menu() {
    local prompt="$1"
    rofi -dmenu -i -p "${prompt}"
}

format_menu_entries() {
    jq -r '
        . as $video
        | ["bestvideo+bestaudio/best", "Best available"] | @tsv,
        (
          $video.formats
          | map(select(.vcodec != "none"))
          | sort_by(.height // 0, .fps // 0, .tbr // 0)
          | reverse
          | unique_by(.format_id)
          | .[]
          | [
              (if .acodec != "none" then .format_id else (.format_id + "+bestaudio") end),
              (
                [
                  (.format_note // empty),
                  (.resolution // (if .height then "\(.height)p" else empty end)),
                  .ext,
                  (if .fps then "\(.fps)fps" else empty end),
                  (if .dynamic_range and .dynamic_range != "SDR" then .dynamic_range else empty end),
                  (if .filesize then ((.filesize / 1048576) | floor | tostring) + "MB"
                   elif .filesize_approx then "~" + (((.filesize_approx / 1048576) | floor | tostring) + "MB")
                   else empty end)
                ]
                | map(select(length > 0))
                | join(" | ")
              )
            ]
          | @tsv
        )
    '
}

trap 'notify "Launcher failed. Check ${log_file}."' ERR

exec >>"${log_file}" 2>&1

# --wallpaper / -w: play as the desktop wallpaper (mpvpaper) instead of a window.
# Everything up to the quality selection is shared with the normal player.
wallpaper_mode=0
case "${1:-}" in
    --wallpaper | -w) wallpaper_mode=1; shift ;;
esac

require mpv
require jq
yt_dlp="$(resolve_yt_dlp)"
require rofi
[ "${wallpaper_mode}" -eq 1 ] && require mpvpaper

url="${*:-}"

if [ -z "${url}" ]; then
    url="$(prompt_text 'YouTube URL')"
fi

if [ -z "${url}" ]; then
    exit 0
fi

notify "Fetching available formats for the video..."

# Fetch video JSON
video_json="$("${yt_dlp}" -J --no-warnings "${url}")"

# Subtitles only matter for the windowed player; skip the extra calls for wallpaper.
subtitle_url=""
if [ "${wallpaper_mode}" -eq 0 ]; then
    # Detect the video's main language
    main_lang="$(printf '%s\n' "${video_json}" | jq -r '.language | if type == "string" then . else "en" end')"
    # Fetch subtitle URL cleanly, grabbing only the first valid URL
    subtitle_url="$("${yt_dlp}" --get-subs --sub-lang "${main_lang}.*" --skip-download --get-url --quiet "${url}" 2>/dev/null | head -n 1 || true)"
fi

formats="$(printf '%s\n' "${video_json}" | format_menu_entries)"
selected_format="$(printf '%s\n' "${formats}" | prompt_menu 'Quality')"

if [ -z "${selected_format}" ]; then
    exit 0
fi

format_selector="${selected_format%%$'\t'*}"

# Wallpaper mode: hand the page URL + chosen format to mpvpaper. mpv re-resolves
# via yt-dlp (so no pre-resolved URL to expire), loops silently on the background
# layer. Drop "+bestaudio" from the selector — no audio is needed for a wallpaper.
if [ "${wallpaper_mode}" -eq 1 ]; then
    notify "Starting video wallpaper…"
    pkill -x swaybg 2>/dev/null || true
    pkill -x mpvpaper 2>/dev/null || true
    exec mpvpaper -f -o "no-audio loop-file=inf hwdec=auto-safe panscan=1.0 ytdl-format=${format_selector//+bestaudio/} script-opts=ytdl_hook-ytdl_path=${yt_dlp}" '*' "${url}"
fi

mapfile -t media_urls < <(
    "${yt_dlp}" -f "${format_selector}" --get-url --sponsorblock-remove default "${url}"
)

if [ "${#media_urls[@]}" -eq 0 ]; then
    notify "Could not resolve media URL"
    exit 1
fi

mpv_args=()

if [ "${#media_urls[@]}" -eq 1 ]; then
    mpv_args=("${media_urls[0]}")
elif [ "${#media_urls[@]}" -eq 2 ]; then
    mpv_args=("${media_urls[0]}" "--audio-file=${media_urls[1]}")
else
    notify "Unexpected media stream selection"
    exit 1
fi

# Add the subtitle file AND force visibility flags
if [ -n "${subtitle_url}" ]; then
    mpv_args+=("--sub-file=${subtitle_url}" "--sub-visibility=yes" "--sid=1")
fi

exec mpv "${mpv_args[@]}"
