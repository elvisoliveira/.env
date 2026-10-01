#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME}/.config/kanshi"
CONFIG_FILE="${CONFIG_DIR}/config"
BEGIN_MARKER="# BEGIN GENERATED CURRENT PROFILE"
END_MARKER="# END GENERATED CURRENT PROFILE"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

format_refresh() {
  awk -v refresh="$1" 'BEGIN {
    hz = refresh / 1000
    if (hz == int(hz)) {
      printf "%.0fHz", hz
    } else {
      printf "%.3fHz", hz
    }
  }'
}

require swaymsg
require jq

mkdir -p "${CONFIG_DIR}"

outputs_json="$(swaymsg -t get_outputs -r)"

if [ "$(printf '%s' "${outputs_json}" | jq 'length')" -eq 0 ]; then
  printf 'No outputs returned by swaymsg.\n' >&2
  exit 1
fi

tmp_file="$(mktemp)"
block_file="$(mktemp)"
cleanup() {
  rm -f "${tmp_file}" "${block_file}"
}
trap cleanup EXIT

{
  printf '%s\n' "${BEGIN_MARKER}"
  printf '# Saved from current Sway output state.\n'
  printf 'profile current {\n'

  while IFS=$'\t' read -r name active width height refresh pos_x pos_y scale transform; do
    if [ "${active}" = "true" ]; then
      refresh_hz="$(format_refresh "${refresh}")"
      printf '    output %s enable mode %sx%s@%s position %s,%s scale %s transform %s\n' \
        "${name}" "${width}" "${height}" "${refresh_hz}" "${pos_x}" "${pos_y}" "${scale}" "${transform}"
    else
      printf '    output %s disable\n' "${name}"
    fi
  done < <(
    printf '%s' "${outputs_json}" | jq -r '
      sort_by(.rect.x, .rect.y)[] |
      [
        .name,
        .active,
        (.current_mode.width // 0),
        (.current_mode.height // 0),
        (.current_mode.refresh // 0),
        (.rect.x // 0),
        (.rect.y // 0),
        (.scale // 1),
        (.transform // "normal")
      ] | @tsv
    '
  )

  printf '}\n'
  printf '%s\n' "${END_MARKER}"
} > "${block_file}"

if [ -f "${CONFIG_FILE}" ]; then
  awk -v begin="${BEGIN_MARKER}" -v end="${END_MARKER}" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "${CONFIG_FILE}" > "${tmp_file}"

  if [ -s "${tmp_file}" ]; then
    printf '\n' >> "${tmp_file}"
  fi
fi

cat "${block_file}" >> "${tmp_file}"
mv "${tmp_file}" "${CONFIG_FILE}"

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Sway" "Saved current outputs to ~/.config/kanshi/config"
fi
