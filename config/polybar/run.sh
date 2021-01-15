#!/usr/bin/env bash

# 0 --- 15, 234 --- 241(16 + 8)
colors=( $(xrdb -query | grep -P "color\d+" | cut -d"r" -f2- | sort -h | cut -f2) )
bl=${colors[4]}
bgr=${colors[10]}
ye=${colors[3]}
bblk=${colors[8]}
function _fgcolor() { echo %{F$1}$2%{F-}; }
function _bgcolor() { echo %{B$1}$2%{B-}; }
function _fbcolor() { echo %{B$1}%{F$2}$3%{B- F-} ; }
upspeed="$(_fgcolor $bl ) $(_fgcolor $ye "%upspeed%")"
downspeed="$(_fgcolor $bl ) $(_fgcolor $ye "%downspeed%")"
export SPEED_FORMAT=$(_bgcolor $bblk "$upspeed $downspeed")

pkill -u $UID -x polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar main >$XDG_DATA_HOME/polybar.log 2>&1 &
echo 'Polybar launched...'
