#!/usr/bin/env bash
WALL="$1"

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
    echo "Usage: $0 /path/to/wallpaper.jpg"
    exit 1
fi

# 1. Daemon check & Wallpaper Transition
if command -v awww &>/dev/null; then
    awww query || awww-daemon &
    sleep 0.15
    awww img "$WALL" --transition-type wipe --transition-fps 60 --transition-duration 1.0
elif command -v swww &>/dev/null; then
    swww query || swww-daemon &
    sleep 0.15
    swww img "$WALL" --transition-type wipe --transition-fps 60 --transition-duration 1.0
fi

# 2. Extract Palette with Pywal
wal -i "$WALL" -n -q -s -t -e 2>/dev/null || wal -i "$WALL" -n -q -s -t

WAL_JSON="$HOME/.cache/wal/colors.json"

if [ -f "$WAL_JSON" ]; then
    BG=$(jq -r '.special.background' "$WAL_JSON")
    FG=$(jq -r '.special.foreground' "$WAL_JSON")
    C0=$(jq -r '.colors.color0' "$WAL_JSON")
    C1=$(jq -r '.colors.color1' "$WAL_JSON")
    C2=$(jq -r '.colors.color2' "$WAL_JSON")
    C3=$(jq -r '.colors.color3' "$WAL_JSON")
    C4=$(jq -r '.colors.color4' "$WAL_JSON")
    C8=$(jq -r '.colors.color8' "$WAL_JSON")

    # Hyprland hex strings (stripped '#')
    H_C2="${C2#\#}"
    H_C3="${C3#\#}"
    H_BG="${C0#\#}"

    # A. Export to Quickshell JSON
    mkdir -p "$HOME/.config/quickshell"
    cat <<EOF > "$HOME/.config/quickshell/theme.json"
{
  "barBackground": "transparent",
  "pillBg": "${C0}cc",
  "pillBorder": "${C2}66",
  "cyan": "${C2}",
  "gold": "${C3}",
  "red": "${C1}",
  "text": "${FG}",
  "inactiveText": "${C8}"
}
EOF

    # B. Export directly as QML Theme Singleton
    mkdir -p "$HOME/quickshell/modules"
    cat <<EOF > "$HOME/quickshell/modules/Theme.qml"
pragma Singleton
import QtQuick

QtObject {
    property string barBackground: "transparent"
    property string pillBg: "${C0}cc"
    property string pillBorder: "${C2}66"
    property string cyan: "${C2}"
    property string gold: "${C3}"
    property string red: "${C1}"
    property string text: "${FG}"
    property string inactiveText: "${C8}"
}
EOF

    # C. Export to Rofi Theme
    mkdir -p "$HOME/.cache/rofi"
    cat <<EOF > "$HOME/.cache/rofi/colors.rasi"
* {
    background:     ${C0}e6;
    background-alt: ${C8}33;
    foreground:     ${FG};
    selected:       ${C2};
    active:         ${C3};
    urgent:         ${C1};
}
EOF

    # D. Export to Hyprland Lua Colors Module
    mkdir -p "$HOME/.cache/hypr"
    cat <<EOF > "$HOME/.cache/hypr/colors.lua"
return {
    active_border = {
        colors = { "rgba(${H_C3}ee)", "rgba(${H_C2}ee)" },
        angle = 45
    },
    inactive_border = "rgba(${H_BG}aa)"
}
EOF

    # E. Live Border Dispatch directly to running Hyprland hl API
    hyprctl eval "hl.config({ general = { col = { active_border = { colors = { 'rgba(${H_C3}ee)', 'rgba(${H_C2}ee)' }, angle = 45 }, inactive_border = 'rgba(${H_BG}aa)' } } })"
fi