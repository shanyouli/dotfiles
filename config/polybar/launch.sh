#!/usr/bin/env bash

export MONITOR=${MONITOR:-$(xrandr -q | grep primary | cut -d' ' -f1)}

export LAN=${LAN:-$(grep "^en.*" /proc/net/dev | cut -d":" -f1)}

export WLP=${WLP:-$(grep "^wlp.*" /proc/net/dev | cut -d":" -f1)}
#killall -q polybar
pkill -u $UID polybar
# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
polybar -r topbar &
