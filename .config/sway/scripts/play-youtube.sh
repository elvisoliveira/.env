#!/usr/bin/env bash
set -euo pipefail

log_file="/tmp/play-youtube.log"
subtitle_file="/tmp/play-youtube.vtt"
yt_dlp_cmd="${HOME}/.virtualenvs/python3/bin/yt-dlp"

notify() {
    local message="$1"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "play-youtube" "${message}"
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
    shift
    rofi -dmenu -i -p "${prompt}" "$@"
}

format_menu_entries() {
    jq -r '
        . as $video
        | ["bestvideo+bestaudio/best", "Best available"] | @tsv,
        (
          $video.formats
          | map(select(.vcodec != "none"))
          | unique_by(.format_id)
          | sort_by(.height // 0, .fps // 0, .tbr // 0)
          | reverse
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

require vlc
require curl
require jq
yt_dlp="$(resolve_yt_dlp)"
require rofi

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

# Detect the video's main language
main_lang="$(printf '%s\n' "${video_json}" | jq -r '.language | if type == "string" then . else "en" end')"
# Fetch subtitle URL cleanly, grabbing only the first valid URL
subtitle_url="$("${yt_dlp}" --get-subs --sub-lang "${main_lang}.*" --skip-download --get-url --quiet "${url}" 2>/dev/null | head -n 1 || true)"

formats="$(printf '%s\n' "${video_json}" | format_menu_entries)"
# Preselect the first 360p entry (0-based row); falls back to the top row.
default_row="$(printf '%s\n' "${formats}" | awk -F'\t' '$2 ~ /(^| )360p( |$)/ { print NR - 1; exit }')"
selected_format="$(printf '%s\n' "${formats}" | prompt_menu 'Quality' ${default_row:+-selected-row "${default_row}"})"

if [ -z "${selected_format}" ]; then
    exit 0
fi

format_selector="${selected_format%%$'\t'*}"

mapfile -t media_urls < <(
    "${yt_dlp}" -f "${format_selector}" --get-url "${url}"
)

if [ "${#media_urls[@]}" -eq 0 ]; then
    notify "Could not resolve media URL"
    exit 1
fi

vlc_args=("${media_urls[0]}")

if [ "${#media_urls[@]}" -eq 2 ]; then
    vlc_args+=("--input-slave=${media_urls[1]}")
elif [ "${#media_urls[@]}" -ne 1 ]; then
    notify "Unexpected media stream selection"
    exit 1
fi

# VLC's --sub-file only takes local paths, so download the subtitle first.
if [ -n "${subtitle_url}" ] && curl -fsSL -o "${subtitle_file}" "${subtitle_url}"; then
    vlc_args+=("--sub-file=${subtitle_file}")
fi

exec vlc "${vlc_args[@]}"
