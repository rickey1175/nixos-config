#!/usr/bin/env bash

COVER_TMP="/tmp/hyprlock_cover.png"
FALLBACK_IMG="/home/rickey/Pictures/wallp/imgbin-halo-3-odst-halo-reach-halo-wars-halo-4-halo-s-free-uyLeGu6eSVsnUqbnZs4w2RrZi_t.webp"

# Check if playerctl finds an active art URL
URL=$(playerctl metadata mpris:artUrl 2>/dev/null)

if [ -n "$URL" ]; then
    # Strip file:// prefix if local path
    URL="${URL#file://}"
    
    if [[ "$URL" =~ ^http ]]; then
        curl -s "$URL" --output /tmp/raw_cover.png
        ffmpeg -y -i /tmp/raw_cover.png -vf "scale=160:160:force_original_aspect_ratio=increase,crop=160:160" "$COVER_TMP" 2>/dev/null
    else
        ffmpeg -y -i "$URL" -vf "scale=160:160:force_original_aspect_ratio=increase,crop=160:160" "$COVER_TMP" 2>/dev/null
    fi
else
    # STANDBY MODE: Format ODST Emblem into clean 160x160 square PNG
    if [ -f "$FALLBACK_IMG" ]; then
        ffmpeg -y -i "$FALLBACK_IMG" -vf "scale=160:160:force_original_aspect_ratio=decrease,pad=160:160:(ow-iw)/2:(oh-ih)/2:color=black@0" "$COVER_TMP" 2>/dev/null
    fi
fi