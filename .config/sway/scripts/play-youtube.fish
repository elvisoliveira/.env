#!/usr/bin/env fish
# Ask for a YouTube URL and a quality in rofi, then play it in mpv.
# mpv resolves the streams (split video+audio included) and the subtitles
# itself through yt-dlp, so nothing is downloaded here.

function notify
    notify-send play-youtube $argv[1]
    echo $argv[1] >&2
end

function main
    for dep in mpv yt-dlp jq rofi
        command -q $dep; or begin
            notify "Missing dependency: $dep"
            return 1
        end
    end

    set url (string join ' ' -- $argv)
    if test -z "$url"
        set url (printf '' | rofi -dmenu -i -p 'YouTube URL' -theme-str 'listview { enabled: false; }')
    end
    test -n "$url"; or return 0

    notify "Fetching available formats for the video..."
    set json (yt-dlp -J --no-warnings $url | string collect); or begin
        notify "Could not fetch the video. Check /tmp/play-youtube.log."
        return 1
    end

    # Subtitles in the video's main language (falls back to English).
    set lang (printf '%s' $json | jq -r '.language | if type == "string" then . else "en" end')

    set formats (printf '%s' $json | jq -r '
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
    ')

    # Preselect the first 360p entry (0-based row); falls back to the top row.
    set rofi_args
    set row (printf '%s\n' $formats | awk -F'\t' '$2 ~ /(^| )360p( |$)/ { print NR - 1; exit }')
    test -n "$row"; and set rofi_args -selected-row $row

    set selected (printf '%s\n' $formats | rofi -dmenu -i -p Quality $rofi_args)
    test -n "$selected"; or return 0
    set format (string split -m1 \t -- $selected)[1]

    mpv --ytdl-format=$format --ytdl-raw-options=write-subs=,sub-langs=$lang.\* -- $url
end

main $argv >>/tmp/play-youtube.log 2>&1
