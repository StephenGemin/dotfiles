#/usr/bin/env bash
# -*- mode:bash -*- vim:ft=bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <wallpapers_directory>"
    echo "Options:"
    echo "  -h, --help    Show this help message"
    exit 1
fi

WALLPAPERS_DIR=$1

if [ ! -d "$WALLPAPERS_DIR" ]; then
    echo "Error: Wallpaper drectory '$WALLPAPERS_DIR' does not exist."
    exit 1
fi

RANDOM_WALLPAPER=$(find "$WALLPAPERS_DIR" -type f \( -iname "*.png" -o -iname "*.bmp" -o -iname "*.jpg" -o -iname "*.jpeg" \) | shuf -n 1)
if [ -z "$RANDOM_WALLPAPER" ]; then
    echo "Error: No image files found in '$WALLPAPERS_DIR'."
    exit 1
fi
gsettings set org.gnome.desktop.background picture-uri "file://$RANDOM_WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$RANDOM_WALLPAPER"
