#!/usr/bin/env bash
# Reload Hyprland and Waybar so config changes show up right away.
command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1 || true
pkill -SIGUSR2 waybar 2>/dev/null || true
