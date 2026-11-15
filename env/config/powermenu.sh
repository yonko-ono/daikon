#!/bin/bash

entries="⭮ Reboot\n⏻ Shutdown\n⏾ Suspend\n⇠ Logout"

selected=$(echo -e $entries| fuzzel --dmenu --width 15 --lines 4 --prompt "Power:")

case $selected in
    "⭮ Reboot")
        exec systemctl reboot
        ;;
    "⏻ Shutdown")
        exec systemctl poweroff
        ;;
    "⏾ Suspend")
        exec systemctl suspend
        ;;
    "⇠ Logout")
        hyprctl dispatch exit
        ;;
esac