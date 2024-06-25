#!/bin/bash

YAY_UPDATES=$(yay -Qum 2> /dev/null | wc -l)
ARCH_UPDATES=$(checkupdates 2> /dev/null | wc -l)
UPDATES=$(($YAY_UPDATES+$ARCH_UPDATES))

printf "%2s" "$UPDATES"
