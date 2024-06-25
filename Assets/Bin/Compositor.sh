#!/bin/bash

cFilePath=$HOME/State/Compositor.txt
enabled="Y"
disabled="N"

enableCompositor() {
    status=$(cat $cFilePath)

    if [[ status != "$enabled" ]]
    then
        picom -b
        echo $enabled > $cFilePath
    fi
}

disableCompositor() {
    status=$(cat $cFilePath)

    if [[ status != "$disabled" ]]
    then
        killall picom
        echo $disabled > $cFilePath
    fi
}

if [[ $1 = "enable" ]]
then
    enableCompositor
elif [[ $1 = "disable" ]]
then
    disableCompositor
else
    echo "Invalid option $1"
    exit 1
fi
