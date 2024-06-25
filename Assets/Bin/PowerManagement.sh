#!/bin/bash

xidlehook \
    --detect-sleep \
    --not-when-audio \
    --not-when-fullscreen \
    --timer 600 'xset dpms force off && if [[ $(sleep 5 && pgrep -l i3lock | wc -l) -eq 0 ]]; then Lock.sh; fi' '' &
