#!/usr/bin/env python3
"""
Generate a Slack theme string from pywal's cached colors.
Usage: python3 ~/.config/wal/scripts/wal-to-slack.py
"""
import json
import os

cache_path = os.path.expanduser('~/.cache/wal/colors.json')
if not os.path.exists(cache_path):
    raise SystemExit(f"colors.json not found at {cache_path}. Run `wal -i /path/to/image` first.")

with open(cache_path) as f:
    data = json.load(f)

colors = data.get('colors', {})
# A reasonable 10-color ordering for Slack's "Paste theme" box.
slack_colors = [
    colors.get('color3', ''),        # active item / accent
    colors.get('color2', ''),        # active item text
    "#00BF76",        # channel background
    colors.get('color15', ''),       # bright text / highlights
]

# Ensure all colors are present and joined by commas
theme_line = ','.join(slack_colors)
print(theme_line)
