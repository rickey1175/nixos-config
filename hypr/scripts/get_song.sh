#!/usr/bin/env bash

TITLE=$(playerctl metadata title 2>/dev/null)
ARTIST=$(playerctl metadata artist 2>/dev/null)

if [ -n "$TITLE" ]; then
    echo "$TITLE"
    echo "$ARTIST"
else
    echo "UNSC AUDIO"
    echo "STANDBY"
fi
