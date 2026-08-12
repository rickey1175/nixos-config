#!/usr/bin/env python3
import json
import subprocess
import urllib.request
import os

CACHE_ART_PATH = "/tmp/waybar_album_art.png"

def get_media_info():
    try:
        status = subprocess.check_output(["playerctl", "status"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        artist = subprocess.check_output(["playerctl", "metadata", "artist"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        title = subprocess.check_output(["playerctl", "metadata", "title"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        art_url = subprocess.check_output(["playerctl", "metadata", "mpris:artUrl"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        
        # Download or resolve album art image to /tmp for GTK rendering
        img_path = ""
        if art_url:
            if art_url.startswith("file://"):
                img_path = art_url.replace("file://", "")
            elif art_url.startswith("http://") or art_url.startswith("https://"):
                try:
                    urllib.request.urlretrieve(art_url, CACHE_ART_PATH)
                    img_path = CACHE_ART_PATH
                except Exception:
                    img_path = ""

        icon = "󰎈" if status == "Playing" else "󰏤"
        
        # Output string format: Title - Artist (Song Title FIRST)
        display_text = f"{icon} {title} - {artist}" if artist else f"{icon} {title}"

        # Serpentine / GNOME Shell style popover layout
        tooltip_lines = []
        if img_path and os.path.exists(img_path):
            tooltip_lines.append(f"<img src='{img_path}' width='200' height='200'/>")
        
        tooltip_lines.append(f"<big><b>{title}</b></big>")
        if artist:
            tooltip_lines.append(f"<span color='#a6adc8'><i>{artist}</i></span>")
            
        tooltip_text = "\n".join(tooltip_lines)

        out = {
            "text": display_text,
            "tooltip": tooltip_text,
            "class": status.lower(),
            "alt": status
        }
        return json.dumps(out)
    except Exception:
        return json.dumps({"text": "󰎈 No Media", "class": "stopped"})

if __name__ == "__main__":
    print(get_media_info())