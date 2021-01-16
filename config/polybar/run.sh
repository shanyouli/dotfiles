#!/usr/bin/env bash

# 0 --- 15, 166,208,223,229,234-239,241,243,246,248,250
# 0 --- 15, 16, 17, 18, 19, 20-25,  26, 27, 28,29, 30
xrdbdata=$(xrdb -query -all)
colors=( $(echo "$xrdbdata" | grep -P "color\d+" | sed "s/\*\.color//" | sort -h | cut -f2) )
cyan=${colors[14]}
bg=$( echo "$xrdbdata" | grep "^\*\.background" | cut -f2)
fg=$( echo "$xrdbdata" | grep "^\*\.foreground" | cut -f2 )

function _fgcolor() { echo %{F$1}$2%{F-}; }
function _bgcolor() { echo %{B$1}$2%{B-}; }
function _fbcolor() { echo %{B$1}%{F$2}$3%{B- F-} ; }
upspeed="$(_fgcolor $fg ) $(_fgcolor $bg "%upspeed:3%")"
downspeed="$(_fgcolor $fg ) $(_fgcolor $bg "%downspeed:3%")"
export SPEED_FORMAT=$(_bgcolor $cyan "$upspeed $downspeed")

pkill -u $UID -x polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar main >$XDG_DATA_HOME/polybar.log 2>&1 &
echo 'Polybar launched...'
