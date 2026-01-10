#!/bin/bash
# Check if the beamer (HDMI-0) is currently connected and active
if xrandr --query | grep "^HDMI-0 connected [0-9]" > /dev/null; then
    # If active, turn it off
    xrandr --output DP-0 --mode 5120x1440 --rate 119.97 --primary --output HDMI-0 --off
else
    # If inactive, turn it on to the right of the main screen
    xrandr --output DP-0 --mode 5120x1440 --rate 119.97 --primary --output HDMI-0 --mode 1920x1080 --right-of DP-0
fi
